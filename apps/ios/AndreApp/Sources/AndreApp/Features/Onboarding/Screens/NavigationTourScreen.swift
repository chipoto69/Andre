import SwiftUI

/// Twelfth and final onboarding screen showing navigation overview.
///
/// Presents the four main tabs and completes the onboarding experience
/// with a celebratory call-to-action.
public struct NavigationTourScreen: View {
    // MARK: - Properties

    let onContinue: () -> Void

    // MARK: - Animation State

    @State private var isAnimating = false
    @State private var showConfetti = false

    // MARK: - Initialization

    public init(onContinue: @escaping () -> Void) {
        self.onContinue = onContinue
    }

    // MARK: - Body

    public var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    // Celebration icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.brandCyan.opacity(0.3),
                                        Color.brandCyan.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .blur(radius: 20)

                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.brandCyan)
                    }
                    .opacity(isAnimating ? 1 : 0)
                    .scaleEffect(isAnimating ? 1 : 0.5)
                    .animation(Tokens.Curve.spring.delay(0.2), value: isAnimating)
                    .padding(.top, Spacing.xxl)

                    // Header
                    VStack(spacing: Spacing.md) {
                        Text("You're All Set!")
                            .font(.titleLarge)
                            .foregroundColor(.textPrimary)
                            .opacity(isAnimating ? 1 : 0)
                            .offset(y: isAnimating ? 0 : 20)

                        Text("Here's how to navigate Andre")
                            .font(.bodyMedium)
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                            .opacity(isAnimating ? 1 : 0)
                            .offset(y: isAnimating ? 0 : 20)
                    }
                    .animation(Tokens.Curve.easeOut.delay(0.3), value: isAnimating)

                    // Four tab preview cards
                    VStack(spacing: Spacing.md) {
                        TabPreviewCard(
                            icon: "list.bullet",
                            iconColor: .brandCyan,
                            title: "Lists",
                            description: "Your three-list board"
                        )
                        .opacity(isAnimating ? 1 : 0)
                        .offset(x: isAnimating ? 0 : -30)
                        .animation(Tokens.Curve.easeOut.delay(0.4), value: isAnimating)

                        TabPreviewCard(
                            icon: "target",
                            iconColor: .brandCyan,
                            title: "Focus",
                            description: "Daily focus cards"
                        )
                        .opacity(isAnimating ? 1 : 0)
                        .offset(x: isAnimating ? 0 : -30)
                        .animation(Tokens.Curve.easeOut.delay(0.5), value: isAnimating)

                        TabPreviewCard(
                            icon: "arrow.triangle.branch",
                            iconColor: .brandCyan,
                            title: "Switch",
                            description: "Smart suggestions"
                        )
                        .opacity(isAnimating ? 1 : 0)
                        .offset(x: isAnimating ? 0 : -30)
                        .animation(Tokens.Curve.easeOut.delay(0.6), value: isAnimating)

                        TabPreviewCard(
                            icon: "sparkles",
                            iconColor: .brandCyan,
                            title: "Wins",
                            description: "Track accomplishments"
                        )
                        .opacity(isAnimating ? 1 : 0)
                        .offset(x: isAnimating ? 0 : -30)
                        .animation(Tokens.Curve.easeOut.delay(0.7), value: isAnimating)
                    }

                    // Large CTA with gradient
                    VStack(spacing: Spacing.sm) {
                        Button(action: onContinue) {
                            HStack(spacing: Spacing.sm) {
                                Text("Get Started")
                                    .font(.bodyLarge)
                                    .fontWeight(.semibold)

                                Image(systemName: "arrow.right")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: LayoutSize.buttonHeightLarge)
                            .foregroundColor(.brandBlack)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color.brandCyan,
                                        Color.brandCyan.opacity(0.8)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(LayoutSize.cornerRadiusMedium)
                            .shadow(.medium)
                        }
                        .opacity(isAnimating ? 1 : 0)
                        .scaleEffect(isAnimating ? 1 : 0.9)
                        .animation(Tokens.Curve.spring.delay(0.8), value: isAnimating)

                        Text("Start building momentum today")
                            .font(.bodySmall)
                            .foregroundColor(.textTertiary)
                            .opacity(isAnimating ? 1 : 0)
                            .animation(Tokens.Curve.easeOut.delay(0.9), value: isAnimating)
                    }
                    .padding(.top, Spacing.md)
                    .padding(.bottom, Spacing.xl)
                }
                .padding(Spacing.screenPadding)
            }

            // Confetti overlay (simple sparkles)
            if showConfetti {
                ConfettiView()
                    .allowsHitTesting(false)
            }
        }
        .background(Color.backgroundPrimary)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            withAnimation(Tokens.Curve.easeOut.delay(0.1)) {
                isAnimating = true
            }

            // Trigger confetti animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showConfetti = true
            }
        }
    }
}

// MARK: - Tab Preview Card Component

/// Individual tab preview card
private struct TabPreviewCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String

    var body: some View {
        AndreCard(style: .glass) {
            HStack(spacing: Spacing.md) {
                // Tab icon
                ZStack {
                    RoundedRectangle(cornerRadius: LayoutSize.cornerRadiusSmall)
                        .fill(iconColor.opacity(0.2))
                        .frame(width: 44, height: 44)

                    Image(systemName: icon)
                        .font(.system(size: LayoutSize.iconMedium))
                        .foregroundColor(iconColor)
                }

                // Tab info
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(title)
                        .font(.titleSmall)
                        .foregroundColor(.textPrimary)

                    Text(description)
                        .font(.bodySmall)
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.textTertiary)
            }
        }
    }
}

// MARK: - Confetti View

/// Simple confetti celebration effect
private struct ConfettiView: View {
    @State private var animationComplete = false

    var body: some View {
        ZStack {
            ForEach(0..<20) { index in
                ConfettiParticle(delay: Double(index) * 0.05)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                animationComplete = true
            }
        }
    }
}

// MARK: - Confetti Particle

/// Individual confetti particle
private struct ConfettiParticle: View {
    let delay: Double

    @State private var opacity: Double = 1
    @State private var yOffset: CGFloat = -50
    @State private var xOffset: CGFloat = 0
    @State private var rotation: Double = 0

    private let colors: [Color] = [
        .brandCyan,
        .listWatch,
        .listLater,
        .listAntiTodo,
        .brandCyan.opacity(0.6)
    ]

    private var randomColor: Color {
        colors.randomElement() ?? .brandCyan
    }

    private var randomX: CGFloat {
        CGFloat.random(in: -150...150)
    }

    var body: some View {
        Image(systemName: ["sparkle", "star.fill", "circle.fill"].randomElement() ?? "sparkle")
            .font(.system(size: CGFloat.random(in: 12...20)))
            .foregroundColor(randomColor)
            .opacity(opacity)
            .offset(x: xOffset, y: yOffset)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(
                    Animation.easeOut(duration: 2.0)
                        .delay(delay)
                ) {
                    yOffset = UIScreen.main.bounds.height + 100
                    xOffset = randomX
                    rotation = Double.random(in: 0...720)
                    opacity = 0
                }
            }
    }
}

// MARK: - Preview

#Preview("Navigation Tour") {
    NavigationStack {
        NavigationTourScreen(
            onContinue: {
                print("Get Started tapped")
            }
        )
    }
}

#Preview("Navigation Tour - Dark") {
    NavigationStack {
        NavigationTourScreen(onContinue: {})
    }
    .preferredColorScheme(.dark)
}
