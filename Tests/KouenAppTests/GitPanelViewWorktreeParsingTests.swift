import XCTest
import KouenCore
@testable import KouenApp

/// `parseWorktreePorcelain`/`repoCandidates` were extracted out of `refreshWorktrees`/
/// `refreshRepos` so the cross-repo Agents review dashboard (P38 Phase A) can reuse the same
/// parsing logic instead of duplicating it. This covers the extracted parsers directly.
final class GitPanelViewWorktreeParsingTests: XCTestCase {

    // MARK: - parseWorktreePorcelain

    func testMainLinkedDetachedAndLockedEntries() {
        let porcelain = """
        worktree /repo/main
        HEAD abc123
        branch refs/heads/main

        worktree /repo/.kouen-worktrees/feature
        HEAD def456
        branch refs/heads/feature

        worktree /repo/.kouen-worktrees/detached
        HEAD ghi789
        detached

        worktree /repo/.kouen-worktrees/locked-one
        HEAD jkl012
        branch refs/heads/locked-branch
        locked
        """
        let entries = GitPanelView.parseWorktreePorcelain(porcelain, mergedBranchOutput: "")
        XCTAssertEqual(entries.count, 4)

        XCTAssertEqual(entries[0].path, "/repo/main")
        XCTAssertEqual(entries[0].branch, "main")
        XCTAssertTrue(entries[0].isMain)
        XCTAssertFalse(entries[0].isLocked)

        XCTAssertEqual(entries[1].path, "/repo/.kouen-worktrees/feature")
        XCTAssertEqual(entries[1].branch, "feature")
        XCTAssertFalse(entries[1].isMain)

        XCTAssertEqual(entries[2].branch, "detached")

        XCTAssertEqual(entries[3].branch, "locked-branch")
        XCTAssertTrue(entries[3].isLocked)
    }

    func testMergedBranchOutputMarksMatchingEntriesMerged() {
        let porcelain = """
        worktree /repo/main
        HEAD abc123
        branch refs/heads/main

        worktree /repo/.kouen-worktrees/done
        HEAD def456
        branch refs/heads/done-feature

        worktree /repo/.kouen-worktrees/pending
        HEAD ghi789
        branch refs/heads/pending-feature
        """
        let entries = GitPanelView.parseWorktreePorcelain(porcelain, mergedBranchOutput: "done-feature\n")
        XCTAssertEqual(entries.count, 3)
        XCTAssertFalse(entries[0].isMerged)
        XCTAssertTrue(entries[1].isMerged)
        XCTAssertFalse(entries[2].isMerged)
    }

    func testEmptyOutputReturnsNoEntries() {
        XCTAssertTrue(GitPanelView.parseWorktreePorcelain("", mergedBranchOutput: "").isEmpty)
    }

    // MARK: - repoCandidates

    func testDedupesByParentRepoPathOverCwd() {
        let tabs: [(cwd: String, parentRepoPath: String?, gitBranch: String?, sessionName: String)] = [
            (cwd: "/repo/.kouen-worktrees/feature-a", parentRepoPath: "/repo", gitBranch: "feature-a", sessionName: "S1"),
            (cwd: "/repo/.kouen-worktrees/feature-b", parentRepoPath: "/repo", gitBranch: "feature-b", sessionName: "S2"),
        ]
        let candidates = GitPanelView.repoCandidates(tabs: tabs)
        XCTAssertEqual(candidates.count, 1, "two worktrees of the same repo must collapse to one repo candidate")
        XCTAssertEqual(candidates[0].path, "/repo")
    }

    func testFallsBackToCwdWhenNoParentRepoPath() {
        let tabs: [(cwd: String, parentRepoPath: String?, gitBranch: String?, sessionName: String)] = [
            (cwd: "/repo/other", parentRepoPath: nil, gitBranch: "main", sessionName: "S1"),
        ]
        let candidates = GitPanelView.repoCandidates(tabs: tabs)
        XCTAssertEqual(candidates.count, 1)
        XCTAssertEqual(candidates[0].path, "/repo/other")
    }

    func testEmptyCwdIsSkipped() {
        let tabs: [(cwd: String, parentRepoPath: String?, gitBranch: String?, sessionName: String)] = [
            (cwd: "", parentRepoPath: nil, gitBranch: nil, sessionName: "S1"),
        ]
        XCTAssertTrue(GitPanelView.repoCandidates(tabs: tabs).isEmpty)
    }

    // MARK: - parseShortstatFileCount

    func testParsesMultiFileShortstat() {
        XCTAssertEqual(GitPanelView.parseShortstatFileCount(" 3 files changed, 12 insertions(+), 4 deletions(-)"), 3)
    }

    func testParsesSingleFileShortstatSingular() {
        XCTAssertEqual(GitPanelView.parseShortstatFileCount(" 1 file changed, 2 insertions(+)"), 1)
    }

    func testEmptyShortstatIsZeroFiles() {
        XCTAssertEqual(GitPanelView.parseShortstatFileCount(""), 0)
    }

    func testUnrelatedOutputIsZeroFiles() {
        XCTAssertEqual(GitPanelView.parseShortstatFileCount("fatal: bad revision 'main...HEAD'"), 0)
    }
}
