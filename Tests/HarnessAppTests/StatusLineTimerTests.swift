import AppKit
import HarnessCore
import XCTest
@testable import HarnessApp

/// The status-interval timer repeats forever once armed, so it must only run while the line is
/// visible in a window. A closed window or hidden line used to keep it firing.
@MainActor
final class StatusLineTimerTests: XCTestCase {
    func testRefreshTimerRunsOnlyWhileVisibleInAWindow() throws {
        let interval = HarnessOptions.shared.get("status-interval", scope: .global)?.intValue ?? 15
        let rows = HarnessOptions.shared.get("status", scope: .global)?.statusLineCount ?? 1
        try XCTSkipIf(interval <= 0 || rows == 0, "status line is disabled by local options")
        let saved = SessionCoordinator.shared.settings
        defer { SessionCoordinator.shared.settings = saved }
        SessionCoordinator.shared.settings.statusLineEnabled = true
        SessionCoordinator.shared.settings.showStatusLine = true

        let line = StatusLineView()
        XCTAssertFalse(line.isRefreshTimerArmed, "no window: nothing to redraw")

        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 400, height: 200),
                              styleMask: [.titled], backing: .buffered, defer: true)
        window.isReleasedWhenClosed = false
        window.contentView?.addSubview(line)
        XCTAssertTrue(line.isRefreshTimerArmed)

        line.removeFromSuperview()
        XCTAssertFalse(line.isRefreshTimerArmed, "leaving the window disarms the timer")

        SessionCoordinator.shared.settings.showStatusLine = false
        window.contentView?.addSubview(line)
        line.applyChrome()
        XCTAssertTrue(line.isHidden)
        XCTAssertFalse(line.isRefreshTimerArmed, "a hidden line does not tick")

        SessionCoordinator.shared.settings.showStatusLine = true
        line.applyChrome()
        XCTAssertTrue(line.isRefreshTimerArmed, "showing the line again re-arms it")
    }
}
