import XCTest
@testable import KouenApp

/// Regression guard for the FSEvent noise filter fixed in this session: it must
/// keep ignoring the panel's own auto-stage writes (.git/index) but must NOT
/// swallow the ref/log changes an external `git commit`/`push` produces —
/// f6ffb0a's blanket `.git/` filter broke exactly that.
final class GitPanelViewFSEventFilterTests: XCTestCase {
    func testAutoStageWritesAreFilteredAsNoise() {
        XCTAssertTrue(GitPanelView.isNoisyGitInternalPath("/repo/.git/index"))
        XCTAssertTrue(GitPanelView.isNoisyGitInternalPath("/repo/.git/index.lock"))
        XCTAssertTrue(GitPanelView.isNoisyGitInternalPath("/repo/.git/objects/ab/cdef1234"))
    }

    func testExternalCommitAndPushPathsAreNotFiltered() {
        XCTAssertFalse(GitPanelView.isNoisyGitInternalPath("/repo/.git/HEAD"))
        XCTAssertFalse(GitPanelView.isNoisyGitInternalPath("/repo/.git/refs/heads/main"))
        XCTAssertFalse(GitPanelView.isNoisyGitInternalPath("/repo/.git/refs/remotes/origin/main"))
        XCTAssertFalse(GitPanelView.isNoisyGitInternalPath("/repo/.git/logs/HEAD"))
        XCTAssertFalse(GitPanelView.isNoisyGitInternalPath("/repo/.git/COMMIT_EDITMSG"))
        XCTAssertFalse(GitPanelView.isNoisyGitInternalPath("/repo/.git/FETCH_HEAD"))
    }

    func testWorkingTreeChangesAreNotFiltered() {
        XCTAssertFalse(GitPanelView.isNoisyGitInternalPath("/repo/README.md"))
    }
}
