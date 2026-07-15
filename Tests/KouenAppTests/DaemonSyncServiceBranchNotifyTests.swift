import XCTest
import KouenCore
@testable import KouenApp

/// A background tab (an agent session not currently in view) that switches git branch used to
/// never get worktree-isolated: `startMetadataRefresh()` only posted
/// `KouenActiveTabGitBranchDidChange` when the changed tab was also the focused tab, so
/// `WorktreeAutoIsolateService` never saw the change and the tab's cwd stayed pinned at the repo
/// root forever — split panes, git panel, file panel, and the tab pill all kept showing `main`.
final class DaemonSyncServiceBranchNotifyTests: XCTestCase {
    func testAllChangedTabsAreReportedNotJustOne() {
        let wsID = WorkspaceID()
        let focusedTabID = TabID()
        let backgroundTabID = TabID()

        let ids = DaemonSyncService.tabIDsToNotify(forChanges: [
            (wsID, focusedTabID, "main"),
            (wsID, backgroundTabID, "feature-x"),
        ])

        XCTAssertTrue(ids.contains(focusedTabID))
        XCTAssertTrue(ids.contains(backgroundTabID), "background tab's branch change must still be reported")
        XCTAssertEqual(ids.count, 2)
    }

    func testNoChangesReportsEmpty() {
        XCTAssertTrue(DaemonSyncService.tabIDsToNotify(forChanges: []).isEmpty)
    }
}
