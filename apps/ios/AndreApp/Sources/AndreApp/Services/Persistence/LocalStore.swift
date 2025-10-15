import Foundation
import SwiftData

/// Handles offline persistence for the three-list system and daily focus cards.
///
/// Rewritten to use SwiftData for real persistence across app launches.
/// Maintains the same async/await API as the placeholder implementation.
public final class LocalStore: @unchecked Sendable {
    @MainActor public static let shared = LocalStore()

    private let modelContainer: ModelContainer
    private let calendar = Calendar.current

    private init() {
        do {
            let schema = Schema([
                ListItemEntity.self,
                FocusCardEntity.self,
                AntiTodoEntryEntity.self,
                SyncQueueOperationEntity.self
            ])

            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )

            self.modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }

    /// Access the model context for database operations
    @MainActor
    private var context: ModelContext {
        modelContainer.mainContext
    }

    // MARK: - List Board Operations

    /// Load the cached list board with all items
    @MainActor
    public func loadListBoard() async -> ListBoard? {
        let descriptor = FetchDescriptor<ListItemEntity>(
            predicate: #Predicate { !$0.pendingDeletion }
        )

        guard let entities = try? context.fetch(descriptor) else {
            return nil
        }

        let items = entities.compactMap(ListItemMapper.toDomain)

        // Group items by list type
        let columns = ListItem.ListType.allCases
            .filter { $0 != .antiTodo }
            .map { listType in
                ListBoard.Column(
                    listType: listType,
                    title: listType.displayName,
                    items: items.filter { $0.listType == listType }
                )
            }

        return ListBoard(columns: columns)
    }

    /// Persist a new board snapshot (bulk replace)
    @MainActor
    public func cache(board: ListBoard) async {
        // Extract all items from columns
        let items = board.columns.flatMap { $0.items }

        // Delete existing items not in the new board
        let newItemIds = Set(items.map { $0.id })
        let descriptor = FetchDescriptor<ListItemEntity>()

        if let existingEntities = try? context.fetch(descriptor) {
            for entity in existingEntities where !newItemIds.contains(entity.id) {
                context.delete(entity)
            }
        }

        // Upsert all items from the board
        for item in items {
            await saveListItem(item, markForSync: false)
        }

        try? context.save()
    }

    /// Upsert a list item in the local cache
    @MainActor
    public func saveListItem(_ item: ListItem, markForSync: Bool = true) async {
        let descriptor = FetchDescriptor<ListItemEntity>(
            predicate: #Predicate { $0.id == item.id }
        )

        if let existingEntity = try? context.fetch(descriptor).first {
            // Update existing entity
            ListItemMapper.updateEntity(existingEntity, from: item, markForSync: markForSync)
        } else {
            // Create new entity
            let newEntity = ListItemMapper.toEntity(item, needsSync: markForSync)
            context.insert(newEntity)
        }

        try? context.save()
    }

    /// Remove a list item from the cache (soft delete)
    @MainActor
    public func deleteListItem(_ id: UUID) async {
        let descriptor = FetchDescriptor<ListItemEntity>(
            predicate: #Predicate { $0.id == id }
        )

        guard let entity = try? context.fetch(descriptor).first else {
            return
        }

        // Soft delete: mark for deletion but keep for sync
        entity.pendingDeletion = true
        entity.needsSync = true
        entity.version += 1

        try? context.save()
    }

    // MARK: - Focus Card Operations

    /// Load a focus card for a given date
    @MainActor
    public func loadFocusCard(for date: Date) async -> DailyFocusCard? {
        let normalizedDate = normalized(date)

        let descriptor = FetchDescriptor<FocusCardEntity>(
            predicate: #Predicate { $0.date == normalizedDate && !$0.pendingDeletion }
        )

        guard let entity = try? context.fetch(descriptor).first else {
            return nil
        }

        // Fetch the items referenced by this focus card
        let itemIds = entity.itemIds
        let itemsDescriptor = FetchDescriptor<ListItemEntity>(
            predicate: #Predicate { itemIds.contains($0.id) && !$0.pendingDeletion }
        )

        let itemEntities = (try? context.fetch(itemsDescriptor)) ?? []
        let items = itemEntities.compactMap(ListItemMapper.toDomain)

        return FocusCardMapper.toDomain(entity, items: items)
    }

    /// Save or replace the cached focus card
    @MainActor
    public func saveFocusCard(_ card: DailyFocusCard, markForSync: Bool = true) async {
        let normalizedDate = normalized(card.date)

        let descriptor = FetchDescriptor<FocusCardEntity>(
            predicate: #Predicate { $0.date == normalizedDate }
        )

        if let existingEntity = try? context.fetch(descriptor).first {
            // Update existing entity
            FocusCardMapper.updateEntity(existingEntity, from: card, markForSync: markForSync)
        } else {
            // Create new entity
            let newEntity = FocusCardMapper.toEntity(card, needsSync: markForSync)
            context.insert(newEntity)
        }

        try? context.save()
    }

    // MARK: - Anti-Todo Operations

    /// Load the Anti-Todo log for a given date
    @MainActor
    public func loadAntiTodoLog(for date: Date) async -> AntiTodoLog {
        let normalizedDate = normalized(date)

        let descriptor = FetchDescriptor<AntiTodoEntryEntity>(
            predicate: #Predicate { $0.date == normalizedDate && !$0.pendingDeletion },
            sortBy: [SortDescriptor(\.completedAt, order: .forward)]
        )

        guard let entities = try? context.fetch(descriptor) else {
            return AntiTodoLog(date: date, entries: [])
        }

        return AntiTodoMapper.toLog(date: date, entries: entities)
    }

    /// Append an Anti-Todo entry for the provided date (defaults to today)
    @MainActor
    public func appendAntiTodoEntry(_ entry: AntiTodoLog.Entry, on date: Date = Date()) async {
        let normalizedDate = normalized(date)
        let entity = AntiTodoMapper.toEntity(entry, date: normalizedDate, needsSync: true)
        context.insert(entity)

        try? context.save()
    }

    /// Replace the cached Anti-Todo log with a new snapshot
    @MainActor
    public func saveAntiTodoLog(_ log: AntiTodoLog) async {
        let normalizedDate = normalized(log.date)

        // Delete existing entries for this date
        let descriptor = FetchDescriptor<AntiTodoEntryEntity>(
            predicate: #Predicate { $0.date == normalizedDate }
        )

        if let existingEntities = try? context.fetch(descriptor) {
            for entity in existingEntities {
                context.delete(entity)
            }
        }

        // Insert new entries
        for entry in log.entries {
            let entity = AntiTodoMapper.toEntity(entry, date: normalizedDate, needsSync: false)
            context.insert(entity)
        }

        try? context.save()
    }

    // MARK: - Sync Queue Operations

    /// Get all pending sync operations
    @MainActor
    public func getPendingSyncOperations() async -> [SyncQueueOperationEntity] {
        let descriptor = FetchDescriptor<SyncQueueOperationEntity>(
            predicate: #Predicate { !$0.isProcessing },
            sortBy: [SortDescriptor(\.timestamp, order: .forward)]
        )

        return (try? context.fetch(descriptor)) ?? []
    }

    /// Mark sync operation as processing
    @MainActor
    public func markSyncOperationProcessing(_ operation: SyncQueueOperationEntity) async {
        operation.isProcessing = true
        try? context.save()
    }

    /// Remove completed sync operation
    @MainActor
    public func removeSyncOperation(_ operation: SyncQueueOperationEntity) async {
        context.delete(operation)
        try? context.save()
    }

    /// Record failed sync attempt
    @MainActor
    public func recordSyncFailure(_ operation: SyncQueueOperationEntity, error: String) async {
        operation.attemptCount += 1
        operation.lastAttemptAt = Date.now
        operation.lastError = error
        operation.isProcessing = false
        try? context.save()
    }

    // MARK: - Private Helpers

    private func normalized(_ date: Date) -> Date {
        calendar.startOfDay(for: date)
    }
}

// MARK: - Backward Compatibility (Completion-based API)

public extension LocalStore {
    func fetchBoard(completion: @escaping (ListBoard) -> Void) {
        Task { @MainActor in
            if let board = await loadListBoard() {
                completion(board)
            } else {
                completion(ListBoard.placeholder)
            }
        }
    }

    func saveBoard(_ board: ListBoard, completion: (() -> Void)? = nil) {
        Task { @MainActor in
            await cache(board: board)
            completion?()
        }
    }

    func fetchFocusCard(completion: @escaping (DailyFocusCard) -> Void) {
        Task { @MainActor in
            if let card = await loadFocusCard(for: .now) {
                completion(card)
            } else {
                completion(DailyFocusCard.placeholder)
            }
        }
    }

    func saveFocusCard(_ card: DailyFocusCard, completion: (() -> Void)? = nil) {
        Task { @MainActor in
            await saveFocusCard(card)
            completion?()
        }
    }

    func fetchAntiTodoLog(completion: @escaping (AntiTodoLog) -> Void) {
        Task { @MainActor in
            let log = await loadAntiTodoLog(for: .now)
            completion(log)
        }
    }

    func appendAntiTodoEntry(_ entry: AntiTodoLog.Entry, completion: (() -> Void)? = nil) {
        Task { @MainActor in
            await appendAntiTodoEntry(entry)
            completion?()
        }
    }
}
