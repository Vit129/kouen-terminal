import Foundation
import KouenGit
import XCTest

final class GitParsersTests: XCTestCase {
    // MARK: - [BE-UT] Worktree Porcelain Parser
    func testParseWorktreeListPorcelain() {
        let sample = """
        worktree /Users/dev/repo
        HEAD a1b2c3d4e5f6
        branch refs/heads/main

        worktree /Users/dev/repo/.worktrees/feature-x
        HEAD 9876543210ab
        branch refs/heads/feat/awesome-thing

        worktree /Users/dev/repo/.worktrees/detached-node
        HEAD 112233445566
        detached

        worktree /Users/dev/repo/.worktrees/locked-node
        HEAD deadbeef1234
        branch refs/heads/fix/locked-task
        locked reason for locking

        worktree /Users/dev/bare-repo
        bare
        """

        let entries = GitParsers.parseWorktreeList(porcelain: sample)
        XCTAssertEqual(entries.count, 5)

        XCTAssertEqual(entries[0].path, "/Users/dev/repo")
        XCTAssertEqual(entries[0].head, "a1b2c3d4e5f6")
        XCTAssertEqual(entries[0].branch, "main")
        XCTAssertFalse(entries[0].isBare)
        XCTAssertFalse(entries[0].isDetached)
        XCTAssertFalse(entries[0].isLocked)

        XCTAssertEqual(entries[1].path, "/Users/dev/repo/.worktrees/feature-x")
        XCTAssertEqual(entries[1].head, "9876543210ab")
        XCTAssertEqual(entries[1].branch, "feat/awesome-thing")
        XCTAssertFalse(entries[1].isBare)
        XCTAssertFalse(entries[1].isDetached)
        XCTAssertFalse(entries[1].isLocked)

        XCTAssertEqual(entries[2].path, "/Users/dev/repo/.worktrees/detached-node")
        XCTAssertTrue(entries[2].isDetached)
        XCTAssertFalse(entries[2].isLocked)

        XCTAssertEqual(entries[3].path, "/Users/dev/repo/.worktrees/locked-node")
        XCTAssertEqual(entries[3].head, "deadbeef1234")
        XCTAssertEqual(entries[3].branch, "fix/locked-task")
        XCTAssertTrue(entries[3].isLocked)

        XCTAssertEqual(entries[4].path, "/Users/dev/bare-repo")
        XCTAssertTrue(entries[4].isBare)
        XCTAssertFalse(entries[4].isLocked)
    }

    func testParseAheadBehind() {
        let sample = "3\t5\n"
        let res = GitParsers.parseAheadBehind(output: sample)
        XCTAssertNotNil(res)
        XCTAssertEqual(res?.ahead, 3)
        XCTAssertEqual(res?.behind, 5)

        XCTAssertNil(GitParsers.parseAheadBehind(output: "invalid"))
    }

    func testParseRepoRoot() {
        XCTAssertEqual(GitParsers.parseRepoRoot(output: "/Users/dev/repo/.git\n"), "/Users/dev/repo")
        XCTAssertEqual(GitParsers.parseRepoRoot(output: "/Users/dev/repo\n"), "/Users/dev/repo")
        XCTAssertNil(GitParsers.parseRepoRoot(output: ""))
    }

    func testParseDiffHunksAndPatchText() {
        let diff = """
        diff --git a/file.txt b/file.txt
        index 1234567..89abcdef 100644
        --- a/file.txt
        +++ b/file.txt
        @@ -1,3 +1,4 @@
         line 1
        +line 1.5
         line 2
         line 3
        @@ -10,2 +11,3 @@
         line 10
        +line 10.5
         line 11
        """

        let (header, hunks) = GitParsers.parseDiffHunks(diff)
        XCTAssertEqual(header.count, 4)
        XCTAssertEqual(hunks.count, 2)
        XCTAssertTrue(hunks[0][0].hasPrefix("@@ -1,3 +1,4 @@"))
        XCTAssertTrue(hunks[1][0].hasPrefix("@@ -10,2 +11,3 @@"))

        let patch = GitParsers.patchText(header: header, hunk: hunks[0])
        XCTAssertTrue(patch.hasPrefix("diff --git"))
        XCTAssertTrue(patch.contains("+line 1.5"))
    }

    func testErrorSummary() {
        let stderr = """
        hint: Updates were rejected because the remote contains work that you do
        hint: not have locally.
        error: failed to push some refs to 'origin'
        fatal: The remote end hung up unexpectedly
        """
        let summary = GitParsers.errorSummary(from: stderr)
        XCTAssertEqual(summary, "error: failed to push some refs to 'origin' fatal: The remote end hung up unexpectedly")
    }
}
