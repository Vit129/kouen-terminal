import XCTest
@testable import KouenCLI

final class HappyAdoptTests: XCTestCase {
    private let listing = """
    Active sessions:
    [
      { "startedBy": "daemon", "happySessionId": "cmuaaa", "pid": 100 },
      { "startedBy": "happy directly - likely by user from terminal", "happySessionId": "cmubbb", "pid": 200 },
      { "startedBy": "daemon", "happySessionId": "cmuccc", "pid": 300 }
    ]
    """

    func testParsesHeaderThenJSONArray() {
        let sessions = KouenCLI.parseHappyDaemonList(listing)
        XCTAssertEqual(sessions.map(\.happySessionId), ["cmuaaa", "cmubbb", "cmuccc"])
        XCTAssertEqual(KouenCLI.parseHappyDaemonList("No active sessions this daemon is aware of"), [])
    }

    func testAdoptsOnlyLivePhoneStartedSessions() {
        let all = KouenCLI.parseHappyDaemonList(listing)
        let adoptable = KouenCLI.adoptableHappySessions(all) { $0 != 300 }   // 300 is a stale pid
        XCTAssertEqual(adoptable.map(\.happySessionId), ["cmuaaa"], "terminal-started and dead sessions are skipped")
    }

    func testResumeCommandPinsClaudeOnPath() {
        XCTAssertEqual(KouenCLI.happyResumeCommand("cmu1", path: "/a:/h/.local/bin:/b") { $0 == "/h/.local/bin/claude" },
                       "HAPPY_CLAUDE_PATH='/h/.local/bin/claude' happy resume cmu1")
        XCTAssertEqual(KouenCLI.happyResumeCommand("cmu1", path: "/a") { _ in false }, "happy resume cmu1")
    }

    func testAgyAndCopilotAdoptResumeNatively() {
        let sessions = Data(#"{"sessions":{"cmuagy":{"metadata":{"flavor":"agy","path":"/p"}}}}"#.utf8)
        XCTAssertEqual(KouenCLI.happyLocalSession("cmuagy", sessionsJSON: sessions)?.flavor, "agy")
        XCTAssertNil(KouenCLI.happyLocalSession("nope", sessionsJSON: sessions))
        let cache = Data(#"{"/p":"conv-1"}"#.utf8)
        XCTAssertEqual(KouenCLI.adoptResumeCommand(id: "x", flavor: "agy", path: "/p", agyCache: cache, copilotSessions: []),
                       "agy --conversation conv-1")
        XCTAssertNil(KouenCLI.adoptResumeCommand(id: "x", flavor: "agy", path: "/other", agyCache: cache, copilotSessions: []))

        let a = KouenCLI.parseCopilotWorkspace("id: c1\ncwd: /p\nclient_name: happy-cli\nupdated_at: 2026-10-07T10:00:00Z\n")!
        let b = KouenCLI.parseCopilotWorkspace("id: c2\ncwd: /p\nclient_name: happy-cli\nupdated_at: 2026-10-07T11:00:00Z\n")!
        let manual = KouenCLI.parseCopilotWorkspace("id: c3\ncwd: /p\nclient_name: copilot\nupdated_at: 2026-10-07T12:00:00Z\n")!
        XCTAssertEqual(KouenCLI.adoptResumeCommand(id: "x", flavor: "acp", path: "/p", agyCache: nil, copilotSessions: [a, b, manual]),
                       "copilot --resume c2", "newest happy-cli session for the cwd; hand-started ones are ignored")
        XCTAssertEqual(KouenCLI.adoptResumeCommand(id: "cmu9", flavor: "claude", path: "/p", agyCache: nil, copilotSessions: []),
                       KouenCLI.happyResumeCommand("cmu9"))
    }
}
