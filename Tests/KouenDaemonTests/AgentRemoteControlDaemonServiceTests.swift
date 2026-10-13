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
