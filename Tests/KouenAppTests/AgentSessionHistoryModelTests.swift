import Foundation
@testable import KouenApp
import KouenCore
import KouenIPC
import XCTest

@MainActor
final class AgentSessionHistoryModelTests: XCTestCase {
    private func makeRecord(
        id: String,
        title: String,
        projectPath: String = "/Users/test/my-repo",
        projectName: String = "my-repo",
        gitBranch: String? = "main",
        updatedAt: Date = Date(),
        firstPrompt: String = "help me fix this",
        turns: [AgentHistoryTurn] = []
    ) -> AgentSessionRecord {
        AgentSessionRecord(
            id: id,
            agentKind: .claudeCode,
            title: title,
            projectPath: projectPath,
            projectName: projectName,
            gitBranch: gitBranch,
            modelName: "claude-sonnet-4-6",
            messageCount: 5,
            updatedAt: updatedAt,
            firstPrompt: firstPrompt,
            latestTurns: turns,
            transcriptPath: "/tmp/\(id).jsonl",
            worktreeAvailable: true
        )
    }

    func testDateGrouping() {
        let calendar = Calendar.current
        let now = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: now)!
        let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: now)!

        XCTAssertEqual(AgentHistoryDateGroup.group(for: now, relativeTo: now), .today)
        XCTAssertEqual(AgentHistoryDateGroup.group(for: yesterday, relativeTo: now), .yesterday)
        XCTAssertEqual(AgentHistoryDateGroup.group(for: threeDaysAgo, relativeTo: now), .thisWeek)
        XCTAssertEqual(AgentHistoryDateGroup.group(for: twoWeeksAgo, relativeTo: now), .older)
    }

    func testSearchQueryIgnoresScopeAndWindow() {
        let calendar = Calendar.current
        let now = Date()
        let oldDate = calendar.date(byAdding: .day, value: -30, to: now)!

        let r1 = makeRecord(id: "r1", title: "Build feature A", projectPath: "/repo/one", projectName: "one", updatedAt: now)
        let r2 = makeRecord(id: "r2", title: "Fix bug in older task", projectPath: "/repo/two", projectName: "two", updatedAt: oldDate)

        let model = AgentSessionHistoryModel()
        model.records = [r1, r2]
        model.selectedScope = .repo

        // Empty query with .repo scope filters out /repo/two if active repo doesn't match
        // But when searching for "older", it matches r2 regardless of scope AND 14-day cutoff
        model.searchQuery = "older"
        model.applyFilterNow()
        XCTAssertEqual(model.filteredRecords.count, 1)
        XCTAssertEqual(model.filteredRecords.first?.id, "r2")
        XCTAssertEqual(model.windowedRecords.count, 1)
        XCTAssertEqual(model.groupedRecords.first?.title, "Best matches")
        XCTAssertEqual(model.groupedRecords.first?.records.count, 1)
    }

    func testEmptyQueryGroupsByDate() {
        let calendar = Calendar.current
        let now = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!

        let r1 = makeRecord(id: "r1", title: "Task 1", updatedAt: now)
        let r2 = makeRecord(id: "r2", title: "Task 2", updatedAt: yesterday)

        let model = AgentSessionHistoryModel()
        model.records = [r1, r2]
        model.selectedScope = .all
        model.searchQuery = ""
        model.applyFilterNow()

        let groups = model.groupedRecords
        XCTAssertEqual(groups.count, 2)
        XCTAssertEqual(groups[0].title, "Today")
        XCTAssertEqual(groups[1].title, "Yesterday")
    }

    func testKeyboardSelectionMovement() {
        let r1 = makeRecord(id: "r1", title: "Task 1")
        let r2 = makeRecord(id: "r2", title: "Task 2")

        let model = AgentSessionHistoryModel()
        model.records = [r1, r2]
        model.selectedScope = .all
        model.applyFilterNow()

        XCTAssertEqual(model.selectedIndex, 0)
        model.moveSelection(by: 1)
        XCTAssertEqual(model.selectedIndex, 1)
        // Clamped at bottom
        model.moveSelection(by: 1)
        XCTAssertEqual(model.selectedIndex, 1)
        model.moveSelection(by: -1)
        XCTAssertEqual(model.selectedIndex, 0)
        // Clamped at top
        model.moveSelection(by: -1)
        XCTAssertEqual(model.selectedIndex, 0)
    }

    func testRepoRootResolutionNotCalledPerRender() {
        final class Counter: @unchecked Sendable {
            var count = 0
            let lock = NSLock()
            func increment() {
                lock.lock()
                defer { lock.unlock() }
                count += 1
            }
            func get() -> Int {
                lock.lock()
                defer { lock.unlock() }
                return count
            }
        }

        let counter = Counter()
        let resolver: @Sendable (String) -> String? = { path in
            counter.increment()
            return path
        }

        let r1 = makeRecord(id: "r1", title: "Task 1", projectPath: "/repo/one")
        let r2 = makeRecord(id: "r2", title: "Task 2", projectPath: "/repo/one")
        let r3 = makeRecord(id: "r3", title: "Task 3", projectPath: "/repo/two")

        let model = AgentSessionHistoryModel(
            repoRootResolver: resolver,
            activeCWDProvider: { "/repo/one" }
        )
        model.records = [r1, r2, r3]
        model.selectedScope = .repo
        model.applyFilterNow()

        let countAfterFilter = counter.get()
        // /repo/one (active) + /repo/one (r1, cached for r2) + /repo/two (r3) -> exactly 2 distinct paths resolved
        XCTAssertLessThanOrEqual(countAfterFilter, 3)

        // Reading computed render properties repeatedly (windowedRecords, hasMoreToLoad, displayRecords, groupedRecords)
        // MUST NOT invoke the resolver again!
        for _ in 0..<10 {
            _ = model.filteredRecords
            _ = model.windowedRecords
            _ = model.hasMoreToLoad
            _ = model.displayRecords
            _ = model.groupedRecords
            _ = model.selectedRecord
        }

        XCTAssertEqual(counter.get(), countAfterFilter, "Repo root resolver must never be called during render property evaluation")
    }

    func testDebounceProducesResultsAsynchronously() async {
        let r1 = makeRecord(id: "r1", title: "Refactor database engine")
        let r2 = makeRecord(id: "r2", title: "Update web styling")

        let model = AgentSessionHistoryModel()
        model.records = [r1, r2]
        model.selectedScope = .all

        // Type query - filteredRecords initially not updated synchronously
        model.searchQuery = "database"
        XCTAssertNotEqual(model.filteredRecords.map(\.id), ["r1"], "results must not be applied synchronously")

        // Poll for the debounced background result instead of a fixed sleep: the first search
        // opens the FTS database, which can take well over the debounce on a cold run.
        let deadline = Date().addingTimeInterval(5)
        while model.filteredRecords.map(\.id) != ["r1"], Date() < deadline {
            await Task.yield()
            try? await Task.sleep(nanoseconds: 10_000_000)
        }

        XCTAssertEqual(model.filteredRecords.count, 1)
        XCTAssertEqual(model.filteredRecords.first?.id, "r1")
    }

    func testGoToTabAmbiguityFallsBackToResume() {
        let sessionID = UUID()
        let tab1 = Tab(
            id: UUID(),
            title: "Claude Terminal 1",
            cwd: "/Users/test/my-repo",
            gitBranch: "main",
            listeningPorts: [],
            notificationText: nil,
            status: .idle,
            rootPane: .leaf(PaneLeaf()),
            sortOrder: 0,
            agent: AgentSnapshot(kind: .claudeCode, executable: "claude", pid: 101)
        )
        let tab2 = Tab(
            id: UUID(),
            title: "Claude Terminal 2",
            cwd: "/Users/test/my-repo",
            gitBranch: "main",
            listeningPorts: [],
            notificationText: nil,
            status: .idle,
            rootPane: .leaf(PaneLeaf()),
            sortOrder: 1,
            agent: AgentSnapshot(kind: .claudeCode, executable: "claude", pid: 102)
        )
        let session = SessionGroup(id: sessionID, name: "Dev", tabs: [tab1, tab2])
        let workspaceID = UUID()
        let workspace = Workspace(id: workspaceID, name: "Workspace", sessions: [session])
        let snapshot = SessionSnapshot(workspaces: [workspace], activeWorkspaceID: workspaceID)

        let record = makeRecord(id: "non-existent-session-id", title: "Work", projectPath: "/Users/test/my-repo")

        // Two tabs match cwd + agentKind -> ambiguous -> must return nil (fall back to resume)
        let resolved = KouenSidebarPanelViewController.resolveTargetTab(for: record, in: snapshot)
        XCTAssertNil(resolved, "Ambiguous tabs (multiple matching same cwd and agent kind) must return nil to trigger resume in a new tab")

        // Exact match by tab title containing session id succeeds unambiguously
        let exactRecord = makeRecord(id: "match-me-123", title: "Specific", projectPath: "/Users/test/my-repo")
        var tabWithID = tab1
        tabWithID.title = "Agent [match-me-123]"
        let snapshotWithExact = SessionSnapshot(workspaces: [Workspace(id: workspaceID, name: "W", sessions: [SessionGroup(id: sessionID, name: "S", tabs: [tabWithID, tab2])])])

        let exactResolved = KouenSidebarPanelViewController.resolveTargetTab(for: exactRecord, in: snapshotWithExact)
        XCTAssertNotNil(exactResolved)
        XCTAssertEqual(exactResolved.map(\.tabID), tabWithID.id)
    }
}
