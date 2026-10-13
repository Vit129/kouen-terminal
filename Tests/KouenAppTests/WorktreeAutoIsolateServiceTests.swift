import Foundation
import XCTest
@testable import KouenApp
import KouenCore

/// Branch changes are observed, never acted on: the decision is pure, so it must not move the
/// shared folder's HEAD, create a worktree, or depend on anything but the tab list.
final class WorktreeAutoIsolateServiceTests: XCTestCase {
    private func tab(cwd: String, branch: String?, worktreePath: String? = nil) -> Tab {
        Tab(
            id: UUID(), title: "t", cwd: cwd, gitBranch: branch, status: .idle,
            rootPane: .leaf(PaneLeaf(surfaceID: SurfaceID())),
            worktreePath: worktreePath
        )
    }

    private func notice(_ tab: Tab, among tabs: [Tab]) -> WorktreeIsolationNotice? {
        WorktreeAutoIsolateService.notice(for: tab, among: tabs, projectRoot: { $0 })
    }

    func testFeatureBranchSharingFolderProducesNotice() {
        let a = tab(cwd: "/repo", branch: "feat/x")
        let b = tab(cwd: "/repo", branch: "feat/x")
        let result = notice(a, among: [a, b])
        XCTAssertEqual(result, WorktreeIsolationNotice(tabID: a.id, branch: "feat/x", sharingTabCount: 1))
        XCTAssertEqual(result?.message, "This tab is on `feat/x` and shares the folder with 1 other tab")
    }

    func testMessagePluralizesOtherTabs() {
        let a = tab(cwd: "/repo", branch: "feat/x")
        let others = [tab(cwd: "/repo", branch: "feat/x"), tab(cwd: "/repo", branch: "feat/x")]
        XCTAssertEqual(
            notice(a, among: [a] + others)?.message,
            "This tab is on `feat/x` and shares the folder with 2 other tabs"
        )
    }

    func testNoNoticeWhenTabIsAlone() {
        let a = tab(cwd: "/repo", branch: "feat/x")
        XCTAssertNil(notice(a, among: [a]))
    }

    func testNoNoticeOnProtectedOrMissingBranch() {
        let main = tab(cwd: "/repo", branch: "main")
        let detached = tab(cwd: "/repo", branch: nil)
        let other = tab(cwd: "/repo", branch: "main")
        XCTAssertNil(notice(main, among: [main, other]))
        XCTAssertNil(notice(detached, among: [detached, other]))
    }

    func testNoNoticeForAlreadyIsolatedTabAndItsWorktreeIsNotCountedAsSharing() {
        let isolated = tab(cwd: "/repo/.kouen-worktrees/x", branch: "feat/x", worktreePath: "/repo/.kouen-worktrees/x")
        let a = tab(cwd: "/repo", branch: "feat/y")
        XCTAssertNil(notice(isolated, among: [isolated, a]))
        XCTAssertNil(notice(a, among: [a, isolated]), "an isolated tab does not share a's folder")
    }

    func testTabsInOtherProjectsDoNotCount() {
        let a = tab(cwd: "/repo", branch: "feat/x")
        let b = tab(cwd: "/elsewhere", branch: "feat/x")
        XCTAssertNil(notice(a, among: [a, b]))
    }

    func testSubdirectoryTabsShareTheProjectFolder() {
        let a = tab(cwd: "/repo", branch: "feat/x")
        let b = tab(cwd: "/repo/src", branch: "feat/x")
        let root: (String) -> String = { $0.hasPrefix("/repo") ? "/repo" : $0 }
        XCTAssertEqual(
            WorktreeAutoIsolateService.notice(for: a, among: [a, b], projectRoot: root)?.sharingTabCount, 1
        )
    }

    /// A branch change must leave git alone: HEAD stays, no worktree dir appears.
    func testDecisionDoesNotMutateGit() throws {
        let repo = FileManager.default.temporaryDirectory
            .appendingPathComponent("kouen-ask-first-\(UUID().uuidString)").path
        try FileManager.default.createDirectory(atPath: repo, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(atPath: repo) }
        func git(_ args: String...) -> String {
            let p = Process()
            let pipe = Pipe()
            p.executableURL = URL(fileURLWithPath: "/usr/bin/git")
            p.arguments = ["-c", "user.name=t", "-c", "user.email=t@t"] + args
            p.currentDirectoryURL = URL(fileURLWithPath: repo)
            p.standardOutput = pipe
            try? p.run()
            let out = pipe.fileHandleForReading.readDataToEndOfFile()
            p.waitUntilExit()
            return String(data: out, encoding: .utf8) ?? ""
        }
        _ = git("init", "-b", "main")
        _ = git("commit", "--allow-empty", "-m", "init")
        _ = git("checkout", "-b", "feat/x")
        let before = git("rev-parse", "--abbrev-ref", "HEAD")

        let a = tab(cwd: repo, branch: "feat/x")
        let b = tab(cwd: repo, branch: "feat/x")
        XCTAssertNotNil(notice(a, among: [a, b]))

        XCTAssertEqual(git("rev-parse", "--abbrev-ref", "HEAD"), before, "shared folder must stay on the tab's branch")
        XCTAssertFalse(FileManager.default.fileExists(atPath: repo + "/.kouen-worktrees"))
    }
}
