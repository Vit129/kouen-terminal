import Foundation

/// Async-native actor wrapping DaemonClient to ensure thread-safe, non-blocking IPC requests.
public actor DaemonClientActor {
    private var client: DaemonClient

    public init(endpoint: Endpoint = .localControlSocket) {
        self.client = DaemonClient(endpoint: endpoint)
    }

    public func switchEndpoint(_ endpoint: Endpoint) {
        self.client = DaemonClient(endpoint: endpoint)
    }

    /// Run IPC request off the caller's thread (detached Task) to prevent blocking @MainActor.
    public func request(_ ipcRequest: IPCRequest, timeout: TimeInterval = 2) async throws -> IPCResponse {
        let currentClient = client
        return try await Task.detached(priority: .userInitiated) {
            try currentClient.request(ipcRequest, timeout: timeout)
        }.value
    }
}
