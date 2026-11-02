import AppKit
import WebKit
import XCTest
@testable import KouenApp

@MainActor
final class TabNavigationButtonsTests: XCTestCase {
    func testTargetStopsAtBothEnds() {
        XCTAssertNil(TabNavigation.target(from: 0, delta: -1, count: 3))
        XCTAssertEqual(TabNavigation.target(from: 0, delta: 1, count: 3), 1)
        XCTAssertEqual(TabNavigation.target(from: 2, delta: -1, count: 3), 1)
        XCTAssertNil(TabNavigation.target(from: 2, delta: 1, count: 3))
        XCTAssertNil(TabNavigation.target(from: 0, delta: 1, count: 1))
    }

    private func control(_ view: NSView, _ id: String) -> NSControl? {
        if view.accessibilityIdentifier() == id, let control = view as? NSControl { return control }
        for subview in view.subviews {
            if let match = control(subview, id) { return match }
        }
        return nil
    }

    private func assertButtonsSwitchTabs(tabCount: Int, width: CGFloat, file: StaticString = #filePath, line: UInt = #line) throws {
        let first = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        let pane = BrowserPaneView(url: URL(string: "about:blank")!, paneID: UUID(), webView: first)
        pane.frame = NSRect(x: 0, y: 0, width: width, height: 400)
        var webViews = [first]
        for _ in 1..<tabCount {
            webViews.append(pane.createTab(url: URL(string: "about:blank")!, skipLoad: true))
        }
        pane.layoutSubtreeIfNeeded()
        let previous = try XCTUnwrap(control(pane, "browser-previous-tab"), file: file, line: line)
        let next = try XCTUnwrap(control(pane, "browser-next-tab"), file: file, line: line)

        XCTAssertFalse(next.isEnabled, "the last tab has no next tab", file: file, line: line)
        previous.performClick(nil)
        XCTAssertTrue(pane.webView === webViews[tabCount - 2], file: file, line: line)
        XCTAssertTrue(next.isEnabled, file: file, line: line)
        next.performClick(nil)
        XCTAssertTrue(pane.webView === webViews[tabCount - 1], file: file, line: line)
    }

    func testButtonsSwitchTabsWhenTabsFit() throws {
        try assertButtonsSwitchTabs(tabCount: 3, width: 1000)
    }

    func testButtonsSwitchTabsWhenTabsOverflow() throws {
        try assertButtonsSwitchTabs(tabCount: 9, width: 400)
    }
}
