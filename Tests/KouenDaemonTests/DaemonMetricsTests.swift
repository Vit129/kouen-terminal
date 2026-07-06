import XCTest
@testable import KouenDaemonCore

/// Deterministic unit tests for the opt-in `DaemonMetrics` instrumentation. No socket,
/// no shell — runs in the default suite.
final class DaemonMetricsTests: XCTestCase {
    func testDisabledRecordsNothing() {
        let metrics = DaemonMetrics(enabled: false)
        XCTAssertFalse(metrics.enabled)
        metrics.recordLockWait(nanos: 5_000)
        metrics.recordOutputNotification()
        metrics.observeBacklog(bytes: 1_234)
        let s = metrics.snapshot()
        XCTAssertEqual(s.lockWaitCount, 0)
        XCTAssertEqual(s.lockWaitTotalNanos, 0)
        XCTAssertEqual(s.outputNotifications, 0)
        XCTAssertEqual(s.maxBacklogBytes, 0)
        XCTAssertTrue(metrics.summary().contains("disabled"))
    }

    func testEnabledAccumulatesLockWaitTotalMaxCount() {
        let metrics = DaemonMetrics(enabled: true)
        metrics.recordLockWait(nanos: 100)
        metrics.recordLockWait(nanos: 900)
        metrics.recordLockWait(nanos: 500)
        let s = metrics.snapshot()
        XCTAssertEqual(s.lockWaitCount, 3)
        XCTAssertEqual(s.lockWaitTotalNanos, 1_500)
        XCTAssertEqual(s.lockWaitMaxNanos, 900)
        XCTAssertEqual(s.meanLockWaitMicros, 0.5, accuracy: 0.0001) // 1500ns / 3 = 500ns = 0.5µs
    }

    func testEnabledCountsOutputNotifications() {
        let metrics = DaemonMetrics(enabled: true)
        for _ in 0 ..< 7 { metrics.recordOutputNotification() }
        XCTAssertEqual(metrics.snapshot().outputNotifications, 7)
    }

    func testObserveBacklogKeepsHighWaterMark() {
        let metrics = DaemonMetrics(enabled: true)
        metrics.observeBacklog(bytes: 100)
        metrics.observeBacklog(bytes: 4_096)
        metrics.observeBacklog(bytes: 512) // lower — must not lower the max
        XCTAssertEqual(metrics.snapshot().maxBacklogBytes, 4_096)
    }

    func testSummaryReflectsCounters() {
        let metrics = DaemonMetrics(enabled: true)
        metrics.recordLockWait(nanos: 2_000)
        metrics.recordOutputNotification()
        metrics.observeBacklog(bytes: 8_192)
        let summary = metrics.summary()
        XCTAssertTrue(summary.contains("lockWaits=1"))
        XCTAssertTrue(summary.contains("outputs=1"))
        XCTAssertTrue(summary.contains("maxBacklog=8192B"))
    }

    /// The counters are touched from multiple threads in production (any thread that
    /// acquires the registry lock, plus the serial server queue). Hammer them to prove
    /// the internal guarding keeps totals exact.
    func testConcurrentRecordingIsRaceFree() {
        let metrics = DaemonMetrics(enabled: true)
        let group = DispatchGroup()
        for _ in 0 ..< 8 {
            group.enter()
            DispatchQueue.global().async {
                for _ in 0 ..< 1_000 {
                    metrics.recordLockWait(nanos: 1)
                    metrics.recordOutputNotification()
                }
                group.leave()
            }
        }
        XCTAssertEqual(group.wait(timeout: .now() + 10), .success)
        let s = metrics.snapshot()
        XCTAssertEqual(s.lockWaitCount, 8_000)
        XCTAssertEqual(s.lockWaitTotalNanos, 8_000)
        XCTAssertEqual(s.outputNotifications, 8_000)
    }
}
