import Foundation

/// Represents a structured procrastination suggestion from the backend.
///
/// Suggestions guide users toward productive work when their focus wanes,
/// drawn from Watch and Later lists or based on momentum patterns.
public struct Suggestion: Hashable, Identifiable, Codable {
    public let id: String
    public let title: String
    public let description: String
    public let listType: ListItem.ListType
    public let score: Double  // 0.0 to 1.0
    public let source: Source

    public enum Source: String, Codable {
        case later
        case watch
        case momentum
    }

    public init(
        id: String = UUID().uuidString,
        title: String,
        description: String,
        listType: ListItem.ListType,
        score: Double,
        source: Source
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.listType = listType
        self.score = score
        self.source = source
    }
}

// MARK: - Placeholder

extension Suggestion {
    public static let placeholder = Suggestion(
        id: "1",
        title: "Review design feedback",
        description: "Quick task while taking a break from deep work",
        listType: .watch,
        score: 0.85,
        source: .watch
    )

    public static let placeholderList: [Suggestion] = [
        Suggestion(
            id: "1",
            title: "Review design feedback",
            description: "Quick task while taking a break from deep work",
            listType: .watch,
            score: 0.85,
            source: .watch
        ),
        Suggestion(
            id: "2",
            title: "Update project documentation",
            description: "Productive distraction when you need a context switch",
            listType: .later,
            score: 0.75,
            source: .later
        ),
        Suggestion(
            id: "3",
            title: "Check team standup notes",
            description: "Stay in the loop without breaking flow",
            listType: .watch,
            score: 0.70,
            source: .momentum
        )
    ]
}
