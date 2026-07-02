import Foundation
import XCTest
@testable import HarnessTerminalEngine

/// OSC 133 `C`'s command-text payload (our own base64 extension), `TerminalEmulator.block(atPromptLine:)`
/// — the exact-command/output-range source the right-click block menu's Re-run/Copy Output/Copy
/// Command actions read instead of screen-scraping — and `captureLines(fromLine:toLine:)`.
final class TerminalBlockStoreTests: XCTestCase {
    private func osc133(_ body: String) -> String { "\u{1b}]133;\(body)\u{07}" }
    private func b64(_ s: String) -> String { Data(s.utf8).base64EncodedString() }

    func testCommandTextCapturedFromCBoundary() {
        let term = TerminalEmulator(cols: 40, rows: 6)
        term.feed(osc133("A") + "$ ")
        term.feed(osc133("C;\(b64("swift build"))") + "\r\nBuild complete!\r\n")
        term.feed(osc133("D;0"))
        XCTAssertEqual(term.block(atPromptLine: 0)?.command, "swift build")
    }

    func testBlockNilWithoutCBoundary() {
        // A shell that only emits A/D (e.g. bash, this pass) — no block captured.
        let term = TerminalEmulator(cols: 40, rows: 6)
        term.feed(osc133("A") + "$ true\r\n" + osc133("D;0"))
        XCTAssertNil(term.block(atPromptLine: 0))
    }

    func testBlockNilForUnknownPromptLine() {
        let term = TerminalEmulator(cols: 40, rows: 6)
        term.feed(osc133("A") + "$ ")
        term.feed(osc133("C;\(b64("swift build"))") + "\r\n")
        XCTAssertNil(term.block(atPromptLine: 99), "no block was ever opened at that prompt line")
    }

    func testEachBlockKeepsItsOwnCommandText() {
        // Two prompt/command cycles — the second block's text must not bleed into the first's
        // prompt line, mirroring the per-scope leak guard used elsewhere in this codebase.
        let term = TerminalEmulator(cols: 40, rows: 20)
        term.feed(osc133("A") + "$ ")
        term.feed(osc133("C;\(b64("swift build"))") + "\r\noutput one\r\n")
        term.feed(osc133("D;0"))
        term.feed(osc133("A") + "$ ")
        term.feed(osc133("C;\(b64("swift test"))") + "\r\noutput two\r\n")
        term.feed(osc133("D;0"))

        let prompts = term.promptRows
        XCTAssertEqual(prompts.count, 2)
        XCTAssertEqual(term.block(atPromptLine: prompts[0])?.command, "swift build")
        XCTAssertEqual(term.block(atPromptLine: prompts[1])?.command, "swift test")
    }

    func testBlockRecordsExitCodeAndOutputRange() {
        let term = TerminalEmulator(cols: 40, rows: 10)
        term.feed(osc133("A") + "$ ")
        term.feed(osc133("C;\(b64("false"))") + "\r\n")
        term.feed(osc133("D;7"))
        let block = term.block(atPromptLine: 0)
        XCTAssertEqual(block?.exitCode, 7)
        XCTAssertNotNil(block?.outputEndLine)
    }

    func testLastBlockOnlyReturnsFinishedBlocks() {
        let term = TerminalEmulator(cols: 40, rows: 10)
        term.feed(osc133("A") + "$ ")
        term.feed(osc133("C;\(b64("still running"))") + "\r\n")
        XCTAssertNil(term.lastBlock, "block hasn't finished (no D yet)")
        term.feed(osc133("D;0"))
        XCTAssertEqual(term.lastBlock?.command, "still running")
    }

    func testCaptureLinesRangeMatchesBlockOutputBounds() {
        let term = TerminalEmulator(cols: 40, rows: 10)
        term.feed(osc133("A") + "$ ")
        term.feed(osc133("C;\(b64("echo hi"))") + "\r\nline one\r\nline two\r\n")
        term.feed(osc133("D;0"))
        guard let block = term.block(atPromptLine: 0), let end = block.outputEndLine else {
            return XCTFail("expected a finished block")
        }
        let lines = term.captureLines(fromLine: block.outputStartLine, toLine: end)
        XCTAssertTrue(lines.contains("line one"))
        XCTAssertTrue(lines.contains("line two"))
    }

    func testCaptureLinesRangeEmptyForInvalidRange() {
        let term = TerminalEmulator(cols: 40, rows: 10)
        term.feed("hello\r\n")
        XCTAssertEqual(term.captureLines(fromLine: 5, toLine: 2), [])
        XCTAssertEqual(term.captureLines(fromLine: -1, toLine: 0), [])
    }
}
