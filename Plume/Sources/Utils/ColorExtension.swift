import SwiftUI

extension Color {
    // Brand palette — hardcoded hex values are guaranteed valid, using nil-coalescing with black as safe fallback
    static let plumeBackground = Color(hex: "#faf8f3") ?? .black
    static let plumeBackgroundDark = Color(hex: "#1a1612") ?? .black
    static let plumeSurface = Color(hex: "#ffffff") ?? .white
    static let plumeSurfaceDark = Color(hex: "#231f1a") ?? .black
    static let plumeAccent = Color(hex: "#8b4513") ?? .brown
    static let plumeAccentSecondary = Color(hex: "#c9a96e") ?? .orange
    static let plumeCurrentlyReading = Color(hex: "#2d5a3d") ?? .green
    static let plumeFinished = Color(hex: "#4a4a4a") ?? .gray
    static let plumeTextPrimary = Color(hex: "#1a1612") ?? .primary
    static let plumeTextSecondary = Color(hex: "#7a7068") ?? .secondary

    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let r, g, b, a: Double
        switch hexSanitized.count {
        case 6:
            r = Double((rgb & 0xFF0000) >> 16) / 255.0
            g = Double((rgb & 0x00FF00) >> 8) / 255.0
            b = Double(rgb & 0x0000FF) / 255.0
            a = 1.0
        case 8:
            r = Double((rgb & 0xFF000000) >> 24) / 255.0
            g = Double((rgb & 0x00FF0000) >> 16) / 255.0
            b = Double((rgb & 0x0000FF00) >> 8) / 255.0
            a = Double(rgb & 0x000000FF) / 255.0
        default:
            return nil
        }

        self.init(red: r, green: g, blue: b, opacity: a)
    }
}
