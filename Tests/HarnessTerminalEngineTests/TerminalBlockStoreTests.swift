import Foundation
import XCTest
@testable import HarnessTerminalEngine

/// OSC 133 `C`'s command-text payload (our own base64 extension) and `commandText(atPromptLine:)`
/// — the exact-command source `BlockActionBar.rerunBlock()` reads instead of screen-scraping.
final class TerminalBlockStoreTests: XCTestCase {
    private func osc133(_ body: String) -> String { "\u{1b}]133;\(body)\u{07}" }
    private func b64(_ s: String) -> String { Data(s.utf8).base64EncodedString() }

    func testCommandTextCapturedFromCBoundary() {
        let term = TerminalEmulator(cols: 40, rows: 6)
        term.feed(osc133("A") + "$ ")
        term.feed(osc133("C;\(b64("swift build"))") + "\r\nBuild complete!\r\n")
        term.feed(osc133("D;0"))
        XCTAssertEqual(term.commandText(atPromptLine: 0), "swift build")
    }

    func testCommandTextNilWithoutCBoundary() {
        // A shell that only emits A/D (e.g. bash, this pass) — no command text available.
        let term = TerminalEmulator(cols: 40, rows: 6)
        term.feed(osc133("A") + "$ true\r\n" + osc133("D;0"))
        XCTAssertNil(term.commandText(atPromptLine: 0))
    }

    func testCommandTextNilForUnknownPromptLine() {
        let term = TerminalEmulator(cols: 40, rows: 6)
        term.feed(osc133("A") + "$ ")
        term.feed(osc133("C;\(b64("swift build"))") + "\r\n")
        XCTAssertNil(term.commandText(atPromptLine: 99), "no block was ever opened at that prompt line")
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
        XCTAssertEqual(term.commandText(atPromptLine: prompts[0]), "swift build")
        XCTAssertEqual(term.commandText(atPromptLine: prompts[1]), "swift test")
    }
}
