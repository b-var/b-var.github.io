import SwiftUI

struct AlarmCard: View {
    let record: AlarmRecord

    var body: some View {
        HStack(spacing: 14) {
            // Time column
            VStack(alignment: .leading, spacing: 2) {
                Text(record.scheduledTime.sonaTimeString)
                    .font(.sonaBold(18))
                    .foregroundStyle(.sonaTextPrimary)
                Text(record.label)
                    .font(.sonaCaption())
                    .foregroundStyle(.sonaTextSecondary)
            }
            .frame(width: 80, alignment: .leading)

            Divider()
                .frame(height: 36)
                .overlay(Color.sonaSurface2)

            // Status and factors
            VStack(alignment: .leading, spacing: 5) {
                StatusBadge(status: record.status)
                if !record.silenceFactors.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(record.silenceFactors.prefix(3)) { factor in
                            HStack(spacing: 3) {
                                Image(systemName: factor.icon)
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundStyle(factor.severityColor)
                                Text(factor.rawValue)
                                    .font(.sonaCaption(10))
                                    .foregroundStyle(factor.severityColor)
                            }
                        }
                        if record.silenceFactors.count > 3 {
                            Text("+\(record.silenceFactors.count - 3)")
                                .font(.sonaCaption(10))
                                .foregroundStyle(.sonaTextTertiary)
                        }
                    }
                }
            }

            Spacer()

            // Latency or chevron
            VStack(alignment: .trailing, spacing: 2) {
                if let latency = record.latencyLabel {
                    Text(latency)
                        .font(.sonaMono(11))
                        .foregroundStyle(.sonaTextSecondary)
                    Text("response")
                        .font(.sonaCaption(9))
                        .foregroundStyle(.sonaTextTertiary)
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.sonaTextTertiary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.sonaSurface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(
                    record.isProblematic
                        ? Color.sonaError.opacity(0.25)
                        : Color.sonaSurface2.opacity(0.6),
                    lineWidth: 1
                )
        )
    }
}

struct RuleCard: View {
    let rule: AlarmRule
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text(rule.timeString)
                    .font(.sonaDisplay(28))
                    .foregroundStyle(rule.isEnabled ? .sonaTextPrimary : .sonaTextTertiary)
                Text(rule.label)
                    .font(.sonaHeadline())
                    .foregroundStyle(rule.isEnabled ? .sonaTextPrimary : .sonaTextTertiary)
                Text(rule.repeatLabel)
                    .font(.sonaCaption())
                    .foregroundStyle(.sonaTextSecondary)
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { rule.isEnabled },
                set: { _ in onToggle() }
            ))
            .tint(.sonaAccent)
            .labelsHidden()
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(Color.sonaSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    rule.isEnabled
                        ? LinearGradient.sonaBrand.opacity(0.4)
                        : Color.sonaSurface2.opacity(0.5),
                    lineWidth: 1
                )
        )
    }
}
