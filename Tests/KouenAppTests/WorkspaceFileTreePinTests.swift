import XCTest
import KouenCore
@testable import KouenApp

/// A root picked by the user (header menu, cmd+click into another project) must survive the
/// session's cwd-follow, which calls `updateRoot` on every snapshot; a session switch drops it.
@MainActor
final class WorkspaceFileTreePinTests: XCTestCase {
    func testPinnedRootSurvivesCwdFollowAndClearsOnSessionSwitch() {
        let session = SessionID()
        let tree = WorkspaceFileTreeView(rootPath: "/repo/app")
        tree.updateRoot(path: "/repo/app", sessionID: session)

        tree.pin("/repo/notes")
        tree.updateRoot(path: "/repo/app", sessionID: session)
        XCTAssertEqual(tree.shownRoot, "/repo/notes", "cwd-follow must not pull a pinned tree back")

        tree.pin(nil)
        XCTAssertEqual(tree.shownRoot, "/repo/app", "unpinning returns to the session's project")

        tree.pin("/repo/notes")
        tree.updateRoot(path: "/repo/other", sessionID: SessionID())
        XCTAssertFalse(tree.isPinned)
        XCTAssertEqual(tree.shownRoot, "/repo/other", "a new session shows its own project")
    }

    func testRevealFileInTreePinsOutsidePathAndSetsPendingReveal() {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let tree = WorkspaceFileTreeView(rootPath: "/some/default/root")
        tree.revealFileInTree(path: tempDir.path, pinOutside: true)

        XCTAssertTrue(tree.isPinned)
        XCTAssertEqual(tree.shownRoot, tempDir.path)
        XCTAssertEqual(tree.keyboard.state.focusedPath, tempDir.path)
    }

    func testRevealFileInTreeHandlesTrailingSlash() {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let tree = WorkspaceFileTreeView(rootPath: tempDir.path)
        let subfolder = tempDir.appendingPathComponent("subfolder")
        try? FileManager.default.createDirectory(at: subfolder, withIntermediateDirectories: true)

        let pathWithSlash = subfolder.path + "/"
        tree.revealFileInTree(path: pathWithSlash, pinOutside: false)

        XCTAssertEqual(tree.keyboard.state.focusedPath, subfolder.path)
    }

    func testRevealFileInTreePinsToEnclosingGitRepo() {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let subDir = tempDir.appendingPathComponent("nested/folder")
        try? FileManager.default.createDirectory(at: subDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["init", tempDir.path]
        try? process.run()
        process.waitUntilExit()

        let tree = WorkspaceFileTreeView(rootPath: "/some/other/project")
        tree.revealFileInTree(path: subDir.path, pinOutside: true)

        XCTAssertTrue(tree.isPinned)
        let expectedRepo = URL(fileURLWithPath: tempDir.path).resolvingSymlinksInPath().path
        let actualRepo = URL(fileURLWithPath: tree.shownRoot).resolvingSymlinksInPath().path
        XCTAssertEqual(actualRepo, expectedRepo)
    }
}
