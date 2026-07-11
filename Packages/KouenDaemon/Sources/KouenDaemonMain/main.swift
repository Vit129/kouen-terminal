#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif
import Foundation
import KouenCore
import KouenDaemonCore

// MARK: - Logging

/// Serializes the size-check→rotate→append sequence below. `daemonLog` is called from
/// four signal `DispatchSource`s on the `.global()` *concurrent* queue, so without this
/// gate parallel handlers could double-rotate or clobber each other's non-`O_APPEND`
/// writes. No reentrancy: `daemonLog` never calls itself, so `.sync` can't deadlock.
private let daemonLogQueue = DispatchQueue(label: "com.vit129.kouen.daemonLog")

/// Append a line to `~/Library/Application Support/Kouen/logs/daemon.log` and
/// (best-effort) duplicate to stderr so `launchctl print` shows recent output.
/// The log file is bounded — rotated to `daemon.log.1` when it crosses 4 MiB.
@Sendable
func daemonLog(_ message: String) {
    let line = "[\(ISO8601DateFormatter().string(from: Date())) pid=\(getpid())] \(message)\n"
    fputs(line, kouenStderr)
    daemonLogQueue.sync {
        let url = KouenPaths.daemonLogURL
        try? KouenPaths.ensureDirectories()
        let attrs = try? FileManager.default.attributesOfItem(atPath: url.path)
        let size = (attrs?[.size] as? NSNumber)?.intValue ?? 0
        if size > 4 * 1024 * 1024 {
            let rotated = url.deletingLastPathComponent().appendingPathComponent("daemon.log.1")
            try? FileManager.default.removeItem(at: rotated)
            try? FileManager.default.moveItem(at: url, to: rotated)
        }
        if let data = line.data(using: .utf8) {
            if let handle = try? FileHandle(forWritingTo: url) {
                _ = try? handle.seekToEnd()
                try? handle.write(contentsOf: data)
                try? handle.close()
            } else {
                try? data.write(to: url)
            }
        }
    }
}

// MARK: - PID file

private func writePIDFile() {
    try? KouenPaths.ensureDirectories()
    let pidString = "\(getpid())\n"
    try? pidString.write(to: KouenPaths.daemonPIDURL, atomically: true, encoding: .utf8)
}

/// Unconditional removal — used when reclaiming a *stale/foreign* PID file
/// (`detectStaleInstance`), where the file by design isn't ours to own-check.
private func removeForeignPIDFile() {
    try? FileManager.default.removeItem(at: KouenPaths.daemonPIDURL)
}

/// Owner-checked removal — only deletes the file if it still records *our* PID.
/// Guards the bind-race where a losing daemon's `catch`/`atexit` cleanup must not
/// delete the winner's freshly written PID file.
private func removePIDFile() {
    DaemonLifecycle.removeOwnedPIDFile(at: KouenPaths.daemonPIDURL, ownPID: getpid())
}

// MARK: - Signal handling

/// Install handlers for orderly shutdown (SIGTERM, SIGINT), config reload (SIGHUP),
/// and runtime stats dump (SIGUSR1). DispatchSource is used because POSIX
/// `signal(2)` handlers may only call async-signal-safe functions and we want to
/// touch Swift state (the server, the log) on shutdown.
private func installSignalHandlers(server: DaemonServer, shutdown: @escaping @Sendable () -> Void) {
    func install(_ signo: Int32, _ handler: @escaping @Sendable () -> Void) {
        signal(signo, SIG_IGN)
        let source = DispatchSource.makeSignalSource(signal: signo, queue: .global())
        source.setEventHandler(handler: handler)
        source.resume()
        // Retain the source so it stays alive for the process lifetime.
        signalSources.append(source)
    }
    install(SIGTERM) {
        daemonLog("received SIGTERM — graceful shutdown")
        shutdown()
    }
    install(SIGINT) {
        daemonLog("received SIGINT — graceful shutdown")
        shutdown()
    }
    install(SIGHUP) {
        daemonLog("received SIGHUP — reloading agent table")
        // Agent table is loaded on each scan tick; no further action needed today.
        // settings.json / keybindings.json reload land in later phases.
    }
    install(SIGUSR1) {
        let telemetry = server.registry.surfaceTelemetry
        daemonLog("stats: surfaces=\(telemetry.surfaceCount) scrollback=\(telemetry.scrollbackBytes)B")
        daemonLog(server.registry.metrics.summary())
    }
}

/// DispatchSource holders must outlive their registration; the array keeps them alive.
nonisolated(unsafe) private var signalSources: [DispatchSourceSignal] = []

/// Retained for the daemon's lifetime — see the assignment site for why a bare
/// temporary would silently break every closure inside it.
#if canImport(Network)
nonisolated(unsafe) private var mobileBridgeServer: MobileBridgeServer?
#endif

// MARK: - Stale instance handling

/// If a previous daemon left a PID file behind and that PID is no longer a live
/// KouenDaemon, remove it before we start. If a live daemon owns the PID, exit with
/// a clear message — two daemons sharing a socket would corrupt the snapshot store.
///
/// The identity check matters: after `kill -9` the PID file survives, and macOS can
/// recycle the freed PID to an unrelated process. A bare `kill(pid, 0)` liveness probe
/// then false-positives, making the fresh daemon `exit(1)` with nothing listening and
/// the `KeepAlive` supervisor thrashing. We only refuse when the live PID is actually a
/// KouenDaemon binary; `DaemonServer.start()`'s socket ping is the authoritative guard.
private func detectStaleInstance() {
    guard FileManager.default.fileExists(atPath: KouenPaths.daemonPIDURL.path) else { return }
    guard let raw = try? String(contentsOf: KouenPaths.daemonPIDURL, encoding: .utf8),
          let priorPID = pid_t(raw.trimmingCharacters(in: .whitespacesAndNewlines))
    else {
        removeForeignPIDFile()
        return
    }
    switch DaemonLifecycle.priorInstanceDecision(
        priorPID: priorPID,
        ownPID: getpid(),
        isAlive: DaemonLifecycle.processIsAlive,
        executablePath: DaemonLifecycle.executablePath
    ) {
    case .proceed:
        return
    case .refuse:
        daemonLog("another KouenDaemon (pid \(priorPID)) is already running — refusing to start")
        exit(1)
    case .stale:
        daemonLog("removing stale PID file from pid \(priorPID)")
        removeForeignPIDFile()
    }
}

// MARK: - Bootstrap

detectStaleInstance()
writePIDFile()
daemonLog("KouenDaemon starting (KOUEN_HOME=\(KouenPaths.applicationSupport.path))")

// Ignore SIGPIPE process-wide: a PTY master or socket write that races a closing peer would
// otherwise kill the daemon. macOS additionally sets SO_NOSIGPIPE per socket fd; this covers the
// PTY masters (which can't use that option) and is the only protection on Linux.
ignoreSIGPIPE()

let server = DaemonServer(enableVersionBanner: true)
nonisolated(unsafe) var hasShutDown = false
let shutdownLock = NSLock()

let shutdown: @Sendable () -> Void = {
    shutdownLock.lock()
    let already = hasShutDown
    hasShutDown = true
    shutdownLock.unlock()
    guard !already else { return }
    server.stop()
    removePIDFile()
    daemonLog("KouenDaemon stopped")
    exit(0)
}

installSignalHandlers(server: server, shutdown: shutdown)
atexit { removePIDFile() }

do {
    try server.start()
    AgentScanner.shared.start(registry: server.registry)
    AutomationScheduler.shared.start(registry: server.registry)
    daemonLog("KouenDaemon ready (socket=\(KouenPaths.socketURL.path))")

    // P25 W1 slice 1: opt-in mobile WS bridge. Unavailable on the Linux headless build
    // (Network.framework is Apple-only). The instance is always created so the Settings
    // toggle (`.setMobileBridgeEnabled`) can start/stop it in the running daemon — no restart
    // needed any more, which used to drop whatever pane/agent hosted the toggle click.
    #if canImport(Network)
    let bridgeWSPort = ProcessInfo.processInfo.environment["KOUEN_MOBILE_BRIDGE_PORT"]
        .flatMap(UInt16.init) ?? 7777
    let bridgePageURLPort = ProcessInfo.processInfo.environment["KOUEN_MOBILE_BRIDGE_PAGE_PORT"]
        .flatMap(Int.init) ?? 8080
    // Must outlive this scope — a bare `MobileBridgeServer().start(...)` temporary gets
    // deallocated the instant `start()` returns, silently turning every `[weak self]` closure
    // inside it (listener callbacks, the pairing loop) into a no-op.
    let bridge = MobileBridgeServer()
    mobileBridgeServer = bridge
    // P37 B1: let the IPC layer read the live pairing URL/countdown from the bridge, the
    // same shared-reference pattern as `server.pairedDevices` above (main.swift holds both).
    server.mobilePairingInfoProvider = { mobileBridgeServer?.currentPairingInfo() ?? (url: nil, secondsRemaining: 0, enabled: false) }
    server.mobileBridgeSetEnabledHandler = { enabled in
        if enabled {
            bridge.start(wsPort: bridgeWSPort, pageURLPort: bridgePageURLPort, store: server.pairedDevices, log: daemonLog)
        } else {
            bridge.stop()
        }
    }
    // Still opt-in at boot: only auto-start if the setting was already on when the daemon
    // launched (env var set by the LaunchAgent plist install). A live toggle afterward goes
    // through `mobileBridgeSetEnabledHandler` above instead.
    if ProcessInfo.processInfo.environment["KOUEN_MOBILE_BRIDGE_PORT"] != nil {
        bridge.start(wsPort: bridgeWSPort, pageURLPort: bridgePageURLPort, store: server.pairedDevices, log: daemonLog)
    }
    #endif

    server.runLoop()
} catch {
    daemonLog("KouenDaemon failed: \(error)")
    removePIDFile()
    exit(1)
}
