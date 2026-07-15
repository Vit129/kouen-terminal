import Foundation
import KouenCore

/// Drives four periodic background jobs for the daemon:
///   1. metadataTimer (1.5s)   — cwd + foreground command per surface; O(N) cheap syscalls.
///   2. agentScanTimer (30s)   — proc_listpids fallback for agents without OSC 26 hooks;
///                               OSC 26 is the primary real-time path, this is just a safety net.
///   3. cwdTimer (0.5s)        — lightweight shell-cwd-only probe when a subprocess is in the fg.
///   4. portScanTimer (5s)     — TCP listening-port scan per surface (P39 G1 sidebar badge);
///                               forks `lsof` once per tick, so slower than the syscall-only timers.
/// @unchecked Sendable: all mutable state confined to the serial `queue`.
public final class AgentScanner: @unchecked Sendable {
    public static let shared = AgentScanner()
    private var metadataTimer: DispatchSourceTimer?
    private var agentScanTimer: DispatchSourceTimer?
    private var cwdTimer: DispatchSourceTimer?
    private var portScanTimer: DispatchSourceTimer?
    private weak var registry: SurfaceRegistry?
    private let queue = DispatchQueue(label: "com.vit129.kouen.agent-scanner")

    /// Adaptive agent-scan cadence (P38 Phase B): 30s idle baseline, ~5s while any surface has
    /// a detected primary agent — subagent child processes are often short-lived, so the slow
    /// baseline would miss most of them. Tracked so `scanAgents()` only reschedules on an actual
    /// change, not every tick.
    private static let idleScanInterval: TimeInterval = 30
    private static let activeScanInterval: TimeInterval = 5
    private var isFastScanCadence = false

    public func start(registry: SurfaceRegistry) {
        self.registry = registry
        metadataTimer?.cancel()
        agentScanTimer?.cancel()
        cwdTimer?.cancel()
        portScanTimer?.cancel()

        // Surface metadata: cwd + foreground command (cheap per-surface proc_pidinfo) — every 1.5s
        let mt = DispatchSource.makeTimerSource(queue: queue)
        mt.schedule(deadline: .now() + 1.5, repeating: 1.5)
        mt.setEventHandler { [weak self] in self?.registry?.refreshSurfaceMetadata() }
        mt.resume()
        metadataTimer = mt

        // Agent proc-scan: proc_listpids(ALL_PIDS) fallback — every 30s.
        // OSC 26 hooks are the primary path (push-based, zero CPU cost).
        // This only matters for agents launched without hooks installed.
        let at = DispatchSource.makeTimerSource(queue: queue)
        at.schedule(deadline: .now() + 5, repeating: 30)
        at.setEventHandler { [weak self] in self?.scanAgents() }
        at.resume()
        agentScanTimer = at

        // Lightweight CWD-only probe (single proc_pidinfo per surface) — every 500ms
        let cwdTimer = DispatchSource.makeTimerSource(queue: queue)
        cwdTimer.schedule(deadline: .now() + 0.5, repeating: 0.5)
        cwdTimer.setEventHandler { [weak self] in self?.registry?.refreshCwdOnly() }
        cwdTimer.resume()
        self.cwdTimer = cwdTimer

        // Listening-port scan (batched `lsof`) — every 5s. Slower than the syscall-only
        // timers above since it forks a process; still fast enough that a dev server shows
        // up in the sidebar within one tick of starting.
        let pt = DispatchSource.makeTimerSource(queue: queue)
        pt.schedule(deadline: .now() + 5, repeating: 5)
        pt.setEventHandler { [weak self] in self?.registry?.refreshListeningPorts() }
        pt.resume()
        portScanTimer = pt
    }

    /// Stop all timers (orderly daemon shutdown / between tests). Safe to call repeatedly.
    public func stop() {
        metadataTimer?.cancel()
        metadataTimer = nil
        agentScanTimer?.cancel()
        agentScanTimer = nil
        cwdTimer?.cancel()
        cwdTimer = nil
        portScanTimer?.cancel()
        portScanTimer = nil
    }

    private func scanAgents() {
        let table = AgentTable.loadFromDisk()
        let changes = AgentDetector.scan(table: table)
        if !changes.isEmpty, let registry {
            registry.applyAgentChanges(changes)
        }
        adjustScanCadence(hasActiveAgent: registry?.hasAnyPrimaryAgent() ?? false)
    }

    /// Reschedule `agentScanTimer` to the fast (~5s) interval while any surface has a detected
    /// primary agent, or back to the 30s idle baseline once none remain. No-op if the cadence
    /// hasn't actually changed since the last tick.
    private func adjustScanCadence(hasActiveAgent: Bool) {
        guard hasActiveAgent != isFastScanCadence else { return }
        isFastScanCadence = hasActiveAgent
        let interval = hasActiveAgent ? Self.activeScanInterval : Self.idleScanInterval
        agentScanTimer?.schedule(deadline: .now() + interval, repeating: interval)
    }
}
