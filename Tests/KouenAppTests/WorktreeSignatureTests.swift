import XCTest
@testable import KouenApp

/// The sidebar skips `git worktree list` while this signature is unchanged, so it must move on
/// everything that changes the porcelain output (commit, new worktree) and stay put otherwise.
final class WorktreeSignatureTests: XCTestCase {
    private func git(_ args: [String], in dir: URL) throws {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        p.arguments = ["-c", "user.name=t", "-c", "user.email=t@t", "-c", "commit.gpgsign=false"] + args
        p.currentDirectoryURL = dir
        p.standardOutput = FileHandle.nullDevice
        p.standardError = FileHandle.nullDevice
        try p.run()
        p.waitUntilExit()
        XCTAssertEqual(p.terminationStatus, 0, "git \(args)")
    }

    func testSignatureMovesOnCommitAndNewWorktreeOnly() throws {
        let repo = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: repo) }
        try FileManager.default.createDirectory(at: repo, withIntermediateDirectories: true)
        try git(["init", "-q"], in: repo)
        try git(["commit", "-q", "--allow-empty", "-m", "one"], in: repo)

        let first = SidebarListModel.worktreeSignature(rootPath: repo.path)
        XCTAssertNotNil(first)
        XCTAssertEqual(SidebarListModel.worktreeSignature(rootPath: repo.path), first, "nothing changed")

        Thread.sleep(forTimeInterval: 1.1) // mtime granularity
        try git(["commit", "-q", "--allow-empty", "-m", "two"], in: repo)
        let afterCommit = SidebarListModel.worktreeSignature(rootPath: repo.path)
        XCTAssertNotEqual(afterCommit, first, "a commit moves HEAD")

        try git(["worktree", "add", "-q", repo.appendingPathComponent("wt").path, "-b", "x"], in: repo)
        XCTAssertNotEqual(SidebarListModel.worktreeSignature(rootPath: repo.path), afterCommit, "a new worktree")

        XCTAssertNil(SidebarListModel.worktreeSignature(rootPath: repo.appendingPathComponent("wt").path),
                     "a linked worktree has a .git file, so callers fall back to the timer")
    }

    @MainActor
    func testDiscoveredWorktreesCollapseAndMissingCheckoutDisappears_TC0001_FE_IT() async throws {
        let repo = FileManager.default.temporaryDirectory.resolvingSymlinksInPath()
            .appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: repo) }
        try FileManager.default.createDirectory(at: repo, withIntermediateDirectories: true)
        try git(["init", "-q"], in: repo)
        try git(["commit", "-q", "--allow-empty", "-m", "initial"], in: repo)
        let worktree = repo.appendingPathComponent("checkout")
        try git(["worktree", "add", "-q", "--detach", worktree.path], in: repo)

        let suite = UUID().uuidString
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = ProjectStore(userDefaults: defaults)
        store.projects = [ProjectEntry(path: repo.path, categoryID: nil)]
        let model = SidebarListModel()
        model.projectStore = store

        let disclosureID = "worktrees-\(repo.path)"
        model.updateWorktrees()
        let discovered = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in
            MainActor.assumeIsolated { model.rows.contains { $0.id == disclosureID } }
        }, object: nil)
        await fulfillment(of: [discovered], timeout: 10)
        let checkout = try XCTUnwrap(model.projectWorktrees[repo.path]?.first { !$0.isMain })
        XCTAssertEqual((checkout.path as NSString).lastPathComponent, "checkout")
        let checkoutID = "sess-wt-\(checkout.path)"
        XCTAssertTrue(model.rows.contains { $0.id == "sess-idle-\(repo.path)" })
        XCTAssertFalse(model.rows.contains { $0.id == checkoutID })

        model.toggleWorktreeCollapse(rootPath: repo.path)
        XCTAssertTrue(model.rows.contains { $0.id == checkoutID })

        let signature = SidebarListModel.worktreeSignature(rootPath: repo.path)
        try FileManager.default.removeItem(at: worktree)
        XCTAssertEqual(SidebarListModel.worktreeSignature(rootPath: repo.path), signature)
        await model.refreshProjects()

        let removed = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in
            MainActor.assumeIsolated { !model.rows.contains { $0.id == disclosureID || $0.id == checkoutID } }
        }, object: nil)
        await fulfillment(of: [removed], timeout: 10)
        XCTAssertTrue(model.rows.contains { $0.id == "sess-idle-\(repo.path)" })
    }

}
