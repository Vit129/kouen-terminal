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
        shell("git branch -m main", in: repoPath)
        shell("git config user.name 'Test Runner'", in: repoPath)
        shell("git config user.email 'test@example.com'", in: repoPath)
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

    // MARK: - Lineage & Divergence (Phase 1)

    func testLineageTrackingAndBaseBranch() throws {
        let wtPath = try XCTUnwrap(mgr.create(repoPath: repoPath, sessionID: "lin-1", branch: "feat-lin", baseRef: "main"))
        XCTAssertTrue(FileManager.default.fileExists(atPath: wtPath))

        // Check base branch resolution
        let base = mgr.baseBranch(for: "feat-lin", in: repoPath)
        XCTAssertEqual(base, "main")

        // Check git config directly
        let configBase = shell("git config --get branch.feat-lin.base", in: repoPath)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertEqual(configBase, "main")

        // Check list includes baseBranch
        let list = mgr.list(repoPath: repoPath)
        let entry = list.first { $0.branch == "feat-lin" }
        XCTAssertEqual(entry?.baseBranch, "main")
    }

    func testDivergenceAheadBehind() throws {
        let wtPath = try XCTUnwrap(mgr.create(repoPath: repoPath, sessionID: "div-1", branch: "feat-div", baseRef: "main"))

        // Add 2 commits in worktree
        shell("git commit --allow-empty -m 'wt commit 1'", in: wtPath)
        shell("git commit --allow-empty -m 'wt commit 2'", in: wtPath)

        // Add 1 commit in main repo
        shell("git commit --allow-empty -m 'main commit 1'", in: repoPath)

        let div = try XCTUnwrap(mgr.divergence(repoPath: repoPath, branch: "feat-div", base: "main"))
        XCTAssertEqual(div.ahead, 2)
        XCTAssertEqual(div.behind, 1)
    }

    /// P46 Pillar 6 gap 5 (Gate 4, Merge Review): `kouen task merge` reads `diffStat` for the
    /// human to review and `currentBranch` to refuse merging onto the wrong checkout.
    func testDiffStatAndCurrentBranch() throws {
        let wtPath = try XCTUnwrap(mgr.create(repoPath: repoPath, sessionID: "diff-1", branch: "feat-diffstat", baseRef: "main"))
        FileManager.default.createFile(atPath: wtPath + "/new.txt", contents: "hello".data(using: .utf8))
        shell("git add new.txt && git commit -m 'add new.txt'", in: wtPath)

        let stat = try XCTUnwrap(mgr.diffStat(repoPath: repoPath, branch: "feat-diffstat", base: "main"))
        XCTAssertTrue(stat.contains("new.txt"), "diffStat must name the changed file: \(stat)")

        XCTAssertEqual(mgr.currentBranch(at: repoPath), "main")
        XCTAssertEqual(mgr.currentBranch(at: wtPath), "feat-diffstat")

        // Nonexistent branch/base must not crash — just report no usable diff.
        XCTAssertNil(mgr.diffStat(repoPath: repoPath, branch: "no-such-branch", base: "main"))
    }

    /// `merge` always uses `--no-ff`, so a fast-forward that could silently move `base`'s ref
    /// without a merge commit never happens — the commit itself is `git log`-verifiable evidence
    /// a merge actually occurred here, not just that the branches converged.
    func testMergeCreatesNoFFCommitAndFailsOnConflict() throws {
        let wtPath = try XCTUnwrap(mgr.create(repoPath: repoPath, sessionID: "merge-1", branch: "feat-merge", baseRef: "main"))
        FileManager.default.createFile(atPath: wtPath + "/merged.txt", contents: "content".data(using: .utf8))
        shell("git add merged.txt && git commit -m 'add merged.txt'", in: wtPath)

        XCTAssertTrue(mgr.merge(repoPath: repoPath, branch: "feat-merge", message: "Merge feat-merge (Gate 4 approved by test)"))
        XCTAssertTrue(FileManager.default.fileExists(atPath: repoPath + "/merged.txt"))
        XCTAssertTrue(mgr.isMergedOrSquashed(repoPath: repoPath, branch: "feat-merge", base: "main"))
        let log = shell("git log -1 --format=%s", in: repoPath)?.trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertEqual(log, "Merge feat-merge (Gate 4 approved by test)", "--no-ff must leave a real merge commit, not fast-forward silently")

        // A genuinely conflicting merge must fail cleanly (and not leave a broken half-merge the
        // caller reports as success).
        FileManager.default.createFile(atPath: repoPath + "/conflict.txt", contents: "main version".data(using: .utf8))
        shell("git add conflict.txt && git commit -m 'main adds conflict.txt'", in: repoPath)
        let conflictWt = try XCTUnwrap(mgr.create(repoPath: repoPath, sessionID: "merge-2", branch: "feat-conflict", baseRef: "main~1"))
        FileManager.default.createFile(atPath: conflictWt + "/conflict.txt", contents: "conflicting version".data(using: .utf8))
        shell("git add conflict.txt && git commit -m 'feat-conflict adds conflict.txt'", in: conflictWt)

        XCTAssertFalse(mgr.merge(repoPath: repoPath, branch: "feat-conflict", message: "should fail"))
        shell("git merge --abort", in: repoPath) // leave the repo clean for teardown
    }

    func testIsMergedOrSquashedNormalMerge() throws {
        let wtPath = try XCTUnwrap(mgr.create(repoPath: repoPath, sessionID: "norm-1", branch: "feat-norm", baseRef: "main"))
        let filePath = wtPath + "/norm.txt"
        FileManager.default.createFile(atPath: filePath, contents: "norm content".data(using: .utf8))
        shell("git add norm.txt && git commit -m 'norm commit'", in: wtPath)

        // Before merge: not merged
        XCTAssertFalse(mgr.isMergedOrSquashed(repoPath: repoPath, branch: "feat-norm", base: "main"))

        // Merge into main
        shell("git merge --no-ff feat-norm -m 'merge feat-norm'", in: repoPath)

        // After merge: merged
        XCTAssertTrue(mgr.isMergedOrSquashed(repoPath: repoPath, branch: "feat-norm", base: "main"))
    }

    func testIsMergedOrSquashedSquashMerge() throws {
        let wtPath = try XCTUnwrap(mgr.create(repoPath: repoPath, sessionID: "sq-1", branch: "feat-sq", baseRef: "main"))
        let filePath = wtPath + "/feature.txt"
        FileManager.default.createFile(atPath: filePath, contents: "feature content".data(using: .utf8))
        shell("git add feature.txt && git commit -m 'add feature'", in: wtPath)

        // Before squash: not merged
        XCTAssertFalse(mgr.isMergedOrSquashed(repoPath: repoPath, branch: "feat-sq", base: "main"))

        // Squash merge into main (does not create an ancestor relationship!)
        shell("git merge --squash feat-sq && git commit -m 'squashed feat-sq'", in: repoPath)

        // squash-merge check via merge-tree should detect tree equality
        XCTAssertTrue(mgr.isMergedOrSquashed(repoPath: repoPath, branch: "feat-sq", base: "main"))

        // An unmerged branch with different content should still be false
        let unmergedPath = try XCTUnwrap(mgr.create(repoPath: repoPath, sessionID: "sq-2", branch: "feat-unmerged", baseRef: "main"))
        let diffFile = unmergedPath + "/diff.txt"
        FileManager.default.createFile(atPath: diffFile, contents: "different content".data(using: .utf8))
        shell("git add diff.txt && git commit -m 'different'", in: unmergedPath)

        XCTAssertFalse(mgr.isMergedOrSquashed(repoPath: repoPath, branch: "feat-unmerged", base: "main"))
    }

    func testRemoveGuardsSafety() throws {
        // Attempting to remove home directory or root or arbitrary dir must fail
        XCTAssertFalse(mgr.remove(repoPath: repoPath, worktreePath: NSHomeDirectory()))
        XCTAssertFalse(mgr.remove(repoPath: repoPath, worktreePath: "/"))
        XCTAssertFalse(mgr.remove(repoPath: repoPath, worktreePath: "/tmp/not-a-worktree"))
    }

    func testRemoveDirtyWorktreeGuards() throws {
        let wtPath = try XCTUnwrap(mgr.create(repoPath: repoPath, sessionID: "dirty-1", branch: "feat-dirty"))
        FileManager.default.createFile(atPath: wtPath + "/dirty.txt", contents: "uncommitted".data(using: .utf8))

        // Without force: refuses to remove
        XCTAssertFalse(mgr.remove(repoPath: repoPath, worktreePath: wtPath, force: false))
        XCTAssertTrue(FileManager.default.fileExists(atPath: wtPath))

        // With force: successfully removes
        XCTAssertTrue(mgr.remove(repoPath: repoPath, worktreePath: wtPath, force: true))
        XCTAssertFalse(FileManager.default.fileExists(atPath: wtPath))
    }

    func testScanGenerationIncrements() throws {
        let gen0 = WorktreeManager.scanGeneration
        let wtPath = try XCTUnwrap(mgr.create(repoPath: repoPath, sessionID: "gen-1", branch: "feat-gen"))
        XCTAssertEqual(WorktreeManager.scanGeneration, gen0 + 1)

        mgr.remove(repoPath: repoPath, worktreePath: wtPath)
        XCTAssertEqual(WorktreeManager.scanGeneration, gen0 + 2)

        mgr.prune(repoPath: repoPath)
        XCTAssertEqual(WorktreeManager.scanGeneration, gen0 + 3)
    }

    // MARK: - Primary Tree Branch Guard (P47)
    //
    // `WorktreeAutoIsolateService.isolate()` performs this exact sequence (checkout default in
    // the primary tree, then a REAL — never --detach — branch checkout in the worktree) when a
    // tab's branch reactively changes. These tests exercise the same `WorktreeManager` calls the
    // service makes, proving the mechanism the fix relies on: a real branch checkout that can
    // never freeze/diverge like the `--detach` snapshot it replaces (see
    // agent-memory/plans/p47-primary-branch-worktree-fix/).

    func testPrimaryTreeChecksOutRealBranchNotDetached() throws {
        // Simulate a tab whose primary tree already switched to a feature branch.
        shell("git checkout -b feat-p47", in: repoPath)
        XCTAssertEqual(shell("git branch --show-current", in: repoPath)?.trimmingCharacters(in: .whitespacesAndNewlines), "feat-p47")

        // isolate()'s sequence: free the branch name in the primary tree first...
        let defaultBranch = try XCTUnwrap(mgr.defaultBaseBranch(repoPath: repoPath))
        XCTAssertEqual(defaultBranch, "main")
        shell("git checkout \(defaultBranch)", in: repoPath)

        // ...then check the branch out for real (not detached) in the worktree. `checkoutExisting:
        // true` because the branch already exists — it's the branch the tab was just on.
        let wtPath = try XCTUnwrap(mgr.create(repoPath: repoPath, sessionID: "feat-p47", branch: "feat-p47", baseRef: defaultBranch, checkoutExisting: true))

        // Primary tree is back on the default branch, never left parked on the feature branch.
        XCTAssertEqual(shell("git branch --show-current", in: repoPath)?.trimmingCharacters(in: .whitespacesAndNewlines), "main")

        // Worktree is a real branch checkout, not a detached HEAD snapshot.
        XCTAssertTrue(FileManager.default.fileExists(atPath: wtPath))
        let list = mgr.list(repoPath: repoPath)
        XCTAssertTrue(list.contains { $0.branch == "feat-p47" })
        let gitList = shell("git worktree list", in: repoPath) ?? ""
        XCTAssertFalse(gitList.contains("detached"), "worktree must be a real branch checkout, never detached: \(gitList)")

        // Lineage is recorded (only happens for a real branch checkout, never for `branch: nil`).
        XCTAssertEqual(mgr.baseBranch(for: "feat-p47", in: repoPath), "main")
    }

    func testDirtyPrimaryTreeIsNotCheckedOutFromUnderneath() throws {
        // Simulate the exact incident: primary tree on a feature branch WITH an uncommitted edit.
        shell("git checkout -b feat-p47-dirty", in: repoPath)
        try "uncommitted".write(toFile: repoPath + "/dirty.txt", atomically: true, encoding: .utf8)

        // `isolate()`'s dirty guard: `WorktreeManager.isDirty` must refuse before any checkout runs.
        XCTAssertTrue(mgr.isDirty(worktreePath: repoPath))

        // The primary tree must be left completely untouched — still on the feature branch, edit
        // still there — never silently carried onto the default branch (which is strictly worse
        // than the original bug, since the fresh worktree wouldn't have it either).
        XCTAssertEqual(shell("git branch --show-current", in: repoPath)?.trimmingCharacters(in: .whitespacesAndNewlines), "feat-p47-dirty")
        XCTAssertTrue(FileManager.default.fileExists(atPath: repoPath + "/dirty.txt"))
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
