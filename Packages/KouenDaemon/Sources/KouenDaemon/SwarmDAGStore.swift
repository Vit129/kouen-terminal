import Foundation

/// Shared fleet DAG for Agent Swarm Core — both the structured (Claude harness) and
/// PTY lanes report into one store. Intentionally minimal for this slice: no
/// delta-only push, no coalescing/debounce, no eviction of old completed nodes.
/// Those land in a later slice per `agent-memory/plans/agent-swarm-core/design.md`;
/// don't add them speculatively here.
public actor SwarmDAGStore {
    private var nodes: [UUID: SwarmTaskNode] = [:]
    private var generation: Int = 0

    public init() {}

    public func recordSpawn(_ node: SwarmTaskNode) {
        nodes[node.id] = node
        generation += 1
    }

    /// No-op (not an implicit insert) if `child` hasn't been spawned yet — a node's
    /// lineage can only be attached after it exists.
    public func recordEdge(parent: UUID, child: UUID, role: String?, summary: String?) {
        guard var childNode = nodes[child] else { return }
        childNode.parentID = parent
        if let role { childNode.role = role }
        if let summary { childNode.summary = summary }
        nodes[child] = childNode
        generation += 1
    }

    /// No-op if `id` isn't a known node. `summary` (added for Lane A completion sync — see
    /// `SwarmWorkerManager`'s harness-completion poll) overwrites the node's existing summary
    /// only when non-nil, same "don't clobber with absence" rule `recordEdge` already uses.
    public func updateStatus(_ id: UUID, status: SwarmTaskStatus, tokens: Int? = nil, summary: String? = nil) {
        guard var node = nodes[id] else { return }
        node.status = status
        if let tokens { node.tokens = tokens }
        if let summary { node.summary = summary }
        node.lastActivityAt = Date()
        nodes[id] = node
        generation += 1
    }

    public func snapshot() -> SwarmFleetSnapshot {
        SwarmFleetSnapshot(nodes: Array(nodes.values), generation: generation)
    }
}
