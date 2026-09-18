import XCTest
@testable import KouenCore

final class FeatureStoreTests: XCTestCase {
    private var tempDir: URL!
    private var storeURL: URL!

    override func setUpWithError() throws {
        try super.setUpWithError()
        tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        storeURL = tempDir.appendingPathComponent("features.json")
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: tempDir)
        try super.tearDownWithError()
    }

    func testFeatureStoreCRUD() throws {
        let store = FeatureStore(url: storeURL)
        XCTAssertTrue(store.list().isEmpty)

        // Create
        let feature = store.create(
            slug: "p46-agentic-dev",
            repoPath: "/path/to/repo",
            branch: "feat/p46",
            baseBranch: "main",
            worktreePath: "/path/to/repo/.kouen-worktrees/p46-agentic-dev",
            phase: .architect
        )
        XCTAssertEqual(feature.slug, "p46-agentic-dev")
        XCTAssertEqual(feature.phase, .architect)
        XCTAssertEqual(store.list().count, 1)

        // Query
        let fetched = store.get(slug: "p46-agentic-dev")
        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.branch, "feat/p46")

        // Update Phase
        let updated = store.updatePhase(slug: "p46-agentic-dev", phase: .dev)
        XCTAssertEqual(updated?.phase, .dev)
        XCTAssertEqual(store.get(slug: "p46-agentic-dev")?.phase, .dev)

        // Find by branch
        let byBranch = store.find(branch: "feat/p46", repoPath: "/path/to/repo")
        XCTAssertEqual(byBranch?.slug, "p46-agentic-dev")

        // Delete
        let deleted = store.delete(slug: "p46-agentic-dev")
        XCTAssertTrue(deleted)
        XCTAssertNil(store.get(slug: "p46-agentic-dev"))
        XCTAssertTrue(store.list().isEmpty)
    }

    func testGateApprovalLifecycle() throws {
        let store = FeatureStore(url: storeURL)
        store.create(slug: "p46-gate-test", repoPath: "/path/to/repo", phase: .architect)

        // Invalid gate
        let invalid = store.approveGate(slug: "p46-gate-test", gate: 0, approver: "supavit.cho")
        XCTAssertNil(invalid)
        let invalidHigh = store.approveGate(slug: "p46-gate-test", gate: 4, approver: "supavit.cho")
        XCTAssertNil(invalidHigh)

        // Valid Gate 1
        let g1 = store.approveGate(slug: "p46-gate-test", gate: 1, approver: "supavit.cho", notes: "Architecture approved")
        XCTAssertNotNil(g1)
        XCTAssertTrue(g1?.isGateApproved(1) == true)
        XCTAssertFalse(g1?.isGateApproved(2) == true)

        // Valid Gate 2
        let g2 = store.approveGate(slug: "p46-gate-test", gate: 2, approver: "supavit.cho", notes: "Scenarios approved")
        XCTAssertNotNil(g2)
        XCTAssertTrue(g2?.isGateApproved(1) == true)
        XCTAssertTrue(g2?.isGateApproved(2) == true)
        XCTAssertFalse(g2?.isGateApproved(3) == true)
    }

    func testStaleOrSupersededDetection() throws {
        let store = FeatureStore(url: storeURL)
        _ = store.create(slug: "feature-old", repoPath: "/repo", phase: .dev)
        let task1 = FeatureTask(label: "Task 1", artifacts: ["shared/api.swift", "shared/ui.swift"])
        store.addTask(slug: "feature-old", task: task1)

        // Set older date artificially
        let olderFeature = store.get(slug: "feature-old")!
        XCTAssertNotNil(olderFeature)

        // Wait slightly or create newer
        Thread.sleep(forTimeInterval: 0.05)
        _ = store.create(slug: "feature-new", repoPath: "/repo", phase: .dev)
        let task2 = FeatureTask(label: "Task 2", artifacts: ["shared/api.swift", "new/feature.swift"])
        store.addTask(slug: "feature-new", task: task2)

        let newlySuperseded = store.detectStaleOrSuperseded(repoPath: "/repo")
        XCTAssertEqual(newlySuperseded.count, 1)
        XCTAssertEqual(newlySuperseded.first?.slug, "feature-old")
        XCTAssertEqual(newlySuperseded.first?.supersededBy, "feature-new")

        let reloadedOld = store.get(slug: "feature-old")
        XCTAssertEqual(reloadedOld?.supersededBy, "feature-new")
    }

    func testWorktreeBindingReuse() throws {
        let store = FeatureStore(url: storeURL)
        let wt = "/repo/.kouen-worktrees/p46"
        store.create(slug: "p46", repoPath: "/repo", branch: "feat/p46", worktreePath: wt)

        // Look up by branch
        let found = store.find(branch: "feat/p46", repoPath: "/repo")
        XCTAssertEqual(found?.worktreePath, wt)

        // Updating worktree
        let newWt = "/repo/.kouen-worktrees/p46-alt"
        store.setWorktree(slug: "p46", worktreePath: newWt)
        XCTAssertEqual(store.get(slug: "p46")?.worktreePath, newWt)

        // Clear worktree
        store.setWorktree(slug: "p46", worktreePath: nil)
        XCTAssertNil(store.get(slug: "p46")?.worktreePath)
    }

    func testMergedBranchSweepLogic() throws {
        let repoPath = tempDir.appendingPathComponent("gitrepo").path
        try FileManager.default.createDirectory(atPath: repoPath, withIntermediateDirectories: true)
        shell("git init", in: repoPath)
        shell("git branch -m main", in: repoPath)
        shell("git config user.name 'Test Runner'", in: repoPath)
        shell("git config user.email 'test@example.com'", in: repoPath)
        shell("git commit --allow-empty -m 'initial'", in: repoPath)

        let mgr = WorktreeManager()
        let wtPath = try XCTUnwrap(mgr.create(repoPath: repoPath, sessionID: "p46-wt", branch: "feat/sweep"))
        XCTAssertTrue(FileManager.default.fileExists(atPath: wtPath))

        let store = FeatureStore(url: storeURL)
        store.create(
            slug: "p46-sweep",
            repoPath: repoPath,
            branch: "feat/sweep",
            baseBranch: "main",
            worktreePath: wtPath,
            phase: .dev
        )

        // Add a commit in feature branch worktree so feat/sweep is ahead of main
        let dummyFile = wtPath + "/work.txt"
        try "feat content".write(toFile: dummyFile, atomically: true, encoding: .utf8)
        shell("git add work.txt", in: wtPath)
        shell("git commit -m 'feat commit'", in: wtPath)

        // 1. Before merge: feat/sweep is ahead of main -> isMergedOrSquashed is false
        XCTAssertFalse(mgr.isMergedOrSquashed(repoPath: repoPath, branch: "feat/sweep", base: "main"))

        // 2. Merge feat/sweep into main
        shell("git merge feat/sweep", in: repoPath)

        // Now isMergedOrSquashed is true
        XCTAssertTrue(mgr.isMergedOrSquashed(repoPath: repoPath, branch: "feat/sweep", base: "main"))

        // 3. If dirty: dirty guard protects it
        let dirtyFile = wtPath + "/uncommitted.txt"
        try "dirty".write(toFile: dirtyFile, atomically: true, encoding: .utf8)
        XCTAssertTrue(mgr.isDirty(worktreePath: wtPath))

        // When clean:
        try FileManager.default.removeItem(atPath: dirtyFile)
        XCTAssertFalse(mgr.isDirty(worktreePath: wtPath))

        let removed = mgr.remove(repoPath: repoPath, worktreePath: wtPath, force: false)
        XCTAssertTrue(removed)
        XCTAssertFalse(FileManager.default.fileExists(atPath: wtPath))

        // Store updates
        store.setWorktree(slug: "p46-sweep", worktreePath: nil)
        store.updatePhase(slug: "p46-sweep", phase: .completed)
        XCTAssertNil(store.get(slug: "p46-sweep")?.worktreePath)
        XCTAssertEqual(store.get(slug: "p46-sweep")?.phase, .completed)
    }

    @discardableResult
    private func shell(_ command: String, in dir: String) -> String? {
        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(fileURLWithPath: "/bin/sh")
        process.arguments = ["-c", command]
        process.currentDirectoryURL = URL(fileURLWithPath: dir)
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice
        try? process.run()
        process.waitUntilExit()
        return String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)
    }
}
