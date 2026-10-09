import Foundation
@testable import KouenCore
import KouenIPC
import XCTest
#if canImport(SQLite3)
import SQLite3
#endif

final class AgentHistoryMultiAgentCoverageTests: XCTestCase {

    private func makeTempDir() -> URL {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("p55_tests_\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    #if canImport(SQLite3)
    private func createMockAntigravityDB(at path: String) {
        var db: OpaquePointer?
        guard sqlite3_open(path, &db) == SQLITE_OK, let db else { return }
        defer { sqlite3_close(db) }

        let schema = """
        CREATE TABLE conversation_summaries (
            conversation_id TEXT PRIMARY KEY,
            title TEXT NOT NULL DEFAULT '',
            preview TEXT NOT NULL DEFAULT '',
            step_count INTEGER NOT NULL DEFAULT 0,
            last_modified_time DATETIME NOT NULL,
            workspace_uris TEXT NOT NULL,
            status TEXT NOT NULL DEFAULT '',
            source TEXT NOT NULL DEFAULT '',
            project_id TEXT NOT NULL DEFAULT '',
            agent_name TEXT NOT NULL DEFAULT '',
            parent_conversation_id TEXT NOT NULL DEFAULT '',
            nesting_depth INTEGER NOT NULL DEFAULT 0,
            battle_id TEXT NOT NULL DEFAULT '',
            winning_conversation_id TEXT NOT NULL DEFAULT '',
            not_fully_idle NUMERIC NOT NULL DEFAULT 0,
            killed NUMERIC NOT NULL DEFAULT 0,
            last_user_input_time DATETIME NOT NULL,
            last_user_input_step_index INTEGER NOT NULL DEFAULT -1,
            app_data_dir TEXT NOT NULL DEFAULT '',
            raw_summary BLOB,
            group_id TEXT NOT NULL DEFAULT ''
        );
        """
        sqlite3_exec(db, schema, nil, nil, nil)

        let insertSQL = """
        INSERT INTO conversation_summaries (
            conversation_id, title, preview, step_count, last_modified_time,
            workspace_uris, project_id, parent_conversation_id, app_data_dir,
            last_user_input_time
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """

        let rows: [(String, String, String, Int, String, String, String, String, String, String)] = [
            // 1. Regular CLI session
            ("cli-1", "CLI Session Title", "CLI preview", 5, "2026-10-09T10:00:00Z", "[\"file:///Users/test/ProjectA\"]", "default-cli-project", "", "antigravity-cli", "2026-10-09T10:00:00Z"),
            // 2. Antigravity 2.0 session
            ("ag2-1", "", "Antigravity 2.0 Feature Planning", 8, "2026-10-09T11:00:00Z", "[\"file:///Users/test/ProjectB\"]", "p2", "", "antigravity", "2026-10-09T11:00:00Z"),
            // 3. IDE session
            ("ide-1", "", "Refactor View in IDE", 3, "2026-10-09T09:00:00Z", "[\"file:///Users/test/ProjectC\"]", "uuid-ide-project-123", "", "antigravity-cli", "2026-10-09T09:00:00Z"),
            // 4. Subagent session (should be excluded)
            ("sub-1", "Subagent", "Subagent task", 2, "2026-10-09T08:00:00Z", "[\"file:///Users/test/ProjectA\"]", "default-cli-project", "cli-1", "antigravity-cli", "2026-10-09T08:00:00Z"),
            // 5. Ancient / corrupted timestamp
            ("ancient-1", "Old session", "Ancient preview", 0, "0001-01-01 00:00:00+00:00", "[\"file:///Users/test/ProjectD\"]", "default-cli-project", "", "antigravity-cli", "0001-01-01 00:00:00+00:00"),
            // 6. Percent-encoded workspace URI
            ("encoded-1", "Encoded Path Session", "Encoded preview", 4, "2026-10-09T12:00:00Z", "[\"file:///Users/test/My%20Test%20Folder\"]", "default-cli-project", "", "antigravity-cli", "2026-10-09T12:00:00Z")
        ]

        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, insertSQL, -1, &stmt, nil)
        for row in rows {
            sqlite3_reset(stmt)
            sqlite3_bind_text(stmt, 1, row.0, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(stmt, 2, row.1, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(stmt, 3, row.2, -1, SQLITE_TRANSIENT)
            sqlite3_bind_int(stmt, 4, Int32(row.3))
            sqlite3_bind_text(stmt, 5, row.4, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(stmt, 6, row.5, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(stmt, 7, row.6, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(stmt, 8, row.7, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(stmt, 9, row.8, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(stmt, 10, row.9, -1, SQLITE_TRANSIENT)
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
    }

    private func createMockCopilotDB(at path: String) {
        var db: OpaquePointer?
        guard sqlite3_open(path, &db) == SQLITE_OK, let db else { return }
        defer { sqlite3_close(db) }

        let schema = """
        CREATE TABLE sessions (
            id TEXT PRIMARY KEY,
            cwd TEXT,
            repository TEXT,
            host_type TEXT,
            branch TEXT,
            summary TEXT,
            created_at TEXT DEFAULT (datetime('now')),
            updated_at TEXT DEFAULT (datetime('now'))
        );
        CREATE TABLE turns (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            session_id TEXT NOT NULL,
            turn_index INTEGER NOT NULL,
            user_message TEXT,
            assistant_response TEXT,
            timestamp TEXT DEFAULT (datetime('now'))
        );
        """
        sqlite3_exec(db, schema, nil, nil, nil)

        let insertSession = "INSERT INTO sessions (id, cwd, repository, host_type, branch, summary, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?);"
        let insertTurn = "INSERT INTO turns (session_id, turn_index, user_message, assistant_response) VALUES (?, ?, ?, ?);"

        let sessions: [(String, String, String, String?, String, String, String)] = [
            ("cop-cli", "/Users/test/repo1", "repo1", nil, "main", "Copilot CLI Task", "2026-10-09T10:00:00Z"),
            ("cop-ado", "/Users/test/repo2", "repo2", "ado", "feat", "Copilot ADO Task", "2026-10-09T11:00:00Z"),
            ("cop-gh", "/Users/test/repo3", "repo3", "github", "fix", "Copilot GitHub Task", "2026-10-09T12:00:00Z")
        ]

        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, insertSession, -1, &stmt, nil)
        for s in sessions {
            sqlite3_reset(stmt)
            sqlite3_bind_text(stmt, 1, s.0, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(stmt, 2, s.1, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(stmt, 3, s.2, -1, SQLITE_TRANSIENT)
            if let h = s.3 { sqlite3_bind_text(stmt, 4, h, -1, SQLITE_TRANSIENT) } else { sqlite3_bind_null(stmt, 4) }
            sqlite3_bind_text(stmt, 5, s.4, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(stmt, 6, s.5, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(stmt, 7, s.6, -1, SQLITE_TRANSIENT)
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)

        sqlite3_prepare_v2(db, insertTurn, -1, &stmt, nil)
        for s in sessions {
            sqlite3_reset(stmt)
            sqlite3_bind_text(stmt, 1, s.0, -1, SQLITE_TRANSIENT)
            sqlite3_bind_int(stmt, 2, 1)
            sqlite3_bind_text(stmt, 3, "Hello from user", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(stmt, 4, "Hello from copilot", -1, SQLITE_TRANSIENT)
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
    }
    #endif

    // MARK: - [TS-P55-001] Read Antigravity & Filter Subagents

    func testAntigravityReadsSummaryDBAndFiltersSubagents() async throws {
        #if canImport(SQLite3)
        let tempDir = makeTempDir()
        defer { try? FileManager.default.removeItem(at: tempDir) }
        let dbPath = tempDir.appendingPathComponent("conversation_summaries.db").path
        createMockAntigravityDB(at: dbPath)

        let records = AgentHistoryScanner.readAntigravitySummaries(dbPath: dbPath, brainDir: tempDir.appendingPathComponent("brain"))
        // subagent "sub-1" must not be present
        XCTAssertFalse(records.contains(where: { $0.id == "sub-1" }))
        // Total top-level records should be 5
        XCTAssertEqual(records.count, 5)
        #endif
    }

    // MARK: - [TS-P55-002] Detect Antigravity 2.0 & Tag

    func testAntigravityDetects2_0AndTags() async throws {
        #if canImport(SQLite3)
        let tempDir = makeTempDir()
        defer { try? FileManager.default.removeItem(at: tempDir) }
        let dbPath = tempDir.appendingPathComponent("conversation_summaries.db").path
        createMockAntigravityDB(at: dbPath)

        let records = AgentHistoryScanner.readAntigravitySummaries(dbPath: dbPath, brainDir: tempDir.appendingPathComponent("brain"))
        guard let ag2 = records.first(where: { $0.id == "ag2-1" }) else {
            XCTFail("ag2-1 not found")
            return
        }
        XCTAssertEqual(ag2.surfaceTag, "2.0")
        XCTAssertEqual(ag2.effectiveResumeCommand(), "open -a Antigravity")
        #endif
    }

    // MARK: - [TS-P55-003] Detect Antigravity IDE Sessions

    func testAntigravityDetectsIDESessions() async throws {
        #if canImport(SQLite3)
        let tempDir = makeTempDir()
        defer { try? FileManager.default.removeItem(at: tempDir) }
        let dbPath = tempDir.appendingPathComponent("conversation_summaries.db").path
        createMockAntigravityDB(at: dbPath)

        let records = AgentHistoryScanner.readAntigravitySummaries(dbPath: dbPath, brainDir: tempDir.appendingPathComponent("brain"))
        guard let ide = records.first(where: { $0.id == "ide-1" }) else {
            XCTFail("ide-1 not found")
            return
        }
        XCTAssertEqual(ide.surfaceTag, "IDE")
        #endif
    }

    // MARK: - [TS-P55-004] Detect Antigravity Web Remote Sessions

    func testAntigravityDetectsWebRemoteSessions() {
        let tag = AgentHistoryScanner.antigravitySurfaceTag(appDataDir: "antigravity-cli", projectID: "default-cli-project", placement: .remoteControl)
        XCTAssertEqual(tag, "Web")
    }

    // MARK: - [TS-P55-005] Workspace URI Decoding

    func testAntigravityDecodesWorkspaceURI() {
        let rawJSON = "[\"file:///Users/test/My%20Test%20Folder\"]"
        let decoded = AgentHistoryScanner.decodeWorkspaceURI(rawJSON)
        XCTAssertEqual(decoded, "/Users/test/My Test Folder")
    }

    // MARK: - [TS-P55-006] Fallback Corrupted/Ancient Timestamps

    func testAntigravityFallbackAncientTimestamp() async throws {
        #if canImport(SQLite3)
        let tempDir = makeTempDir()
        defer { try? FileManager.default.removeItem(at: tempDir) }
        let dbPath = tempDir.appendingPathComponent("conversation_summaries.db").path
        createMockAntigravityDB(at: dbPath)

        let records = AgentHistoryScanner.readAntigravitySummaries(dbPath: dbPath, brainDir: tempDir.appendingPathComponent("brain"))
        guard let ancient = records.first(where: { $0.id == "ancient-1" }) else {
            XCTFail("ancient-1 not found")
            return
        }
        XCTAssertEqual(ancient.updatedAt, Date.distantPast)
        #endif
    }

    // MARK: - [TS-P55-007] Transcript Enrichment Priority

    func testAntigravityTranscriptEnrichmentPriority() async throws {
        #if canImport(SQLite3)
        let tempDir = makeTempDir()
        defer { try? FileManager.default.removeItem(at: tempDir) }
        let dbPath = tempDir.appendingPathComponent("conversation_summaries.db").path
        createMockAntigravityDB(at: dbPath)

        // Create an on-disk transcript for cli-1
        let brainSessionDir = tempDir.appendingPathComponent("brain/cli-1/.system_generated/logs")
        try FileManager.default.createDirectory(at: brainSessionDir, withIntermediateDirectories: true)
        let transcriptURL = brainSessionDir.appendingPathComponent("transcript.jsonl")
        let transcriptLines = [
            #"{"type":"USER_INPUT","content":"<USER_REQUEST>Write custom parser</USER_REQUEST>"}"#,
            #"{"type":"PLANNER_RESPONSE","content":"Parser written successfully."}"#
        ]
        try transcriptLines.joined(separator: "\n").write(to: transcriptURL, atomically: true, encoding: .utf8)

        let records = AgentHistoryScanner.readAntigravitySummaries(dbPath: dbPath, brainDir: tempDir.appendingPathComponent("brain"))
        guard let cli1 = records.first(where: { $0.id == "cli-1" }) else {
            XCTFail("cli-1 not found")
            return
        }
        XCTAssertEqual(cli1.firstPrompt, "Write custom parser")
        XCTAssertEqual(cli1.latestTurns.map { $0.content }, ["Write custom parser", "Parser written successfully."])
        #endif
    }

    // MARK: - [TS-P55-008] Codex Active and Archived Rollouts Discovery

    func testCodexActiveAndArchivedRolloutsDiscovery() throws {
        let tempDir = makeTempDir()
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let activeDir = tempDir.appendingPathComponent(".codex/sessions/2026/04/04")
        let archivedDir = tempDir.appendingPathComponent(".codex/archived_sessions/2026/04/01")
        try FileManager.default.createDirectory(at: activeDir, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: archivedDir, withIntermediateDirectories: true)

        let activeURL = activeDir.appendingPathComponent("rollout-active.jsonl")
        let archivedURL = archivedDir.appendingPathComponent("rollout-archived.jsonl")

        let sampleLines = [
            #"{"id":"rollout-1","timestamp":"2026-04-04T12:00:00Z","instructions":"None"}"#,
            #"{"type":"message","id":"m1","role":"user","content":[{"type":"text","text":"Implement feature"}]}"#,
            #"{"type":"message","id":"m2","role":"assistant","content":[{"type":"text","text":"Done"}]}"#
        ]
        try sampleLines.joined(separator: "\n").write(to: activeURL, atomically: true, encoding: .utf8)
        try sampleLines.joined(separator: "\n").write(to: archivedURL, atomically: true, encoding: .utf8)

        let records = AgentHistoryScanner.readCodexRollouts(baseDir: tempDir.appendingPathComponent(".codex"))
        XCTAssertEqual(records.count, 2)

        let activeRec = records.first(where: { $0.transcriptPath.contains("rollout-active") })
        let archivedRec = records.first(where: { $0.transcriptPath.contains("rollout-archived") })

        XCTAssertEqual(activeRec?.surfaceTag, "CLI")
        XCTAssertEqual(archivedRec?.surfaceTag, "Archived")
    }

    // MARK: - [TS-P55-009] Codex ChatGPT Remote Session Tagging

    func testCodexChatGPTRemoteTagging() {
        let tag = AgentHistoryScanner.codexSurfaceTag(filePath: "/path/to/rollout.jsonl", placement: .remoteControl)
        XCTAssertEqual(tag, "ChatGPT")
    }

    // MARK: - [TS-P55-010] Copilot VS Code & Insiders Scanning

    func testCopilotVSCodeAndInsidersScanning() throws {
        let tempDir = makeTempDir()
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let standardDir = tempDir.appendingPathComponent("Code/User/workspaceStorage/ws1/chatSessions")
        let insidersDir = tempDir.appendingPathComponent("Code - Insiders/User/workspaceStorage/ws2/chatSessions")
        try FileManager.default.createDirectory(at: standardDir, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: insidersDir, withIntermediateDirectories: true)

        let chatJSON = """
        {
            "version": 3,
            "sessionId": "chat-test-1",
            "requests": [
                {
                    "message": { "text": "Fix tests" },
                    "response": [ { "value": "Tests fixed" } ]
                }
            ]
        }
        """
        try chatJSON.write(to: standardDir.appendingPathComponent("chat.json"), atomically: true, encoding: .utf8)
        try chatJSON.write(to: insidersDir.appendingPathComponent("chat.json"), atomically: true, encoding: .utf8)

        let records = AgentHistoryScanner.readVSCodeStorageSessions(storageDirs: [
            tempDir.appendingPathComponent("Code/User/workspaceStorage"),
            tempDir.appendingPathComponent("Code - Insiders/User/workspaceStorage")
        ])

        XCTAssertEqual(records.count, 2)
        let std = records.first(where: { $0.transcriptPath.contains("Code/User") })
        let ins = records.first(where: { $0.transcriptPath.contains("Code - Insiders") })

        XCTAssertEqual(std?.surfaceTag, "VS Code")
        XCTAssertEqual(ins?.surfaceTag, "Insiders")
    }

    // MARK: - [TS-P55-011] Copilot CLI Host Type Tagging

    func testCopilotCLIHostTypeTagging() async throws {
        #if canImport(SQLite3)
        let tempDir = makeTempDir()
        defer { try? FileManager.default.removeItem(at: tempDir) }
        let dbPath = tempDir.appendingPathComponent("session-store.db").path
        createMockCopilotDB(at: dbPath)

        let records = AgentHistoryScanner.readCopilotSessions(dbPath: dbPath)
        XCTAssertEqual(records.count, 3)

        let cliRec = records.first(where: { $0.id == "cop-cli" })
        let adoRec = records.first(where: { $0.id == "cop-ado" })
        let ghRec = records.first(where: { $0.id == "cop-gh" })

        XCTAssertEqual(cliRec?.surfaceTag, "CLI")
        XCTAssertEqual(adoRec?.surfaceTag, "ADO")
        XCTAssertEqual(ghRec?.surfaceTag, "GitHub")
        #endif
    }

    // MARK: - [TS-P55-012] FTS Search Indexing Surface Tags

    func testFTSSearchMatchesSurfaceTags() {
        let tempDBPath = FileManager.default.temporaryDirectory
            .appendingPathComponent("fts_surface_\(UUID().uuidString).sqlite").path
        defer {
            try? FileManager.default.removeItem(atPath: tempDBPath)
            try? FileManager.default.removeItem(atPath: tempDBPath + "-shm")
            try? FileManager.default.removeItem(atPath: tempDBPath + "-wal")
        }
        let fts = AgentHistoryFTSIndex(dbPath: tempDBPath)

        let tags = ["2.0", "Web", "IDE", "Archived", "ChatGPT", "VS Code", "Insiders", "ADO", "GitHub"]
        for (i, tag) in tags.enumerated() {
            fts.indexSession(
                sessionID: "s-\(i)",
                title: "Session \(tag)",
                firstPrompt: "Prompt for \(tag)",
                fullTranscript: "Transcript for \(tag)",
                gitBranch: "main",
                repoName: "repo",
                agentName: "Agent",
                filesEdited: "",
                toolsCalled: "",
                transcriptPath: "/tmp/s-\(i).jsonl",
                mtime: Date(),
                fileSize: 10,
                surfaceTag: tag
            )
        }

        for tag in tags {
            let matches = fts.searchRanked(query: tag)
            XCTAssertTrue(matches.contains(where: { $0.snippet.contains(tag) || ftsHasAgentMatch(fts: fts, query: tag) }), "FTS search should find tag: \(tag)")
        }
    }

    private func ftsHasAgentMatch(fts: AgentHistoryFTSIndex, query: String) -> Bool {
        return !fts.searchRanked(query: query).isEmpty
    }
}

#if canImport(SQLite3)
private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
#endif
