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

    private let dagStore: SwarmDAGStore
    private let createPTYSurface: CreatePTYSurface
    private let sendToSurface: SendToSurface
    private let closeSurface: CloseSurface
    private let startHarnessRun: StartHarnessRun
    private let cancelHarnessRun: CancelHarnessRun
    /// Lane B only: which surface a task id is bound to. Lane A has no equivalent (its
    /// identity lives entirely in `ClaudeCodeHarness`'s own run table, keyed by the same id).
    private var surfaceByTask: [UUID: String] = [:]

    public init(
        dagStore: SwarmDAGStore,
        createPTYSurface: @escaping CreatePTYSurface,
        sendToSurface: @escaping SendToSurface,
        closeSurface: @escaping CloseSurface,
        startHarnessRun: @escaping StartHarnessRun,
        cancelHarnessRun: @escaping CancelHarnessRun
    ) {
        self.dagStore = dagStore
        self.createPTYSurface = createPTYSurface
        self.sendToSurface = sendToSurface
        self.closeSurface = closeSurface
        self.startHarnessRun = startHarnessRun
        self.cancelHarnessRun = cancelHarnessRun
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
}
