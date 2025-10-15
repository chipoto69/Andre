import Foundation

/// Maps between `AntiTodoLog.Entry` domain model and `AntiTodoEntryEntity` persistence model.
///
/// Handles date grouping for timeline views and individual entry persistence.
public enum AntiTodoMapper {
    /// Convert domain entry to entity for persistence
    public static func toEntity(_ entry: AntiTodoLog.Entry, date: Date, needsSync: Bool = true) -> AntiTodoEntryEntity {
        AntiTodoEntryEntity(
            id: entry.id,
            title: entry.title,
            completedAt: entry.completedAt,
            date: date,
            needsSync: needsSync
        )
    }

    /// Convert entity to domain entry
    public static func toDomain(_ entity: AntiTodoEntryEntity) -> AntiTodoLog.Entry {
        AntiTodoLog.Entry(
            id: entity.id,
            title: entity.title,
            completedAt: entity.completedAt
        )
    }

    /// Convert entities grouped by date to AntiTodoLog
    public static func toLog(date: Date, entries: [AntiTodoEntryEntity]) -> AntiTodoLog {
        let domainEntries = entries.map(toDomain)
        return AntiTodoLog(date: date, entries: domainEntries)
    }

    /// Update existing entity from domain entry (preserves sync metadata)
    public static func updateEntity(
        _ entity: AntiTodoEntryEntity,
        from entry: AntiTodoLog.Entry,
        markForSync: Bool = true
    ) {
        entity.title = entry.title
        entity.completedAt = entry.completedAt

        if markForSync {
            entity.needsSync = true
            entity.version += 1
        }
    }
}
