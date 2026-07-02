import XCTest
@testable import HarnessCore
@testable import HarnessDaemonCore

/// Integration tests for worktree-per-session isolation via SurfaceRegistry.handle().
/// Drives the daemon directly (no socket) with a temp git repo.
final class WorktreeIsolationDaemonTests: XCTestCase {
    private var root: URL!
    private var repoPath: String!
    private var previousHome: String?
    private var previousShell: String?

    override func setUpWithError() throws {
        previousHome = getenv("HARNESS_HOME").map { String(cString: $0) }
        previousShell = getenv("SHELL").map { String(cString: $0) }
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("harness-wt-daemon-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        root = dir
        setenv("HARNESS_HOME", dir.path, 1)
        try HarnessPaths.ensureDirectories()

        // Create a real git repo for worktree tests
        repoPath = dir.appendingPathComponent("repo").path
        try FileManager.default.createDirectory(atPath: repoPath, withIntermediateDirectories: true)
        shell("git init && git commit --allow-empty -m init", in: repoPath)
    }

    override func tearDownWithError() throws {
        if let previousHome { setenv("HARNESS_HOME", previousHome, 1) } else { unsetenv("HARNESS_HOME") }
        if let previousShell { setenv("SHELL", previousShell, 1) } else { unsetenv("SHELL") }
        try? FileManager.default.removeItem(at: root)
    }

    // MARK: - newSession with worktree metadata

    func testNewSessionWithWorktreeTagsTab() throws {
        let registry = SurfaceRegistry()
        let wsID = try workspaceID(registry)

        // Create worktree first (like CLI --isolate does)
        let mgr = WorktreeManager()
        let wtPath = try XCTUnwrap(mgr.create(repoPath: repoPath, sessionID: "test1", branch: "feat-x"))

        // Send newSession with worktree metadata
        let response = registry.handle(.newSession(
            workspaceID: wsID, cwd: wtPath, name: "isolated-session",
            worktreePath: wtPath, parentRepoPath: repoPath
        ))

        guard case let .sessionID(sessionID) = response else {
            return XCTFail("Expected sessionID, got \(response)")
        }

        // Verify tab has worktree metadata
        guard case let .snapshot(snap) = registry.handle(.getSnapshot) else {
            return XCTFail("Expected snapshot")
        }
        let session = try XCTUnwrap(snap.workspaces.flatMap(\.sessions).first(where: { $0.id == sessionID }))
        let tab = try XCTUnwrap(session.tabs.first)
        XCTAssertEqual(tab.worktreePath, wtPath)
        XCTAssertEqual(tab.parentRepoPath, repoPath)
        XCTAssertEqual(tab.cwd, wtPath)
    }

    func testNewSessionWithoutWorktreeHasNilFields() throws {
        let registry = SurfaceRegistry()
        let wsID = try workspaceID(registry)

        let response = registry.handle(.newSession(workspaceID: wsID, cwd: "/tmp", name: "normal"))
        guard case let .sessionID(sessionID) = response else {
            return XCTFail("Expected sessionID")
        }

        guard case let .snapshot(snap) = registry.handle(.getSnapshot) else {
            return XCTFail("Expected snapshot")
        }
        let session = try XCTUnwrap(snap.workspaces.flatMap(\.sessions).first(where: { $0.id == sessionID }))
        XCTAssertNil(session.tabs.first?.worktreePath)
        XCTAssertNil(session.tabs.first?.parentRepoPath)
    }

    // MARK: - closeSession cleans up worktree

    func testCloseSessionRemovesCleanWorktree() throws {
        let registry = SurfaceRegistry()
        let wsID = try workspaceID(registry)

        let mgr = WorktreeManager()
        let wtPath = try XCTUnwrap(mgr.create(repoPath: repoPath, sessionID: "cl1", branch: "to-close"))
        XCTAssertTrue(FileManager.default.fileExists(atPath: wtPath))

        let response = registry.handle(.newSession(
            workspaceID: wsID, cwd: wtPath, name: "will-close",
            worktreePath: wtPath, parentRepoPath: repoPath
        ))
        guard case let .sessionID(sessionID) = response else {
            return XCTFail("Expected sessionID")
        }

        // Close the session
        let closeResponse = registry.handle(.closeSession(sessionID: sessionID))
        guard case .ok = closeResponse else {
            return XCTFail("Expected ok, got \(closeResponse)")
        }

        // Worktree should be removed (was clean)
        XCTAssertFalse(FileManager.default.fileExists(atPath: wtPath))
    }

    // MARK: - P32 F3: archiveScript runs before worktree removal

    func testCloseSessionRunsArchiveScriptBeforeRemoval() throws {
        let registry = SurfaceRegistry()
        let wsID = try workspaceID(registry)

        let mgr = WorktreeManager()
        let wtPath = try XCTUnwrap(mgr.create(repoPath: repoPath, sessionID: "arch1", branch: "archive-close"))

        // A harness.json with archiveScript that writes a marker file OUTSIDE the worktree
        // (so we can still see it after the worktree dir is removed) and reads an injected env var.
        let markerPath = root.appendingPathComponent("marker.txt").path
        let config = """
        {"archiveScript": "echo done-$MARKER_TOKEN > \(markerPath)", "env": {"MARKER_TOKEN": "abc123"}}
        """
        try config.write(toFile: wtPath + "/harness.json", atomically: true, encoding: .utf8)
        shell("git add harness.json && git commit -m cfg", in: wtPath)

        let response = registry.handle(.newSession(
            workspaceID: wsID, cwd: wtPath, name: "archive-session",
            worktreePath: wtPath, parentRepoPath: repoPath
        ))
        guard case let .sessionID(sessionID) = response else {
            return XCTFail("Expected sessionID")
        }

        _ = registry.handle(.closeSession(sessionID: sessionID))

        // Worktree removed (clean after commit)...
        XCTAssertFalse(FileManager.default.fileExists(atPath: wtPath))
        // ...but the archiveScript ran first, with cwd inside the worktree and env injected.
        let markerContents = try String(contentsOfFile: markerPath, encoding: .utf8)
        XCTAssertEqual(markerContents.trimmingCharacters(in: .whitespacesAndNewlines), "done-abc123")
    }

    func testCloseSessionKeepsDirtyWorktree() throws {
        let registry = SurfaceRegistry()
        let wsID = try workspaceID(registry)

        let mgr = WorktreeManager()
        let wtPath = try XCTUnwrap(mgr.create(repoPath: repoPath, sessionID: "cl2", branch: "dirty-close"))

        // Make it dirty
        FileManager.default.createFile(atPath: wtPath + "/uncommitted.txt", contents: "wip".data(using: .utf8))

        let response = registry.handle(.newSession(
            workspaceID: wsID, cwd: wtPath, name: "dirty-session",
            worktreePath: wtPath, parentRepoPath: repoPath
        ))
        guard case let .sessionID(sessionID) = response else {
            return XCTFail("Expected sessionID")
        }

        _ = registry.handle(.closeSession(sessionID: sessionID))

        // Worktree should still exist (dirty)
        XCTAssertTrue(FileManager.default.fileExists(atPath: wtPath))
    }

    // MARK: - Multiple isolated sessions in same repo

    func testMultipleIsolatedSessionsIndependent() throws {
        let registry = SurfaceRegistry()
        let wsID = try workspaceID(registry)
        let mgr = WorktreeManager()

        let wt1 = try XCTUnwrap(mgr.create(repoPath: repoPath, sessionID: "m1", branch: "branch-a"))
        let wt2 = try XCTUnwrap(mgr.create(repoPath: repoPath, sessionID: "m2", branch: "branch-b"))

        let r1 = registry.handle(.newSession(workspaceID: wsID, cwd: wt1, name: "sess-a", worktreePath: wt1, parentRepoPath: repoPath))
        let r2 = registry.handle(.newSession(workspaceID: wsID, cwd: wt2, name: "sess-b", worktreePath: wt2, parentRepoPath: repoPath))

        guard case let .sessionID(id1) = r1, case let .sessionID(id2) = r2 else {
            return XCTFail("Expected two sessionIDs")
        }

        // Close first — second's worktree survives
        _ = registry.handle(.closeSession(sessionID: id1))
        XCTAssertFalse(FileManager.default.fileExists(atPath: wt1))
        XCTAssertTrue(FileManager.default.fileExists(atPath: wt2))

        // Close second
        _ = registry.handle(.closeSession(sessionID: id2))
        XCTAssertFalse(FileManager.default.fileExists(atPath: wt2))
    }

    // MARK: - Split pane inherits worktree

    func testSplitPaneInIsolatedSessionInheritsWorktree() throws {
        let registry = SurfaceRegistry()
        let wsID = try workspaceID(registry)
        let mgr = WorktreeManager()

        let wtPath = try XCTUnwrap(mgr.create(repoPath: repoPath, sessionID: "sp1", branch: "split-test"))
        let response = registry.handle(.newSession(workspaceID: wsID, cwd: wtPath, name: "split-sess", worktreePath: wtPath, parentRepoPath: repoPath))
        guard case let .sessionID(sessionID) = response else { return XCTFail("Expected sessionID") }

        // Get the tab to split
        guard case let .snapshot(snap) = registry.handle(.getSnapshot) else { return XCTFail("Expected snapshot") }
        let session = try XCTUnwrap(snap.workspaces.flatMap(\.sessions).first(where: { $0.id == sessionID }))
        let tab = try XCTUnwrap(session.tabs.first)

        // Split
        let splitResponse = registry.handle(.newSplit(tabID: tab.id, paneID: nil, direction: .horizontal))
        guard case .paneID = splitResponse else { return XCTFail("Expected paneID, got \(splitResponse)") }

        // After split, tab still has worktree metadata
        guard case let .snapshot(snap2) = registry.handle(.getSnapshot) else { return XCTFail("Expected snapshot") }
        let updatedSession = try XCTUnwrap(snap2.workspaces.flatMap(\.sessions).first(where: { $0.id == sessionID }))
        let updatedTab = try XCTUnwrap(updatedSession.tabs.first)
        XCTAssertEqual(updatedTab.worktreePath, wtPath)
        // Both panes should exist
        XCTAssertEqual(updatedTab.rootPane.allPaneIDs().count, 2)
    }

    // MARK: - Switch session preserves worktree

    func testSwitchSessionAndBackPreservesWorktree() throws {
        let registry = SurfaceRegistry()
        let wsID = try workspaceID(registry)
        let mgr = WorktreeManager()

        // Create normal session
        let normalResp = registry.handle(.newSession(workspaceID: wsID, cwd: "/tmp", name: "normal"))
        guard case let .sessionID(normalID) = normalResp else { return XCTFail("Expected sessionID") }

        // Create isolated session
        let wtPath = try XCTUnwrap(mgr.create(repoPath: repoPath, sessionID: "sw1", branch: "switch-test"))
        let isoResp = registry.handle(.newSession(workspaceID: wsID, cwd: wtPath, name: "isolated", worktreePath: wtPath, parentRepoPath: repoPath))
        guard case let .sessionID(isoID) = isoResp else { return XCTFail("Expected sessionID") }

        // Switch to normal
        _ = registry.handle(.selectSession(workspaceID: wsID, sessionID: normalID))

        // Switch back to isolated
        _ = registry.handle(.selectSession(workspaceID: wsID, sessionID: isoID))

        // Worktree metadata still intact
        guard case let .snapshot(snap) = registry.handle(.getSnapshot) else { return XCTFail("Expected snapshot") }
        let session = try XCTUnwrap(snap.workspaces.flatMap(\.sessions).first(where: { $0.id == isoID }))
        XCTAssertEqual(session.tabs.first?.worktreePath, wtPath)
        // Worktree directory still on disk
        XCTAssertTrue(FileManager.default.fileExists(atPath: wtPath))
    }

    // MARK: - Close pane (not session) keeps worktree

    func testClosePaneKeepsWorktreeAlive() throws {
        let registry = SurfaceRegistry()
        let wsID = try workspaceID(registry)
        let mgr = WorktreeManager()

        let wtPath = try XCTUnwrap(mgr.create(repoPath: repoPath, sessionID: "cp1", branch: "pane-close"))
        let response = registry.handle(.newSession(workspaceID: wsID, cwd: wtPath, name: "pane-sess", worktreePath: wtPath, parentRepoPath: repoPath))
        guard case let .sessionID(sessionID) = response else { return XCTFail("Expected sessionID") }

        // Split to create second pane
        guard case let .snapshot(snap) = registry.handle(.getSnapshot) else { return XCTFail("Expected snapshot") }
        let tab = try XCTUnwrap(snap.workspaces.flatMap(\.sessions).first(where: { $0.id == sessionID })?.tabs.first)
        _ = registry.handle(.newSplit(tabID: tab.id, paneID: nil, direction: .horizontal))

        // Close one pane (session stays because other pane remains)
        guard case let .snapshot(snap2) = registry.handle(.getSnapshot) else { return XCTFail("Expected snapshot") }
        let panes = try XCTUnwrap(snap2.workspaces.flatMap(\.sessions).first(where: { $0.id == sessionID })?.tabs.first?.rootPane.allPaneIDs())
        XCTAssertEqual(panes.count, 2)

        // Close the last pane added (session collapses to single pane, NOT closed)
        _ = registry.handle(.killPane(paneID: panes.last!))

        // Worktree still exists
        XCTAssertTrue(FileManager.default.fileExists(atPath: wtPath))
    }

    // MARK: - Git checkout in normal doesn't affect isolated

    func testGitCheckoutInNormalDoesNotAffectIsolated() throws {
        let registry = SurfaceRegistry()
        let wsID = try workspaceID(registry)
        let mgr = WorktreeManager()

        let wtPath = try XCTUnwrap(mgr.create(repoPath: repoPath, sessionID: "gc1", branch: "stable-branch"))

        _ = registry.handle(.newSession(workspaceID: wsID, cwd: wtPath, name: "isolated", worktreePath: wtPath, parentRepoPath: repoPath))

        // Checkout different branch in main repo
        shell("git checkout -b other-branch", in: repoPath)

        // Main repo is on other-branch
        let mainBranch = shell("git branch --show-current", in: repoPath)?.trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertEqual(mainBranch, "other-branch")

        // Worktree still on its own branch
        let wtBranch = shell("git branch --show-current", in: wtPath)?.trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertEqual(wtBranch, "stable-branch")
    }

    // MARK: - Helpers

    private func workspaceID(_ registry: SurfaceRegistry) throws -> UUID {
        guard case let .snapshot(snap) = registry.handle(.getSnapshot) else {
            throw XCTestError(.failureWhileWaiting)
        }
        return try XCTUnwrap(snap.workspaces.first?.id)
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
