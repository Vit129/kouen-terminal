import Foundation
import KouenCore

/// Drives three periodic background jobs for the daemon:
///   1. metadataTimer (1.5s)   — cwd + foreground command per surface; O(N) cheap syscalls.
///   2. agentScanTimer (30s)   — proc_listpids fallback for agents without OSC 26 hooks;
///                               OSC 26 is the primary real-time path, this is just a safety net.
///   3. cwdTimer (0.5s)        — lightweight shell-cwd-only probe when a subprocess is in the fg.
/// @unchecked Sendable: all mutable state confined to the serial `queue`.
public final class AgentScanner: @unchecked Sendable {
    public static let shared = AgentScanner()
    private var metadataTimer: DispatchSourceTimer?
    private var agentScanTimer: DispatchSourceTimer?
    private var cwdTimer: DispatchSourceTimer?
    private weak var registry: SurfaceRegistry?
    private let queue = DispatchQueue(label: "com.vit129.kouen.agent-scanner")

    public func start(registry: SurfaceRegistry) {
        self.registry = registry
        metadataTimer?.cancel()
        agentScanTimer?.cancel()
        cwdTimer?.cancel()

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
    }

    /// Stop all timers (orderly daemon shutdown / between tests). Safe to call repeatedly.
    public func stop() {
        metadataTimer?.cancel()
        metadataTimer = nil
        agentScanTimer?.cancel()
        agentScanTimer = nil
        cwdTimer?.cancel()
        cwdTimer = nil
    }

    private func scanAgents() {
        let table = AgentTable.loadFromDisk()
        let changes = AgentDetector.scan(table: table)
        guard !changes.isEmpty, let registry else { return }
        registry.applyAgentChanges(changes)
    }
}
