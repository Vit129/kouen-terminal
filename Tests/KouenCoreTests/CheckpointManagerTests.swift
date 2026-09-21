import XCTest
@testable import KouenCore

/// P46 Phase 3: `CheckpointManager` — shadow git commits for `kouen undo`, built through a
/// temporary index so they never touch the real staging area or `git stash`.
final class CheckpointManagerTests: XCTestCase {
    private var tempDir: String!
    private var repoPath: String!
    private let mgr = CheckpointManager()

    override func setUpWithError() throws {
        tempDir = NSTemporaryDirectory() + "kouen-checkpoint-test-\(UUID().uuidString.prefix(8))"
        repoPath = tempDir + "/repo"
        try FileManager.default.createDirectory(atPath: repoPath, withIntermediateDirectories: true)
        _ = shell("git init", in: repoPath)
        _ = shell("git config user.name 'Test Runner'", in: repoPath)
        _ = shell("git config user.email 'test@example.com'", in: repoPath)
        FileManager.default.createFile(atPath: repoPath + "/tracked.txt", contents: "v1".data(using: .utf8))
        _ = shell("git add tracked.txt && git commit -m init", in: repoPath)
    }

    override func tearDownWithError() throws {
        if let dir = tempDir { try? FileManager.default.removeItem(atPath: dir) }
    }

    func testCreateSnapshotsTrackedAndUntrackedChangesWithoutTouchingRealIndex() throws {
        try "v2".write(toFile: repoPath + "/tracked.txt", atomically: true, encoding: .utf8)
        FileManager.default.createFile(atPath: repoPath + "/untracked.txt", contents: "new".data(using: .utf8))
        // A file the agent staged itself — the checkpoint must not disturb this.
        FileManager.default.createFile(atPath: repoPath + "/staged.txt", contents: "staged".data(using: .utf8))
        _ = shell("git add staged.txt", in: repoPath)

        let checkpoint = try XCTUnwrap(mgr.create(cwd: repoPath, session: "s1"))
        XCTAssertEqual(checkpoint.turn, 1)
        XCTAssertTrue(checkpoint.diffStat.contains("tracked.txt"))
        XCTAssertTrue(checkpoint.diffStat.contains("untracked.txt"))

        // The real index is untouched: `staged.txt` is still staged, nothing else got added to it.
        let status = shell("git status --porcelain", in: repoPath) ?? ""
        XCTAssertTrue(status.contains("A  staged.txt"), "staged.txt must remain staged exactly as the user left it: \(status)")
        XCTAssertTrue(status.contains(" M tracked.txt"), "tracked.txt must remain unstaged: \(status)")
        XCTAssertTrue(status.contains("?? untracked.txt"), "untracked.txt must remain untracked: \(status)")

        // No real stash was created either.
        let stashList = shell("git stash list", in: repoPath) ?? ""
        XCTAssertTrue(stashList.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }

    func testCreateIsANoOpWhenNothingChangedSinceTheLastCheckpoint() throws {
        try "v2".write(toFile: repoPath + "/tracked.txt", atomically: true, encoding: .utf8)
        _ = try XCTUnwrap(mgr.create(cwd: repoPath, session: "s2"))

        // Same working tree, no new edits — a second call must not create turn 2.
        XCTAssertNil(mgr.create(cwd: repoPath, session: "s2"))
        XCTAssertEqual(mgr.list(cwd: repoPath, session: "s2").count, 1)
    }

    func testListReturnsCheckpointsOldestFirstBySession() throws {
        try "v2".write(toFile: repoPath + "/tracked.txt", atomically: true, encoding: .utf8)
        _ = try XCTUnwrap(mgr.create(cwd: repoPath, session: "s3"))
        try "v3".write(toFile: repoPath + "/tracked.txt", atomically: true, encoding: .utf8)
        _ = try XCTUnwrap(mgr.create(cwd: repoPath, session: "s3"))

        let checkpoints = mgr.list(cwd: repoPath, session: "s3")
        XCTAssertEqual(checkpoints.map(\.turn), [1, 2])

        // A different session's namespace is untouched.
        XCTAssertTrue(mgr.list(cwd: repoPath, session: "other-session").isEmpty)
    }

    func testRestoreRevertsWorkingTreeWithoutMovingHEAD() throws {
        try "v2".write(toFile: repoPath + "/tracked.txt", atomically: true, encoding: .utf8)
        _ = try XCTUnwrap(mgr.create(cwd: repoPath, session: "s4"))

        // Agent makes it worse in a later turn.
        try "v3-broken".write(toFile: repoPath + "/tracked.txt", atomically: true, encoding: .utf8)

        let headBefore = shell("git rev-parse HEAD", in: repoPath)
        XCTAssertTrue(mgr.restore(cwd: repoPath, session: "s4"))
        let headAfter = shell("git rev-parse HEAD", in: repoPath)

        XCTAssertEqual(headBefore, headAfter, "restore must never move HEAD/branch")
        let content = try String(contentsOfFile: repoPath + "/tracked.txt", encoding: .utf8)
        XCTAssertEqual(content, "v2", "working tree must be back to the checkpointed content, not the later broken edit")
    }

    func testRestoreWithNoCheckpointsReturnsFalse() {
        XCTAssertFalse(mgr.restore(cwd: repoPath, session: "never-checkpointed"))
    }

    private func shell(_ command: String, in dir: String) -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-c", command]
        process.currentDirectoryURL = URL(fileURLWithPath: dir)
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()
        try? process.run()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
