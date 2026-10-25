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
}
