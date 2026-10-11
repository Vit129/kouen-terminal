import AppKit
import Metal
import XCTest
import HarnessTerminalRenderer
import HarnessTheme
@testable import HarnessTerminalKit

// XCTest pulls in ApplicationServices, whose QuickDraw `RGBColor` shadows ours.
private typealias RGBColor = HarnessTheme.RGBColor

/// #161: mouse selection is content-anchored (absolute buffer lines), so scrolling — and new
/// output pushing lines into history — must neither clear it nor change what it extracts.
@MainActor
final class SelectionScrollTests: XCTestCase {
    private func drainMainQueue() async {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async { continuation.resume() }
        }
    }

    private func settle(_ view: HarnessTerminalSurfaceView) async {
        view.testingWaitForEmulatorIdle()
        await drainMainQueue()
    }

    func testSelectionSurvivesScrolling() async {
        let view = HarnessTerminalSurfaceView()
        for i in 0 ..< 60 { view.receive("history line \(i) padded out for selection\r\n") }
        await settle(view)

        // A drag's end state on visible content (viewport rows 2…3).
        view.testingSetSelection(anchor: (row: 2, column: 0), head: (row: 3, column: 12))
        let before = view.testingSelectionText()
        XCTAssertNotNil(before, "selection on visible content must extract")

        // Scroll far enough that the selected lines leave the viewport entirely.
        view.testingScrollBy(lines: 30)
        XCTAssertEqual(view.testingSelectionText(), before,
                       "scrolling must not clear or shift the selection")

        // Smooth (fractional) scrolling included, and scrolling back down too.
        view.testingScrollByContinuous(lines: -7.5)
        XCTAssertEqual(view.testingSelectionText(), before,
                       "continuous scrolling must keep the selection")
    }

    func testSelectionStaysOnContentAsNewOutputArrives() async {
        let view = HarnessTerminalSurfaceView()
        for i in 0 ..< 30 { view.receive("steady line \(i)\r\n") }
        await settle(view)

        view.testingSetSelection(anchor: (row: 1, column: 0), head: (row: 1, column: 12))
        let before = view.testingSelectionText()
        XCTAssertNotNil(before)

        // New output pushes the selected line further into history; the selection rides it.
        for i in 30 ..< 45 { view.receive("steady line \(i)\r\n") }
        await settle(view)
        XCTAssertEqual(view.testingSelectionText(), before,
                       "new output must not shift a content-anchored selection")
    }

    func testEvictedSelectionClampsInsteadOfCrashing() async {
        let view = HarnessTerminalSurfaceView()
        for i in 0 ..< 20 { view.receive("early line \(i)\r\n") }
        await settle(view)
        view.testingSetSelection(anchor: (row: 0, column: 0), head: (row: 0, column: 10))
        XCTAssertNotNil(view.testingSelectionText())

        // Push far past the selection; even if the ring evicts the anchored lines, resolution
        // clamps to the retained buffer (copy mode's convention) — never traps.
        let flood = String(repeating: "flood line that keeps the parser busy\r\n", count: 30_000)
        view.receive(flood)
        await settle(view)
        _ = view.testingSelectionText() // must not crash; content may have shifted/evicted
        view.testingScrollBy(lines: 5)
        _ = view.testingSelectionText()
    }

    func testSelectionAndReadingPositionSurviveRepeatedReflow() async {
        let view = HarnessTerminalSurfaceView()
        view.testingResizeGrid(cols: 20, rows: 5)
        view.receive((0..<30).map { "line \($0) abcdefghijklmnop" }.joined(separator: "\r\n") + "\r\n")
        await settle(view)
        view.testingScrollBy(lines: 15)
        view.testingSetSelection(anchor: (row: 1, column: 1), head: (row: 2, column: 3))
        let text = view.testingSelectionText()
        XCTAssertNotNil(text)
        for width in [9, 31, 12, 20] {
            view.testingResizeGrid(cols: width, rows: 5)
            await settle(view)
            XCTAssertEqual(view.testingSelectionText(), text, "width \(width)")
            XCTAssertGreaterThan(view.testingScrollPosition.offset, 0)
        }
    }

    func testWrappedSelectionPreservesInteriorSpacesAndWideDeferral() async {
        let view = HarnessTerminalSurfaceView()
        view.testingResizeGrid(cols: 8, rows: 5)
        view.receive("ab   cd界efghij")
        await settle(view)
        view.testingSetSelection(anchor: (row: 0, column: 0), head: (row: 1, column: 7))
        let text = view.testingSelectionText()
        XCTAssertEqual(text, "ab   cd界efghij")
        for width in [4, 20, 7] {
            view.testingResizeGrid(cols: width, rows: 5)
            XCTAssertEqual(view.testingSelectionText(), text)
        }
    }

    /// The rendered highlight moves WITH the content when the viewport scrolls (Metal-gated).
    func testPresentedSelectionShadingRebasesAcrossScroll() async throws {
        guard MTLCreateSystemDefaultDevice() != nil else { throw XCTSkip("No Metal device available") }
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
            styleMask: [.titled, .resizable], backing: .buffered, defer: false
        )
        window.isReleasedWhenClosed = false
        defer { window.contentView = nil }
        let view = HarnessTerminalSurfaceView()
        window.contentView = view
        guard view.testingHasRenderer else { throw XCTSkip("renderer unavailable") }
        view.layoutSubtreeIfNeeded()

        let selectionBG = RGBColor(red: 60, green: 80, blue: 200)
        view.testingSetSelectionColors(background: selectionBG, foreground: nil)
        for i in 0 ..< 60 { view.receive("scroll shade line \(i) content\r\n") }
        await settle(view)
        view.testingForceRender()
        await drainRenderPipelineAsync(view)
        guard view.testingLastPresentedFrame != nil else {
            throw XCTSkip("no present happened (drawable unavailable)")
        }

        view.testingSetSelection(anchor: (row: 2, column: 0), head: (row: 2, column: 8))
        view.testingForceRender()
        await drainRenderPipelineAsync(view)
        let atRest = try XCTUnwrap(view.testingLastPresentedFrame)
        XCTAssertEqual(atRest.cell(row: 2, column: 4)?.background, RenderColor(selectionBG))

        // Scroll 3 lines back into history: the selected content moves down 3 viewport rows,
        // and the shading must move with it.
        view.testingScrollBy(lines: 3)
        await settle(view)
        view.testingForceRender()
        await drainRenderPipelineAsync(view)
        let scrolled = try XCTUnwrap(view.testingLastPresentedFrame)
        XCTAssertEqual(scrolled.cell(row: 5, column: 4)?.background, RenderColor(selectionBG),
                       "highlight must follow the content, not the viewport")
        XCTAssertNotEqual(scrolled.cell(row: 2, column: 4)?.background, RenderColor(selectionBG),
                          "the old viewport row must not stay shaded")
    }
}
