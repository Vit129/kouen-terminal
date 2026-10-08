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

    func testBm25BoostGrowsWithStrongerMatchAndStaysBelowOne() {
        XCTAssertEqual(AgentHistorySearch.bm25Boost(0), 0)
        XCTAssertGreaterThan(AgentHistorySearch.bm25Boost(-8), AgentHistorySearch.bm25Boost(-1))
        XCTAssertLessThan(AgentHistorySearch.bm25Boost(-1_000), 1)
    }

    func testEmptyQueryReturnsNothing() {
        XCTAssertTrue(AgentHistorySearch.rank(query: "  ", records: [record("a", title: "x", project: "r")]).isEmpty)
    }
}
