import Foundation

/// Handles offline persistence for the three-list system and daily focus cards.
public final class LocalStore {
    public static let shared = LocalStore()

    private let queue = DispatchQueue(label: "io.andre.localStore", qos: .userInitiated)
    private let calendar = Calendar.current

    private var board: ListBoard
    private var focusCard: DailyFocusCard
    private var antiTodo: AntiTodoLog

    private init() {
        board = .placeholder
        focusCard = .placeholder
        antiTodo = .placeholder
    }

    // MARK: - Completion-based helpers

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

// MARK: - Async/Await API

public extension LocalStore {
    /// Load the cached list board, if available.
    func loadListBoard() async -> ListBoard? {
        await withCheckedContinuation { continuation in
            queue.async {
                continuation.resume(returning: self.board)
            }
        }
    }

    /// Persist a new board snapshot.
    func cache(board: ListBoard) async {
        await withCheckedContinuation { continuation in
            queue.async {
                self.board = board
                continuation.resume()
            }
        }
    }

    /// Upsert a list item in the local cache.
    func saveListItem(_ item: ListItem) async {
        await withCheckedContinuation { continuation in
            queue.async {
                self.upsert(item: item)
                continuation.resume()
            }
        }
    }

    /// Remove a list item from the cache.
    func deleteListItem(_ id: UUID) async {
        await withCheckedContinuation { continuation in
            queue.async {
                self.removeItem(id: id)
                continuation.resume()
            }
        }
    }

    /// Load a focus card for a given date.
    func loadFocusCard(for date: Date) async -> DailyFocusCard? {
        await withCheckedContinuation { continuation in
            queue.async {
                let normalizedRequestDate = self.normalized(date)
                let normalizedStoredDate = self.normalized(self.focusCard.date)
                let card = normalizedRequestDate == normalizedStoredDate ? self.focusCard : nil
                continuation.resume(returning: card)
            }
        }
    }

    /// Save or replace the cached focus card.
    func saveFocusCard(_ card: DailyFocusCard) async {
        await withCheckedContinuation { continuation in
            queue.async {
                self.focusCard = card
                continuation.resume()
            }
        }
    }

    /// Load the Anti-Todo log for a given date.
    func loadAntiTodoLog(for date: Date) async -> AntiTodoLog {
        await withCheckedContinuation { continuation in
            queue.async {
                let normalizedRequestDate = self.normalized(date)
                let normalizedStoredDate = self.normalized(self.antiTodo.date)

                if normalizedRequestDate == normalizedStoredDate {
                    continuation.resume(returning: self.antiTodo)
                } else {
                    continuation.resume(
                        returning: AntiTodoLog(date: date, entries: [])
                    )
                }
            }
        }
    }

    /// Append an Anti-Todo entry for the provided date (defaults to today).
    func appendAntiTodoEntry(_ entry: AntiTodoLog.Entry, on date: Date = Date()) async {
        await withCheckedContinuation { continuation in
            queue.async {
                let normalizedRequestDate = self.normalized(date)
                let normalizedStoredDate = self.normalized(self.antiTodo.date)

                if normalizedRequestDate != normalizedStoredDate {
                    self.antiTodo = AntiTodoLog(date: date, entries: [])
                }

                self.antiTodo.entries.append(entry)
                continuation.resume()
            }
        }
    }

    /// Replace the cached Anti-Todo log with a new snapshot.
    func saveAntiTodoLog(_ log: AntiTodoLog) async {
        await withCheckedContinuation { continuation in
            queue.async {
                self.antiTodo = log
                continuation.resume()
            }
        }
    }
}

// MARK: - Private helpers

private extension LocalStore {
    func normalized(_ date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    func upsert(item: ListItem) {
        var columns = board.columns

        // Remove the item if it already exists in any column
        for index in columns.indices {
            columns[index].items.removeAll { $0.id == item.id }
        }

        if let targetIndex = columns.firstIndex(where: { $0.listType == item.listType }) {
            columns[targetIndex].items.append(item)
        } else {
            columns.append(
                ListBoard.Column(
                    listType: item.listType,
                    title: item.listType.displayName,
                    items: [item]
                )
            )
        }

        board = ListBoard(columns: columns)
    }

    func removeItem(id: UUID) {
        var columns = board.columns
        for index in columns.indices {
            columns[index].items.removeAll { $0.id == id }
        }
        board = ListBoard(columns: columns)
    }
}
