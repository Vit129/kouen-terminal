import XCTest
@testable import HarnessTerminalEngine

final class GraphemeBreakTests: XCTestCase {
    func testOfficialUnicode18BoundaryCorpus() {
        XCTAssertEqual(GraphemeBreak.unicodeVersion, CharacterWidth.unicodeVersion)
        for (line, test) in Unicode18GraphemeCorpus.cases.split(separator: "\n").enumerated() {
            var state = GraphemeBreak.State()
            var expected = true
            for token in test.split(separator: " ") {
                if token == "÷" { expected = true }
                else if token == "×" { expected = false }
                else {
                    let scalar = UInt32(token, radix: 16)!
                    XCTAssertEqual(state.append(scalar), expected, "Unicode corpus line \(line + 1): \(test)")
                }
            }
        }
    }

    func testWidthUsesPinnedClusterProperties() {
        for (text, width) in [("👩🏽‍💻", 2), ("🇺🇸", 2), ("🇺", 1), ("❤️", 2), ("1️⃣", 2),
                              ("a\u{FE0F}", 1), ("a\u{20E3}", 1), ("©‍©", 2), ("각", 2), ("क्‍ष", 1), ("a\u{1AE0}", 1)] {
            XCTAssertEqual(GraphemeBreak.width(of: text), width, text)
        }
    }

    func testClusterMembershipIncludesIndicHangulAndNewUnicodeMarks() {
        XCTAssertTrue(GraphemeBreak.extends(cluster: "क्", with: 0x0937))
        XCTAssertTrue(GraphemeBreak.extends(cluster: "ᄀ", with: 0x1161))
        XCTAssertTrue(GraphemeBreak.extends(cluster: "a", with: 0x1AE0))
        XCTAssertFalse(GraphemeBreak.extends(cluster: "🇺🇸", with: 0x1F1E8))
        XCTAssertFalse(GraphemeBreak.extends(cluster: "a\u{200D}", with: 0x1F600))
        XCTAssertTrue(GraphemeBreak.extends(cluster: "\u{0600}", with: 0x41))
    }

    func testMode2027NegotiationAndReset() {
        let terminal = TerminalEmulator(cols: 20, rows: 3)
        var replies: [String] = []
        terminal.onResponse = { replies.append(String(decoding: $0, as: UTF8.self)) }
        terminal.feed("\u{1b}[?2027$p\u{1b}[?2027l\u{1b}[?2027$p")
        terminal.feed("\u{1b}[?2027h\u{1b}[?2027$p")
        terminal.feed("\u{1b}[?2027l\u{1b}c\u{1b}[?2027$p")
        XCTAssertEqual(replies, ["\u{1b}[?2027;1$y", "\u{1b}[?2027;2$y",
                                  "\u{1b}[?2027;1$y", "\u{1b}[?2027;1$y"])
    }

    func testMode2027ControlsFutureGraphemePlacement() {
        let terminal = TerminalEmulator(cols: 20, rows: 3)
        terminal.feed("각X")
        XCTAssertEqual(terminal.readGrid().cursor.col, 3)
        XCTAssertEqual(terminal.cluster(for: terminal.readGrid().cells[0]), "각")
        terminal.feed("\r\n\u{1b}[?2027l각X")
        XCTAssertEqual(terminal.readGrid().cursor.col, 5)
        terminal.feed("\r\n\u{1b}[?2027h각X")
        XCTAssertEqual(terminal.readGrid().cursor.col, 3)
    }

    func testPinnedClustersSurviveByteBoundariesAndResize() {
        for text in ["각", "क्‍ष", "a\u{1AE0}", "👩🏽‍💻"] {
            let terminal = TerminalEmulator(cols: 8, rows: 3)
            for byte in (text + "X").utf8 { terminal.feed([byte]) }
            XCTAssertEqual(terminal.cluster(for: terminal.readGrid().cells[0]), text)
            XCTAssertEqual(terminal.readGrid().cursor.col, GraphemeBreak.width(of: text) + 1)
            terminal.resize(cols: 3, rows: 3)
            XCTAssertEqual(terminal.captureLines(joinWrapped: true).first, text + "X")
        }
    }


    func testMixedPlacementModesSurviveScreenCaptureAndCheckpoint() throws {
        let terminal = TerminalEmulator(cols: 30, rows: 3)
        terminal.feed("\u{1b}[?2027l각🇺🇸\u{1b}[?2027h각👩🏽‍💻\u{0600}A")
        terminal.feed("\u{1b}[?2027l")
        let restored = TerminalEmulator(cols: 30, rows: 3)
        restored.feed(PaneCapture.screen(terminal))
        XCTAssertEqual(restored.captureLines(joinWrapped: true), terminal.captureLines(joinWrapped: true))
        XCTAssertEqual(restored.readGrid().cells.map(\.codepoint), terminal.readGrid().cells.map(\.codepoint))
        XCTAssertEqual(restored.readGrid().cells.map(\.width), terminal.readGrid().cells.map(\.width))
        XCTAssertFalse(restored.modes.graphemeClusters)
        let checkpointed = TerminalEmulator(cols: 30, rows: 3)
        try checkpointed.restore(terminal.checkpoint())
        checkpointed.feed("각X")
        terminal.feed("각X")
        XCTAssertEqual(checkpointed.readGrid(), terminal.readGrid())
    }

    func testPrependBeforeASCIIPreservesBothRunPaths() {
        let text = "\u{0600}ABC"
        let batched = TerminalEmulator(cols: 10, rows: 2)
        let scalarwise = TerminalEmulator(cols: 10, rows: 2)
        batched.feed(text)
        scalarwise.feedScalarwise(Array(text.utf8))
        XCTAssertEqual(batched.readGrid(), scalarwise.readGrid())
        XCTAssertEqual(batched.cluster(for: batched.readGrid().cells[0]), "\u{0600}A")
        XCTAssertEqual(batched.readGrid().cursor.col, 3)
    }


    func testASCIIScreenCaptureChangesGraphemeModeOnlyAtItsBoundaries() {
        let terminal = TerminalEmulator(cols: 40, rows: 8)
        terminal.feed(String(repeating: "ordinary ASCII output\r\n", count: 5))
        let capture = String(decoding: PaneCapture.screen(terminal), as: UTF8.self)
        XCTAssertEqual(capture.components(separatedBy: "?2027l").count - 1, 1)
        XCTAssertEqual(capture.components(separatedBy: "?2027h").count - 1, 1)
    }

}
