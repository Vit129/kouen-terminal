import XCTest
@testable import KouenDaemonCore

final class FDWatchdogTests: XCTestCase {
    func testLevelThresholds() {
        XCTAssertEqual(FDWatchdog.level(open: 100, limit: 2560), 0)
        XCTAssertEqual(FDWatchdog.level(open: 1280, limit: 2560), 1)
        XCTAssertEqual(FDWatchdog.level(open: 2048, limit: 2560), 2)
        XCTAssertEqual(FDWatchdog.level(open: 10, limit: 0), 0)
    }

    /// One line per rising crossing, silence while steady, re-armed after it falls back.
    func testObserveLogsOncePerCrossing() {
        let w = FDWatchdog()
        XCTAssertNil(w.observe(open: 100, limit: 2560))
        XCTAssertNotNil(w.observe(open: 1300, limit: 2560))
        XCTAssertNil(w.observe(open: 1400, limit: 2560))
        XCTAssertTrue(w.observe(open: 2100, limit: 2560)?.contains("80%") == true)
        XCTAssertNil(w.observe(open: 2200, limit: 2560))
        XCTAssertNil(w.observe(open: 50, limit: 2560))
        XCTAssertNotNil(w.observe(open: 1300, limit: 2560))
    }
}
