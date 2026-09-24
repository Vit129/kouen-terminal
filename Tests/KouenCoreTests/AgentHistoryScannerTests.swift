import Foundation
@testable import KouenCore
import KouenIPC
import XCTest

final class AgentHistoryScannerTests: XCTestCase {
    func testScanAllReturnsRecords() async {
        let scanner = AgentHistoryScanner()
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
        XCTAssertEqual(merged[0].resumeCommandOverride, "claude --cloud abc123")
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
        XCTAssertEqual(synthetic?.resumeCommandOverride, "claude --cloud cloud-only")
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
            "claude --cloud s"
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
        XCTAssertEqual(record.effectiveResumeCommand(claudeMode: .remoteControl), "claude --cloud abc123")
    }

    func testEffectiveResumeCommandFallsBackToAgentKindWhenLocal() {
        let record = makeRecord()
        XCTAssertEqual(record.effectiveResumeCommand(claudeMode: .cloud), record.agentKind.resumeCommand(sessionID: record.id, claudeMode: .cloud))
    }
}
