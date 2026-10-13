import AppKit
import XCTest
@testable import HarnessApp

/// Settings search lands on the matching control, not only its pane.
@MainActor
final class SettingsSearchTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        setenv("HARNESS_HOME", "/tmp/hss-\(UUID().uuidString.prefix(6))", 1)
        MainActor.assumeIsolated { _ = NSApplication.shared }
    }

    private func openSettings(searching query: String) -> (SettingsViewController, NSWindow) {
        let controller = SettingsViewController()
        controller.initialSearch = query
        let window = NSWindow(contentViewController: controller)
        window.setContentSize(NSSize(width: 840, height: 600))
        window.layoutIfNeeded()
        return (controller, window)
    }

    private func assertLands(on title: String, pane: SettingsPane, query: String,
                             file: StaticString = #filePath, line: UInt = #line) {
        let (controller, window) = openSettings(searching: query)
        defer { window.close() }
        let first = controller.settingsSearchMatches(query).first
        XCTAssertEqual(first?.title, title, file: file, line: line)
        XCTAssertEqual(controller.currentPane, pane, file: file, line: line)
        let row = descendants(of: controller.view).first { $0.accessibilityLabel() == "\(title), search match" }
        XCTAssertNotNil(row, "The landed row should be marked as the search match", file: file, line: line)
        if let row {
            XCTAssertFalse(row.visibleRect.isEmpty, "\(title) should be scrolled into view", file: file, line: line)
        }
    }

    func testSearchLandsOnTheExactControl() {
        assertLands(on: "Padding", pane: .appearance, query: "padding")
        assertLands(on: "Fallback fonts", pane: .terminal, query: "fallback font")
        assertLands(on: "Quiet hours and destinations", pane: .notifications, query: "quiet hours")
    }

    func testTitleMatchesRankAheadOfHintMatches() {
        let (controller, window) = openSettings(searching: "")
        defer { window.close() }
        let matches = controller.settingsSearchMatches("quiet hours")
        XCTAssertEqual(matches.first?.title, "Quiet hours and destinations")
        XCTAssertTrue(matches.contains { $0.title == "Notification policy" && $0.pane == .tools },
                      "A row whose hint mentions the query is still found")
    }

    func testReturnStepsToTheNextMatchAcrossPanes() {
        let (controller, window) = openSettings(searching: "quiet hours")
        defer { window.close() }
        let matches = controller.settingsSearchMatches("quiet hours")
        XCTAssertGreaterThan(matches.count, 1)
        controller.showNextSearchMatch()
        XCTAssertEqual(controller.searchMatchIndex, 1)
        XCTAssertEqual(controller.currentPane, matches[1].pane)
        let marked = descendants(of: controller.view).filter { ($0.accessibilityLabel() ?? "").hasSuffix(", search match") }
        XCTAssertEqual(marked.count, 1, "Only the current match is highlighted")
    }

    func testEmptyQueryMatchesNothing() {
        let (controller, window) = openSettings(searching: "")
        defer { window.close() }
        XCTAssertTrue(controller.settingsSearchMatches("   ").isEmpty)
    }

    private func descendants(of view: NSView) -> [NSView] {
        view.subviews + view.subviews.flatMap(descendants)
    }
}

@MainActor
final class PaletteSettingsFallbackTests: XCTestCase {
    func testUnmatchedQueryOffersSettingsSearch() {
        let palette = PaletteViewController(actions: [
            PaletteAction(id: "split", title: "Split Right", subtitle: "", symbol: "", shortcut: "",
                          section: .actions, handler: {}),
        ], recentIDs: [])
        XCTAssertEqual(palette.testingResultTitles(for: "fallback font"), ["Search Settings for “fallback font”"])
        XCTAssertEqual(palette.testingResultTitles(for: "split"), ["Split Right"])
    }
}
