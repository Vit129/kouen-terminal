import Foundation

public final class AgentTableCache: @unchecked Sendable {
    private static let sharedLock = NSLock()
    nonisolated(unsafe) private static var current: AgentTableCache?
    public static var shared: AgentTableCache {
        sharedLock.lock(); defer { sharedLock.unlock() }
        let url = HarnessPaths.applicationSupport.appendingPathComponent("agents.json")
        if let current, current.url == url { return current }
        let cache = AgentTableCache(url: url); current = cache; return cache
    }
    private let url: URL
    private let queue = DispatchQueue(label: "com.harness.agent-table", qos: .utility)
    private let lock = NSLock()
    private var table: AgentTable = .default
    private var watcher: FileWatcher?

    public init(url: URL) {
        self.url = url
        reload()
        watcher = FileWatcher(url: url, callbackQueue: queue) { [weak self] in self?.reload() }
        queue.async { [weak self] in self?.reload() }
    }
    public var value: AgentTable { lock.lock(); defer { lock.unlock() }; return table }
    private func reload() {
        do {
            let next = try PrivateFile.read(url).map { try JSONDecoder().decode(AgentTable.self, from: $0) } ?? .default
            lock.lock(); table = next; lock.unlock()
        } catch {
            fputs("Harness: agents.json could not be reloaded; retaining the last valid agent definitions: \(error)\n", harnessStderr)
        }
    }
}
