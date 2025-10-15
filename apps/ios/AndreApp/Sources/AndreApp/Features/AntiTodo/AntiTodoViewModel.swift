import Foundation
import Observation

/// View model responsible for loading and logging Anti-Todo entries.
@MainActor
@Observable
public final class AntiTodoViewModel {
    public private(set) var log: AntiTodoLog
    public private(set) var isLoading = false
    public private(set) var error: Error?

    private let localStore: LocalStore
    private let syncService: SyncService
    private let calendar = Calendar.current

    public init(
        localStore: LocalStore? = nil,
        syncService: SyncService? = nil
    ) {
        self.localStore = localStore ?? LocalStore.shared
        self.syncService = syncService ?? SyncService.shared
        self.log = AntiTodoLog(date: Date(), entries: [])
    }

    /// Load the Anti-Todo log for a given date (defaults to today).
    public func loadLog(for date: Date = Date()) async {
        isLoading = true
        error = nil

        let normalizedDate = calendar.startOfDay(for: date)
        log = await localStore.loadAntiTodoLog(for: normalizedDate)

        do {
            let remoteLog = try await syncService.fetchAntiTodoLog(for: normalizedDate)
            log = remoteLog
            await localStore.saveAntiTodoLog(remoteLog)
        } catch {
            self.error = error
            print("Failed to fetch Anti-Todo log: \(error)")
        }

        isLoading = false
    }

    /// Log a new Anti-Todo entry with the given title.
    public func logWin(_ title: String) async {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let newEntry = AntiTodoLog.Entry(title: title, completedAt: Date())
        log.entries.insert(newEntry, at: 0)

        await localStore.appendAntiTodoEntry(newEntry, on: log.date)

        do {
            _ = try await syncService.logAntiTodo(newEntry)
        } catch {
            self.error = error
            print("Failed to sync Anti-Todo entry: \(error)")
        }
    }
}
