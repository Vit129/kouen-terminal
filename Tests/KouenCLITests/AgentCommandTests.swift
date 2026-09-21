import XCTest
@testable import KouenCLI
import KouenCore
import KouenIPC

final class AgentCommandTests: XCTestCase {

    func testAgentListSerialization() throws {
        struct AgentEntry: Codable, Equatable {
            let tabID: String
            let surfaceID: String
            let agent: String
            let status: String
            let activity: String
            let prompt: String?
            let cwd: String
        }

        let entry = AgentEntry(
            tabID: UUID().uuidString,
            surfaceID: UUID().uuidString,
            agent: "Claude Code",
            status: "waiting",
            activity: "awaiting",
            prompt: "Allow tool execute_command?",
            cwd: "/Users/dev/repo"
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode([entry])

        let decoded = try JSONDecoder().decode([AgentEntry].self, from: data)
        XCTAssertEqual(decoded.count, 1)
        XCTAssertEqual(decoded.first?.agent, "Claude Code")
        XCTAssertEqual(decoded.first?.status, "waiting")
        XCTAssertEqual(decoded.first?.prompt, "Allow tool execute_command?")
    }

    func testAgentStatusFilterMatching() {
        let statuses = ["idle", "waiting", "running", "done", "error"]
        for s in statuses {
            let tabStatus = TabStatus(rawValue: s)
            XCTAssertNotNil(tabStatus)
            XCTAssertEqual(tabStatus?.rawValue, s)
        }
    }

    /// P46 Pillar 6 gap 4: `kouen agent send` used to silently pick "the first agent tab
    /// found" — with two agents running that's a coin flip on which one gets the file. An
    /// ambiguous target (no `--tab`/`--surface`, more than one agent) must resolve to nil
    /// (an error at the call site), never guess.
    func testResolveAgentTabRequiresExplicitTargetWhenMultipleAgentsRunning() {
        let agentA = Tab(title: "claude", agent: AgentSnapshot(kind: .claudeCode, executable: "/bin/claude", pid: 1, activity: .working))
        let agentB = Tab(title: "codex", agent: AgentSnapshot(kind: .codex, executable: "/bin/codex", pid: 2, activity: .working))
        let plain = Tab(title: "shell")
        let session = SessionGroup(id: UUID(), name: "s", tabs: [agentA, agentB, plain], activeTabID: agentA.id, sortOrder: 0)
        let ws = Workspace(id: UUID(), name: "W", sessions: [session], activeSessionID: session.id)
        let snap = SessionSnapshot(workspaces: [ws], activeWorkspaceID: ws.id)

        XCTAssertNil(KouenCLI.resolveAgentTab(in: snap, target: nil), "two agent tabs with no target must not silently pick one")

        let matched = KouenCLI.resolveAgentTab(in: snap, target: String(agentB.id.uuidString.prefix(8)))
        XCTAssertEqual(matched?.id, agentB.id, "an explicit --tab prefix must resolve the exact tab it names")
    }

    /// A single running agent still auto-resolves with no target — the ambiguity guard only
    /// kicks in once there's genuinely more than one candidate.
    func testResolveAgentTabAutoResolvesSingleAgent() {
        let agentA = Tab(title: "claude", agent: AgentSnapshot(kind: .claudeCode, executable: "/bin/claude", pid: 1, activity: .working))
        let plain = Tab(title: "shell")
        let session = SessionGroup(id: UUID(), name: "s", tabs: [agentA, plain], activeTabID: agentA.id, sortOrder: 0)
        let ws = Workspace(id: UUID(), name: "W", sessions: [session], activeSessionID: session.id)
        let snap = SessionSnapshot(workspaces: [ws], activeWorkspaceID: ws.id)

        XCTAssertEqual(KouenCLI.resolveAgentTab(in: snap, target: nil)?.id, agentA.id)
    }

    /// P46 Pillar 6 gap 4 follow-up: `--feature <slug>` targeting resolves to the tab bound to
    /// that feature's worktree — matching either `cwd` (the common case: a shell opened directly
    /// in the worktree) or the explicit `worktreePath` tag (set via `.newSession`'s
    /// `worktreePath:` — a linked/grouped tab whose own `cwd` may differ).
    func testMatchTabForWorktreePathMatchesCwdOrExplicitTag() {
        let byCwd = Tab(title: "by-cwd", cwd: "/repo/.kouen-worktrees/feat-a")
        let byTag = Tab(title: "by-tag", cwd: "/somewhere/else", worktreePath: "/repo/.kouen-worktrees/feat-b")
        let unrelated = Tab(title: "unrelated", cwd: "/repo")
        let session = SessionGroup(id: UUID(), name: "s", tabs: [byCwd, byTag, unrelated], activeTabID: byCwd.id, sortOrder: 0)
        let ws = Workspace(id: UUID(), name: "W", sessions: [session], activeSessionID: session.id)
        let snap = SessionSnapshot(workspaces: [ws], activeWorkspaceID: ws.id)

        XCTAssertEqual(KouenCLI.matchTab(forWorktreePath: "/repo/.kouen-worktrees/feat-a", in: snap)?.id, byCwd.id)
        XCTAssertEqual(KouenCLI.matchTab(forWorktreePath: "/repo/.kouen-worktrees/feat-b", in: snap)?.id, byTag.id)
        XCTAssertNil(KouenCLI.matchTab(forWorktreePath: "/repo/.kouen-worktrees/no-such-feature", in: snap))
    }
}
