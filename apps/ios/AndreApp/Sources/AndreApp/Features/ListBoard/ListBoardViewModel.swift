import SwiftUI
import Observation

/// View model managing the three-list board state and operations.
///
/// Handles CRUD operations for list items across Todo, Watch, and Later lists.
@MainActor
@Observable
public final class ListBoardViewModel {
    // MARK: - Published State

    /// Current list board
    public private(set) var board: ListBoard

    /// Loading state
    public private(set) var isLoading = false

    /// Error state
    public private(set) var error: Error?

    /// Quick capture sheet presentation
    public var showQuickCapture = false

    /// Selected list type for quick capture
    public var selectedListType: ListItem.ListType = .todo

    /// Filter by list type (nil = show all)
    public var filterListType: ListItem.ListType?

    // MARK: - Dependencies

    private let localStore: LocalStore
    private let syncService: SyncService

    // MARK: - Initialization

    public init(
        localStore: LocalStore = .shared,
        syncService: SyncService = .shared
    ) {
        self.localStore = localStore
        self.syncService = syncService
        self.board = .placeholder
    }

    // MARK: - Actions

    /// Load the current list board
    public func loadBoard() async {
        isLoading = true
        error = nil

        if let cachedBoard = await localStore.loadListBoard() {
            board = cachedBoard
        }

        do {
            let remoteBoard = try await syncService.fetchListBoard()
            board = remoteBoard
            await localStore.cache(board: remoteBoard)
        } catch {
            self.error = error
            print("Failed to load list board: \(error)")
        }

        isLoading = false
    }

    /// Add a new item to a list
    public func addItem(
        title: String,
        listType: ListItem.ListType,
        notes: String? = nil,
        dueAt: Date? = nil,
        tags: [String] = []
    ) async {
        let item = ListItem(
            title: title,
            listType: listType,
            notes: notes,
            dueAt: dueAt,
            tags: tags
        )

        await localStore.saveListItem(item)
        await refreshBoardFromCache()

        do {
            try await syncService.createListItem(item)
        } catch {
            self.error = error
            print("Failed to sync new item: \(error)")
        }
    }

    /// Update an existing item
    public func updateItem(_ item: ListItem) async {
        await localStore.saveListItem(item)
        await refreshBoardFromCache()

        do {
            try await syncService.updateListItem(item)
        } catch {
            self.error = error
            print("Failed to sync updated item: \(error)")
        }
    }

    /// Delete an item
    public func deleteItem(_ item: ListItem) async {
        await localStore.deleteListItem(item.id)
        await refreshBoardFromCache()

        do {
            try await syncService.deleteListItem(item.id)
        } catch {
            self.error = error
            print("Failed to delete item remotely: \(error)")
        }
    }

    /// Move item to a different list
    public func moveItem(_ item: ListItem, to listType: ListItem.ListType) async {
        var updatedItem = item
        updatedItem.listType = listType
        await updateItem(updatedItem)
    }

    /// Toggle item completion status
    public func toggleItemCompletion(_ item: ListItem) async {
        var updatedItem = item

        if updatedItem.status == .completed {
            updatedItem.status = .planned
            updatedItem.completedAt = nil
        } else {
            updatedItem.status = .completed
            updatedItem.completedAt = Date()
        }

        await updateItem(updatedItem)
    }

    /// Get items for a specific list type
    public func items(for listType: ListItem.ListType) -> [ListItem] {
        board.columns.first { $0.listType == listType }?.items ?? []
    }

    /// Get filtered items based on current filter
    public var filteredItems: [ListItem] {
        if let filterType = filterListType {
            return items(for: filterType)
        }

        return board.columns.flatMap { $0.items }
    }

    /// Get item counts per list
    public func itemCount(for listType: ListItem.ListType) -> Int {
        items(for: listType).count
    }

    /// Get active (non-completed) item count
    public func activeItemCount(for listType: ListItem.ListType) -> Int {
        items(for: listType).filter { $0.status != .completed }.count
    }
}

private extension ListBoardViewModel {
    func refreshBoardFromCache() async {
        if let cachedBoard = await localStore.loadListBoard() {
            board = cachedBoard
        }
    }
}
