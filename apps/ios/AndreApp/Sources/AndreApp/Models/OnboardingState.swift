import Foundation

/// Manages onboarding state and progression tracking for first-time users.
///
/// Persists completion status and screen progression to UserDefaults, enabling
/// users to resume onboarding if interrupted and providing analytics on which
/// screens have been viewed.
public struct OnboardingState: Codable {
    // MARK: - Properties

    /// Whether user has completed the full onboarding flow
    public var hasCompletedOnboarding: Bool

    /// Set of screen identifiers that have been viewed
    public var viewedScreens: Set<String>

    /// Whether user has created their first list items
    public var createdFirstItems: Bool

    /// Whether user has created their first focus card
    public var createdFirstFocusCard: Bool

    /// Identifier of the last screen viewed (for resumption)
    public var lastViewedScreen: String?

    /// Timestamp when onboarding was completed
    public var completedAt: Date?

    /// Timestamp when onboarding was started
    public var startedAt: Date?

    // MARK: - Initialization

    public init(
        hasCompletedOnboarding: Bool = false,
        viewedScreens: Set<String> = [],
        createdFirstItems: Bool = false,
        createdFirstFocusCard: Bool = false,
        lastViewedScreen: String? = nil,
        completedAt: Date? = nil,
        startedAt: Date? = nil
    ) {
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.viewedScreens = viewedScreens
        self.createdFirstItems = createdFirstItems
        self.createdFirstFocusCard = createdFirstFocusCard
        self.lastViewedScreen = lastViewedScreen
        self.completedAt = completedAt
        self.startedAt = startedAt
    }

    // MARK: - Persistence

    /// Load onboarding state from UserDefaults
    public static func load() -> OnboardingState {
        guard let data = UserDefaults.standard.data(forKey: UserDefaults.onboardingStateKey) else {
            return OnboardingState()
        }

        do {
            let state = try JSONDecoder().decode(OnboardingState.self, from: data)
            return state
        } catch {
            print("Failed to decode OnboardingState: \(error)")
            return OnboardingState()
        }
    }

    /// Save onboarding state to UserDefaults
    public func save() {
        do {
            let data = try JSONEncoder().encode(self)
            UserDefaults.standard.set(data, forKey: UserDefaults.onboardingStateKey)
        } catch {
            print("Failed to encode OnboardingState: \(error)")
        }
    }

    // MARK: - Actions

    /// Mark a screen as viewed
    public mutating func markScreenViewed(_ screenId: String) {
        viewedScreens.insert(screenId)
        lastViewedScreen = screenId

        // Initialize startedAt on first screen view
        if startedAt == nil {
            startedAt = Date()
        }

        save()
    }

    /// Check if a screen has been viewed
    public func hasViewedScreen(_ screenId: String) -> Bool {
        viewedScreens.contains(screenId)
    }

    /// Mark onboarding as complete
    public mutating func complete() {
        hasCompletedOnboarding = true
        completedAt = Date()
        save()
    }

    /// Mark first items as created
    public mutating func markFirstItemsCreated() {
        createdFirstItems = true
        save()
    }

    /// Mark first focus card as created
    public mutating func markFirstFocusCardCreated() {
        createdFirstFocusCard = true
        save()
    }

    /// Reset onboarding state (for testing or user re-onboarding)
    public mutating func reset() {
        hasCompletedOnboarding = false
        viewedScreens.removeAll()
        createdFirstItems = false
        createdFirstFocusCard = false
        lastViewedScreen = nil
        completedAt = nil
        startedAt = nil
        save()
    }

    // MARK: - Analytics Helpers

    /// Calculate completion percentage (0.0 to 1.0)
    public func completionPercentage(totalScreens: Int) -> Double {
        guard totalScreens > 0 else { return 0.0 }
        return Double(viewedScreens.count) / Double(totalScreens)
    }

    /// Time spent in onboarding (if completed or in progress)
    public var timeSpent: TimeInterval? {
        guard let start = startedAt else { return nil }
        let end = completedAt ?? Date()
        return end.timeIntervalSince(start)
    }
}

// MARK: - UserDefaults Extension

public extension UserDefaults {
    /// Key for legacy simple boolean onboarding flag
    static let onboardingKey = "hasCompletedOnboarding"

    /// Key for detailed onboarding state object
    static let onboardingStateKey = "onboardingState"

    /// Convenience method to check onboarding completion
    var hasCompletedOnboarding: Bool {
        get {
            // Check modern state first, fall back to legacy key
            let state = OnboardingState.load()
            return state.hasCompletedOnboarding || bool(forKey: Self.onboardingKey)
        }
        set {
            var state = OnboardingState.load()
            if newValue {
                state.complete()
            } else {
                state.reset()
            }
        }
    }
}
