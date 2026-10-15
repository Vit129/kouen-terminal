#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif
import Foundation

/// Early warning for file-descriptor leaks. On 2026-10-15 a pipe leak (`runProcess` inside the
/// never-ending pairing loop) filled the fd table after ~8h; the daemon then could not save
/// layout/scrollback or spawn panes, and the app looped on "Reconnecting". Nothing logged it
/// until EMFILE. This logs when open fds cross half, then 80%, of the soft limit, so the next
/// leak shows up in `daemon.log` hours before it breaks anything.
public final class FDWatchdog: @unchecked Sendable {
    /// 0 = fine, 1 = at least half the limit, 2 = at least 80%.
    public static func level(open: Int, limit: Int) -> Int {
        guard limit > 0 else { return 0 }
        if open * 5 >= limit * 4 { return 2 }
        if open * 2 >= limit { return 1 }
        return 0
    }

    private let lock = NSLock()
    private var lastLevel = 0

    public init() {}

    /// The line to log when the level rises (once per crossing), nil otherwise. Falling back
    /// re-arms it, so a leak that is fixed and then returns is reported again.
    public func observe(open: Int, limit: Int) -> String? {
        let now = Self.level(open: open, limit: limit)
        lock.lock(); defer { lock.unlock() }
        defer { lastLevel = now }
        guard now > lastLevel else { return nil }
        return "fd watchdog: \(open) of \(limit) file descriptors open (\(now == 2 ? "80%" : "50%")) — likely a leak; check `lsof -p \(getpid())`"
    }

    private var timer: DispatchSourceTimer?

    /// Samples every `interval` seconds for the daemon's lifetime.
    public func start(interval: TimeInterval = 60, log: @escaping @Sendable (String) -> Void) {
        let t = DispatchSource.makeTimerSource(queue: .global(qos: .utility))
        t.schedule(deadline: .now() + interval, repeating: interval)
        t.setEventHandler { [weak self] in
            guard let self,
                  let open = try? FileManager.default.contentsOfDirectory(atPath: "/dev/fd").count
            else { return }
            if let line = self.observe(open: open, limit: Int(sysconf(Int32(_SC_OPEN_MAX)))) { log(line) }
        }
        t.resume()
        timer = t
    }
}
