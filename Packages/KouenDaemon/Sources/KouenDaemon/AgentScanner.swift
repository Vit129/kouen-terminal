import Foundation
import KouenCore

/// Drives four periodic background jobs for the daemon:
///   1. cwdTimer (0.5s)        — shell cwd probes; every third tick adds command metadata.
///   2. agentScanTimer (30s)   — proc_listpids fallback for agents without OSC 26 hooks;
///                               OSC 26 is the primary real-time path, this is just a safety net.
///   3. every third cwd tick   — full cwd + foreground command probe; avoids duplicate proc_pidinfo.
///   4. portScanTimer (5s)     — TCP listening-port scan per surface (P39 G1 sidebar badge);
///                               forks `lsof` once per tick, so slower than the syscall-only timers.
/// @unchecked Sendable: all mutable state confined to the serial `queue`.
public final class AgentScanner: @unchecked Sendable {
    public static let shared = AgentScanner()
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

    private static let idlePortScanInterval: TimeInterval = 30
    private static let activePortScanInterval: TimeInterval = 5
    private var isFastPortScanCadence = false
    private var cwdProbeTicks = 0

    public func start(registry: SurfaceRegistry) {
        self.registry = registry
        cwdProbeTicks = 0
        agentScanTimer?.cancel()
        cwdTimer?.cancel()
        portScanTimer?.cancel()

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
        cwdTimer.setEventHandler { [weak self] in
            guard let self, let registry = self.registry else { return }
            self.cwdProbeTicks = (self.cwdProbeTicks + 1) % 3
            if self.cwdProbeTicks == 0 { registry.refreshSurfaceMetadata() }
            else { registry.refreshCwdOnly() }
        }
        cwdTimer.resume()
        self.cwdTimer = cwdTimer

        // Listening-port scan (batched `lsof`) — adaptive: 5s when dev candidate active, 30s idle baseline
        let pt = DispatchSource.makeTimerSource(queue: queue)
        pt.schedule(deadline: .now() + 5, repeating: Self.idlePortScanInterval)
        pt.setEventHandler { [weak self] in self?.scanPorts() }
        pt.resume()
        portScanTimer = pt
    }

    /// Stop all timers (orderly daemon shutdown / between tests). Safe to call repeatedly.
    public func stop() {
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

    private func scanPorts() {
        guard let registry else { return }
        registry.refreshListeningPorts()
        let hasCandidate = registry.hasAnyActiveSubprocessOrAgent()
        adjustPortScanCadence(hasCandidate: hasCandidate)
    }

    private func adjustPortScanCadence(hasCandidate: Bool) {
        guard hasCandidate != isFastPortScanCadence else { return }
        isFastPortScanCadence = hasCandidate
        let interval = hasCandidate ? Self.activePortScanInterval : Self.idlePortScanInterval
        portScanTimer?.schedule(deadline: .now() + interval, repeating: interval)
    }
}
