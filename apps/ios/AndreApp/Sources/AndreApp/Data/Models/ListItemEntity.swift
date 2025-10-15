import Foundation
import SwiftData

/// SwiftData entity for persisting list items across app launches.
///
/// Maps to the domain `ListItem` model via mappers. This entity includes
/// sync tracking fields for offline-first operation.
@Model
public final class ListItemEntity {
    /// Unique identifier matching server ID
    @Attribute(.unique) public var id: UUID

    /// Item title/description
    public var title: String

    /// List type (todo/watch/later/antiTodo)
    public var listType: String

    /// Current status (planned/inProgress/completed/archived)
    public var status: String

    /// Optional notes
    public var notes: String?

    /// Optional due date
    public var dueAt: Date?

    /// Optional follow-up reminder date
    public var followUpAt: Date?

    /// Creation timestamp
    public var createdAt: Date

    /// Completion timestamp
    public var completedAt: Date?

    /// Comma-separated tags for filtering
    public var tagsString: String

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
        listType: String,
        status: String,
        notes: String? = nil,
        dueAt: Date? = nil,
        followUpAt: Date? = nil,
        createdAt: Date = .now,
        completedAt: Date? = nil,
        tagsString: String = "",
        lastSyncedAt: Date? = nil,
        needsSync: Bool = true,
        pendingDeletion: Bool = false,
        version: Int = 0
    ) {
        self.id = id
        self.title = title
        self.listType = listType
        self.status = status
        self.notes = notes
        self.dueAt = dueAt
        self.followUpAt = followUpAt
        self.createdAt = createdAt
        self.completedAt = completedAt
        self.tagsString = tagsString
        self.lastSyncedAt = lastSyncedAt
        self.needsSync = needsSync
        self.pendingDeletion = pendingDeletion
        self.version = version
    }
}

// MARK: - Convenience

extension ListItemEntity {
    /// Parse tags from comma-separated string
    public var tags: [String] {
        get {
            tagsString.isEmpty ? [] : tagsString.components(separatedBy: ",")
        }
        set {
            tagsString = newValue.joined(separator: ",")
        }
    }
}
