import Foundation
import XCTest
@testable import KouenCore

final class SSHTunnelLeaseTests: XCTestCase {
    private var root: URL!
    private let ownerPID: Int32 = 2_000_000_001
    private let childPID: Int32 = 2_000_000_002

    override func setUpWithError() throws {
        root = FileManager.default.temporaryDirectory.appendingPathComponent("kouen-lease-" + UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
    }
    override func tearDownWithError() throws { try FileManager.default.removeItem(at: root) }

    private func identity(_ pid: Int32, birth: String = "original", executable: String = "/usr/bin/ssh") -> SSHTunnelProcessIdentity {
        .init(pid: pid, birth: birth, uid: UInt32(getuid()), executable: executable)
    }
    private func lease(owner: SSHTunnelProcessIdentity? = nil) throws -> URL {
        let file = root.appendingPathComponent("fixture.sock.lease.json")
        let lease = SSHTunnelLeaseStore.Lease(owner: owner ?? identity(ownerPID), child: identity(childPID), socketName: "fixture.sock")
        try JSONEncoder().encode(lease).write(to: file)
        return file
    }

    func test_TS_2374_BE_UT_orphanSweepSignalsOnlyMatchingChildBirth() throws {
        _ = try lease()
        var signalled: [Int32] = []
        let child = identity(childPID)
        let store = SSHTunnelLeaseStore(directory: root, snapshot: { $0 == child.pid ? child : nil },
                                       terminate: { signalled.append($0); return true })
        store.sweep()
        XCTAssertEqual(signalled, [childPID])
    }

    func test_TS_2375_BE_UT_liveOwnerAndReusedChildPIDArePreserved() throws {
        _ = try lease()
        let owner = identity(ownerPID)
        let child = identity(childPID)
        var signalled: [Int32] = []
        let live = SSHTunnelLeaseStore(directory: root, snapshot: { $0 == owner.pid ? owner : child },
                                      terminate: { signalled.append($0); return true })
        live.sweep()
        let reused = identity(childPID, birth: "reused")
        let stale = SSHTunnelLeaseStore(directory: root, snapshot: { $0 == reused.pid ? reused : nil },
                                       terminate: { signalled.append($0); return true })
        stale.sweep()
        XCTAssertTrue(signalled.isEmpty)
    }

    func test_TS_2376_BE_UT_deadLeaseDoesNotUnlinkPotentialLiveSocket() throws {
        let file = try lease()
        let socket = root.appendingPathComponent("fixture.sock")
        try Data().write(to: socket)
        let unrelated = root.appendingPathComponent("other.sock")
        try Data().write(to: unrelated)
        SSHTunnelLeaseStore(directory: root, snapshot: { _ in nil }, terminate: { _ in XCTFail("Dead PID must not be signalled"); return false }).sweep()
        XCTAssertFalse(FileManager.default.fileExists(atPath: file.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: socket.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: unrelated.path))
    }

    func test_TS_2377_BE_UT_unknownLiveOwnerAndUntrustedDirectoryArePreserved() throws {
        let owner = SSHTunnelProcessIdentity(pid: Int32(getpid()), birth: "unreadable", uid: UInt32(getuid()), executable: "/fixture")
        _ = try lease(owner: owner)
        let child = identity(childPID)
        let store = SSHTunnelLeaseStore(directory: root, snapshot: { $0 == child.pid ? child : nil },
                                       terminate: { _ in XCTFail("Unknown live owner must survive"); return false })
        store.sweep()
        try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: root.path)
        SSHTunnelLeaseStore(directory: root, snapshot: { $0 == child.pid ? child : nil },
                            terminate: { _ in XCTFail("Untrusted directory must not authorize a signal"); return false }).sweep()
    }

    func test_TS_2378_BE_IT_nativeProcessIdentityIsStableAndBirthBound() throws {
        let own = try XCTUnwrap(SSHTunnelProcessIdentity.read(Int32(getpid())))
        XCTAssertEqual(own, SSHTunnelProcessIdentity.read(Int32(getpid())))
        XCTAssertEqual(own.uid, UInt32(getuid()))
        XCTAssertFalse(own.birth.isEmpty)
        XCTAssertFalse(own.executable.isEmpty)
        XCTAssertNil(SSHTunnelProcessIdentity.read(-1))
    }

    func test_TS_2387_BE_IT_leaseRoundTripTerminatesOnlyAnOwnedFixture() throws {
        let socket = root.appendingPathComponent("fixture.sock")
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/sh")
        process.arguments = ["-c", "exec /bin/sleep 60", "-N", "-L", socket.path + ":/remote.sock"]
        let exited = expectation(description: "Owned fixture exits after orphan cleanup")
        process.terminationHandler = { _ in exited.fulfill() }
        try process.run()
        defer { if process.isRunning { process.terminate() }; process.waitUntilExit() }
        let owner = try XCTUnwrap(SSHTunnelProcessIdentity.read(Int32(getpid())))
        let child = SSHTunnelProcessIdentity(pid: process.processIdentifier, birth: "fixture-birth", uid: UInt32(getuid()), executable: "/usr/bin/ssh")
        let writer = SSHTunnelLeaseStore(directory: root, snapshot: { $0 == owner.pid ? owner : child })
        writer.record(process: process, socket: socket)
        let file = socket.appendingPathExtension("lease.json")
        XCTAssertTrue(FileManager.default.fileExists(atPath: file.path))
        let metadata = try FileManager.default.attributesOfItem(atPath: file.path)
        XCTAssertEqual((metadata[.posixPermissions] as? NSNumber)?.intValue, 0o600)
        let orphanOwner = identity(ownerPID)
        let record = SSHTunnelLeaseStore.Lease(owner: orphanOwner, child: child, socketName: socket.lastPathComponent)
        try JSONEncoder().encode(record).write(to: file)
        SSHTunnelLeaseStore(directory: root, snapshot: { $0 == child.pid ? child : nil }, terminate: { pid in
            XCTAssertEqual(pid, process.processIdentifier)
            process.terminate()
            return true
        }).sweep()
        wait(for: [exited], timeout: 3)
        XCTAssertFalse(process.isRunning)
        writer.remove(process: process, socket: socket)
        XCTAssertFalse(FileManager.default.fileExists(atPath: file.path))
    }

    func test_TS_2379_BE_UT_reusedOwnerPIDDoesNotProtectAnOrphan() throws {
        _ = try lease()
        let owner = identity(ownerPID, birth: "new-owner")
        let child = identity(childPID)
        var signalled: [Int32] = []
        SSHTunnelLeaseStore(directory: root, snapshot: { $0 == owner.pid ? owner : child },
                            terminate: { signalled.append($0); return true }).sweep()
        XCTAssertEqual(signalled, [childPID])
    }
}
