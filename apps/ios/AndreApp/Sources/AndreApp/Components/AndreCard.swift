import SwiftUI

/// Glassmorphic card component with material background.
///
/// Provides a consistent card style across the app with support
/// for different visual treatments.
public struct AndreCard<Content: View>: View {
    // MARK: - Style

    public enum Style {
        case `default`
        case elevated
        case glass
        case accent
    }

    // MARK: - Properties

    private let style: Style
    private let content: Content

    // MARK: - Initialization

    public init(
        style: Style = .default,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.content = content()
    }

    // MARK: - Body

    public var body: some View {
        content
            .padding(Spacing.cardPadding)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .cornerRadius(LayoutSize.cornerRadiusLarge)
            .overlay(borderOverlay)
            .shadow(shadowStyle)
    }

    // MARK: - Computed Properties

    private var backgroundColor: Color {
        switch style {
        case .default:
            return .backgroundSecondary
        case .elevated:
            return .backgroundSecondary
        case .glass:
            return .brandDarkGray.opacity(0.6)
        case .accent:
            return .backgroundSecondary
        }
    }

    private var borderOverlay: some View {
        Group {
            if style == .glass || style == .accent {
                RoundedRectangle(cornerRadius: LayoutSize.cornerRadiusLarge)
                    .stroke(borderColor, lineWidth: borderWidth)
            }
        }
    }

    private var borderColor: Color {
        switch style {
        case .glass:
            return .brandWhite.opacity(0.1)
        case .accent:
            return .brandCyan
        default:
            return .clear
        }
    }

    private var borderWidth: CGFloat {
        switch style {
        case .glass:
            return Tokens.BorderWidth.hairline
        case .accent:
            return Tokens.BorderWidth.thin
        default:
            return 0
        }
    }

    private var shadowStyle: ShadowStyle {
        switch style {
        case .default:
            return .small
        case .elevated:
            return .medium
        case .glass:
            return .small
        case .accent:
            return .small
        }
    }
}

// MARK: - Interactive Card

/// Card with tap action
public struct AndreInteractiveCard<Content: View>: View {
    private let style: AndreCard<Content>.Style
    private let action: () -> Void
    private let content: Content

    public init(
        style: AndreCard<Content>.Style = .default,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.action = action
        self.content = content()
    }

    public var body: some View {
        Button(action: action) {
            AndreCard(style: style) {
                content
            }
        }
        .buttonStyle(CardButtonStyle())
    }
}

// MARK: - Card Button Style

private struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(Tokens.Curve.spring, value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview("Card Variants") {
    ScrollView {
        VStack(spacing: Spacing.lg) {
            AndreCard(style: .default) {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Default Card")
                        .font(.titleMedium)
                        .foregroundColor(.textPrimary)
                    Text("This is a default card with standard styling.")
                        .font(.bodyMedium)
                        .foregroundColor(.textSecondary)
                }
            }

            AndreCard(style: .elevated) {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Elevated Card")
                        .font(.titleMedium)
                        .foregroundColor(.textPrimary)
                    Text("This card has a larger shadow for more prominence.")
                        .font(.bodyMedium)
                        .foregroundColor(.textSecondary)
                }
            }

            AndreCard(style: .glass) {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Glass Card")
                        .font(.titleMedium)
                        .foregroundColor(.textPrimary)
                    Text("Glassmorphic effect with translucent background.")
                        .font(.bodyMedium)
                        .foregroundColor(.textSecondary)
                }
            }

            AndreCard(style: .accent) {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Accent Card")
                        .font(.titleMedium)
                        .foregroundColor(.textPrimary)
                    Text("Highlighted with cyan border for emphasis.")
                        .font(.bodyMedium)
                        .foregroundColor(.textSecondary)
                }
            }

            AndreInteractiveCard(style: .accent, action: {}) {
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Interactive Card")
                            .font(.titleMedium)
                            .foregroundColor(.textPrimary)
                        Text("Tap to interact")
                            .font(.bodySmall)
                            .foregroundColor(.textSecondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.brandCyan)
                }
            }
        }
        .padding()
    }
    .background(Color.backgroundPrimary)
}
