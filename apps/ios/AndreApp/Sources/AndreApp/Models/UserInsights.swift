import Foundation

/// User insights derived from completion patterns and list health
public struct UserInsights: Equatable, Sendable {
    public struct CompletionPatterns: Equatable, Sendable {
        public let bestDayOfWeek: String?
        public let bestTimeOfDay: String?
        public let averageCompletionRate: Double
        public let streak: Int

        public init(
            bestDayOfWeek: String?,
            bestTimeOfDay: String?,
            averageCompletionRate: Double,
            streak: Int
        ) {
            self.bestDayOfWeek = bestDayOfWeek
            self.bestTimeOfDay = bestTimeOfDay
            self.averageCompletionRate = averageCompletionRate
            self.streak = streak
        }
    }

    public struct ListHealthMetrics: Equatable, Sendable {
        public let count: Int
        public let staleItems: Int?
        public let avgDwellTime: Double?

        public init(count: Int, staleItems: Int? = nil, avgDwellTime: Double? = nil) {
            self.count = count
            self.staleItems = staleItems
            self.avgDwellTime = avgDwellTime
        }
    }

    public struct ListHealth: Equatable, Sendable {
        public let todo: ListHealthMetrics
        public let watch: ListHealthMetrics
        public let later: ListHealthMetrics

        public init(
            todo: ListHealthMetrics,
            watch: ListHealthMetrics,
            later: ListHealthMetrics
        ) {
            self.todo = todo
            self.watch = watch
            self.later = later
        }
    }

    public struct Suggestion: Equatable, Sendable, Identifiable {
        public enum SuggestionType: String, Sendable {
            case insight
            case warning
            case tip
        }

        public let id: UUID
        public let type: SuggestionType
        public let message: String
        public let actionable: Bool

        public init(
            id: UUID = UUID(),
            type: SuggestionType,
            message: String,
            actionable: Bool
        ) {
            self.id = id
            self.type = type
            self.message = message
            self.actionable = actionable
        }
    }

    public let completionPatterns: CompletionPatterns
    public let listHealth: ListHealth
    public let suggestions: [Suggestion]

    public init(
        completionPatterns: CompletionPatterns,
        listHealth: ListHealth,
        suggestions: [Suggestion]
    ) {
        self.completionPatterns = completionPatterns
        self.listHealth = listHealth
        self.suggestions = suggestions
    }
}
