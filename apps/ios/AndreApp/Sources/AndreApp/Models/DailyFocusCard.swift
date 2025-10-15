import Foundation

public struct DailyFocusCard: Identifiable, Hashable, Codable {
    public struct Meta: Hashable, Codable {
        public var theme: String
        public var energyBudget: EnergyBudget
        public var successMetric: String

        public init(theme: String, energyBudget: EnergyBudget, successMetric: String) {
            self.theme = theme
            self.energyBudget = energyBudget
            self.successMetric = successMetric
        }
    }

    public enum EnergyBudget: String, Codable {
        case high
        case medium
        case low
    }

    public let id: UUID
    public var date: Date
    public var items: [ListItem]
    public var meta: Meta
    public var reflection: String?

    public init(
        id: UUID = UUID(),
        date: Date,
        items: [ListItem],
        meta: Meta,
        reflection: String? = nil
    ) {
        self.id = id
        self.date = date
        self.items = items
        self.meta = meta
        self.reflection = reflection
    }
}

extension DailyFocusCard {
    static let placeholder = DailyFocusCard(
        date: Calendar.current.startOfDay(for: .now.addingTimeInterval(86_400)),
        items: ListItem.placeholderItems,
        meta: .init(theme: "Focus on deep work", energyBudget: .medium, successMetric: "Ship API spec")
    )
}

public struct AntiTodoLog: Hashable, Codable {
    public struct Entry: Identifiable, Hashable, Codable {
        public let id: UUID
        public var title: String
        public var completedAt: Date

        public init(id: UUID = UUID(), title: String, completedAt: Date = .now) {
            self.id = id
            self.title = title
            self.completedAt = completedAt
        }
    }

    public var date: Date
    public var entries: [Entry]

    public init(date: Date, entries: [Entry]) {
        self.date = date
        self.entries = entries
    }
}

extension AntiTodoLog {
    static let placeholder = AntiTodoLog(
        date: .now,
        entries: [
            .init(title: "Debugged sync token bug"),
            .init(title: "Reviewed focus card heuristic"),
            .init(title: "Documented structured procrastination ideas")
        ]
    )
}
