import XCTest
import KouenIPC
@testable import KouenCore
@testable import KouenDaemonCore

/// P37 Phase D3 (browser mirror). Guards a regression found via code review: a stale
/// `browserPaneID` that never cleared on an error response left the mobile browser mirror
/// permanently bricked for the rest of that connection (every subsequent navigate re-targeted
/// the same dead pane and kept failing, with no path back short of a full WS reconnect).
///
/// Drives `MobileBridgeServer.nextBrowserPaneID` directly — the pure state-transition logic
/// `handleBrowserNavigate` uses — same "static, no live socket needed" shape
/// `MobileBridgeFilePreviewTests` already establishes for D1's handlers.
final class MobileBridgeBrowserTests: XCTestCase {
    func testOpenResponseSetsPaneID() {
        let paneID = UUID()
        XCTAssertEqual(
            MobileBridgeServer.nextBrowserPaneID(current: nil, response: .open(paneID: paneID)),
            paneID
        )
    }

    /// The regression this test guards: before the fix, `.error` left `current` untouched.
    func testErrorResponseClearsStalePaneID() {
        let stalePaneID = UUID()
        XCTAssertNil(
            MobileBridgeServer.nextBrowserPaneID(current: stalePaneID, response: .error("Browser pane not found")),
            "an error response (e.g. the Mac closed the pane) must clear browserPaneID so the next navigate reopens a fresh pane instead of retargeting a dead one"
        )
    }

    func testOkResponseLeavesPaneIDUnchanged() {
        let paneID = UUID()
        XCTAssertEqual(MobileBridgeServer.nextBrowserPaneID(current: paneID, response: .ok), paneID)
    }

    /// A response shape that isn't `.open`/`.error` (e.g. a stray `.snapshot` reaching this path)
    /// must not clobber an already-tracked pane id.
    func testOtherResponseLeavesPaneIDUnchanged() {
        let paneID = UUID()
        let snapshot = BrowserSnapshot(url: "https://example.com", title: "Example", text: "", elements: [])
        XCTAssertEqual(MobileBridgeServer.nextBrowserPaneID(current: paneID, response: .snapshot(snapshot)), paneID)
    }

    func testErrorWithNoPriorPaneIDStaysNil() {
        XCTAssertNil(MobileBridgeServer.nextBrowserPaneID(current: nil, response: .error("Kouen GUI is not running or connected")))
    }
}
