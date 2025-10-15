import SwiftUI

/// Typography system following Apple's Human Interface Guidelines
/// with semantic styles for the Andre brand.
///
/// Uses SF Pro for interface text and SF Mono for code references.
public extension Font {
    // MARK: - Display Styles

    /// Extra large display text (48pt, semibold)
    static let displayXL = Font.system(size: 48, weight: .semibold, design: .default)

    /// Large display text (40pt, semibold)
    static let displayLarge = Font.system(size: 40, weight: .semibold, design: .default)

    /// Medium display text (34pt, semibold)
    static let displayMedium = Font.system(size: 34, weight: .semibold, design: .default)

    /// Small display text (28pt, semibold)
    static let displaySmall = Font.system(size: 28, weight: .semibold, design: .default)

    // MARK: - Title Styles

    /// Large title (24pt, bold)
    static let titleLarge = Font.system(size: 24, weight: .bold, design: .default)

    /// Medium title (20pt, semibold)
    static let titleMedium = Font.system(size: 20, weight: .semibold, design: .default)

    /// Small title (18pt, semibold)
    static let titleSmall = Font.system(size: 18, weight: .semibold, design: .default)

    // MARK: - Body Styles

    /// Large body text (17pt, regular)
    static let bodyLarge = Font.system(size: 17, weight: .regular, design: .default)

    /// Medium body text (15pt, regular) - Default body text
    static let bodyMedium = Font.system(size: 15, weight: .regular, design: .default)

    /// Small body text (13pt, regular)
    static let bodySmall = Font.system(size: 13, weight: .regular, design: .default)

    // MARK: - Label Styles

    /// Large label (14pt, medium)
    static let labelLarge = Font.system(size: 14, weight: .medium, design: .default)

    /// Medium label (12pt, medium)
    static let labelMedium = Font.system(size: 12, weight: .medium, design: .default)

    /// Small label (11pt, medium)
    static let labelSmall = Font.system(size: 11, weight: .medium, design: .default)

    // MARK: - Code/Monospace Styles

    /// Large monospace (17pt, regular) - For code blocks
    static let codeLarge = Font.system(size: 17, weight: .regular, design: .monospaced)

    /// Medium monospace (15pt, regular) - For inline code
    static let codeMedium = Font.system(size: 15, weight: .regular, design: .monospaced)

    /// Small monospace (13pt, regular) - For compact code
    static let codeSmall = Font.system(size: 13, weight: .regular, design: .monospaced)

    // MARK: - Semantic Styles

    /// Navigation bar title
    static let navigationTitle = titleLarge

    /// Section header
    static let sectionHeader = titleSmall

    /// Card title
    static let cardTitle = titleMedium

    /// Button text
    static let button = bodyMedium.weight(.semibold)

    /// Caption text
    static let caption = labelSmall
}

// MARK: - Text Style Modifiers

public struct TextStyle {
    let font: Font
    let color: Color
    let lineHeight: CGFloat?
    let letterSpacing: CGFloat?

    public init(
        font: Font,
        color: Color = .textPrimary,
        lineHeight: CGFloat? = nil,
        letterSpacing: CGFloat? = nil
    ) {
        self.font = font
        self.color = color
        self.lineHeight = lineHeight
        self.letterSpacing = letterSpacing
    }
}

public extension View {
    /// Apply a complete text style to a view
    func textStyle(_ style: TextStyle) -> some View {
        self
            .font(style.font)
            .foregroundColor(style.color)
            .modifier(ConditionalLineSpacing(lineHeight: style.lineHeight))
            .modifier(ConditionalLetterSpacing(letterSpacing: style.letterSpacing))
    }
}

// MARK: - Helper Modifiers

private struct ConditionalLineSpacing: ViewModifier {
    let lineHeight: CGFloat?

    func body(content: Content) -> some View {
        if let lineHeight = lineHeight {
            content.lineSpacing(lineHeight)
        } else {
            content
        }
    }
}

private struct ConditionalLetterSpacing: ViewModifier {
    let letterSpacing: CGFloat?

    func body(content: Content) -> some View {
        if let letterSpacing = letterSpacing {
            content.tracking(letterSpacing)
        } else {
            content
        }
    }
}

// MARK: - Predefined Text Styles

public extension TextStyle {
    /// Hero text style for main headings
    static let hero = TextStyle(
        font: .displayLarge,
        color: .textPrimary,
        lineHeight: 8
    )

    /// Page title style
    static let pageTitle = TextStyle(
        font: .titleLarge,
        color: .textPrimary
    )

    /// Section heading style
    static let sectionHeading = TextStyle(
        font: .titleSmall,
        color: .textPrimary
    )

    /// Body text style
    static let body = TextStyle(
        font: .bodyMedium,
        color: .textPrimary,
        lineHeight: 4
    )

    /// Secondary body text style
    static let bodySecondary = TextStyle(
        font: .bodyMedium,
        color: .textSecondary,
        lineHeight: 4
    )

    /// Caption style
    static let captionStyle = TextStyle(
        font: .caption,
        color: .textTertiary
    )

    /// Code reference style (for [[.ApplicationName]] pattern)
    static let codeReference = TextStyle(
        font: .codeMedium,
        color: .brandCyan,
        letterSpacing: 0.5
    )
}
