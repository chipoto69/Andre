import Foundation

/// Coordinates sync between the local store and the Andre backend.
public final class SyncService {
    public enum SyncError: Error {
        case httpStatus(Int)
        case invalidURL
        case invalidData
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
            baseURL: URL(string: "http://localhost:3333")!,
            authTokenProvider: { nil }
        )
    )

    private let session: URLSession
    private let config: Config
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let isoDateTimeFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
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
    }

    public func fetchListBoard() async throws -> ListBoard {
        let request = try makeRequest(path: "/v1/lists/sync", method: "GET")
        let data = try await data(for: request)
        let dto = try decoder.decode(BoardDTO.self, from: data)
        return dto.toDomain(using: isoDateTimeFormatter, dayFormatter: dayFormatter)
    }

    public func createListItem(_ item: ListItem) async throws {
        var request = try makeRequest(path: "/v1/lists", method: "POST")
        let payload = ListItemDTO(item: item, formatter: isoDateTimeFormatter)
        request.httpBody = try encoder.encode(payload)
        _ = try await data(for: request)
    }

    public func updateListItem(_ item: ListItem) async throws {
        var request = try makeRequest(path: "/v1/lists/\(item.id.uuidString)", method: "PUT")
        let payload = ListItemDTO(item: item, formatter: isoDateTimeFormatter)
        request.httpBody = try encoder.encode(payload)
        _ = try await data(for: request)
    }

    public func deleteListItem(_ id: UUID) async throws {
        let request = try makeRequest(path: "/v1/lists/\(id.uuidString)", method: "DELETE")
        _ = try await data(for: request)
    }

    public func fetchFocusCard(for date: Date) async throws -> DailyFocusCard {
        let dayString = dayFormatter.string(from: date)
        let request = try makeRequest(
            path: "/v1/focus-card",
            method: "GET",
            queryItems: [URLQueryItem(name: "date", value: dayString)]
        )
        let data = try await data(for: request)
        let dto = try decoder.decode(DailyFocusCardDTO.self, from: data)
        guard let card = dto.toDomain(using: isoDateTimeFormatter, dayFormatter: dayFormatter) else {
            throw SyncError.invalidData
        }
        return card
    }

    public func syncFocusCard(_ card: DailyFocusCard) async throws {
        var request = try makeRequest(path: "/v1/focus-card", method: "PUT")
        let payload = DailyFocusCardDTO(card: card, formatter: isoDateTimeFormatter, dayFormatter: dayFormatter)
        request.httpBody = try encoder.encode(payload)
        _ = try await data(for: request)
    }

    public func generateFocusCard() async throws -> DailyFocusCard {
        let request = try makeRequest(path: "/v1/focus-card/generate", method: "POST")
        let data = try await data(for: request)
        let dto = try decoder.decode(DailyFocusCardDTO.self, from: data)
        guard let card = dto.toDomain(using: isoDateTimeFormatter, dayFormatter: dayFormatter) else {
            throw SyncError.invalidData
        }
        return card
    }

    public func fetchAntiTodoLog(for date: Date) async throws -> AntiTodoLog {
        let isoDate = dayFormatter.string(from: date)
        let request = try makeRequest(
            path: "/v1/anti-todo",
            method: "GET",
            queryItems: [URLQueryItem(name: "date", value: isoDate)]
        )
        let data = try await data(for: request)
        let entries = try decoder.decode([AntiTodoEntryDTO].self, from: data)
            .map { $0.toDomain(using: isoDateTimeFormatter, dayFormatter: dayFormatter) }
        return AntiTodoLog(date: date, entries: entries)
    }

    @discardableResult
    public func logAntiTodo(_ entry: AntiTodoLog.Entry) async throws -> AntiTodoLog.Entry {
        var request = try makeRequest(path: "/v1/anti-todo", method: "POST")
        let payload = AntiTodoEntryDTO(entry: entry, formatter: isoDateTimeFormatter)
        request.httpBody = try encoder.encode(payload)
        let data = try await data(for: request)
        let dto = try decoder.decode(AntiTodoEntryDTO.self, from: data)
        return dto.toDomain(using: isoDateTimeFormatter, dayFormatter: dayFormatter)
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
