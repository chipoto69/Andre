import SwiftUI

/// Sixth onboarding screen explaining structured procrastination.
///
/// Introduces the smart task switching concept when deep work stalls,
/// showing how to maintain momentum through productive alternatives.
public struct SwitchTabTourScreen: View {
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
                    // Branch icon
                    ZStack {
                        Circle()
                            .fill(Color.brandCyan.opacity(0.1))
                            .frame(width: 80, height: 80)

                        Image(systemName: "arrow.triangle.branch")
                            .font(.system(size: 36))
                            .foregroundColor(.brandCyan)
                    }
                    .opacity(isAnimating ? 1 : 0)
                    .scaleEffect(isAnimating ? 1 : 0.8)
                    .animation(Tokens.Curve.spring.delay(0.3), value: isAnimating)

                    Text("Structured Procrastination")
                        .font(.titleLarge)
                        .foregroundColor(.textPrimary)
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 20)

                    Text("Smart task switching when deep work stalls")
                        .font(.bodyMedium)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 20)
                }
                .padding(.top, Spacing.xl)

                // Concept Explanation Card
                AndreCard(style: .accent) {
                    VStack(spacing: Spacing.md) {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.brandCyan)
                            Text("Strategic Breaks")
                                .font(.titleSmall)
                                .foregroundColor(.textPrimary)
                        }

                        Text("When you're stuck on deep work, switch to a productive alternative")
                            .font(.bodyMedium)
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)

                        Divider()
                            .background(Color.textTertiary.opacity(0.3))

                        Text(""Instead of forcing focus, redirect your energy productively"")
                            .font(.bodySmall)
                            .italic()
                            .foregroundColor(.textTertiary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 30)
                .animation(Tokens.Curve.easeOut.delay(0.4), value: isAnimating)

                // Three Sample Suggestion Cards
                VStack(spacing: Spacing.md) {
                    SuggestionPreviewCard(
                        title: "Review design feedback",
                        description: "From Watch list",
                        score: 85,
                        sourceColor: .listWatch
                    )
                    .opacity(isAnimating ? 1 : 0)
                    .offset(x: isAnimating ? 0 : 30)
                    .animation(Tokens.Curve.easeOut.delay(0.5), value: isAnimating)

                    SuggestionPreviewCard(
                        title: "Organize project files",
                        description: "From Later list",
                        score: 72,
                        sourceColor: .listLater
                    )
                    .opacity(isAnimating ? 1 : 0)
                    .offset(x: isAnimating ? 0 : 30)
                    .animation(Tokens.Curve.easeOut.delay(0.6), value: isAnimating)

                    SuggestionPreviewCard(
                        title: "Quick code cleanup",
                        description: "Momentum builder",
                        score: 68,
                        sourceColor: .brandCyan
                    )
                    .opacity(isAnimating ? 1 : 0)
                    .offset(x: isAnimating ? 0 : 30)
                    .animation(Tokens.Curve.easeOut.delay(0.7), value: isAnimating)
                }

                // Footer benefit
                AndreCard(style: .glass) {
                    VStack(spacing: Spacing.sm) {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.brandCyan)
                                .font(.system(size: 20))
                            Text("Switch tasks productively. Keep momentum.")
                                .font(.titleSmall)
                                .foregroundColor(.textPrimary)
                        }

                        Text("Never waste a stuck moment")
                            .font(.bodySmall)
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 30)
                .animation(Tokens.Curve.easeOut.delay(0.8), value: isAnimating)

                // CTA button
                VStack(spacing: Spacing.md) {
                    AndreButton.primary(
                        "Continue",
                        icon: "arrow.right",
                        size: .large,
                        action: onContinue
                    )
                    .opacity(isAnimating ? 1 : 0)
                    .animation(Tokens.Curve.easeOut.delay(0.9), value: isAnimating)

                    if let onSkip = onSkip {
                        AndreButton.borderless(
                            "Skip Tour",
                            size: .medium,
                            action: onSkip
                        )
                        .opacity(isAnimating ? 1 : 0)
                        .animation(Tokens.Curve.easeOut.delay(0.9), value: isAnimating)
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

// MARK: - Suggestion Preview Card Component

/// Individual suggestion card preview with score
private struct SuggestionPreviewCard: View {
    let title: String
    let description: String
    let score: Int
    let sourceColor: Color

    var body: some View {
        AndreCard(style: .elevated) {
            HStack(spacing: Spacing.md) {
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(title)
                        .font(.bodyMedium)
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)

                    Text(description)
                        .font(.bodySmall)
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                // Score circle
                ZStack {
                    Circle()
                        .stroke(sourceColor.opacity(0.2), lineWidth: 3)
                        .frame(width: 48, height: 48)

                    Circle()
                        .trim(from: 0, to: CGFloat(score) / 100.0)
                        .stroke(
                            sourceColor,
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .frame(width: 48, height: 48)
                        .rotationEffect(.degrees(-90))

                    Text("\(score)")
                        .font(.labelMedium)
                        .foregroundColor(sourceColor)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Switch Tab Tour") {
    NavigationStack {
        SwitchTabTourScreen(
            onContinue: {
                print("Continue tapped")
            },
            onSkip: {
                print("Skip tapped")
            }
        )
    }
}

#Preview("Switch Tab Tour - No Skip") {
    NavigationStack {
        SwitchTabTourScreen(onContinue: {})
    }
}

#Preview("Switch Tab Tour - Dark") {
    NavigationStack {
        SwitchTabTourScreen(onContinue: {}, onSkip: {})
    }
    .preferredColorScheme(.dark)
}
