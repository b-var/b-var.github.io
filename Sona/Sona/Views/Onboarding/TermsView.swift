import SwiftUI

struct TermsView: View {
    @AppStorage("hasAcceptedTerms") private var hasAcceptedTerms = false
    @State private var scrolledToBottom = false
    @State private var appeared = false

    var body: some View {
        ZStack {
            LinearGradient.sonaBackgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Logo header
                VStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient.sonaBrand.opacity(0.15))
                            .frame(width: 80, height: 80)
                        Image(systemName: "waveform.circle.fill")
                            .font(.system(size: 44, weight: .light))
                            .foregroundStyle(LinearGradient.sonaBrand)
                    }
                    GradientText(text: "Sona", font: .sonaDisplay(36))
                    Text("Your alarm story, simplified.")
                        .font(.sonaBody())
                        .foregroundStyle(.sonaTextSecondary)
                }
                .padding(.top, 56)
                .padding(.bottom, 32)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : -20)

                // Terms scroll
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        termsSection(title: "1. Acceptance of Terms",
                            body: "By using Sona, you agree to these Terms of Service. If you do not agree, please do not use the app.")

                        termsSection(title: "2. What Sona Does",
                            body: "Sona schedules local alarm notifications on your device, monitors whether those alarms fired and were acknowledged, and logs contextual system data (volume level, Focus mode status, silent switch state) at alarm time. All data is stored on your device or in your personal iCloud Drive. Sona never transmits your alarm data to external servers.")

                        termsSection(title: "3. Data Storage & Privacy",
                            body: "Your alarm records, rules, and logs are stored exclusively on your device and optionally synced to your personal iCloud Drive account. Sona does not collect, share, or sell personal data. Logs are retained until you explicitly delete them.")

                        termsSection(title: "4. Notification Permissions",
                            body: "Sona requires notification permissions to schedule and deliver alarm notifications. Without this permission, alarms cannot fire. You may manage notification permissions at any time in iOS Settings.")

                        termsSection(title: "5. Limitations",
                            body: "Sona cannot access alarms created in Apple's built-in Clock app. Sona alarms are separate notifications managed within this app. System-level interruptions (DND, Focus modes, silent switch) may affect alarm delivery in ways outside Sona's control.")

                        termsSection(title: "6. No Warranty",
                            body: "Sona is provided 'as is' without warranty of any kind. It should not be used as the sole means of waking for critical obligations. Always maintain a backup alarm method.")

                        termsSection(title: "7. Changes to Terms",
                            body: "We may update these terms. Continued use of Sona constitutes acceptance of updated terms.")

                        // Scroll sentinel
                        Color.clear.frame(height: 1)
                            .onAppear { scrolledToBottom = true }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
                .background(Color.sonaSurface.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 20)
                .opacity(appeared ? 1 : 0)

                // Agree button
                Button {
                    hasAcceptedTerms = true
                } label: {
                    Text("I Agree & Continue")
                        .font(.sonaBold(16))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            scrolledToBottom
                                ? LinearGradient.sonaBrand
                                : LinearGradient(colors: [.sonaTextTertiary, .sonaTextTertiary],
                                                  startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(!scrolledToBottom)
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
            }
        }
        .onAppear {
            withAnimation(.spring(duration: 0.7)) { appeared = true }
        }
    }

    @ViewBuilder
    private func termsSection(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.sonaHeadline())
                .foregroundStyle(.sonaTextPrimary)
            Text(body)
                .font(.sonaBody(14))
                .foregroundStyle(.sonaTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
