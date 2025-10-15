import SwiftUI

/// Design tokens consolidating all design system values in one place.
///
/// This file serves as the single source of truth for design decisions,
/// making it easy to update the entire app's appearance from one location.
public enum Tokens {
    // MARK: - Animation Durations

    public enum Duration {
        /// Extra fast animation (100ms) - Micro-interactions
        public static let xfast: Double = 0.1

        /// Fast animation (200ms) - Quick transitions
        public static let fast: Double = 0.2

        /// Normal animation (300ms) - Standard transitions
        public static let normal: Double = 0.3

        /// Slow animation (500ms) - Deliberate transitions
        public static let slow: Double = 0.5

        /// Extra slow animation (800ms) - Dramatic transitions
        public static let xslow: Double = 0.8
    }

    // MARK: - Animation Curves

    public enum Curve {
        /// Standard ease-in-out curve
        public static let easeInOut = Animation.easeInOut(duration: Duration.normal)

        /// Ease-out curve for appearing elements
        public static let easeOut = Animation.easeOut(duration: Duration.normal)

        /// Ease-in curve for disappearing elements
        public static let easeIn = Animation.easeIn(duration: Duration.normal)

        /// Spring animation for bouncy effects
        public static let spring = Animation.spring(response: 0.3, dampingFraction: 0.7)

        /// Smooth spring for natural motion
        public static let smoothSpring = Animation.spring(response: 0.4, dampingFraction: 0.8)
    }

    // MARK: - Opacity Levels

    public enum Opacity {
        /// Fully visible
        public static let full: Double = 1.0

        /// High visibility (90%)
        public static let high: Double = 0.9

        /// Medium-high visibility (70%)
        public static let mediumHigh: Double = 0.7

        /// Medium visibility (50%)
        public static let medium: Double = 0.5

        /// Low visibility (30%)
        public static let low: Double = 0.3

        /// Very low visibility (10%)
        public static let veryLow: Double = 0.1

        /// Nearly invisible (5%)
        public static let subtle: Double = 0.05

        /// Invisible
        public static let invisible: Double = 0.0
    }

    // MARK: - Border Widths

    public enum BorderWidth {
        /// Hairline border (0.5px)
        public static let hairline: CGFloat = 0.5

        /// Thin border (1px)
        public static let thin: CGFloat = 1

        /// Medium border (2px)
        public static let medium: CGFloat = 2

        /// Thick border (3px)
        public static let thick: CGFloat = 3
    }

    // MARK: - Blur Radius

    public enum BlurRadius {
        /// Small blur
        public static let small: CGFloat = 8

        /// Medium blur
        public static let medium: CGFloat = 16

        /// Large blur
        public static let large: CGFloat = 24

        /// Extra large blur
        public static let xl: CGFloat = 32
    }

    // MARK: - Z-Index Layers

    public enum ZIndex {
        /// Background layer
        public static let background: Double = 0

        /// Base content layer
        public static let base: Double = 1

        /// Elevated content (cards, etc.)
        public static let elevated: Double = 10

        /// Floating elements (FABs, etc.)
        public static let floating: Double = 100

        /// Modal overlays
        public static let modal: Double = 1000

        /// Toasts and notifications
        public static let notification: Double = 10000
    }
}

// MARK: - Material Styles

public enum MaterialStyle {
    case ultraThin
    case thin
    case regular
    case thick
    case ultraThick

    var material: Material {
        switch self {
        case .ultraThin: return .ultraThinMaterial
        case .thin: return .thinMaterial
        case .regular: return .regularMaterial
        case .thick: return .thickMaterial
        case .ultraThick: return .ultraThickMaterial
        }
    }
}

// MARK: - Card Styles

public struct CardStyle {
    let background: Color
    let cornerRadius: CGFloat
    let shadow: ShadowStyle
    let border: (color: Color, width: CGFloat)?

    public init(
        background: Color = .backgroundSecondary,
        cornerRadius: CGFloat = LayoutSize.cornerRadiusLarge,
        shadow: ShadowStyle = .small,
        border: (color: Color, width: CGFloat)? = nil
    ) {
        self.background = background
        self.cornerRadius = cornerRadius
        self.shadow = shadow
        self.border = border
    }
}

public extension View {
    /// Apply a card style to a view
    func cardStyle(_ style: CardStyle = CardStyle()) -> some View {
        self
            .background(style.background)
            .cornerRadius(style.cornerRadius)
            .shadow(style.shadow)
            .modifier(ConditionalBorder(border: style.border))
    }
}

private struct ConditionalBorder: ViewModifier {
    let border: (color: Color, width: CGFloat)?

    func body(content: Content) -> some View {
        if let border = border {
            content.overlay(
                RoundedRectangle(cornerRadius: LayoutSize.cornerRadiusLarge)
                    .stroke(border.color, lineWidth: border.width)
            )
        } else {
            content
        }
    }
}

// MARK: - Predefined Card Styles

public extension CardStyle {
    /// Default card style
    static let `default` = CardStyle()

    /// Elevated card with more shadow
    static let elevated = CardStyle(
        shadow: .medium
    )

    /// Glassmorphic card
    static let glass = CardStyle(
        background: .brandDarkGray.opacity(0.6),
        border: (.brandWhite.opacity(0.1), Tokens.BorderWidth.hairline)
    )

    /// Accent card with cyan border
    static let accent = CardStyle(
        border: (.brandCyan, Tokens.BorderWidth.thin)
    )
}
