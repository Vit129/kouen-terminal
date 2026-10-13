import XCTest
@testable import KouenCore

final class AntigravityTranscriptTurnsTests: XCTestCase {
    func testOnlyUserAndPlannerEntriesBecomeTurns() async throws {
        let lines = [
            #"{"type":"USER_INPUT","content":"<USER_REQUEST>build a space game</USER_REQUEST>"}"#,
            #"{"type":"GENERIC","content":"The command exited with code 0."}"#,
            #"{"type":"SYSTEM_MESSAGE","content":"<SYSTEM_MESSAGE priority=MESSAGE_PRIORITY_HIGH>task finished"}"#,
            #"{"type":"CHECKPOINT","content":"{{ CHECKPOINT 0 }}"}"#,
            #"{"type":"PLANNER_RESPONSE","content":"Done, game runs."}"#,
        ]
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).jsonl")
        try lines.joined(separator: "\n").write(to: url, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: url) }

        let parsed = await AgentHistoryScanner().parseAntigravityTranscript(sessionID: "s1", fileURL: url)
        let record = try XCTUnwrap(parsed)
        XCTAssertEqual(record.latestTurns.map(\.content), ["build a space game", "Done, game runs."])
    }

    func testToolOnlyPlannerResponseBecomesAgentTurn() {
        let json: [String: Any] = ["type": "PLANNER_RESPONSE", "tool_calls": [["name": "run_command", "args": ["CommandLine": "\"git status\""]]]]
        let turn = AgentHistoryScanner.antigravityTurn(json)
        XCTAssertEqual(turn?.role, "AGENT")
        XCTAssertEqual(turn?.text, "→ run_command: git status")
        XCTAssertNil(AgentHistoryScanner.antigravityTurn(["type": "PLANNER_RESPONSE"]))
    }

    func testConsecutiveToolTurnsFoldSoTheRequestStaysVisible() {
        var turns: [AgentHistoryTurn] = []
        AgentHistoryScanner.appendTurn(&turns, role: "YOU", text: "fix the build")
        for i in 0..<20 { AgentHistoryScanner.appendTurn(&turns, role: "AGENT", text: "→ run_command: step \(i)") }
        XCTAssertEqual(turns.count, 2)
        XCTAssertEqual(turns[0].content, "fix the build")
        XCTAssertEqual(turns[1].content.split(separator: "\n").last, "→ run_command: step 19")
    }
}

final class ClaudeHumanTextTests: XCTestCase {
    func testPlumbingDroppedAndMetadataHeaderStripped() {
        for plumbing in ["<local-command-caveat>x</local-command-caveat>", "<task-notification>\n<task-id>b1</task-id>", "[Request interrupted by user]", "Caveat: The messages below"] {
            XCTAssertNil(ClaudeTranscriptLine.humanText(plumbing, isUser: true), plumbing)
        }
        XCTAssertEqual(ClaudeTranscriptLine.humanText("Transcript Metadata:\nProject Working Directory: /x\nGit Branch: main\n\nreview this diff", isUser: true), "review this diff")
        XCTAssertEqual(ClaudeTranscriptLine.humanText("ทำไม [Image #1] ไม่ขึ้น", isUser: true), "ทำไม  ไม่ขึ้น")
        // The agent may legitimately say these words; only user lines are plumbing.
        XCTAssertEqual(ClaudeTranscriptLine.humanText("Caveat: this is slow", isUser: false), "Caveat: this is slow")
    }
}
