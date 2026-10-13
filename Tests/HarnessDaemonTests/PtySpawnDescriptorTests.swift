import XCTest
@testable import HarnessDaemonCore

/// A shell must start without any descriptor the spawning process left open.
final class PtySpawnDescriptorTests: XCTestCase {
    override func setUpWithError() throws {
        try skipUnlessLiveDaemonTests()
    }

    func testShellDoesNotInheritAnOpenDescriptor() throws {
        var ends: [Int32] = [-1, -1]
        XCTAssertEqual(pipe(&ends), 0)
        let leaked: Int32 = 777
        XCTAssertEqual(dup2(ends[1], leaked), leaked, "dup2 clears FD_CLOEXEC, so 777 would be inherited")
        defer { close(leaked); close(ends[0]); close(ends[1]) }

        let reaped = expectation(description: "probe shell exited")
        let status = LockedStatus()
        let probe = "[ -e /dev/fd/\(leaked) ] && exit 3; exit 0"
        let pty = try RealPty(id: UUID().uuidString, cwd: NSTemporaryDirectory(), shell: "/bin/sh", rows: 24, cols: 80,
                              scrollbackBytes: 65536, launchArgumentsOverride: ["-c", probe],
                              initialStandardInput: Data())
        defer { pty.close() }
        pty.onReaped = { _, code in status.set(code); reaped.fulfill() }
        pty.start()
        wait(for: [reaped], timeout: 10)
        XCTAssertEqual(status.value, 0, "the shell could see descriptor \(leaked)")
    }
}

private final class LockedStatus: @unchecked Sendable {
    private let lock = NSLock()
    private var stored: Int32?
    var value: Int32? { lock.withLock { stored } }
    func set(_ code: Int32?) { lock.withLock { stored = code } }
}
