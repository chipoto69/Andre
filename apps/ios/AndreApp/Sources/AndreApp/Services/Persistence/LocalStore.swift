import Foundation

/// Handles offline persistence for the three-list system and daily focus cards.
public final class LocalStore {
    public static let shared = LocalStore()

    private let queue = DispatchQueue(label: "io.andre.localStore", qos: .userInitiated)
    private var board: ListBoard = .placeholder
    private var focusCard: DailyFocusCard = .placeholder
    private var antiTodo: AntiTodoLog = .placeholder

    private init() {}

    public func fetchBoard(completion: @escaping (ListBoard) -> Void) {
        queue.async {
            completion(self.board)
        }
    }

    public func saveBoard(_ board: ListBoard, completion: (() -> Void)? = nil) {
        queue.async {
            self.board = board
            completion?()
        }
    }

    public func fetchFocusCard(completion: @escaping (DailyFocusCard) -> Void) {
        queue.async {
            completion(self.focusCard)
        }
    }

    public func saveFocusCard(_ card: DailyFocusCard, completion: (() -> Void)? = nil) {
        queue.async {
            self.focusCard = card
            completion?()
        }
    }

    public func fetchAntiTodoLog(completion: @escaping (AntiTodoLog) -> Void) {
        queue.async {
            completion(self.antiTodo)
        }
    }

    public func appendAntiTodoEntry(_ entry: AntiTodoLog.Entry, completion: (() -> Void)? = nil) {
        queue.async {
            self.antiTodo.entries.append(entry)
            completion?()
        }
    }
}
