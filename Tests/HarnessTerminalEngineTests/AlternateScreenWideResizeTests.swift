import XCTest
@testable import HarnessTerminalEngine

/// Shrinking the alternate screen through a wide glyph must not leave a head without its tail.
final class AlternateScreenWideResizeTests: XCTestCase {
    func testShrinkThroughAWideGlyphLeavesNoOrphanHead() {
        let term = TerminalEmulator(cols: 6, rows: 2)
        term.feed("\u{1b}[?1049h\u{1b}[44mab漢d\r\n😀😀😀")
        term.resize(cols: 3, rows: 2)
        let grid = term.readGrid()
        XCTAssertEqual(grid.cols, 3)
        assertNoOrphanWideHeads(grid)
        XCTAssertEqual(grid.cells[2].codepoint, TerminalGridCell.blank.codepoint, "the cut CJK head should become a blank")
        XCTAssertEqual(grid.cells[2].background, grid.cells[0].background, "the gap keeps the line's background")
        XCTAssertEqual(grid.cells[3].width, .wide, "a wide glyph that still fits stays intact")
        XCTAssertEqual(grid.cells[4].width, .spacerTail)
    }

    func testShrinkOnAGlyphBoundaryKeepsTheGlyph() {
        let term = TerminalEmulator(cols: 6, rows: 1)
        term.feed("\u{1b}[?1049h漢字ab")
        term.resize(cols: 4, rows: 1)
        let grid = term.readGrid()
        assertNoOrphanWideHeads(grid)
        XCTAssertEqual(grid.cells[2].width, .wide)
        XCTAssertEqual(grid.cells[3].width, .spacerTail)
    }

    private func assertNoOrphanWideHeads(_ grid: TerminalGridSnapshot, file: StaticString = #filePath, line: UInt = #line) {
        for row in 0 ..< grid.rows {
            for col in 0 ..< grid.cols where grid.cells[row * grid.cols + col].width == .wide {
                let hasTail = col + 1 < grid.cols && grid.cells[row * grid.cols + col + 1].width == .spacerTail
                XCTAssertTrue(hasTail, "wide head at row \(row) col \(col) has no tail", file: file, line: line)
            }
        }
    }
}
