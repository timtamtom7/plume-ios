import SwiftUI

// MARK: - Color.init(hex:)

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Theme colors (static, light-mode defaults)

enum Theme {
    static let inkBlue = Color(hex: "1E3A5F")
    static let parchment = Color(hex: "F5F0E8")
    static let featherGold = Color(hex: "C9A227")
    static let surface = Color(hex: "FAFAF8")
    static let cardBg = Color(hex: "FFFFFF")
    static let accentOrange = Color(hex: "D97706")
    static let successGreen = Color(hex: "16A34A")
    static let subtleGray = Color(hex: "6B7280")

    static let serifFont = "Georgia"
    static let sansSerifFont = "SF Pro Text"
}

// MARK: - Adaptive Theme Environment

struct AppTheme {
    let inkBlue: Color
    let parchment: Color
    let surface: Color
    let cardBg: Color
    let featherGold: Color
    let accentOrange: Color
    let successGreen: Color
    let subtleGray: Color

    static let light = AppTheme(
        inkBlue: Color(hex: "1E3A5F"),
        parchment: Color(hex: "F5F0E8"),
        surface: Color(hex: "FAFAF8"),
        cardBg: Color(hex: "FFFFFF"),
        featherGold: Color(hex: "C9A227"),
        accentOrange: Color(hex: "D97706"),
        successGreen: Color(hex: "16A34A"),
        subtleGray: Color(hex: "6B7280")
    )

    static let dark = AppTheme(
        inkBlue: Color(hex: "A8C5E2"),
        parchment: Color(hex: "1C1B18"),
        surface: Color(hex: "141413"),
        cardBg: Color(hex: "2A2926"),
        featherGold: Color(hex: "E8C547"),
        accentOrange: Color(hex: "E8A050"),
        successGreen: Color(hex: "4ADE80"),
        subtleGray: Color(hex: "9CA3AF")
    )
}

private struct AppThemeKey: EnvironmentKey {
    static let defaultValue: AppTheme = .light
}

extension EnvironmentValues {
    var appTheme: AppTheme {
        get { self[AppThemeKey.self] }
        set { self[AppThemeKey.self] = newValue }
    }
}

struct ThemedBackground: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .environment(\.appTheme, colorScheme == .dark ? .dark : .light)
            .background(
                (colorScheme == .dark ? AppTheme.dark.parchment : AppTheme.light.parchment)
                    .ignoresSafeArea()
            )
    }
}

extension View {
    func themedBackground() -> some View {
        modifier(ThemedBackground())
    }
}
