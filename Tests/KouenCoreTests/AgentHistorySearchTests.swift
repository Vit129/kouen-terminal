import XCTest
@testable import KouenCore

final class AgentHistorySearchTests: XCTestCase {
    private func record(_ id: String, title: String, project: String, prompt: String = "", age: TimeInterval = 0) -> AgentSessionRecord {
        AgentSessionRecord(
            id: id, agentKind: .claudeCode, title: title,
            projectPath: "/p/\(project)", projectName: project,
            messageCount: 1, updatedAt: Date().addingTimeInterval(-age),
            firstPrompt: prompt, transcriptPath: "/tmp/\(id).jsonl", worktreeAvailable: false
        )
    }

    private func tempIndex() -> (AgentHistoryFTSIndex, URL) {
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test_history_search_\(UUID().uuidString).sqlite")
        return (AgentHistoryFTSIndex(dbPath: url.path), url)
    }

    func testFindsSessionWhoseOnlyMatchIsDeepInTranscript() {
        let (index, url) = tempIndex()
        defer { try? FileManager.default.removeItem(at: url) }
        index.indexSession(
            sessionID: "deep", title: "ตอนนี้เราใช้ happy อยู่สินะ", firstPrompt: "happy vs orca",
            fullTranscript: String(repeating: "filler line\n", count: 200) + "redesign the session history search",
            gitBranch: "main", repoName: "kouen-terminal", agentName: "Claude",
            filesEdited: "", toolsCalled: "", transcriptPath: "/tmp/deep.jsonl", mtime: Date(), fileSize: 1
        )
        let records = [record("deep", title: "ตอนนี้เราใช้ happy อยู่สินะ", project: "kouen-terminal", prompt: "happy vs orca"),
                       record("other", title: "Godot vs Unreal", project: "space-discovery-game")]

        let hits = AgentHistorySearch.rank(query: "history search", records: records, index: index)
        XCTAssertEqual(hits.map(\.record.id), ["deep"])
    }

    func testTitleMatchOutranksTranscriptOnlyMatch() {
        let (index, url) = tempIndex()
        defer { try? FileManager.default.removeItem(at: url) }
        index.indexSession(
            sessionID: "chat", title: "Misc", firstPrompt: "", fullTranscript: "we talked about the browser pane",
            gitBranch: "main", repoName: "r", agentName: "Claude", filesEdited: "", toolsCalled: "",
            transcriptPath: "/tmp/chat.jsonl", mtime: Date(), fileSize: 1
        )
        // Newer transcript-only hit must still rank below an older title hit.
        let records = [record("chat", title: "Misc", project: "r", age: 0),
                       record("title", title: "Close browser pane after verify", project: "r", age: 86_400)]

        let hits = AgentHistorySearch.rank(query: "browser pane", records: records, index: index)
        XCTAssertEqual(hits.map(\.record.id), ["title", "chat"])
    }

    func testRareWordsBeatCommonWords() {
        let (index, url) = tempIndex()
        defer { try? FileManager.default.removeItem(at: url) }
        // "kouen" and "agent" appear in every session; only one session is about the browser pane.
        var records = (0..<8).map { record("g\($0)", title: "kouen agent dev environment review \($0)", project: "kouen-terminal") }
        records.append(record("target", title: "Close browser panes the agent opened", project: ".claude", age: 60 * 86_400))

        let hits = AgentHistorySearch.rank(query: "kouen close agent browser auto", records: records, index: index)
        XCTAssertEqual(hits.first?.record.id, "target")
        XCTAssertFalse(hits.contains { $0.record.id.hasPrefix("g") }, "common words alone must not carry a match")
    }

    func testUnweightedMatchHistoryKeepsHalfTheTokensRule() {
        let matcher = SearchMatcher(query: "alpha beta gamma delta")
        XCTAssertNotNil(matcher.matchHistory(title: "alpha beta"))
        XCTAssertNil(matcher.matchHistory(title: "alpha"))
    }

    func testBm25BoostGrowsWithStrongerMatchAndStaysBelowOne() {
        XCTAssertEqual(AgentHistorySearch.bm25Boost(0), 0)
        XCTAssertGreaterThan(AgentHistorySearch.bm25Boost(-8), AgentHistorySearch.bm25Boost(-1))
        XCTAssertLessThan(AgentHistorySearch.bm25Boost(-1_000), 1)
    }

    func testEmptyQueryReturnsNothing() {
        XCTAssertTrue(AgentHistorySearch.rank(query: "  ", records: [record("a", title: "x", project: "r")]).isEmpty)
    }

    func testSaveAndLoadCachedSessionRecords() {
        let (index, url) = tempIndex()
        defer { try? FileManager.default.removeItem(at: url) }

        let rec = AgentSessionRecord(
            id: "cached-session-1",
            agentKind: .claudeCode,
            title: "Performance optimization for search",
            projectPath: "/Users/test/kouen-terminal",
            projectName: "kouen-terminal",
            gitBranch: "perf/test",
            modelName: "claude-sonnet-4-6",
            messageCount: 5,
            updatedAt: Date(),
            firstPrompt: "optimize search latency",
            latestTurns: [
                AgentHistoryTurn(role: "YOU", content: "Optimize startup"),
                AgentHistoryTurn(role: "AGENT", content: "Cached SQLite index applied")
            ],
            transcriptPath: "/tmp/cached-session-1.jsonl",
            worktreeAvailable: true
        )

        let mtime = Date(timeIntervalSince1970: 1700000000)
        let fileSize = 4096

        XCTAssertTrue(index.needsReindex(sessionID: "cached-session-1", mtime: mtime, fileSize: fileSize))

        index.saveRecord(rec, mtime: mtime, fileSize: fileSize)
        index.indexSession(
            sessionID: "cached-session-1",
            title: rec.title,
            firstPrompt: rec.firstPrompt,
            fullTranscript: "full transcript text",
            gitBranch: rec.gitBranch,
            repoName: rec.projectName,
            agentName: "Claude Code",
            filesEdited: "",
            toolsCalled: "",
            transcriptPath: rec.transcriptPath,
            mtime: mtime,
            fileSize: fileSize
        )

        XCTAssertFalse(index.needsReindex(sessionID: "cached-session-1", mtime: mtime, fileSize: fileSize))

        let loaded = index.loadCachedEntries()
        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded[0].record.id, "cached-session-1")
        XCTAssertEqual(loaded[0].record.title, "Performance optimization for search")
        XCTAssertEqual(loaded[0].record.latestTurns.count, 2)
        XCTAssertEqual(loaded[0].record.latestTurns[1].content, "Cached SQLite index applied")
        XCTAssertEqual(loaded[0].fileSize, fileSize)

        index.deleteSession(sessionID: "cached-session-1")
        let afterDelete = index.loadCachedEntries()
        XCTAssertEqual(afterDelete.count, 0)
    }

    func testFastPathFTSUsedForStandardQuery() {
        let (index, url) = tempIndex()
        defer { try? FileManager.default.removeItem(at: url) }

        let rec = record("sess-fast", title: "optimize compiler performance in swift", project: "swift")
        index.saveRecord(rec, mtime: Date(), fileSize: 100)

        let hits = AgentHistorySearch.rank(query: "compiler", records: [rec], index: index)
        XCTAssertEqual(hits.count, 1)
        XCTAssertEqual(hits[0].record.id, "sess-fast")
    }

    func testThaiQueryFindsUnsegmentedMatch() {
        let (index, url) = tempIndex()
        defer { try? FileManager.default.removeItem(at: url) }

        let rec = record("sess-thai", title: "การทดสอบระบบและบันทึกข้อมูล", project: "proj")
        index.saveRecord(rec, mtime: Date(), fileSize: 100)

        // Query "ทดสอบ" is a substring without word boundaries
        let hits = AgentHistorySearch.rank(query: "ทดสอบ", records: [rec], index: index)
        XCTAssertEqual(hits.count, 1)
        XCTAssertEqual(hits[0].record.id, "sess-thai")
    }

    func testUnindexedRecordsFoundBeyond200Limit() {
        let (index, url) = tempIndex()
        defer { try? FileManager.default.removeItem(at: url) }

        // Create 250 in-memory records (simulating records before indexing in SQLite)
        var records: [AgentSessionRecord] = []
        for i in 0..<250 {
            let rec = record("sess-\(i)", title: "Regular session \(i)", project: "proj")
            records.append(rec)
        }
        let target = record("sess-target", title: "Important unique search target", project: "proj")
        records.append(target)

        let hits = AgentHistorySearch.rank(query: "target", records: records, index: index)
        XCTAssertEqual(hits.count, 1)
        XCTAssertEqual(hits[0].record.id, "sess-target")
    }

    func testRepresentativeQueryRankingQuality() {
        let (index, url) = tempIndex()
        defer { try? FileManager.default.removeItem(at: url) }

        // Session with title match: "fix memory leak in audio engine" (weight 3.0)
        let recTitle = record("sess-title", title: "fix memory leak in audio engine", project: "audio")
        // Session with branch match: "perf/memory-leak-fix", title "audio improvements" (weight 2.5)
        let recBranch = AgentSessionRecord(
            id: "sess-branch", agentKind: .claudeCode, title: "audio improvements",
            projectPath: "/p/audio", projectName: "audio", gitBranch: "memory-leak-fix",
            messageCount: 1, updatedAt: Date(), firstPrompt: "", transcriptPath: "/tmp/sess-branch.jsonl",
            worktreeAvailable: false
        )
        // Session with transcript-only match: "misc audio notes" (weight 1.0)
        let recTranscript = record("sess-transcript", title: "misc audio notes", project: "audio")

        index.indexSession(
            sessionID: recTitle.id, title: recTitle.title, firstPrompt: "",
            fullTranscript: "audio", gitBranch: "main", repoName: "audio",
            agentName: "Claude", filesEdited: "", toolsCalled: "", transcriptPath: "/tmp/t1.jsonl",
            mtime: Date(), fileSize: 10
        )
        index.indexSession(
            sessionID: recBranch.id, title: recBranch.title, firstPrompt: "",
            fullTranscript: "audio", gitBranch: recBranch.gitBranch, repoName: "audio",
            agentName: "Claude", filesEdited: "", toolsCalled: "", transcriptPath: "/tmp/t2.jsonl",
            mtime: Date(), fileSize: 10
        )
        index.indexSession(
            sessionID: recTranscript.id, title: recTranscript.title, firstPrompt: "",
            fullTranscript: "we observed a severe memory leak during stress testing", gitBranch: "main", repoName: "audio",
            agentName: "Claude", filesEdited: "", toolsCalled: "", transcriptPath: "/tmp/t3.jsonl",
            mtime: Date(), fileSize: 10
        )

        let records = [recTranscript, recBranch, recTitle]
        let hits = AgentHistorySearch.rank(query: "memory leak", records: records, index: index)

        XCTAssertEqual(hits.count, 3)
        // Title weight (3.0) outranks branch weight (2.5), which outranks transcript (1.0)
        XCTAssertEqual(hits[0].record.id, "sess-title")
        XCTAssertEqual(hits[1].record.id, "sess-branch")
        XCTAssertEqual(hits[2].record.id, "sess-transcript")
    }

    func testMultiTermMatchOutranksSingleTermMatch() {
        let (index, url) = tempIndex()
        defer { try? FileManager.default.removeItem(at: url) }

        let recBoth = record("sess-both", title: "sqlite performance optimization", project: "db")
        let recOne = record("sess-one", title: "sqlite database schema", project: "db")

        index.indexSession(
            sessionID: recBoth.id, title: recBoth.title, firstPrompt: "",
            fullTranscript: "", gitBranch: "main", repoName: "db",
            agentName: "Claude", filesEdited: "", toolsCalled: "", transcriptPath: "/tmp/b.jsonl",
            mtime: Date(), fileSize: 10
        )
        index.indexSession(
            sessionID: recOne.id, title: recOne.title, firstPrompt: "",
            fullTranscript: "", gitBranch: "main", repoName: "db",
            agentName: "Claude", filesEdited: "", toolsCalled: "", transcriptPath: "/tmp/o.jsonl",
            mtime: Date(), fileSize: 10
        )

        let records = [recOne, recBoth]
        let hits = AgentHistorySearch.rank(query: "sqlite optimization", records: records, index: index)

        XCTAssertEqual(hits.count, 2)
        XCTAssertEqual(hits[0].record.id, "sess-both")
        XCTAssertEqual(hits[1].record.id, "sess-one")
    }
}

