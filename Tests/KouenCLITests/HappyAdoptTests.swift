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
}
