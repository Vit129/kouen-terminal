import XCTest
import KouenCore
@testable import KouenApp

/// P46 Pillar 6 gap 6: `FleetView` is the one screen that lists every live session across
/// every workspace instead of clicking through tabs one at a time — these test the pure
/// flatten/sort/filter logic behind it (`FleetViewModel.refresh`/`.filteredItems`), no UI.
final class FleetViewModelTests: XCTestCase {
    @MainActor
    func testRefreshFlattensAllTabsAndSortsWaitingFirst() {
        let waitingTab = Tab(
            title: "waiting-agent",
            cwd: "/tmp/a",
            notificationText: "Approve?",
            status: .waiting,
            agent: AgentSnapshot(kind: .claudeCode, executable: "/bin/claude", pid: 1, activity: .awaiting)
        )
        let idleTab = Tab(title: "idle-shell", cwd: "/tmp/b")
        let session = SessionGroup(id: UUID(), name: "s", tabs: [idleTab, waitingTab], activeTabID: idleTab.id, sortOrder: 0)
        let ws = Workspace(id: UUID(), name: "MyRepo", sessions: [session], activeSessionID: session.id)
        let snap = SessionSnapshot(workspaces: [ws], activeWorkspaceID: ws.id)

        let model = FleetViewModel()
        model.refresh(from: snap)

        XCTAssertEqual(model.items.count, 2)
        XCTAssertEqual(model.items.first?.title, "waiting-agent", "a waiting tab must sort before an idle one")
        XCTAssertEqual(model.waitingCount, 1)
    }

    /// Found live: two blank shell tabs in the same session/cwd render identically, so
    /// `isActive` marking which one you're looking at is the only way to tell them apart.
    @MainActor
    func testRefreshMarksTheActiveSurfaceAndOnlyThatOne() {
        let tabA = Tab(title: "Shell", cwd: "/tmp")
        let tabB = Tab(title: "Shell", cwd: "/tmp")
        let session = SessionGroup(id: UUID(), name: "s", tabs: [tabA, tabB], activeTabID: tabA.id, sortOrder: 0)
        let ws = Workspace(id: UUID(), name: "W", sessions: [session], activeSessionID: session.id)
        let snap = SessionSnapshot(workspaces: [ws], activeWorkspaceID: ws.id)

        let activeSurfaceID = tabB.rootPane.allSurfaceIDs().first
        let model = FleetViewModel()
        model.refresh(from: snap, activeSurfaceID: activeSurfaceID)

        XCTAssertEqual(model.items.count, 2)
        let activeItems = model.items.filter(\.isActive)
        XCTAssertEqual(activeItems.count, 1, "exactly one row must be marked active")
        XCTAssertEqual(activeItems.first?.tabID, tabB.id.uuidString)
    }

    @MainActor
    func testFilterTextMatchesTitleCwdAndAgentName() {
        let tab = Tab(
            title: "review-pr",
            cwd: "/Users/dev/kouen-terminal",
            agent: AgentSnapshot(kind: .codex, executable: "/bin/codex", pid: 1)
        )
        let session = SessionGroup(id: UUID(), name: "s", tabs: [tab], activeTabID: tab.id, sortOrder: 0)
        let ws = Workspace(id: UUID(), name: "kouen-terminal", sessions: [session], activeSessionID: session.id)
        let snap = SessionSnapshot(workspaces: [ws], activeWorkspaceID: ws.id)

        let model = FleetViewModel()
        model.refresh(from: snap)

        model.filterText = "codex"
        XCTAssertEqual(model.filteredItems.count, 1)

        model.filterText = "no-match-xyz"
        XCTAssertTrue(model.filteredItems.isEmpty)
    }
}
