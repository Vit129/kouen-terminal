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

    func testUntrackRemovesPaneSoLaterDrainCannotRecloseIt() {
        var tracker = AgentBrowserPaneTracker()
        let (a, b) = (SurfaceID(), SurfaceID())
        let (paneA, paneB) = (PaneID(), PaneID())
        tracker.track(paneA, origin: a)
        tracker.track(paneA, origin: b)
        tracker.track(paneB, origin: a)

        tracker.untrack(paneA)

        XCTAssertFalse(tracker.drain(origin: a).contains(paneA), "closed pane must not be reclosed")
        XCTAssertFalse(tracker.drain(origin: b).contains(paneA))
    }

    func testUntrackKeepsOriginsWithOtherTrackedPanes() {
        var tracker = AgentBrowserPaneTracker()
        let origin = SurfaceID()
        let (paneA, paneB) = (PaneID(), PaneID())
        tracker.track(paneA, origin: origin)
        tracker.track(paneB, origin: origin)

        tracker.untrack(paneA)

        XCTAssertEqual(tracker.drain(origin: origin), [paneB], "the origin must keep its remaining panes")
    }

    func testUntrackOfUnknownPaneIsHarmless() {
        var tracker = AgentBrowserPaneTracker()
        let origin = SurfaceID()
        let pane = PaneID()
        tracker.track(pane, origin: origin)

        tracker.untrack(PaneID())

        XCTAssertEqual(tracker.drain(origin: origin), [pane])
    }
}
