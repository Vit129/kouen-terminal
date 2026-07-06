import XCTest
@testable import KouenTerminalEngine

/// Mirrors the original the renderer `HeadlessGridReadTests` contract against the native
/// engine, so the two can be A/B-compared and the engine is held to the same bar:
/// `readGrid()` must faithfully report codepoints, SGR colors (palette + RGB),
/// attributes, wide characters, and the cursor.
final class KouenGridTerminalTests: XCTestCase {
    private func feedAndRead(
        _ bytes: String,
        cols: Int = 80,
        rows: Int = 24
    ) -> (KouenGridTerminal, TerminalGridSnapshot)? {
        guard let term = KouenGridTerminal(cols: cols, rows: rows) else {
            XCTFail("KouenGridTerminal failed to create")
            return nil
        }
        term.feed(bytes)
        guard let grid = term.readGrid() else {
            XCTFail("readGrid returned nil")
            return nil
        }
        return (term, grid)
    }

    func testCreatesAtExactSize() {
        guard let term = KouenGridTerminal(cols: 80, rows: 24) else {
            return XCTFail("create failed")
        }
        let grid = term.readGrid()
        XCTAssertEqual(grid?.cols, 80)
        XCTAssertEqual(grid?.rows, 24)
        XCTAssertEqual(grid?.cells.count, 80 * 24)
    }

    func testRejectsZeroSize() {
        XCTAssertNil(KouenGridTerminal(cols: 0, rows: 24))
        XCTAssertNil(KouenGridTerminal(cols: 80, rows: 0))
    }

    func testResizeIsExactAndSynchronous() {
        guard let term = KouenGridTerminal(cols: 80, rows: 24) else {
            return XCTFail("create failed")
        }
        term.resize(cols: 120, rows: 40)
        let grid = term.readGrid()
        XCTAssertEqual(grid?.cols, 120)
        XCTAssertEqual(grid?.rows, 40)
        XCTAssertEqual(grid?.cells.count, 120 * 40)
    }

    func testPlainTextLandsInCells() {
        guard let (_, grid) = feedAndRead("Hello") else { return }
        let expected = Array("Hello".unicodeScalars).map { UInt32($0.value) }
        for (i, cp) in expected.enumerated() {
            XCTAssertEqual(grid.cell(row: 0, col: i)?.codepoint, cp, "mismatch at col \(i)")
        }
    }

    func testForegroundPaletteColor() {
        guard let (_, grid) = feedAndRead("\u{1b}[31mR") else { return }
        XCTAssertEqual(grid.cell(row: 0, col: 0)?.foreground, .palette(1))
    }

    func testBrightForegroundPaletteColor() {
        // SGR 91 = bright red (palette index 9).
        guard let (_, grid) = feedAndRead("\u{1b}[91mR") else { return }
        XCTAssertEqual(grid.cell(row: 0, col: 0)?.foreground, .palette(9))
    }

    func test256Color() {
        guard let (_, grid) = feedAndRead("\u{1b}[38;5;208mO") else { return }
        XCTAssertEqual(grid.cell(row: 0, col: 0)?.foreground, .palette(208))
    }

    func testTrueColorBackground() {
        guard let (_, grid) = feedAndRead("\u{1b}[48;2;10;20;30mX") else { return }
        XCTAssertEqual(grid.cell(row: 0, col: 0)?.background, .rgb(r: 10, g: 20, b: 30))
    }

    func testAttributesBoldItalicUnderline() {
        guard let (_, grid) = feedAndRead("\u{1b}[1;3;4mA") else { return }
        guard let cell = grid.cell(row: 0, col: 0) else { return XCTFail("no cell") }
        XCTAssertTrue(cell.bold)
        XCTAssertTrue(cell.italic)
        XCTAssertEqual(cell.underline, .single)
    }

    func testInverseAttribute() {
        guard let (_, grid) = feedAndRead("\u{1b}[7mI") else { return }
        XCTAssertTrue(grid.cell(row: 0, col: 0)?.inverse ?? false)
    }

    func testSGRResetClearsAttributes() {
        guard let (_, grid) = feedAndRead("\u{1b}[1;31mA\u{1b}[0mB") else { return }
        XCTAssertTrue(grid.cell(row: 0, col: 0)?.bold ?? false)
        XCTAssertFalse(grid.cell(row: 0, col: 1)?.bold ?? true)
        XCTAssertEqual(grid.cell(row: 0, col: 1)?.foreground, TerminalGridColor.none)
    }

    func testWideCharacter() {
        guard let (_, grid) = feedAndRead("世") else { return }
        XCTAssertEqual(grid.cell(row: 0, col: 0)?.width, .wide)
        XCTAssertEqual(grid.cell(row: 0, col: 1)?.width, .spacerTail)
        XCTAssertEqual(grid.cell(row: 0, col: 0)?.codepoint, 0x4E16)
    }

    func testCursorPosition() {
        guard let (_, grid) = feedAndRead("\u{1b}[5;10H") else { return }
        XCTAssertEqual(grid.cursor.row, 4)
        XCTAssertEqual(grid.cursor.col, 9)
        XCTAssertTrue(grid.cursor.visible)
    }

    func testNewlinesAdvanceRows() {
        guard let (_, grid) = feedAndRead("a\r\nb\r\nc") else { return }
        XCTAssertEqual(grid.cell(row: 0, col: 0)?.codepoint, UInt32(UnicodeScalar("a").value))
        XCTAssertEqual(grid.cell(row: 1, col: 0)?.codepoint, UInt32(UnicodeScalar("b").value))
        XCTAssertEqual(grid.cell(row: 2, col: 0)?.codepoint, UInt32(UnicodeScalar("c").value))
    }

    // MARK: - capture-pane (-J join wrapped)

    func testCaptureJoinsSoftWrappedLines() {
        guard let term = KouenGridTerminal(cols: 10, rows: 6) else { return XCTFail() }
        // 25 chars with no newline autowraps across 3 physical rows; then a hard line.
        term.feed("0123456789abcdefghijABCDE\r\nnext")

        let physical = term.captureLines(joinWrapped: false)
        XCTAssertEqual(physical.prefix(4).map { $0 }, ["0123456789", "abcdefghij", "ABCDE", "next"],
                       "without -J each physical row is its own line")

        let joined = term.captureLines(joinWrapped: true)
        XCTAssertEqual(joined.prefix(2).map { $0 }, ["0123456789abcdefghijABCDE", "next"],
                       "with -J the soft-wrapped rows rejoin into one logical line")
    }

    func testCaptureReflectsOverwrites() {
        guard let term = KouenGridTerminal(cols: 20, rows: 4) else { return XCTFail() }
        // A carriage return returns to column 0; "done" overwrites "load" → "doneing...".
        // Grid capture shows the final on-screen state — a raw byte-stream strip would keep
        // the literal "loading...\rdone" instead.
        term.feed("loading...\rdone")
        XCTAssertEqual(term.captureLines(joinWrapped: false).first, "doneing...")
    }

    // MARK: - Block forwarding (P34 F3 — what RealPty.block(id:) calls into after replaying
    // retained scrollback through a fresh KouenGridTerminal, the same way captureGrid does)

    func testLastBlockForwardsFromEmulator() {
        guard let term = KouenGridTerminal(cols: 40, rows: 10) else { return XCTFail() }
        let cmd = Data("swift build".utf8).base64EncodedString()
        term.feed("\u{1b}]133;A\u{07}$ ")
        term.feed("\u{1b}]133;C;\(cmd)\u{07}\r\nBuild complete!\r\n")
        term.feed("\u{1b}]133;D;0\u{07}")
        XCTAssertEqual(term.lastBlock?.command, "swift build")
        XCTAssertEqual(term.lastBlock?.exitCode, 0)
    }

    func testBlockByIDForwardsFromEmulator() {
        guard let term = KouenGridTerminal(cols: 40, rows: 10) else { return XCTFail() }
        let cmd = Data("echo hi".utf8).base64EncodedString()
        term.feed("\u{1b}]133;A\u{07}$ ")
        term.feed("\u{1b}]133;C;\(cmd)\u{07}\r\n")
        term.feed("\u{1b}]133;D;0\u{07}")
        guard let id = term.lastBlock?.id else { return XCTFail("expected a block") }
        XCTAssertEqual(term.block(id: id)?.command, "echo hi")
        XCTAssertNil(term.block(id: id + 1), "no block with that id")
    }
}
