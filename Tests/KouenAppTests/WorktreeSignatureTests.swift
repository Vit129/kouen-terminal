import XCTest
import KouenIPC
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
    func testTC6920_FE_BL_StoredSubfolderIsHiddenAndSessionGroupsUnderListedRepo() async throws {
        try await verifyStoredSubfolders(listedRoot: true)
    }

    @MainActor
    func testTC6921_FE_BL_StoredSubfoldersOfUnlistedRepoShowOneRootWithWorktrees() async throws {
        try await verifyStoredSubfolders(listedRoot: false)
    }

    @MainActor
    func testTC6922_FE_BL_AddingSubfolderRevealsRepoInItsCollapsedCategory() async throws {
        let repo = FileManager.default.temporaryDirectory.resolvingSymlinksInPath()
            .appendingPathComponent(UUID().uuidString)
        let subdirectory = repo.appendingPathComponent(".claude")
        defer { try? FileManager.default.removeItem(at: repo) }
        try FileManager.default.createDirectory(at: subdirectory, withIntermediateDirectories: true)
        try git(["init", "-q"], in: repo)

        let suite = UUID().uuidString
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = ProjectStore(userDefaults: defaults)
        let category = store.addCategory(name: "Repo")
        let model = SidebarListModel()
        model.projectStore = store

        let pathToAdd = await model.projectPathForAdd(subdirectory.path)
        XCTAssertEqual(pathToAdd, repo.path)
        let root = try XCTUnwrap(pathToAdd)
        store.projects = [ProjectEntry(path: root, categoryID: category.id)]
        model.toggleCollapse(id: category.id)
        XCTAssertFalse(model.rows.contains { $0.id == "proj-\(repo.path)" })

        let duplicate = await model.projectPathForAdd(subdirectory.path + "/")
        XCTAssertNil(duplicate)
        XCTAssertEqual(model.projectReveal?.path, repo.path)
        XCTAssertFalse(model.collapsedGroups.contains(category.id))
        XCTAssertTrue(model.rows.contains { $0.id == "proj-\(repo.path)" })
        XCTAssertEqual(store.projects.map(\.path), [repo.path])
    }

    @MainActor
    private func verifyStoredSubfolders(listedRoot: Bool) async throws {
        let repo = FileManager.default.temporaryDirectory.resolvingSymlinksInPath()
            .appendingPathComponent(UUID().uuidString)
        let subdirectory = repo.appendingPathComponent(".claude")
        let other = repo.appendingPathComponent("docs")
        defer { try? FileManager.default.removeItem(at: repo) }
        for folder in [subdirectory, other] {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        try git(["init", "-q", "-b", "trunk"], in: repo)
        try git(["commit", "-q", "--allow-empty", "-m", "initial"], in: repo)
        let worktree = repo.appendingPathComponent("checkout")
        try git(["worktree", "add", "-q", "-b", "feature", worktree.path], in: repo)

        let suite = UUID().uuidString
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = ProjectStore(userDefaults: defaults)
        let rootCategory = store.addCategory(name: "Repo")
        let nestedCategory = store.addCategory(name: "Folders")
        let nested = [subdirectory, other].map { ProjectEntry(path: $0.path, categoryID: nestedCategory.id) }
        let stored = nested + (listedRoot ? [ProjectEntry(path: repo.path, categoryID: rootCategory.id)] : [])
        store.projects = stored
        store.save()

        let model = SidebarListModel()
        model.projectStore = store
        let session = SessionGroup(tabs: [Tab(cwd: subdirectory.path, gitBranch: "trunk")])
        if listedRoot {
            model.update(from: SessionSnapshot(workspaces: [Workspace(sessions: [session])]))
        }
        model.updateWorktrees()

        let ready = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in
            MainActor.assumeIsolated {
                let headers = model.rows.filter { row in
                    if case .projectHeader = row { return true }
                    return false
                }
                return headers.map(\.id) == ["proj-\(repo.path)"]
                    && model.rows.contains { $0.id == "worktrees-\(repo.path)" }
            }
        }, object: nil)
        await fulfillment(of: [ready], timeout: 10)

        let headers = model.rows.compactMap { row -> SidebarProjectHeaderItem? in
            guard case .projectHeader(let item) = row else { return nil }
            return item
        }
        let header = try XCTUnwrap(headers.first)
        XCTAssertEqual(headers.count, 1)
        XCTAssertEqual(header.name, repo.lastPathComponent)
        XCTAssertEqual(header.categoryID, listedRoot ? rootCategory.id : nestedCategory.id)
        XCTAssertEqual(header.sessionsCount, listedRoot ? 1 : 0)
        let primary = model.rows.compactMap { row -> SidebarSessionCardItem? in
            guard case .sessionItem(let item) = row, item.isPrimaryCheckout else { return nil }
            return item
        }
        XCTAssertEqual(primary.map(\.title), ["trunk"])
        XCTAssertEqual(primary.map(\.projectPath), [repo.path])
        if listedRoot {
            XCTAssertTrue(model.rows.contains { $0.id == "sess-\(session.id.uuidString)" })
        }
        XCTAssertEqual(store.projects, stored)
        XCTAssertEqual(ProjectStore(userDefaults: defaults).projects, stored)
    }

    @MainActor
    func testDiscoveredWorktreesCollapseAndMissingCheckoutDisappears_TC0001_FE_IT() async throws {
        let temporaryPath = try XCTUnwrap(realpath(FileManager.default.temporaryDirectory.path, nil))
        defer { free(temporaryPath) }
        let repo = URL(fileURLWithPath: String(cString: temporaryPath)).appendingPathComponent(UUID().uuidString)
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

    @MainActor
    func testTC6918_FE_BL_SidebarListModelShowsPrimaryCheckoutWithAnActiveLinkedSession() async throws {
        let temporaryPath = try XCTUnwrap(realpath(FileManager.default.temporaryDirectory.path, nil))
        defer { free(temporaryPath) }
        let repo = URL(fileURLWithPath: String(cString: temporaryPath)).appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: repo) }
        try FileManager.default.createDirectory(at: repo, withIntermediateDirectories: true)
        try git(["init", "-q", "-b", "trunk"], in: repo)
        try git(["commit", "-q", "--allow-empty", "-m", "initial"], in: repo)
        let linked = repo.appendingPathComponent("checkout")
        try git(["worktree", "add", "-q", "-b", "feature", linked.path], in: repo)

        let suite = UUID().uuidString
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = ProjectStore(userDefaults: defaults)
        store.projects = [ProjectEntry(path: repo.path, categoryID: nil)]
        let model = SidebarListModel()
        model.projectStore = store
        let linkedSession = SessionGroup(tabs: [Tab(cwd: linked.path, gitBranch: "feature",
            worktreePath: linked.path, parentRepoPath: repo.path)])
        model.update(from: SessionSnapshot(workspaces: [Workspace(sessions: [linkedSession])]))
        model.updateWorktrees()

        let ready = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in
            MainActor.assumeIsolated {
                model.rows.contains { row in
                    guard case .sessionItem(let card) = row else { return false }
                    return card.isPrimaryCheckout && card.title == "trunk" && card.lastActivityAt != nil
                }
            }
        }, object: nil)
        await fulfillment(of: [ready], timeout: 10)
        XCTAssertEqual(Array(model.rows.prefix(3).map(\.id)),
            ["proj-\(repo.path)", "sess-idle-\(repo.path)", "sess-\(linkedSession.id.uuidString)"])

        let primarySession = SessionGroup(tabs: [Tab(cwd: repo.path, gitBranch: "trunk", taskName: "Task title")])
        model.update(from: SessionSnapshot(workspaces: [Workspace(sessions: [linkedSession, primarySession])]))
        guard let row = model.rows.dropFirst().first, case .sessionItem(let primary) = row else {
            return XCTFail("Expected the primary checkout immediately below the repository header")
        }
        XCTAssertEqual(primary.title, "trunk")
        XCTAssertEqual(primary.sessionID, primarySession.id)
        XCTAssertTrue(primary.isPrimaryCheckout)
        XCTAssertTrue(primary.isRunning)

        model.toggleProjectCollapse(path: repo.path)
        XCTAssertEqual(model.rows.map(\.id), ["proj-\(repo.path)"])
        model.toggleProjectCollapse(path: repo.path)
        XCTAssertEqual(model.rows.dropFirst().first?.id, "sess-\(primarySession.id.uuidString)")
    }

}
