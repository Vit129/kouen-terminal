import XCTest
@testable import HarnessTerminalEngine

/// The documented edges of the parser and cluster limits (docs/TERMINAL-QUALITY.md, "Input limits").
final class UnicodeAndCSILimitTests: XCTestCase {
    func testLongValidSGRAppliesEveryAttribute() {
        let term = TerminalEmulator(cols: 10, rows: 2)
        term.feed("\u{1b}[0;1;3;4;9;38;2;255;128;0;48;2;0;0;255;58;2;1;2;3mX")
        let cell = term.readGrid().cells[0]
        XCTAssertTrue(cell.bold)
        XCTAssertTrue(cell.italic)
        XCTAssertNotEqual(cell.underline, .none)
        XCTAssertTrue(cell.strikethrough)
        XCTAssertEqual(cell.foreground, .rgb(r: 255, g: 128, b: 0))
        XCTAssertEqual(cell.background, .rgb(r: 0, g: 0, b: 255))
        XCTAssertEqual(cell.underlineColor, .rgb(r: 1, g: 2, b: 3))
    }

    func testColonTruecolorSGRAppliesAlongsideOtherAttributes() {
        let term = TerminalEmulator(cols: 10, rows: 2)
        term.feed("\u{1b}[1;38:2::10:20:30;48:5:21;4:3mX")
        let cell = term.readGrid().cells[0]
        XCTAssertTrue(cell.bold)
        XCTAssertEqual(cell.foreground, .rgb(r: 10, g: 20, b: 30))
        XCTAssertEqual(cell.background, .palette(21))
        XCTAssertEqual(cell.underline, .curly)
    }

    func testThirtyTwoParameterGroupsStillApply() {
        let term = TerminalEmulator(cols: 10, rows: 2)
        let groups = Array(repeating: "1", count: 26) + ["38", "2", "10", "20", "30", "4"]
        XCTAssertEqual(groups.count, 32)
        term.feed("\u{1b}[\(groups.joined(separator: ";"))mX")
        let cell = term.readGrid().cells[0]
        XCTAssertEqual(cell.foreground, .rgb(r: 10, g: 20, b: 30))
        XCTAssertNotEqual(cell.underline, .none)
    }

    func testThirtyThreeParameterGroupsAreIgnoredWhole() {
        let term = TerminalEmulator(cols: 10, rows: 2)
        let groups = Array(repeating: "1", count: 27) + ["38", "2", "10", "20", "30", "4"]
        term.feed("\u{1b}[\(groups.joined(separator: ";"))mX")
        let cell = term.readGrid().cells[0]
        XCTAssertEqual(cell.codepoint, UInt32(UnicodeScalar("X").value), "text after the dropped sequence still prints")
        XCTAssertFalse(cell.bold)
        XCTAssertEqual(cell.foreground, .none)
    }

    func testClusterPastTwoHundredFiftySixBytesKeepsItsPrefix() {
        let term = TerminalEmulator(cols: 10, rows: 2)
        let marks = String(repeating: "\u{0301}", count: 300)
        term.feed("e\(marks)X")
        let line = term.captureLines(joinWrapped: true, history: false).first ?? ""
        XCTAssertTrue(line.hasSuffix("X"), "the next glyph still lands in the next cell")
        let cluster = String(line.dropLast())
        XCTAssertEqual(cluster.count, 1, "extra marks never spill into new cells")
        XCTAssertLessThanOrEqual(cluster.utf8.count, 256)
        XCTAssertTrue(cluster.unicodeScalars.starts(with: "e\u{0301}\u{0301}".unicodeScalars))
        XCTAssertEqual(term.readGrid().cursor.col, 2)
    }

    func testClusterStoreBudgetDegradesToInlineMarks() {
        let term = TerminalEmulator(cols: 400, rows: 200)
        let marks: [UInt32] = [0x0300, 0x0301, 0x0302, 0x0303, 0x0304, 0x0306, 0x0307, 0x0308]
        var text = String.UnicodeScalarView()
        // Four marks force the shared store. 70,000 distinct live clusters exceed 8 MiB.
        for index in 0 ..< 70_000 {
            text.append(Unicode.Scalar(UInt32(0x61 + index % 26))!)
            var rest = index / 26
            for _ in 0 ..< 4 {
                text.append(Unicode.Scalar(marks[rest % marks.count])!)
                rest /= marks.count
            }
        }
        term.feed(String(text))
        let stored = term.clusters.values.reduce(0) { $0 + $1.utf8.count + 128 }
        XCTAssertLessThanOrEqual(stored, 8 * 1024 * 1024, "the cluster store stays within its budget")
        XCTAssertGreaterThan(stored, 8 * 1024 * 1024 - 1024, "the input must fill the store for this test to mean anything")

        term.feed("\r\nZ\u{0301}\u{0300}\u{0302}!")
        let lines = term.captureLines(joinWrapped: true, history: false)
        let row = lines.last { $0.unicodeScalars.first == "Z" } ?? ""
        XCTAssertTrue(row.unicodeScalars.starts(with: "Z\u{0301}\u{0300}".unicodeScalars), "inline marks survive when the store is full")
        XCTAssertTrue(row.hasSuffix("!"), "output after an over-budget cluster still renders")
    }
}
