import SwiftUI

extension Color {
    // Backgrounds
    static let sonaBackground  = Color(red: 0.039, green: 0.039, blue: 0.059)  // #0A0A0F
    static let sonaSurface     = Color(red: 0.078, green: 0.078, blue: 0.110)  // #141418
    static let sonaSurface2    = Color(red: 0.118, green: 0.118, blue: 0.180)  // #1E1E2E

    // Accents
    static let sonaAccent      = Color(red: 1.000, green: 0.420, blue: 0.420)  // #FF6B6B coral
    static let sonaPurple      = Color(red: 0.753, green: 0.518, blue: 0.988)  // #C084FC purple

    // Semantic
    static let sonaSuccess     = Color(red: 0.204, green: 0.827, blue: 0.600)  // #34D399
    static let sonaWarning     = Color(red: 0.984, green: 0.753, blue: 0.141)  // #FBBF24
    static let sonaError       = Color(red: 0.973, green: 0.443, blue: 0.443)  // #F87171

    // Text
    static let sonaTextPrimary   = Color.white
    static let sonaTextSecondary = Color(red: 0.545, green: 0.545, blue: 0.620) // #8B8B9E
    static let sonaTextTertiary  = Color(red: 0.340, green: 0.340, blue: 0.400)
}

extension LinearGradient {
    static let sonaBrand = LinearGradient(
        colors: [.sonaAccent, .sonaPurple],
        startPoint: .leading,
        endPoint: .trailing
    )
    static let sonaBrandVertical = LinearGradient(
        colors: [.sonaAccent, .sonaPurple],
        startPoint: .top,
        endPoint: .bottom
    )
    static let sonaBackgroundGradient = LinearGradient(
        colors: [Color(red: 0.039, green: 0.039, blue: 0.059),
                 Color(red: 0.060, green: 0.039, blue: 0.090)],
        startPoint: .top,
        endPoint: .bottom
    )
}
