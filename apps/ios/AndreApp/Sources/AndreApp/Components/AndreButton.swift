import SwiftUI

/// Andre brand button component with multiple style variants.
///
/// Supports primary, secondary, and borderless styles with proper
/// accessibility support and loading states.
public struct AndreButton: View {
    // MARK: - Style

    public enum Style {
        case primary
        case secondary
        case borderless
        case destructive
    }

    // MARK: - Size

    public enum Size {
        case small
        case medium
        case large

        var height: CGFloat {
            switch self {
            case .small: return LayoutSize.buttonHeightSmall
            case .medium: return LayoutSize.buttonHeightMedium
            case .large: return LayoutSize.buttonHeightLarge
            }
        }

        var font: Font {
            switch self {
            case .small: return .bodySmall.weight(.semibold)
            case .medium: return .button
            case .large: return .bodyLarge.weight(.semibold)
            }
        }

        var horizontalPadding: CGFloat {
            switch self {
            case .small: return Spacing.md
            case .medium: return Spacing.lg
            case .large: return Spacing.xl
            }
        }
    }

    // MARK: - Properties

    private let title: String
    private let icon: String?
    private let style: Style
    private let size: Size
    private let isLoading: Bool
    private let isDisabled: Bool
    private let action: () -> Void

    // MARK: - Initialization

    public init(
        _ title: String,
        icon: String? = nil,
        style: Style = .primary,
        size: Size = .medium,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.size = size
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }

    // MARK: - Body

    public var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(textColor)
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: size == .small ? 14 : 16))
                }

                Text(title)
                    .font(size.font)
            }
            .frame(maxWidth: .infinity)
            .frame(height: size.height)
            .padding(.horizontal, size.horizontalPadding)
            .foregroundColor(textColor)
            .background(backgroundColor)
            .cornerRadius(LayoutSize.cornerRadiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: LayoutSize.cornerRadiusMedium)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
        }
        .disabled(isDisabled || isLoading)
        .opacity(isDisabled ? Tokens.Opacity.medium : Tokens.Opacity.full)
        .animation(Tokens.Curve.easeOut, value: isLoading)
        .accessibilityLabel(title)
        .accessibilityHint(isLoading ? "Loading" : "")
        .accessibilityAddTraits(isDisabled ? .isButton : [.isButton])
    }

    // MARK: - Computed Properties

    private var backgroundColor: Color {
        switch style {
        case .primary:
            return .brandCyan
        case .secondary:
            return .backgroundSecondary
        case .borderless:
            return .clear
        case .destructive:
            return .statusError
        }
    }

    private var textColor: Color {
        switch style {
        case .primary:
            return .brandBlack
        case .secondary:
            return .brandCyan
        case .borderless:
            return .brandCyan
        case .destructive:
            return .brandWhite
        }
    }

    private var borderColor: Color {
        switch style {
        case .primary, .destructive:
            return .clear
        case .secondary:
            return .brandCyan
        case .borderless:
            return .clear
        }
    }

    private var borderWidth: CGFloat {
        switch style {
        case .primary, .destructive, .borderless:
            return 0
        case .secondary:
            return Tokens.BorderWidth.thin
        }
    }
}

// MARK: - Convenience Initializers

public extension AndreButton {
    /// Create a primary button
    static func primary(
        _ title: String,
        icon: String? = nil,
        size: Size = .medium,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) -> AndreButton {
        AndreButton(
            title,
            icon: icon,
            style: .primary,
            size: size,
            isLoading: isLoading,
            isDisabled: isDisabled,
            action: action
        )
    }

    /// Create a secondary button
    static func secondary(
        _ title: String,
        icon: String? = nil,
        size: Size = .medium,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) -> AndreButton {
        AndreButton(
            title,
            icon: icon,
            style: .secondary,
            size: size,
            isLoading: isLoading,
            isDisabled: isDisabled,
            action: action
        )
    }

    /// Create a borderless button
    static func borderless(
        _ title: String,
        icon: String? = nil,
        size: Size = .medium,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) -> AndreButton {
        AndreButton(
            title,
            icon: icon,
            style: .borderless,
            size: size,
            isLoading: isLoading,
            isDisabled: isDisabled,
            action: action
        )
    }

    /// Create a destructive button
    static func destructive(
        _ title: String,
        icon: String? = nil,
        size: Size = .medium,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) -> AndreButton {
        AndreButton(
            title,
            icon: icon,
            style: .destructive,
            size: size,
            isLoading: isLoading,
            isDisabled: isDisabled,
            action: action
        )
    }
}

// MARK: - Preview

#Preview("Button Variants") {
    VStack(spacing: Spacing.md) {
        AndreButton.primary("Primary Button", icon: "plus") {}
        AndreButton.secondary("Secondary Button", icon: "star") {}
        AndreButton.borderless("Borderless Button") {}
        AndreButton.destructive("Destructive Button", icon: "trash") {}

        AndreButton.primary("Loading", isLoading: true) {}
        AndreButton.secondary("Disabled", isDisabled: true) {}

        HStack(spacing: Spacing.md) {
            AndreButton.primary("Small", size: .small) {}
            AndreButton.primary("Medium", size: .medium) {}
        }
        AndreButton.primary("Large", size: .large) {}
    }
    .padding()
    .background(Color.backgroundPrimary)
}
