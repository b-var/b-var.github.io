import SwiftUI

struct StatusBadge: View {
    let status: AlarmStatus
    var compact: Bool = false

    private var color: Color {
        switch status {
        case .fired:     return .sonaSuccess
        case .missed:    return .sonaError
        case .dismissed: return .sonaWarning
        case .snoozed:   return .sonaPurple
        case .silenced:  return .sonaTextSecondary
        case .pending:   return .sonaAccent
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.icon)
                .font(.system(size: compact ? 10 : 11, weight: .semibold))
            if !compact {
                Text(status.rawValue)
                    .font(.sonaCaption(11))
                    .fontWeight(.semibold)
            }
        }
        .foregroundStyle(color)
        .padding(.horizontal, compact ? 6 : 8)
        .padding(.vertical, compact ? 3 : 4)
        .background(color.opacity(0.15))
        .clipShape(Capsule())
    }
}

struct SeverityDot: View {
    let factor: SilenceFactor
    var body: some View {
        Circle()
            .fill(factor.severityColor)
            .frame(width: 7, height: 7)
    }
}
