import SwiftUI

/// Ninth onboarding screen explaining daily execution principles.
///
/// Shows users how to work with their Focus Card during the day,
/// use structured procrastination, and track wins.
public struct DailyExecutionScreen: View {
    // MARK: - Properties

    let onContinue: () -> Void
    let onSkip: (() -> Void)?

    // MARK: - Animation State

    @State private var isAnimating = false
    @State private var cycleRotation: Double = 0

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
                    Text("During Your Day")
                        .font(.titleLarge)
                        .foregroundColor(.textPrimary)
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 20)

                    Text("Stay on track with your focus")
                        .font(.bodyMedium)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 20)
                }
                .padding(.top, Spacing.xl)
                .animation(Tokens.Curve.easeOut.delay(0.2), value: isAnimating)

                // Three execution principles
                VStack(spacing: Spacing.md) {
                    ExecutionPrincipleCard(
                        icon: "sun.max.fill",
                        iconColor: .brandCyan,
                        title: "Start with your Focus Card",
                        description: "Begin your day by reviewing your 3-5 priority items"
                    )
                    .opacity(isAnimating ? 1 : 0)
                    .offset(x: isAnimating ? 0 : -30)
                    .animation(Tokens.Curve.easeOut.delay(0.3), value: isAnimating)

                    ExecutionPrincipleCard(
                        icon: "arrow.triangle.branch",
                        iconColor: .listWatch,
                        title: "Switch strategically",
                        description: "Use structured procrastination when you need a break"
                    )
                    .opacity(isAnimating ? 1 : 0)
                    .offset(x: isAnimating ? 0 : -30)
                    .animation(Tokens.Curve.easeOut.delay(0.4), value: isAnimating)

                    ExecutionPrincipleCard(
                        icon: "checkmark.circle.fill",
                        iconColor: .listAntiTodo,
                        title: "Track your wins",
                        description: "Log accomplishments in Anti-Todo throughout the day"
                    )
                    .opacity(isAnimating ? 1 : 0)
                    .offset(x: isAnimating ? 0 : -30)
                    .animation(Tokens.Curve.easeOut.delay(0.5), value: isAnimating)
                }

                // Animated cycle diagram
                AndreCard(style: .glass) {
                    VStack(spacing: Spacing.md) {
                        Text("The Execution Cycle")
                            .font(.titleSmall)
                            .foregroundColor(.textPrimary)

                        ZStack {
                            // Background circle
                            Circle()
                                .stroke(Color.brandCyan.opacity(0.2), lineWidth: 2)
                                .frame(width: 160, height: 160)

                            // Cycle steps in circle
                            VStack(spacing: Spacing.xxs) {
                                CycleStepLabel(text: "Focus", color: .brandCyan)
                                    .offset(y: -50)

                                HStack(spacing: 80) {
                                    CycleStepLabel(text: "Wins", color: .listAntiTodo)
                                        .offset(x: -20)

                                    CycleStepLabel(text: "Switch", color: .listWatch)
                                        .offset(x: 20)
                                }
                            }
                            .frame(width: 160, height: 160)

                            // Rotating arrow indicator
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 24))
                                .foregroundColor(.brandCyan)
                                .rotationEffect(.degrees(cycleRotation))
                        }
                        .padding(.vertical, Spacing.sm)
                    }
                }
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 30)
                .animation(Tokens.Curve.easeOut.delay(0.6), value: isAnimating)

                // Footer benefit
                AndreCard(style: .accent) {
                    VStack(spacing: Spacing.sm) {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "sparkles")
                                .foregroundColor(.brandCyan)
                                .font(.system(size: 20))
                            Text("Momentum builds with consistency")
                                .font(.titleSmall)
                                .foregroundColor(.textPrimary)
                        }

                        Text("Small daily wins compound into major progress")
                            .font(.bodySmall)
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 30)
                .animation(Tokens.Curve.easeOut.delay(0.7), value: isAnimating)

                // CTA button
                VStack(spacing: Spacing.md) {
                    AndreButton.primary(
                        "Continue",
                        icon: "arrow.right",
                        size: .large,
                        action: onContinue
                    )
                    .opacity(isAnimating ? 1 : 0)
                    .animation(Tokens.Curve.easeOut.delay(0.8), value: isAnimating)

                    if let onSkip = onSkip {
                        AndreButton.borderless(
                            "Skip Tour",
                            size: .medium,
                            action: onSkip
                        )
                        .opacity(isAnimating ? 1 : 0)
                        .animation(Tokens.Curve.easeOut.delay(0.8), value: isAnimating)
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

            // Start arrow rotation animation
            withAnimation(
                Animation.linear(duration: 3.0)
                    .repeatForever(autoreverses: false)
            ) {
                cycleRotation = 360
            }
        }
    }
}

// MARK: - Execution Principle Card Component

/// Individual execution principle with icon and description
private struct ExecutionPrincipleCard: View {
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

// MARK: - Cycle Step Label Component

/// Label for a step in the execution cycle
private struct CycleStepLabel: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.labelSmall)
            .fontWeight(.semibold)
            .foregroundColor(color)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xxs)
            .background(color.opacity(0.2))
            .cornerRadius(LayoutSize.cornerRadiusPill)
    }
}

// MARK: - Preview

#Preview("Daily Execution") {
    NavigationStack {
        DailyExecutionScreen(
            onContinue: {
                print("Continue tapped")
            },
            onSkip: {
                print("Skip tapped")
            }
        )
    }
}

#Preview("Daily Execution - No Skip") {
    NavigationStack {
        DailyExecutionScreen(onContinue: {})
    }
}

#Preview("Daily Execution - Dark") {
    NavigationStack {
        DailyExecutionScreen(onContinue: {}, onSkip: {})
    }
    .preferredColorScheme(.dark)
}
