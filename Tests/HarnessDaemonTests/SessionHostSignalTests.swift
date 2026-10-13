import HarnessCore
import XCTest

/// The session host must survive a hangup and still stop cleanly on SIGTERM.
final class SessionHostSignalTests: XCTestCase {
    func testHangupKeepsTheHostAndItsPanesRunning() throws {
        guard let products = ProcessInfo.processInfo.environment["HARNESS_TEST_PRODUCTS"] else {
            throw XCTSkip("Set HARNESS_TEST_PRODUCTS to the built product directory to run the session host.")
        }
        let home = URL(fileURLWithPath: "/tmp/hsig-" + String(UUID().uuidString.prefix(8)))
        defer { try? FileManager.default.removeItem(at: home) }
        let client = DaemonClient(endpoint: .unix(path: home.appendingPathComponent("harness.sock").path))
        let host = Process()
        host.executableURL = URL(fileURLWithPath: products).appendingPathComponent("HarnessSessionHost")
        var environment = ProcessInfo.processInfo.environment
        environment["HARNESS_HOME"] = home.path
        for key in ["HARNESS_SERVER", "HARNESS_SOCK", "HARNESS_SESSION", "HARNESS_TAB", "HARNESS_SURFACE"] {
            environment.removeValue(forKey: key)
        }
        host.environment = environment
        host.standardInput = FileHandle.nullDevice
        host.standardOutput = FileHandle.nullDevice
        host.standardError = FileHandle.nullDevice
        try host.run()
        defer { if host.isRunning { host.terminate() }; host.waitUntilExit() }

        XCTAssertTrue(waitUntil(timeout: 10) { Self.ready(client) }, "session host never became ready")
        guard case let .surfaceID(surface) = try client.request(.createSurface(cwd: home.path, shell: "/bin/sh")) else {
            return XCTFail("could not create a pane")
        }

        XCTAssertEqual(kill(host.processIdentifier, SIGHUP), 0)
        Thread.sleep(forTimeInterval: 0.5)
        XCTAssertTrue(host.isRunning, "SIGHUP stopped the session host")
        _ = try client.request(.sendData(surfaceID: surface, data: Data("echo AFTER_$((40+2))\n".utf8)))
        XCTAssertTrue(waitUntil(timeout: 10) { Self.replay(client, surface).contains("AFTER_42") },
                      "the pane's shell did not survive the hangup")

        XCTAssertEqual(kill(host.processIdentifier, SIGTERM), 0)
        XCTAssertTrue(waitUntil(timeout: 10) { !host.isRunning }, "SIGTERM no longer stops the host")
    }

    private static func replay(_ client: DaemonClient, _ surface: String) -> String {
        guard case let .text(text) = try? client.request(.replayScrollback(surfaceID: surface, fromSequence: nil)) else {
            return ""
        }
        return text
    }

    private static func ready(_ client: DaemonClient) -> Bool {
        guard case let .daemonStats(stats) = try? client.request(.daemonStats, timeout: 0.2) else { return false }
        return stats.isReadyForClient
    }
}
