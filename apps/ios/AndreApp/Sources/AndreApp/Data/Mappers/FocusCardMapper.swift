import Foundation

/// Maps between `DailyFocusCard` domain model and `FocusCardEntity` persistence model.
///
/// Handles conversion of Meta struct and item references.
/// Note: This mapper only stores item IDs - actual items must be fetched separately.
public enum FocusCardMapper {
    /// Convert domain model to entity for persistence
    public static func toEntity(_ card: DailyFocusCard, needsSync: Bool = true) -> FocusCardEntity {
        let entity = FocusCardEntity(
            id: card.id,
            date: card.date,
            theme: card.meta.theme,
            energyBudget: card.meta.energyBudget.rawValue,
            successMetric: card.meta.successMetric,
            reflection: card.reflection,
            needsSync: needsSync
        )

        // Store item IDs
        entity.itemIds = card.items.map { $0.id }

        return entity
    }

    /// Convert entity to domain model
    /// Note: Items must be fetched separately and provided
    public static func toDomain(
        _ entity: FocusCardEntity,
        items: [ListItem]
    ) -> DailyFocusCard? {
        guard let energyBudget = DailyFocusCard.EnergyBudget(rawValue: entity.energyBudget) else {
            return nil
        }

        let meta = DailyFocusCard.Meta(
            theme: entity.theme,
            energyBudget: energyBudget,
            successMetric: entity.successMetric
        )

        // Filter items that match the stored IDs and preserve order
        let itemIdSet = Set(entity.itemIds)
        let filteredItems = items.filter { itemIdSet.contains($0.id) }

        return DailyFocusCard(
            id: entity.id,
            date: entity.date,
            items: filteredItems,
            meta: meta,
            reflection: entity.reflection
        )
    }

    /// Update existing entity from domain model (preserves sync metadata)
    public static func updateEntity(
        _ entity: FocusCardEntity,
        from card: DailyFocusCard,
        markForSync: Bool = true
    ) {
        entity.theme = card.meta.theme
        entity.energyBudget = card.meta.energyBudget.rawValue
        entity.successMetric = card.meta.successMetric
        entity.reflection = card.reflection
        entity.itemIds = card.items.map { $0.id }

        if markForSync {
            entity.needsSync = true
            entity.version += 1
        }
    }
}
