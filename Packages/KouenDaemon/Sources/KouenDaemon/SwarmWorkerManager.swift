import Foundation
import KouenCore

/// One request to spawn a fleet worker. `initialCommand` means different things per lane:
/// Lane A (`.structured`): the actual prompt sent to `ClaudeCodeHarness.start`.
/// Lane B (`.pty`): the shell command typed into the freshly created surface to launch the
/// agent CLI (e.g. `"codex\n"`) — NOT a user prompt. A caller sends the real user prompt
/// afterward via `SwarmWorkerManager.send`, exactly like the existing interactive
/// `kouenSpawnAgent`/`kouenSpawnWorker` MCP tools already separate "launch the agent" from
/// "type a prompt into it".
public struct SwarmSpawnSpec: Sendable {
    public var lane: SwarmLane
    public var agentKind: AgentKind
    public var cwd: String?
    public var initialCommand: String
    public var role: String?

    public init(lane: SwarmLane, agentKind: AgentKind, cwd: String? = nil, initialCommand: String, role: String? = nil) {
        self.lane = lane
        self.agentKind = agentKind
        self.cwd = cwd
        self.initialCommand = initialCommand
        self.role = role
    }
}

/// Fleet-lifecycle wrapper over both worker lanes, reporting into one shared `SwarmDAGStore`.
/// Every daemon-process side effect (creating a PTY surface, typing into one, running the
/// Claude harness) is injected as a closure rather than this type holding a direct reference
/// to `SurfaceRegistry`/`ClaudeCodeHarness` — keeps this type trivially unit-testable with
/// fake closures instead of a real PTY/subprocess, and keeps it decoupled from exactly how
/// the daemon wires those dependencies (`DaemonServer` does that wiring separately).
public actor SwarmWorkerManager {
    public typealias CreatePTYSurface = @Sendable (_ cwd: String?) -> String?
    public typealias SendToSurface = @Sendable (_ surfaceID: String, _ text: String) -> Void
    public typealias CloseSurface = @Sendable (_ surfaceID: String) -> Void
    public typealias StartHarnessRun = @Sendable (_ id: UUID, _ agentKind: AgentKind, _ prompt: String, _ cwd: String) async -> ClaudeCodeHarness.RunSummary
    public typealias CancelHarnessRun = @Sendable (_ id: UUID) async -> Bool
    /// Polled after a Lane A spawn to sync the DAG node's status once the run actually
    /// finishes — `startHarnessRun`/`ClaudeCodeHarness.start()` return as soon as the process
    /// *launches*, not when it completes (that contract is shared with `kouenCCRun`/
    /// `kouenCCStatus`'s own poll-based usage, so it can't change here). Without this, a fleet
    /// node sits at `.working` forever even after the real subprocess exits — a real bug found
    /// during this feature's first live-daemon check (2026-09-14), not a hypothetical.
    public typealias GetHarnessRun = @Sendable (_ id: UUID) async -> ClaudeCodeHarness.RunSummary?

    private let dagStore: SwarmDAGStore
    private let createPTYSurface: CreatePTYSurface
    private let sendToSurface: SendToSurface
    private let closeSurface: CloseSurface
    private let startHarnessRun: StartHarnessRun
    private let cancelHarnessRun: CancelHarnessRun
    private let getHarnessRun: GetHarnessRun
    /// Hard ceiling on a Lane A run's wall-clock time before it's treated as dead. Found
    /// necessary live (2026-09-14): a real headless `copilot` invocation hung indefinitely
    /// mid-run — reproduced 3× outside Kouen entirely (with/without `--session-id`,
    /// with/without stdin redirected), so this is the external CLI's own flakiness, not a
    /// Kouen bug — but a fleet has no way to notice or recover from it without a timeout
    /// here. Generous on purpose (180s default): a real multi-tool agent turn can
    /// legitimately run for minutes; this is a dead-process backstop, not a responsiveness
    /// target. Injectable (not a hardcoded constant) so tests can verify the timeout path
    /// itself without a real 180s wait.
    private let harnessRunTimeout: Duration
    /// Lane B only: which surface a task id is bound to. Lane A has no equivalent (its
    /// identity lives entirely in `ClaudeCodeHarness`'s own run table, keyed by the same id).
    private var surfaceByTask: [UUID: String] = [:]

    public init(
        dagStore: SwarmDAGStore,
        createPTYSurface: @escaping CreatePTYSurface,
        sendToSurface: @escaping SendToSurface,
        closeSurface: @escaping CloseSurface,
        startHarnessRun: @escaping StartHarnessRun,
        cancelHarnessRun: @escaping CancelHarnessRun,
        getHarnessRun: @escaping GetHarnessRun,
        harnessRunTimeout: Duration = .seconds(180)
    ) {
        self.dagStore = dagStore
        self.createPTYSurface = createPTYSurface
        self.sendToSurface = sendToSurface
        self.closeSurface = closeSurface
        self.startHarnessRun = startHarnessRun
        self.cancelHarnessRun = cancelHarnessRun
        self.getHarnessRun = getHarnessRun
        self.harnessRunTimeout = harnessRunTimeout
    }

    /// Spawns a new fleet worker and records it in the DAG store. `id` is a fresh UUID
    /// generated here (never caller-supplied) — this is the node's identity for every
    /// future `send`/`terminate`/DAG lookup.
    @discardableResult
    public func spawn(_ spec: SwarmSpawnSpec) async -> SwarmTaskNode {
        let id = UUID()
        switch spec.lane {
        case .structured:
            let node = SwarmTaskNode(id: id, lane: .structured, agentKind: spec.agentKind, role: spec.role, status: .working)
            await dagStore.recordSpawn(node)
            _ = await startHarnessRun(id, spec.agentKind, spec.initialCommand, spec.cwd ?? FileManager.default.currentDirectoryPath)
            pollForCompletion(id)
            return node
        case .pty:
            guard let surfaceID = createPTYSurface(spec.cwd) else {
                let failedNode = SwarmTaskNode(
                    id: id, lane: .pty, agentKind: spec.agentKind, role: spec.role,
                    status: .failed, summary: "failed to create PTY surface"
                )
                await dagStore.recordSpawn(failedNode)
                return failedNode
            }
            surfaceByTask[id] = surfaceID
            sendToSurface(surfaceID, spec.initialCommand)
            let node = SwarmTaskNode(
                id: id, lane: .pty, agentKind: spec.agentKind, role: spec.role,
                status: .spawning, surfaceID: surfaceID
            )
            await dagStore.recordSpawn(node)
            return node
        }
    }

    /// Types `text` into a Lane B worker's surface. Lane A has no equivalent yet — a running
    /// one-shot `claude -p` process has no stdin to steer mid-run; a follow-up turn needs
    /// `resumeSessionID` chaining, which is a separate, not-yet-built slice (see
    /// agent-memory/plans/agent-swarm-core/design.md). Returns `false` for an unknown id OR
    /// a Lane A id (both are "can't do this yet" from the caller's point of view).
    @discardableResult
    public func send(taskID: UUID, text: String) async -> Bool {
        guard let surfaceID = surfaceByTask[taskID] else { return false }
        sendToSurface(surfaceID, text)
        await dagStore.updateStatus(taskID, status: .working)
        return true
    }

    /// Terminates a worker: Lane B closes its surface, Lane A cancels the harness run.
    /// Marks the DAG node `.cancelled` only when the underlying lane actually confirms the
    /// termination (Lane B's `closeSurface` is fire-and-forget so it's always treated as
    /// successful; Lane A's `cancelHarnessRun` can report `false` for an already-finished
    /// run, in which case the node's existing status is left alone rather than overwritten).
    @discardableResult
    public func terminate(taskID: UUID) async -> Bool {
        if let surfaceID = surfaceByTask[taskID] {
            closeSurface(surfaceID)
            surfaceByTask.removeValue(forKey: taskID)
            await dagStore.updateStatus(taskID, status: .cancelled)
            return true
        }
        let cancelled = await cancelHarnessRun(taskID)
        if cancelled {
            await dagStore.updateStatus(taskID, status: .cancelled)
        }
        return cancelled
    }

    public func snapshot() async -> SwarmFleetSnapshot {
        await dagStore.snapshot()
    }

    /// Fire-and-forget: not `await`ed by `spawn()` (a 50-worker fleet spawning must return
    /// each `spawn()` call quickly, not block on every worker's eventual completion). Detached
    /// rather than structured under this actor because it must keep running after `spawn()`
    /// returns and long outlives any single method call — same shape as
    /// `RealPty`'s termination-handler `Task { await self?... }` hops elsewhere in this daemon,
    /// just started explicitly instead of from a C callback.
    private func pollForCompletion(_ id: UUID) {
        let dagStore = dagStore
        let getHarnessRun = getHarnessRun
        let cancelHarnessRun = cancelHarnessRun
        let harnessRunTimeout = harnessRunTimeout
        Task.detached {
            var elapsed: Duration = .zero
            while true {
                try? await Task.sleep(for: .milliseconds(500))
                elapsed += .milliseconds(500)
                guard let summary = await getHarnessRun(id) else { return }
                if summary.state == .running {
                    guard elapsed < harnessRunTimeout else {
                        _ = await cancelHarnessRun(id)
                        await dagStore.updateStatus(
                            id, status: .failed,
                            summary: "timed out after \(Int(harnessRunTimeout.components.seconds))s with no response"
                        )
                        return
                    }
                    continue
                }
                let status: SwarmTaskStatus
                switch summary.state {
                case .succeeded: status = .succeeded
                case .failed: status = .failed
                case .cancelled: status = .cancelled
                case .running: status = .working // unreachable, guarded above
                }
                await dagStore.updateStatus(id, status: status, summary: summary.resultText)
                return
            }
        }
    }
}
