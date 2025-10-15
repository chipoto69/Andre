import SwiftUI

/// Seventh onboarding screen explaining the Anti-Todo log.
///
/// Introduces the concept of tracking accomplishments instead of just plans,
/// showing how to build momentum through celebrating wins.
public struct WinsTabTourScreen: View {
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
                    // Sparkles icon
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: [
                                    Color.statusSuccess.opacity(0.2),
                                    Color.brandCyan.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 80, height: 80)

                        Image(systemName: "sparkles")
                            .font(.system(size: 36))
                            .foregroundColor(.statusSuccess)
                    }
                    .opacity(isAnimating ? 1 : 0)
                    .scaleEffect(isAnimating ? 1 : 0.8)
                    .animation(Tokens.Curve.spring.delay(0.3), value: isAnimating)

                    Text("Track Your Wins")
                        .font(.titleLarge)
                        .foregroundColor(.textPrimary)
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 20)

                    Text("Celebrate progress, build momentum")
                        .font(.bodyMedium)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 20)
                }
                .padding(.top, Spacing.xl)

                // Anti-Todo Explanation Card
                AndreCard(style: .accent) {
                    VStack(spacing: Spacing.md) {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "trophy.fill")
                                .foregroundColor(.brandCyan)
                            Text("The Anti-Todo")
                                .font(.titleSmall)
                                .foregroundColor(.textPrimary)
                        }

                        Text("Instead of what you plan to do, log what you actually accomplished")
                            .font(.bodyMedium)
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)

                        Divider()
                            .background(Color.textTertiary.opacity(0.3))

                        Text("The secret to productivity is recognizing your wins")
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

                // Sample Win Entries
                VStack(spacing: Spacing.md) {
                    WinEntryPreview(
                        text: "Shipped new feature to production",
                        time: "2 hours ago"
                    )
                    .opacity(isAnimating ? 1 : 0)
                    .offset(x: isAnimating ? 0 : -30)
                    .animation(Tokens.Curve.easeOut.delay(0.5), value: isAnimating)

                    WinEntryPreview(
                        text: "Reviewed design feedback",
                        time: "3 hours ago"
                    )
                    .opacity(isAnimating ? 1 : 0)
                    .offset(x: isAnimating ? 0 : -30)
                    .animation(Tokens.Curve.easeOut.delay(0.6), value: isAnimating)

                    WinEntryPreview(
                        text: "Completed code review",
                        time: "5 hours ago"
                    )
                    .opacity(isAnimating ? 1 : 0)
                    .offset(x: isAnimating ? 0 : -30)
                    .animation(Tokens.Curve.easeOut.delay(0.7), value: isAnimating)
                }

                // Benefits explanation
                AndreCard(style: .glass) {
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .foregroundColor(.statusSuccess)
                            Text("Why Track Wins?")
                                .font(.titleSmall)
                                .foregroundColor(.textPrimary)
                        }

                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            BenefitPoint(text: "See tangible proof of progress")
                            BenefitPoint(text: "Build confidence through accomplishments")
                            BenefitPoint(text: "Recognize patterns in your productivity")
                            BenefitPoint(text: "Combat imposter syndrome with evidence")
                        }
                    }
                }
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 30)
                .animation(Tokens.Curve.easeOut.delay(0.8), value: isAnimating)

                // Footer benefit
                AndreCard(style: .elevated) {
                    VStack(spacing: Spacing.sm) {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.statusSuccess)
                                .font(.system(size: 20))
                            Text("See tangible proof of progress")
                                .font(.titleSmall)
                                .foregroundColor(.textPrimary)
                        }

                        Text("Every win, no matter how small, moves you forward")
                            .font(.bodySmall)
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 30)
                .animation(Tokens.Curve.easeOut.delay(0.9), value: isAnimating)

                // CTA button
                VStack(spacing: Spacing.md) {
                    AndreButton.primary(
                        "Get Started",
                        icon: "checkmark",
                        size: .large,
                        action: onContinue
                    )
                    .opacity(isAnimating ? 1 : 0)
                    .animation(Tokens.Curve.easeOut.delay(1.0), value: isAnimating)

                    if let onSkip = onSkip {
                        AndreButton.borderless(
                            "Skip Tour",
                            size: .medium,
                            action: onSkip
                        )
                        .opacity(isAnimating ? 1 : 0)
                        .animation(Tokens.Curve.easeOut.delay(1.0), value: isAnimating)
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

// MARK: - Win Entry Preview Component

/// Individual win entry preview with checkmark and timestamp
private struct WinEntryPreview: View {
    let text: String
    let time: String

    var body: some View {
        AndreCard(style: .elevated) {
            HStack(spacing: Spacing.md) {
                // Checkmark
                ZStack {
                    Circle()
                        .fill(Color.statusSuccess.opacity(0.2))
                        .frame(width: 32, height: 32)

                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.statusSuccess)
                }

                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(text)
                        .font(.bodyMedium)
                        .foregroundColor(.textPrimary)

                    Text(time)
                        .font(.caption)
                        .foregroundColor(.textTertiary)
                }

                Spacer()
            }
        }
    }
}

// MARK: - Benefit Point Component

/// Small benefit point with checkmark
private struct BenefitPoint: View {
    let text: String

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16))
                .foregroundColor(.statusSuccess)

            Text(text)
                .font(.bodySmall)
                .foregroundColor(.textPrimary)

            Spacer()
        }
    }
}

// MARK: - Preview

#Preview("Wins Tab Tour") {
    NavigationStack {
        WinsTabTourScreen(
            onContinue: {
                print("Continue tapped")
            },
            onSkip: {
                print("Skip tapped")
            }
        )
    }
}

#Preview("Wins Tab Tour - No Skip") {
    NavigationStack {
        WinsTabTourScreen(onContinue: {})
    }
}

#Preview("Wins Tab Tour - Dark") {
    NavigationStack {
        WinsTabTourScreen(onContinue: {}, onSkip: {})
    }
    .preferredColorScheme(.dark)
}
