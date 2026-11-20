import XCTest
@testable import KouenCore
@testable import KouenDaemonCore

/// [TC-0301][BE-IT] A slow archive script (worktree cleanup on closeSession) must not stall the daemon:
/// other clients' requests are served while it runs. [TC-0302][BE-UT] a TERM-ignoring archive script is
/// SIGKILLed after the grace period instead of holding the caller forever.
final class DaemonOffLockWorktreeTests: XCTestCase {
    private var root: URL!
    private var repoPath: String!
    private var previousHome: String?
    private var server: DaemonServer!

    override func setUpWithError() throws {
        previousHome = getenv("KOUEN_HOME").map { String(cString: $0) }
        root = URL(fileURLWithPath: "/tmp/dol-\(UUID().uuidString.prefix(8))", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        setenv("KOUEN_HOME", root.path, 1)
        try KouenPaths.ensureDirectories()
        repoPath = root.appendingPathComponent("repo").path
        try FileManager.default.createDirectory(atPath: repoPath, withIntermediateDirectories: true)
        shell("git init && git config user.name 'Kouen Tests' && git config user.email kouen-tests@example.invalid && git commit --allow-empty -m init", in: repoPath)
    }

    override func tearDownWithError() throws {
        server?.stop()
        server = nil
        if let previousHome { setenv("KOUEN_HOME", previousHome, 1) } else { unsetenv("KOUEN_HOME") }
        try? FileManager.default.removeItem(at: root)
    }

    func test_TC0301_BE_IT_slowArchiveScriptDoesNotBlockOtherRequests() throws {
        try skipUnlessLiveDaemonTests()
        server = DaemonServer()
        try server.start()
        let client = DaemonClient()
        var ready = false
        for _ in 0 ..< 50 where !ready {
            if case .pong = (try? client.request(.ping, timeout: 0.4)) { ready = true } else { usleep(100_000) }
        }
        XCTAssertTrue(ready)

        let wtPath = try XCTUnwrap(WorktreeManager().create(repoPath: repoPath, sessionID: "slow1", branch: "slow-close"))
        let started = root.appendingPathComponent("started").path
        try #"{"archiveScript": "touch \#(started); sleep 3"}"#.write(toFile: wtPath + "/kouen.json", atomically: true, encoding: .utf8)
        shell("git add kouen.json && git commit -m cfg", in: wtPath)

        guard case let .snapshot(snap) = try client.request(.getSnapshot, timeout: 2),
              let wsID = snap.workspaces.first?.id,
              case let .sessionID(wtSession) = try client.request(.newSession(
                  workspaceID: wsID, cwd: wtPath, name: "wt", worktreePath: wtPath, parentRepoPath: repoPath), timeout: 5),
              case let .sessionID(plainSession) = try client.request(.newSession(workspaceID: wsID, cwd: "/tmp", name: "plain"), timeout: 5),
              case let .snapshot(after) = try client.request(.getSnapshot, timeout: 2),
              let surface = after.workspaces.flatMap(\.sessions).first(where: { $0.id == plainSession })?
                  .tabs.first?.rootPane.allSurfaceIDs().first?.uuidString
        else { return XCTFail("setup failed") }

        let closed = expectation(description: "closeSession replied")
        DispatchQueue.global().async {
            if case .ok? = try? DaemonClient().request(.closeSession(sessionID: wtSession), timeout: 15) { closed.fulfill() }
        }
        // Condition poll: the archive script has begun, so the slow cleanup is in flight.
        let deadline = Date().addingTimeInterval(5)
        while !FileManager.default.fileExists(atPath: started), Date() < deadline { usleep(10_000) }
        XCTAssertTrue(FileManager.default.fileExists(atPath: started), "archive script never started")

        let t0 = Date()
        let reply = try client.request(.send(surfaceID: surface, text: "", origin: .human), timeout: 5)
        let elapsed = Date().timeIntervalSince(t0)
        XCTAssertLessThan(elapsed, 0.2, "send waited \(elapsed)s behind the archive script; reply \(reply)")

        wait(for: [closed], timeout: 15)
        XCTAssertFalse(FileManager.default.fileExists(atPath: wtPath), "worktree is still removed after the script")
    }

    func test_TC0302_BE_UT_termIgnoringArchiveScriptIsKilledAfterGrace() {
        let t0 = Date()
        let ok = WorktreeManager().runArchiveScript("trap '' TERM; sleep 6", cwd: root.path, timeout: 0.3, killGrace: 0.3)
        XCTAssertFalse(ok)
        XCTAssertLessThan(Date().timeIntervalSince(t0), 3, "script survived SIGTERM and held the caller")
    }

    @discardableResult
    private func shell(_ command: String, in dir: String) -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/sh")
        process.arguments = ["-c", command]
        process.currentDirectoryURL = URL(fileURLWithPath: dir)
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        try? process.run()
        process.waitUntilExit()
        return nil
    }
}
