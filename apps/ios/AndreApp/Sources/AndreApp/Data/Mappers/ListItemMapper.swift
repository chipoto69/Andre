import Foundation

/// Maps between `ListItem` domain model and `ListItemEntity` persistence model.
///
/// Handles conversion of enums to strings and parsing of tags.
/// Maintains sync metadata during round-trip conversions.
public enum ListItemMapper {
    /// Convert domain model to entity for persistence
    public static func toEntity(_ item: ListItem, needsSync: Bool = true) -> ListItemEntity {
        ListItemEntity(
            id: item.id,
            title: item.title,
            listType: item.listType.rawValue,
            status: item.status.rawValue,
            notes: item.notes,
            dueAt: item.dueAt,
            followUpAt: item.followUpAt,
            createdAt: item.createdAt,
            completedAt: item.completedAt,
            tagsString: item.tags.joined(separator: ","),
            needsSync: needsSync
        )
    }

    /// Convert entity to domain model
    public static func toDomain(_ entity: ListItemEntity) -> ListItem? {
        guard let listType = ListItem.ListType(rawValue: entity.listType),
              let status = ListItem.Status(rawValue: entity.status) else {
            return nil
        }

        return ListItem(
            id: entity.id,
            title: entity.title,
            listType: listType,
            status: status,
            notes: entity.notes,
            dueAt: entity.dueAt,
            followUpAt: entity.followUpAt,
            createdAt: entity.createdAt,
            completedAt: entity.completedAt,
            tags: entity.tags
        )
    }

    /// Update existing entity from domain model (preserves sync metadata)
    public static func updateEntity(
        _ entity: ListItemEntity,
        from item: ListItem,
        markForSync: Bool = true
    ) {
        entity.title = item.title
        entity.listType = item.listType.rawValue
        entity.status = item.status.rawValue
        entity.notes = item.notes
        entity.dueAt = item.dueAt
        entity.followUpAt = item.followUpAt
        entity.completedAt = item.completedAt
        entity.tags = item.tags

        if markForSync {
            entity.needsSync = true
            entity.version += 1
        }
    }
}
