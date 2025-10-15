import SwiftUI
import Observation

/// View model managing daily focus card state and actions.
///
/// Handles loading, creating, and updating focus cards while coordinating
/// with LocalStore and SyncService for persistence and synchronization.
@MainActor
@Observable
public final class FocusCardViewModel {
    // MARK: - Published State

    /// Current focus card for display
    public private(set) var currentCard: DailyFocusCard?

    /// Loading state
    public private(set) var isLoading = false

    /// AI generation state
    public private(set) var isGeneratingAI = false

    /// Error state
    public private(set) var error: Error?

    /// Selected items for planning
    public var selectedItems: [ListItem] = []

    /// Theme input for new card
    public var theme: String = ""

    /// Energy budget selection
    public var energyBudget: DailyFocusCard.EnergyBudget = .medium

    /// Success metric input
    public var successMetric: String = ""

    // MARK: - Dependencies

    private let localStore: LocalStore
    private let syncService: SyncService

    // MARK: - Initialization

    public init(
        localStore: LocalStore? = nil,
        syncService: SyncService? = nil
    ) {
        self.localStore = localStore ?? LocalStore.shared
        self.syncService = syncService ?? SyncService.shared
    }

    // MARK: - Actions

    /// Load the focus card for a specific date
    public func loadFocusCard(for date: Date = Date()) async {
        isLoading = true
        error = nil

        let normalizedDate = Calendar.current.startOfDay(for: date)

        if let cachedCard = await localStore.loadFocusCard(for: normalizedDate) {
            currentCard = cachedCard
        }

        do {
            let remoteCard = try await syncService.fetchFocusCard(for: normalizedDate)
            currentCard = remoteCard
            await localStore.saveFocusCard(remoteCard)
        } catch {
            if currentCard == nil {
                self.error = error
            }
            print("Failed to load focus card: \(error)")
        }

        isLoading = false
    }

    /// Load tomorrow's focus card
    public func loadTomorrowsCard() async {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        await loadFocusCard(for: tomorrow)
    }

    /// Create a new focus card
    public func createFocusCard(
        date: Date,
        items: [ListItem],
        theme: String,
        energyBudget: DailyFocusCard.EnergyBudget,
        successMetric: String
    ) async {
        isLoading = true
        error = nil

        let meta = DailyFocusCard.Meta(
            theme: theme,
            energyBudget: energyBudget,
            successMetric: successMetric
        )

        let card = DailyFocusCard(
            date: Calendar.current.startOfDay(for: date),
            items: items,
            meta: meta
        )

        await localStore.saveFocusCard(card)

        do {
            try await syncService.syncFocusCard(card)
        } catch {
            self.error = error
            print("Failed to sync focus card: \(error)")
        }

        currentCard = card
        resetPlanningState()
        isLoading = false
    }

    /// Update existing focus card
    public func updateFocusCard(_ card: DailyFocusCard) async {
        isLoading = true
        error = nil

        await localStore.saveFocusCard(card)

        do {
            try await syncService.syncFocusCard(card)
        } catch {
            self.error = error
            print("Failed to sync updated focus card: \(error)")
        }

        currentCard = card
        isLoading = false
    }

    /// Add reflection to focus card
    public func addReflection(_ reflection: String) async {
        guard var card = currentCard else { return }

        card.reflection = reflection
        await updateFocusCard(card)
    }

    /// Mark an item as completed
    public func markItemCompleted(_ item: ListItem) async {
        guard var card = currentCard else { return }

        if let index = card.items.firstIndex(where: { $0.id == item.id }) {
            var updatedItem = card.items[index]
            updatedItem.status = .completed
            updatedItem.completedAt = Date()
            card.items[index] = updatedItem

            await updateFocusCard(card)
        }
    }

    /// Toggle item selection for planning
    public func toggleItemSelection(_ item: ListItem) {
        if selectedItems.contains(where: { $0.id == item.id }) {
            selectedItems.removeAll { $0.id == item.id }
        } else {
            selectedItems.append(item)
        }
    }

    /// Check if an item is selected
    public func isItemSelected(_ item: ListItem) -> Bool {
        selectedItems.contains { $0.id == item.id }
    }

    /// Load available items for planning from local cache and remote sync
    public func loadPlanningItems() async -> [ListItem] {
        var items: [ListItem] = []

        if let cachedBoard = await localStore.loadListBoard() {
            items = planningCandidates(from: cachedBoard)
        }

        do {
            let remoteBoard = try await syncService.fetchListBoard()
            await localStore.cache(board: remoteBoard)
            return planningCandidates(from: remoteBoard)
        } catch {
            print("Failed to refresh planning items: \(error)")
            return items
        }
    }

    /// Validate planning inputs
    public var canCreateCard: Bool {
        !selectedItems.isEmpty &&
        !theme.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !successMetric.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        selectedItems.count >= 1 &&
        selectedItems.count <= 5
    }

    /// Reset planning state
    private func resetPlanningState() {
        selectedItems = []
        theme = ""
        energyBudget = .medium
        successMetric = ""
    }

    /// Get suggested theme based on selected items
    public func suggestedTheme() -> String {
        guard !selectedItems.isEmpty else {
            return ""
        }

        // Simple heuristic: use most common list type
        let listTypes = selectedItems.map { $0.listType }
        let counts = Dictionary(grouping: listTypes) { $0 }
            .mapValues { $0.count }

        if let mostCommon = counts.max(by: { $0.value < $1.value })?.key {
            switch mostCommon {
            case .todo:
                return "Focus on completing key tasks"
            case .watch:
                return "Monitor and follow up"
            case .later:
                return "Tackle deferred priorities"
            case .antiTodo:
                return "Celebrate wins"
            }
        }

        return "Balance multiple priorities"
    }

    // MARK: - AI Generation

    /// Generate focus card with AI assistance
    public func generateFocusCardWithAI(
        from availableItems: [ListItem],
        targetDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    ) async {
        isGeneratingAI = true
        error = nil

        do {
            let generated = try await syncService.generateFocusCard(for: Calendar.current.startOfDay(for: targetDate))

            // Pre-populate wizard fields with AI-generated content
            theme = generated.meta.theme
            energyBudget = generated.meta.energyBudget
            successMetric = generated.meta.successMetric

            let generatedIDs = Set(generated.items.map { $0.id })
            let matchedItems = availableItems.filter { generatedIDs.contains($0.id) }
            if !matchedItems.isEmpty {
                selectedItems = matchedItems
            }

        } catch {
            self.error = error
            print("Failed to generate focus card with AI: \(error)")
        }

        isGeneratingAI = false
    }
}

private extension FocusCardViewModel {
    func planningCandidates(from board: ListBoard) -> [ListItem] {
        board.columns
            .filter { $0.listType != .antiTodo }
            .flatMap { $0.items }
            .filter { $0.status != .archived }
    }
}
