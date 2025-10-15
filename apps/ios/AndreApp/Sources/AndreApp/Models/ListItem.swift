import Foundation

public struct ListItem: Identifiable, Hashable, Codable {
    public enum ListType: String, Codable, CaseIterable {
        case todo
        case watch
        case later
        case antiTodo

        public var displayName: String {
            switch self {
            case .todo: return "Todo"
            case .watch: return "Watch"
            case .later: return "Later"
            case .antiTodo: return "Anti-Todo"
            }
        }
    }

    public enum Status: String, Codable {
        case planned
        case inProgress
        case completed
        case archived
    }

    public let id: UUID
    public var title: String
    public var listType: ListType
    public var status: Status
    public var notes: String?
    public var dueAt: Date?
    public var followUpAt: Date?
    public var createdAt: Date
    public var completedAt: Date?
    public var tags: [String]

    public init(
        id: UUID = UUID(),
        title: String,
        listType: ListType,
        status: Status = .planned,
        notes: String? = nil,
        dueAt: Date? = nil,
        followUpAt: Date? = nil,
        createdAt: Date = .now,
        completedAt: Date? = nil,
        tags: [String] = []
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
        self.tags = tags
    }
}

extension ListItem {
    static let placeholderItems: [ListItem] = [
        .init(title: "Ship API design draft", listType: .todo, dueAt: .now.addingTimeInterval(86_400)),
        .init(title: "Follow up with Sarah on partnership", listType: .watch, followUpAt: .now.addingTimeInterval(172_800)),
        .init(title: "Research calendar integration", listType: .later, notes: "Check GCAL API quotas")
    ]
}
