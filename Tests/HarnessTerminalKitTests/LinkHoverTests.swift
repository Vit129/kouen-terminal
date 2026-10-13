import AppKit
import Metal
import XCTest
@testable import HarnessTerminalKit

@MainActor
final class LinkHoverTests: XCTestCase {
    private func makeView() throws -> (HarnessTerminalSurfaceView, NSWindow) {
        guard MTLCreateSystemDefaultDevice() != nil else { throw XCTSkip("Metal unavailable") }
        let view = HarnessTerminalSurfaceView()
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 640, height: 480), styleMask: [.titled], backing: .buffered, defer: false)
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
