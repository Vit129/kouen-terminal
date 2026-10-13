import AppKit
import Metal
import XCTest
@testable import HarnessTerminalKit

@MainActor
final class LinkHoverTests: XCTestCase {
    private func makeView() throws -> (HarnessTerminalSurfaceView, NSWindow) {
        guard MTLCreateSystemDefaultDevice() != nil else { throw XCTSkip("Metal unavailable") }
        let view = HarnessTerminalSurfaceView()
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 640, height: 480), styleMask: [.titled],
                              backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.contentView = view
        view.layoutSubtreeIfNeeded()
        view.testingResizeGrid(cols: 60, rows: 8)
        return (view, window)
    }

    func testHoverInsideOneLinkProbesOnce() throws {
        let (view, window) = try makeView()
        defer { window.contentView = nil; window.close() }
        view.receive("see https://example.com/path here\r\n")
        view.testingWaitForEmulatorIdle()
        guard view.testingCommandHover(row: 0, column: 6) else { throw XCTSkip("Cell geometry unavailable") }
        XCTAssertEqual(view.testingHoveredLink?.columns, 4 ..< 28)
        XCTAssertEqual(view.testingLinkProbeCount, 1)
        for column in 7 ..< 28 { view.testingCommandHover(row: 0, column: column) }
        view.testingCommandHover(row: 0, column: 6)
        XCTAssertEqual(view.testingLinkProbeCount, 1, "moving inside the hovered link must not re-read the emulator")
        view.testingCommandHover(row: 0, column: 30)
        XCTAssertNil(view.testingHoveredLink)
        view.testingCommandHover(row: 0, column: 30)
        XCTAssertEqual(view.testingLinkProbeCount, 2, "a repeated miss on one cell is not re-probed")
    }

    func testOutputInvalidatesTheHoverProbe() throws {
        let (view, window) = try makeView()
        defer { window.contentView = nil; window.close() }
        view.receive("plain text\r\n")
        view.testingWaitForEmulatorIdle()
        guard view.testingCommandHover(row: 1, column: 2) else { throw XCTSkip("Cell geometry unavailable") }
        XCTAssertNil(view.testingHoveredLink)
        view.receive("https://example.com\r\n")
        view.testingWaitForEmulatorIdle()
        view.testingCommandHover(row: 1, column: 2)
        XCTAssertEqual(view.testingHoveredLink?.columns, 0 ..< 19, "new output under a resting pointer is re-probed")
    }

    /// VoiceOver asks for several attributes per action. Streaming output used to rebuild the
    /// whole buffer for each one.
    func testVoiceOverQueriesShareOneSnapshotWhileOutputStreams() async throws {
        let view = HarnessTerminalSurfaceView()
        view.testingResizeGrid(cols: 40, rows: 6)
        view.receive("first\r\n")
        view.testingWaitForEmulatorIdle()
        _ = view.accessibilityValue()
        let baseline = view.testingAccessibleRebuildCount
        for i in 0 ..< 20 {
            view.receive("chunk \(i)\r\n")
            _ = view.accessibilityValue()
            _ = view.accessibilityNumberOfCharacters()
            _ = view.accessibilityVisibleCharacterRange()
        }
        XCTAssertEqual(view.testingAccessibleRebuildCount, baseline, "queries inside the cache lifetime reuse one snapshot")
        view.testingWaitForEmulatorIdle()
        try await Task.sleep(nanoseconds: UInt64(HarnessTerminalSurfaceView.accessibleCacheLifetime * 1_000_000_000) + 50_000_000)
        let value = view.accessibilityValue() as? String ?? ""
        XCTAssertTrue(value.contains("chunk 19"), "a query after the lifetime sees the latest output")
        XCTAssertEqual(view.testingAccessibleRebuildCount, baseline + 1)
    }

    func testHyperlinksStayWebLinksAndRemotePanesSkipFileReferences() {
        let view = HarnessTerminalSurfaceView()
        view.testingResizeGrid(cols: 60, rows: 4)
        let disguised = "harness-file://open?path=/etc/hosts&line=1"
        view.receive("\u{1B}]8;;\(disguised)\u{1B}\\click me\u{1B}]8;;\u{1B}\\\r\nSources/App.swift:3:1 failed\r\n")
        view.testingWaitForEmulatorIdle()
        XCTAssertEqual(view.linkRange(atRow: 0, column: 2)?.link, .web(disguised))
        XCTAssertEqual(view.linkRange(atRow: 1, column: 2)?.link, .file(path: "Sources/App.swift"))
        view.opensLocalFileLinks = false
        XCTAssertNil(view.linkRange(atRow: 1, column: 2), "a remote pane's paths name files on that machine")
    }

    func testHyperlinkSpanUsesTheScrolledRow() throws {
        let (view, window) = try makeView()
        defer { window.contentView = nil; window.close() }
        view.receive("\u{1B}]8;;https://example.com/a\u{1B}\\linked\u{1B}]8;;\u{1B}\\ tail\r\n")
        for i in 0 ..< 20 { view.receive("filler \(i)\r\n") }
        view.testingWaitForEmulatorIdle()
        view.testingScrollBy(lines: 100)
        XCTAssertGreaterThan(view.testingScrollPosition.offset, 0)
        guard view.testingCommandHover(row: 0, column: 2) else { throw XCTSkip("Cell geometry unavailable") }
        XCTAssertEqual(view.testingHoveredLink?.columns, 0 ..< 6, "the oldest history row is the hyperlink")
    }
}
