import XCTest
import KouenIPC
@testable import KouenApp

final class AgentBrowserPaneTrackerTests: XCTestCase {
    func testDrainReturnsOnlyThatOriginsPanesAndForgetsThem() {
        var tracker = AgentBrowserPaneTracker()
        let (a, b) = (SurfaceID(), SurfaceID())
        let (paneA, paneB) = (PaneID(), PaneID())
        tracker.track(paneA, origin: a)
        tracker.track(paneB, origin: b)

        XCTAssertEqual(tracker.drain(origin: a), [paneA])
        XCTAssertTrue(tracker.drain(origin: a).isEmpty, "drained panes must not be closed twice")
        XCTAssertEqual(tracker.drain(origin: b), [paneB], "another surface's panes must be untouched")
    }

    func testDrainOfUnknownOriginIsEmpty() {
        var tracker = AgentBrowserPaneTracker()
        XCTAssertTrue(tracker.drain(origin: SurfaceID()).isEmpty, "a user-opened pane was never tracked")
    }
}
