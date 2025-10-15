import Foundation
import SwiftData

/// SwiftData entity for persisting Anti-Todo log entries.
///
/// Maps to the domain `AntiTodoLog.Entry` model. These capture
/// completed work that wasn't explicitly planned, revealing momentum
/// and structured procrastination patterns.
@Model
public final class AntiTodoEntryEntity {
    /// Unique identifier matching server ID
    @Attribute(.unique) public var id: UUID

    /// Title/description of the completed unplanned work
    public var title: String

    /// When this work was completed
    public var completedAt: Date

    /// Date grouping (normalized to start of day)
    public var date: Date

    // MARK: - Sync Metadata

    /// Last successful sync with server
    public var lastSyncedAt: Date?

    /// Indicates local changes need syncing
    public var needsSync: Bool

    /// Deletion pending sync (soft delete)
    public var pendingDeletion: Bool

    /// Optimistic lock version
    public var version: Int

    public init(
        id: UUID,
        title: String,
        completedAt: Date = .now,
        date: Date,
        lastSyncedAt: Date? = nil,
        needsSync: Bool = true,
        pendingDeletion: Bool = false,
        version: Int = 0
    ) {
        self.id = id
        self.title = title
        self.completedAt = completedAt
        self.date = date
        self.lastSyncedAt = lastSyncedAt
        self.needsSync = needsSync
        self.pendingDeletion = pendingDeletion
        self.version = version
    }
}
