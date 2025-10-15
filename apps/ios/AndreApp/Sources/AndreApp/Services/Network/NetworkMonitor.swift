import Foundation
import Network
import Observation

/// Monitors network connectivity status and notifies observers of changes.
///
/// Uses NWPathMonitor to track real-time network availability and connection type.
/// Provides reactive updates via @Observable for SwiftUI integration.
@MainActor
@Observable
public final class NetworkMonitor {
    // MARK: - Connection Status

    public enum ConnectionStatus {
        case connected(type: ConnectionType)
        case disconnected
        case unknown

        public var isConnected: Bool {
            if case .connected = self {
                return true
            }
            return false
        }
    }

    public enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case other
    }

    // MARK: - Properties

    /// Current connection status
    public private(set) var status: ConnectionStatus = .unknown

    /// Whether currently connected to internet
    public var isConnected: Bool {
        status.isConnected
    }

    /// Whether connection is expensive (e.g., cellular)
    public private(set) var isExpensive: Bool = false

    /// Whether connection is constrained (e.g., low data mode)
    public private(set) var isConstrained: Bool = false

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "io.andre.networkMonitor", qos: .utility)

    // MARK: - Singleton

    public static let shared = NetworkMonitor()

    private init() {
        startMonitoring()
    }

    deinit {
        monitor.cancel()
    }

    // MARK: - Monitoring

    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor [weak self] in
                self?.updateStatus(from: path)
            }
        }

        monitor.start(queue: queue)
    }

    private func updateStatus(from path: NWPath) {
        // Determine connection status
        if path.status == .satisfied {
            let type = connectionType(from: path)
            status = .connected(type: type)
        } else {
            status = .disconnected
        }

        // Update connection characteristics
        isExpensive = path.isExpensive
        isConstrained = path.isConstrained
    }

    private func connectionType(from path: NWPath) -> ConnectionType {
        if path.usesInterfaceType(.wifi) {
            return .wifi
        } else if path.usesInterfaceType(.cellular) {
            return .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            return .ethernet
        } else {
            return .other
        }
    }

    // MARK: - Connection Quality

    /// Whether connection is suitable for large uploads/downloads
    public var isSuitableForLargeTransfers: Bool {
        isConnected && !isExpensive && !isConstrained
    }

    /// Whether connection is suitable for background sync
    public var isSuitableForBackgroundSync: Bool {
        isConnected
    }
}
