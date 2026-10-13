import HarnessTerminalEngine
import HarnessTerminalRenderer
import XCTest
@testable import HarnessTerminalKit

/// Copying a soft-wrapped line must give the same text as capture, including where a wide
/// glyph was deferred to the next row.
final class WideWrapCopyTests: XCTestCase {
    private func assertCopyMatchesCapture(_ input: String, expected: String, file: StaticString = #filePath, line: UInt = #line) {
        let emulator = TerminalEmulator(cols: 4, rows: 3)
        emulator.feed(input)
        let captured = emulator.captureLines(joinWrapped: true, history: false).first ?? ""
        let copied = HarnessTerminalSurfaceView.testingSelectedText(TerminalSelection((0, 0), (1, 3)), emulator: emulator)
        XCTAssertEqual(captured, expected, "capture", file: file, line: line)
        XCTAssertEqual(copied, expected, "copy", file: file, line: line)
    }

    func testDeferredWideGlyphDropsTheGap() {
        assertCopyMatchesCapture("abc漢", expected: "abc漢")
    }

    func testDeferredWideGlyphOnAColoredLineDropsTheGap() {
        assertCopyMatchesCapture("\u{1b}[44m\u{1b}[K\u{1b}[0mabc漢", expected: "abc漢")
    }

    func testWrittenSpaceBeforeAWideGlyphIsKept() {
        assertCopyMatchesCapture("abc 漢", expected: "abc 漢")
    }
}
