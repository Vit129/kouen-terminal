import XCTest
import HarnessTerminalEngine
import HarnessTerminalRenderer
import HarnessTheme
@testable import HarnessTerminalKit

final class TextOverlayLayoutTests: XCTestCase {
    private let theme = HarnessThemeCatalog.theme(named: "Dracula")!

    func testPreeditMatchesCommittedClustersAndAvoidsExistingClusterIDs() throws {
        let builder = FrameBuilder(theme: theme)
        for text in ["👩🏽‍💻", "👨‍👩‍👧‍👦", "각", "क्‍ष", "น้ำ", "a\u{301}\u{323}\u{302}\u{304}"] {
            let committed = TerminalEmulator(cols: 20, rows: 2)
            committed.feed(text)
            let expected = builder.build(committed.readGrid())
            var preedit = builder.build(TerminalEmulator(cols: 20, rows: 2).readGrid())
            preedit.clusters[0x7fff_ffff] = "retained cluster"
            HarnessTerminalSurfaceView.applyPreedit(into: &preedit, text: text, builder: builder,
                canvasForeground: theme.foreground, canvasBackground: theme.background)
            XCTAssertEqual(preedit.clusters[0x7fff_ffff], "retained cluster")
            XCTAssertEqual(preedit.cursor.column, expected.cursor.column, text)
            for column in 0..<expected.cursor.column {
                let actualCell = try XCTUnwrap(preedit.cell(row: 0, column: column))
                let expectedCell = try XCTUnwrap(expected.cell(row: 0, column: column))
                XCTAssertEqual(actualCell.width, expectedCell.width, text)
                XCTAssertEqual(preedit.cluster(for: actualCell), expected.cluster(for: expectedCell), text)
                XCTAssertEqual(actualCell.underline, .single)
            }
        }
    }

    func testPreeditClipsWholeWideClusterAtRightEdge() throws {
        let builder = FrameBuilder(theme: theme)
        var frame = builder.build(TerminalEmulator(cols: 4, rows: 2).readGrid())
        frame.cursor.column = 3
        HarnessTerminalSurfaceView.applyPreedit(into: &frame, text: "👩🏽‍💻", builder: builder,
            canvasForeground: theme.foreground, canvasBackground: theme.background)
        XCTAssertEqual(frame.cell(row: 0, column: 3)?.codepoint, 0)
        XCTAssertEqual(frame.cursor.column, 3)
    }

    func testCopyStatusUsesCellWidthsAndCompleteClusters() throws {
        let builder = FrameBuilder(theme: theme)
        var frame = builder.build(TerminalEmulator(cols: 10, rows: 2).readGrid())
        HarnessTerminalSurfaceView.applyCopyModeStatus(into: &frame, text: "中👩🏽‍💻X", builder: builder,
            selectionBackground: nil, canvasForeground: theme.foreground, canvasBackground: theme.background)
        XCTAssertEqual(frame.cell(row: 1, column: 0)?.width, .wide)
        XCTAssertEqual(frame.cell(row: 1, column: 1)?.width, .spacerTail)
        let emoji = try XCTUnwrap(frame.cell(row: 1, column: 2))
        XCTAssertEqual(frame.cluster(for: emoji), "👩🏽‍💻")
        XCTAssertEqual(frame.cell(row: 1, column: 4)?.codepoint, 0x58)
    }
}
