import Foundation

/// AI-generated suggestion for tomorrow's focus card with reasoning
public struct FocusCardSuggestion: Equatable, Sendable {
    public struct Reasoning: Equatable, Sendable {
        public let itemSelection: String
        public let themeRationale: String
        public let energyEstimate: String

        public init(
            itemSelection: String,
            themeRationale: String,
            energyEstimate: String
        ) {
            self.itemSelection = itemSelection
            self.themeRationale = themeRationale
            self.energyEstimate = energyEstimate
        }
    }

    public let suggestedItemIDs: [UUID]
    public let theme: String
    public let energyBudget: DailyFocusCard.EnergyBudget
    public let successMetric: String
    public let reasoning: Reasoning

    public init(
        suggestedItemIDs: [UUID],
        theme: String,
        energyBudget: DailyFocusCard.EnergyBudget,
        successMetric: String,
        reasoning: Reasoning
    ) {
        self.suggestedItemIDs = suggestedItemIDs
        self.theme = theme
        self.energyBudget = energyBudget
        self.successMetric = successMetric
        self.reasoning = reasoning
    }
}
