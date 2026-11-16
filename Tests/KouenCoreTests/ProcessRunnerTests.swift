import Foundation
import KouenCore
import XCTest

/// [BE-UT] Unit Tests for Layer 1 ProcessRunner
final class ProcessRunnerTests: XCTestCase {
    func testProcessRunner_EchoOutput() {
        let res = ProcessRunner.run(executable: "/bin/echo", arguments: ["hello", "world"])
        XCTAssertTrue(res.isSuccess)
        XCTAssertEqual(res.exitCode, 0)
        XCTAssertEqual(res.stdout.trimmingCharacters(in: .whitespacesAndNewlines), "hello world")
        XCTAssertEqual(res.stderr, "")
    }

    func testProcessRunner_NonZeroExit() {
        let res = ProcessRunner.run(executable: "/usr/bin/false")
        XCTAssertFalse(res.isSuccess)
        XCTAssertNotEqual(res.exitCode, 0)
    }

    func testProcessRunner_ResolveBinary() {
        let resolved = ProcessRunner.resolveBinary("echo")
        XCTAssertNotNil(resolved)
        XCTAssertTrue(resolved?.hasSuffix("/echo") == true)
    }

    func testProcessRunner_AsyncExecution() async {
        let res = await ProcessRunner.runAsync(executable: "/bin/echo", arguments: ["async-test"])
        XCTAssertTrue(res.isSuccess)
        XCTAssertEqual(res.stdout.trimmingCharacters(in: .whitespacesAndNewlines), "async-test")
    }

    // MARK: - Timeout & Partial Output Tests

    func testProcessRunner_TimeoutReturnsFastAndNotSuccess() {
        let start = Date()
        let res = ProcessRunner.run(executable: "/bin/sleep", arguments: ["5"], timeout: 0.5)
        let elapsed = Date().timeIntervalSince(start)
        XCTAssertFalse(res.isSuccess)
        XCTAssertNotEqual(res.exitCode, 0)
        XCTAssertTrue(res.isTimedOut)
        XCTAssertTrue(elapsed < 2.0, "Expected timeout around 0.5s, took \(elapsed)s")
        XCTAssertTrue(res.stderr.contains("timed out"))
    }

    func testProcessRunner_PartialOutputKeptOnTimeout() {
        let start = Date()
        let res = ProcessRunner.run(executable: "/bin/sh", arguments: ["-c", "echo hi; sleep 5"], timeout: 0.5)
        let elapsed = Date().timeIntervalSince(start)
        XCTAssertFalse(res.isSuccess)
        XCTAssertTrue(res.isTimedOut)
        XCTAssertEqual(res.stdout.trimmingCharacters(in: .whitespacesAndNewlines), "hi")
        XCTAssertTrue(res.stderr.contains("timed out"))
        XCTAssertTrue(elapsed < 2.0, "Expected timeout around 0.5s, took \(elapsed)s")
    }

    func testProcessRunner_AsyncPartialOutputKeptOnTimeout() async {
        let start = Date()
        let res = await ProcessRunner.runAsync(executable: "/bin/sh", arguments: ["-c", "echo hi; sleep 5"], timeout: 0.5)
        let elapsed = Date().timeIntervalSince(start)
        XCTAssertFalse(res.isSuccess)
        XCTAssertTrue(res.isTimedOut)
        XCTAssertEqual(res.stdout.trimmingCharacters(in: .whitespacesAndNewlines), "hi")
        XCTAssertTrue(res.stderr.contains("timed out"))
        XCTAssertTrue(elapsed < 2.0, "Expected timeout around 0.5s, took \(elapsed)s")
    }

    // MARK: - Async Non-Blocking Concurrency Test

    func testProcessRunner_AsyncDoesNotBlockCooperativePool() async {
        let start = Date()
        await withTaskGroup(of: ProcessResult.self) { group in
            for _ in 0..<20 {
                group.addTask {
                    await ProcessRunner.runAsync(executable: "/bin/sleep", arguments: ["1"])
                }
            }
        }
        let elapsed = Date().timeIntervalSince(start)
        XCTAssertTrue(elapsed < 3.0, "20 concurrent 1s sleep calls took \(elapsed)s (expected < 3.0s)")
    }

    /// Regression: a sync `run` with no timeout waited for pipe EOF, not for the process. When
    /// something else kept the pipe's write end open after git exited, every caller blocked forever;
    /// in the app all cooperative threads ended up stuck there and new Tasks piled up in memory.
    func testProcessRunner_ReturnsWhenProcessExitsEvenIfPipeStaysOpen() {
        let start = Date()
        // The backgrounded sleep inherits stdout and keeps the pipe open after sh exits.
        let res = ProcessRunner.run(executable: "/bin/sh", arguments: ["-c", "echo hi; sleep 20 &"])
        let elapsed = Date().timeIntervalSince(start)
        XCTAssertFalse(res.isSuccess)
        XCTAssertTrue(res.stdoutWasTruncated || res.stderrWasTruncated)
        XCTAssertEqual(res.stdout.trimmingCharacters(in: .whitespacesAndNewlines), "hi")
        XCTAssertTrue(elapsed < 5.0, "Expected return soon after sh exits, took \(elapsed)s")
    }

    // MARK: - Merged Output & Stderr Retention

    func testProcessRunner_StderrRetentionAndMerge() async {
        let res = await ProcessRunner.runAsync(executable: "/bin/sh", arguments: ["-c", "echo stdout_line; echo stderr_line >&2"])
        XCTAssertTrue(res.isSuccess)
        XCTAssertEqual(res.stdout.trimmingCharacters(in: .whitespacesAndNewlines), "stdout_line")
        XCTAssertEqual(res.stderr.trimmingCharacters(in: .whitespacesAndNewlines), "stderr_line")

        let parts = [
            res.stdout.trimmingCharacters(in: .whitespacesAndNewlines),
            res.stderr.trimmingCharacters(in: .whitespacesAndNewlines)
        ].filter { !$0.isEmpty }
        let combined = parts.joined(separator: "\n")
        XCTAssertEqual(combined, "stdout_line\nstderr_line")
    }

    func test_TS_2292_BE_IT_OutputCaptureIsBoundedAndReportsTruncation() async {
        let arguments = ["-c", "yes x | head -c 5000000; yes y | head -c 5000000 >&2"]
        let sync = ProcessRunner.run(executable: "/bin/sh", arguments: arguments)
        XCTAssertEqual(sync.stdout.utf8.count, 4 * 1024 * 1024)
        XCTAssertEqual(sync.stderr.utf8.count, 4 * 1024 * 1024)
        XCTAssertTrue(sync.stdoutWasTruncated)
        XCTAssertTrue(sync.stderrWasTruncated)

        let async = await ProcessRunner.runAsync(executable: "/bin/sh", arguments: arguments)
        XCTAssertEqual(async.stdout.utf8.count, 4 * 1024 * 1024)
        XCTAssertEqual(async.stderr.utf8.count, 4 * 1024 * 1024)
        XCTAssertTrue(async.stdoutWasTruncated)
        XCTAssertTrue(async.stderrWasTruncated)
    }
    func test_TS_2298_BE_IT_AsyncReturnsWhenDescendantKeepsPipeOpen() async {
        let start = Date()
        let result = await ProcessRunner.runAsync(executable: "/bin/sh", arguments: ["-c", "printf ready; sleep 10 &"])
        XCTAssertLessThan(Date().timeIntervalSince(start), 5)
        XCTAssertTrue(result.stdout.contains("ready"))
    }

    func test_TS_2299_BE_IT_AsyncCancellationStopsProcess() async {
        let task = Task { await ProcessRunner.runAsync(executable: "/bin/sleep", arguments: ["10"]) }
        task.cancel()
        let start = Date()
        let result = await task.value
        XCTAssertLessThan(Date().timeIntervalSince(start), 5)
        XCTAssertFalse(result.isSuccess)
    }

    func test_TS_2300_BE_IT_SyncTimeoutStillAppliesAfterChildClosesPipes() {
        let start = Date()
        let result = ProcessRunner.run(executable: "/bin/sh", arguments: ["-c", "exec 1>&- 2>&-; exec sleep 10"], timeout: 0.5)
        XCTAssertLessThan(Date().timeIntervalSince(start), 5)
        XCTAssertTrue(result.isTimedOut)
        XCTAssertFalse(result.isSuccess)
    }


    func test_TS_2300_BE_UT_TruncatedOutputKeepsRealExitCode() {
        let res = ProcessRunner.run(executable: "/bin/sh", arguments: ["-c", "yes x | head -c 5000000"])
        XCTAssertEqual(res.exitCode, 0)
        XCTAssertTrue(res.isSuccess)
        XCTAssertTrue(res.stdoutWasTruncated)
    }

    func test_TS_2301_BE_UT_ProcessExitingNearTimeoutIsNotTimedOut() {
        let res = ProcessRunner.run(executable: "/bin/sh", arguments: ["-c", "sleep 0.9; echo done"], timeout: 1)
        XCTAssertFalse(res.isTimedOut)
        XCTAssertEqual(res.exitCode, 0)
        XCTAssertEqual(res.stdout.trimmingCharacters(in: .whitespacesAndNewlines), "done")
    }
}
