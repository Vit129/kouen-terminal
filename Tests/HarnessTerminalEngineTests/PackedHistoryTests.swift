import XCTest
@testable import HarnessTerminalEngine

final class PackedHistoryTests: XCTestCase {
    func testRandomStyledRowsDecodeIdenticallyToUnencodedCells() {
        var random: UInt64 = 0x4852_4E53
        func next() -> UInt64 {
            random = random &* 6_364_136_223_846_793_005 &+ 1
            return random
        }
        let styles = PackedHistoryBlock()
        for iteration in 0..<128 {
            var cells = Array(repeating: TerminalGridCell.blank, count: 160)
            let length = Int(next() % 130)
            for column in 0..<length {
                let value = next()
                var cell = TerminalGridCell(codepoint: iteration & 1 == 0 ? UInt32(32 + value % 95) : UInt32(0x400 + value % 128),
                    foreground: column & 3 == 0 ? .palette(UInt8(value % 16)) : .none,
                    background: column & 7 == 0 ? .rgb(r: 1, g: 20, b: 31) : .none,
                    underlineColor: column & 15 == 0 ? .palette(4) : .none,
                    bold: value & 1 != 0, faint: value & 2 != 0, italic: value & 4 != 0,
                    underline: TerminalGridUnderline(rawValue: UInt16(value % 6))!,
                    blink: value & 8 != 0, inverse: value & 16 != 0, invisible: value & 32 != 0,
                    strikethrough: value & 64 != 0, overline: value & 128 != 0)
                if column % 11 == 0 { cell.combining0 = 0x301; cell.combining1 = 0x323 }
                if column % 13 == 0 { cell.clusterID = UInt32(column + 1) }
                if column % 17 == 0 { cell.hyperlinkID = UInt32(column + 3); cell.placeholderMark = 0x1234 }
                if column % 19 == 0 { cell.width = .wide }
                if column % 19 == 1 { cell.width = .spacerTail }
                cells[column] = cell
            }
            // A styled empty glyph must survive trimming, including its original position.
            cells[139] = TerminalGridCell(background: .palette(6))
            let hard = PackedHistoryLine(cells: cells, wrapped: false, block: styles)
            let soft = PackedHistoryLine(cells: cells, wrapped: true, block: styles)
            XCTAssertEqual(hard.cells, cells)
            XCTAssertEqual(soft.cells, cells)
            XCTAssertEqual(hard.reflowCells, Array(cells.prefix(140)))
            XCTAssertEqual(soft.reflowCells, cells)
            var clusters = Set<UInt32>()
            hard.collectClusterIDs(into: &clusters)
            XCTAssertEqual(clusters, Set(cells.map(\.clusterID).filter { $0 != 0 }))
        }
    }

    func testCompactHistoryMatchesRawViewportVTStreamAndSearch() {
        let compact = TerminalEmulator(cols: 32, rows: 5)
        let raw = TerminalEmulator(cols: 32, rows: 400)
        var seed: UInt64 = 57
        let fragments = ["plain", "中文", "a\u{301}\u{323}\u{302}", "👩🏽‍💻", "  ", "\u{1b}[38;2;12;34;56mred\u{1b}[0m", "\u{1b}]8;;https://example.com\u{7}link\u{1b}]8;;\u{7}"]
        for index in 0..<90 {
            seed = seed &* 6_364_136_223_846_793_005 &+ 1
            let payload = "\u{1b}]133;A\u{7}\(index): " + fragments[Int(seed % UInt64(fragments.count))] + "\u{1b}[0m tail\r\n"
            compact.feed(payload)
            raw.feedScalarwise(Array(payload.utf8))
        }
        let compactText = compact.textSnapshot()
        let rawText = raw.textSnapshot()
        for index in 0..<compactText.lineCount {
            XCTAssertEqual(compactText.line(index), rawText.line(index))
            XCTAssertEqual(compactText.isWrapped(index), rawText.isWrapped(index))
        }
        XCTAssertEqual(compact.promptRows, raw.promptRows)
        for query in ["tail", "中文", "a\u{301}", "link"] {
            XCTAssertEqual(TerminalBufferSearch.search(query: query, lineCount: compactText.lineCount,
                clusters: compactText.clusters, isWrapped: compactText.isWrapped, line: compactText.line),
                TerminalBufferSearch.search(query: query, lineCount: compactText.lineCount,
                    clusters: rawText.clusters, isWrapped: rawText.isWrapped, line: rawText.line))
        }
    }

    func testSnapshotRowsStayImmutableWhileSharedBlockGrows() {
        let block = PackedHistoryBlock()
        let expected = Array(repeating: TerminalGridCell(codepoint: 120, foreground: .palette(1)), count: 160)
        let first = PackedHistoryLine(cells: expected, wrapped: false, block: block)
        let reader = DispatchGroup()
        reader.enter()
        DispatchQueue.global().async {
            for _ in 0..<1_000 { XCTAssertEqual(first.cells, expected) }
            reader.leave()
        }
        for index in 1..<128 {
            let cells = Array(repeating: TerminalGridCell(codepoint: index & 1 == 0 ? 0x4e2d : 120,
                foreground: .palette(UInt8(index % 16))), count: 160 + index * 7)
            let row = PackedHistoryLine(cells: cells, wrapped: true, block: block)
            XCTAssertEqual(row.cells, cells)
        }
        XCTAssertEqual(reader.wait(timeout: .now() + 3), .success)
        XCTAssertEqual(first.cells, expected)
    }

    func testRandomVTStreamMatchesFullRowsThroughReflowAndEviction() {
        let packed = TerminalEmulator(cols: 32, rows: 5)
        // This viewport is tall enough to hold the reference stream without encoding history.
        let reference = TerminalEmulator(cols: 32, rows: 1_000)
        var seed: UInt64 = 0x5645_4354
        let fragments = ["plain", "中文", "a\u{301}\u{323}\u{302}", "👩🏽‍💻", "  ",
            "\u{1b}[1;38;2;12;34;56mstyled\u{1b}[0m", "\u{1b}[4:3;58:2::9:8:7munder\u{1b}[0m",
            "\u{1b}]8;;https://example.com\u{7}link\u{1b}]8;;\u{7}"]
        func feed(_ count: Int, fragments choices: [String] = []) {
            let choices = choices.isEmpty ? fragments : choices
            for index in 0..<count {
                seed = seed &* 6_364_136_223_846_793_005 &+ 1
                let payload = "\u{1b}]133;A\u{7}\(index): " + choices[Int(seed % UInt64(choices.count))] + "\u{1b}[0m tail\r\n"
                packed.feed(payload)
                reference.feedScalarwise(Array(payload.utf8))
            }
        }
        func compare() {
            let actual = packed.textSnapshot()
            let expected = reference.textSnapshot()
            let retained = packed.historyCount + packed.readGrid().cursor.row + 1
            let referenceCount = reference.historyCount + reference.readGrid().cursor.row + 1
            let dropped = referenceCount - retained
            XCTAssertGreaterThanOrEqual(dropped, 0)
            guard dropped >= 0 else { return }
            for index in 0..<retained {
                let raw = expected.line(dropped + index)
                XCTAssertEqual(actual.line(index), raw, "retained row \(index)")
                XCTAssertEqual(actual.isWrapped(index), expected.isWrapped(dropped + index))
                XCTAssertEqual(actual.line(index).map { $0.resolvedCluster(in: actual.clusters) },
                    raw.map { $0.resolvedCluster(in: expected.clusters) })
            }
            XCTAssertEqual(packed.promptRows, reference.promptRows.filter { $0 >= dropped }.map { $0 - dropped })
            for query in ["tail", "中文", "a\u{301}", "link", "styled"] {
                XCTAssertEqual(TerminalBufferSearch.search(query: query, lineCount: retained,
                    clusters: actual.clusters, isWrapped: actual.isWrapped, line: actual.line),
                    TerminalBufferSearch.search(query: query, lineCount: retained, clusters: expected.clusters,
                        isWrapped: { expected.isWrapped(dropped + $0) }, line: { expected.line(dropped + $0) }))
            }
        }
        feed(70)
        compare()
        for columns in [23, 48, 17] {
            packed.resize(cols: columns, rows: 5)
            reference.resize(cols: columns, rows: 1_000)
            compare()
        }
        packed.maxScrollbackLines = 12
        // Avoid re-interning evicted exceptional clusters: their local pool IDs may
        // legitimately differ from the reference's pool, which never evicts rows.
        feed(80, fragments: [fragments[0], fragments[1], "a\u{301}\u{323}"] + Array(fragments[4...]))
        compare()
        XCTAssertLessThanOrEqual(packed.historyCount, 15)
        XCTAssertEqual(reference.historyCount, 0)
    }

    func testStyledHistoryUsesPackedPayloadAndSharedStyles() {
        let term = TerminalEmulator(cols: 160, rows: 3)
        term.maxScrollbackLines = 0
        for index in 0..<1_000 {
            term.feed("\u{1b}[31;1magent \(index)\u{1b}[0m " + String(repeating: "x", count: 100) + "\r\n")
        }
        XCTAssertGreaterThan(term.historyCount, 990)
        XCTAssertLessThan(term.decodedHistoryBytes, 1_000_000)
        let snapshot = term.textSnapshot()
        term.feed("\u{1b}[3J")
        XCTAssertEqual(term.decodedHistoryBytes, 0)
        XCTAssertEqual(snapshot.line(0)[0].foreground, .palette(1))
    }
}
