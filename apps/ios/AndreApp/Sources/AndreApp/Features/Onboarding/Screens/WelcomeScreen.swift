import SwiftUI

/// First onboarding screen introducing Andre and its core value proposition.
///
/// Presents brand name, tagline, and brief intro with an immersive full-screen
/// experience using cyan accent gradients.
public struct WelcomeScreen: View {
    // MARK: - Properties

    let onContinue: () -> Void

    // MARK: - Animation State

    @State private var isAnimating = false

    // MARK: - Initialization

    public init(onContinue: @escaping () -> Void) {
        self.onContinue = onContinue
    }

    // MARK: - Body

    public var body: some View {
        ZStack {
            // Background gradient
            LinearGradient.brandGradient
                .ignoresSafeArea()

            VStack(spacing: Spacing.xxxl) {
                Spacer()

                // Main content card
                VStack(spacing: Spacing.xl) {
                    // App branding
                    VStack(spacing: Spacing.lg) {
                        // Andre logo/name
                        Text("Andre")
                            .font(.displayLarge)
                            .foregroundColor(.textPrimary)
                            .opacity(isAnimating ? 1 : 0)
                            .offset(y: isAnimating ? 0 : 20)

                        // Tagline
                        Text("Master focus. Build momentum. Track wins.")
                            .font(.titleMedium)
                            .foregroundColor(.brandCyan)
                            .multilineTextAlignment(.center)
                            .opacity(isAnimating ? 1 : 0)
                            .offset(y: isAnimating ? 0 : 20)
                    }

                    // Description
                    AndreCard(style: .accent) {
                        VStack(spacing: Spacing.md) {
                            Text("Based on Marc Andreessen's three-list productivity system")
                                .font(.bodyLarge)
                                .foregroundColor(.textPrimary)
                                .multilineTextAlignment(.center)
                                .lineLimit(3)

                            HStack(spacing: Spacing.md) {
                                FeaturePill(icon: "list.bullet", text: "Three Lists")
                                FeaturePill(icon: "target", text: "Daily Focus")
                                FeaturePill(icon: "trophy", text: "Track Wins")
                            }
                        }
                    }
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 30)
                }

                Spacer()

                // CTA button
                AndreButton.primary(
                    "Get Started",
                    icon: "arrow.right",
                    size: .large,
                    action: onContinue
                )
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 20)
            }
            .padding(Spacing.screenPadding)
        }
        .onAppear {
            withAnimation(Tokens.Curve.easeOut.delay(0.2)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Feature Pill Component

/// Small pill-shaped indicator for key features
private struct FeaturePill: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text(text)
                .font(.labelSmall)
        }
        .foregroundColor(.textPrimary)
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(Color.backgroundTertiary)
        .cornerRadius(LayoutSize.cornerRadiusPill)
    }
}

// MARK: - Preview

#Preview("Welcome Screen") {
    WelcomeScreen(onContinue: {
        print("Continue tapped")
    })
}

#Preview("Welcome Screen - Dark") {
    WelcomeScreen(onContinue: {})
        .preferredColorScheme(.dark)
}
