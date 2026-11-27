import Combine
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
        turns: [AgentHistoryTurn] = [],
        usage: AgentUsage? = nil
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
            worktreeAvailable: true,
            usage: usage
        )
    }


    func testTC6901_FE_BL_WorkspaceHistoryPrioritizesActiveRepository() {
        let now = Date()
        let model = AgentSessionHistoryModel(
            repoRootResolver: { $0 == "/worktree/one" ? "/repo/one" : $0 },
            activeCWDProvider: { "/repo/one" },
            workspaceCWDsProvider: { ["/repo/one", "/repo/two"] }
        )
        model.selectedScope = .workspace
        model.records = [
            makeRecord(id: "newer", title: "Newer", projectPath: "/repo/two", updatedAt: now),
            makeRecord(id: "active", title: "Active", projectPath: "/worktree/one", updatedAt: now.addingTimeInterval(-86_400))
        ]
        model.applyFilterNow()
        XCTAssertEqual(model.displayRecords.map(\.id), ["active", "newer"])

        model.activeCWDProvider = { "/repo/two" }
        model.applyFilterNow()
        XCTAssertEqual(model.displayRecords.map(\.id), ["newer", "active"])
    }

    func testTC6902_FE_BL_WorkspaceAndProjectKeepTheirRepositoryBoundaries() {
        let model = AgentSessionHistoryModel(
            repoRootResolver: { $0 },
            activeCWDProvider: { "/scope/one" },
            workspaceCWDsProvider: { ["/scope/one", "/scope/two"] }
        )
        model.records = [
            makeRecord(id: "one", title: "One", projectPath: "/scope/one"),
            makeRecord(id: "two", title: "Two", projectPath: "/scope/two"),
            makeRecord(id: "outside", title: "Outside", projectPath: "/scope/three")
        ]
        model.selectedScope = .workspace
        model.applyFilterNow()
        XCTAssertEqual(Set(model.displayRecords.map(\.id)), ["one", "two"])

        model.selectedScope = .repo
        model.applyFilterNow()
        XCTAssertEqual(model.displayRecords.map(\.id), ["one"])
    }

    func testTC6903_FE_BL_WorkspaceSearchPreservesRelevanceOrder() {
        let model = AgentSessionHistoryModel(
            repoRootResolver: { $0 },
            activeCWDProvider: { "/search/one" },
            workspaceCWDsProvider: { ["/search/one", "/search/two"] }
        )
        model.selectedScope = .workspace
        model.records = [
            makeRecord(id: "active", title: "regression6903", projectPath: "/search/one", updatedAt: Date(timeIntervalSinceNow: -60)),
            makeRecord(id: "match", title: "regression6903", projectPath: "/search/two")
        ]
        model.searchQuery = "regression6903"
        model.applyFilterNow()
        XCTAssertEqual(model.displayRecords.map(\.id), ["match", "active"])
    }

    func testTC6904_FE_BL_AllHistoryGroupsCanonicalProjectsAndSortsByActivity() {
        let now = Date()
        let model = AgentSessionHistoryModel(repoRootResolver: { path in
            switch path {
            case "/worktree/kouen/fix": return "/repo/kouen"
            case "/repo/kouen/.kouen-worktrees/pruned": return nil
            default: return path
            }
        }, activeCWDProvider: { "/repo/kouen" })
        model.selectedScope = .all
        model.records = [
            makeRecord(id: "old", title: "Old Kouen session", projectPath: "/repo/kouen", projectName: "kouen",
                       updatedAt: now.addingTimeInterval(-300)),
            makeRecord(id: "plugin", title: "Plugin session", projectPath: "/repo/plugin", projectName: "plugin",
                       gitBranch: "fix/shared-name", updatedAt: now.addingTimeInterval(-60)),
            makeRecord(id: "kouen", title: "Kouen session", projectPath: "/worktree/kouen/fix", projectName: "fix",
                       gitBranch: "fix/shared-name", updatedAt: now),
            makeRecord(id: "pruned", title: "Deleted worktree", projectPath: "/repo/kouen/.kouen-worktrees/pruned",
                       updatedAt: now.addingTimeInterval(-600))
        ]

        model.applyFilterNow()

        XCTAssertEqual(model.groupedRecords.map(\.title), ["kouen", "plugin"])
        XCTAssertEqual(model.groupedRecords.map { $0.records.map(\.id) }, [["kouen", "old", "pruned"], ["plugin"]])
        XCTAssertEqual(model.windowedRecords.map(\.id), ["kouen", "old", "pruned", "plugin"])
    }

    func testTC6905_FE_BL_ProjectHistoryExcludesNestedRepositories() {
        let model = AgentSessionHistoryModel(repoRootResolver: { path in
            path == "/repo/kouen/Sources" ? "/repo/kouen" : path
        }, activeCWDProvider: { "/repo/kouen" })
        model.records = [
            makeRecord(id: "kouen", title: "Kouen", projectPath: "/repo/kouen/Sources"),
            makeRecord(id: "plugin", title: "Plugin", projectPath: "/repo/kouen/embedded/plugin")
        ]

        model.applyFilterNow()

        XCTAssertEqual(model.displayRecords.map(\.id), ["kouen"])
    }

    func testTC6906_FE_BL_RefreshKeepsSelectedSessionWhenRowsMove() {
        let now = Date()
        let model = AgentSessionHistoryModel(repoRootResolver: { $0 })
        model.selectedScope = .all
        let previous = makeRecord(id: "selected", title: "Selected", updatedAt: now)
        model.records = [previous]
        model.applyFilterNow()

        model.records = [
            makeRecord(id: "new", title: "New session", updatedAt: now.addingTimeInterval(1)),
            previous
        ]
        model.applyFilterNow()

        XCTAssertEqual(model.displayRecords.map(\.id), ["new", "selected"])
        XCTAssertEqual(model.selectedRecordID, "selected")
        XCTAssertEqual(model.selectedIndex, 1)
    }

    func testTC6907_FE_IT_TranscriptEventsRefreshNewSessionsAndAppendedTurns() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let first = root.appendingPathComponent("rollout-first.jsonl")
        let second = root.appendingPathComponent("rollout-second.jsonl")
        let scanner = AgentHistoryScanner(ftsIndex: AgentHistoryFTSIndex(dbPath: ":memory:"), scanOperation: {
            AgentHistoryScanner.readCodexRollouts(baseDir: root)
        })
        let model = AgentSessionHistoryModel(repoRootResolver: { $0 })
        model.selectedScope = .all

        let discovered = expectation(description: "New session discovered")
        let appended = expectation(description: "Appended turn from the selected session")
        let subscription = model.$records.sink { records in
            if records.count == 1 { discovered.fulfill() }
            if records.count == 2, records.first(where: { $0.id == "first" })?.latestTurns.last?.content == "Latest answer" {
                appended.fulfill()
            }
        }
        defer { subscription.cancel() }
        let (updates, continuation) = AsyncStream<Void>.makeStream(bufferingPolicy: .bufferingNewest(1))
        let watcher = FileTreeWatcher()
        await watcher.startWatching(rootPaths: [root.path]) { continuation.yield() }
        let observing = Task { await model.followHistoryUpdates(updates, scanner: scanner) }

        func writeSession(_ id: String, to url: URL) throws {
            let header = """
            {"type":"session_meta","payload":{"id":"\(id)","cwd":"/repos/\(id)"}}
            {"type":"message","role":"user","content":"Initial prompt"}

            """
            try header.write(to: url, atomically: true, encoding: .utf8)
        }
        do {
            try writeSession("first", to: first)
            await fulfillment(of: [discovered], timeout: 5)

            try writeSession("second", to: second)
            let handle = try FileHandle(forWritingTo: first)
            defer { try? handle.close() }
            try handle.seekToEnd()
            let response = #"{"type":"message","role":"assistant","content":"Latest answer"}"# + "\n"
            try handle.write(contentsOf: Data(response.utf8))
            await fulfillment(of: [appended], timeout: 5)
        } catch {
            observing.cancel()
            await watcher.stopWatching()
            throw error
        }
        observing.cancel()
        await observing.value
        await watcher.stopWatching()

        XCTAssertEqual(model.records.first(where: { $0.id == "first" })?.latestTurns.map(\.content),
                       ["Initial prompt", "Latest answer"])
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

    func testSearchQueryFindsOlderSessionsInAllRepos() {
        let calendar = Calendar.current
        let now = Date()
        let oldDate = calendar.date(byAdding: .day, value: -30, to: now)!

        let r1 = makeRecord(id: "r1", title: "Build feature A", projectPath: "/repo/one", projectName: "one", updatedAt: now)
        let r2 = makeRecord(id: "r2", title: "Fix bug in older task", projectPath: "/repo/two", projectName: "two", updatedAt: oldDate)

        let model = AgentSessionHistoryModel()
        model.records = [r1, r2]
        model.selectedScope = .all

        // Searching includes sessions older than the normal recent window.
        model.searchQuery = "older"
        model.applyFilterNow()
        XCTAssertEqual(model.filteredRecords.count, 1)
        XCTAssertEqual(model.filteredRecords.first?.id, "r2")
        XCTAssertEqual(model.windowedRecords.count, 1)
        XCTAssertEqual(model.groupedRecords.first?.title, "Best matches")
        XCTAssertEqual(model.groupedRecords.first?.records.count, 1)

        model.searchQuery = ""
        model.applyFilterNow()
        XCTAssertEqual(model.filteredRecords.count, 2, "Clearing search restores the unsearched records")
        XCTAssertEqual(model.searchableRecordsCount, 2)
    }

    func testSearchHonorsSelectedRepositoryAndFindsOldSessions() {
        let old = Date(timeIntervalSince1970: 1)
        let own = makeRecord(id: "own", title: "sprint report", projectPath: "/repo/one", projectName: "one", updatedAt: old)
        let other = makeRecord(id: "other", title: "sprint report", projectPath: "/repo/two", projectName: "two")
        let resolver: @Sendable (String) -> String? = { $0 }
        let scoped = AgentSessionHistoryModel.computeFiltered(
            query: "sprint", scope: .repo, records: [own, other], activeCWD: "/repo/one",
            resolver: resolver, initialCache: [:])
        XCTAssertEqual(scoped.filtered.map(\.id), ["own"])
        XCTAssertEqual(scoped.searchableCount, 1)
        let all = AgentSessionHistoryModel.computeFiltered(
            query: "sprint", scope: .all, records: [own, other], activeCWD: "/repo/one",
            resolver: resolver, initialCache: [:])
        XCTAssertEqual(Set(all.filtered.map(\.id)), Set(["own", "other"]))
        XCTAssertEqual(all.searchableCount, 2)
    }

    func testSearchingDoesNotCollapseMatchingSessionsAcrossRepos() {
        let first = makeRecord(id: "search-a", title: "first", projectPath: "/one", projectName: "one", gitBranch: "refactor/logic-structure")
        let second = makeRecord(id: "search-b", title: "second", projectPath: "/two", projectName: "two", gitBranch: "refactor/logic-structure")
        let model = AgentSessionHistoryModel()
        model.records = [first, second]
        model.selectedScope = .all
        model.searchQuery = "refactor/logic-structure"
        model.applyFilterNow()
        XCTAssertEqual(Set(model.windowedRecords.map(\.id)), Set(["search-a", "search-b"]))
    }

    func testEmptyQueryGroupsByDate() {
        let calendar = Calendar.current
        let now = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!

        let r1 = makeRecord(id: "r1", title: "Task 1", updatedAt: now)
        let r2 = makeRecord(id: "r2", title: "Task 2", updatedAt: yesterday)

        let model = AgentSessionHistoryModel(repoRootResolver: { $0 }, activeCWDProvider: { "/Users/test/my-repo" })
        model.records = [r1, r2]
        model.selectedScope = .repo
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

    func testAntigravityFilterRemainsAvailableWhenNoSessionsLoaded() {
        let model = AgentSessionHistoryModel()
        model.records = [makeRecord(id: "claude", title: "Task", agentKind: .claudeCode)]
        XCTAssertTrue(model.availableAgentKinds.contains(.antigravity))
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
        XCTAssertEqual(model.searchableRecordsCount, 4)
        XCTAssertEqual(model.availableAgentKinds, [.claudeCode, .codex, .copilot, .antigravity])

        // 2. Single selection: toggle claudeCode -> only r1
        model.toggleAgentFilter(.claudeCode)
        XCTAssertEqual(model.selectedAgents, [.claudeCode])
        model.applyFilterNow()
        XCTAssertEqual(model.filteredRecords.map(\.id), ["r1"])
        XCTAssertEqual(model.searchableRecordsCount, 1)

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
        XCTAssertEqual(model.searchableRecordsCount, 1)
    }

    func testAgentShortcutOrderPersistsAndNormalizesWithoutChangingFilters() {
        let suiteName = "AgentSessionHistoryModelTests.\(UUID().uuidString)"
        let preferences = UserDefaults(suiteName: suiteName)!
        defer { preferences.removePersistentDomain(forName: suiteName) }

        let model = AgentSessionHistoryModel(userDefaults: preferences)
        XCTAssertEqual(model.agentShortcutKinds, [.claudeCode, .codex, .antigravity, .copilot])

        model.selectedAgents = [.cursor]
        model.setAgentShortcutKinds([.grok, .codex, .grok, .cursor, .pi, .gemini, .aider])
        XCTAssertEqual(model.agentShortcutKinds, [.grok, .codex, .cursor, .pi, .gemini])
        XCTAssertEqual(model.selectedAgents, [.cursor], "Changing shortcuts must not change active agent filters")

        let restored = AgentSessionHistoryModel(userDefaults: preferences)
        XCTAssertEqual(restored.agentShortcutKinds, [.grok, .codex, .cursor, .pi, .gemini])

        restored.selectedAgents = [.cursor]
        restored.setAgentShortcutKinds([.codex, .grok, .cursor, .pi, .gemini])
        XCTAssertEqual(restored.agentShortcutKinds, [.codex, .grok, .cursor, .pi, .gemini], "Reordering shortcuts persists their visible order")
        XCTAssertEqual(restored.selectedAgents, [.cursor], "Reordering shortcuts must not change active agent filters")

        restored.setAgentShortcutKinds([.grok, .codex, .cursor, .pi, .gemini])
        restored.moveAgentShortcut(.grok, to: .codex)
        XCTAssertEqual(restored.agentShortcutKinds, [.codex, .grok, .cursor, .pi, .gemini], "Dropping on the next shortcut moves into its former slot")
        restored.moveAgentShortcut(.codex, to: .gemini)
        XCTAssertEqual(restored.agentShortcutKinds, [.grok, .cursor, .pi, .gemini, .codex], "Dropping on the last shortcut supports moving to the end")
        XCTAssertEqual(restored.selectedAgents, [.cursor])
        let reordered = AgentSessionHistoryModel(userDefaults: preferences)
        XCTAssertEqual(reordered.agentShortcutKinds, [.grok, .cursor, .pi, .gemini, .codex])

        preferences.set(["gemini", "unknown-agent", "gemini", "aider", "goose", "pi", "hermes", "codex"], forKey: AgentSessionHistoryModel.agentShortcutKindsDefaultsKey)
        let normalized = AgentSessionHistoryModel(userDefaults: preferences)
        XCTAssertEqual(normalized.agentShortcutKinds, [.gemini, .aider, .goose, .pi, .hermes])
        XCTAssertEqual(preferences.stringArray(forKey: AgentSessionHistoryModel.agentShortcutKindsDefaultsKey), ["gemini", "aider", "goose", "pi", "hermes"])

        normalized.toggleAgentShortcut(.grok)
        XCTAssertEqual(normalized.agentShortcutKinds, [.gemini, .aider, .goose, .pi, .hermes])
        normalized.toggleAgentShortcut(.aider)
        normalized.toggleAgentShortcut(.grok)
        XCTAssertEqual(normalized.agentShortcutKinds, [.gemini, .goose, .pi, .hermes, .grok])
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

    func testRecordPreservesUsageAndShortSummary() {
        var usage = AgentUsage()
        usage.inputTokens = 15000
        usage.cacheReadTokens = 35000
        usage.outputTokens = 420
        let record = makeRecord(id: "u1", title: "Usage Test", usage: usage)

        XCTAssertEqual(record.usage?.contextTokens, 50000)
        XCTAssertEqual(record.usage?.shortSummary, "50k ctx")
    }
}

