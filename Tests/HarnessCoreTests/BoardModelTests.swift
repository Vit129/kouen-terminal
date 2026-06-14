import XCTest
@testable import HarnessCore

/// P16 PBI-BOARD-001: `BoardModel.classify` is the single source of truth for
/// Kanban column assignment shared by GUI, CLI, scripting, and MCP.
final class BoardModelTests: XCTestCase {
    private func snapshot(tabs: [Tab]) -> SessionSnapshot {
        let session = SessionGroup(id: UUID(), name: "s", tabs: tabs, activeTabID: tabs.first?.id, sortOrder: 0)
        let ws = Workspace(id: UUID(), name: "W", sessions: [session], activeSessionID: session.id)
        return SessionSnapshot(workspaces: [ws], activeWorkspaceID: ws.id)
    }

    func testReturnsAllColumnsInOrderEvenWhenEmpty() {
        let columns = BoardModel.classify(snapshot: SessionSnapshot())
        XCTAssertEqual(columns.map(\.kind), [.needsAttention, .running, .idle, .done, .error])
        // Default SessionSnapshot has one idle tab.
        XCTAssertEqual(columns.first { $0.kind == .idle }?.cards.count, 1)
    }

    func testRunningTabWithForegroundCommand() {
        let tab = Tab(title: "build", currentCommand: "npm")
        let columns = BoardModel.classify(snapshot: snapshot(tabs: [tab]))
        XCTAssertEqual(columns.first { $0.kind == .running }?.cards.count, 1)
        XCTAssertEqual(columns.first { $0.kind == .running }?.cards.first?.tabID, tab.id)
    }

    func testIdleTabWithShellCurrentCommand() {
        let tab = Tab(title: "shell", currentCommand: "zsh")
        let columns = BoardModel.classify(snapshot: snapshot(tabs: [tab]))
        XCTAssertEqual(columns.first { $0.kind == .idle }?.cards.count, 1)
    }

    func testIdleTabWithNoCurrentCommand() {
        let tab = Tab(title: "shell")
        let columns = BoardModel.classify(snapshot: snapshot(tabs: [tab]))
        XCTAssertEqual(columns.first { $0.kind == .idle }?.cards.count, 1)
    }

    func testDoneTabWithZeroExitStatus() {
        let tab = Tab(title: "build", exitStatus: 0)
        let columns = BoardModel.classify(snapshot: snapshot(tabs: [tab]))
        XCTAssertEqual(columns.first { $0.kind == .done }?.cards.count, 1)
    }

    func testErrorTabWithNonZeroExitStatus() {
        let tab = Tab(title: "build", exitStatus: 1)
        let columns = BoardModel.classify(snapshot: snapshot(tabs: [tab]))
        XCTAssertEqual(columns.first { $0.kind == .error }?.cards.count, 1)
    }

    func testNeedsAttentionFromAwaitingAgent() {
        let agent = AgentSnapshot(kind: .claudeCode, executable: "claude", pid: 123, activity: .awaiting)
        let tab = Tab(title: "agent", agent: agent, currentCommand: "claude")
        let columns = BoardModel.classify(snapshot: snapshot(tabs: [tab]))
        XCTAssertEqual(columns.first { $0.kind == .needsAttention }?.cards.count, 1)
        XCTAssertEqual(columns.first { $0.kind == .needsAttention }?.cards.first?.agentKind, .claudeCode)
        // Should not also appear in Running.
        XCTAssertEqual(columns.first { $0.kind == .running }?.cards.count, 0)
    }

    func testNeedsAttentionTakesPrecedenceOverExitStatus() {
        let agent = AgentSnapshot(kind: .codex, executable: "codex", pid: 1, activity: .awaiting)
        let tab = Tab(title: "agent", agent: agent, exitStatus: 1)
        let columns = BoardModel.classify(snapshot: snapshot(tabs: [tab]))
        XCTAssertEqual(columns.first { $0.kind == .needsAttention }?.cards.count, 1)
        XCTAssertEqual(columns.first { $0.kind == .error }?.cards.count, 0)
    }

    func testAgentRunningButNotAwaitingClassifiesByCommand() {
        let agent = AgentSnapshot(kind: .codex, executable: "codex", pid: 1, activity: .working)
        let tab = Tab(title: "agent", agent: agent, currentCommand: "codex")
        let columns = BoardModel.classify(snapshot: snapshot(tabs: [tab]))
        XCTAssertEqual(columns.first { $0.kind == .running }?.cards.count, 1)
        XCTAssertEqual(columns.first { $0.kind == .running }?.cards.first?.agentKind, .codex)
    }

    func testCardCarriesTitleCwdAndBranch() {
        let tab = Tab(title: "my-tab", cwd: "/tmp/project", gitBranch: "main", currentCommand: "vim")
        let columns = BoardModel.classify(snapshot: snapshot(tabs: [tab]))
        let card = columns.first { $0.kind == .running }?.cards.first
        XCTAssertEqual(card?.title, "my-tab")
        XCTAssertEqual(card?.cwd, "/tmp/project")
        XCTAssertEqual(card?.gitBranch, "main")
        XCTAssertEqual(card?.currentCommand, "vim")
    }

    func testMultipleTabsAcrossWorkspacesAndSessions() {
        let running = Tab(title: "running", currentCommand: "npm")
        let idle = Tab(title: "idle")
        let session1 = SessionGroup(id: UUID(), name: "s1", tabs: [running], activeTabID: running.id, sortOrder: 0)
        let session2 = SessionGroup(id: UUID(), name: "s2", tabs: [idle], activeTabID: idle.id, sortOrder: 1)
        let ws1 = Workspace(id: UUID(), name: "W1", sessions: [session1], activeSessionID: session1.id, sortOrder: 0)
        let ws2 = Workspace(id: UUID(), name: "W2", sessions: [session2], activeSessionID: session2.id, sortOrder: 1)
        let snap = SessionSnapshot(workspaces: [ws1, ws2], activeWorkspaceID: ws1.id)

        let columns = BoardModel.classify(snapshot: snap)
        XCTAssertEqual(columns.first { $0.kind == .running }?.cards.count, 1)
        XCTAssertEqual(columns.first { $0.kind == .idle }?.cards.count, 1)
    }
}
