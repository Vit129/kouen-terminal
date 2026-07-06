import XCTest
@testable import KouenCore

final class WorktreeIsolationTests: XCTestCase {
    private var tempDir: String!
    private var repoPath: String!
    private let mgr = WorktreeManager()

    override func setUpWithError() throws {
        tempDir = NSTemporaryDirectory() + "kouen-wt-test-\(UUID().uuidString.prefix(8))"
        repoPath = tempDir + "/repo"
        try FileManager.default.createDirectory(atPath: repoPath, withIntermediateDirectories: true)
        // Init a git repo with one commit so worktrees work
        shell("git init", in: repoPath)
        shell("git commit --allow-empty -m 'init'", in: repoPath)
    }

    override func tearDownWithError() throws {
        if let dir = tempDir { try? FileManager.default.removeItem(atPath: dir) }
    }

    // MARK: - WorktreeManager

    func testCreateAndListWorktree() throws {
        let wtPath = try XCTUnwrap(mgr.create(repoPath: repoPath, sessionID: "s1", branch: "feat-1"))
        XCTAssertTrue(FileManager.default.fileExists(atPath: wtPath))

        let list = mgr.list(repoPath: repoPath)
        // Should have main worktree + new one
        XCTAssertEqual(list.count, 2)
        XCTAssertTrue(list.contains(where: { $0.branch == "feat-1" }))
    }

    func testRemoveCleanWorktree() throws {
        let wtPath = try XCTUnwrap(mgr.create(repoPath: repoPath, sessionID: "s2", branch: "feat-2"))
        XCTAssertTrue(FileManager.default.fileExists(atPath: wtPath))

        let removed = mgr.remove(repoPath: repoPath, worktreePath: wtPath)
        XCTAssertTrue(removed)
        XCTAssertFalse(FileManager.default.fileExists(atPath: wtPath))
    }

    func testIsDirtyDetectsUncommittedFile() throws {
        let wtPath = try XCTUnwrap(mgr.create(repoPath: repoPath, sessionID: "s3", branch: "feat-3"))
        XCTAssertFalse(mgr.isDirty(worktreePath: wtPath))

        // Create an untracked file
        FileManager.default.createFile(atPath: wtPath + "/new.txt", contents: "hello".data(using: .utf8))
        XCTAssertTrue(mgr.isDirty(worktreePath: wtPath))
    }

    func testRepoRoot() throws {
        let root = try XCTUnwrap(mgr.repoRoot(for: repoPath))
        // macOS resolves /var → /private/var; compare resolved paths
        let expected = (repoPath as NSString).resolvingSymlinksInPath
        let actual = (root as NSString).resolvingSymlinksInPath
        XCTAssertEqual(actual, expected)
    }

    // MARK: - SessionEditor worktree metadata

    func testSetWorktreeTagsTab() throws {
        var editor = SessionEditor()
        let ws = try XCTUnwrap(editor.snapshot.activeWorkspace)
        let sessionID = try XCTUnwrap(editor.addSession(to: ws.id, cwd: "/tmp", name: "isolated"))

        editor.setWorktree(sessionID: sessionID, worktreePath: "/tmp/wt", parentRepoPath: "/tmp/repo")

        let session = try XCTUnwrap(editor.snapshot.activeWorkspace?.sessions.first(where: { $0.id == sessionID }))
        XCTAssertEqual(session.tabs.first?.worktreePath, "/tmp/wt")
        XCTAssertEqual(session.tabs.first?.parentRepoPath, "/tmp/repo")
    }

    // P32 Phase 2: explicit task worktrees also tag taskName.
    func testSetWorktreeTagsTaskName() throws {
        var editor = SessionEditor()
        let ws = try XCTUnwrap(editor.snapshot.activeWorkspace)
        let sessionID = try XCTUnwrap(editor.addSession(to: ws.id, cwd: "/tmp", name: "fix login bug"))

        editor.setWorktree(sessionID: sessionID, worktreePath: "/tmp/wt", parentRepoPath: "/tmp/repo", taskName: "fix login bug")

        let session = try XCTUnwrap(editor.snapshot.activeWorkspace?.sessions.first(where: { $0.id == sessionID }))
        XCTAssertEqual(session.tabs.first?.worktreePath, "/tmp/wt")
        XCTAssertEqual(session.tabs.first?.taskName, "fix login bug")
    }

    // P32 Phase 2 gap-close: branch-reactive auto-isolate tags an *existing* tab by ID,
    // not just tabs[0] of a freshly-created session.
    func testSetTabWorktreeTagsExistingTabByID() throws {
        var editor = SessionEditor()
        let ws = try XCTUnwrap(editor.snapshot.activeWorkspace)
        let sessionID = try XCTUnwrap(editor.addSession(to: ws.id, cwd: "/tmp", name: nil))
        let tabID = try XCTUnwrap(editor.snapshot.activeWorkspace?.sessions.first(where: { $0.id == sessionID })?.tabs.first?.id)

        let ok = editor.setTabWorktree(tabID, worktreePath: "/tmp/wt-auto", parentRepoPath: "/tmp/repo")
        XCTAssertTrue(ok)

        let session = try XCTUnwrap(editor.snapshot.activeWorkspace?.sessions.first(where: { $0.id == sessionID }))
        XCTAssertEqual(session.tabs.first?.worktreePath, "/tmp/wt-auto")
        XCTAssertEqual(session.tabs.first?.parentRepoPath, "/tmp/repo")
        XCTAssertNil(session.tabs.first?.taskName)

        XCTAssertFalse(editor.setTabWorktree(UUID(), worktreePath: "/tmp/x", parentRepoPath: nil))
    }

    // MARK: - Tab model persistence

    func testTabWorktreeFieldsRoundTrip() throws {
        let tab = Tab(cwd: "/tmp/wt", worktreePath: "/tmp/wt", parentRepoPath: "/tmp/repo")
        let data = try JSONEncoder().encode(tab)
        let decoded = try JSONDecoder().decode(Tab.self, from: data)
        XCTAssertEqual(decoded.worktreePath, "/tmp/wt")
        XCTAssertEqual(decoded.parentRepoPath, "/tmp/repo")
    }

    func testTabWorktreeFieldsNilByDefault() throws {
        let tab = Tab(cwd: "/tmp")
        let data = try JSONEncoder().encode(tab)
        let decoded = try JSONDecoder().decode(Tab.self, from: data)
        XCTAssertNil(decoded.worktreePath)
        XCTAssertNil(decoded.parentRepoPath)
    }

    // MARK: - ProjectConfig

    func testProjectConfigIsolateAgents() throws {
        let json = """
        {"isolateAgents": true, "baseRef": "origin/main", "agent": "claude-code"}
        """.data(using: .utf8)!
        let config = try JSONDecoder().decode(ProjectConfig.self, from: json)
        XCTAssertEqual(config.isolateAgents, true)
        XCTAssertEqual(config.baseRef, "origin/main")
    }

    // MARK: - Multi-session isolation scenario

    func testTwoSessionsDifferentWorktrees() throws {
        let wt1 = try XCTUnwrap(mgr.create(repoPath: repoPath, sessionID: "a1", branch: "feature-a"))
        let wt2 = try XCTUnwrap(mgr.create(repoPath: repoPath, sessionID: "a2", branch: "feature-b"))

        // Both exist independently
        XCTAssertTrue(FileManager.default.fileExists(atPath: wt1))
        XCTAssertTrue(FileManager.default.fileExists(atPath: wt2))

        // They report different branches
        let list = mgr.list(repoPath: repoPath)
        let branches = Set(list.compactMap(\.branch))
        XCTAssertTrue(branches.contains("feature-a"))
        XCTAssertTrue(branches.contains("feature-b"))

        // Cleanup one doesn't affect the other
        mgr.remove(repoPath: repoPath, worktreePath: wt1)
        XCTAssertFalse(FileManager.default.fileExists(atPath: wt1))
        XCTAssertTrue(FileManager.default.fileExists(atPath: wt2))
    }

    // MARK: - Helpers

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
