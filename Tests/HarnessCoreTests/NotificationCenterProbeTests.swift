import XCTest
@testable import HarnessCore

final class NotificationCenterProbeTests: XCTestCase {
    override func setUp() {
        super.setUp()
        NotificationCenterProbe.resetForRetry()
        NotificationCenterProbe.probeAction = {}
    }

    override func tearDown() {
        NotificationCenterProbe.resetForRetry()
        NotificationCenterProbe.probeAction = {}
        super.tearDown()
    }

    /// The common case: probeAction runs and returns normally (simulating a working
    /// notification database) - isKnownBad must stay false afterward.
    func testProbeSucceedsWhenActionReturnsNormally() {
        var didRun = false
        NotificationCenterProbe.probeAction = { didRun = true }
        NotificationCenterProbe.runAtLaunch()
        XCTAssertTrue(didRun)
        XCTAssertFalse(NotificationCenterProbe.isKnownBad)
    }

    /// The crash-recovery case: a unit test can't simulate the actual crash (that would kill
    /// the test process too), but it can simulate the OBSERVABLE consequence directly - a
    /// prior launch set the pending flag and never got to clear it. The next runAtLaunch()
    /// call must detect this and mark the center permanently bad WITHOUT attempting the risky
    /// call again this launch.
    func testPriorUnclearedPendingFlagMarksKnownBadWithoutReprobing() {
        UserDefaults.standard.set(true, forKey: "notificationCenterProbePending")
        var didRun = false
        NotificationCenterProbe.probeAction = { didRun = true }
        NotificationCenterProbe.runAtLaunch()
        XCTAssertFalse(didRun, "must not re-attempt the risky call in the same launch that detected a crash")
        XCTAssertTrue(NotificationCenterProbe.isKnownBad)
    }

    /// Once known bad, subsequent runAtLaunch() calls (e.g. a second call site, or a retry)
    /// must be a complete no-op - never touch probeAction again.
    func testKnownBadSkipsProbeOnSubsequentCalls() {
        UserDefaults.standard.set(true, forKey: "notificationCenterProbePending")
        NotificationCenterProbe.probeAction = {}
        NotificationCenterProbe.runAtLaunch()  // marks bad
        XCTAssertTrue(NotificationCenterProbe.isKnownBad)

        var didRun = false
        NotificationCenterProbe.probeAction = { didRun = true }
        NotificationCenterProbe.runAtLaunch()
        XCTAssertFalse(didRun)
        XCTAssertTrue(NotificationCenterProbe.isKnownBad)
    }

    /// resetForRetry() (called after the user repairs the database per Step 2) must clear
    /// both flags so the next launch probes again instead of staying permanently bad.
    func testResetForRetryAllowsReprobing() {
        UserDefaults.standard.set(true, forKey: "notificationCenterProbePending")
        NotificationCenterProbe.probeAction = {}
        NotificationCenterProbe.runAtLaunch()  // marks bad
        XCTAssertTrue(NotificationCenterProbe.isKnownBad)

        NotificationCenterProbe.resetForRetry()
        XCTAssertFalse(NotificationCenterProbe.isKnownBad)

        var didRun = false
        NotificationCenterProbe.probeAction = { didRun = true }
        NotificationCenterProbe.runAtLaunch()
        XCTAssertTrue(didRun, "must re-attempt the probe after a reset")
        XCTAssertFalse(NotificationCenterProbe.isKnownBad)
    }
}
