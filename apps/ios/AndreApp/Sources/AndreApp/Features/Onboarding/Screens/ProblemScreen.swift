import SwiftUI

/// Second onboarding screen explaining the pain points of traditional todo apps.
///
/// Presents three key problems in glass cards to establish context before
/// introducing Andre's solution.
public struct ProblemScreen: View {
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
                        Text("Too Many Lists,")
                            .font(.displaySmall)
                            .foregroundColor(.textPrimary)
                            .opacity(isAnimating ? 1 : 0)
                            .offset(y: isAnimating ? 0 : 20)

                        Text("Too Little Focus")
                            .font(.displaySmall)
                            .foregroundColor(.brandCyan)
                            .opacity(isAnimating ? 1 : 0)
                            .offset(y: isAnimating ? 0 : 20)
                    }
                    .multilineTextAlignment(.center)
                    .padding(.top, Spacing.xxl)

                    // Problem cards
                    VStack(spacing: Spacing.lg) {
                        ProblemCard(
                            icon: "list.bullet.rectangle",
                            iconColor: .statusWarning,
                            title: "Endless Lists That Never Shrink",
                            description: "Traditional todo apps create endless lists that never shrink. You keep adding, but rarely completing."
                        )
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 30)

                        ProblemCard(
                            icon: "exclamationmark.triangle",
                            iconColor: .statusError,
                            title: "Capturing Everything, Accomplishing Nothing",
                            description: "You capture everything but accomplish nothing. The sheer volume of tasks creates paralysis instead of progress."
                        )
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 40)

                        ProblemCard(
                            icon: "arrow.triangle.branch",
                            iconColor: .brandCyan,
                            title: "Scattered Obligations Slipping Away",
                            description: "Obligations scatter across tools, apps, and notebooks. Important items slip through the cracks."
                        )
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 50)
                    }

                    // CTA
                    VStack(spacing: Spacing.md) {
                        AndreButton.primary(
                            "See the Solution",
                            icon: "arrow.right",
                            size: .large,
                            action: onContinue
                        )
                        .opacity(isAnimating ? 1 : 0)

                        if let onSkip = onSkip {
                            AndreButton.borderless(
                                "Skip Introduction",
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

// MARK: - Problem Card Component

/// Individual problem display card with icon and description
private struct ProblemCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String

    var body: some View {
        AndreCard(style: .glass) {
            HStack(alignment: .top, spacing: Spacing.md) {
                // Icon container
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 48, height: 48)

                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(iconColor)
                }

                // Content
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(title)
                        .font(.titleSmall)
                        .foregroundColor(.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(description)
                        .font(.bodyMedium)
                        .foregroundColor(.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
        }
    }
}

// MARK: - Preview

#Preview("Problem Screen") {
    ProblemScreen(
        onContinue: {
            print("Continue tapped")
        },
        onSkip: {
            print("Skip tapped")
        }
    )
}

#Preview("Problem Screen - No Skip") {
    ProblemScreen(onContinue: {})
}

#Preview("Problem Screen - Dark") {
    ProblemScreen(onContinue: {}, onSkip: {})
        .preferredColorScheme(.dark)
}
