import Foundation
import Combine
import UserNotifications

@MainActor
final class AlarmHistoryViewModel: ObservableObject {

    // MARK: - Published State

    @Published var rules: [AlarmRule]   = []
    @Published var records: [AlarmRecord] = []
    @Published var notificationsGranted: Bool = false

    private let storage  = LogStorageService.shared
    private let monitor  = AlarmMonitorService.shared

    // MARK: - Derived

    var todayRecords: [AlarmRecord] {
        records.filter { $0.scheduledTime.isToday }
            .sorted { $0.scheduledTime > $1.scheduledTime }
    }

    var todayFired: Int   { todayRecords.filter { $0.status == .fired }.count }
    var todayIssues: Int  { todayRecords.filter { $0.isProblematic }.count }

    var groupedHistory: [(day: Date, records: [AlarmRecord])] {
        let grouped = Dictionary(grouping: records) { $0.scheduledTime.dayStart }
        return grouped
            .map { (day: $0.key, records: $0.value.sorted { $0.scheduledTime > $1.scheduledTime }) }
            .sorted { $0.day > $1.day }
    }

    var last10DaysRecords: [AlarmRecord] {
        let cutoff = Date.daysAgo(10)
        return records.filter { $0.scheduledTime >= cutoff }
    }

    // MARK: - Lifecycle

    init() {
        load()
        Task { await checkPermissions() }
    }

    func load() {
        rules   = storage.loadRules()
        records = storage.loadRecords()
    }

    func refresh() {
        load()
    }

    // MARK: - Alarm Rules CRUD

    func addRule(_ rule: AlarmRule) {
        rules.append(rule)
        save()
        monitor.scheduleAlarm(rule)
    }

    func updateRule(_ rule: AlarmRule) {
        guard let i = rules.firstIndex(where: { $0.id == rule.id }) else { return }
        monitor.cancelAlarm(rules[i])
        rules[i] = rule
        save()
        if rule.isEnabled { monitor.scheduleAlarm(rule) }
    }

    func deleteRule(_ rule: AlarmRule) {
        monitor.cancelAlarm(rule)
        rules.removeAll { $0.id == rule.id }
        save()
    }

    func toggleRule(_ rule: AlarmRule) {
        var updated = rule
        updated.isEnabled.toggle()
        updateRule(updated)
    }

    // MARK: - Records

    func addManualRecord(_ record: AlarmRecord) {
        records.append(record)
        storage.appendRecord(record)
    }

    func updateRecord(_ record: AlarmRecord) {
        if let i = records.firstIndex(where: { $0.id == record.id }) {
            records[i] = record
        }
        storage.appendRecord(record)
    }

    func clearHistory() {
        records.removeAll()
        storage.clearAllRecords()
    }

    // MARK: - Permissions

    func requestPermissions() async {
        notificationsGranted = await monitor.requestPermissions()
    }

    func checkPermissions() async {
        let status = await monitor.notificationAuthStatus()
        notificationsGranted = status == .authorized || status == .provisional
    }

    // MARK: - Export helpers

    func csvString() -> String {
        ExportService.shared.generateCSV(from: last10DaysRecords)
    }

    func txtString() -> String {
        ExportService.shared.generateTXT(from: last10DaysRecords)
    }

    func exportFilename(ext: String) -> String {
        let date = Date().sonaCSVString.replacingOccurrences(of: " ", with: "_").replacingOccurrences(of: ":", with: "-")
        return "sona_alarm_history_\(date).\(ext)"
    }

    // MARK: - Persistence

    private func save() {
        storage.saveRules(rules)
    }

    // MARK: - Seed demo data (first launch)

    func seedDemoDataIfNeeded() {
        guard records.isEmpty && rules.isEmpty else { return }

        let demoRule = AlarmRule(label: "Morning", hour: 7, minute: 30, repeatDays: [.monday, .tuesday, .wednesday, .thursday, .friday])
        rules.append(demoRule)
        storage.saveRules(rules)

        let now = Date()
        var demoRecords: [AlarmRecord] = []

        // Day 0 — today
        demoRecords.append(AlarmRecord(alarmRuleID: demoRule.id, label: "Morning",
            scheduledTime: Calendar.current.date(bySettingHour: 7, minute: 30, second: 0, of: now)!,
            status: .fired, deviceVolume: 0.8))

        // Day 1 — silenced by attention awareness
        let d1 = Date.daysAgo(1)
        demoRecords.append(AlarmRecord(alarmRuleID: demoRule.id, label: "Morning",
            scheduledTime: Calendar.current.date(bySettingHour: 7, minute: 30, second: 0, of: d1)!,
            status: .silenced, silenceFactors: [.attentionAwareness],
            deviceVolume: 0.6, attentionAwarenessEnabled: true))

        // Day 2 — snoozed
        let d2 = Date.daysAgo(2)
        demoRecords.append(AlarmRecord(alarmRuleID: demoRule.id, label: "Morning",
            scheduledTime: Calendar.current.date(bySettingHour: 7, minute: 30, second: 0, of: d2)!,
            status: .snoozed, silenceFactors: [.userSnoozed], deviceVolume: 0.7))

        // Day 3 — silent mode
        let d3 = Date.daysAgo(3)
        demoRecords.append(AlarmRecord(alarmRuleID: demoRule.id, label: "Morning",
            scheduledTime: Calendar.current.date(bySettingHour: 7, minute: 30, second: 0, of: d3)!,
            status: .missed, silenceFactors: [.silentMode], deviceVolume: 0.0, isSilentMode: true))

        // Day 4 — focus mode
        let d4 = Date.daysAgo(4)
        demoRecords.append(AlarmRecord(alarmRuleID: demoRule.id, label: "Morning",
            scheduledTime: Calendar.current.date(bySettingHour: 7, minute: 30, second: 0, of: d4)!,
            status: .silenced, silenceFactors: [.focusMode], isFocusActive: true, focusModeName: "Sleep"))

        demoRecords.forEach { storage.appendRecord($0) }
        records = storage.loadRecords()
    }
}
