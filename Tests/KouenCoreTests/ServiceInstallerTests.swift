import XCTest
@testable import KouenCore

final class ServiceInstallerTests: XCTestCase {
    func testSystemdUnitContents() {
        let unit = SystemdUserInstaller.unitContents(
            daemonPath: URL(fileURLWithPath: "/opt/kouen/KouenDaemon"),
            kouenHome: URL(fileURLWithPath: "/home/u/.local/share/kouen"),
            logPath: URL(fileURLWithPath: "/home/u/.local/share/kouen/logs/daemon.log")
        )
        XCTAssertTrue(unit.contains("ExecStart=/opt/kouen/KouenDaemon"))
        XCTAssertTrue(unit.contains("Environment=KOUEN_HOME=/home/u/.local/share/kouen"))
        XCTAssertTrue(unit.contains("Restart=on-failure"))
        XCTAssertTrue(unit.contains("Type=simple"))
        XCTAssertTrue(unit.contains("WantedBy=default.target"))
        XCTAssertTrue(unit.contains("StandardError=append:/home/u/.local/share/kouen/logs/daemon.log"))
    }

    func testCurrentBackendMatchesPlatform() {
        #if os(macOS)
        XCTAssertEqual(ServiceInstallers.current.backendName, "launchd")
        #else
        XCTAssertEqual(ServiceInstallers.current.backendName, "systemd --user")
        #endif
    }
}
