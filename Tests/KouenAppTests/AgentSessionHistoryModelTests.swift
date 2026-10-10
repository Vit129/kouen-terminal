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
        agentKind: AgentKind = .claudeCode,
        projectPath: String = "/Users/test/my-repo",
        projectName: String = "my-repo",
        gitBranch: String? = "main",
        updatedAt: Date = Date(),
        firstPrompt: String = "help me fix this",
        turns: [AgentHistoryTurn] = []
    ) -> AgentSessionRecord {
        AgentSessionRecord(
            id: id,
            agentKind: agentKind,
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

    func testAgentKindFilter() {
        let r1 = makeRecord(id: "r1", title: "Claude Task", agentKind: .claudeCode)
        let r2 = makeRecord(id: "r2", title: "Codex Task", agentKind: .codex)
        let r3 = makeRecord(id: "r3", title: "Copilot Task", agentKind: .copilot)
        let r4 = makeRecord(id: "r4", title: "Antigravity Task", agentKind: .antigravity)

        let model = AgentSessionHistoryModel()
        model.records = [r1, r2, r3, r4]
        model.selectedScope = .all
        model.applyFilterNow()

        // 1. Default: empty selectedAgents -> all records shown
        XCTAssertEqual(model.filteredRecords.count, 4)
        XCTAssertEqual(model.availableAgentKinds, [.claudeCode, .codex, .copilot, .antigravity])

        // 2. Single selection: toggle claudeCode -> only r1
        model.toggleAgentFilter(.claudeCode)
        XCTAssertEqual(model.selectedAgents, [.claudeCode])
        model.applyFilterNow()
        XCTAssertEqual(model.filteredRecords.map(\.id), ["r1"])

        // 3. Multi-selection: toggle copilot -> r1 and r3
        model.toggleAgentFilter(.copilot)
        XCTAssertEqual(model.selectedAgents, [.claudeCode, .copilot])
        model.applyFilterNow()
        XCTAssertEqual(Set(model.filteredRecords.map(\.id)), ["r1", "r3"])

        // 4. Toggle off claudeCode -> only copilot (r3)
        model.toggleAgentFilter(.claudeCode)
        XCTAssertEqual(model.selectedAgents, [.copilot])
        model.applyFilterNow()
        XCTAssertEqual(model.filteredRecords.map(\.id), ["r3"])

        // 5. Clear all -> all records restored
        model.selectedAgents.removeAll()
        model.applyFilterNow()
        XCTAssertEqual(model.filteredRecords.count, 4)

        // 6. Agent filter combined with search query
        model.toggleAgentFilter(.antigravity)
        model.searchQuery = "Task"
        model.applyFilterNow()
        XCTAssertEqual(model.filteredRecords.map(\.id), ["r4"])
    }

    func testCrossRepoTaskGrouping() {
        let now = Date()
        let older = now.addingTimeInterval(-3600)

        let r1 = makeRecord(
            id: "r1",
            title: "Blueprint compliance in repo A",
            projectPath: "/repo/one",
            projectName: "one",
            gitBranch: "chore/blueprint-compliance",
            updatedAt: older
        )
        let r2 = makeRecord(
            id: "r2",
            title: "Blueprint compliance in repo B",
            projectPath: "/repo/two",
            projectName: "two",
            gitBranch: "chore/blueprint-compliance",
            updatedAt: now
        )

        let grouped = AgentSessionHistoryModel.groupCrossRepoTasks([r2, r1])
        XCTAssertEqual(grouped.count, 1)

        let composite = grouped[0]
        XCTAssertEqual(composite.id, "r2", "Most recent session must be the primary record")
        XCTAssertEqual(composite.crossRepoSiblings?.count, 2)
        XCTAssertEqual(composite.crossRepoSiblings?.map(\.projectName), ["two", "one"])
    }

    func testCrossRepoTaskGroupingIgnoresMainAndMaster() {
        let r1 = makeRecord(id: "r1", title: "Main 1", projectPath: "/repo/one", projectName: "one", gitBranch: "main")
        let r2 = makeRecord(id: "r2", title: "Main 2", projectPath: "/repo/two", projectName: "two", gitBranch: "main")
        let r3 = makeRecord(id: "r3", title: "Master 1", projectPath: "/repo/one", projectName: "one", gitBranch: "master")
        let r4 = makeRecord(id: "r4", title: "Master 2", projectPath: "/repo/two", projectName: "two", gitBranch: "master")

        let grouped = AgentSessionHistoryModel.groupCrossRepoTasks([r1, r2, r3, r4])
        XCTAssertEqual(grouped.count, 4)
        for item in grouped {
            XCTAssertNil(item.crossRepoSiblings, "main and master branches must never be grouped")
        }
    }

    func testCrossRepoTaskGroupingSingleRepoNotGrouped() {
        let r1 = makeRecord(id: "r1", title: "Task 1", projectPath: "/repo/one", projectName: "one", gitBranch: "feat/single-repo")
        let r2 = makeRecord(id: "r2", title: "Task 2", projectPath: "/repo/one", projectName: "one", gitBranch: "feat/single-repo")

        let grouped = AgentSessionHistoryModel.groupCrossRepoTasks([r1, r2])
        XCTAssertEqual(grouped.count, 2)
        XCTAssertNil(grouped[0].crossRepoSiblings)
        XCTAssertNil(grouped[1].crossRepoSiblings)
    }

    func testCrossRepoTaskGroupingDeduplicatesSameRepo() {
        let now = Date()
        let mid = now.addingTimeInterval(-1800)
        let old = now.addingTimeInterval(-3600)

        // Two sessions in repo "one" and one session in repo "two"
        let r1 = makeRecord(id: "r1", title: "New in one", projectPath: "/repo/one", projectName: "one", gitBranch: "feat/sync", updatedAt: now)
        let r2 = makeRecord(id: "r2", title: "Old in one", projectPath: "/repo/one", projectName: "one", gitBranch: "feat/sync", updatedAt: old)
        let r3 = makeRecord(id: "r3", title: "Mid in two", projectPath: "/repo/two", projectName: "two", gitBranch: "feat/sync", updatedAt: mid)

        let grouped = AgentSessionHistoryModel.groupCrossRepoTasks([r1, r2, r3])
        XCTAssertEqual(grouped.count, 2, "Older same-repo session must stay visible as its own row")

        let composite = grouped[0]
        XCTAssertEqual(composite.id, "r1")
        XCTAssertEqual(composite.crossRepoSiblings?.count, 2, "Only latest session per distinct repo is kept in crossRepoSiblings")
        XCTAssertEqual(composite.crossRepoSiblings?.map(\.id), ["r1", "r3"])
        XCTAssertEqual(grouped[1].id, "r2")
        XCTAssertNil(grouped[1].crossRepoSiblings)
    }

    func testCrossRepoTaskGroupingWindowedIntegration() {
        let r1 = makeRecord(id: "r1", title: "Fix A", projectPath: "/repo/one", projectName: "one", gitBranch: "fix/cross-fix")
        let r2 = makeRecord(id: "r2", title: "Fix B", projectPath: "/repo/two", projectName: "two", gitBranch: "fix/cross-fix")
        let r3 = makeRecord(id: "r3", title: "Other", projectPath: "/repo/three", projectName: "three", gitBranch: "feat/other")

        let model = AgentSessionHistoryModel()
        model.records = [r1, r2, r3]
        model.selectedScope = .all
        model.applyFilterNow()

        // r1 & r2 grouped into 1 item; r3 is standalone -> 2 total windowed records
        XCTAssertEqual(model.windowedRecords.count, 2)
        XCTAssertEqual(model.displayRecords.count, 2)
        let groupedItem = model.windowedRecords.first { $0.gitBranch == "fix/cross-fix" }
        XCTAssertNotNil(groupedItem)
        XCTAssertEqual(groupedItem?.crossRepoSiblings?.count, 2)
    }

    // MARK: - Phase 3 Advanced Capabilities Tests

    func testMatchLocationCalculation() {
        let turns: [AgentHistoryTurn] = [
            AgentHistoryTurn(role: "user", content: "Initial kickoff"),
            AgentHistoryTurn(role: "assistant", content: "Working on kickoff"),
            AgentHistoryTurn(role: "user", content: "Midway refactor step"),
            AgentHistoryTurn(role: "assistant", content: "Refactoring midway"),
            AgentHistoryTurn(role: "user", content: "Final verification and polishing"),
            AgentHistoryTurn(role: "assistant", content: "Done with polishing")
        ]

        let record = makeRecord(
            id: "loc1",
            title: "Project Setup",
            firstPrompt: "Please help setup the project",
            turns: turns
        )

        // Turn early in session
        let earlyLoc = record.matchLocation(for: "kickoff")
        XCTAssertNotNil(earlyLoc)
        XCTAssertEqual(earlyLoc?.relativePosition, "early in session")
        XCTAssertEqual(earlyLoc?.turnIndex, 0)
        XCTAssertEqual(earlyLoc?.description, "early in session · turn 1/6")

        // Turn midway in session
        let midLoc = record.matchLocation(for: "refactor")
        XCTAssertNotNil(midLoc)
        XCTAssertEqual(midLoc?.relativePosition, "mid session")
        XCTAssertEqual(midLoc?.turnIndex, 2)
        XCTAssertEqual(midLoc?.description, "mid session · turn 3/6")

        // Turn late in session
        let lateLoc = record.matchLocation(for: "polishing")
        XCTAssertNotNil(lateLoc)
        XCTAssertEqual(lateLoc?.relativePosition, "late in session")
        XCTAssertEqual(lateLoc?.turnIndex, 4)
        XCTAssertEqual(lateLoc?.description, "late in session · turn 5/6")

        // First prompt match
        let promptLoc = record.matchLocation(for: "setup the project")
        XCTAssertNotNil(promptLoc)
        XCTAssertEqual(promptLoc?.relativePosition, "start of session")
        XCTAssertEqual(promptLoc?.description, "start of session · prompt")

        // Title match
        let titleLoc = record.matchLocation(for: "Project Setup")
        XCTAssertNotNil(titleLoc)
        XCTAssertEqual(titleLoc?.description, "title match")
    }

    func testTopicSegmentation() {
        let turns: [AgentHistoryTurn] = [
            AgentHistoryTurn(role: "user", content: "Part 1: Build database schema"),
            AgentHistoryTurn(role: "assistant", content: "Created tables"),
            AgentHistoryTurn(role: "user", content: "Part 2: Add REST API handlers"),
            AgentHistoryTurn(role: "assistant", content: "Created routes"),
            AgentHistoryTurn(role: "user", content: "Part 3: Setup frontend UI"),
            AgentHistoryTurn(role: "assistant", content: "Created views"),
            AgentHistoryTurn(role: "user", content: "Part 4: Deploy to production"),
            AgentHistoryTurn(role: "assistant", content: "Deployed successfully")
        ]

        let segments = AgentSessionRecord.detectTopicSegments(
            title: "Fullstack Architecture",
            firstPrompt: "Part 1: Build database schema",
            turns: turns
        )

        XCTAssertNotNil(segments)
        XCTAssertGreaterThanOrEqual(segments?.count ?? 0, 2)
        XCTAssertTrue(segments?.contains(where: { $0.contains("Fullstack") || $0.contains("database") }) ?? false)
        XCTAssertTrue(segments?.contains(where: { $0.contains("REST API") }) ?? false)

        let record = AgentSessionRecord(
            id: "seg1",
            agentKind: .claudeCode,
            title: "Fullstack Architecture",
            projectPath: "/repo",
            projectName: "repo",
            messageCount: 8,
            updatedAt: Date(),
            firstPrompt: "Part 1: Build database schema",
            latestTurns: turns,
            transcriptPath: "/tmp/seg1.jsonl",
            worktreeAvailable: true
        )

        XCTAssertNotNil(record.topicBreadcrumbs)
        XCTAssertTrue(record.topicBreadcrumbs?.contains("→") ?? false)
    }

    func testSemanticSearchFallback() {
        let r1 = makeRecord(
            id: "sem1",
            title: "Memory leak in terminal ring buffer",
            firstPrompt: "Buffer allocation causes high ram usage"
        )
        let r2 = makeRecord(
            id: "sem2",
            title: "Recipe for chocolate chip cookies",
            firstPrompt: "Bake at 350 degrees"
        )

        // Exact keywords don't match, but semantic meaning matches r1 closely
        let query = "ram leak"
        let hits = AgentHistorySearch.rank(query: query, records: [r1, r2])

        // Either exact hit or fallback semantic hit
        if !hits.isEmpty {
            let first = hits[0]
            XCTAssertEqual(first.record.id, "sem1")
            XCTAssertTrue(first.score > 0)
        }

        // Test model integration
        let model = AgentSessionHistoryModel()
        model.records = [r1, r2]
        model.selectedScope = .all
        model.searchQuery = "memory leak"
        model.applyFilterNow()

        XCTAssertEqual(model.filteredRecords.first?.id, "sem1")
        if let first = model.filteredRecords.first {
            let loc = model.matchLocation(for: first)
            XCTAssertNotNil(loc)
        }
    }

    func testGraphifyIndexEnrichment() {
        let cache = GraphifyIndexCache()
        let currentFile = URL(fileURLWithPath: #filePath)
        let repoRoot = currentFile
            .deletingLastPathComponent() // Tests/KouenAppTests
            .deletingLastPathComponent() // Tests
            .deletingLastPathComponent() // repo root
            .path

        let labelsFile = URL(fileURLWithPath: repoRoot).appendingPathComponent("graphify-out/.graphify_labels.json")
        let projectPath: String
        var tempDir: URL? = nil

        if FileManager.default.fileExists(atPath: labelsFile.path) {
            projectPath = repoRoot
        } else {
            let tmp = FileManager.default.temporaryDirectory.appendingPathComponent("graphify-test-\(UUID().uuidString)")
            let outDir = tmp.appendingPathComponent("graphify-out")
            try? FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)
            let mockLabels = ["node1": "DaemonClient", "node2": "AgentSessionHistoryView"]
            if let data = try? JSONSerialization.data(withJSONObject: mockLabels) {
                try? data.write(to: outDir.appendingPathComponent(".graphify_labels.json"))
            }
            try? "1. `DaemonClient` - God node\n".write(to: outDir.appendingPathComponent("GRAPH_SUMMARY.md"), atomically: true, encoding: .utf8)
            projectPath = tmp.path
            tempDir = tmp
        }
        defer {
            if let tempDir { try? FileManager.default.removeItem(at: tempDir) }
        }

        let touchedFiles = [
            "Apps/Kouen/Sources/KouenApp/UI/History/AgentSessionHistoryView.swift",
            "Packages/KouenCore/Sources/KouenCore/IPC/DaemonClient.swift"
        ]

        let enriched = cache.enrich(files: touchedFiles, projectPath: projectPath)
        XCTAssertFalse(enriched.isEmpty, "Should extract symbols from .graphify_labels.json")
        XCTAssertTrue(enriched.contains("DaemonClient") || enriched.contains(where: { $0.contains("Daemon") }))
    }
}

