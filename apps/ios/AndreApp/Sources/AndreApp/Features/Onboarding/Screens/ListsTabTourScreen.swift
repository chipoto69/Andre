import SwiftUI

/// Fourth onboarding screen explaining the three lists (Todo, Watch, Later).
///
/// Introduces Marc Andreessen's three-list methodology with clear visual
/// distinction between list types and their purposes.
public struct ListsTabTourScreen: View {
    // MARK: - Properties

    let onContinue: () -> Void
    let onSkip: (() -> Void)?

    // MARK: - Animation State

    @State private var isAnimating = false

    // MARK: - Initialization

    public init(
        onContinue: @escaping () -> Void,
        onSkip: (() -> Void)? = nil
    ) {
        self.onContinue = onContinue
        self.onSkip = onSkip
    }

    // MARK: - Body

    public var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                // Header
                VStack(spacing: Spacing.md) {
                    Text("Your Three Lists")
                        .font(.titleLarge)
                        .foregroundColor(.textPrimary)
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 20)

                    Text("Everything captured in three simple categories")
                        .font(.bodyMedium)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 20)
                }
                .padding(.top, Spacing.xl)

                // Three List Cards
                VStack(spacing: Spacing.md) {
                    ListTypeCard(
                        icon: "circle.fill",
                        iconColor: .listTodo,
                        title: "Todo",
                        description: "Active tasks for this week. Things you plan to complete soon."
                    )
                    .opacity(isAnimating ? 1 : 0)
                    .offset(x: isAnimating ? 0 : -30)
                    .animation(Tokens.Curve.easeOut.delay(0.3), value: isAnimating)

                    ListTypeCard(
                        icon: "eye.fill",
                        iconColor: .listWatch,
                        title: "Watch",
                        description: "Items to monitor or follow up on. Keep an eye on progress."
                    )
                    .opacity(isAnimating ? 1 : 0)
                    .offset(x: isAnimating ? 0 : -30)
                    .animation(Tokens.Curve.easeOut.delay(0.4), value: isAnimating)

                    ListTypeCard(
                        icon: "clock.fill",
                        iconColor: .listLater,
                        title: "Later",
                        description: "Deferred priorities. Important but not urgent."
                    )
                    .opacity(isAnimating ? 1 : 0)
                    .offset(x: isAnimating ? 0 : -30)
                    .animation(Tokens.Curve.easeOut.delay(0.5), value: isAnimating)
                }

                // Footer benefit
                AndreCard(style: .accent) {
                    VStack(spacing: Spacing.sm) {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.brandCyan)
                                .font(.system(size: 20))
                            Text("Everything captured. Nothing forgotten.")
                                .font(.titleSmall)
                                .foregroundColor(.textPrimary)
                        }

                        Text("Move tasks between lists as priorities change")
                            .font(.bodySmall)
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 30)
                .animation(Tokens.Curve.easeOut.delay(0.6), value: isAnimating)

                // CTA button
                VStack(spacing: Spacing.md) {
                    AndreButton.primary(
                        "Continue",
                        icon: "arrow.right",
                        size: .large,
                        action: onContinue
                    )
                    .opacity(isAnimating ? 1 : 0)
                    .animation(Tokens.Curve.easeOut.delay(0.7), value: isAnimating)

                    if let onSkip = onSkip {
                        AndreButton.borderless(
                            "Skip Tour",
                            size: .medium,
                            action: onSkip
                        )
                        .opacity(isAnimating ? 1 : 0)
                        .animation(Tokens.Curve.easeOut.delay(0.7), value: isAnimating)
                    }
                }
                .padding(.vertical, Spacing.lg)
            }
            .padding(Spacing.screenPadding)
        }
        .background(Color.backgroundPrimary)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let onSkip = onSkip {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Skip") { onSkip() }
                        .foregroundColor(.brandCyan)
                }
            }
        }
        .onAppear {
            withAnimation(Tokens.Curve.easeOut.delay(0.2)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - List Type Card Component

/// Individual list type card with icon, color, title, and description
private struct ListTypeCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String

    var body: some View {
        AndreCard(style: .elevated) {
            HStack(spacing: Spacing.md) {
                // Icon with colored background
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.2))
                        .frame(width: 48, height: 48)

                    Image(systemName: icon)
                        .font(.system(size: LayoutSize.iconMedium))
                        .foregroundColor(iconColor)
                }

                // Title and description
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(title)
                        .font(.titleSmall)
                        .foregroundColor(.textPrimary)

                    Text(description)
                        .font(.bodySmall)
                        .foregroundColor(.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }
        }
    }
}

// MARK: - Preview

#Preview("Lists Tab Tour") {
    NavigationStack {
        ListsTabTourScreen(
            onContinue: {
                print("Continue tapped")
            },
            onSkip: {
                print("Skip tapped")
            }
        )
    }
}

#Preview("Lists Tab Tour - No Skip") {
    NavigationStack {
        ListsTabTourScreen(onContinue: {})
    }
}

#Preview("Lists Tab Tour - Dark") {
    NavigationStack {
        ListsTabTourScreen(onContinue: {}, onSkip: {})
    }
    .preferredColorScheme(.dark)
}
