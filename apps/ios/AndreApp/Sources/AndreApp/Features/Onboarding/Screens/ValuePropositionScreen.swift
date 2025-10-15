import SwiftUI

/// Screen 1 of streamlined onboarding - Delivers immediate value proposition in 5 seconds.
///
/// Shows the core concept: "Plan 3-5 things. Complete them. Win."
/// with visual emphasis and clear CTA.
public struct ValuePropositionScreen: View {
    let onContinue: () -> Void
    let onSkip: () -> Void

    @State private var animatePhase: Int = 0

    public init(onContinue: @escaping () -> Void, onSkip: @escaping () -> Void) {
        self.onContinue = onContinue
        self.onSkip = onSkip
    }

    public var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.backgroundPrimary, Color.backgroundSecondary],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: Spacing.xl) {
                Spacer()

                // Hero visual
                heroAnimation

                // Value proposition text
                VStack(spacing: Spacing.md) {
                    Text("Focus on What Matters")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.textPrimary)
                        .multilineTextAlignment(.center)
                        .opacity(animatePhase >= 1 ? 1 : 0)
                        .offset(y: animatePhase >= 1 ? 0 : 20)

                    Text("Plan 3-5 things.\nComplete them.\nWin.")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(8)
                        .opacity(animatePhase >= 2 ? 1 : 0)
                        .offset(y: animatePhase >= 2 ? 0 : 20)
                }
                .padding(.horizontal, Spacing.xl)

                Spacer()

                // CTA buttons
                VStack(spacing: Spacing.md) {
                    AndreButton.primary("Start Planning", icon: "arrow.right") {
                        onContinue()
                    }
                    .opacity(animatePhase >= 3 ? 1 : 0)
                    .scaleEffect(animatePhase >= 3 ? 1 : 0.9)

                    Button("Skip to App") {
                        onSkip()
                    }
                    .font(.bodyMedium)
                    .foregroundColor(.textSecondary)
                    .opacity(animatePhase >= 3 ? 1 : 0)
                }
                .padding(.horizontal, Spacing.screenPadding)
                .padding(.bottom, Spacing.xl)
            }
        }
        .onAppear {
            // Staggered animation entrance
            withAnimation(.easeOut(duration: 0.4)) {
                animatePhase = 1
            }

            withAnimation(.easeOut(duration: 0.4).delay(0.2)) {
                animatePhase = 2
            }

            withAnimation(.easeOut(duration: 0.4).delay(0.4)) {
                animatePhase = 3
            }
        }
    }

    @ViewBuilder
    private var heroAnimation: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(Color.brandCyan.opacity(0.1))
                .frame(width: 200, height: 200)
                .scaleEffect(animatePhase >= 1 ? 1 : 0.5)
                .opacity(animatePhase >= 1 ? 1 : 0)

            // Icon stack representing the 3-list + focus methodology
            VStack(spacing: Spacing.md) {
                // Three dots representing lists
                HStack(spacing: Spacing.sm) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(Color.brandCyan)
                            .frame(width: 12, height: 12)
                            .scaleEffect(animatePhase >= 1 ? 1 : 0)
                            .animation(
                                .spring(response: 0.5, dampingFraction: 0.6)
                                    .delay(Double(index) * 0.1 + 0.3),
                                value: animatePhase
                            )
                    }
                }

                // Arrow down
                Image(systemName: "arrow.down")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.brandCyan)
                    .opacity(animatePhase >= 2 ? 1 : 0)
                    .scaleEffect(animatePhase >= 2 ? 1 : 0)

                // Target icon representing focus
                Image(systemName: "target")
                    .font(.system(size: 48, weight: .regular))
                    .foregroundColor(.brandCyan)
                    .opacity(animatePhase >= 2 ? 1 : 0)
                    .scaleEffect(animatePhase >= 2 ? 1 : 0)
            }
        }
        .padding(.vertical, Spacing.xl)
    }
}

#Preview {
    ValuePropositionScreen(
        onContinue: { print("Continue") },
        onSkip: { print("Skip") }
    )
}
