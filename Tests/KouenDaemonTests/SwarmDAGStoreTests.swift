import XCTest
@testable import KouenDaemonCore

final class SwarmDAGStoreTests: XCTestCase {
    func testRecordSpawnThenSnapshotReturnsThatNode() async {
        let store = SwarmDAGStore()
        let node = SwarmTaskNode(id: UUID(), lane: .structured, agentKind: .claudeCode)
        await store.recordSpawn(node)
        let snapshot = await store.snapshot()
        XCTAssertEqual(snapshot.nodes.count, 1)
        XCTAssertEqual(snapshot.nodes[0].id, node.id)
        XCTAssertEqual(snapshot.generation, 1)
    }

    func testRecordEdgeSetsParentRoleAndSummaryOnExistingChild() async {
        let store = SwarmDAGStore()
        let parentNode = SwarmTaskNode(id: UUID(), lane: .structured, agentKind: .claudeCode)
        let childNode = SwarmTaskNode(id: UUID(), lane: .structured, agentKind: .claudeCode)
        await store.recordSpawn(parentNode)
        await store.recordSpawn(childNode)
        await store.recordEdge(parent: parentNode.id, child: childNode.id, role: "reviewer", summary: "review the diff")
        let snapshot = await store.snapshot()
        let child = snapshot.nodes.first(where: { $0.id == childNode.id })
        XCTAssertNotNil(child)
        XCTAssertEqual(child?.parentID, parentNode.id)
        XCTAssertEqual(child?.role, "reviewer")
        XCTAssertEqual(child?.summary, "review the diff")
    }

    func testRecordEdgeOnUnknownChildIsNoOp() async {
        let store = SwarmDAGStore()
        await store.recordEdge(parent: UUID(), child: UUID(), role: "reviewer", summary: "review the diff")
        let snapshot = await store.snapshot()
        XCTAssertEqual(snapshot.nodes.count, 0)
        XCTAssertEqual(snapshot.generation, 0)
    }

    func testUpdateStatusChangesStatusTokensAndLastActivityAt() async {
        let store = SwarmDAGStore()
        let node = SwarmTaskNode(
            id: UUID(), lane: .structured, agentKind: .claudeCode,
            startedAt: Date(timeIntervalSince1970: 0)
        )
        await store.recordSpawn(node)
        await store.updateStatus(node.id, status: .working, tokens: 42)
        let snapshot = await store.snapshot()
        let updatedNode = snapshot.nodes.first(where: { $0.id == node.id })
        XCTAssertNotNil(updatedNode)
        XCTAssertEqual(updatedNode?.status, .working)
        XCTAssertEqual(updatedNode?.tokens, 42)
        XCTAssertTrue(updatedNode!.lastActivityAt > node.startedAt)
    }

    func testUpdateStatusOnUnknownIdIsNoOp() async {
        let store = SwarmDAGStore()
        await store.updateStatus(UUID(), status: .working, tokens: 42)
        let snapshot = await store.snapshot()
        XCTAssertEqual(snapshot.nodes.count, 0)
        XCTAssertEqual(snapshot.generation, 0)
    }

    func testGenerationOnlyIncrementsOnRealMutations() async {
        let store = SwarmDAGStore()
        let node = SwarmTaskNode(id: UUID(), lane: .structured, agentKind: .claudeCode)
        await store.recordSpawn(node)
        await store.recordEdge(parent: UUID(), child: UUID(), role: "reviewer", summary: "review the diff")
        await store.updateStatus(UUID(), status: .working, tokens: 42)
        let snapshot1 = await store.snapshot()
        await store.updateStatus(node.id, status: .working, tokens: 42)
        let snapshot2 = await store.snapshot()
        XCTAssertEqual(snapshot1.generation, 1)
        XCTAssertEqual(snapshot2.generation, 2)
    }
}
