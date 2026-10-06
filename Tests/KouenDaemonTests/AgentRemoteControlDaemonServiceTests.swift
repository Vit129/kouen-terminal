import XCTest
@testable import KouenDaemonCore
import KouenIPC
import KouenSettings

final class AgentRemoteControlDaemonServiceTests: XCTestCase {
    private final class LogBox: @unchecked Sendable {
        private let lock = NSLock()
        private var logs: [String] = []
        func append(_ log: String) {
            lock.lock()
            logs.append(log)
            lock.unlock()
        }
        var count: Int {
            lock.lock()
            defer { lock.unlock() }
            return logs.count
        }
    }

    func testResolveExecutable() {
        XCTAssertNotNil(AgentRemoteControlDaemonService.resolveExecutable(named: "which"))
        XCTAssertNotNil(AgentRemoteControlDaemonService.resolveExecutable(named: "sh"))
        XCTAssertNil(AgentRemoteControlDaemonService.resolveExecutable(named: "non_existent_binary_xyz_123"))
    }

    func testHappyDaemonStartsOnlyWhenInstalledAndLoggedIn() throws {
        let home = FileManager.default.temporaryDirectory.appendingPathComponent("kouen-happy-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: home.appendingPathComponent(".happy"), withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: home) }
        XCTAssertFalse(AgentRemoteControlDaemonService.shouldStartHappyDaemon(happyPath: "/bin/happy", home: home.path),
                       "no access.key yet: not logged in")
        FileManager.default.createFile(atPath: home.appendingPathComponent(".happy/access.key").path, contents: Data("k".utf8))
        XCTAssertTrue(AgentRemoteControlDaemonService.shouldStartHappyDaemon(happyPath: "/bin/happy", home: home.path))
        XCTAssertFalse(AgentRemoteControlDaemonService.shouldStartHappyDaemon(happyPath: nil, home: home.path),
                       "happy not installed")
    }

    func testHappyEnvironmentAddsToolDirsAndPinsClaude() {
        let env = AgentRemoteControlDaemonService.happyEnvironment(
            base: ["PATH": "/usr/bin:/bin"], home: "/h", claude: "/h/.local/bin/claude")
        XCTAssertEqual(env["PATH"], "/h/.local/bin:/h/.volta/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin")
        XCTAssertEqual(env["HAPPY_CLAUDE_PATH"], "/h/.local/bin/claude")
        let keep = AgentRemoteControlDaemonService.happyEnvironment(
            base: ["PATH": "/usr/bin", "HAPPY_CLAUDE_PATH": "/custom"], home: "/h", claude: "/h/.local/bin/claude")
        XCTAssertEqual(keep["HAPPY_CLAUDE_PATH"], "/custom", "an explicit setting wins")
    }

    func testServiceIdempotent() {
        let service = AgentRemoteControlDaemonService()
        let box = LogBox()
        let settings = KouenSettings()

        // Call twice — should be safe and idempotent
        service.startConfiguredDaemons(settings: settings) { box.append($0) }
        let countAfterFirst = box.count
        service.startConfiguredDaemons(settings: settings) { box.append($0) }
        XCTAssertEqual(box.count, countAfterFirst, "Repeated calls must not re-spawn daemons")
    }
}
