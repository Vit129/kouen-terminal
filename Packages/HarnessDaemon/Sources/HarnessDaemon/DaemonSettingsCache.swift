import Foundation
import HarnessCore

/// A daemon reads and decodes each settings revision once; consumers retain their
/// last working policy if an external edit is invalid.
final class DaemonSettingsCache: @unchecked Sendable {
    private static let sharedLock = NSLock()
    nonisolated(unsafe) private static var current: DaemonSettingsCache?
    static var shared: DaemonSettingsCache {
        sharedLock.lock(); defer { sharedLock.unlock() }
        let url = HarnessPaths.settingsURL
        if let current, current.url == url { return current }
        let cache = DaemonSettingsCache(url: url); current = cache; return cache
    }
    private let url: URL
    private let queue = DispatchQueue(label: "com.harness.daemon.settings", qos: .utility)
    private let lock = NSLock()
    private var bytes: Data?
    private var latest: Result<HarnessSettings, Error>?
    private var observers: [UUID: @Sendable () -> Void] = [:]
    private var watcher: FileWatcher?
    init(url: URL) {
        self.url = url
        reload()
        watcher = FileWatcher(url: url, callbackQueue: queue) { [weak self] in self?.reload() }
        queue.async { [weak self] in self?.reload() }
    }
    var latestResult: Result<HarnessSettings, Error>? { lock.lock(); defer { lock.unlock() }; return latest }
    func refresh() { queue.sync { reload() } }
    func observe(_ callback: @escaping @Sendable () -> Void) -> UUID {
        let token = UUID()
        lock.lock(); observers[token] = callback
        if latest != nil { queue.async { callback() } }
        lock.unlock()
        return token
    }
    func removeObserver(_ token: UUID) { lock.lock(); observers.removeValue(forKey: token); lock.unlock() }
    private func reload() {
        let result: Result<HarnessSettings, Error>
        do {
            guard let next = try PrivateFile.read(url) else { return }
            lock.lock()
            let unchanged: Bool
            if case .success? = latest { unchanged = next == bytes } else { unchanged = false }
            lock.unlock()
            guard !unchanged else { return }
            result = .success(try HarnessSettings.reload(data: next))
            lock.lock(); bytes = next; lock.unlock()
        } catch { result = .failure(error) }
        lock.lock(); latest = result; let callbacks = Array(observers.values)
        queue.async { for callback in callbacks { callback() } }
        lock.unlock()
    }
}
