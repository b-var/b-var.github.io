import Foundation
import SwiftUI

enum SilenceFactor: String, Codable, CaseIterable, Identifiable {
    case userDismissed      = "User Dismissed"
    case userSnoozed        = "User Snoozed"
    case attentionAwareness = "Attention Awareness"
    case doNotDisturb       = "Do Not Disturb"
    case focusMode          = "Focus Mode Active"
    case silentMode         = "Silent Mode On"
    case lowVolume          = "Volume Too Low"
    case systemOverride     = "System Override"
    case notificationDenied = "Notifications Denied"
    case appBackground      = "App Backgrounded"
    case unknown            = "Unknown Reason"

    var id: String { rawValue }

    var detail: String {
        switch self {
        case .userDismissed:
            return "You manually dismissed the alarm by swiping or tapping Dismiss."
        case .userSnoozed:
            return "You chose to snooze the alarm."
        case .attentionAwareness:
            return "Attention Awareness (Settings → Accessibility → Face ID & Attention) detected you were looking at your device and automatically lowered the alarm volume."
        case .doNotDisturb:
            return "Do Not Disturb was active at alarm time and suppressed the notification."
        case .focusMode:
            return "A Focus mode (Sleep, Work, Personal, etc.) was active and filtered the alarm."
        case .silentMode:
            return "The device's hardware Silent switch was enabled, muting the alarm."
        case .lowVolume:
            return "Device volume was below 20% — the alarm may not have been audible."
        case .systemOverride:
            return "A system-level policy or MDM profile overrode the alarm."
        case .notificationDenied:
            return "Sona does not have notification permission. Grant it in Settings → Sona → Notifications."
        case .appBackground:
            return "The app was in the background and notification delivery was delayed by the system."
        case .unknown:
            return "The reason for alarm failure could not be determined from available logs."
        }
    }

    var icon: String {
        switch self {
        case .userDismissed:      return "hand.raised.fill"
        case .userSnoozed:        return "zzz"
        case .attentionAwareness: return "eye.fill"
        case .doNotDisturb:       return "moon.fill"
        case .focusMode:          return "person.crop.circle.fill"
        case .silentMode:         return "speaker.slash.fill"
        case .lowVolume:          return "speaker.wave.1.fill"
        case .systemOverride:     return "lock.shield.fill"
        case .notificationDenied: return "bell.slash.fill"
        case .appBackground:      return "arrow.down.app.fill"
        case .unknown:            return "questionmark.circle.fill"
        }
    }

    var severity: Severity {
        switch self {
        case .userDismissed, .userSnoozed, .appBackground:
            return .info
        case .attentionAwareness, .focusMode, .doNotDisturb, .lowVolume:
            return .warning
        case .silentMode, .notificationDenied, .systemOverride, .unknown:
            return .critical
        }
    }

    enum Severity { case info, warning, critical }

    var severityColor: Color {
        switch severity {
        case .info:     return .sonaTextSecondary
        case .warning:  return .sonaWarning
        case .critical: return .sonaError
        }
    }
}
