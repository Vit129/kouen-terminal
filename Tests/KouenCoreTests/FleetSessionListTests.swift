import XCTest
import KouenIPC
@testable import KouenCore

/// [TS-P54-007] [BE-UT] Pure flatten / sort / filter behind the Projects tab — moved out of
/// the UI layer into KouenCore (Nov 2026 memory investigation) so it can be tested headless.
final class FleetSessionListTests: XCTestCase {

    private func snapshot(_ tabs: [Tab], name: String = "W") -> SessionSnapshot {
        let session = SessionGroup(id: UUID(), name: "s", tabs: tabs, activeTabID: tabs.first?.id, sortOrder: 0)
        let ws = Workspace(id: UUID(), name: name, sessions: [session], activeSessionID: session.id)
        return SessionSnapshot(workspaces: [ws], activeWorkspaceID: ws.id)
    }

    func testFlattenSortsWaitingFirst() {
        let waitingTab = Tab(
            title: "waiting-agent",
            cwd: "/tmp/a",
            notificationText: "Approve?",
            status: .waiting,
            agent: AgentSnapshot(kind: .claudeCode, executable: "/bin/claude", pid: 1, activity: .awaiting)
        )
        let idleTab = Tab(title: "idle-shell", cwd: "/tmp/b")

        let items = FleetSessionList.flatten(snapshot([idleTab, waitingTab]))

        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(items.first?.title, "waiting-agent")
        XCTAssertEqual(items.filter(\.isWaiting).count, 1)
    }

    func testFlattenMarksOnlyTheActiveSurface() {
        let tabA = Tab(title: "Shell", cwd: "/tmp")
        let tabB = Tab(title: "Shell", cwd: "/tmp")

        let active = tabB.rootPane.allSurfaceIDs().first
        let items = FleetSessionList.flatten(snapshot([tabA, tabB]), activeSurfaceID: active)

        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(items.filter(\.isActive).count, 1)
        XCTAssertEqual(items.first(where: \.isActive)?.tabID, tabB.id.uuidString)
    }

    func testFilterTextMatchesTitleCwdAndAgentName() {
        let tab = Tab(
            title: "review-pr",
            cwd: "/Users/dev/kouen-terminal",
            agent: AgentSnapshot(kind: .codex, executable: "/bin/codex", pid: 1)
        )
        let items = FleetSessionList.flatten(snapshot([tab], name: "kouen-terminal"))

        XCTAssertEqual(FleetSessionList.filter(items, text: "codex").count, 1)
        XCTAssertTrue(FleetSessionList.filter(items, text: "no-match-xyz").isEmpty)
        XCTAssertEqual(FleetSessionList.filter(items, text: "").count, 1)
    }

    func testChipFilterSeparatesAgentsAndWaiting() {
        let waitingAgent = Tab(
            title: "agent-waiting",
            cwd: "/tmp/a",
            status: .waiting,
            agent: AgentSnapshot(kind: .claudeCode, executable: "/bin/claude", pid: 1, activity: .awaiting)
        )
        let busyAgent = Tab(
            title: "agent-busy",
            cwd: "/tmp/b",
            status: .running,
            agent: AgentSnapshot(kind: .codex, executable: "/bin/codex", pid: 2, activity: .working)
        )
        let shell = Tab(title: "idle-shell", cwd: "/tmp/c")

        let items = FleetSessionList.flatten(snapshot([waitingAgent, busyAgent, shell]))

        XCTAssertEqual(FleetSessionList.filtered(items, by: .all).count, 3)
        XCTAssertEqual(FleetSessionList.filtered(items, by: .agents).count, 2)
        XCTAssertTrue(FleetSessionList.filtered(items, by: .agents).allSatisfy { $0.agentName != nil })
        XCTAssertEqual(FleetSessionList.filtered(items, by: .waiting).map(\.title), ["agent-waiting"])
    }
}
