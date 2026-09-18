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
    }
}
