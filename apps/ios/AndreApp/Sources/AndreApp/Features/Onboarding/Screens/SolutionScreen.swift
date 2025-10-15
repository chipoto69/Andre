import SwiftUI

/// Third onboarding screen introducing the three-list methodology.
///
/// Presents the core concepts of Todo, Watch, and Later lists with clear
/// visual distinction and explanation of the daily focus ritual.
public struct SolutionScreen: View {
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
        ZStack {
            // Background
            Color.backgroundPrimary
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: Spacing.xl) {
                    // Header
                    VStack(spacing: Spacing.md) {
                        Text("Three Lists.")
                            .font(.displaySmall)
                            .foregroundColor(.textPrimary)
                            .opacity(isAnimating ? 1 : 0)
                            .offset(y: isAnimating ? 0 : 20)

                        Text("One Daily Focus.")
                            .font(.displaySmall)
                            .foregroundColor(.brandCyan)
                            .opacity(isAnimating ? 1 : 0)
                            .offset(y: isAnimating ? 0 : 20)

                        Text("Based on Marc Andreessen's methodology")
                            .font(.bodyLarge)
                            .foregroundColor(.textSecondary)
                            .opacity(isAnimating ? 1 : 0)
                            .offset(y: isAnimating ? 0 : 20)
                    }
                    .multilineTextAlignment(.center)
                    .padding(.top, Spacing.xxl)

                    // Three principle cards
                    VStack(spacing: Spacing.md) {
                        PrincipleCard(
                            icon: "circle.fill",
                            iconColor: .listTodo,
                            title: "Todo",
                            description: "Active tasks for this week. Your current priorities and work in progress."
                        )
                        .opacity(isAnimating ? 1 : 0)
                        .offset(x: isAnimating ? 0 : -30)

                        PrincipleCard(
                            icon: "eye.fill",
                            iconColor: .listWatch,
                            title: "Watch",
                            description: "Items to follow up on. Delegated work, pending responses, things to monitor."
                        )
                        .opacity(isAnimating ? 1 : 0)
                        .offset(x: isAnimating ? 0 : -30)

                        PrincipleCard(
                            icon: "clock.fill",
                            iconColor: .listLater,
                            title: "Later",
                            description: "Deferred priorities. Ideas and tasks moved intentionally to reduce noise."
                        )
                        .opacity(isAnimating ? 1 : 0)
                        .offset(x: isAnimating ? 0 : -30)
                    }

                    // Focus ritual explanation
                    AndreCard(style: .accent) {
                        VStack(spacing: Spacing.sm) {
                            HStack(spacing: Spacing.xs) {
                                Image(systemName: "moon.stars.fill")
                                    .foregroundColor(.brandCyan)
                                Text("Evening Ritual")
                                    .font(.titleSmall)
                                    .foregroundColor(.textPrimary)
                            }

                            Text("Every evening, choose 3-5 items from your Todo list for tomorrow's focus card")
                                .font(.bodyMedium)
                                .foregroundColor(.textSecondary)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 30)

                    // CTA
                    VStack(spacing: Spacing.md) {
                        AndreButton.primary(
                            "Continue",
                            icon: "arrow.right",
                            size: .large,
                            action: onContinue
                        )
                        .opacity(isAnimating ? 1 : 0)

                        if let onSkip = onSkip {
                            AndreButton.borderless(
                                "Skip to App",
                                size: .medium,
                                action: onSkip
                            )
                            .opacity(isAnimating ? 1 : 0)
                        }
                    }
                    .padding(.vertical, Spacing.lg)
                }
                .padding(Spacing.screenPadding)
            }
        }
        .onAppear {
            withAnimation(Tokens.Curve.easeOut.delay(0.2)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Principle Card Component

/// Individual principle card with icon, title, and description
private struct PrincipleCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String

    var body: some View {
        AndreCard(style: .elevated) {
            VStack(spacing: Spacing.md) {
                // Icon
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 64, height: 64)

                    Image(systemName: icon)
                        .font(.system(size: 28))
                        .foregroundColor(iconColor)
                }

                // Title and description
                VStack(spacing: Spacing.xs) {
                    Text(title)
                        .font(.titleSmall)
                        .foregroundColor(.textPrimary)

                    Text(description)
                        .font(.bodySmall)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Preview

#Preview("Solution Screen") {
    SolutionScreen(
        onContinue: {
            print("Continue tapped")
        },
        onSkip: {
            print("Skip tapped")
        }
    )
}

#Preview("Solution Screen - No Skip") {
    SolutionScreen(onContinue: {})
}

#Preview("Solution Screen - Dark") {
    SolutionScreen(onContinue: {}, onSkip: {})
        .preferredColorScheme(.dark)
}

#Preview("Solution Screen - Light") {
    SolutionScreen(onContinue: {}, onSkip: {})
        .preferredColorScheme(.light)
}
