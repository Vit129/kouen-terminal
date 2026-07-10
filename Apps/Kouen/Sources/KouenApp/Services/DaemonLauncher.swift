import Darwin
import Foundation
import KouenCore
import KouenSettings

/// Connects the app to the long-lived `KouenDaemon` process. The daemon is
/// owned by launchd (installed by `LaunchAgentInstaller`) in release builds so it
/// survives `Kouen.app` quitting, logout, and reboot. The launcher's job is to
/// *find* a running daemon and, if none, start one — fast and without freezing the
/// UI. Release builds prefer launchd first so the daemon is supervised from the
/// start; debug builds and launchd failures fall back to a directly-spawned child.
///
/// **Startup must never block the main thread.** `ensureRunning(then:)` runs the
/// whole discover→install→poll dance on a background queue and calls back on the
/// main thread once the daemon answers (or gives up). The strategy is
/// *launchd-first in release*: if a quick ping fails we install/bootstrap the
/// LaunchAgent and let launchd bring the daemon up, so it is launchd-owned and
/// supervised from the start. Installing first also rewrites a stale LaunchAgent
/// path (e.g. a DerivedData path from a previous Xcode build that no longer
/// exists) instead of running a directly-spawned daemon *underneath* a launchd
/// service that then retries every throttle interval. A directly-spawned child is
/// the fallback only when launchd cannot bring one up — and is the normal path in
/// DEBUG, which skips the LaunchAgent entirely.
///
/// @unchecked Sendable: launch/poll state is confined to the serial `queue`.
final class DaemonLauncher: @unchecked Sendable {
    static let shared = DaemonLauncher()

    private var fallbackProcess: Process?
    private let queue = DispatchQueue(label: "com.vit129.kouen.daemon-launcher")

    /// True when running as a preview/SIT build or debug build.
    /// Preview/Debug must never interact with the production LaunchAgent.
    private let isPreview: Bool = {
        if Bundle.main.bundleIdentifier == "com.vit129.kouen.preview" {
            return true
        }
        if let val = Bundle.main.object(forInfoDictionaryKey: "KouenPreviewHome") as? String, !val.isEmpty {
            return true
        }
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()

    private init() {}

    /// Matches `Scripts/mobile-web.sh`'s default — no Settings field for the port itself since
    /// only enabling/disabling the bridge was asked for.
    private static let mobileBridgePort: UInt16 = 7777

    private func mobileBridgePortIfEnabled() -> UInt16? {
        KouenSettings.load().mobileBridgeEnabled ? Self.mobileBridgePort : nil
    }

    /// Ensure a daemon is reachable, off the main thread. `completion` runs on the
    /// main thread with `true` if the daemon answers. Safe to call at launch — the
    /// UI can build immediately and refresh from the callback.
    func ensureRunning(then completion: @escaping @MainActor (Bool) -> Void = { _ in }) {
        queue.async { [weak self] in
            let ok = self?.ensureRunningBlocking() ?? false
            Task { @MainActor in completion(ok) }
        }
    }

    /// Synchronous variant for non-main callers/tests. Never call from the main thread.
    @discardableResult
    func ensureRunningBlocking() -> Bool {
        // Preview builds (KouenPreviewHome in Info.plist) must never touch the production
        // LaunchAgent — they use their own isolated daemon spawned directly.
        if isPreview {
            if daemonResponds(timeout: 0.4) { return true }
            spawnFallbackProcess()
            if pollUntilResponding(timeoutSeconds: 3) { return true }
            return false
        }

        // Refresh the installed bin/ copies before any staleness check so the restart below
        // brings up the *updated* daemon. Release-only: a DEBUG build must never clobber the
        // user's installed release binaries (the bin/ copies and the LaunchAgent label are
        // global — not isolated by KOUEN_HOME).
        #if !DEBUG
        refreshInstalledBinaries()
        #endif
        if let stats = daemonStats(timeout: 0.4) {
            if daemonIsStale(stats) {
                restartStaleDaemon()
                if pollUntilFreshDaemon(replacingPID: stats.pid, timeoutSeconds: 3) { return true }
            } else {
                return true
            }
        } else if daemonResponds(timeout: 0.2) {
            // A daemon old enough to not understand `daemonStats` may still
            // answer `ping`, which is not enough for newer app/CLI features.
            // Restart it through the installed LaunchAgent and wait for a
            // daemon that can report stats before declaring startup ready.
            let stalePID = daemonPIDFromFile()
            restartStaleDaemon()
            if pollUntilFreshDaemon(replacingPID: stalePID, timeoutSeconds: 3) { return true }
        }

        // In release, install the corrected LaunchAgent before falling back. This
        // fixes stale DerivedData/App bundle paths and avoids running a fallback
        // daemon underneath a launchd service that then retries every throttle
        // interval.
        #if !DEBUG
        if installLaunchAgentIfPossible(), pollUntilResponding(timeoutSeconds: 4) { return true }
        #endif

        spawnFallbackProcess()
        if pollUntilResponding(timeoutSeconds: 3) { return true }
        return false
    }

    private func daemonResponds(timeout: TimeInterval = 0.5) -> Bool {
        guard let response = try? DaemonClient().request(.ping, timeout: timeout) else { return false }
        if case .pong = response { return true }
        return false
    }

    private func daemonStats(timeout: TimeInterval = 0.5) -> DaemonStats? {
        guard let response = try? DaemonClient().request(.daemonStats, timeout: timeout),
              case let .daemonStats(stats) = response
        else { return nil }
        return stats
    }

    /// A running daemon is stale when its build handshake disagrees with this app's build
    /// (nil = a daemon too old to report one), or — for the dev loop, where the build constant
    /// doesn't change between rebuilds — when the bundled binary is newer than the daemon's
    /// start. The handshake is authoritative: it survives daemon restarts, which reset the
    /// start time the mtime heuristic compares against and made it permanently read "fresh".
    ///
    /// A build mismatch alone isn't enough to force a restart, though: `install-graceful.sh`
    /// deliberately preserves a running daemon across a UI-only release when its IPC protocol
    /// still matches and it's holding live surfaces (protecting PTYs/agent sessions across the
    /// app update). If we didn't mirror that check here, this launcher would restart the very
    /// daemon install-graceful.sh just decided to keep, seconds after the app relaunches.
    /// Returning `false` (not falling through) is what skips `bundledDaemonIsNewer` below —
    /// falling through would defeat this, since `refreshInstalledBinaries()` (called just
    /// before this in `ensureRunningBlocking`) already gave the on-disk binary a fresh mtime by
    /// the time we get here.
    /// ponytail: accepted ceiling — the preserved daemon keeps running its OLD build's
    /// non-protocol code (bugfixes, etc.) until the next protocol bump, crash, or reboot, since
    /// this path skips both `restartStaleDaemon()` and `install()`'s plist rewrite. That's the
    /// same tradeoff `install-graceful.sh` already makes; nothing new here.
    func daemonIsStale(_ stats: DaemonStats) -> Bool {
        if stats.isStale(comparedTo: KouenVersion.build) {
            if stats.protocolVersion == ipcProtocolVersion, stats.surfaceCount > 0 { return false }
            return true
        }
        return bundledDaemonIsNewer(than: stats)
    }

    private func bundledDaemonIsNewer(than stats: DaemonStats) -> Bool {
        guard let executable = daemonExecutableURL(),
              let attributes = try? FileManager.default.attributesOfItem(atPath: executable.path),
              let modifiedAt = attributes[.modificationDate] as? Date
        else { return false }
        let daemonStartedAt = Date().addingTimeInterval(-stats.uptimeSeconds)
        return modifiedAt > daemonStartedAt.addingTimeInterval(1)
    }

    /// Restart the daemon **exactly once**. `install()` already bootouts-on-change + bootstraps, so a
    /// changed plist path (daemon moved on disk) starts the fresh daemon itself; only an *unchanged*
    /// path (the same binary rebuilt in place — the common Xcode dev loop) needs a single
    /// `relaunch()` kick. The old `install() + relaunch() + kill(pid)` combo fired 2–3 restarts,
    /// re-running `ensureAllSnapshotSurfaces` each time and widening the window where a pane reconnect
    /// could subscribe to a momentarily-missing surface and freeze.
    private func restartStaleDaemon() {
        guard let executable = launchAgentDaemonTarget(),
              let report = try? LaunchAgentInstaller.install(daemonPath: executable, mobileBridgePort: mobileBridgePortIfEnabled())
        else {
            // No installable LaunchAgent (e.g. daemon binary not found) — best-effort kick.
            LaunchAgentInstaller.relaunch()
            fallbackProcess = nil
            return
        }
        if report.wasAlreadyInstalled {
            LaunchAgentInstaller.relaunch()
        }
        fallbackProcess = nil
    }

    private func pollUntilResponding(timeoutSeconds: Double) -> Bool {
        let deadline = Date().addingTimeInterval(timeoutSeconds)
        while Date() < deadline {
            if daemonResponds(timeout: 0.3) { return true }
            usleep(100_000)
        }
        return false
    }

    private func pollUntilFreshDaemon(replacingPID oldPID: Int32?, timeoutSeconds: Double) -> Bool {
        let deadline = Date().addingTimeInterval(timeoutSeconds)
        while Date() < deadline {
            if let stats = daemonStats(timeout: 0.3),
               oldPID.map({ stats.pid != $0 }) ?? true,
               !daemonIsStale(stats) {
                return true
            }
            usleep(100_000)
        }
        return false
    }

    private func daemonPIDFromFile() -> Int32? {
        guard let raw = try? String(contentsOf: KouenPaths.daemonPIDURL, encoding: .utf8) else {
            return nil
        }
        return Int32(raw.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    private func installLaunchAgentIfPossible() -> Bool {
        guard let executable = launchAgentDaemonTarget() else { return false }
        do {
            _ = try LaunchAgentInstaller.install(daemonPath: executable, mobileBridgePort: mobileBridgePortIfEnabled())
            return true
        } catch {
            fputs("Kouen: LaunchAgent install failed: \(error) — using in-process daemon\n", kouenStderr)
            return false
        }
    }

    private func spawnFallbackProcess(forceRestart: Bool = false) {
        if let existing = fallbackProcess {
            // Don't stack duplicate spawns if a previous one is still coming up, unless the
            // caller explicitly wants a restart (mobile-bridge setting just changed).
            guard forceRestart || !existing.isRunning else { return }
            if existing.isRunning {
                existing.terminate()
                existing.waitUntilExit()
            }
            fallbackProcess = nil
        }
        guard let executable = daemonExecutableURL() else {
            fputs("Kouen: could not locate KouenDaemon executable\n", kouenStderr)
            return
        }
        let proc = Process()
        proc.executableURL = executable
        proc.standardOutput = nil
        proc.standardError = nil
        var environment = ProcessInfo.processInfo.environment
        environment["KOUEN_HOME"] = KouenPaths.applicationSupport.path
        if let port = mobileBridgePortIfEnabled() {
            environment["KOUEN_MOBILE_BRIDGE_PORT"] = String(port)
        }
        proc.environment = environment
        try? KouenPaths.ensureDirectories()
        do {
            try proc.run()
            fallbackProcess = proc
        } catch {
            fputs("Kouen: failed to spawn KouenDaemon at \(executable.path): \(error)\n", kouenStderr)
        }
    }

    /// Refresh the installed `bin/` daemon + CLI from this app bundle so an app update actually
    /// advances the launchd-supervised daemon and the on-PATH CLI (issue #60 — Sparkle replaces
    /// the bundle copies, never these). Only refreshes copies an installer already created, and
    /// only when bytes differ, so the common up-to-date case is just a content compare and the
    /// refresh→restart happens at most once per update.
    private func refreshInstalledBinaries() {
        _ = try? BinaryRefresher.refreshIfChanged(
            source: bundledBinaryURL(named: "KouenDaemon"),
            destination: BinaryRefresher.installedDaemonPath
        )
        _ = try? BinaryRefresher.refreshIfChanged(
            source: bundledBinaryURL(named: "kouen-cli"),
            destination: BinaryRefresher.installedCLIPath
        )
    }

    /// A binary shipped next to the app executable (`Contents/MacOS/`), where the release
    /// packager puts both the daemon and the CLI.
    private func bundledBinaryURL(named name: String) -> URL? {
        guard let dir = Bundle.main.executableURL?.deletingLastPathComponent() else { return nil }
        let url = dir.appendingPathComponent(name)
        return FileManager.default.isExecutableFile(atPath: url.path) ? url : nil
    }

    /// The daemon the LaunchAgent should supervise: the installed AppSupport copy when present
    /// (canonical — what onboarding/`kouen-cli install` write, survives the app moving, and
    /// just refreshed above in release), else wherever the bundle/dev daemon lives. DEBUG keeps
    /// the bundle/dev path so the Xcode loop restarts into the freshly built daemon, not a
    /// previously installed release copy.
    private func launchAgentDaemonTarget() -> URL? {
        #if !DEBUG
        let installed = BinaryRefresher.installedDaemonPath
        if FileManager.default.isExecutableFile(atPath: installed.path) { return installed }
        #endif
        return daemonExecutableURL()
    }

    /// Locate the daemon binary across every layout we ship in:
    /// 1. inside the app bundle (`Contents/MacOS/KouenDaemon`, copied by the
    ///    release packager and the Xcode post-build script),
    /// 2. next to the app bundle (Xcode `BUILT_PRODUCTS_DIR` sibling),
    /// 3. the SwiftPM debug build dir (`.build/debug`),
    /// 4. a system install path.
    private func daemonExecutableURL() -> URL? {
        let fm = FileManager.default
        var candidates: [URL] = []

        if let executable = Bundle.main.executableURL {
            candidates.append(executable.deletingLastPathComponent().appendingPathComponent("KouenDaemon"))
        }
        // Sibling of Kouen.app — where Xcode drops the KouenDaemon product.
        candidates.append(Bundle.main.bundleURL.deletingLastPathComponent().appendingPathComponent("KouenDaemon"))

        #if DEBUG
        let repoRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent().deletingLastPathComponent()
        candidates.append(repoRoot.appendingPathComponent(".build/debug/KouenDaemon"))
        candidates.append(repoRoot.appendingPathComponent(".build/release/KouenDaemon"))
        #endif

        candidates.append(URL(fileURLWithPath: "/usr/local/bin/KouenDaemon"))

        return candidates.first { fm.isExecutableFile(atPath: $0.path) }
    }
}
