import SwiftUI

// MARK: - iOS 26 Liquid Glass Design System
// Token-based design system following Apple's Liquid Glass guidelines

enum Theme {
    
    // MARK: - Corner Radius (iOS 26 Liquid Glass)
    /// Minimum touch target: 8pt
    static let cornerRadiusSmall: CGFloat = 8
    /// Standard elements: 12pt
    static let cornerRadiusMedium: CGFloat = 12
    /// Cards and containers: 16pt
    static let cornerRadiusLarge: CGFloat = 16
    /// Modal sheets: 20pt
    static let cornerRadiusXLarge: CGFloat = 20
    /// Buttons: 10pt (iOS 26 standard)
    static let cornerRadiusButton: CGFloat = 10
    /// Small badges/tags: 6pt
    static let cornerRadiusBadge: CGFloat = 6
    /// Icon containers: 10pt
    static let cornerRadiusIconContainer: CGFloat = 10
    
    // MARK: - Spacing
    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 12
    static let spacingL: CGFloat = 16
    static let spacingXL: CGFloat = 20
    static let spacingXXL: CGFloat = 24
    
    // MARK: - Typography (Minimum 11pt for iOS 26 Accessibility)
    /// Caption/Labels - Minimum 11pt
    static let fontCaption: Font = .system(size: 11, weight: .regular)
    static let fontCaptionMedium: Font = .system(size: 11, weight: .medium)
    static let fontCaptionSemibold: Font = .system(size: 11, weight: .semibold)
    
    /// Small body text - 12pt minimum
    static let fontSmall: Font = .system(size: 12, weight: .regular)
    static let fontSmallMedium: Font = .system(size: 12, weight: .medium)
    static let fontSmallSemibold: Font = .system(size: 12, weight: .semibold)
    
    /// Body text - 13pt minimum
    static let fontBody: Font = .system(size: 13, weight: .regular)
    static let fontBodyMedium: Font = .system(size: 13, weight: .medium)
    static let fontBodySemibold: Font = .system(size: 13, weight: .semibold)
    
    /// Subheadings - 14pt minimum
    static let fontSubhead: Font = .system(size: 14, weight: .regular)
    static let fontSubheadMedium: Font = .system(size: 14, weight: .medium)
    static let fontSubheadSemibold: Font = .system(size: 14, weight: .semibold)
    
    /// Section headers - 15pt minimum
    static let fontHeadline: Font = .system(size: 15, weight: .semibold)
    
    /// Titles - 17pt minimum
    static let fontTitle: Font = .system(size: 17, weight: .bold)
    static let fontTitleMedium: Font = .system(size: 17, weight: .semibold)
    
    /// Large titles - 20pt minimum
    static let fontLargeTitle: Font = .system(size: 20, weight: .bold)
    
    // MARK: - Shadows
    static let shadowSmall = Shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    static let shadowMedium = Shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
    static let shadowLarge = Shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
    
    struct Shadow {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
    
    // MARK: - Haptics
    /// Light haptic for UI feedback (toggles, selections)
    static func hapticLight() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    /// Medium haptic for important actions
    static func hapticMedium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    /// Heavy haptic for significant events
    static func hapticHeavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    /// Success haptic for completed actions
    static func hapticSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    /// Warning haptic
    static func hapticWarning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    /// Error haptic
    static func hapticError() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    /// Selection changed haptic
    static func hapticSelection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

// MARK: - Liquid Glass Button Style
struct LiquidGlassButtonStyle: ButtonStyle {
    var isPrimary: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Card Modifier with Liquid Glass styling
struct LiquidGlassCard: ViewModifier {
    var cornerRadius: CGFloat = Theme.cornerRadiusLarge
    
    func body(content: Content) -> some View {
        content
            .background(Color.plumeSurface)
            .cornerRadius(cornerRadius)
            .shadow(
                color: Theme.shadowMedium.color,
                radius: Theme.shadowMedium.radius,
                x: Theme.shadowMedium.x,
                y: Theme.shadowMedium.y
            )
    }
}

extension View {
    func liquidGlassCard(cornerRadius: CGFloat = Theme.cornerRadiusLarge) -> some View {
        modifier(LiquidGlassCard(cornerRadius: cornerRadius))
    }
}

// MARK: - Accessibility Helpers
extension View {
    /// Adds accessibility label with haptic feedback capability
    func accessibleButton(label: String, hint: String? = nil) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(.isButton)
    }
    
    /// Adds accessibility label for containers
    func accessibleContainer(label: String) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityAddTraits(.isHeader)
    }
}
