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
}
