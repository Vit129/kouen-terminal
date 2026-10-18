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
}
