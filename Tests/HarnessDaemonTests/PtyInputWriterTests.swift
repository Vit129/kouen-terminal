import Foundation
import XCTest
@testable import HarnessDaemonCore
import HarnessCore
#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif

final class PtyInputAdmissionTests: XCTestCase {
    func testAdmissionIsBoundedBeforeDispatchAndNeverTruncates() throws {
        var descriptors: [Int32] = [0, 0]
        XCTAssertEqual(pipe(&descriptors), 0)
        defer { close(descriptors[0]); close(descriptors[1]) }
        _ = fcntl(descriptors[1], F_SETFL, O_NONBLOCK)
        let queue = DispatchQueue(label: "input-admission-test")
        queue.suspend()
        let writer = PtyInputWriter(queue: queue, limit: 5)
        XCTAssertTrue(writer.write(Data("abc".utf8), master: (dup(descriptors[1]), 1)))
        XCTAssertFalse(writer.write(Data("XYZ".utf8), master: (dup(descriptors[1]), 1)))
        XCTAssertTrue(writer.write(Data("de".utf8), master: (dup(descriptors[1]), 1)))
        queue.resume()
        queue.sync {}
        var bytes = [UInt8](repeating: 0, count: 5)
        XCTAssertEqual(read(descriptors[0], &bytes, 5), 5)
        XCTAssertEqual(String(decoding: bytes, as: UTF8.self), "abcde")
    }

    func testAControlBoundarySeparatesAcceptedWritesAndCancelsWithItsGeneration() throws {
        var descriptors: [Int32] = [0, 0]
        XCTAssertEqual(pipe(&descriptors), 0)
        defer { close(descriptors[0]); close(descriptors[1]) }
        _ = fcntl(descriptors[1], F_SETFL, O_NONBLOCK)
        let queue = DispatchQueue(label: "input-control-test"), writer = PtyInputWriter(queue: queue)
        let applied = expectation(description: "Control applied after earlier input")
        queue.suspend()
        XCTAssertTrue(writer.write(Data("before".utf8), master: (dup(descriptors[1]), 1)))
        let readEnd = descriptors[0]
        XCTAssertTrue(writer.perform(afterInput: (dup(descriptors[1]), 1), apply: {
            var bytes = [UInt8](repeating: 0, count: 6)
            XCTAssertEqual(read(readEnd, &bytes, bytes.count), 6)
            XCTAssertEqual(String(decoding: bytes, as: UTF8.self), "before")
            applied.fulfill()
        }, cancel: { XCTFail("Current control cancelled") }))
        XCTAssertTrue(writer.write(Data("after".utf8), master: (dup(descriptors[1]), 1)))
        queue.resume(); wait(for: [applied], timeout: 2)
        var bytes = [UInt8](repeating: 0, count: 5)
        XCTAssertEqual(read(readEnd, &bytes, bytes.count), 5)
        XCTAssertEqual(String(decoding: bytes, as: UTF8.self), "after")
        queue.suspend()
        let cancelled = expectation(description: "Replaced generation cancels its control")
        XCTAssertTrue(writer.perform(afterInput: (dup(descriptors[1]), 1), apply: { XCTFail("Old control applied") }, cancel: { cancelled.fulfill() }))
        XCTAssertTrue(writer.write(Data("new".utf8), master: (dup(descriptors[1]), 2)))
        queue.resume(); wait(for: [cancelled], timeout: 2)
    }

    func testReplacementCannotReceiveOldQueuedInput() throws {
        var descriptors: [Int32] = [0, 0]
        XCTAssertEqual(pipe(&descriptors), 0)
        defer { close(descriptors[0]); close(descriptors[1]) }
        _ = fcntl(descriptors[1], F_SETFL, O_NONBLOCK)
        let queue = DispatchQueue(label: "input-generation-test")
        queue.suspend()
        let writer = PtyInputWriter(queue: queue)
        XCTAssertTrue(writer.write(Data("old".utf8), master: (dup(descriptors[1]), 1)))
        XCTAssertTrue(writer.write(Data("new".utf8), master: (dup(descriptors[1]), 2)))
        XCTAssertFalse(writer.write(Data("late".utf8), master: (dup(descriptors[1]), 1)))
        queue.resume()
        queue.sync {}
        var bytes = [UInt8](repeating: 0, count: 3)
        XCTAssertEqual(read(descriptors[0], &bytes, 3), 3)
        XCTAssertEqual(String(decoding: bytes, as: UTF8.self), "new")
    }

    func testInterruptWithNothingQueuedIsWrittenInOrder() throws {
        var descriptors: [Int32] = [0, 0]
        XCTAssertEqual(pipe(&descriptors), 0)
        defer { close(descriptors[0]); close(descriptors[1]) }
        _ = fcntl(descriptors[1], F_SETFL, O_NONBLOCK)
        let writer = PtyInputWriter(queue: DispatchQueue(label: "interrupt-idle-test"))
        var signalled = false
        XCTAssertTrue(writer.interrupt(0x03, master: (dup(descriptors[1]), 1)) { _ in signalled = true; return true })
        XCTAssertFalse(signalled)
        var byte: UInt8 = 0
        XCTAssertEqual(read(descriptors[0], &byte, 1), 1)
        XCTAssertEqual(byte, 0x03)
    }

    func testInterruptDropsQueuedInputAndSignalsInsteadOfWaiting() throws {
        var descriptors: [Int32] = [0, 0]
        XCTAssertEqual(pipe(&descriptors), 0)
        defer { close(descriptors[0]); close(descriptors[1]) }
        _ = fcntl(descriptors[0], F_SETFL, O_NONBLOCK)
        _ = fcntl(descriptors[1], F_SETFL, O_NONBLOCK)
        let queue = DispatchQueue(label: "interrupt-backlog-test")
        let writer = PtyInputWriter(queue: queue)
        let applied = expectation(description: "A queued control still applies after the interrupt")
        queue.suspend()
        XCTAssertTrue(writer.write(Data(repeating: UInt8(ascii: "p"), count: 1 << 20), master: (dup(descriptors[1]), 1)))
        XCTAssertTrue(writer.perform(afterInput: (dup(descriptors[1]), 1), apply: { applied.fulfill() },
                                     cancel: { XCTFail("Control cancelled by the interrupt") }))
        var signalled: Int32 = -1
        XCTAssertTrue(writer.interrupt(0x03, master: (dup(descriptors[1]), 1)) { fd in signalled = fd; return true })
        XCTAssertGreaterThanOrEqual(signalled, 0, "a backlog routes the interrupt to the signal")
        XCTAssertTrue(writer.write(Data("after".utf8), master: (dup(descriptors[1]), 1)))
        queue.resume()
        wait(for: [applied], timeout: 2)
        queue.sync {}

        var bytes = [UInt8](repeating: 0, count: 64)
        XCTAssertEqual(read(descriptors[0], &bytes, bytes.count), 5, "the dropped paste never reaches the PTY")
        XCTAssertEqual(String(decoding: bytes.prefix(5), as: UTF8.self), "after")
    }

    func testInterruptForAReplacedShellIsRejected() throws {
        var descriptors: [Int32] = [0, 0]
        XCTAssertEqual(pipe(&descriptors), 0)
        defer { close(descriptors[0]); close(descriptors[1]) }
        let queue = DispatchQueue(label: "interrupt-generation-test")
        let writer = PtyInputWriter(queue: queue)
        XCTAssertTrue(writer.write(Data("x".utf8), master: (dup(descriptors[1]), 2)))
        XCTAssertFalse(writer.interrupt(0x03, master: (dup(descriptors[1]), 1)) { _ in XCTFail("stale signal"); return true })
        queue.sync {}
    }
}

/// Ctrl-C must reach a foreground job even while a paste fills the terminal's input queue.
final class PtyInterruptLiveTests: XCTestCase {
    override func setUpWithError() throws {
        try skipUnlessLiveDaemonTests()
    }

    func testInterruptReachesForegroundJobBehindAPasteBacklog() throws {
        let pty = try RealPty(id: UUID().uuidString, cwd: NSTemporaryDirectory(), shell: "/bin/sh",
                              rows: 24, cols: 80, scrollbackBytes: 256 * 1024)
        pty.start()
        defer { pty.close() }
        let output = OutputAccumulator()
        _ = pty.subscribe { data, _ in _ = output.appendAndContains(String(decoding: data, as: UTF8.self), marker: "") }

        pty.write("echo READY_$((20+1)); sleep 30\n")
        XCTAssertTrue(waitUntil(timeout: 8) { output.contains("READY_21") })
        // `sleep` never reads stdin, so this fills the canonical queue and backs up the writer.
        // Each line would print PASTED_2 if the shell ever ran it.
        XCTAssertTrue(pty.write(String(repeating: "echo PASTED_$((1+1))\n", count: 20_000)))
        usleep(200_000)

        XCTAssertTrue(pty.write("\u{3}"))
        pty.write("echo DONE_$((40+2))\n")
        XCTAssertTrue(waitUntil(timeout: 5) { output.contains("DONE_42") }, "Ctrl-C did not interrupt sleep")
        XCTAssertFalse(output.contains("PASTED_2"), "queued paste ran after the interrupt")
    }
}
