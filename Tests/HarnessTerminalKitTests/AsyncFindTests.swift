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

    /// Output used to clear the matches and restart the debounce on every chunk, so a steady
    /// stream kept Find at zero results. Results must stay visible, refresh while output
    /// arrives, and report "Updating…" until the stream settles.
    func testResultsStayVisibleAndRefreshWhileOutputStreams() async throws {
        let view = HarnessTerminalSurfaceView()
        view.testingResizeGrid(cols: 40, rows: 10)
        view.receive("needle one\r\n")
        view.testingWaitForEmulatorIdle()
        let initial = expectation(description: "Initial search")
        view.onFindResultsChanged = { _, count in if count == 1 { initial.fulfill() } }
        view.updateFind(query: "needle")
        await fulfillment(of: [initial], timeout: 2)

        var counts: [Int] = []
        var statuses: [String?] = []
        view.onFindResultsChanged = { _, count in counts.append(count) }
        view.onFindStatusChanged = { statuses.append($0) }
        let streamEnd = Date().addingTimeInterval(1.2)
        var line = 0
        while Date() < streamEnd {
            line += 1
            view.receive("output \(line)\(line % 5 == 0 ? " needle" : "")\r\n")
            try await Task.sleep(nanoseconds: 30_000_000)
        }
        XCTAssertFalse(counts.contains(0), "streaming output must not blank the results")
        XCTAssertGreaterThan(counts.count, 1, "results refresh while output arrives")
        XCTAssertLessThanOrEqual(counts.count, Int(1.2 / HarnessTerminalSurfaceView.findRefreshInterval) + 2,
                                 "refreshes are bounded by the refresh interval")
        XCTAssertTrue(statuses.contains("Updating…"))

        let expected = 1 + line / 5
        let settled = expectation(description: "Final refresh after output stops")
        view.onFindResultsChanged = { _, count in if count == expected { settled.fulfill() } }
        if counts.last != expected { await fulfillment(of: [settled], timeout: 2) }
        try await Task.sleep(nanoseconds: 400_000_000)
        XCTAssertEqual(statuses.last ?? nil, nil, "status clears once output settles")
        view.onFindResultsChanged = nil
        view.onFindStatusChanged = nil
        view.endFind()
    }
}
