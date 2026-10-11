import XCTest
@testable import HarnessTerminalEngine

final class TerminalTextLayoutTests: XCTestCase {
    func testClusterExactlyFillingRowRetainsAllExtenders() {
        let layout = TerminalTextLayout(text: "👩🏽‍💻", columns: 2)
        XCTAssertEqual(layout.cells.count, 2)
        XCTAssertEqual(layout.cells[0].resolvedCluster(in: layout.clusters), "👩🏽‍💻")
        XCTAssertEqual(layout.cells[1].width, .spacerTail)
    }

    func testLiteralLayoutDoesNotInterpretEscapeCommands() {
        let layout = TerminalTextLayout(text: "\u{1b}[2Jhello", columns: 20)
        let visible = layout.cells.map { $0.resolvedCluster(in: layout.clusters) }.joined()
        XCTAssertEqual(visible, "[2Jhello")
    }

    func testEmptyAndClippedWideTextHaveNoPartialCells() {
        XCTAssertTrue(TerminalTextLayout(text: "hello", columns: 0).cells.isEmpty)
        XCTAssertTrue(TerminalTextLayout(text: "中", columns: 1).cells.isEmpty)
        XCTAssertTrue(TerminalTextLayout(text: "❤️", columns: 1).cells.isEmpty)
        XCTAssertEqual(TerminalTextLayout(text: "A中", columns: 2).cells.map(\.codepoint), [65])
    }
}
