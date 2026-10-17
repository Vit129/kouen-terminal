import XCTest
import KouenCore
@testable import KouenCLI

final class HistorySearchQueryTests: XCTestCase {
    // Unquoted multi-word queries used to search only the first word.
    func testJoinsAllBareWordsAndSkipsFlagValues() {
        XCTAssertEqual(KouenCLI.historySearchQuery(["kouen", "happy"]), "kouen happy")
        XCTAssertEqual(KouenCLI.historySearchQuery(["--limit", "5", "kouen", "happy"]), "kouen happy")
        XCTAssertEqual(KouenCLI.historySearchQuery(["kouen", "--limit", "5", "happy"]), "kouen happy")
        XCTAssertEqual(KouenCLI.historySearchQuery(["--limit", "5"]), "")
    }

    func testHistoryEntryEncodesUsageJSON() throws {
        var usage = AgentUsage()
        usage.inputTokens = 1500
        usage.cacheReadTokens = 2500
        usage.outputTokens = 300
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(usage)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(json["contextTokens"] as? Int, 4000)
        XCTAssertEqual(json["shortSummary"] as? String, "4.0k ctx")
    }
}
