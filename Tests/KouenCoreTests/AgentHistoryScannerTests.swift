import Foundation
@testable import KouenCore
import KouenIPC
import XCTest
#if canImport(SQLite3)
import SQLite3
#endif

final class AgentHistoryScannerTests: XCTestCase {
    func testScanAllReturnsRecords() async {
        let tempDBPath = FileManager.default.temporaryDirectory
            .appendingPathComponent("test_agent_history_\(UUID().uuidString).sqlite").path
        defer {
            try? FileManager.default.removeItem(atPath: tempDBPath)
            try? FileManager.default.removeItem(atPath: tempDBPath + "-shm")
            try? FileManager.default.removeItem(atPath: tempDBPath + "-wal")
        }
        let fts = AgentHistoryFTSIndex(dbPath: tempDBPath)
        let scanner = AgentHistoryScanner(ftsIndex: fts)
        let records = await scanner.scanAll()
        // Scanner successfully runs and produces an array without crashing or throwing
        XCTAssertNotNil(records)
    }

    func testAgentSessionRecordProperties() {
        let record = AgentSessionRecord(
            id: "test-session-123",
            agentKind: .claudeCode,
            title: "Refactor auth pipeline",
            projectPath: "/Users/test/repo",
            projectName: "repo",
            gitBranch: "feat/auth",
            modelName: "claude-sonnet-4-6",
            messageCount: 14,
            updatedAt: Date(),
            firstPrompt: "Please refactor the auth service",
            latestTurns: [
                AgentHistoryTurn(role: "YOU", content: "Check tests"),
                AgentHistoryTurn(role: "AGENT", content: "Tests passing"),
            ],
            transcriptPath: "/tmp/transcript.jsonl",
            worktreeAvailable: false
        )

        XCTAssertEqual(record.id, "test-session-123")
        XCTAssertEqual(record.agentKind, .claudeCode)
        XCTAssertEqual(record.title, "Refactor auth pipeline")
        XCTAssertEqual(record.projectName, "repo")
        XCTAssertEqual(record.gitBranch, "feat/auth")
        XCTAssertEqual(record.messageCount, 14)
        XCTAssertEqual(record.latestTurns.count, 2)
        XCTAssertEqual(record.latestTurns[0].role, "YOU")
        XCTAssertEqual(record.placement, .local)
        XCTAssertNil(record.liveStatus)
        XCTAssertNil(record.resumeCommandOverride)
    }

    // MARK: - Live Claude agents ("claude agents --json") merge

    private func makeRecord(id: String = "abc123", updatedAt: Date = Date()) -> AgentSessionRecord {
        AgentSessionRecord(
            id: id, agentKind: .claudeCode, title: "t", projectPath: "/tmp/repo", projectName: "repo",
            messageCount: 3, updatedAt: updatedAt, firstPrompt: "hi", transcriptPath: "/tmp/t.jsonl",
            worktreeAvailable: true
        )
    }

    func testParseLiveAgentsJSONParsesAllKinds() {
        let json = """
        [
          {"pid":102,"cwd":"/tmp/a","kind":"interactive","startedAt":1700000000000,"sessionId":"s1","name":"n1","status":"busy"},
          {"cwd":"/tmp/b","kind":"cloud","sessionId":"s2","name":"n2","status":"idle"},
          {"kind":"background","sessionId":"s3"}
        ]
        """.data(using: .utf8)!
        let entries = AgentHistoryScanner.parseLiveAgentsJSON(json)
        XCTAssertEqual(entries.count, 3)
        XCTAssertEqual(entries[0].placement, nil) // "interactive" — already covered by transcript scan
        XCTAssertEqual(entries[1].placement, .cloud)
        XCTAssertEqual(entries[1].cwd, "/tmp/b")
        XCTAssertEqual(entries[2].placement, .background)
        XCTAssertNil(entries[2].cwd)
    }

    func testParseLiveAgentsJSONIgnoresMalformedRows() {
        let json = """
        [{"kind":"cloud"}, {"sessionId":"s1"}, "not an object", 42]
        """.data(using: .utf8)!
        XCTAssertEqual(AgentHistoryScanner.parseLiveAgentsJSON(json).count, 0)
    }

    func testParseLiveAgentsJSONGarbageReturnsEmpty() {
        XCTAssertEqual(AgentHistoryScanner.parseLiveAgentsJSON(Data("not json".utf8)).count, 0)
    }

    func testMergeLivePlacementsEnrichesExistingRecordByID() {
        let local = makeRecord(id: "abc123")
        let live = LiveClaudeAgentEntry(sessionId: "abc123", kind: "cloud", cwd: nil, name: nil, status: "busy", startedAt: nil)
        let merged = AgentHistoryScanner.mergeLivePlacements([local], live: [live])
        XCTAssertEqual(merged.count, 1)
        XCTAssertEqual(merged[0].placement, .cloud)
        XCTAssertEqual(merged[0].liveStatus, "busy")
        XCTAssertEqual(merged[0].resumeCommandOverride, "claude --teleport abc123")
        // Enrichment must not touch unrelated fields.
        XCTAssertEqual(merged[0].title, local.title)
        XCTAssertEqual(merged[0].messageCount, local.messageCount)
    }

    func testMergeLivePlacementsAddsSyntheticRecordForUnmatchedCloudSession() {
        let local = makeRecord(id: "other-session")
        let live = LiveClaudeAgentEntry(
            sessionId: "cloud-only", kind: "cloud", cwd: "/tmp/cloud-repo", name: "My cloud task",
            status: "idle", startedAt: Date(timeIntervalSince1970: 1_700_000_000)
        )
        let merged = AgentHistoryScanner.mergeLivePlacements([local], live: [live])
        XCTAssertEqual(merged.count, 2)
        let synthetic = merged.first { $0.id == "cloud-only" }
        XCTAssertNotNil(synthetic)
        XCTAssertEqual(synthetic?.placement, .cloud)
        XCTAssertEqual(synthetic?.title, "My cloud task")
        XCTAssertEqual(synthetic?.projectPath, "/tmp/cloud-repo")
        XCTAssertEqual(synthetic?.transcriptPath, "cloud://cloud-only")
        XCTAssertEqual(synthetic?.resumeCommandOverride, "claude --teleport cloud-only")
    }

    func testMergeLivePlacementsSkipsInteractiveKind() {
        let local = makeRecord(id: "abc123")
        let live = LiveClaudeAgentEntry(sessionId: "abc123", kind: "interactive", cwd: nil, name: nil, status: "busy", startedAt: nil)
        let merged = AgentHistoryScanner.mergeLivePlacements([local], live: [live])
        XCTAssertEqual(merged.count, 1)
        XCTAssertEqual(merged[0].placement, .local)
        XCTAssertNil(merged[0].resumeCommandOverride)
    }

    func testMergeLivePlacementsNoOpWhenLiveEmpty() {
        let local = makeRecord()
        XCTAssertEqual(AgentHistoryScanner.mergeLivePlacements([local], live: []).count, 1)
    }

    func testResumeOverridePerPlacement() {
        XCTAssertEqual(
            LiveClaudeAgentEntry(sessionId: "s", kind: "cloud", cwd: nil, name: nil, status: nil, startedAt: nil)
                .makeSyntheticRecord(placement: .cloud).resumeCommandOverride,
            "claude --teleport s"
        )
        XCTAssertEqual(
            LiveClaudeAgentEntry(sessionId: "s", kind: "background", cwd: nil, name: nil, status: nil, startedAt: nil)
                .makeSyntheticRecord(placement: .background).resumeCommandOverride,
            "claude attach s"
        )
        XCTAssertNil(
            LiveClaudeAgentEntry(sessionId: "s", kind: "remote-control", cwd: nil, name: nil, status: nil, startedAt: nil)
                .makeSyntheticRecord(placement: .remoteControl).resumeCommandOverride
        )
    }

    func testEffectiveResumeCommandPrefersOverride() {
        let record = makeRecord().withLivePlacement(.cloud, status: "busy")
        XCTAssertEqual(record.effectiveResumeCommand(claudeMode: .remoteControl), "claude --teleport abc123")
    }

    func testEffectiveResumeCommandFallsBackToAgentKindWhenLocal() {
        let record = makeRecord()
        XCTAssertEqual(record.effectiveResumeCommand(claudeMode: .cloud), record.agentKind.resumeCommand(sessionID: record.id, claudeMode: .cloud))
    }

    // MARK: - Remembered cloud sessions

    private func withStore(_ body: (ClaudeCloudSessionStore) throws -> Void) rethrows {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("kouen-cloud-store-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }
        try body(ClaudeCloudSessionStore(fileURL: url))
    }

    private func liveRow(_ id: String, kind: String = "cloud", cwd: String? = "/tmp/repo") -> LiveClaudeAgentEntry {
        LiveClaudeAgentEntry(sessionId: id, kind: kind, cwd: cwd, name: "task \(id)", status: "busy", startedAt: nil)
    }

    func testStoreRemembersOnlyCloudRowsAndPersists() {
        withStore { store in
            store.remember([liveRow("c1"), liveRow("i1", kind: "interactive"), liveRow("r1", kind: "remote-control")])
            XCTAssertEqual(store.load().map(\.sessionId), ["c1"])
            // A fresh store on the same file sees it — it's on disk, not just in memory.
            XCTAssertEqual(ClaudeCloudSessionStore(fileURL: store.fileURL).load().map(\.sessionId), ["c1"])
        }
    }

    func testStoreKeepsSessionAfterItLeavesTheLiveScan() {
        withStore { store in
            store.remember([liveRow("c1")])
            let remembered = store.remember([])   // pane closed: no longer live
            let offline = ClaudeCloudSessionStore.offlineRows(remembered, excluding: [])
            XCTAssertEqual(offline.map(\.sessionId), ["c1"])
            XCTAssertEqual(offline.first?.placement, .cloud)
            XCTAssertNil(offline.first?.status, "offline rows carry no live status")
            XCTAssertEqual(offline.first?.cwd, "/tmp/repo")
        }
    }

    func testOfflineRowsSkipSessionsThatAreLive() {
        withStore { store in
            let live = [liveRow("c1")]
            let remembered = store.remember(live)
            XCTAssertTrue(ClaudeCloudSessionStore.offlineRows(remembered, excluding: live).isEmpty)
        }
    }

    func testStorePrunesEntriesOlderThanMaxAge() {
        withStore { store in
            let long = Date(timeIntervalSinceNow: -(ClaudeCloudSessionStore.maxAge + 60))
            store.remember([liveRow("old")], now: long)
            XCTAssertTrue(store.remember([]).isEmpty)
        }
    }

    func testRememberedCloudSessionShowsUpInMergedHistory() {
        withStore { store in
            store.remember([liveRow("c1")])
            let rows = ClaudeCloudSessionStore.offlineRows(store.remember([]), excluding: [])
            let merged = AgentHistoryScanner.mergeLivePlacements([makeRecord(id: "local")], live: rows)
            let cloud = merged.first { $0.id == "c1" }
            XCTAssertEqual(cloud?.placement, .cloud)
            XCTAssertEqual(cloud?.resumeCommandOverride, "claude --teleport c1")
        }
    }

    // MARK: - SQLite FTS5 Full-Transcript Index & Incremental Re-index (Slice C)

    func testFTSIndexIncrementalReindexChecksMtimeAndSize() {
        let tempDB = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test_fts_\(UUID().uuidString).sqlite")
        defer { try? FileManager.default.removeItem(at: tempDB) }

        let index = AgentHistoryFTSIndex(dbPath: tempDB.path)
        let initialDate = Date(timeIntervalSince1970: 1700000000)
        let initialSize = 2048

        // Initially not in DB, needs re-index
        XCTAssertTrue(index.needsReindex(sessionID: "sess-1", mtime: initialDate, fileSize: initialSize))

        // Index session
        index.indexSession(
            sessionID: "sess-1",
            title: "Optimize network protocol",
            firstPrompt: "Please optimize network protocol",
            fullTranscript: "Turn 1: analyzing network buffers\nTurn 2: improved throughput by 40%",
            gitBranch: "perf/network",
            repoName: "kouen-terminal",
            agentName: "Claude",
            filesEdited: "NetworkOptimizer.swift BufferPool.swift",
            toolsCalled: "Edit Read Bash",
            transcriptPath: "/tmp/sess-1.jsonl",
            mtime: initialDate,
            fileSize: initialSize
        )

        // Same mtime and fileSize -> does NOT need re-index
        XCTAssertFalse(index.needsReindex(sessionID: "sess-1", mtime: initialDate, fileSize: initialSize))

        // Modified mtime -> needs re-index
        let newDate = initialDate.addingTimeInterval(30)
        XCTAssertTrue(index.needsReindex(sessionID: "sess-1", mtime: newDate, fileSize: initialSize))

        // Modified fileSize -> needs re-index
        XCTAssertTrue(index.needsReindex(sessionID: "sess-1", mtime: initialDate, fileSize: 4096))
    }

    func testFTSIndexMatchesDeepInLongTranscriptBeyondLast60Lines() {
        let tempDB = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test_fts_deep_\(UUID().uuidString).sqlite")
        defer { try? FileManager.default.removeItem(at: tempDB) }

        let index = AgentHistoryFTSIndex(dbPath: tempDB.path)

        // Build a simulated long transcript where the special keyword appears ONLY
        // in turn 15, and subsequent 80 turns are generic conversation
        var transcriptLines: [String] = []
        transcriptLines.append("Starting session on database migration.")
        transcriptLines.append("Deep needle keyword: quantumTeleportationProtocol")
        for i in 1...80 {
            transcriptLines.append("Turn \(i): Discussing standard database indexes and caching layers.")
        }
        let fullTranscript = transcriptLines.joined(separator: "\n")

        index.indexSession(
            sessionID: "long-session-42",
            title: "Database index tuning",
            firstPrompt: "Tune database indexes",
            fullTranscript: fullTranscript,
            gitBranch: "main",
            repoName: "database-core",
            agentName: "Claude",
            filesEdited: "IndexTuner.swift",
            toolsCalled: "Edit Read",
            transcriptPath: "/tmp/long-session-42.jsonl",
            mtime: Date(),
            fileSize: fullTranscript.utf8.count
        )

        // Search for the deep keyword that is beyond the last 60 lines
        let hits = index.search(query: "quantumTeleportationProtocol")
        XCTAssertEqual(hits.count, 1)
        XCTAssertNotNil(hits["long-session-42"])
        XCTAssertEqual(hits["long-session-42"]?.sessionID, "long-session-42")
        XCTAssertTrue(hits["long-session-42"]?.snippet.contains("quantumTeleportationProtocol") == true)
        XCTAssertEqual(hits["long-session-42"]?.filesEdited, "IndexTuner.swift")
        XCTAssertEqual(hits["long-session-42"]?.toolsCalled, "Edit Read")
    }

    func testFTSIndexRespectsLimit() {
        let tempDB = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test_fts_limit_\(UUID().uuidString).sqlite")
        defer { try? FileManager.default.removeItem(at: tempDB) }

        let index = AgentHistoryFTSIndex(dbPath: tempDB.path)

        for i in 1...10 {
            index.indexSession(
                sessionID: "sess-\(i)",
                title: "Session \(i)",
                firstPrompt: "prompt \(i)",
                fullTranscript: "debugging issue number \(i) with commonSearchTerm",
                gitBranch: "main",
                repoName: "test-repo",
                agentName: "Claude",
                filesEdited: "File\(i).swift",
                toolsCalled: "Bash",
                transcriptPath: "/tmp/sess-\(i).jsonl",
                mtime: Date(),
                fileSize: 100
            )
        }

        let hitsLimit3 = index.search(query: "commonSearchTerm", limit: 3)
        XCTAssertEqual(hitsLimit3.count, 3)

        let hitsLimit5 = index.search(query: "commonSearchTerm", limit: 5)
        XCTAssertEqual(hitsLimit5.count, 5)
    }

    // MARK: - Regression Tests for Defects 1-4

    func testGhostSessionsPrunedWhenTranscriptDeletedOnDisk() {
        let tempDB = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test_prune_\(UUID().uuidString).sqlite")
        let tempTranscript = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test_transcript_\(UUID().uuidString).jsonl")
        defer {
            try? FileManager.default.removeItem(at: tempDB)
            try? FileManager.default.removeItem(at: tempTranscript)
        }

        try? "test data".write(to: tempTranscript, atomically: true, encoding: .utf8)

        let index = AgentHistoryFTSIndex(dbPath: tempDB.path)
        let rec = makeRecord(id: "sess-to-prune")
        index.saveRecord(rec, mtime: Date(), fileSize: 100)
        index.indexSession(
            sessionID: rec.id, title: rec.title, firstPrompt: rec.firstPrompt,
            fullTranscript: "content", gitBranch: "main", repoName: "repo",
            agentName: "Claude", filesEdited: "", toolsCalled: "",
            transcriptPath: tempTranscript.path, mtime: Date(), fileSize: 100
        )

        XCTAssertEqual(index.loadCachedEntries().count, 1)

        // Delete the transcript file on disk
        try? FileManager.default.removeItem(at: tempTranscript)

        // Pruning with an empty set of seen paths (or missing path) must delete it across all tables
        index.pruneMissingSessions(validTranscriptPaths: [])

        XCTAssertEqual(index.loadCachedEntries().count, 0)
        XCTAssertTrue(index.search(query: "content").isEmpty)
        XCTAssertTrue(index.needsReindex(sessionID: rec.id, mtime: Date(), fileSize: 100))
    }

    // A scan that misses a transcript (e.g. one agent's dir was unreadable this round) must not
    // drop a session whose file still exists — only files gone from disk are ghosts.
    func testPruneKeepsUnseenSessionWhoseTranscriptStillExists() {
        let tempDB = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test_prune_keep_\(UUID().uuidString).sqlite")
        let tempTranscript = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test_transcript_\(UUID().uuidString).jsonl")
        defer {
            try? FileManager.default.removeItem(at: tempDB)
            try? FileManager.default.removeItem(at: tempTranscript)
        }
        try? "test data".write(to: tempTranscript, atomically: true, encoding: .utf8)

        let index = AgentHistoryFTSIndex(dbPath: tempDB.path)
        let rec = AgentSessionRecord(
            id: "sess-keep", agentKind: .claudeCode, title: "t", projectPath: "/tmp/repo", projectName: "repo",
            messageCount: 3, updatedAt: Date(), firstPrompt: "hi", transcriptPath: tempTranscript.path,
            worktreeAvailable: true
        )
        index.saveRecord(rec, mtime: Date(), fileSize: 100)

        index.pruneMissingSessions(validTranscriptPaths: [])

        XCTAssertEqual(index.loadCachedEntries().map(\.record.id), ["sess-keep"])
    }

    func testNoFabricatedRecordsPersistedWhenSessionRecordsEmpty() {
        let tempDB = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test_no_fabricate_\(UUID().uuidString).sqlite")
        defer { try? FileManager.default.removeItem(at: tempDB) }

        let index = AgentHistoryFTSIndex(dbPath: tempDB.path)
        // Manually insert into session_fts and session_index_meta without session_records (legacy database scenario)
        index.indexSession(
            sessionID: "legacy-sess", title: "Legacy Session", firstPrompt: "prompt",
            fullTranscript: "full transcript", gitBranch: "main", repoName: "repo",
            agentName: "Claude Code", filesEdited: "", toolsCalled: "",
            transcriptPath: "/tmp/legacy.jsonl", mtime: Date(), fileSize: 100
        )

        // loadCachedEntries must NOT fabricate synthesized records or persist fake records
        let entries = index.loadCachedEntries()
        XCTAssertEqual(entries.count, 0, "No fabricated records should be returned or saved to session_records")
    }

    #if canImport(SQLite3)
    func testSchemaVersioningDropsAndRecreatesOnMismatch() {
        let tempDB = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test_schema_\(UUID().uuidString).sqlite")
        defer { try? FileManager.default.removeItem(at: tempDB) }

        // Create database with old user_version = 999
        var db: OpaquePointer?
        XCTAssertEqual(sqlite3_open(tempDB.path, &db), SQLITE_OK)
        sqlite3_exec(db, "PRAGMA user_version = 999;", nil, nil, nil)
        sqlite3_exec(db, "CREATE TABLE session_records (dummy_col TEXT);", nil, nil, nil)
        sqlite3_close(db)

        // Opening index must detect mismatch, drop outdated table, recreate correct schema, and set user_version = 1
        let index = AgentHistoryFTSIndex(dbPath: tempDB.path)
        let rec = makeRecord(id: "sess-v1")
        index.saveRecord(rec, mtime: Date(), fileSize: 42)

        let loaded = index.loadCachedEntries()
        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded[0].record.id, "sess-v1")
    }
    #endif

    func testScanAllReentrancyAndForceSemantics() async {
        let tempDB = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test_reentrancy_\(UUID().uuidString).sqlite")
        defer { try? FileManager.default.removeItem(at: tempDB) }

        let index = AgentHistoryFTSIndex(dbPath: tempDB.path)
        let scanner = AgentHistoryScanner(ftsIndex: index)

        // Expect notification when scan completes
        final class Box: @unchecked Sendable {
            var value = false
        }
        let box = Box()
        let observer = NotificationCenter.default.addObserver(
            forName: AgentHistoryScanner.didUpdateNotification,
            object: nil,
            queue: nil
        ) { _ in
            box.value = true
        }
        defer { NotificationCenter.default.removeObserver(observer) }

        // Run concurrent scans
        async let scan1 = scanner.scanAll()
        async let scan2 = scanner.getOrScan(force: true)

        let (res1, res2) = await (scan1, scan2)
        XCTAssertEqual(res1.count, res2.count)
        XCTAssertTrue(box.value)
    }
}
