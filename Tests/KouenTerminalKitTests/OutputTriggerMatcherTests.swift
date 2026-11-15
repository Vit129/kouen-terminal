import XCTest
@testable import KouenTerminalKit

final class OutputTriggerMatcherTests: XCTestCase {
    func test_TC1202_BEUT_triggerSplitAcrossChunksMatches() {
        var m = OutputTriggerMatcher()
        XCTAssertEqual(m.matches(in: "build fail", patterns: ["failed"]), [])
        XCTAssertEqual(m.matches(in: "ed: 3 errors", patterns: ["failed"]), ["failed"])
    }

    func test_TC1202_BEUT_triggerFullyInsideCarryDoesNotRefire() {
        var m = OutputTriggerMatcher()
        XCTAssertEqual(m.matches(in: "xx done", patterns: ["done"]), ["done"])
        XCTAssertEqual(m.matches(in: " more", patterns: ["done"]), [])
    }
}
