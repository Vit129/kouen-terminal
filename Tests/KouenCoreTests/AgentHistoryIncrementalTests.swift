import Foundation
@testable import KouenCore
import XCTest
import KouenIPC
#if canImport(SQLite3)
import SQLite3

final class AgentHistoryIncrementalTests: XCTestCase {
    func test_TS_2380_BE_IT_AppendRetainsExistingIndexRows() async throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        let file = dir.appendingPathComponent("session.jsonl")
        let dbURL = dir.appendingPathComponent("index.sqlite")
        let initial = "{\"message\":{\"role\":\"user\",\"content\":\"originalneedle\"}}\n"
        try initial.write(to: file, atomically: true, encoding: .utf8)
        let index = AgentHistoryFTSIndex(dbPath: dbURL.path)
        let scanner = AgentHistoryScanner(ftsIndex: index)
        _ = await scanner.parseClaudeTranscript(fileURL: file)

        func rowIDs() throws -> Set<Int64> {
            var db: OpaquePointer?
            XCTAssertEqual(sqlite3_open(dbURL.path, &db), SQLITE_OK)
            defer { sqlite3_close(db) }
            var statement: OpaquePointer?
            XCTAssertEqual(sqlite3_prepare_v2(db, "SELECT rowid FROM session_fts", -1, &statement, nil), SQLITE_OK)
            defer { sqlite3_finalize(statement) }
            var ids = Set<Int64>()
            while sqlite3_step(statement) == SQLITE_ROW { ids.insert(sqlite3_column_int64(statement, 0)) }
            return ids
        }
        let before = try rowIDs()
        let handle = try FileHandle(forWritingTo: file)
        try handle.seekToEnd()
        try handle.write(contentsOf: Data("{\"message\":{\"role\":\"assistant\",\"content\":\"appendedneedle\"}}\n".utf8))
        try handle.close()
        try FileManager.default.setAttributes([.modificationDate: Date(timeIntervalSinceNow: 5)], ofItemAtPath: file.path)
        let appendedRecord = await scanner.parseClaudeTranscript(fileURL: file)
        XCTAssertNotNil(appendedRecord, "scanner must accept the appended snapshot")
        XCTAssertEqual(index.incrementalCursor(sessionID: "session", path: file.path)?.offset, try Data(contentsOf: file).count)
        let after = try rowIDs()
        XCTAssertFalse(before.isEmpty)
        XCTAssertTrue(before.isSubset(of: after), "unchanged chunks must survive append")
        XCTAssertGreaterThan(after.count, before.count, "append must add a chunk without replacing the original")
        XCTAssertFalse(index.searchRanked(query: "originalneedle").isEmpty)
        XCTAssertFalse(index.searchRanked(query: "appendedneedle").isEmpty)
    }
    #if canImport(CryptoKit)
    func test_TS_2381_BE_IT_OnlyAppendedRecordsAreExtractedAcrossRestart() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        let file = dir.appendingPathComponent("session.jsonl")
        func line(_ value: String) -> String { "{\"message\":{\"role\":\"user\",\"content\":\"\(value)\"}}\n" }
        try line("oldneedle").write(to: file, atomically: true, encoding: .utf8)
        let first = try XCTUnwrap(AgentHistoryIncrementalFTS.extract(url: file, previous: nil, provider: .claudeCode))
        let db = AgentHistoryFTSIndex(dbPath: dir.appendingPathComponent("index.sqlite").path)
        var item = AgentHistoryFTSIndex.SessionIndexItem(sessionID: "session", transcriptPath: file.path, mtime: Date(), fileSize: try Data(contentsOf: file).count, title: "", firstPrompt: "", fullTranscript: "", agentName: AgentKind.claudeCode.displayName)
        item.incrementalJSONL = true
        db.indexSessionsBatch([item])
        func append(_ text: String) throws {
            let handle = try FileHandle(forWritingTo: file)
            defer { try? handle.close() }
            try handle.seekToEnd()
            try handle.write(contentsOf: Data(text.utf8))
        }
        try append(line("newneedle"))
        let reopened = AgentHistoryFTSIndex(dbPath: dir.appendingPathComponent("index.sqlite").path)
        let stored = try XCTUnwrap(reopened.incrementalCursor(sessionID: "session", path: file.path))
        XCTAssertEqual(stored.offset, first.cursor.offset)
        let second = try XCTUnwrap(AgentHistoryIncrementalFTS.extract(url: file, previous: stored, provider: .claudeCode))
        XCTAssertTrue(second.append)
        var chunks: [String] = []
        try second.spool.forEachChunk { chunks.append($0) }
        XCTAssertEqual(chunks.joined(), "newneedle")
        try append(line("thirdneedle"))
        let third = try XCTUnwrap(AgentHistoryIncrementalFTS.extract(url: file, previous: second.cursor, provider: .claudeCode))
        XCTAssertTrue(third.append)
        chunks.removeAll()
        try third.spool.forEachChunk { chunks.append($0) }
        XCTAssertEqual(chunks.joined(), "thirdneedle")
    }

    func test_TS_2382_BE_IT_RewritesTruncationAndOldPrefixGrowthReplace() throws {
        let file = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: file) }
        func line(_ value: String) -> String { "{\"message\":{\"role\":\"user\",\"content\":\"\(value)\"}}\n" }
        try line("before").write(to: file, atomically: true, encoding: .utf8)
        let initial = try XCTUnwrap(AgentHistoryIncrementalFTS.extract(url: file, previous: nil, provider: .claudeCode))
        for replacement in [line("after!"), line("x"), line("after!") + line("growth")] {
            try replacement.write(to: file, atomically: true, encoding: .utf8)
            let result = try XCTUnwrap(AgentHistoryIncrementalFTS.extract(url: file, previous: initial.cursor, provider: .claudeCode))
            XCTAssertFalse(result.append)
        }
    }

    func test_TS_2383_BE_IT_PartialTailAndValidEOF() throws {
        let file = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: file) }
        let first = "{\"message\":{\"role\":\"user\",\"content\":\"one\"}}\n"
        let incomplete = "{\"message\":{\"role\":\"user\",\"content\":\"two"
        try (first + incomplete).write(to: file, atomically: true, encoding: .utf8)
        let partial = try XCTUnwrap(AgentHistoryIncrementalFTS.extract(url: file, previous: nil, provider: .claudeCode))
        XCTAssertEqual(partial.cursor.offset, first.utf8.count)
        let h = try FileHandle(forWritingTo: file)
        try h.seekToEnd()
        try h.write(contentsOf: Data("\"}}".utf8))
        try h.close()
        let complete = try XCTUnwrap(AgentHistoryIncrementalFTS.extract(url: file, previous: partial.cursor, provider: .claudeCode))
        XCTAssertTrue(complete.append)
        var text = ""
        try complete.spool.forEachChunk { text += $0 }
        XCTAssertEqual(text, "two")
        let h2 = try FileHandle(forWritingTo: file)
        try h2.seekToEnd()
        try h2.write(contentsOf: Data("\n".utf8))
        try h2.close()
        let rebuilt = try XCTUnwrap(AgentHistoryIncrementalFTS.extract(url: file, previous: complete.cursor, provider: .claudeCode))
        XCTAssertFalse(rebuilt.append)
    }
    func test_TS_2384_BE_IT_CursorFailureRollsBackRowsAndRetries() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        let file = dir.appendingPathComponent("session.jsonl")
        let dbURL = dir.appendingPathComponent("index.sqlite")
        try "{\"message\":{\"content\":\"originalneedle\"}}\n".write(to: file, atomically: true, encoding: .utf8)
        let index = AgentHistoryFTSIndex(dbPath: dbURL.path)
        func item() throws -> AgentHistoryFTSIndex.SessionIndexItem {
            var item = AgentHistoryFTSIndex.SessionIndexItem(sessionID: "s", transcriptPath: file.path, mtime: Date(), fileSize: try Data(contentsOf: file).count, title: "", firstPrompt: "", fullTranscript: "", agentName: AgentKind.claudeCode.displayName)
            item.incrementalJSONL = true
            return item
        }
        index.indexSessionsBatch([try item()])
        let initial = try XCTUnwrap(index.incrementalCursor(sessionID: "s", path: file.path))
        var db: OpaquePointer?
        XCTAssertEqual(sqlite3_open(dbURL.path, &db), SQLITE_OK)
        defer { sqlite3_close(db) }
        XCTAssertEqual(sqlite3_exec(db, "CREATE TRIGGER fail_cursor BEFORE INSERT ON session_fts_cursor BEGIN SELECT RAISE(ABORT, 'injected'); END;", nil, nil, nil), SQLITE_OK)
        let handle = try FileHandle(forWritingTo: file)
        try handle.seekToEnd()
        try handle.write(contentsOf: Data("{\"message\":{\"content\":\"appendedneedle\"}}\n".utf8))
        try handle.close()
        index.indexSessionsBatch([try item()])
        XCTAssertEqual(index.incrementalCursor(sessionID: "s", path: file.path)?.offset, initial.offset)
        XCTAssertFalse(index.searchRanked(query: "originalneedle").isEmpty)
        XCTAssertTrue(index.searchRanked(query: "appendedneedle").isEmpty)
        XCTAssertEqual(sqlite3_exec(db, "DROP TRIGGER fail_cursor", nil, nil, nil), SQLITE_OK)
        index.indexSessionsBatch([try item()])
        XCTAssertFalse(index.searchRanked(query: "appendedneedle").isEmpty)
        XCTAssertGreaterThan(try XCTUnwrap(index.incrementalCursor(sessionID: "s", path: file.path)).offset, initial.offset)
    }
    func test_TS_2385_BE_IT_InvalidRecordsKeepCursorAndExistingRows() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        let file = dir.appendingPathComponent("session.jsonl")
        let base = "{\"message\":{\"content\":\"persistneedle\"}}\n"
        try base.write(to: file, atomically: true, encoding: .utf8)
        let index = AgentHistoryFTSIndex(dbPath: dir.appendingPathComponent("index.sqlite").path)
        func item() throws -> AgentHistoryFTSIndex.SessionIndexItem {
            var value = AgentHistoryFTSIndex.SessionIndexItem(sessionID: "s", transcriptPath: file.path, mtime: Date(), fileSize: try Data(contentsOf: file).count, title: "", firstPrompt: "", fullTranscript: "", agentName: AgentKind.claudeCode.displayName)
            value.incrementalJSONL = true
            return value
        }
        index.indexSessionsBatch([try item()])
        let before = try XCTUnwrap(index.incrementalCursor(sessionID: "s", path: file.path))
        for bad in ["not-json\n", String(repeating: "x", count: AgentHistoryScanner.maxJSONLRecordBytes + 1)] {
            try (base + bad).write(to: file, atomically: true, encoding: .utf8)
            index.indexSessionsBatch([try item()])
            XCTAssertEqual(index.incrementalCursor(sessionID: "s", path: file.path)?.offset, before.offset)
            XCTAssertFalse(index.searchRanked(query: "persistneedle").isEmpty)
        }
    }

    func test_TS_2386_BE_IT_SameSizeRewriteIsDetected() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        let file = dir.appendingPathComponent("session.jsonl")
        let first = "{\"message\":{\"content\":\"oldneedle\"}}\n"
        let second = "{\"message\":{\"content\":\"newneedle\"}}\n"
        try first.write(to: file, atomically: true, encoding: .utf8)
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let index = AgentHistoryFTSIndex(dbPath: dir.appendingPathComponent("index.sqlite").path)
        var item = AgentHistoryFTSIndex.SessionIndexItem(sessionID: "s", transcriptPath: file.path, mtime: date, fileSize: first.utf8.count, title: "", firstPrompt: "", fullTranscript: "", agentName: AgentKind.claudeCode.displayName)
        item.incrementalJSONL = true
        index.indexSessionsBatch([item])
        try second.write(to: file, atomically: true, encoding: .utf8)
        let changedDate = date.addingTimeInterval(2)
        XCTAssertTrue(index.needsReindex(sessionID: "s", mtime: changedDate, fileSize: second.utf8.count))
        item = AgentHistoryFTSIndex.SessionIndexItem(sessionID: "s", transcriptPath: file.path, mtime: changedDate, fileSize: second.utf8.count, title: "", firstPrompt: "", fullTranscript: "", agentName: AgentKind.claudeCode.displayName)
        item.incrementalJSONL = true
        index.indexSessionsBatch([item])
        XCTAssertTrue(index.searchRanked(query: "oldneedle").isEmpty)
        XCTAssertFalse(index.searchRanked(query: "newneedle").isEmpty)
    }

    func test_TS_2390_BE_IT_CodexAndAntigravityExtractOnlyAppends() throws {
        let file = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: file) }
        let fixtures: [(AgentKind, String, String)] = [
            (.codex, "{\"type\":\"message\",\"role\":\"user\",\"content\":\"old\"}\n", "{\"type\":\"message\",\"role\":\"assistant\",\"content\":\"new\"}\n"),
            (.antigravity, "{\"type\":\"USER_INPUT\",\"content\":\"old\"}\n", "{\"type\":\"PLANNER_RESPONSE\",\"content\":\"new\"}\n")
        ]
        for (provider, first, appended) in fixtures {
            try first.write(to: file, atomically: true, encoding: .utf8)
            let initial = try XCTUnwrap(AgentHistoryIncrementalFTS.extract(url: file, previous: nil, provider: provider))
            let handle = try FileHandle(forWritingTo: file)
            try handle.seekToEnd()
            try handle.write(contentsOf: Data(appended.utf8))
            try handle.close()
            let result = try XCTUnwrap(AgentHistoryIncrementalFTS.extract(url: file, previous: initial.cursor, provider: provider))
            XCTAssertTrue(result.append)
            var text = ""
            try result.spool.forEachChunk { text += $0 }
            XCTAssertEqual(text, "new")
        }
    }
    func test_TS_2391_BE_IT_NegativeCursorRebuildsSafely() throws {
        let file = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: file) }
        try "{\"message\":{\"content\":\"safe\"}}\n".write(to: file, atomically: true, encoding: .utf8)
        let cursor = AgentHistoryIncrementalFTS.Cursor(offset: -1, digest: "")
        let result = try XCTUnwrap(AgentHistoryIncrementalFTS.extract(url: file, previous: cursor, provider: .claudeCode))
        XCTAssertFalse(result.append)
        XCTAssertGreaterThan(result.cursor.offset, 0)
    }
    #endif
}
#endif
