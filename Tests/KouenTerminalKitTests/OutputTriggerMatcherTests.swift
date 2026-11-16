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

    func test_TC1206_BE_UT_newOccurrenceStillFiresWhenOldMatchRemainsInCarry() {
        var m = OutputTriggerMatcher()
        let patterns = ["done", "a much longer pattern"]
        XCTAssertEqual(m.matches(in: "done", patterns: patterns), ["done"])
        XCTAssertEqual(m.matches(in: " done", patterns: patterns), ["done"])
        XCTAssertEqual(m.matches(in: " more", patterns: patterns), [])
    }

    func test_TC1206_BE_UT_overlappingOccurrenceCrossesCarryBoundary() {
        var m = OutputTriggerMatcher()
        let patterns = ["aba", "a much longer pattern"]
        XCTAssertEqual(m.matches(in: "aba", patterns: patterns), ["aba"])
        XCTAssertEqual(m.matches(in: "ba", patterns: patterns), ["aba"])
    }

    func test_TC1207_BE_IT_coalescedSlicesKeepTriggersAroundSplitUTF8() throws {
        let c = TerminalHostView.OutputCoalescer()
        let text = "done " + String(repeating: "a", count: 256 * 1024 - 6) + "é done"
        try c.append(Data(text.utf8)) {}
        var m = OutputTriggerMatcher()
        var hits: [String] = []
        while true {
            let slice = try c.drain()
            hits += m.matches(in: slice.data, patterns: ["done"])
            if !slice.hasMore { break }
        }
        XCTAssertEqual(hits, ["done", "done"])
    }

    func test_TC1207_BE_UT_unicodeTriggerSurvivesEveryByteBoundary() {
        for pattern in ["café", "พร้อม", "done 🥳"] {
            let bytes = Data(pattern.utf8)
            for split in 1 ..< bytes.count {
                var m = OutputTriggerMatcher()
                XCTAssertEqual(m.matches(in: Data(bytes.prefix(split)), patterns: [pattern]), [])
                XCTAssertEqual(m.matches(in: Data(bytes.dropFirst(split)), patterns: [pattern]), [pattern], "\(pattern), split \(split)")
            }
        }
    }

    func test_TC1207_BE_UT_invalidUTF8DoesNotDiscardFollowingTrigger() {
        var m = OutputTriggerMatcher()
        XCTAssertEqual(m.matches(in: Data([0xFF]) + Data("done".utf8), patterns: ["done"]), ["done"])
    }

    func test_TC1207_BE_UT_combiningCharactersSurviveSingleByteChunks() {
        for (text, pattern) in [("e\u{301}", "é"), ("👨‍👩‍👧", "👨‍👩‍👧")] {
            var m = OutputTriggerMatcher()
            var hits: [String] = []
            for byte in text.utf8 {
                hits += m.matches(in: Data([byte]), patterns: [pattern])
            }
            XCTAssertEqual(hits, [pattern])
        }
    }
}
