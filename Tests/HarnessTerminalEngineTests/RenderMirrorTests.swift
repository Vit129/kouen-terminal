import XCTest
@testable import HarnessTerminalEngine

final class RenderMirrorTests: XCTestCase {
    func testMirrorMatchesExportAcrossDamageScrollResizeAndScreenSwitch() {
        let term = TerminalEmulator(cols: 12, rows: 5)
        var mirror: TerminalGridSnapshot?
        let streams = ["first", "\r\nsecond\r\nthird\r\nfourth\r\nfifth\r\nsixth",
            "\u{1b}[2;4r\u{1b}[4;1Hregion\nscroll", "\u{1b}[r\u{1b}[2T", "\u{1b}]133;A\u{7}中文👩🏽‍💻",
            "\u{1b}[?1049h\u{1b}[31malt", "\u{1b}[?1049l", "\u{1b}[1;1H\u{1b}[5 q",
            "\u{1b}_Ga=T,f=32,s=1,v=1,i=5;/wAA/w==\u{1b}\\"]
        for stream in streams {
            term.feed(stream)
            term.updateRenderMirror(&mirror, damage: term.consumeDamage())
            XCTAssertEqual(mirror, term.readGrid())
        }
        XCTAssertFalse(mirror!.images.isEmpty)
        let retained = mirror!
        term.resize(cols: 7, rows: 3)
        term.updateRenderMirror(&mirror, damage: term.consumeDamage())
        XCTAssertEqual(mirror, term.readGrid())
        XCTAssertEqual(retained.cols, 12)
        XCTAssertEqual(retained.cells.count, 60)
    }

    func testRetainedFramesShareUnchangedRowsAndCopyOnlyDirtyRows() {
        let term = TerminalEmulator(cols: 80, rows: 5)
        var mirror: TerminalGridSnapshot?
        term.feed("first")
        term.updateRenderMirror(&mirror, damage: term.consumeDamage())
        let previous = mirror!
        let previousClean = previous.withRowCells(row: 1) { UInt(bitPattern: $0.baseAddress!) }
        let previousDirty = previous.withRowCells(row: 2) { UInt(bitPattern: $0.baseAddress!) }
        term.feed("\u{1b}[3;1HZ")
        term.updateRenderMirror(&mirror, damage: term.consumeDamage())
        XCTAssertEqual(mirror!.withRowCells(row: 1) { UInt(bitPattern: $0.baseAddress!) }, previousClean)
        XCTAssertNotEqual(mirror!.withRowCells(row: 2) { UInt(bitPattern: $0.baseAddress!) }, previousDirty)
        XCTAssertEqual(previous.cell(row: 2, col: 0), .blank)
        XCTAssertEqual(mirror!.cell(row: 2, col: 0)?.codepoint, 90)
        XCTAssertEqual(mirror, term.readGrid())
    }

    func testWordDamageMatchesIndexSetAcrossShifts() {
        for rows in [1, 63, 64, 65, 130] {
            var damage = RowDamage(rows: rows)
            var reference = IndexSet()
            for step in 0..<100 {
                let row = (step * 31) % rows
                damage.insert(row)
                reference.insert(row)
                let delta = step % 9 - 4
                damage.shift(by: delta)
                reference = IndexSet(reference.map { $0 + delta }.filter { $0 >= 0 && $0 < rows })
                XCTAssertEqual(damage.indexSet, reference)
                XCTAssertEqual(damage.isEmpty, reference.isEmpty)
            }
            damage.clear()
            damage.insert(0..<rows)
            XCTAssertEqual(damage.indexSet, IndexSet(integersIn: 0..<rows))
        }
    }
}
