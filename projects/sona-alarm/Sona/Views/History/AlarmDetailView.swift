import SwiftUI

struct AlarmDetailView: View {
    let record: AlarmRecord
    @Environment(\.dismiss) private var dismiss
    @State private var isInvestigating = true

    var body: some View {
        ZStack {
            LinearGradient.sonaBackgroundGradient.ignoresSafeArea()

            if isInvestigating {
                investigatingView
            } else {
                resultView
            }
        }
        .navigationTitle(record.label)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(record.label)
                    .font(.sonaHeadline())
                    .foregroundStyle(.sonaTextPrimary)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    isInvestigating = false
                }
            }
        }
    }

    // MARK: - Investigating / Ad placeholder

    private var investigatingView: some View {
        VStack(spacing: 28) {
            Spacer()

            // Animated investigating indicator
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.sonaAccent.opacity(0.12))
                        .frame(width: 72, height: 72)
                    Image(systemName: "waveform.circle.fill")
                        .font(.system(size: 36, weight: .light))
                        .foregroundStyle(LinearGradient.sonaBrand)
                }
                Text("Investigating…")
                    .font(.sonaTitle())
                    .foregroundStyle(.sonaTextPrimary)
                Text("Analysing your alarm data")
                    .font(.sonaBody())
                    .foregroundStyle(.sonaTextSecondary)
                ProgressView()
                    .tint(.sonaAccent)
            }

            Spacer()

            // Advertisement placeholder
            adPlaceholder

            Spacer(minLength: 24)
        }
        .padding(.horizontal, 24)
    }

    private var adPlaceholder: some View {
        VStack(spacing: 8) {
            Text("Advertisement")
                .font(.sonaCaption(10))
                .foregroundStyle(.sonaTextTertiary)
                .frame(maxWidth: .infinity, alignment: .center)

            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.sonaSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.sonaSurface2, lineWidth: 1)
                    )

                VStack(spacing: 6) {
                    Image(systemName: "rectangle.on.rectangle.angled")
                        .font(.system(size: 28, weight: .light))
                        .foregroundStyle(.sonaTextTertiary)
                    Text("Ad Placeholder")
                        .font(.sonaHeadline(14))
                        .foregroundStyle(.sonaTextTertiary)
                    Text("Your ad could appear here")
                        .font(.sonaCaption())
                        .foregroundStyle(.sonaTextTertiary.opacity(0.6))
                }
                .padding(.vertical, 24)
            }
            .frame(height: 120)
        }
    }

    // MARK: - Results

    private var resultView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {

                // Status hero
                statusHero

                    // Timeline
                    timelineSection

                    // Silence factors
                    if !record.silenceFactors.isEmpty {
                        silenceFactorsSection
                    }

                    // System snapshot
                    systemSnapshotSection

                    // Notes
                    if !record.notes.isEmpty {
                        notesSection
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
        }

    // MARK: - Sub-sections

    private var statusHero: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.12))
                    .frame(width: 80, height: 80)
                Image(systemName: record.status.icon)
                    .font(.system(size: 36, weight: .light))
                    .foregroundStyle(statusColor)
            }
            Text(record.status.rawValue)
                .font(.sonaTitle())
                .foregroundStyle(statusColor)
            Text(record.scheduledTime.sonaDateString)
                .font(.sonaBody())
                .foregroundStyle(.sonaTextSecondary)
            Text(record.scheduledTime.sonaTimeString)
                .font(.sonaDisplay(38))
                .foregroundStyle(.sonaTextPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(Color.sonaSurface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(statusColor.opacity(0.25), lineWidth: 1)
        )
    }

    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionTitle("Timeline")
            VStack(spacing: 0) {
                timelineRow(
                    icon: "clock.fill",
                    color: .sonaAccent,
                    title: "Scheduled",
                    time: record.scheduledTime.sonaTimeString,
                    isLast: false
                )
                if let fired = record.firedTime {
                    timelineRow(
                        icon: "bell.fill",
                        color: .sonaSuccess,
                        title: "Alarm Fired",
                        time: fired.sonaTimeString,
                        isLast: record.acknowledgedTime == nil
                    )
                }
                if let ack = record.acknowledgedTime {
                    timelineRow(
                        icon: record.status == .snoozed ? "zzz" : "hand.raised.fill",
                        color: record.status == .snoozed ? .sonaPurple : .sonaWarning,
                        title: record.status == .snoozed ? "Snoozed" : "Dismissed",
                        time: ack.sonaTimeString,
                        isLast: true,
                        subtitle: record.latencyLabel.map { "Response: \($0)" }
                    )
                }
                if record.firedTime == nil {
                    timelineRow(
                        icon: "xmark.circle.fill",
                        color: .sonaError,
                        title: "Never Fired",
                        time: "—",
                        isLast: true,
                        subtitle: "Alarm was silenced before delivery"
                    )
                }
            }
            .padding(.horizontal, 16)
            .background(Color.sonaSurface)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private var silenceFactorsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("Silence Factors Detected")
            ForEach(record.silenceFactors) { factor in
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(factor.severityColor.opacity(0.12))
                            .frame(width: 36, height: 36)
                        Image(systemName: factor.icon)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(factor.severityColor)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Text(factor.rawValue)
                                .font(.sonaHeadline(14))
                                .foregroundStyle(.sonaTextPrimary)
                            severityTag(factor.severity)
                        }
                        Text(factor.detail)
                            .font(.sonaBody(13))
                            .foregroundStyle(.sonaTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(14)
                .background(Color.sonaSurface)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(factor.severityColor.opacity(0.2), lineWidth: 1)
                )
            }
        }
    }

    private var systemSnapshotSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("System Snapshot at Alarm Time")
            VStack(spacing: 0) {
                snapshotRow("Volume", value: record.deviceVolume.map { "\(Int($0 * 100))%" } ?? "Unknown",
                    icon: "speaker.wave.2.fill",
                    color: (record.deviceVolume ?? 1) < 0.2 ? .sonaError : .sonaSuccess)
                Divider().overlay(Color.sonaSurface2).padding(.leading, 46)
                snapshotRow("Silent Mode", value: record.isSilentMode ? "On" : "Off",
                    icon: "speaker.slash.fill",
                    color: record.isSilentMode ? .sonaError : .sonaSuccess)
                Divider().overlay(Color.sonaSurface2).padding(.leading, 46)
                snapshotRow("Focus Mode", value: record.isFocusActive ? (record.focusModeName ?? "Active") : "Off",
                    icon: "person.crop.circle.fill",
                    color: record.isFocusActive ? .sonaWarning : .sonaSuccess)
                Divider().overlay(Color.sonaSurface2).padding(.leading, 46)
                snapshotRow("Attention Awareness", value: record.attentionAwarenessEnabled ? "Enabled" : "Off",
                    icon: "eye.fill",
                    color: record.attentionAwarenessEnabled ? .sonaWarning : .sonaSuccess)
                Divider().overlay(Color.sonaSurface2).padding(.leading, 46)
                snapshotRow("Notifications", value: record.notificationsAllowed ? "Allowed" : "Denied",
                    icon: "bell.fill",
                    color: record.notificationsAllowed ? .sonaSuccess : .sonaError)
            }
            .background(Color.sonaSurface)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("Notes")
            Text(record.notes)
                .font(.sonaBody())
                .foregroundStyle(.sonaTextSecondary)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.sonaSurface)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    // MARK: - Row builders

    @ViewBuilder
    private func timelineRow(icon: String, color: Color, title: String, time: String, isLast: Bool, subtitle: String? = nil) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 0) {
                ZStack {
                    Circle().fill(color.opacity(0.15)).frame(width: 28, height: 28)
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(color)
                }
                if !isLast {
                    Rectangle()
                        .fill(Color.sonaSurface2)
                        .frame(width: 1)
                        .frame(maxHeight: .infinity)
                        .padding(.vertical, 2)
                }
            }
            .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(title)
                        .font(.sonaHeadline(14))
                        .foregroundStyle(.sonaTextPrimary)
                    Spacer()
                    Text(time)
                        .font(.sonaMono(13))
                        .foregroundStyle(.sonaTextSecondary)
                }
                if let sub = subtitle {
                    Text(sub)
                        .font(.sonaCaption())
                        .foregroundStyle(.sonaTextTertiary)
                }
            }
            .padding(.vertical, 12)
        }
    }

    @ViewBuilder
    private func snapshotRow(_ title: String, value: String, icon: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(color)
                .frame(width: 22)
            Text(title)
                .font(.sonaBody(14))
                .foregroundStyle(.sonaTextSecondary)
            Spacer()
            Text(value)
                .font(.sonaBold(14))
                .foregroundStyle(color)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }

    @ViewBuilder
    private func severityTag(_ severity: SilenceFactor.Severity) -> some View {
        let (label, color): (String, Color) = {
            switch severity {
            case .info:     return ("Info",     .sonaTextSecondary)
            case .warning:  return ("Warning",  .sonaWarning)
            case .critical: return ("Critical", .sonaError)
            }
        }()
        Text(label)
            .font(.sonaCaption(10))
            .fontWeight(.semibold)
            .foregroundStyle(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }

    @ViewBuilder
    private func sectionTitle(_ t: String) -> some View {
        Text(t)
            .font(.sonaHeadline(13))
            .foregroundStyle(.sonaTextSecondary)
            .padding(.bottom, 6)
    }

    private var statusColor: Color {
        switch record.status {
        case .fired:     return .sonaSuccess
        case .missed:    return .sonaError
        case .dismissed: return .sonaWarning
        case .snoozed:   return .sonaPurple
        case .silenced:  return .sonaTextSecondary
        case .pending:   return .sonaAccent
        }
    }
}
