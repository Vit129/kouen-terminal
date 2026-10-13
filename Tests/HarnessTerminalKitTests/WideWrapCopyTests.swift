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

    func testErasedLastColumnBeforeWideGlyphIsKeptAcrossCaptureCopySearchReflowAndRestore() throws {
        let input = "abcd漢\u{1b}[1;4H\u{1b}[1X"
        assertCopyMatchesCapture(input, expected: "abc 漢")

        let emulator = TerminalEmulator(cols: 4, rows: 3)
        emulator.feed(input)
        let snapshot = emulator.textSnapshot()
        XCTAssertEqual(snapshot.logicalText(startingAt: 0).text.text.trimmingCharacters(in: .whitespaces), "abc 漢")
        if case let .matches(matches, _) = TerminalBufferSearch.search(
            query: "abc 漢",
            lineCount: snapshot.lineCount,
            clusters: snapshot.clusters,
            isWrapped: snapshot.isWrapped,
            isWideDeferred: snapshot.isWideDeferred,
            line: snapshot.line
        ) {
            XCTAssertEqual(matches.count, 1)
        } else {
            XCTFail("Expected search match for erased blank before wide glyph")
        }

        let checkpoint = try emulator.checkpoint()
        let restored = TerminalEmulator(cols: 4, rows: 3)
        try restored.restore(checkpoint)
        XCTAssertEqual(restored.captureLines(joinWrapped: true, history: false).first, "abc 漢")

        emulator.resize(cols: 8, rows: 3)
        XCTAssertEqual(emulator.captureLines(joinWrapped: true, history: false).first, "abc 漢")
    }

    func testDeferralFlagClearedByEraseAndKeptThroughRestore() throws {
        // "abc" + 漢 in 4 columns defers 漢, leaving a gap; erasing that cell makes it content.
        assertCopyMatchesCapture("abc漢\u{1b}[1;4H\u{1b}[1X", expected: "abc 漢")

        let deferred = TerminalEmulator(cols: 4, rows: 3)
        deferred.feed("abc漢")
        let restored = TerminalEmulator(cols: 4, rows: 3)
        try restored.restore(deferred.checkpoint())
        XCTAssertEqual(restored.captureLines(joinWrapped: true, history: false).first, "abc漢")
        restored.resize(cols: 8, rows: 3)
        XCTAssertEqual(restored.captureLines(joinWrapped: true, history: false).first, "abc漢")
    }

    func testLocalTextFileResolution() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("harness-file-loc-\(UUID().uuidString)", isDirectory: true)
        let sources = root.appendingPathComponent("Sources", isDirectory: true)
        try FileManager.default.createDirectory(at: sources, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let file = sources.appendingPathComponent("Example.swift")
        try "let x = 1\n".write(to: file, atomically: true, encoding: .utf8)
        try FileManager.default.createDirectory(at: root.appendingPathComponent("Fake.app"), withIntermediateDirectories: true)
        let expected = file.standardizedFileURL.resolvingSymlinksInPath().path

        func resolve(_ path: String, in directory: URL? = root) -> String? {
            HarnessTerminalSurfaceView.localTextFileURL(path: path, workingDirectory: directory?.path)?.path
        }
        XCTAssertEqual(resolve("Sources/Example.swift"), expected)
        XCTAssertEqual(resolve("../Sources/Example.swift", in: sources), expected, "monorepo tools print parent paths")
        XCTAssertEqual(resolve(file.path, in: nil), expected)
        XCTAssertNil(resolve("Sources/Example.swift", in: nil), "a relative path needs a working directory")
        XCTAssertNil(resolve("Sources"), "directories are not files")
        XCTAssertNil(resolve("Fake.app"), "bundles are not files")
        XCTAssertNil(resolve("Missing.swift"))
    }

    func testLineHeightAndCellWidthMultipliersScaleRasterizerMetrics() {
        let base = GlyphRasterizer(fontFamily: "Menlo", size: 14, scale: 2.0)
        let scaled = GlyphRasterizer(
            fontFamily: "Menlo",
            size: 14,
            scale: 2.0,
            lineHeightMultiplier: 1.25,
            cellWidthMultiplier: 1.15
        )
        let natural = base.metrics(), taller = scaled.metrics()
        XCTAssertGreaterThan(taller.height, natural.height)
        XCTAssertGreaterThan(taller.width, natural.width)
        XCTAssertEqual(natural.linePadding, 0)
        XCTAssertEqual(taller.linePadding, (taller.height - natural.height) / 2)
        XCTAssertEqual(taller.ascent, natural.ascent + taller.linePadding, accuracy: 0.001, "glyphs stay centered")
    }
}
