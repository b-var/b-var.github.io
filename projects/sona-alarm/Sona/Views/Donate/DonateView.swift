import SwiftUI

struct DonateView: View {
    private let paypalURL = URL(string: "https://paypal.me/bobosv")!

    var body: some View {
        ZStack {
            LinearGradient.sonaBackgroundGradient.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    Spacer(minLength: 20)

                    // Heart icon
                    ZStack {
                        Circle()
                            .fill(LinearGradient.sonaBrand.opacity(0.15))
                            .frame(width: 100, height: 100)
                        Image(systemName: "heart.fill")
                            .font(.system(size: 48, weight: .light))
                            .foregroundStyle(LinearGradient.sonaBrand)
                    }

                    // Thank you message
                    VStack(spacing: 12) {
                        GradientText("Thank You", font: .sonaDisplay(32))

                        Text("Your support means everything.")
                            .font(.sonaTitle())
                            .foregroundStyle(.sonaTextPrimary)
                            .multilineTextAlignment(.center)

                        Text("Sona is built and maintained by a solo developer. If this app has helped you understand your alarm habits, a small donation keeps the lights on and new features coming.")
                            .font(.sonaBody())
                            .foregroundStyle(.sonaTextSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.top, 4)
                    }
                    .padding(.horizontal, 24)

                    // Donation button
                    Button {
                        UIApplication.shared.open(paypalURL)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.system(size: 20, weight: .semibold))
                            Text("Donate via PayPal")
                                .font(.sonaBold(17))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(LinearGradient.sonaBrand)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color.sonaAccent.opacity(0.4), radius: 12, y: 6)
                    }
                    .padding(.horizontal, 24)

                    // paypal.me link label
                    Text("paypal.me/bobosv")
                        .font(.sonaMono(13))
                        .foregroundStyle(.sonaTextTertiary)

                    // Appreciation cards
                    VStack(spacing: 12) {
                        appreciationCard(
                            icon: "alarm.fill",
                            color: .sonaAccent,
                            title: "Every donation helps",
                            body: "Even a small tip covers server costs and motivates more updates."
                        )
                        appreciationCard(
                            icon: "star.fill",
                            color: .sonaWarning,
                            title: "Leave a review",
                            body: "A 5-star review on the App Store is just as valuable — it helps others find Sona."
                        )
                        appreciationCard(
                            icon: "bubble.left.and.bubble.right.fill",
                            color: .sonaPurple,
                            title: "Share with friends",
                            body: "Know someone who struggles with missed alarms? Tell them about Sona."
                        )
                    }
                    .padding(.horizontal, 20)

                    Spacer(minLength: 40)
                }
                .padding(.top, 16)
            }
        }
        .navigationTitle("Support Sona")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Support Sona")
                    .font(.sonaHeadline())
                    .foregroundStyle(.sonaTextPrimary)
            }
        }
    }

    @ViewBuilder
    private func appreciationCard(icon: String, color: Color, title: String, body: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(color)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.sonaHeadline(14))
                    .foregroundStyle(.sonaTextPrimary)
                Text(body)
                    .font(.sonaBody(13))
                    .foregroundStyle(.sonaTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.sonaSurface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(color.opacity(0.18), lineWidth: 1)
        )
    }
}
