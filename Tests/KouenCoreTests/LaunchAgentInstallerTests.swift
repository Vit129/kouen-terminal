import XCTest
@testable import KouenCore

final class LaunchAgentInstallerTests: XCTestCase {
    func testPlistContainsLabelDaemonPathAndLogPath() {
        let daemon = URL(fileURLWithPath: "/Applications/Kouen.app/Contents/MacOS/KouenDaemon")
        let home = URL(fileURLWithPath: "/Users/test/Library/Application Support/Kouen")
        let log = URL(fileURLWithPath: "/Users/test/Library/Application Support/Kouen/logs/daemon.log")

        let plist = LaunchAgentInstaller.plist(daemonPath: daemon, kouenHome: home, logPath: log)

        XCTAssertTrue(plist.contains("<string>\(KouenPaths.launchAgentLabel)</string>"),
                      "label must appear so launchctl can address the service")
        XCTAssertTrue(plist.contains(daemon.path), "daemon path must be embedded")
        XCTAssertTrue(plist.contains(home.path), "KOUEN_HOME must be embedded")
        XCTAssertTrue(plist.contains(log.path), "log path must be embedded")
        XCTAssertTrue(plist.contains("<key>KeepAlive</key>"), "KeepAlive must be set so launchd respawns on crash")
        XCTAssertTrue(plist.contains("<key>RunAtLoad</key>"), "RunAtLoad ensures the daemon starts on user login")
    }

    func testMobileBridgePortOmittedByDefaultButEmbeddedWhenGiven() {
        let daemon = URL(fileURLWithPath: "/Applications/Kouen.app/Contents/MacOS/KouenDaemon")
        let home = URL(fileURLWithPath: "/Users/test/Library/Application Support/Kouen")
        let log = URL(fileURLWithPath: "/Users/test/Library/Application Support/Kouen/logs/daemon.log")

        let withoutBridge = LaunchAgentInstaller.plist(daemonPath: daemon, kouenHome: home, logPath: log)
        XCTAssertFalse(withoutBridge.contains("KOUEN_MOBILE_BRIDGE_PORT"),
                       "mobile bridge must stay off by default — no env var means MobileBridgeServer never starts")

        let withBridge = LaunchAgentInstaller.plist(daemonPath: daemon, kouenHome: home, logPath: log, mobileBridgePort: 7777)
        XCTAssertTrue(withBridge.contains("<key>KOUEN_MOBILE_BRIDGE_PORT</key>"))
        XCTAssertTrue(withBridge.contains("<string>7777</string>"))
    }

    func testIsInstalledReflectsFilesystem() throws {
        // Don't touch the real LaunchAgents path; just confirm the API uses
        // FileManager.default which honors the URL we expose.
        let exists = FileManager.default.fileExists(atPath: KouenPaths.launchAgentURL.path)
        XCTAssertEqual(LaunchAgentInstaller.isInstalled, exists)
    }
}
