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
}
