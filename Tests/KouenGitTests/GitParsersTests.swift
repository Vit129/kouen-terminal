import Foundation
import KouenGit
import XCTest

final class GitParsersTests: XCTestCase {
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

        worktree /Users/dev/bare-repo
        bare
        """

        let entries = GitParsers.parseWorktreeList(porcelain: sample)
        XCTAssertEqual(entries.count, 4)

        XCTAssertEqual(entries[0].path, "/Users/dev/repo")
        XCTAssertEqual(entries[0].head, "a1b2c3d4e5f6")
        XCTAssertEqual(entries[0].branch, "main")
        XCTAssertFalse(entries[0].isBare)
        XCTAssertFalse(entries[0].isDetached)

        XCTAssertEqual(entries[1].path, "/Users/dev/repo/.worktrees/feature-x")
        XCTAssertEqual(entries[1].head, "9876543210ab")
        XCTAssertEqual(entries[1].branch, "feat/awesome-thing")
        XCTAssertFalse(entries[1].isBare)
        XCTAssertFalse(entries[1].isDetached)

        XCTAssertEqual(entries[2].path, "/Users/dev/repo/.worktrees/detached-node")
        XCTAssertTrue(entries[2].isDetached)

        XCTAssertEqual(entries[3].path, "/Users/dev/bare-repo")
        XCTAssertTrue(entries[3].isBare)
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
}
