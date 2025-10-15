import SwiftUI

/// Fifth onboarding screen explaining the daily focus card.
///
/// Introduces the evening planning ritual and tomorrow's focus card concept,
/// demonstrating how to prioritize 3-5 items for maximum impact.
public struct FocusTabTourScreen: View {
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
                    Text("Tomorrow's Focus Card")
                        .font(.titleLarge)
                        .foregroundColor(.textPrimary)
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 20)

                    Text("Plan tonight. Execute tomorrow.")
                        .font(.bodyMedium)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 20)
                }
                .padding(.top, Spacing.xl)

                // Mock Focus Card Preview
                AndreCard(style: .glass) {
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        // Header with theme and energy
                        HStack {
                            VStack(alignment: .leading, spacing: Spacing.xxs) {
                                Text("Tomorrow")
                                    .font(.labelSmall)
                                    .foregroundColor(.textTertiary)

                                Text("Deep Work Day")
                                    .font(.titleMedium)
                                    .foregroundColor(.textPrimary)
                            }

                            Spacer()

                            // Energy badge
                            HStack(spacing: Spacing.xxs) {
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.brandCyan)
                                Text("High")
                                    .font(.labelSmall)
                                    .foregroundColor(.brandCyan)
                            }
                            .padding(.horizontal, Spacing.sm)
                            .padding(.vertical, Spacing.xxs)
                            .background(Color.brandCyan.opacity(0.1))
                            .cornerRadius(LayoutSize.cornerRadiusPill)
                        }

                        Divider()
                            .background(Color.textTertiary.opacity(0.3))

                        // Sample focus items
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            FocusItemPreview(number: 1, text: "Complete API integration")
                            FocusItemPreview(number: 2, text: "Review design mockups")
                            FocusItemPreview(number: 3, text: "Team sync meeting")
                        }
                    }
                }
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 30)
                .animation(Tokens.Curve.easeOut.delay(0.3), value: isAnimating)

                // Four Key Features
                VStack(spacing: Spacing.sm) {
                    FeaturePointRow(
                        icon: "moon.stars.fill",
                        text: "Plan tomorrow tonight",
                        color: .brandCyan
                    )
                    .opacity(isAnimating ? 1 : 0)
                    .offset(x: isAnimating ? 0 : -20)
                    .animation(Tokens.Curve.easeOut.delay(0.4), value: isAnimating)

                    FeaturePointRow(
                        icon: "target",
                        text: "Choose 3-5 priority items",
                        color: .brandCyan
                    )
                    .opacity(isAnimating ? 1 : 0)
                    .offset(x: isAnimating ? 0 : -20)
                    .animation(Tokens.Curve.easeOut.delay(0.5), value: isAnimating)

                    FeaturePointRow(
                        icon: "bolt.fill",
                        text: "Set your theme and energy budget",
                        color: .brandCyan
                    )
                    .opacity(isAnimating ? 1 : 0)
                    .offset(x: isAnimating ? 0 : -20)
                    .animation(Tokens.Curve.easeOut.delay(0.6), value: isAnimating)

                    FeaturePointRow(
                        icon: "checkmark.seal.fill",
                        text: "Define success for the day",
                        color: .brandCyan
                    )
                    .opacity(isAnimating ? 1 : 0)
                    .offset(x: isAnimating ? 0 : -20)
                    .animation(Tokens.Curve.easeOut.delay(0.7), value: isAnimating)
                }

                // Footer benefit
                AndreCard(style: .accent) {
                    VStack(spacing: Spacing.sm) {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "sparkles")
                                .foregroundColor(.brandCyan)
                                .font(.system(size: 20))
                            Text("Know exactly what deserves attention")
                                .font(.titleSmall)
                                .foregroundColor(.textPrimary)
                        }

                        Text("Wake up with clarity and purpose")
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

// MARK: - Focus Item Preview Component

/// Individual focus item in the preview card
private struct FocusItemPreview: View {
    let number: Int
    let text: String

    var body: some View {
        HStack(spacing: Spacing.sm) {
            // Number circle
            ZStack {
                Circle()
                    .fill(Color.brandCyan.opacity(0.2))
                    .frame(width: 28, height: 28)

                Text("\(number)")
                    .font(.labelMedium)
                    .foregroundColor(.brandCyan)
            }

            Text(text)
                .font(.bodyMedium)
                .foregroundColor(.textPrimary)

            Spacer()
        }
    }
}

// MARK: - Feature Point Row Component

/// Individual feature point with icon and text
private struct FeaturePointRow: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: LayoutSize.iconMedium))
                .foregroundColor(color)
                .frame(width: 32)

            Text(text)
                .font(.bodyMedium)
                .foregroundColor(.textPrimary)

            Spacer()
        }
        .padding(.vertical, Spacing.xs)
    }
}

// MARK: - Preview

#Preview("Focus Tab Tour") {
    NavigationStack {
        FocusTabTourScreen(
            onContinue: {
                print("Continue tapped")
            },
            onSkip: {
                print("Skip tapped")
            }
        )
    }
}

#Preview("Focus Tab Tour - No Skip") {
    NavigationStack {
        FocusTabTourScreen(onContinue: {})
    }
}

#Preview("Focus Tab Tour - Dark") {
    NavigationStack {
        FocusTabTourScreen(onContinue: {}, onSkip: {})
    }
    .preferredColorScheme(.dark)
}
