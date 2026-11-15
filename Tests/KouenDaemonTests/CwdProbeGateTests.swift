import XCTest
@testable import KouenDaemonCore

final class CwdProbeGateTests: XCTestCase {
    func test_TC1205_BEUT_idleSurfaceIsNotProbed() {
        XCTAssertFalse(SurfaceRegistry.shouldProbeCwd(idleSeconds: 60))
    }

    func test_TC1205_BEUT_recentlyActiveOrUnmonitoredSurfaceIsProbed() {
        XCTAssertTrue(SurfaceRegistry.shouldProbeCwd(idleSeconds: 0.2))
        XCTAssertTrue(SurfaceRegistry.shouldProbeCwd(idleSeconds: nil))
    }
}
