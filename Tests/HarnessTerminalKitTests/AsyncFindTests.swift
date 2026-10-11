import AppKit
import Metal
import XCTest
import HarnessCore
import HarnessTerminalEngine
@testable import HarnessTerminalKit

@MainActor
final class AsyncFindTests: XCTestCase {
    func testRecordedRegexMatchIsShadedInPresentedFrame() throws {
        guard MTLCreateSystemDefaultDevice() != nil else { throw XCTSkip("Metal unavailable") }
        let view = HarnessTerminalSurfaceView()
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 640, height: 480), styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false; window.contentView = view
        defer { window.contentView = nil; window.close() }
        view.layoutSubtreeIfNeeded()
        view.receive("fresh native acceptance\r\n")
        view.testingWaitForEmulatorIdle()
        XCTAssertTrue(view.revealRegexSearchResult(line: 0, fingerprint: OutputSearch.fingerprint("fresh native acceptance"), span: OutputSearchSpan(location: 0, length: 12)))
        view.testingForceRender()
        drainRenderPipeline(view)
        guard let frame = view.testingLastPresentedFrame else { throw XCTSkip("Drawable unavailable") }
        XCTAssertNotEqual(frame.cells[0].background, frame.cells[13].background, "A valid span must change the rendered cells, not just the find state")
        XCTAssertNotEqual(frame.cells[0].foreground, frame.cells[13].foreground)
    }

    func testRecordedRegexHighlightSurvivesRemountAndClearsOnOutput() {
        let view = HarnessTerminalSurfaceView()
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 640, height: 480), styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false; window.contentView = view
        defer { window.close() }
        view.receive("fresh native acceptance\r\n")
        XCTAssertTrue(view.revealRegexSearchResult(line: 0, fingerprint: OutputSearch.fingerprint("fresh native acceptance"), span: OutputSearchSpan(location: 0, length: 12)))
        XCTAssertNotNil(view.currentFindMatchRect())
        view.viewDidMoveToWindow()
        XCTAssertNotNil(view.currentFindMatchRect(), "Rehosting an unchanged pane must retain its verified span")
        XCTAssertTrue(view.revealRegexSearchResult(line: 1, fingerprint: OutputSearch.fingerprint("fresh native acceptance"), span: OutputSearchSpan(location: 0, length: 12)), "A unique identical line can be mapped across host/client reflow offsets")
        XCTAssertNotNil(view.currentFindMatchRect())
        view.receive("changed\r\n")
        XCTAssertNil(view.currentFindMatchRect(), "New output invalidates a recorded span rather than searching regex on the UI queue")
        view.receive("fresh native acceptance\r\n")
        XCTAssertFalse(view.revealRegexSearchResult(line: 1, fingerprint: OutputSearch.fingerprint("fresh native acceptance"), span: OutputSearchSpan(location: 0, length: 12)), "Do not guess between duplicate nearby lines")
    }

    func testReturnCommitsMarkedTextBeforeNavigatingMatches() {
        let bar = TerminalFindBar(frame: .zero)
        let editor = NSTextView()
        var navigations = 0
        bar.onNext = { navigations += 1 }
        editor.setMarkedText("に", selectedRange: NSRange(location: 1, length: 0),
                             replacementRange: NSRange(location: NSNotFound, length: 0))
        XCTAssertTrue(editor.hasMarkedText())
        XCTAssertFalse(bar.control(NSSearchField(), textView: editor, doCommandBy: #selector(NSResponder.insertNewline(_:))))
        XCTAssertEqual(navigations, 0)
        editor.unmarkText()
        XCTAssertTrue(bar.control(NSSearchField(), textView: editor, doCommandBy: #selector(NSResponder.insertNewline(_:))))
        XCTAssertEqual(navigations, 1)
    }

    func testNewQueryReplacesPendingSearchAndInvalidRegexIsReported() async {
        let view = HarnessTerminalSurfaceView()
        view.receive("old old old\r\n世界 family 👩🏽‍💻\r\n")
        let found = expectation(description: "Only the latest query lands")
        view.onFindResultsChanged = { _, count in
            if count > 0 { XCTAssertEqual(count, 1); found.fulfill() }
        }
        view.updateFind(query: "old")
        view.updateFind(query: "世界")
        await fulfillment(of: [found], timeout: 2)
        view.onFindResultsChanged = nil
        let invalid = expectation(description: "Regex error is visible")
        view.onFindStatusChanged = { status in
            if status?.hasPrefix("Invalid pattern:") == true { invalid.fulfill() }
        }
        view.updateFind(query: "[", options: TerminalBufferSearchOptions(isRegex: true))
        await fulfillment(of: [invalid], timeout: 2)
        view.endFind()
    }
    func testCurrentMatchSurvivesWidthReflow() async {
        let view = HarnessTerminalSurfaceView()
        view.testingResizeGrid(cols: 30, rows: 6)
        view.receive("first needle in a long line\r\nsecond needle in a long line\r\n")
        view.testingWaitForEmulatorIdle()
        let initial = expectation(description: "Initial search")
        view.onFindResultsChanged = { current, count in
            if current == 1, count == 2 { initial.fulfill() }
        }
        view.updateFind(query: "needle")
        await fulfillment(of: [initial], timeout: 2)
        view.onFindResultsChanged = nil
        view.findNext()
        let resized = expectation(description: "Same selected match after resize")
        view.onFindResultsChanged = { current, count in
            if count == 2 {
                XCTAssertEqual(current, 2)
                resized.fulfill()
            }
        }
        view.testingResizeGrid(cols: 9, rows: 6)
        await fulfillment(of: [resized], timeout: 2)
        view.onFindResultsChanged = nil
        view.endFind()
    }

}
