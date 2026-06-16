import Foundation
import HarnessCore

/// Lightweight hot-path counters for P22 long-session responsiveness investigation.
///
/// All mutation happens on @MainActor (the same isolation as every caller).
/// Dumps a formatted report to stderr every 30 minutes so it shows up in
/// Console.app or `harness-cli log` without any special tooling.
///
/// To read live: `log stream --process Harness | grep "P22 PerfCounters"`
@MainActor
final class PerfCounters {
    static let shared = PerfCounters()

    // MARK: - SurfaceShellTracker
    var shellTrackerTicks = 0
    var shellTrackerCwdChanges = 0   // surfaces whose cwd actually changed

    // MARK: - DaemonSyncService.startMetadataRefresh
    var metadataRefreshWakeups = 0
    var metadataRefreshSkippedIdle = 0   // skipped because AppIdleThrottle.isSuspended
    var metadataRefreshGitChecks = 0     // individual tab git probes
    var metadataRefreshSyncFired = 0     // syncFromDaemon actually called (delta found)
    var metadataRefreshSyncSkipped = 0   // skipped because no branch delta

    // MARK: - applySnapshot fanout
    var snapshotApplied = 0
    var snapshotAppliedMetadataOnly = 0
    var snapshotAppliedStructural = 0

    // MARK: - snapshotChanged consumers
    var fanoutSidebarReload = 0
    var fanoutSidebarMetadata = 0
    var fanoutBoardReload = 0
    var fanoutNotchRefresh = 0
    var fanoutTabBarReload = 0
    var fanoutTabBarMetadata = 0

    // MARK: - Lifecycle
    private let startTime = Date()
    private var dumpTimer: DispatchSourceTimer?

    private init() {}

    func start() {
        let t = DispatchSource.makeTimerSource(queue: .main)
        t.schedule(deadline: .now() + 1800, repeating: 1800)   // every 30 min
        t.setEventHandler { [weak self] in self?.dump() }
        t.resume()
        dumpTimer = t
    }

    /// Emit a one-shot report now (also called by the timer).
    func dump() {
        let elapsed = -startTime.timeIntervalSinceNow
        let hrs = elapsed / 3600
        let rate: (Int) -> String = { n in
            guard elapsed > 0 else { return "—" }
            let r = Double(n) / hrs
            return String(format: "%.1f/hr", r)
        }

        let lines = [
            "───── P22 PerfCounters ─────────────────────────────",
            String(format: "  uptime              %.0f min", elapsed / 60),
            "",
            "  SurfaceShellTracker",
            "    ticks              \(shellTrackerTicks)  (\(rate(shellTrackerTicks)))",
            "    cwd changes        \(shellTrackerCwdChanges)  (\(rate(shellTrackerCwdChanges)))",
            "    no-op ticks        \(shellTrackerTicks - shellTrackerCwdChanges)",
            "",
            "  MetadataRefresh (5-s loop)",
            "    wakeups            \(metadataRefreshWakeups)  (\(rate(metadataRefreshWakeups)))",
            "    skipped (idle)     \(metadataRefreshSkippedIdle)",
            "    git probes         \(metadataRefreshGitChecks)",
            "    sync fired         \(metadataRefreshSyncFired)",
            "    sync skipped       \(metadataRefreshSyncSkipped)",
            "",
            "  applySnapshot",
            "    total              \(snapshotApplied)",
            "    structural         \(snapshotAppliedStructural)",
            "    metadata-only      \(snapshotAppliedMetadataOnly)",
            "",
            "  snapshotChanged fanout",
            "    sidebar reload     \(fanoutSidebarReload)",
            "    sidebar metadata   \(fanoutSidebarMetadata)",
            "    board reload       \(fanoutBoardReload)",
            "    notch refresh      \(fanoutNotchRefresh)",
            "    tabbar reload      \(fanoutTabBarReload)",
            "    tabbar metadata    \(fanoutTabBarMetadata)",
            "────────────────────────────────────────────────────",
        ]
        fputs(lines.joined(separator: "\n") + "\n", harnessStderr)
    }
}
