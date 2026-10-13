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

    func testSafeLocalFileLocationResolutionRejectsTraversalBundlesAndScripts() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("harness-file-loc-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let srcDir = root.appendingPathComponent("Sources", isDirectory: true)
        try FileManager.default.createDirectory(at: srcDir, withIntermediateDirectories: true)
        let swiftFile = srcDir.appendingPathComponent("Example.swift")
        try "let x = 1\n".write(to: swiftFile, atomically: true, encoding: .utf8)

        let scriptFile = root.appendingPathComponent("run.command")
        try "#!/bin/sh\necho hi\n".write(to: scriptFile, atomically: true, encoding: .utf8)

        let appBundle = root.appendingPathComponent("Fake.app", isDirectory: true)
        try FileManager.default.createDirectory(at: appBundle, withIntermediateDirectories: true)

        let validRelative = URLDetection.FileLocationTarget(path: "Sources/Example.swift", line: 1, column: 5)
        let resolved = try XCTUnwrap(
            HarnessTerminalSurfaceView.resolveSafeLocalFileURL(validRelative, workingDirectory: root.path)
        )
        XCTAssertEqual(resolved.path, swiftFile.standardizedFileURL.resolvingSymlinksInPath().path)

        let traversal = URLDetection.FileLocationTarget(path: "../outside.txt", line: 1)
        XCTAssertNil(HarnessTerminalSurfaceView.resolveSafeLocalFileURL(traversal, workingDirectory: srcDir.path))

        let commandTarget = URLDetection.FileLocationTarget(path: "run.command", line: 1)
        XCTAssertNil(HarnessTerminalSurfaceView.resolveSafeLocalFileURL(commandTarget, workingDirectory: root.path))

        let bundleTarget = URLDetection.FileLocationTarget(path: "Fake.app", line: 1)
        XCTAssertNil(HarnessTerminalSurfaceView.resolveSafeLocalFileURL(bundleTarget, workingDirectory: root.path))

        let dirTarget = URLDetection.FileLocationTarget(path: "Sources", line: 1)
        XCTAssertNil(HarnessTerminalSurfaceView.resolveSafeLocalFileURL(dirTarget, workingDirectory: root.path))
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
        XCTAssertGreaterThan(scaled.metrics().height, base.metrics().height)
        XCTAssertGreaterThan(scaled.metrics().width, base.metrics().width)
    }
}
