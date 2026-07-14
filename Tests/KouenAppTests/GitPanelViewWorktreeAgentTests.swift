import XCTest
import KouenCore
@testable import KouenApp

/// The Git panel's worktree cards used to show only git-level info (branch/merged/locked) with
/// no link to the agent actually running there, even though the Board/Notch HUD already track
/// exactly that per-tab (`Tab.agent`, `Tab.cwd`, `Tab.worktreePath`). This covers the matching
/// logic added to close that gap.
final class GitPanelViewWorktreeAgentTests: XCTestCase {
    func testMatchesByExactCwd() {
        let tab = Tab(cwd: "/repo/feature", agent: AgentSnapshot(kind: .claudeCode, executable: "claude", pid: 1, activity: .working))
        let result = GitPanelView.agentInfo(forWorktreePath: "/repo/feature", tabs: [tab])
        XCTAssertEqual(result?.kind, .claudeCode)
        XCTAssertEqual(result?.activity, .working)
    }

    func testMatchesByTrackedWorktreePathWhenCwdIsNested() {
        var tab = Tab(cwd: "/repo/feature/subdir", agent: AgentSnapshot(kind: .codex, executable: "codex", pid: 2, activity: .awaiting))
        tab.worktreePath = "/repo/feature"
        let result = GitPanelView.agentInfo(forWorktreePath: "/repo/feature", tabs: [tab])
        XCTAssertEqual(result?.kind, .codex)
        XCTAssertEqual(result?.activity, .awaiting)
    }

    func testNoMatchReturnsNil() {
        let tab = Tab(cwd: "/repo/other", agent: AgentSnapshot(kind: .gemini, executable: "gemini", pid: 3))
        XCTAssertNil(GitPanelView.agentInfo(forWorktreePath: "/repo/feature", tabs: [tab]))
    }

    func testTabWithoutAgentIsSkipped() {
        let tab = Tab(cwd: "/repo/feature", agent: nil)
        XCTAssertNil(GitPanelView.agentInfo(forWorktreePath: "/repo/feature", tabs: [tab]))
    }
}

/// Clicking a worktree card used to blind-sendKeys `cd <path>` to whatever surface happened to
/// be focused instead of navigating to the tab already tracking that worktree — this covers the
/// find-existing-tab matching `cdToWorktree` now uses (see GitPanelView.matchingTab).
final class GitPanelViewWorktreeNavigationTests: XCTestCase {
    func testMatchesTabByExactCwdAcrossWorkspaces() {
        let tab = Tab(cwd: "/repo/feature")
        let workspace = Workspace(sessions: [SessionGroup(tabs: [tab])])
        let result = GitPanelView.matchingTab(forPath: "/repo/feature", workspaces: [workspace])
        XCTAssertEqual(result?.workspaceID, workspace.id)
        XCTAssertEqual(result?.tabID, tab.id)
    }

    func testMatchesTabByTrackedWorktreePath() {
        var tab = Tab(cwd: "/repo/feature/subdir")
        tab.worktreePath = "/repo/feature"
        let workspace = Workspace(sessions: [SessionGroup(tabs: [tab])])
        let result = GitPanelView.matchingTab(forPath: "/repo/feature", workspaces: [workspace])
        XCTAssertEqual(result?.tabID, tab.id)
    }

    func testNoMatchingTabReturnsNil() {
        let workspace = Workspace(sessions: [SessionGroup(tabs: [Tab(cwd: "/repo/other")])])
        XCTAssertNil(GitPanelView.matchingTab(forPath: "/repo/feature", workspaces: [workspace]))
    }
}
