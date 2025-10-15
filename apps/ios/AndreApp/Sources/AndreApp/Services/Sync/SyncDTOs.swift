import Foundation

struct BoardDTO: Codable {
    let todo: [ListItemDTO]
    let watch: [ListItemDTO]
    let later: [ListItemDTO]
    let antiTodo: [ListItemDTO]

    func toDomain(using formatter: ISO8601DateFormatter, dayFormatter: DateFormatter) -> ListBoard {
        let columns: [ListBoard.Column] = [
            (.todo, "Todo", todo),
            (.watch, "Watch", watch),
            (.later, "Later", later)
        ].map { listType, title, items in
            ListBoard.Column(
                listType: listType,
                title: title,
                items: items.compactMap { $0.toDomain(using: formatter, dayFormatter: dayFormatter) }
            )
        }

        return ListBoard(columns: columns)
    }
}

struct ListItemDTO: Codable {
    let id: UUID
    let title: String
    let listType: ListItem.ListType
    let status: String
    let notes: String?
    let dueAt: String?
    let followUpAt: String?
    let createdAt: String
    let completedAt: String?
    let tags: [String]

    init(item: ListItem, formatter: ISO8601DateFormatter) {
        id = item.id
        title = item.title
        listType = item.listType
        status = item.status.rawValue
        notes = item.notes
        dueAt = item.dueAt.map { formatter.string(from: $0) }
        followUpAt = item.followUpAt.map { formatter.string(from: $0) }
        createdAt = formatter.string(from: item.createdAt)
        completedAt = item.completedAt.map { formatter.string(from: $0) }
        tags = item.tags
    }

    func toDomain(using formatter: ISO8601DateFormatter, dayFormatter: DateFormatter) -> ListItem? {
        ListItem(
            id: id,
            title: title,
            listType: listType,
            status: ListItem.Status(rawValue: status) ?? .planned,
            notes: notes,
            dueAt: dueAt.flatMap { Self.parseDate($0, isoFormatter: formatter, dayFormatter: dayFormatter) },
            followUpAt: followUpAt.flatMap { Self.parseDate($0, isoFormatter: formatter, dayFormatter: dayFormatter) },
            createdAt: Self.parseDate(createdAt, isoFormatter: formatter, dayFormatter: dayFormatter) ?? Date(),
            completedAt: completedAt.flatMap { Self.parseDate($0, isoFormatter: formatter, dayFormatter: dayFormatter) },
            tags: tags
        )
    }

    private static let fallbackISOFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    static func parseDate(_ value: String, isoFormatter: ISO8601DateFormatter, dayFormatter: DateFormatter) -> Date? {
        if let date = isoFormatter.date(from: value) {
            return date
        }
        if let fallback = fallbackISOFormatter.date(from: value) {
            return fallback
        }
        return dayFormatter.date(from: value)
    }
}

struct DailyFocusCardDTO: Codable {
    struct MetaDTO: Codable {
        let theme: String
        let energyBudget: DailyFocusCard.EnergyBudget
        let successMetric: String
    }

    let id: UUID
    let date: String
    let items: [ListItemDTO]
    let meta: MetaDTO
    let reflection: String?

    init(card: DailyFocusCard, formatter: ISO8601DateFormatter, dayFormatter: DateFormatter) {
        id = card.id
        date = dayFormatter.string(from: card.date)
        items = card.items.map { ListItemDTO(item: $0, formatter: formatter) }
        meta = MetaDTO(
            theme: card.meta.theme,
            energyBudget: card.meta.energyBudget,
            successMetric: card.meta.successMetric
        )
        reflection = card.reflection
    }

    func toDomain(using formatter: ISO8601DateFormatter, dayFormatter: DateFormatter) -> DailyFocusCard? {
        guard let parsedDate = ListItemDTO.parseDate(date, isoFormatter: formatter, dayFormatter: dayFormatter) else {
            return nil
        }

        return DailyFocusCard(
            id: id,
            date: parsedDate,
            items: items.compactMap { $0.toDomain(using: formatter, dayFormatter: dayFormatter) },
            meta: DailyFocusCard.Meta(
                theme: meta.theme,
                energyBudget: meta.energyBudget,
                successMetric: meta.successMetric
            ),
            reflection: reflection
        )
    }
}

struct AntiTodoEntryDTO: Codable {
    let id: UUID
    let title: String
    let completedAt: String

    init(entry: AntiTodoLog.Entry, formatter: ISO8601DateFormatter) {
        id = entry.id
        title = entry.title
        completedAt = formatter.string(from: entry.completedAt)
    }

    func toDomain(using formatter: ISO8601DateFormatter, dayFormatter: DateFormatter) -> AntiTodoLog.Entry {
        let date = ListItemDTO.parseDate(completedAt, isoFormatter: formatter, dayFormatter: dayFormatter) ?? Date()
        return AntiTodoLog.Entry(id: id, title: title, completedAt: date)
    }
}
