import SwiftUI

/// Spacing system following an 8px base scale for consistent layouts.
///
/// All spacing values are multiples of 8 to create a harmonious rhythm
/// throughout the interface.
public enum Spacing {
    // MARK: - Base Spacing Scale (8px base)

    /// 4px - Minimal spacing for very tight elements
    public static let xxs: CGFloat = 4

    /// 8px - Extra small spacing
    public static let xs: CGFloat = 8

    /// 12px - Small spacing
    public static let sm: CGFloat = 12

    /// 16px - Medium spacing (most common)
    public static let md: CGFloat = 16

    /// 24px - Large spacing
    public static let lg: CGFloat = 24

    /// 32px - Extra large spacing
    public static let xl: CGFloat = 32

    /// 48px - 2XL spacing
    public static let xxl: CGFloat = 48

    /// 64px - 3XL spacing
    public static let xxxl: CGFloat = 64

    /// 96px - 4XL spacing
    public static let xxxxl: CGFloat = 96

    // MARK: - Semantic Spacing

    /// Standard padding for screens
    public static let screenPadding = md

    /// Standard padding for cards
    public static let cardPadding = lg

    /// Standard spacing between sections
    public static let sectionSpacing = xl

    /// Standard spacing between list items
    public static let listItemSpacing = xs

    /// Standard spacing between grouped elements
    public static let groupSpacing = md

    /// Standard spacing for form fields
    public static let formFieldSpacing = md

    /// Standard spacing between buttons
    public static let buttonSpacing = sm

    /// Minimum touch target size (Apple HIG)
    public static let minTouchTarget: CGFloat = 44
}

// MARK: - Padding Modifiers

public extension View {
    /// Apply screen-level padding
    func screenPadding() -> some View {
        self.padding(Spacing.screenPadding)
    }

    /// Apply card-level padding
    func cardPadding() -> some View {
        self.padding(Spacing.cardPadding)
    }

    /// Apply section spacing
    func sectionSpacing() -> some View {
        self.padding(.vertical, Spacing.sectionSpacing)
    }
}

// MARK: - Layout Sizes

public enum LayoutSize {
    // MARK: - Corner Radius

    /// Small corner radius (4px)
    public static let cornerRadiusSmall: CGFloat = 4

    /// Medium corner radius (8px)
    public static let cornerRadiusMedium: CGFloat = 8

    /// Large corner radius (12px)
    public static let cornerRadiusLarge: CGFloat = 12

    /// Extra large corner radius (16px)
    public static let cornerRadiusXL: CGFloat = 16

    /// Pill corner radius (999px - creates fully rounded ends)
    public static let cornerRadiusPill: CGFloat = 999

    // MARK: - Icon Sizes

    /// Small icon (16x16)
    public static let iconSmall: CGFloat = 16

    /// Medium icon (24x24)
    public static let iconMedium: CGFloat = 24

    /// Large icon (32x32)
    public static let iconLarge: CGFloat = 32

    /// Extra large icon (48x48)
    public static let iconXL: CGFloat = 48

    // MARK: - Avatar Sizes

    /// Small avatar (32x32)
    public static let avatarSmall: CGFloat = 32

    /// Medium avatar (40x40)
    public static let avatarMedium: CGFloat = 40

    /// Large avatar (56x56)
    public static let avatarLarge: CGFloat = 56

    // MARK: - Card Dimensions

    /// Minimum card height
    public static let cardMinHeight: CGFloat = 120

    /// Maximum card width for readable content
    public static let cardMaxWidth: CGFloat = 640

    // MARK: - Button Heights

    /// Small button height
    public static let buttonHeightSmall: CGFloat = 32

    /// Medium button height
    public static let buttonHeightMedium: CGFloat = 44

    /// Large button height
    public static let buttonHeightLarge: CGFloat = 56
}

// MARK: - Shadow Definitions

public struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat

    public init(color: Color = .black.opacity(0.1), radius: CGFloat, x: CGFloat = 0, y: CGFloat = 0) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }
}

public extension View {
    /// Apply a shadow style to a view
    func shadow(_ style: ShadowStyle) -> some View {
        self.shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }
}

public extension ShadowStyle {
    /// Small shadow for subtle elevation
    static let small = ShadowStyle(radius: 4, y: 2)

    /// Medium shadow for cards
    static let medium = ShadowStyle(radius: 8, y: 4)

    /// Large shadow for modals
    static let large = ShadowStyle(radius: 16, y: 8)

    /// Extra large shadow for prominent elements
    static let xl = ShadowStyle(radius: 24, y: 12)
}
