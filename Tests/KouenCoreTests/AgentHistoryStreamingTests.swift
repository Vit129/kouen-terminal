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

    func test_TS_2900_BE_IT_CodexPreservesProjectContextAndMessageOrder() throws {
        let transcript = """
        {"type":"session_meta","payload":{"id":"mixed","cwd":"/repo/kouen","git":{"branch":"main"}}}
        {"type":"turn_context","payload":{"cwd":"/repo/kouen"}}
        {"type":"message","role":"user","content":"Work on Kouen"}
        {"type":"turn_context","payload":{"cwd":"/repo/plugin"}}
        {"type":"message","role":"user","content":"Work on the plugin"}
        {"type":"message","role":"assistant","content":[{"text":"Patched the plugin"},{"text":"Tests passed"}]}
        """
        let (root, file) = try tempFile(Data(transcript.utf8))
        defer { try? FileManager.default.removeItem(at: root) }

        let record = try XCTUnwrap(AgentHistoryScanner.parseCodexTranscript(fileURL: file))
        XCTAssertEqual(record.projectPath, "/repo/kouen")
        XCTAssertEqual(record.gitBranch, "main")
        XCTAssertEqual(record.latestTurns.map(\.projectPath), ["/repo/kouen", "/repo/plugin", "/repo/plugin"])
        XCTAssertEqual(record.latestTurns.map(\.content), ["Work on Kouen", "Work on the plugin", "Patched the plugin\nTests passed"])
        let oldRecord = AgentSessionRecord(
            id: "mixed", agentKind: .codex, title: record.title, projectPath: record.projectPath,
            projectName: record.projectName, messageCount: record.messageCount, updatedAt: record.updatedAt,
            firstPrompt: record.firstPrompt,
            latestTurns: record.latestTurns.map { AgentHistoryTurn(role: $0.role, content: $0.content) },
            transcriptPath: file.path, worktreeAvailable: false
        )
        XCTAssertEqual(AgentHistoryScanner.recoverTurnProjects(for: oldRecord), record.latestTurns)
        XCTAssertNil(AgentHistoryScanner.recoverTurnProjects(for: record))
    }

    func test_TS_2315_BE_IT_CodexParseFailureKeepsCachedRolloutAndRetries() throws {
        let initial = #"{"type":"session_meta","payload":{"id":"fixture","cwd":"/tmp"}}"# + "\n"
            + #"{"type":"message","role":"user","content":"original prompt"}"#
        let (root, fixture) = try tempFile(Data(initial.utf8))
        defer { try? FileManager.default.removeItem(at: root) }
        let url = root.appendingPathComponent("rollout-fixture.jsonl")
        try FileManager.default.moveItem(at: fixture, to: url)
        var cache: [String: AgentHistoryScanner.FileCacheEntry] = [:]

        let original = try XCTUnwrap(AgentHistoryScanner.readCodexRollouts(baseDir: root, fileCache: &cache).first)
        XCTAssertEqual(original.firstPrompt, "original prompt")
        try Data((initial + "\n{broken").utf8).write(to: url)
        let recovered = AgentHistoryScanner.readCodexRollouts(baseDir: root, fileCache: &cache)
        XCTAssertEqual(recovered.first?.firstPrompt, original.firstPrompt)
        XCTAssertEqual(cache.count, 1)
        XCTAssertEqual(cache.values.first?.size, initial.utf8.count)

        let repaired = initial.replacingOccurrences(of: "original prompt", with: "repaired longer prompt")
        try Data(repaired.utf8).write(to: url)
        let rescanned = AgentHistoryScanner.readCodexRollouts(baseDir: root, fileCache: &cache)
        XCTAssertEqual(rescanned.first?.firstPrompt, "repaired longer prompt")
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
