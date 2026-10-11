import XCTest
@testable import HarnessTerminalEngine

final class TerminalTextAnchorTests: XCTestCase {
    private func write(_ text: String, to screen: TerminalScreen) {
        for scalar in text.unicodeScalars { screen.print(scalar.value) }
    }

    func testAnchorsFollowNarrowWideAndInclusiveWideTailThroughRepeatedReflow() throws {
        let screen = TerminalScreen(cols: 8, rows: 4, recordsHistory: true)
        write("abc界defghij", to: screen)
        let narrow = screen.makeTextAnchor(line: 0, column: 2)
        let wide = screen.makeTextAnchor(line: 0, column: 3)
        let tail = screen.makeTextAnchor(line: 0, column: 4)
        let last = screen.makeCursorTextAnchor()
        for width in [4, 11, 5, 8] {
            screen.resize(cols: width, rows: 4)
            let n = try XCTUnwrap(narrow.position)
            let w = try XCTUnwrap(wide.position)
            let t = try XCTUnwrap(tail.position)
            XCTAssertEqual(screen.bufferLine(n.line)[n.column].codepoint, 99)
            XCTAssertEqual(screen.bufferLine(w.line)[w.column].codepoint, 0x754C)
            XCTAssertEqual(t.line, w.line)
            XCTAssertEqual(t.column, w.column + 1)
            XCTAssertEqual(screen.bufferLine(t.line)[t.column].width, .spacerTail)
            XCTAssertNotNil(last.position)
        }
    }

    func testEndExclusiveBoundaryAtFullRowSurvivesResize() {
        let screen = TerminalScreen(cols: 8, rows: 2, recordsHistory: true)
        write("abcdefgh", to: screen)
        let end = screen.makeCursorTextAnchor()
        XCTAssertEqual(end.position, .init(line: 0, column: 8))
        screen.resize(cols: 4, rows: 2)
        XCTAssertEqual(end.position, .init(line: 1, column: 4))
        screen.resize(cols: 12, rows: 2)
        XCTAssertEqual(end.position, .init(line: 0, column: 8))
    }

    func testHistoryEvictionInvalidatesOnlyLostAnchorsAndHeightResizeKeepsText() throws {
        let screen = TerminalScreen(cols: 8, rows: 2, recordsHistory: true)
        screen.maxHistoryLines = 2
        write("first", to: screen)
        let first = screen.makeTextAnchor(line: 0, column: 0)
        screen.carriageReturn(); screen.lineFeed()
        write("second", to: screen)
        let second = screen.makeTextAnchor(line: 1, column: 0)
        screen.carriageReturn(); screen.lineFeed()
        write("third", to: screen)
        screen.carriageReturn(); screen.lineFeed()
        write("fourth", to: screen)
        screen.carriageReturn(); screen.lineFeed()
        XCTAssertNil(first.position)
        let before = try XCTUnwrap(second.position)
        XCTAssertEqual(screen.bufferLine(before.line)[before.column].codepoint, 115)
        screen.resize(cols: 8, rows: 4)
        let after = try XCTUnwrap(second.position)
        XCTAssertEqual(screen.bufferLine(after.line)[after.column].codepoint, 115)
        screen.eraseInDisplay(mode: 3)
        XCTAssertNil(second.position)
    }

    func testRegionScrollAndCharacterEditsMoveOrInvalidateAnchors() {
        let screen = TerminalScreen(cols: 8, rows: 4)
        screen.moveCursor(row: 1, col: 0)
        write("abcdef", to: screen)
        let kept = screen.makeTextAnchor(line: 1, column: 4)
        let deleted = screen.makeTextAnchor(line: 1, column: 1)
        screen.moveCursor(row: 1, col: 1)
        screen.deleteCharacters(2)
        XCTAssertNil(deleted.position)
        XCTAssertEqual(kept.position, .init(line: 1, column: 2))
        screen.insertCharacters(1)
        XCTAssertEqual(kept.position, .init(line: 1, column: 3))
        screen.setScrollRegion(top: 1, bottom: 3)
        screen.scrollDown(1)
        XCTAssertEqual(kept.position, .init(line: 2, column: 3))
        screen.moveCursor(row: 2, col: 0)
        screen.eraseInLine(mode: 2)
        XCTAssertNil(kept.position)
    }

    func testRestorationTransfersReferencesAndOldScreenDestructionDoesNotInvalidateThem() {
        var previous: TerminalScreen? = TerminalScreen(cols: 8, rows: 2, recordsHistory: true)
        write("text", to: previous!)
        let anchor = previous!.makeTextAnchor(line: 0, column: 2)
        let restored = TerminalScreen(cols: 8, rows: 4, recordsHistory: true)
        restored.takeTextAnchors(from: previous!, lineOffset: 2)
        previous = nil
        XCTAssertEqual(anchor.position, .init(line: 2, column: 2))
        let next = TerminalScreen(cols: 8, rows: 4, recordsHistory: true)
        next.takeTextAnchors(from: restored, lineOffset: -1)
        XCTAssertEqual(anchor.position, .init(line: 1, column: 2))
        next.fullReset()
        XCTAssertNil(anchor.position)
    }

    func testContextAndAnchorInvalidationWhenScreenIsDestroyed() {
        var screen: TerminalScreen? = TerminalScreen(cols: 8, rows: 2, recordsHistory: true)
        let context = screen!.textAnchorContext()
        let anchor = context.makeAnchor(line: 0, column: 2)
        XCTAssertNotNil(anchor)
        screen = nil
        XCTAssertNil(anchor?.position)
        XCTAssertNil(context.makeAnchor(line: 0, column: 2))
    }

    func testContextTranslatesEvictionAndRejectsCoordinatesChangedByReflow() {
        let screen = TerminalScreen(cols: 8, rows: 2, recordsHistory: true)
        screen.maxHistoryLines = 2
        write("first", to: screen)
        screen.carriageReturn(); screen.lineFeed()
        write("second", to: screen)
        let context = screen.textAnchorContext()
        for text in ["third", "fourth", "fifth"] {
            screen.carriageReturn(); screen.lineFeed()
            write(text, to: screen)
        }
        XCTAssertNil(context.makeAnchor(line: 0, column: 0), "evicted coordinates cannot select replacement text")
        let second = context.makeAnchor(line: 1, column: 0)
        XCTAssertEqual(second?.position, .init(line: 0, column: 0))
        // Narrowing expands the retained lines; keep the fixture's target instead of
        // legitimately evicting it under the deliberately tiny cap used above.
        screen.maxHistoryLines = 100
        let beforeResize = screen.textAnchorContext()
        screen.resize(cols: 4, rows: 2)
        XCTAssertNil(beforeResize.makeAnchor(line: 0, column: 0), "old geometry cannot silently select another cell")
        XCTAssertNotNil(second?.position, "already registered positions follow the reflow")
        XCTAssertNotNil(screen.textAnchorContext().makeAnchor(line: 0, column: 0))
    }

    func testContextCannotRegisterAnUnmappedAnchorDuringReflow() {
        let store = TerminalTextAnchorStore()
        let context = store.context(lineCount: 4, columns: 8)
        let anchor = context.makeAnchor(line: 1, column: 2)
        let remapping = store.beginRemap()
        XCTAssertNil(context.makeAnchor(line: 1, column: 2))
        store.remap(remapping) { .init(line: $0.line + 1, column: $0.column) }
        XCTAssertEqual(anchor?.position, .init(line: 2, column: 2))
        XCTAssertNil(context.makeAnchor(line: 1, column: 2))
    }

    func testCommandBoundarySurvivesPromptEraseButSelectedCellDoesNot() {
        let screen = TerminalScreen(cols: 8, rows: 2, recordsHistory: true)
        write("output", to: screen)
        screen.carriageReturn(); screen.lineFeed()
        let commandEnd = screen.makeCursorTextAnchor()
        let selected = screen.makeTextAnchor(line: 1, column: 0)
        screen.markPromptStart()
        screen.carriageReturn()
        screen.eraseInLine(mode: 0)
        write("prompt", to: screen)
        XCTAssertEqual(commandEnd.position, .init(line: 1, column: 0))
        XCTAssertNil(selected.position)
        screen.eraseInDisplay(mode: 2)
        XCTAssertNotNil(commandEnd.position)
        screen.fullReset()
        XCTAssertNil(commandEnd.position)
    }

}
