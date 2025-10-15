import Foundation
import Observation

/// View model managing structured procrastination suggestions.
///
/// Fetches contextual suggestions from the backend when users need
/// productive distractions or alternative work options.
@MainActor
@Observable
public final class SuggestionsViewModel {
    // MARK: - Published State

    /// Current suggestions
    public private(set) var suggestions: [Suggestion] = []

    /// Loading state
    public private(set) var isLoading = false

    /// Error state
    public private(set) var error: Error?

    // MARK: - Dependencies

    private let syncService: SyncService

    // MARK: - Initialization

    public init(syncService: SyncService = .shared) {
        self.syncService = syncService
    }

    // MARK: - Actions

    /// Load structured procrastination suggestions
    public func loadSuggestions(limit: Int = 5) async {
        isLoading = true
        error = nil

        do {
            suggestions = try await syncService.fetchSuggestions(limit: limit)
        } catch {
            self.error = error
            print("Failed to load suggestions: \(error)")
            // Fallback to placeholder data for development
            suggestions = Suggestion.placeholderList
        }

        isLoading = false
    }

    /// Refresh suggestions
    public func refresh() async {
        await loadSuggestions()
    }

    /// Get suggestion by score tier
    public func topSuggestions(count: Int = 3) -> [Suggestion] {
        Array(suggestions.sorted { $0.score > $1.score }.prefix(count))
    }

    /// Get suggestions by source
    public func suggestions(from source: Suggestion.Source) -> [Suggestion] {
        suggestions.filter { $0.source == source }
    }

    /// Get suggestions by list type
    public func suggestions(for listType: ListItem.ListType) -> [Suggestion] {
        suggestions.filter { $0.listType == listType }
    }
}
