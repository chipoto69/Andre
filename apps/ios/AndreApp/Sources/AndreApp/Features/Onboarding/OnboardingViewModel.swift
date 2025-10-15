import SwiftUI
import Observation

/// View model managing onboarding flow navigation and state coordination.
///
/// Handles progression through 12 onboarding screens, coordinates with
/// OnboardingState for persistence, and provides navigation controls
/// for the onboarding experience.
@MainActor
@Observable
public final class OnboardingViewModel {
    // MARK: - Onboarding Screens

    /// All onboarding screens in order
    public enum OnboardingScreen: String, CaseIterable, Identifiable {
        case welcome
        case problem
        case solution
        case listsTour
        case focusTour
        case switchTour
        case winsTour
        case eveningRitual
        case dailyExecution
        case firstItems
        case firstFocusCard
        case navigationTour

        public var id: String { rawValue }

        /// Display title for each screen
        public var title: String {
            switch self {
            case .welcome:
                return "Welcome to Andre"
            case .problem:
                return "The Todo List Problem"
            case .solution:
                return "The Three-List Solution"
            case .listsTour:
                return "Your Three Lists"
            case .focusTour:
                return "Daily Focus Cards"
            case .switchTour:
                return "Smart Switching"
            case .winsTour:
                return "Celebrate Your Wins"
            case .eveningRitual:
                return "Evening Ritual"
            case .dailyExecution:
                return "Daily Execution"
            case .firstItems:
                return "Create Your First Items"
            case .firstFocusCard:
                return "Plan Tomorrow"
            case .navigationTour:
                return "Navigation Tour"
            }
        }

        /// Screen category for analytics and grouping
        public var category: ScreenCategory {
            switch self {
            case .welcome, .problem, .solution:
                return .introduction
            case .listsTour, .focusTour, .switchTour, .winsTour:
                return .conceptTour
            case .eveningRitual, .dailyExecution:
                return .workflowExplanation
            case .firstItems, .firstFocusCard:
                return .interactiveTutorial
            case .navigationTour:
                return .appTour
            }
        }
    }

    public enum ScreenCategory {
        case introduction
        case conceptTour
        case workflowExplanation
        case interactiveTutorial
        case appTour
    }

    // MARK: - Published State

    /// Current screen index in the flow
    public private(set) var currentScreenIndex: Int = 0

    /// Onboarding state for persistence
    public private(set) var state: OnboardingState

    /// Whether onboarding can be dismissed (minimum screens viewed)
    public var canDismiss: Bool {
        state.viewedScreens.count >= 3
    }

    // MARK: - Computed Properties

    /// Current screen being displayed
    public var currentScreen: OnboardingScreen {
        let screens = OnboardingScreen.allCases
        guard currentScreenIndex < screens.count else {
            return screens.last ?? .welcome
        }
        return screens[currentScreenIndex]
    }

    /// All screens in order
    public var screens: [OnboardingScreen] {
        OnboardingScreen.allCases
    }

    /// Total number of screens
    public var totalScreens: Int {
        screens.count
    }

    /// Progress through onboarding (0.0 to 1.0)
    public var progress: Double {
        guard totalScreens > 0 else { return 0.0 }
        return Double(currentScreenIndex + 1) / Double(totalScreens)
    }

    /// Can navigate to previous screen
    public var canGoBack: Bool {
        currentScreenIndex > 0
    }

    /// Can navigate to next screen
    public var canGoNext: Bool {
        currentScreenIndex < totalScreens - 1
    }

    /// Is on final screen
    public var isOnFinalScreen: Bool {
        currentScreenIndex == totalScreens - 1
    }

    // MARK: - Initialization

    public init(state: OnboardingState = .load()) {
        self.state = state

        // Resume from last viewed screen if available
        if let lastScreen = state.lastViewedScreen,
           let screen = OnboardingScreen(rawValue: lastScreen),
           let index = screens.firstIndex(of: screen) {
            currentScreenIndex = index
        }
    }

    // MARK: - Navigation Actions

    /// Navigate to the next screen
    public func goToNext() {
        guard canGoNext else {
            // If on final screen, complete onboarding
            completeOnboarding()
            return
        }

        currentScreenIndex += 1
        markCurrentScreenViewed()
    }

    /// Navigate to the previous screen
    public func goToPrevious() {
        guard canGoBack else { return }
        currentScreenIndex -= 1
        markCurrentScreenViewed()
    }

    /// Jump to a specific screen by index
    public func goToScreen(_ screen: OnboardingScreen) {
        guard let index = screens.firstIndex(of: screen) else { return }
        currentScreenIndex = index
        markCurrentScreenViewed()
    }

    /// Jump to a specific screen by index
    public func goToScreenIndex(_ index: Int) {
        guard index >= 0 && index < totalScreens else { return }
        currentScreenIndex = index
        markCurrentScreenViewed()
    }

    /// Skip onboarding entirely
    public func skipOnboarding() {
        // Mark at least current screen as viewed for analytics
        markCurrentScreenViewed()
        completeOnboarding()
    }

    /// Complete onboarding flow
    public func completeOnboarding() {
        markCurrentScreenViewed()
        state.complete()
    }

    // MARK: - State Management

    /// Mark the current screen as viewed
    public func markCurrentScreenViewed() {
        state.markScreenViewed(currentScreen.rawValue)
    }

    /// Mark screen viewed by identifier
    public func markScreenViewed(_ screenId: String) {
        state.markScreenViewed(screenId)
    }

    /// Check if a screen has been viewed
    public func hasViewedScreen(_ screen: OnboardingScreen) -> Bool {
        state.hasViewedScreen(screen.rawValue)
    }

    /// Mark first items as created (during interactive tutorial)
    public func markFirstItemsCreated() {
        state.markFirstItemsCreated()
    }

    /// Mark first focus card as created (during interactive tutorial)
    public func markFirstFocusCardCreated() {
        state.markFirstFocusCardCreated()
    }

    /// Reset onboarding (for testing or re-onboarding)
    public func reset() {
        state.reset()
        currentScreenIndex = 0
    }

    // MARK: - Analytics Helpers

    /// Get screens by category
    public func screens(in category: ScreenCategory) -> [OnboardingScreen] {
        screens.filter { $0.category == category }
    }

    /// Get completion percentage for a category
    public func completionPercentage(for category: ScreenCategory) -> Double {
        let categoryScreens = screens(in: category)
        guard !categoryScreens.isEmpty else { return 0.0 }

        let viewedCount = categoryScreens.filter { hasViewedScreen($0) }.count
        return Double(viewedCount) / Double(categoryScreens.count)
    }

    /// Time spent in onboarding so far
    public var timeSpent: TimeInterval? {
        state.timeSpent
    }
}

// MARK: - Preview Helpers

extension OnboardingViewModel {
    /// Create a view model for previews at a specific screen
    public static func preview(at screen: OnboardingScreen) -> OnboardingViewModel {
        let state = OnboardingState()
        let viewModel = OnboardingViewModel(state: state)
        viewModel.goToScreen(screen)
        return viewModel
    }

    /// Create a view model for previews with specific progress
    public static func preview(screenIndex: Int) -> OnboardingViewModel {
        let state = OnboardingState()
        let viewModel = OnboardingViewModel(state: state)
        viewModel.goToScreenIndex(screenIndex)
        return viewModel
    }
}
