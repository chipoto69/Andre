import SwiftUI

/// Eighth onboarding screen explaining the nightly ritual.
///
/// Introduces the 5-10 minute evening routine for planning tomorrow,
/// reviewing today's wins, and preparing the next day's focus card.
public struct EveningRitualScreen: View {
    // MARK: - Properties

    let onContinue: () -> Void
    let onSkip: (() -> Void)?

    // MARK: - Animation State

    @State private var isAnimating = false
    @State private var reminderEnabled = false

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
                // Moon icon at top
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.brandCyan)
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : -20)
                    .animation(Tokens.Curve.easeOut.delay(0.2), value: isAnimating)

                // Header
                VStack(spacing: Spacing.md) {
                    Text("The Nightly Ritual")
                        .font(.titleLarge)
                        .foregroundColor(.textPrimary)
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 20)

                    Text("Every evening, 5-10 minutes")
                        .font(.bodyMedium)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 20)
                }
                .padding(.top, Spacing.sm)
                .animation(Tokens.Curve.easeOut.delay(0.3), value: isAnimating)

                // Four numbered steps
                VStack(spacing: Spacing.md) {
                    RitualStepCard(
                        number: 1,
                        text: "Review today's progress and note wins"
                    )
                    .opacity(isAnimating ? 1 : 0)
                    .offset(x: isAnimating ? 0 : -30)
                    .animation(Tokens.Curve.easeOut.delay(0.4), value: isAnimating)

                    RitualStepCard(
                        number: 2,
                        text: "Check Watch items for follow-ups"
                    )
                    .opacity(isAnimating ? 1 : 0)
                    .offset(x: isAnimating ? 0 : -30)
                    .animation(Tokens.Curve.easeOut.delay(0.5), value: isAnimating)

                    RitualStepCard(
                        number: 3,
                        text: "Pick 3-5 items for tomorrow's Focus Card"
                    )
                    .opacity(isAnimating ? 1 : 0)
                    .offset(x: isAnimating ? 0 : -30)
                    .animation(Tokens.Curve.easeOut.delay(0.6), value: isAnimating)

                    RitualStepCard(
                        number: 4,
                        text: "Set your theme and energy budget"
                    )
                    .opacity(isAnimating ? 1 : 0)
                    .offset(x: isAnimating ? 0 : -30)
                    .animation(Tokens.Curve.easeOut.delay(0.7), value: isAnimating)
                }

                // Reminder toggle
                AndreCard(style: .glass) {
                    Toggle(isOn: $reminderEnabled) {
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.brandCyan)
                                .font(.system(size: LayoutSize.iconMedium))

                            Text("Remind me at 8pm")
                                .font(.bodyMedium)
                                .foregroundColor(.textPrimary)
                        }
                    }
                    .tint(.brandCyan)
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
            withAnimation(Tokens.Curve.easeOut.delay(0.1)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Ritual Step Card Component

/// Individual step in the nightly ritual
private struct RitualStepCard: View {
    let number: Int
    let text: String

    var body: some View {
        AndreCard(style: .glass) {
            HStack(spacing: Spacing.md) {
                // Number circle
                ZStack {
                    Circle()
                        .fill(Color.brandCyan.opacity(0.2))
                        .frame(width: 40, height: 40)

                    Text("\(number)")
                        .font(.titleSmall)
                        .fontWeight(.semibold)
                        .foregroundColor(.brandCyan)
                }

                // Step text
                Text(text)
                    .font(.bodyMedium)
                    .foregroundColor(.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

// MARK: - Preview

#Preview("Evening Ritual") {
    NavigationStack {
        EveningRitualScreen(
            onContinue: {
                print("Continue tapped")
            },
            onSkip: {
                print("Skip tapped")
            }
        )
    }
}

#Preview("Evening Ritual - No Skip") {
    NavigationStack {
        EveningRitualScreen(onContinue: {})
    }
}

#Preview("Evening Ritual - Dark") {
    NavigationStack {
        EveningRitualScreen(onContinue: {}, onSkip: {})
    }
    .preferredColorScheme(.dark)
}
