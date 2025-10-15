import SwiftUI

/// Main container view orchestrating the streamlined 3-screen onboarding flow.
///
/// Manages page navigation, progress tracking, and completion flow.
/// iOS 26 compliant: Delivers value in <20 seconds with radical simplicity.
public struct OnboardingContainerView: View {
    @State private var currentScreenIndex: Int = 0
    private let totalScreens: Int = 3

    /// Callback when onboarding is completed
    let onComplete: () -> Void

    public init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }

    public var body: some View {
        ZStack(alignment: .top) {
            // Main content
            TabView(selection: $currentScreenIndex) {
                // Screen 1: Value Proposition (5 seconds)
                ValuePropositionScreen(
                    onContinue: { goToNext() },
                    onSkip: { completeOnboarding() }
                )
                .tag(0)

                // Screen 2: Interactive Demo (10 seconds)
                InteractiveDemoScreen(
                    onContinue: { goToNext() },
                    onSkip: { completeOnboarding() }
                )
                .tag(1)

                // Screen 3: Personalization (Optional)
                PersonalizationScreen(
                    onComplete: { completeOnboarding() }
                )
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()

            // Minimalist progress indicator
            VStack {
                HStack(spacing: Spacing.xs) {
                    ForEach(0..<totalScreens, id: \.self) { index in
                        Capsule()
                            .fill(index <= currentScreenIndex ? Color.brandCyan : Color.brandCyan.opacity(0.3))
                            .frame(width: index == currentScreenIndex ? 24 : 8, height: 4)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentScreenIndex)
                    }
                }
                .padding(.horizontal, Spacing.screenPadding)
                .padding(.top, Spacing.md)

                Spacer()
            }
        }
        .background(Color.backgroundPrimary.ignoresSafeArea())
    }

    // MARK: - Navigation

    private func goToNext() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if currentScreenIndex < totalScreens - 1 {
                currentScreenIndex += 1
            } else {
                completeOnboarding()
            }
        }
    }

    private func completeOnboarding() {
        // Mark onboarding as complete
        UserDefaults.standard.hasCompletedOnboarding = true
        onComplete()
    }
}

// MARK: - Preview

#Preview("Streamlined Onboarding") {
    OnboardingContainerView {
        print("Onboarding completed - user ready to start!")
    }
}
