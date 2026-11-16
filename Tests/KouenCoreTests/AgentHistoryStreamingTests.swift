import Foundation
@testable import KouenCore
import XCTest

final class AgentHistoryStreamingTests: XCTestCase {
    func test_TS_2296_BE_IT_VendorParsersStreamFullConversationAndMetadata() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        func write(_ name: String, _ rows: [[String: Any]]) throws -> URL {
            let url = root.appendingPathComponent(name)
            var data = Data()
            for row in rows {
                data.append(try JSONSerialization.data(withJSONObject: row))
                data.append(10)
            }
            try data.write(to: url)
            return url
        }
        let claude = try write("claude.jsonl", [
            ["cwd": root.path, "message": ["role": "user", "content": "first Claude"]],
            ["message": ["role": "assistant", "content": "last Claude", "model": "model-test"]],
        ])
        let agy = try write("agy.jsonl", [
            ["type": "USER_INPUT", "content": "first agy"],
            ["type": "PLANNER_RESPONSE", "content": "last agy"],
        ])
        let codex = try write("codex.jsonl", [
            ["type": "session_meta", "payload": ["id": "fixture", "cwd": root.path]],
            ["type": "response_item", "payload": ["type": "message", "role": "user", "content": "first Codex"]],
            ["type": "turn_context", "payload": ["model": "model-test"]],
            ["type": "response_item", "payload": ["type": "message", "role": "assistant", "content": "last Codex"]],
        ])
        let scanner = AgentHistoryScanner(ftsIndex: AgentHistoryFTSIndex(dbPath: ":memory:"))
        let claudeRecord = await scanner.parseClaudeTranscript(fileURL: claude)
        let agyRecord = await scanner.parseAntigravityTranscript(sessionID: "fixture", fileURL: agy)
        let codexRecord = AgentHistoryScanner.parseCodexTranscript(fileURL: codex)
        XCTAssertEqual(claudeRecord?.modelName, "model-test")
        XCTAssertEqual(claudeRecord?.latestTurns.last?.content, "last Claude")
        XCTAssertEqual(agyRecord?.latestTurns.last?.content, "last agy")
        XCTAssertEqual(codexRecord?.modelName, "model-test")
        XCTAssertEqual(codexRecord?.latestTurns.last?.content, "last Codex")
    }
}
