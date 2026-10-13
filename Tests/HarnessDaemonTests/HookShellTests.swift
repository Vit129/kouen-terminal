import XCTest
@testable import HarnessCore
@testable import HarnessDaemonCore

/// `if-shell` runs on the serial hook queue and `run-shell -b` captures output, so both
/// must be bounded: a hung condition stalls every later hook, and an unread pipe can
/// block the child forever.
final class HookShellTests: XCTestCase {
    private var root: URL?
    private var previousHome: String?

    override func setUpWithError() throws {
        previousHome = getenv("HARNESS_HOME").map { String(cString: $0) }
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("harness-hook-shell-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        root = dir
        setenv("HARNESS_HOME", dir.path, 1)
        try HarnessPaths.ensureDirectories()
    }

    override func tearDownWithError() throws {
        if let previousHome { setenv("HARNESS_HOME", previousHome, 1) } else { unsetenv("HARNESS_HOME") }
        if let root { try? FileManager.default.removeItem(at: root) }
    }

    func testConditionReportsExitStatus() {
        let registry = SurfaceRegistry()
        XCTAssertTrue(registry.evaluateShellCondition("exit 0"))
        XCTAssertFalse(registry.evaluateShellCondition("exit 3"))
    }

    func testHungConditionTimesOutAsFalse() {
        let registry = SurfaceRegistry()
        _ = registry.handle(.setOption(scope: "global", target: nil, key: "hook-shell-timeout", rawValue: "1"))
        let start = ProcessInfo.processInfo.systemUptime
        XCTAssertFalse(registry.evaluateShellCondition("sleep 30"))
        XCTAssertLessThan(ProcessInfo.processInfo.systemUptime - start, 5)
    }

    func testCapturedRunShellStoresStdoutInBuffer() throws {
        let registry = SurfaceRegistry()
        let marker = "HOOK_CAPTURE_\(UUID().uuidString.prefix(8))"
        registry.runShellForHook("printf \(marker)", captureToBuffer: true)
        XCTAssertTrue(waitFor(timeout: 5) { latestBuffer(registry) == marker })
    }

    func testCapturedRunShellDoesNotBlockHookQueue() {
        let registry = SurfaceRegistry()
        registry.hookQueue.sync { registry.runShellForHook("sleep 5", captureToBuffer: true) }
        let drained = expectation(description: "hook queue drains while the capture runs")
        registry.hookQueue.async { drained.fulfill() }
        wait(for: [drained], timeout: 1)
    }

    func testOversizedCaptureIsDiscarded() {
        let registry = SurfaceRegistry()
        registry.runShellForHook("head -c 4000000 /dev/zero | tr '\\0' x", captureToBuffer: true)
        registry.runShellForHook("sleep 1; printf done", captureToBuffer: true)
        XCTAssertTrue(waitFor(timeout: 5) { latestBuffer(registry) == "done" })
        guard case let .buffers(all) = registry.handle(.listBuffers) else { return XCTFail("expected buffers") }
        XCTAssertFalse(all.contains { $0.byteCount > 1_048_576 })
    }

    private func latestBuffer(_ registry: SurfaceRegistry) -> String? {
        guard case let .buffer(summary) = registry.handle(.getBuffer(name: nil)), let data = summary.data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func waitFor(timeout: TimeInterval, _ condition: () -> Bool) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if condition() { return true }
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        }
        return condition()
    }
}
