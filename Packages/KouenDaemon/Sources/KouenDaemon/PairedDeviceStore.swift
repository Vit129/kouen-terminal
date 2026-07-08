#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif
import Foundation
import KouenCore

/// P25 F3: persistent (disk-backed, survives a daemon restart) record of devices paired
/// to the mobile WS bridge. Owned by `DaemonServer` so `kouen-cli mobile-list-clients`/
/// `mobile-revoke-client` (ordinary IPC requests) can read/mutate it; `MobileBridgeServer`
/// registers new devices on successful pairing and sets `onRevoke` so a revoke can cancel
/// the live connection. Kept in KouenDaemonCore proper (not gated behind
/// `canImport(Network)`) so the IPC surface compiles identically on every platform — on
/// Linux (bridge never starts) it just always reports zero devices.
///
/// Storage mirrors `RemoteHostStore`'s pattern (small, read-rarely JSON list, atomic write,
/// `flock` sidecar) — this process is the only writer today (mutations arrive over IPC,
/// funneled through this one daemon), so the file lock is defense-in-depth rather than a
/// load-bearing requirement, same reasoning `RemoteHostStore` documents for its own case.
public final class PairedDeviceStore: @unchecked Sendable {
    private let lock = NSLock()
    private var devices: [String: PairedDeviceSummary] = [:]

    /// Set by `MobileBridgeServer` after `start()`; called with a device id when
    /// `revoke(id:)` finds and removes a matching entry, so the live WS connection
    /// (if still attached) gets cancelled too — not just dropped from the table.
    public var onRevoke: (@Sendable (String) -> Void)?

    public init() {
        let loaded = Self.loadFromDisk()
        lock.lock()
        devices = Dictionary(uniqueKeysWithValues: loaded.map { ($0.id, $0) })
        lock.unlock()
    }

    public func register(id: String, label: String) {
        lock.lock()
        defer { lock.unlock() }
        withFileLock {
            devices[id] = PairedDeviceSummary(id: id, label: label, pairedAt: Date())
            saveLocked()
        }
    }

    public func list() -> [PairedDeviceSummary] {
        lock.lock()
        defer { lock.unlock() }
        return devices.values.sorted { $0.pairedAt < $1.pairedAt }
    }

    @discardableResult
    public func revoke(id: String) -> Bool {
        lock.lock()
        var existed = false
        withFileLock {
            existed = devices.removeValue(forKey: id) != nil
            if existed { saveLocked() }
        }
        lock.unlock()
        if existed { onRevoke?(id) }
        return existed
    }

    // MARK: - Inter-process locking (caller must already hold `lock`)

    /// Degrades to running `body` unlocked if the lock file can't be opened/locked — same
    /// tradeoff `RemoteHostStore.withFileLock` documents: a missing cross-process lock is
    /// strictly less safe than skipping persistence entirely, never worse.
    private func withFileLock(_ body: () -> Void) {
        try? KouenPaths.ensureDirectories()
        let lockPath = KouenPaths.pairedDevicesLockURL.path
        let fd = open(lockPath, O_RDWR | O_CREAT | O_CLOEXEC, 0o600)
        guard fd >= 0 else { body(); return }
        defer { close(fd) }
        guard flock(fd, LOCK_EX) == 0 else { body(); return }
        defer { flock(fd, LOCK_UN) }
        body()
    }

    // MARK: - Disk I/O

    private static func loadFromDisk() -> [PairedDeviceSummary] {
        let url = KouenPaths.pairedDevicesURL
        guard FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url)
        else { return [] }
        if let decoded = try? JSONDecoder().decode([PairedDeviceSummary].self, from: data) {
            return decoded
        }
        KouenPaths.backupCorruptFile(at: url, label: "PairedDeviceStore")
        return []
    }

    /// Caller must already hold `lock`.
    @discardableResult
    private func saveLocked() -> Bool {
        try? KouenPaths.ensureDirectories()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(Array(devices.values)) else { return false }
        return KouenPaths.atomicWrite(data, to: KouenPaths.pairedDevicesURL, label: "PairedDeviceStore")
    }
}
