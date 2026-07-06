import Foundation

/// Opt-in daemon instrumentation for diagnosing lock pressure on the hot output
/// path. **Off by default** — production users see no behavior change. Enable by
/// launching the daemon with `KOUEN_DAEMON_METRICS=1`; the snapshot is then
/// surfaced through the existing `SIGUSR1` stats log (no IPC / wire change).
///
/// Captured metrics:
/// - registry-lock acquisition wait (total / max / count) at instrumented sites,
/// - number of per-subscriber output notifications delivered,
/// - high-water mark of a client's pending socket write backlog.
///
/// When disabled, every `record*/observe*` call is a single predictable branch
/// that returns immediately, so it is safe to leave the call sites in place on
/// the hot path. When enabled, a small private lock guards the counters; this is
/// a debug-only path, so the minor measurement perturbation is acceptable.
public final class DaemonMetrics: @unchecked Sendable {
    /// Whether metrics are being recorded. Read this before doing any work on a
    /// hot path so the disabled case stays a single branch.
    public let enabled: Bool

    private let lock = NSLock()
    private var lockWaitTotalNanos: UInt64 = 0
    private var lockWaitMaxNanos: UInt64 = 0
    private var lockWaitCount: UInt64 = 0
    private var outputNotifications: UInt64 = 0
    private var maxBacklogBytes: Int = 0

    /// Default initializer reads the `KOUEN_DAEMON_METRICS` environment variable
    /// once. Tests pass `enabled:` explicitly for deterministic behavior.
    public init(enabled: Bool? = nil) {
        if let enabled {
            self.enabled = enabled
        } else {
            self.enabled = ProcessInfo.processInfo.environment["KOUEN_DAEMON_METRICS"] == "1"
        }
    }

    /// Record how long a registry-lock acquisition blocked. No-op when disabled.
    public func recordLockWait(nanos: UInt64) {
        guard enabled else { return }
        lock.lock()
        // Wrapping adds: these are monotonic counters; UInt64 nanos/counts can't realistically
        // overflow within a daemon's lifetime, and wrap-on-overflow is preferable to a trap.
        lockWaitTotalNanos &+= nanos
        if nanos > lockWaitMaxNanos { lockWaitMaxNanos = nanos }
        lockWaitCount &+= 1
        lock.unlock()
    }

    /// Count one delivered output notification (one chunk → one subscriber). No-op when disabled.
    public func recordOutputNotification() {
        guard enabled else { return }
        lock.lock()
        outputNotifications &+= 1
        lock.unlock()
    }

    /// Update the high-water mark of a client's pending write backlog. No-op when disabled.
    public func observeBacklog(bytes: Int) {
        guard enabled else { return }
        lock.lock()
        if bytes > maxBacklogBytes { maxBacklogBytes = bytes }
        lock.unlock()
    }

    /// A consistent point-in-time copy of the counters.
    public struct Snapshot: Equatable, Sendable {
        public var lockWaitTotalNanos: UInt64
        public var lockWaitMaxNanos: UInt64
        public var lockWaitCount: UInt64
        public var outputNotifications: UInt64
        public var maxBacklogBytes: Int

        /// Mean registry-lock wait in microseconds, or 0 when nothing was sampled.
        public var meanLockWaitMicros: Double {
            lockWaitCount == 0 ? 0 : Double(lockWaitTotalNanos) / Double(lockWaitCount) / 1000
        }
    }

    public func snapshot() -> Snapshot {
        lock.lock()
        defer { lock.unlock() }
        return Snapshot(
            lockWaitTotalNanos: lockWaitTotalNanos,
            lockWaitMaxNanos: lockWaitMaxNanos,
            lockWaitCount: lockWaitCount,
            outputNotifications: outputNotifications,
            maxBacklogBytes: maxBacklogBytes
        )
    }

    /// One-line, human-readable summary for the `SIGUSR1` stats log.
    public func summary() -> String {
        guard enabled else { return "metrics: disabled (set KOUEN_DAEMON_METRICS=1)" }
        let s = snapshot()
        return String(
            format: "metrics: lockWaits=%llu meanLockWait=%.1fµs maxLockWait=%.1fµs outputs=%llu maxBacklog=%dB",
            s.lockWaitCount, s.meanLockWaitMicros, Double(s.lockWaitMaxNanos) / 1000,
            s.outputNotifications, s.maxBacklogBytes
        )
    }
}
