import SwiftUI

struct GradientText: View {
    let text: String
    var font: Font = .sonaDisplay()
    var gradient: LinearGradient = .sonaBrand

    var body: some View {
        Text(text)
            .font(font)
            .foregroundStyle(gradient)
    }
}

struct SummaryStatCard: View {
    let title: String
    let value: String
    let icon: String
    var color: Color = .sonaAccent
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(color)
                Text(title)
                    .font(.sonaCaption(11))
                    .foregroundStyle(.sonaTextSecondary)
            }
            Text(value)
                .font(.sonaDisplay(26))
                .foregroundStyle(color)
            if let sub = subtitle {
                Text(sub)
                    .font(.sonaCaption(10))
                    .foregroundStyle(.sonaTextTertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.sonaSurface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(color.opacity(0.2), lineWidth: 1)
        )
    }
}
