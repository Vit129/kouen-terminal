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

    func testAncestorExpansionDownHierarchy() async throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let sub1 = tempDir.appendingPathComponent("parent")
        let sub2 = sub1.appendingPathComponent("child")
        let targetFile = sub2.appendingPathComponent("target.txt")
        try FileManager.default.createDirectory(at: sub2, withIntermediateDirectories: true)
        try "hello".write(to: targetFile, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let watcher = FileTreeWatcher()
        let rootRaw = try await watcher.scan(rootPath: tempDir.path)
        let rootNodes = rootRaw.map { FileTreeNode(node: $0) }

        let cleanTarget = targetFile.path
        let cleanRoot = tempDir.path
        let rootPrefix = cleanRoot + "/"
        let relative = String(cleanTarget.dropFirst(rootPrefix.count))
        let components = relative.split(separator: "/").map(String.init)

        var currentNodes = rootNodes
        var accumulated = cleanRoot
        for i in 0..<components.count {
            accumulated = (accumulated as NSString).appendingPathComponent(components[i])
            let isLast = (i == components.count - 1)
            if let node = currentNodes.first(where: { $0.node.path == accumulated }) {
                if !isLast && node.node.isDirectory {
                    node.isExpanded = true
                    let children = try await watcher.expand(node: node.node)
                    node.children = children.map { FileTreeNode(node: $0) }
                    currentNodes = node.children ?? []
                }
            }
        }

        let parentNode = rootNodes.first(where: { $0.node.path == sub1.path })
        XCTAssertNotNil(parentNode)
        XCTAssertTrue(parentNode?.isExpanded == true)

        let childNode = parentNode?.children?.first(where: { $0.node.path == sub2.path })
        XCTAssertNotNil(childNode)
        XCTAssertTrue(childNode?.isExpanded == true)

        let fileNode = childNode?.children?.first(where: { $0.node.path == targetFile.path })
        XCTAssertNotNil(fileNode)
        XCTAssertEqual(fileNode?.node.name, "target.txt")
    }
}
