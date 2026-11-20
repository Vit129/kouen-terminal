import Foundation
import KouenCore
import XCTest
@testable import KouenApp

@MainActor
final class ProjectAddTests: XCTestCase {
    func testTC0001_FE_IT_BrowseFromGroupKeepsGroupAndAddsWithoutOpeningSession() throws {
        let (root, cleanUp) = try fixture()
        defer { cleanUp() }
        let store = ProjectStore(userDefaultsSuite: UUID().uuidString)
        let group = store.addCategory(name: "Work")
        let other = store.addCategory(name: "Other")
        let scope = ProjectAddScope.group(name: group.name, id: group.id)
        let multiRoot = root.appendingPathComponent("multi")
        for path in ["single", "multi/first", "multi/second"] {
            let marker = root.appendingPathComponent(path).appendingPathComponent(".git")
            try FileManager.default.createDirectory(at: marker, withIntermediateDirectories: true)
        }
        let single = FolderScanner.inspect(path: root.appendingPathComponent("single").path)
        let multiple = FolderScanner.inspect(path: multiRoot.path)

        XCTAssertEqual(scope.groupName, group.name)
        XCTAssertFalse(scope.opensFirstSession)
        XCTAssertFalse(single.isMultiRepo)
        XCTAssertTrue(multiple.isMultiRepo)
        XCTAssertEqual(multiple.items.count, 2)
        for item in single.items + multiple.items {
            let result = store.addProject(item.path, categoryID: scope.categoryForConfirmation(other.id))
            XCTAssertEqual(result?.entry.categoryID, group.id)
        }
    }

    func testTC0002_FE_IT_TopLevelBrowsePreservesCategorySelectionAndRevealsDuplicate() async throws {
        let (root, cleanUp) = try fixture()
        defer { cleanUp() }
        let store = ProjectStore(userDefaultsSuite: UUID().uuidString)
        let sidebar = SidebarListModel()
        sidebar.projectStore = store
        let group = store.addCategory(name: "Selected group")
        let scope = ProjectAddScope.projects
        let checkout = root.appendingPathComponent("first")
        try FileManager.default.createDirectory(at: checkout.appendingPathComponent(".git"), withIntermediateDirectories: true)
        let sheet = AddToWorkspaceSheet(
            folderPath: root.path,
            store: store,
            onConfirm: { _, _ in XCTFail("Cancel must not confirm the import") },
            onCancel: {}
        )

        sheet.onCancel()
        XCTAssertTrue(store.projects.isEmpty)
        XCTAssertTrue(scope.opensFirstSession)
        XCTAssertNil(scope.categoryForConfirmation(nil))
        store.addProject(checkout.path, categoryID: scope.categoryForConfirmation(group.id))

        let path = await sidebar.projectPathForAdd(checkout.path)
        XCTAssertNil(path)
        XCTAssertEqual(sidebar.projectReveal?.path, checkout.path)
        XCTAssertEqual(store.projects.map(\.categoryID), [group.id])
    }

    func testTC0006_FE_IT_ActiveProjectFollowsSessionAndRevealsCollapsedGroup() throws {
        let (root, cleanUp) = try fixture()
        defer { cleanUp() }
        let store = ProjectStore(userDefaultsSuite: UUID().uuidString)
        let sidebar = SidebarListModel()
        sidebar.projectStore = store
        let group = store.addCategory(name: "Projects")
        let paths = try ["alpha", "zulu"].map { name in
            let repo = root.appendingPathComponent(name)
            try FileManager.default.createDirectory(
                at: repo.appendingPathComponent(".git"), withIntermediateDirectories: true
            )
            return try XCTUnwrap(store.addProject(repo.path, categoryID: group.id)).entry.path
        }
        let blank = try XCTUnwrap(URL(string: "about:blank"))
        let alpha = Tab(cwd: paths[0], rootPane: .browser(BrowserLeaf(url: blank)))
        let zulu = Tab(cwd: paths[1] + "/nested", rootPane: .browser(BrowserLeaf(url: blank)))
        let first = SessionGroup(tabs: [alpha], activeTabID: alpha.id)
        let second = SessionGroup(tabs: [zulu], activeTabID: zulu.id)
        var workspace = Workspace(name: "Test", sessions: [first, second], activeSessionID: first.id)
        sidebar.collapsedGroups.insert(group.id)

        sidebar.update(from: SessionSnapshot(workspaces: [workspace], activeWorkspaceID: workspace.id))
        XCTAssertEqual(sidebar.activeProjectPath, paths[0])
        XCTAssertFalse(sidebar.rows.contains { $0.id == "proj-\(paths[0])" })

        workspace.activeSessionID = second.id
        sidebar.update(from: SessionSnapshot(workspaces: [workspace], activeWorkspaceID: workspace.id))
        XCTAssertEqual(sidebar.activeProjectPath, paths[1])
        sidebar.expandActiveProjectGroup()
        XCTAssertTrue(sidebar.rows.contains { $0.id == "proj-\(paths[1])" })

        workspace.activeSessionID = first.id
        sidebar.update(from: SessionSnapshot(workspaces: [workspace], activeWorkspaceID: workspace.id))
        XCTAssertEqual(sidebar.activeProjectPath, paths[0])
    }

    func testTC0007_FE_IT_RefreshLoadsCheckoutAndSelectionKeepsSessionOrder() async throws {
        let (root, cleanUp) = try fixture()
        defer { cleanUp() }
        let checkout = try await ProjectAcquisitionService.acquire(
            .init(mode: .create, input: "Shared", parent: root)
        )
        let store = ProjectStore(userDefaultsSuite: UUID().uuidString)
        let sidebar = SidebarListModel()
        sidebar.projectStore = store
        let path = try XCTUnwrap(store.addProject(checkout.path)).entry.path
        let blank = try XCTUnwrap(URL(string: "about:blank"))
        let sessions = (0..<4).map { _ in
            let tab = Tab(cwd: path, rootPane: .browser(BrowserLeaf(url: blank)))
            return SessionGroup(tabs: [tab], activeTabID: tab.id)
        }
        var workspace = Workspace(name: "Test", sessions: sessions, activeSessionID: sessions[0].id)
        func cards() -> [SidebarSessionCardItem] {
            sidebar.rows.compactMap {
                guard case let .sessionItem(card) = $0 else { return nil }
                return card
            }
        }

        sidebar.update(from: SessionSnapshot(workspaces: [workspace], activeWorkspaceID: workspace.id))
        await sidebar.refreshProjects()
        XCTAssertEqual(cards().first?.isPrimaryCheckout, true)

        workspace.activeSessionID = sessions[2].id
        sidebar.update(from: SessionSnapshot(workspaces: [workspace], activeWorkspaceID: workspace.id))
        XCTAssertEqual(cards().compactMap(\.sessionID), sessions.map(\.id))
        XCTAssertEqual(cards().filter(\.isSelected).compactMap(\.sessionID), [sessions[2].id])
        XCTAssertEqual(cards().first?.isPrimaryCheckout, true)
    }

    func testTC0009_FE_IT_SessionActivityIncludesWorkingPaneOfSameAgentKind() throws {
        let (root, cleanUp) = try fixture()
        defer { cleanUp() }
        let store = ProjectStore(userDefaultsSuite: UUID().uuidString)
        let sidebar = SidebarListModel()
        sidebar.projectStore = store
        let path = try XCTUnwrap(store.addProject(root.path)).entry.path
        let idle = AgentSnapshot(kind: .codex, executable: "codex", pid: 1)
        var otherPane = AgentSnapshot(kind: .codex, executable: "codex", pid: 2, activity: .working)
        var tab = Tab(cwd: path, agent: idle, paneAgents: ["second": otherPane])
        var session = SessionGroup(tabs: [tab], activeTabID: tab.id)
        var workspace = Workspace(name: "Test", sessions: [session], activeSessionID: session.id)

        func displayedActivity() -> TabStatus? {
            sidebar.update(from: SessionSnapshot(workspaces: [workspace], activeWorkspaceID: workspace.id))
            for row in sidebar.rows {
                if case let .sessionItem(card) = row, card.sessionID == session.id {
                    return card.status
                }
            }
            return nil
        }

        XCTAssertEqual(displayedActivity(), .running)
        for (activity, expected): (AgentActivity, TabStatus) in [(.awaiting, .waiting), (.idle, .idle)] {
            otherPane.activity = activity
            tab.paneAgents = ["second": otherPane]
            session.tabs = [tab]
            workspace.sessions = [session]
            XCTAssertEqual(displayedActivity(), expected)
        }

        for status: TabStatus in [.done, .running] {
            tab.status = status
            session.tabs = [tab]
            workspace.sessions = [session]
            XCTAssertEqual(displayedActivity(), status)
        }
    }

    func testTC0003_BE_IT_CloneRegistersOnlyAfterGitSucceeds() async throws {
        let (root, cleanUp) = try fixture()
        defer { cleanUp() }
        let remote = root.appendingPathComponent("fixture.git")
        let request = ProjectAcquisitionService.Request(mode: .clone, input: remote.absoluteString, parent: root)
        let destination = try request.destination()
        let submission = ProjectAddSubmission()
        let failed = await submission.submit(request) { _ in
            XCTFail("Git failed but registration was attempted")
            return true
        }
        XCTAssertFalse(failed)
        XCTAssertTrue(submission.error?.contains(destination.path) == true)
        XCTAssertFalse(FileManager.default.fileExists(atPath: destination.path))

        let fixtureRun = await ProcessRunner.runAsync(
            executable: "git", arguments: ["init", "--bare", "--", remote.path], timeout: 10
        )
        XCTAssertTrue(fixtureRun.isSuccess, fixtureRun.stderr)
        let added = await submission.submit(request) { checkout in
            XCTAssertEqual(checkout, destination)
            XCTAssertTrue(WorkspaceRepositoryScanner.isPrimaryRepository(checkout.path))
            return true
        }
        XCTAssertTrue(added)
        XCTAssertNil(submission.error)
    }

    func testTC0004_BE_IT_CreateInitializesGitAndPreservesExistingDestination() async throws {
        let (root, cleanUp) = try fixture()
        defer { cleanUp() }
        for name in ["", "..", ".git", "parent/child", "a:b"] {
            XCTAssertThrowsError(try ProjectAcquisitionService.Request(mode: .create, input: name, parent: root).destination())
        }
        let collision = root.appendingPathComponent("existing")
        try FileManager.default.createDirectory(at: collision, withIntermediateDirectories: false)
        let marker = collision.appendingPathComponent("keep")
        try Data("original".utf8).write(to: marker)
        do {
            _ = try await ProjectAcquisitionService.acquire(.init(mode: .create, input: "existing", parent: root))
            XCTFail("Existing directory was accepted")
        } catch {
            XCTAssertTrue(error.localizedDescription.contains(collision.path))
        }
        XCTAssertEqual(try String(contentsOf: marker, encoding: .utf8), "original")
        XCTAssertFalse(WorkspaceRepositoryScanner.isPrimaryRepository(collision.path))

        let checkout = try await ProjectAcquisitionService.acquire(.init(mode: .create, input: "New Project", parent: root))
        XCTAssertEqual(checkout.path, root.appendingPathComponent("New Project").path)
        XCTAssertTrue(WorkspaceRepositoryScanner.isPrimaryRepository(checkout.path))
    }

    func testTC0005_FE_IT_RegistrationRetryUsesExistingCheckout() async throws {
        let (root, cleanUp) = try fixture()
        defer { cleanUp() }
        let submission = ProjectAddSubmission()
        let request = ProjectAcquisitionService.Request(mode: .create, input: "retry", parent: root)
        let failed = await submission.submit(request) { _ in false }
        XCTAssertFalse(failed)
        let checkout = try XCTUnwrap(submission.checkout)
        XCTAssertTrue(submission.error?.contains(checkout.path) == true)
        XCTAssertTrue(WorkspaceRepositoryScanner.isPrimaryRepository(checkout.path))

        let store = ProjectStore(userDefaultsSuite: UUID().uuidString)
        let succeeded = await submission.submit(request) { url in
            XCTAssertEqual(url, checkout)
            return store.addProject(url.path) != nil
        }
        XCTAssertTrue(succeeded) // Running Git again would fail on the existing destination.
        XCTAssertEqual(store.projects.map(\.path), [checkout.path])
    }

    func testTC0003_BE_UT_RejectsOptionInjectionAndUnsupportedCloneSchemes() throws {
        let parent = URL(fileURLWithPath: "/tmp", isDirectory: true)
        for input in ["--upload-pack=anything", "ext::anything", "http://example.com/repo", "ssh:///repo"] {
            XCTAssertThrowsError(try ProjectAcquisitionService.Request(mode: .clone, input: input, parent: parent).destination())
        }
        XCTAssertThrowsError(try ProjectAcquisitionService.Request(mode: .create, input: " -test", parent: parent).destination())
        for input in ["https://example.com/repo.git", "ssh://git@example.com/repo.git", "git@example.com:repo.git"] {
            let destination = try ProjectAcquisitionService.Request(mode: .clone, input: input, parent: parent).destination()
            XCTAssertEqual(destination.lastPathComponent, "repo")
        }
    }

    private func fixture() throws -> (URL, () -> Void) {
        let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
            .appendingPathComponent(".tmp/project-add-test-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let defaults = UserDefaults.standard
        let recents = defaults.object(forKey: "RecentProjectPaths")
        return (root, {
            defaults.set(recents, forKey: "RecentProjectPaths")
            try? FileManager.default.removeItem(at: root)
        })
    }
}
