import SwiftUI

/// Preview container for testing all twelve onboarding screens.
///
/// Provides a TabView to easily navigate between all onboarding screens
/// during development and design iteration.
struct OnboardingScreensPreview: View {
    @State private var currentScreen = 0

    var body: some View {
        TabView(selection: $currentScreen) {
            // Introduction Phase (Screens 1-3)
            WelcomeScreen(onContinue: {
                withAnimation {
                    currentScreen = 1
                }
            })
            .tag(0)

            ProblemScreen(
                onContinue: {
                    withAnimation {
                        currentScreen = 2
                    }
                },
                onSkip: {
                    print("Skip tapped")
                }
            )
            .tag(1)

            SolutionScreen(
                onContinue: {
                    withAnimation {
                        currentScreen = 3
                    }
                },
                onSkip: {
                    print("Skip tapped")
                }
            )
            .tag(2)

            // Feature Tour Phase (Screens 4-7)
            ListsTabTourScreen(
                onContinue: {
                    withAnimation {
                        currentScreen = 4
                    }
                },
                onSkip: {
                    print("Skip tapped")
                }
            )
            .tag(3)

            FocusTabTourScreen(
                onContinue: {
                    withAnimation {
                        currentScreen = 5
                    }
                },
                onSkip: {
                    print("Skip tapped")
                }
            )
            .tag(4)

            SwitchTabTourScreen(
                onContinue: {
                    withAnimation {
                        currentScreen = 6
                    }
                },
                onSkip: {
                    print("Skip tapped")
                }
            )
            .tag(5)

            WinsTabTourScreen(
                onContinue: {
                    withAnimation {
                        currentScreen = 7
                    }
                },
                onSkip: {
                    print("Skip tapped")
                }
            )
            .tag(6)

            // Ritual & Execution Phase (Screens 8-9)
            EveningRitualScreen(
                onContinue: {
                    withAnimation {
                        currentScreen = 8
                    }
                },
                onSkip: {
                    print("Skip tapped")
                }
            )
            .tag(7)

            DailyExecutionScreen(
                onContinue: {
                    withAnimation {
                        currentScreen = 9
                    }
                },
                onSkip: {
                    print("Skip tapped")
                }
            )
            .tag(8)

            // Interactive Setup Phase (Screens 10-11)
            FirstItemsScreen(
                onContinue: {
                    withAnimation {
                        currentScreen = 10
                    }
                },
                onSkip: {
                    print("Skip tapped")
                },
                onItemsCreated: { items in
                    print("Created items: \(items)")
                }
            )
            .tag(9)

            FirstFocusCardScreen(
                onContinue: {
                    withAnimation {
                        currentScreen = 11
                    }
                },
                onSkip: {
                    print("Skip tapped")
                },
                onFocusCardCreated: { theme, energy, metric in
                    print("Created focus card: \(theme), \(energy), \(metric)")
                }
            )
            .tag(10)

            // Final Screen (Screen 12)
            NavigationTourScreen(
                onContinue: {
                    print("Complete onboarding")
                }
            )
            .tag(11)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

// MARK: - Individual Screen Previews

#Preview("All Twelve Screens") {
    OnboardingScreensPreview()
}

// Introduction Phase Previews
#Preview("Welcome Screen Only") {
    WelcomeScreen(onContinue: {})
}

#Preview("Problem Screen Only") {
    ProblemScreen(
        onContinue: {},
        onSkip: {}
    )
}

#Preview("Solution Screen Only") {
    SolutionScreen(
        onContinue: {},
        onSkip: {}
    )
}

// Feature Tour Phase Previews
#Preview("Lists Tab Tour Only") {
    NavigationStack {
        ListsTabTourScreen(
            onContinue: {},
            onSkip: {}
        )
    }
}

#Preview("Focus Tab Tour Only") {
    NavigationStack {
        FocusTabTourScreen(
            onContinue: {},
            onSkip: {}
        )
    }
}

#Preview("Switch Tab Tour Only") {
    NavigationStack {
        SwitchTabTourScreen(
            onContinue: {},
            onSkip: {}
        )
    }
}

#Preview("Wins Tab Tour Only") {
    NavigationStack {
        WinsTabTourScreen(
            onContinue: {},
            onSkip: {}
        )
    }
}

// Ritual & Execution Phase Previews
#Preview("Evening Ritual Only") {
    NavigationStack {
        EveningRitualScreen(
            onContinue: {},
            onSkip: {}
        )
    }
}

#Preview("Daily Execution Only") {
    NavigationStack {
        DailyExecutionScreen(
            onContinue: {},
            onSkip: {}
        )
    }
}

// Interactive Setup Phase Previews
#Preview("First Items Only") {
    NavigationStack {
        FirstItemsScreen(
            onContinue: {},
            onSkip: {},
            onItemsCreated: { _ in }
        )
    }
}

#Preview("First Focus Card Only") {
    NavigationStack {
        FirstFocusCardScreen(
            onContinue: {},
            onSkip: {},
            onFocusCardCreated: { _, _, _ in }
        )
    }
}

// Final Screen Preview
#Preview("Navigation Tour Only") {
    NavigationStack {
        NavigationTourScreen(onContinue: {})
    }
}

// MARK: - Interactive Flow Preview

/// Preview showing the complete flow with view model integration
struct OnboardingFlowPreview: View {
    @State private var viewModel = OnboardingViewModel.preview(screenIndex: 0)

    var body: some View {
        ZStack {
            currentScreenView
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
        }
        .overlay(alignment: .top) {
            // Progress indicator
            HStack(spacing: Spacing.xs) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(index == viewModel.currentScreenIndex ? Color.brandCyan : Color.brandWhite.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.top, Spacing.lg)
        }
        .animation(Tokens.Curve.smoothSpring, value: viewModel.currentScreenIndex)
    }

    @ViewBuilder
    private var currentScreenView: some View {
        switch viewModel.currentScreen {
        case .welcome:
            WelcomeScreen(onContinue: {
                viewModel.goToNext()
            })

        case .problem:
            ProblemScreen(
                onContinue: {
                    viewModel.goToNext()
                },
                onSkip: {
                    viewModel.skipOnboarding()
                }
            )

        case .solution:
            SolutionScreen(
                onContinue: {
                    viewModel.goToNext()
                },
                onSkip: {
                    viewModel.skipOnboarding()
                }
            )

        default:
            Text("Screen: \(viewModel.currentScreen.title)")
                .font(.titleLarge)
                .foregroundColor(.textPrimary)
        }
    }
}

#Preview("Complete Flow with ViewModel") {
    OnboardingFlowPreview()
}
