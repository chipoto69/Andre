import Foundation

/// Production-ready HTTP client with comprehensive error handling.
///
/// Provides a type-safe interface for making authenticated API requests
/// with automatic retry logic, timeout handling, and detailed error reporting.
private func resolveAPIBaseURL(defaultValue: String) -> URL {
    if let override = ProcessInfo.processInfo.environment["ANDRE_API_URL"],
       let url = URL(string: override) {
        return url
    }
    return URL(string: defaultValue)!
}

public final class APIClient {
    // MARK: - Configuration

    public struct Configuration {
        public let baseURL: URL
        public let timeout: TimeInterval
        public let maxRetries: Int
        public let retryDelay: TimeInterval

        public init(
            baseURL: URL,
            timeout: TimeInterval = 30.0,
            maxRetries: Int = 3,
            retryDelay: TimeInterval = 1.0
        ) {
            self.baseURL = baseURL
            self.timeout = timeout
            self.maxRetries = maxRetries
            self.retryDelay = retryDelay
        }

        public static let production = Configuration(
            baseURL: resolveAPIBaseURL(defaultValue: "https://api.andre.app")
        )

        public static let development = Configuration(
            baseURL: resolveAPIBaseURL(defaultValue: "http://localhost:3333"),
            timeout: 60.0
        )
    }

    // MARK: - Error Types

    public enum APIError: Error, LocalizedError {
        case invalidURL
        case invalidResponse
        case unauthorized
        case forbidden
        case notFound
        case serverError(statusCode: Int)
        case networkError(Error)
        case decodingError(Error)
        case encodingError(Error)
        case timeout
        case noInternetConnection
        case requestCancelled

        public var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid URL"
            case .invalidResponse:
                return "Invalid response from server"
            case .unauthorized:
                return "Unauthorized - please log in again"
            case .forbidden:
                return "Access forbidden"
            case .notFound:
                return "Resource not found"
            case .serverError(let code):
                return "Server error (code: \(code))"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            case .decodingError(let error):
                return "Failed to decode response: \(error.localizedDescription)"
            case .encodingError(let error):
                return "Failed to encode request: \(error.localizedDescription)"
            case .timeout:
                return "Request timed out"
            case .noInternetConnection:
                return "No internet connection"
            case .requestCancelled:
                return "Request was cancelled"
            }
        }

        public var isRetryable: Bool {
            switch self {
            case .timeout, .serverError, .networkError, .noInternetConnection:
                return true
            case .unauthorized, .forbidden, .notFound, .invalidURL, .invalidResponse,
                 .decodingError, .encodingError, .requestCancelled:
                return false
            }
        }
    }

    // MARK: - Properties

    private let configuration: Configuration
    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(configuration: Configuration = .production) {
        self.configuration = configuration

        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = configuration.timeout
        sessionConfig.timeoutIntervalForResource = configuration.timeout * 2
        sessionConfig.waitsForConnectivity = true

        self.session = URLSession(configuration: sessionConfig)

        self.encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        self.decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    // MARK: - Request Methods

    /// Perform a GET request
    public func get<T: Decodable>(
        _ path: String,
        parameters: [String: String]? = nil
    ) async throws -> T {
        try await request(method: "GET", path: path, parameters: parameters)
    }

    /// Perform a POST request
    public func post<T: Decodable, Body: Encodable>(
        _ path: String,
        body: Body
    ) async throws -> T {
        try await request(method: "POST", path: path, body: body)
    }

    /// Perform a PUT request
    public func put<T: Decodable, Body: Encodable>(
        _ path: String,
        body: Body
    ) async throws -> T {
        try await request(method: "PUT", path: path, body: body)
    }

    /// Perform a DELETE request
    public func delete<T: Decodable>(
        _ path: String
    ) async throws -> T {
        try await request(method: "DELETE", path: path)
    }

    /// Perform a request without expecting a response body
    public func perform(
        method: String,
        path: String,
        body: (any Encodable)? = nil
    ) async throws {
        let _: EmptyResponse = try await request(method: method, path: path, body: body)
    }

    // MARK: - Core Request Method

    private func request<T: Decodable>(
        method: String,
        path: String,
        parameters: [String: String]? = nil,
        body: (any Encodable)? = nil,
        retryCount: Int = 0
    ) async throws -> T {
        // Build URL
        guard var components = URLComponents(
            url: configuration.baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: true
        ) else {
            throw APIError.invalidURL
        }

        // Add query parameters
        if let parameters = parameters {
            components.queryItems = parameters.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
        }

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        // Build request
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // Encode body if present
        if let body = body {
            do {
                request.httpBody = try encoder.encode(AnyEncodable(body))
            } catch {
                throw APIError.encodingError(error)
            }
        }

        // Perform request
        do {
            let (data, response) = try await session.data(for: request)

            // Validate response
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            // Handle HTTP status codes
            switch httpResponse.statusCode {
            case 200...299:
                // Success - decode response
                do {
                    return try decoder.decode(T.self, from: data)
                } catch {
                    throw APIError.decodingError(error)
                }

            case 401:
                throw APIError.unauthorized

            case 403:
                throw APIError.forbidden

            case 404:
                throw APIError.notFound

            case 500...599:
                let error = APIError.serverError(statusCode: httpResponse.statusCode)

                // Retry server errors if retries remaining
                if retryCount < configuration.maxRetries {
                    try await Task.sleep(nanoseconds: UInt64(configuration.retryDelay * 1_000_000_000))
                    return try await self.request(
                        method: method,
                        path: path,
                        parameters: parameters,
                        body: body,
                        retryCount: retryCount + 1
                    )
                }

                throw error

            default:
                throw APIError.serverError(statusCode: httpResponse.statusCode)
            }

        } catch let error as URLError {
            // Handle URLError cases
            let apiError: APIError

            switch error.code {
            case .timedOut:
                apiError = .timeout
            case .notConnectedToInternet, .networkConnectionLost:
                apiError = .noInternetConnection
            case .cancelled:
                apiError = .requestCancelled
            default:
                apiError = .networkError(error)
            }

            // Retry if error is retryable and retries remaining
            if apiError.isRetryable && retryCount < configuration.maxRetries {
                try await Task.sleep(nanoseconds: UInt64(configuration.retryDelay * 1_000_000_000))
                return try await self.request(
                    method: method,
                    path: path,
                    parameters: parameters,
                    body: body,
                    retryCount: retryCount + 1
                )
            }

            throw apiError

        } catch let error as APIError {
            throw error

        } catch {
            throw APIError.networkError(error)
        }
    }
}

// MARK: - Helper Types

private struct EmptyResponse: Decodable {}

private struct AnyEncodable: Encodable {
    private let encodable: any Encodable

    init(_ encodable: any Encodable) {
        self.encodable = encodable
    }

    func encode(to encoder: Encoder) throws {
        try encodable.encode(to: encoder)
    }
}
