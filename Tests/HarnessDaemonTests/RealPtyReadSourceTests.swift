import XCTest
import Foundation
@testable import HarnessDaemonCore
#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif

final class RealPtyReadSourceTests: XCTestCase {
    func testMandatoryConsumersBackpressureProducerAndResumeWithoutLosingBytes() throws {
        try skipUnlessLiveDaemonTests()
        let total = 16 << 20
        let pty = try RealPty(id: UUID().uuidString, cwd: NSTemporaryDirectory(), shell: "/bin/sh",
            scrollbackBytes: total + 65536, launchArgumentsOverride: ["-c", "head -c \(total) /dev/zero"])
        defer { pty.close() }
        let acknowledgements = Acknowledgements()
        let token = pty.subscribe(acknowledgesOutput: true) { [weak pty] data, sequence in
            if acknowledgements.isEnabled, let token = acknowledgements.token { pty?.acknowledgeSubscription(token: token, sequence: sequence + UInt64(data.count)) }
        }
        acknowledgements.setToken(token)
        pty.beginObservation()
        pty.onObservation = { [weak pty] observation in
            if acknowledgements.isEnabled { pty?.acknowledgeObservation(observation.endSequence) }
        }
        pty.start()
        XCTAssertTrue(waitUntil(timeout: 8) { pty.ringEnd >= UInt64(4 << 20) })
        let paused = pty.ringEnd
        XCTAssertLessThanOrEqual(paused, UInt64((4 << 20) + 65536 + 1))
        Thread.sleep(forTimeInterval: 0.05)
        XCTAssertEqual(pty.ringEnd, paused, "a mandatory consumer must throttle kernel reads")
        pty.acknowledgeObservation(paused)
        Thread.sleep(forTimeInterval: 0.05)
        XCTAssertEqual(pty.ringEnd, paused, "the daemon observer cannot release bytes still pending in the GUI")
        acknowledgements.enable()
        pty.acknowledgeSubscription(token: token, sequence: paused)
        XCTAssertTrue(waitUntil(timeout: 8) { pty.ringEnd == UInt64(total + 1) })
        XCTAssertEqual(pty.historyBytes, total)
    }

    private final class Acknowledgements: @unchecked Sendable {
        private let lock = NSLock()
        private var enabled = false
        private var subscriptionToken: UUID?
        var token: UUID? { lock.lock(); defer { lock.unlock() }; return subscriptionToken }
        func setToken(_ token: UUID) { lock.lock(); subscriptionToken = token; lock.unlock() }
        var isEnabled: Bool { lock.lock(); defer { lock.unlock() }; return enabled }
        func enable() { lock.lock(); enabled = true; lock.unlock() }
    }

    func testSupersededStartDoesNotTouchAReusedDescriptor() throws {
        var descriptors: [Int32] = [0, 0]
        guard pipe(&descriptors) == 0 else { return XCTFail("Could not create fixture pipe") }
        defer { close(descriptors[0]); close(descriptors[1]) }
        let flags = fcntl(descriptors[0], F_GETFL)
        XCTAssertGreaterThanOrEqual(flags, 0)

        let pty = RealPty(forTesting: ())
        pty.startReading(fd: descriptors[0], generation: .max)

        XCTAssertEqual(fcntl(descriptors[0], F_GETFL), flags,
                       "a stale start must neither set nonblocking mode nor close a descriptor it no longer owns")
    }
}
