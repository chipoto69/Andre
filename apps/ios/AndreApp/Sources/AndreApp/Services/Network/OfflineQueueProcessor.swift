import Foundation

/// Processes pending sync operations from the offline queue.
///
/// Monitors network connectivity and automatically syncs queued operations
/// when connection is available. Implements exponential backoff for failed operations.
@MainActor
public final class OfflineQueueProcessor {
    // MARK: - Properties

    private let localStore: LocalStore
    private let networkMonitor: NetworkMonitor
    private let apiClient: APIClient
    private let decoder: JSONDecoder
    private var processingTask: Task<Void, Never>?
    private var isProcessing = false

    // MARK: - Initialization

    nonisolated public init(
        localStore: LocalStore,
        networkMonitor: NetworkMonitor,
        apiClient: APIClient = APIClient(configuration: .development)
    ) {
        self.localStore = localStore
        self.networkMonitor = networkMonitor
        self.apiClient = apiClient
        self.decoder = JSONDecoder()
    }

    /// Start the processor (must be called after initialization)
    public func start() {
        // Start monitoring network changes
        startMonitoring()
    }

    deinit {
        processingTask?.cancel()
        processingTask = nil
    }

    // MARK: - Monitoring

    private func startMonitoring() {
        // Process queue when network becomes available
        processingTask = Task { @MainActor in
            while !Task.isCancelled {
                // Wait for network connection
                while !networkMonitor.isConnected {
                    try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                }

                // Process queue
                await processQueue()

                // Wait before next check
                try? await Task.sleep(nanoseconds: 30_000_000_000) // 30 seconds
            }
        }
    }

    // MARK: - Queue Processing

    /// Manually trigger queue processing
    public func processQueue() async {
        guard !isProcessing else { return }
        guard networkMonitor.isConnected else { return }

        isProcessing = true
        defer { isProcessing = false }

        let operations = await localStore.getPendingSyncOperations()

        for operation in operations {
            // Check if operation can be retried
            guard operation.shouldRetry else {
                // Too many failures - remove from queue
                await localStore.removeSyncOperation(operation)
                print("⚠️ Sync operation abandoned after \(operation.attemptCount) failures: \(operation.entityType) \(operation.entityId)")
                continue
            }

            // Check backoff delay
            guard operation.canRetry() else {
                continue
            }

            // Mark as processing
            await localStore.markSyncOperationProcessing(operation)

            // Process operation
            do {
                try await processSyncOperation(operation)

                // Success - remove from queue
                await localStore.removeSyncOperation(operation)
                print("✅ Sync operation succeeded: \(operation.operationType) \(operation.entityType) \(operation.entityId)")

            } catch {
                // Failure - record error
                await localStore.recordSyncFailure(operation, error: error.localizedDescription)
                print("❌ Sync operation failed (attempt \(operation.attemptCount + 1)): \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Operation Processing

    private func processSyncOperation(_ operation: SyncQueueOperationEntity) async throws {
        // Decode payload
        guard let payloadData = operation.payloadJson.data(using: .utf8) else {
            throw ProcessingError.invalidPayload
        }

        // Route based on entity type and operation type
        switch (operation.entityType, operation.operationType) {
        case ("listItem", "create"):
            try await processListItemCreate(payloadData)

        case ("listItem", "update"):
            try await processListItemUpdate(payloadData)

        case ("listItem", "delete"):
            try await processListItemDelete(operation.entityId)

        case ("focusCard", "create"), ("focusCard", "update"):
            try await processFocusCardSync(payloadData)

        case ("antiTodoEntry", "create"):
            try await processAntiTodoCreate(payloadData)

        default:
            throw ProcessingError.unsupportedOperation
        }
    }

    // MARK: - Entity-Specific Processing

    private func processListItemCreate(_ payloadData: Data) async throws {
        let dto = try decoder.decode(ListItemDTO.self, from: payloadData)
        try await apiClient.perform(method: "POST", path: "/v1/lists", body: dto)
    }

    private func processListItemUpdate(_ payloadData: Data) async throws {
        let dto = try decoder.decode(ListItemDTO.self, from: payloadData)
        try await apiClient.perform(method: "PUT", path: "/v1/lists/\(dto.id.uuidString)", body: dto)
    }

    private func processListItemDelete(_ itemId: UUID) async throws {
        try await apiClient.perform(method: "DELETE", path: "/v1/lists/\(itemId.uuidString)")
    }

    private func processFocusCardSync(_ payloadData: Data) async throws {
        let dto = try decoder.decode(DailyFocusCardDTO.self, from: payloadData)
        try await apiClient.perform(method: "PUT", path: "/v1/focus-card", body: dto)
    }

    private func processAntiTodoCreate(_ payloadData: Data) async throws {
        let dto = try decoder.decode(AntiTodoEntryDTO.self, from: payloadData)
        try await apiClient.perform(method: "POST", path: "/v1/anti-todo", body: dto)
    }

    // MARK: - Errors

    enum ProcessingError: Error {
        case invalidPayload
        case unsupportedOperation
    }
}
