import Foundation

/// Coordinates sync between the local store and the Andre backend.
public final class SyncService {
    public enum SyncError: Error {
        case httpStatus(Int)
        case invalidURL
    }

    public struct Config {
        public var baseURL: URL
        public var authTokenProvider: () -> String?

        public init(baseURL: URL, authTokenProvider: @escaping () -> String?) {
            self.baseURL = baseURL
            self.authTokenProvider = authTokenProvider
        }
    }

    public static let shared = SyncService(
        config: Config(
            baseURL: URL(string: "http://localhost:8080")!,
            authTokenProvider: { nil }
        )
    )

    private let session: URLSession
    private let config: Config
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    public init(
        config: Config,
        session: URLSession = .shared
    ) {
        self.config = config
        self.session = session
        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601
    }

    public func fetchListBoard() async throws -> ListBoard {
        let request = try makeRequest(path: "/v1/lists/sync", method: "GET")
        let data = try await data(for: request)
        return try decoder.decode(ListBoard.self, from: data)
    }

    public func pushBoard(_ board: ListBoard) async throws {
        var request = try makeRequest(path: "/v1/lists/sync", method: "PUT")
        request.httpBody = try encoder.encode(board)
        _ = try await data(for: request)
    }

    public func createListItem(_ item: ListItem) async throws {
        var request = try makeRequest(path: "/v1/lists", method: "POST")
        request.httpBody = try encoder.encode(item)
        _ = try await data(for: request)
    }

    public func updateListItem(_ item: ListItem) async throws {
        var request = try makeRequest(path: "/v1/lists/\(item.id.uuidString)", method: "PUT")
        request.httpBody = try encoder.encode(item)
        _ = try await data(for: request)
    }

    public func deleteListItem(_ id: UUID) async throws {
        let request = try makeRequest(path: "/v1/lists/\(id.uuidString)", method: "DELETE")
        _ = try await data(for: request)
    }

    public func fetchFocusCard(for date: Date) async throws -> DailyFocusCard {
        let isoDate = ISO8601DateFormatter().string(from: date)
        let request = try makeRequest(
            path: "/v1/focus-card",
            method: "GET",
            queryItems: [URLQueryItem(name: "date", value: isoDate)]
        )
        let data = try await data(for: request)
        return try decoder.decode(DailyFocusCard.self, from: data)
    }

    public func syncFocusCard(_ card: DailyFocusCard) async throws {
        var request = try makeRequest(path: "/v1/focus-card", method: "PUT")
        request.httpBody = try encoder.encode(card)
        _ = try await data(for: request)
    }

    public func generateFocusCard() async throws -> DailyFocusCard {
        let request = try makeRequest(path: "/v1/focus-card/generate", method: "POST")
        let data = try await data(for: request)
        return try decoder.decode(DailyFocusCard.self, from: data)
    }

    public func fetchAntiTodoLog(for date: Date) async throws -> AntiTodoLog {
        let isoDate = dayFormatter.string(from: date)
        let request = try makeRequest(
            path: "/v1/anti-todo",
            method: "GET",
            queryItems: [URLQueryItem(name: "date", value: isoDate)]
        )
        let data = try await data(for: request)
        let entries = try decoder.decode([AntiTodoLog.Entry].self, from: data)
        return AntiTodoLog(date: date, entries: entries)
    }

    @discardableResult
    public func logAntiTodo(_ entry: AntiTodoLog.Entry) async throws -> AntiTodoLog.Entry {
        var request = try makeRequest(path: "/v1/anti-todo", method: "POST")
        request.httpBody = try encoder.encode(entry)
        let data = try await data(for: request)
        return try decoder.decode(AntiTodoLog.Entry.self, from: data)
    }

    private func makeRequest(
        path: String,
        method: String,
        queryItems: [URLQueryItem] = []
    ) throws -> URLRequest {
        var url = config.baseURL.appending(path: path)
        if !queryItems.isEmpty {
            guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                throw SyncError.invalidURL
            }
            components.queryItems = queryItems
            guard let composed = components.url else {
                throw SyncError.invalidURL
            }
            url = composed
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = config.authTokenProvider() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    private func data(for request: URLRequest) async throws -> Data {
        let (data, response) = try await session.data(for: request)
        if let httpResponse = response as? HTTPURLResponse,
           !(200..<300).contains(httpResponse.statusCode) {
            throw SyncError.httpStatus(httpResponse.statusCode)
        }
        return data
    }
}
