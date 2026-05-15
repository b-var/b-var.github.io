import Foundation

struct AlarmRecord: Identifiable, Codable, Equatable {
    var id: UUID
    var alarmRuleID: UUID
    var label: String
    var scheduledTime: Date
    var firedTime: Date?
    var acknowledgedTime: Date?
    var status: AlarmStatus
    var silenceFactors: [SilenceFactor]
    var deviceVolume: Float?
    var isSilentMode: Bool
    var isFocusActive: Bool
    var focusModeName: String?
    var attentionAwarenessEnabled: Bool
    var notificationsAllowed: Bool
    var notes: String

    init(
        id: UUID = UUID(),
        alarmRuleID: UUID,
        label: String,
        scheduledTime: Date,
        status: AlarmStatus = .pending,
        silenceFactors: [SilenceFactor] = [],
        deviceVolume: Float? = nil,
        isSilentMode: Bool = false,
        isFocusActive: Bool = false,
        focusModeName: String? = nil,
        attentionAwarenessEnabled: Bool = false,
        notificationsAllowed: Bool = true,
        notes: String = ""
    ) {
        self.id = id
        self.alarmRuleID = alarmRuleID
        self.label = label
        self.scheduledTime = scheduledTime
        self.status = status
        self.silenceFactors = silenceFactors
        self.deviceVolume = deviceVolume
        self.isSilentMode = isSilentMode
        self.isFocusActive = isFocusActive
        self.focusModeName = focusModeName
        self.attentionAwarenessEnabled = attentionAwarenessEnabled
        self.notificationsAllowed = notificationsAllowed
        self.notes = notes
    }

    var isProblematic: Bool {
        status.isProblematic || !silenceFactors.isEmpty
    }

    var responseLatency: TimeInterval? {
        guard let fired = firedTime, let ack = acknowledgedTime else { return nil }
        return ack.timeIntervalSince(fired)
    }

    var latencyLabel: String? {
        guard let seconds = responseLatency else { return nil }
        if seconds < 60 { return "\(Int(seconds))s" }
        return "\(Int(seconds / 60))m \(Int(seconds.truncatingRemainder(dividingBy: 60)))s"
    }
}

// MARK: - AlarmStatus

enum AlarmStatus: String, Codable, CaseIterable, Identifiable {
    case fired      = "Fired"
    case missed     = "Missed"
    case dismissed  = "Dismissed"
    case snoozed    = "Snoozed"
    case silenced   = "Silenced"
    case pending    = "Pending"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .fired:     return "checkmark.circle.fill"
        case .missed:    return "xmark.circle.fill"
        case .dismissed: return "hand.raised.fill"
        case .snoozed:   return "zzz"
        case .silenced:  return "speaker.slash.fill"
        case .pending:   return "clock.fill"
        }
    }

    var isProblematic: Bool { self == .missed || self == .silenced }

    var displayColor: String {
        switch self {
        case .fired:     return "sonaSuccess"
        case .missed:    return "sonaError"
        case .dismissed: return "sonaWarning"
        case .snoozed:   return "sonaPurple"
        case .silenced:  return "sonaTextSecondary"
        case .pending:   return "sonaAccent"
        }
    }
}
