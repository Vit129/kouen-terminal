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

    private func tempFile(_ data: Data) throws -> (URL, URL) {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let url = root.appendingPathComponent("t.jsonl")
        try data.write(to: url)
        return (root, url)
    }

    func test_TS_2297_BE_UT_SequenceStreamsRecordsAcrossChunksAndIsRepeatable() throws {
        var data = Data()
        for i in 0..<5000 { data.append(Data("{\"i\":\(i),\"pad\":\"\(String(repeating: "x", count: 40))\"}\n".utf8)) }
        let (root, url) = try tempFile(data)
        defer { try? FileManager.default.removeItem(at: root) }
        let seq = try XCTUnwrap(AgentHistoryJSONLSequence(url: url))
        XCTAssertEqual(seq.count, 5000)
        XCTAssertEqual(Array(seq).count, 5000)
        XCTAssertEqual(seq.enumerated().filter { $0.offset >= 4990 }.count, 10)
        XCTAssertTrue(seq.isValid)
    }

    func test_TS_2298_BE_UT_PartialFinalLineDoesNotBreakEarlierRecords() throws {
        let (root, url) = try tempFile(Data("{\"a\":1}\n{\"b\":2}\n{\"c\":".utf8))
        defer { try? FileManager.default.removeItem(at: root) }
        let seq = try XCTUnwrap(AgentHistoryJSONLSequence(url: url))
        let parsed = seq.compactMap { historyJSONObject($0) }
        XCTAssertEqual(parsed.count, 2)
    }

    func test_TS_2299_BE_UT_OversizedRecordRejectedSoCallerKeepsCachedRecord() throws {
        var data = Data("{\"a\":\"".utf8)
        data.append(Data(repeating: 0x78, count: AgentHistoryScanner.maxJSONLRecordBytes + 1))
        data.append(Data("\"}\n".utf8))
        let (root, url) = try tempFile(data)
        defer { try? FileManager.default.removeItem(at: root) }
        XCTAssertNil(AgentHistoryJSONLSequence(url: url))
    }
}
