import SwiftUI

/// Main container view orchestrating the 12-screen onboarding flow.
///
/// Manages page navigation, progress tracking, and completion flow.
/// Integrates with OnboardingViewModel for state persistence.
public struct OnboardingContainerView: View {
    @State private var viewModel = OnboardingViewModel()

    /// Callback when onboarding is completed
    let onComplete: () -> Void

    public init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }

    public var body: some View {
        @Bindable var viewModel = viewModel

        let selection = Binding(
            get: { viewModel.currentScreenIndex },
            set: { index in
                withAnimation(.easeInOut(duration: 0.3)) {
                    viewModel.goToScreenIndex(index)
                }
            }
        )

        ZStack(alignment: .top) {
            // Main content
            TabView(selection: selection) {
                // Phase 1: Philosophy (Screens 1-3)
                WelcomeScreen(
                    onContinue: { goToNext() }
                )
                .tag(0)

                ProblemScreen(
                    onContinue: { goToNext() },
                    onSkip: { skipToScreen(3) }
                )
                .tag(1)

                SolutionScreen(
                    onContinue: { goToNext() },
                    onSkip: { skipToScreen(3) }
                )
                .tag(2)

                // Phase 2: Feature Tour (Screens 4-7)
                ListsTabTourScreen(
                    onContinue: { goToNext() },
                    onSkip: { skipToScreen(7) }
                )
                .tag(3)

                FocusTabTourScreen(
                    onContinue: { goToNext() },
                    onSkip: { skipToScreen(7) }
                )
                .tag(4)

                SwitchTabTourScreen(
                    onContinue: { goToNext() },
                    onSkip: { skipToScreen(7) }
                )
                .tag(5)

                WinsTabTourScreen(
                    onContinue: { goToNext() },
                    onSkip: { skipToScreen(7) }
                )
                .tag(6)

                // Phase 3: Rituals & Execution (Screens 8-9)
                EveningRitualScreen(
                    onContinue: { goToNext() },
                    onSkip: { skipToScreen(9) }
                )
                .tag(7)

                DailyExecutionScreen(
                    onContinue: { goToNext() },
                    onSkip: { skipToScreen(9) }
                )
                .tag(8)

                // Phase 4: Interactive Setup (Screens 10-11)
                FirstItemsScreen(
                    onContinue: { goToNext() },
                    onSkip: { skipToScreen(11) },
                    onItemsCreated: { items in
                        handleFirstItemsCreated(items)
                        goToNext()
                    }
                )
                .tag(9)

                FirstFocusCardScreen(
                    onContinue: { goToNext() },
                    onSkip: { skipToScreen(11) },
                    onFocusCardCreated: { theme, energy, metric in
                        handleFirstFocusCardCreated(theme: theme, energy: energy, metric: metric)
                        goToNext()
                    }
                )
                .tag(10)

                // Phase 5: Final Tour (Screen 12)
                NavigationTourScreen(
                    onContinue: {
                        completeOnboarding()
                    }
                )
                .tag(11)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()

            // Progress bar overlay
            VStack {
                progressBar
                    .padding(.horizontal, Spacing.screenPadding)
                    .padding(.top, Spacing.md)

                Spacer()
            }

            // Back button (hidden on first and last screen)
            if viewModel.currentScreenIndex > 0 && viewModel.currentScreenIndex < 11 {
                VStack {
                    HStack {
                        backButton
                            .padding(.leading, Spacing.screenPadding)
                            .padding(.top, Spacing.md)

                        Spacer()
                    }

                    Spacer()
                }
            }
        }
        .background(Color.backgroundPrimary.ignoresSafeArea())
        .onAppear {
            viewModel.markCurrentScreenViewed()
        }
        .onChange(of: viewModel.currentScreenIndex) { _, _ in
            viewModel.markCurrentScreenViewed()
        }
    }

    // MARK: - Progress Bar

    @ViewBuilder
    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                Capsule()
                    .fill(Color.backgroundTertiary)
                    .frame(height: 4)

                // Progress indicator
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.brandCyan, .brandCyan.opacity(0.6)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress, height: 4)
                    .animation(.easeOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: 4)
    }

    // MARK: - Back Button

    @ViewBuilder
    private var backButton: some View {
        Button {
            goToPrevious()
        } label: {
            HStack(spacing: Spacing.xxs) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))

                Text("Back")
                    .font(.bodySmall)
            }
            .foregroundColor(.brandCyan)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(
                Capsule()
                    .fill(Color.backgroundSecondary)
            )
        }
    }

    // MARK: - Navigation

    private func goToNext() {
        withAnimation(.easeInOut(duration: 0.3)) {
            viewModel.goToNext()
        }
    }

    private func goToPrevious() {
        guard viewModel.canGoBack else { return }

        withAnimation(.easeInOut(duration: 0.3)) {
            viewModel.goToPrevious()
        }
    }

    private func skipToScreen(_ screenIndex: Int) {
        withAnimation(.easeInOut(duration: 0.3)) {
            viewModel.goToScreenIndex(screenIndex)
        }
    }

    private func completeOnboarding() {
        viewModel.completeOnboarding()
        onComplete()
    }

    // MARK: - State Updates

    // MARK: - Interactive Callbacks

    private func handleFirstItemsCreated(_ items: [String]) {
        // Mark milestone in onboarding state
        viewModel.markFirstItemsCreated()

        // TODO: Create actual list items via syncService
        // For now, just log the items
        print("First items created: \(items)")

        // In production, you would call:
        // Task {
        //     for (index, title) in items.enumerated() {
        //         let listType: ListItem.ListType = index == 0 ? .todo : (index == 1 ? .watch : .later)
        //         let item = ListItem(title: title, listType: listType, status: .planned)
        //         try? await syncService.createItem(item)
        //     }
        // }
    }

    private func handleFirstFocusCardCreated(
        theme: String,
        energy: FirstFocusCardScreen.EnergyBudget,
        metric: String
    ) {
        // Mark milestone in onboarding state
        viewModel.markFirstFocusCardCreated()

        // TODO: Create actual focus card via syncService
        // For now, just log the card details
        print("First focus card created - Theme: \(theme), Energy: \(energy), Metric: \(metric)")

        // In production, you would call:
        // Task {
        //     let meta = DailyFocusCard.Meta(
        //         theme: theme,
        //         energyBudget: energyBudgetToDomain(energy),
        //         successMetric: metric
        //     )
        //     let card = DailyFocusCard(
        //         date: Calendar.current.startOfDay(for: Date()),
        //         items: selectedItems,
        //         meta: meta
        //     )
        //     try? await syncService.syncFocusCard(card)
        // }
    }

    // MARK: - Computed Properties

    private var progress: Double {
        viewModel.progress
    }
}

// MARK: - Preview

#Preview("Onboarding Flow") {
    OnboardingContainerView {
        print("Onboarding completed!")
    }
}

#Preview("Starting at Screen 5") {
    struct PreviewWrapper: View {
        @State private var currentPage = 4

        var body: some View {
            OnboardingContainerView {
                print("Onboarding completed!")
            }
        }
    }

    return PreviewWrapper()
}
