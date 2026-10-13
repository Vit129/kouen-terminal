import Foundation
import HarnessCore
import XCTest
@testable import HarnessApp

final class DaemonLauncherTests: XCTestCase {
    private final class Service: @unchecked Sendable {
        private let lock = NSLock()
        private var replacements = 0
        private var stops = 0
        let before: DaemonStats
        let after: DaemonStats?
        let reply: IPCResponse

        init(before: DaemonStats, after: DaemonStats? = nil, reply: IPCResponse = .ok) {
            self.before = before; self.after = after; self.reply = reply
        }
        var counts: (replacements: Int, stops: Int) { lock.withLock { (replacements, stops) } }
        func request(_ request: IPCRequest, timeout: TimeInterval) throws -> IPCResponse {
            lock.withLock {
                switch request {
                case .daemonStats:
                    guard let stats = replacements == 0 ? before : after else { return .error("Unavailable") }
                    return .daemonStats(stats)
                case let .replaceDaemon(executable):
                    XCTAssertNotNil(executable, "Adoption must use the updated app's executable, never the host's old default")
                    replacements += 1
                    return reply
                default: XCTFail("Unexpected startup request: \(request)"); return .error("Unexpected request")
                }
            }
        }
        func stopEmptyOwner() throws {
            lock.withLock { stops += 1 }
            throw DaemonRestart.Failure.refused("A new shell arrived before the atomic empty check")
        }
        var launcher: DaemonLauncher { DaemonLauncher(request: request, stopEmptyOwner: stopEmptyOwner) }
    }

    private func current() -> DaemonStats {
        var stats = DaemonStats(pid: 123, uptimeSeconds: 1, surfaceCount: 2, totalScrollbackBytes: 0,
            clientCount: 0, subscriberCount: 0, snapshotRevision: 1, version: HarnessVersion.short,
            build: HarnessVersion.build, capabilities: DaemonStats.currentCapabilities + [DaemonStats.sessionHost],
            protocolLevel: HarnessVersion.protocolLevel, sessionHostPID: 123, sessionHostBuild: HarnessVersion.build)
        stats.sessionHostProtocolLevel = DaemonStats.currentSessionHostProtocolLevel
        stats.daemonAvailable = true
        return stats
    }

    func testCurrentServiceNeedsNoReplacement() {
        let service = Service(before: current())
        XCTAssertTrue(service.launcher.ensureRunningBlocking())
        XCTAssertEqual(service.counts.replacements, 0)
        XCTAssertEqual(service.counts.stops, 0)
    }

    func testUnavailableApplicationDaemonRecoversWithoutStoppingShells() {
        var stats = current(); stats.daemonAvailable = false
        let service = Service(before: stats, after: current())
        let launcher = service.launcher
        XCTAssertTrue(launcher.ensureRunningBlocking())
        XCTAssertEqual(service.counts.replacements, 1)
        XCTAssertEqual(service.counts.stops, 0)
        XCTAssertNil(launcher.pendingUpgrade)
    }

    func testReceiptDoesNotEstablishReadinessWithoutAUsableDaemon() {
        for missingReply in [false, true] {
            var stats = current(); stats.build = HarnessVersion.build - 1
            var unavailable = current(); unavailable.daemonAvailable = false
            let service = Service(before: stats, after: missingReply ? nil : unavailable)
            let launcher = service.launcher
            XCTAssertFalse(launcher.ensureRunningBlocking())
            XCTAssertNotNil(launcher.pendingUpgrade)
            XCTAssertEqual(service.counts.stops, 0)
        }
    }

    func testFailedAdoptionRetainsACompatibleOlderServiceAndPendingUpdate() {
        var stats = current(); stats.build = HarnessVersion.build - 1
        let service = Service(before: stats, after: stats, reply: .error("Candidate could not restore its checkpoint"))
        let launcher = service.launcher
        XCTAssertTrue(launcher.ensureRunningBlocking())
        XCTAssertNotNil(launcher.pendingUpgrade)
        XCTAssertEqual(service.counts.stops, 0)
    }

    func testIncompatibleEmptyOwnerUsesGuardedRestartAndARacingShellCannotMakeItReady() {
        var stats = current(); stats.surfaceCount = 0
        stats.sessionHostProtocolLevel = DaemonStats.currentSessionHostProtocolLevel - 1
        let service = Service(before: stats)
        XCTAssertFalse(service.launcher.ensureRunningBlocking())
        XCTAssertEqual(service.counts.stops, 1)
        XCTAssertEqual(service.counts.replacements, 0)
    }

    func testIncompatibleLiveOwnerKeepsItsProgramsAndRequiresRecovery() {
        var stats = current(); stats.sessionHostProtocolLevel = DaemonStats.currentSessionHostProtocolLevel - 1
        let service = Service(before: stats)
        XCTAssertFalse(service.launcher.ensureRunningBlocking())
        XCTAssertEqual(service.counts.stops, 0)
        XCTAssertEqual(service.counts.replacements, 0)
    }
}
