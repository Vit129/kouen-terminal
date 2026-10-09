import XCTest
@testable import KouenCLI

final class HistorySearchQueryTests: XCTestCase {
    // Unquoted multi-word queries used to search only the first word.
    func testJoinsAllBareWordsAndSkipsFlagValues() {
        XCTAssertEqual(KouenCLI.historySearchQuery(["kouen", "happy"]), "kouen happy")
        XCTAssertEqual(KouenCLI.historySearchQuery(["--limit", "5", "kouen", "happy"]), "kouen happy")
        XCTAssertEqual(KouenCLI.historySearchQuery(["kouen", "--limit", "5", "happy"]), "kouen happy")
        XCTAssertEqual(KouenCLI.historySearchQuery(["--limit", "5"]), "")
    }
}
