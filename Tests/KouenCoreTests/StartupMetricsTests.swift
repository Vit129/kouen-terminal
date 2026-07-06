import XCTest
@testable import KouenCore

final class StartupMetricsTests: XCTestCase {
    private let ms: UInt64 = 1_000_000

    func testDisabledRecordsNothing() {
        let metrics = StartupMetrics(enabled: false)
        XCTAssertFalse(metrics.enabled)
        metrics.mark(.launchStart, at: 0)
        metrics.mark(.firstWindow, at: 5 * ms)
        XCTAssertTrue(metrics.recordedPhases().isEmpty)
        XCTAssertNil(metrics.elapsedMs(.firstWindow))
        XCTAssertTrue(metrics.report().contains("disabled"))
    }

    func testEnabledRecordsPhasesInOrder() {
        let metrics = StartupMetrics(enabled: true)
        metrics.mark(.launchStart, at: 0)
        metrics.mark(.firstWindow, at: 3 * ms)
        metrics.mark(.daemonConnected, at: 40 * ms)
        metrics.mark(.firstSnapshot, at: 42 * ms)
        XCTAssertEqual(
            metrics.recordedPhases(),
            [.launchStart, .firstWindow, .daemonConnected, .firstSnapshot]
        )
    }

    func testDuplicateMarkIsIgnoredFirstWins() throws {
        let metrics = StartupMetrics(enabled: true)
        metrics.mark(.launchStart, at: 0)
        metrics.mark(.firstSnapshot, at: 10 * ms)
        metrics.mark(.firstSnapshot, at: 99 * ms) // later duplicate must be ignored
        XCTAssertEqual(metrics.recordedPhases(), [.launchStart, .firstSnapshot])
        XCTAssertEqual(try XCTUnwrap(metrics.elapsedMs(.firstSnapshot)), 10, accuracy: 0.0001)
    }

    func testElapsedIsRelativeToLaunchStart() throws {
        let metrics = StartupMetrics(enabled: true)
        metrics.mark(.launchStart, at: 100 * ms)
        metrics.mark(.firstWindow, at: 102 * ms)
        metrics.mark(.firstDrawablePresented, at: 250 * ms)
        XCTAssertEqual(try XCTUnwrap(metrics.elapsedMs(.firstWindow)), 2, accuracy: 0.0001)
        XCTAssertEqual(try XCTUnwrap(metrics.elapsedMs(.firstDrawablePresented)), 150, accuracy: 0.0001)
        XCTAssertNil(metrics.elapsedMs(.daemonConnected), "unmarked phase has no elapsed")
    }

    func testReportContainsEachMarkedPhaseWithDeltas() {
        let metrics = StartupMetrics(enabled: true)
        metrics.mark(.launchStart, at: 0)
        metrics.mark(.firstWindow, at: 2 * ms)
        let report = metrics.report()
        XCTAssertTrue(report.contains("launchStart=0.0ms"))
        XCTAssertTrue(report.contains("firstWindow=2.0ms"))
        XCTAssertFalse(report.contains("disabled"))
    }

    func testElapsedNilWithoutLaunchStartAnchor() {
        let metrics = StartupMetrics(enabled: true)
        // No launchStart recorded — deltas can't be anchored.
        metrics.mark(.firstWindow, at: 5 * ms)
        XCTAssertNil(metrics.elapsedMs(.firstWindow))
    }
}
