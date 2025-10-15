import Foundation
import SwiftData

/// SwiftData entity for persisting daily focus cards.
///
/// Maps to the domain `DailyFocusCard` model. Each card represents
/// a day's planned focus with 3-5 priority items and execution metadata.
@Model
public final class FocusCardEntity {
    /// Unique identifier matching server ID
    @Attribute(.unique) public var id: UUID

    /// Date for this focus card (normalized to start of day)
    @Attribute(.unique) public var date: Date

    /// Theme/intention for the day
    public var theme: String

    /// Energy budget (high/medium/low)
    public var energyBudget: String

    /// Success metric for the day
    public var successMetric: String

    /// Optional end-of-day reflection
    public var reflection: String?

    /// IDs of items selected for this focus card
    /// Stored as comma-separated UUID strings
    public var itemIdsString: String

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
        date: Date,
        theme: String,
        energyBudget: String,
        successMetric: String,
        reflection: String? = nil,
        itemIdsString: String = "",
        lastSyncedAt: Date? = nil,
        needsSync: Bool = true,
        pendingDeletion: Bool = false,
        version: Int = 0
    ) {
        self.id = id
        self.date = date
        self.theme = theme
        self.energyBudget = energyBudget
        self.successMetric = successMetric
        self.reflection = reflection
        self.itemIdsString = itemIdsString
        self.lastSyncedAt = lastSyncedAt
        self.needsSync = needsSync
        self.pendingDeletion = pendingDeletion
        self.version = version
    }
}

// MARK: - Convenience

extension FocusCardEntity {
    /// Parse item IDs from comma-separated string
    public var itemIds: [UUID] {
        get {
            guard !itemIdsString.isEmpty else { return [] }
            return itemIdsString
                .components(separatedBy: ",")
                .compactMap { UUID(uuidString: $0) }
        }
        set {
            itemIdsString = newValue.map { $0.uuidString }.joined(separator: ",")
        }
    }
}
