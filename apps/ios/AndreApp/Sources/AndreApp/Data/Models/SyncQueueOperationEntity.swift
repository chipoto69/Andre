import Foundation
import SwiftData

/// SwiftData entity for tracking pending sync operations.
///
/// Implements offline-first queue where local changes are queued
/// for upload when network becomes available. Operations are processed
/// in FIFO order with exponential backoff for retries.
@Model
public final class SyncQueueOperationEntity {
    /// Unique identifier for this operation
    @Attribute(.unique) public var id: UUID

    /// Operation type (create/update/delete)
    public var operationType: String

    /// Entity type being synced (listItem/focusCard/antiTodoEntry)
    public var entityType: String

    /// ID of the entity being synced
    public var entityId: UUID

    /// JSON payload for the operation
    public var payloadJson: String

    /// When this operation was created
    public var createdAt: Date

    /// Timestamp of the operation for ordering
    public var timestamp: Date

    /// Number of failed attempts
    public var attemptCount: Int

    /// Last attempt timestamp
    public var lastAttemptAt: Date?

    /// Error message from last failure
    public var lastError: String?

    /// Whether operation is currently being processed
    public var isProcessing: Bool

    public init(
        id: UUID = UUID(),
        operationType: String,
        entityType: String,
        entityId: UUID,
        payloadJson: String,
        createdAt: Date = .now,
        timestamp: Date = .now,
        attemptCount: Int = 0,
        lastAttemptAt: Date? = nil,
        lastError: String? = nil,
        isProcessing: Bool = false
    ) {
        self.id = id
        self.operationType = operationType
        self.entityType = entityType
        self.entityId = entityId
        self.payloadJson = payloadJson
        self.createdAt = createdAt
        self.timestamp = timestamp
        self.attemptCount = attemptCount
        self.lastAttemptAt = lastAttemptAt
        self.lastError = lastError
        self.isProcessing = isProcessing
    }
}

// MARK: - Convenience

extension SyncQueueOperationEntity {
    /// Maximum retry attempts before giving up
    public static let maxAttempts = 5

    /// Whether this operation should be retried
    public var shouldRetry: Bool {
        attemptCount < Self.maxAttempts
    }

    /// Calculate backoff delay (exponential: 2^attemptCount seconds)
    public var backoffDelay: TimeInterval {
        pow(2.0, Double(attemptCount))
    }

    /// Whether enough time has passed since last attempt
    public func canRetry() -> Bool {
        guard let lastAttempt = lastAttemptAt else { return true }
        let elapsed = Date.now.timeIntervalSince(lastAttempt)
        return elapsed >= backoffDelay
    }
}
