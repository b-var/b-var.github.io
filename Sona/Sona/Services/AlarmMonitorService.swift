import Foundation
import UserNotifications
import AVFoundation

/// Schedules local notifications from AlarmRule objects, handles responses,
/// and captures system context (volume, silent mode, Focus) at alarm time.
final class AlarmMonitorService: NSObject, ObservableObject, UNUserNotificationCenterDelegate {

    static let shared = AlarmMonitorService()

    private let center = UNUserNotificationCenter.current()
    private let storage = LogStorageService.shared

    // Pending records waiting for acknowledgment (in memory)
    private var pendingRecords: [UUID: AlarmRecord] = [:]

    // Notification category identifiers
    private let alarmCategoryID  = "SONA_ALARM"
    private let snoozeActionID   = "SNOOZE"
    private let dismissActionID  = "DISMISS"

    override init() {
        super.init()
        center.delegate = self
        registerCategories()
    }

    // MARK: - Permissions

    func requestPermissions() async -> Bool {
        let granted = (try? await center.requestAuthorization(options: [.alert, .sound, .badge, .criticalAlert])) ?? false
        return granted
    }

    func notificationAuthStatus() async -> UNAuthorizationStatus {
        await center.notificationSettings().authorizationStatus
    }

    // MARK: - Scheduling

    func scheduleAlarm(_ rule: AlarmRule) {
        guard rule.isEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = rule.label
        content.body  = "Your alarm is ringing."
        content.sound = .defaultCritical
        content.categoryIdentifier = alarmCategoryID
        content.userInfo = [
            "ruleID": rule.id.uuidString,
            "label": rule.label
        ]

        if rule.repeatDays.isEmpty {
            // One-time alarm
            var comps = DateComponents()
            comps.hour   = rule.hour
            comps.minute = rule.minute
            comps.second = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            let request = UNNotificationRequest(
                identifier: "sona-\(rule.id.uuidString)",
                content: content,
                trigger: trigger
            )
            center.add(request)
        } else {
            for day in rule.repeatDays {
                var comps = DateComponents()
                comps.weekday = day.rawValue
                comps.hour    = rule.hour
                comps.minute  = rule.minute
                comps.second  = 0
                let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
                let request = UNNotificationRequest(
                    identifier: "sona-\(rule.id.uuidString)-\(day.rawValue)",
                    content: content,
                    trigger: trigger
                )
                center.add(request)
            }
        }
    }

    func cancelAlarm(_ rule: AlarmRule) {
        var ids = ["sona-\(rule.id.uuidString)"]
        for day in AlarmRule.Weekday.allCases {
            ids.append("sona-\(rule.id.uuidString)-\(day.rawValue)")
        }
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }

    func rescheduleAll(rules: [AlarmRule]) {
        center.removeAllPendingNotificationRequests()
        for rule in rules where rule.isEnabled {
            scheduleAlarm(rule)
        }
    }

    // MARK: - System Context Snapshot

    func captureSystemContext() -> (volume: Float, isSilent: Bool) {
        let session = AVAudioSession.sharedInstance()
        try? session.setActive(true)
        let volume = session.outputVolume
        // Silent mode: best-effort via output route (no earphones + Ring/Silent switch is undocumented)
        let isSilent = volume == 0
        return (volume, isSilent)
    }

    // MARK: - UNUserNotificationCenterDelegate

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        recordFired(notification: notification)
        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let notifID = response.notification.request.identifier
        let info    = response.notification.request.content.userInfo
        let ruleIDStr = info["ruleID"] as? String ?? ""
        let label     = info["label"] as? String ?? "Alarm"

        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            finalize(notifID: notifID, ruleIDStr: ruleIDStr, label: label, status: .dismissed, factors: [.userDismissed])
        case dismissActionID:
            finalize(notifID: notifID, ruleIDStr: ruleIDStr, label: label, status: .dismissed, factors: [.userDismissed])
        case snoozeActionID:
            finalize(notifID: notifID, ruleIDStr: ruleIDStr, label: label, status: .snoozed, factors: [.userSnoozed])
        default:
            finalize(notifID: notifID, ruleIDStr: ruleIDStr, label: label, status: .dismissed, factors: [])
        }
        completionHandler()
    }

    // MARK: - Record Helpers

    private func recordFired(notification: UNNotification) {
        let info      = notification.request.content.userInfo
        let ruleIDStr = info["ruleID"] as? String ?? ""
        let label     = info["label"] as? String ?? "Alarm"
        let ruleID    = UUID(uuidString: ruleIDStr) ?? UUID()
        let (vol, silent) = captureSystemContext()
        var factors: [SilenceFactor] = []
        if silent          { factors.append(.silentMode) }
        if vol < 0.2       { factors.append(.lowVolume) }

        var record = AlarmRecord(
            alarmRuleID: ruleID,
            label: label,
            scheduledTime: notification.date,
            status: .fired,
            silenceFactors: factors,
            deviceVolume: vol,
            isSilentMode: silent,
            notificationsAllowed: true
        )
        record.firedTime = Date()
        pendingRecords[record.id] = record
        storage.appendRecord(record)
    }

    private func finalize(notifID: String, ruleIDStr: String, label: String, status: AlarmStatus, factors: [SilenceFactor]) {
        // Update the most-recent pending record for this rule
        if let key = pendingRecords.keys.first(where: {
            pendingRecords[$0]?.alarmRuleID.uuidString == ruleIDStr
        }) {
            var record = pendingRecords[key]!
            record.status            = status
            record.acknowledgedTime  = Date()
            record.silenceFactors    = Array(Set(record.silenceFactors + factors))
            pendingRecords.removeValue(forKey: key)
            storage.appendRecord(record)
        } else {
            // Notification tapped without willPresent (cold launch)
            let ruleID  = UUID(uuidString: ruleIDStr) ?? UUID()
            let (vol, silent) = captureSystemContext()
            var newFactors = factors
            if silent    { newFactors.append(.silentMode) }
            if vol < 0.2 { newFactors.append(.lowVolume)  }
            let record = AlarmRecord(
                alarmRuleID: ruleID,
                label: label,
                scheduledTime: Date(),
                status: status,
                silenceFactors: Array(Set(newFactors)),
                deviceVolume: vol,
                isSilentMode: silent,
                notificationsAllowed: true
            )
            storage.appendRecord(record)
        }
    }

    // MARK: - Categories

    private func registerCategories() {
        let snooze  = UNNotificationAction(identifier: snoozeActionID,  title: "Snooze",  options: [])
        let dismiss = UNNotificationAction(identifier: dismissActionID, title: "Dismiss", options: [.destructive])
        let category = UNNotificationCategory(
            identifier: alarmCategoryID,
            actions: [snooze, dismiss],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        center.setNotificationCategories([category])
    }
}
