import XCTest
@testable import KouenApp

/// The sidebar skips `git worktree list` while this signature is unchanged, so it must move on
/// everything that changes the porcelain output (commit, new worktree) and stay put otherwise.
final class WorktreeSignatureTests: XCTestCase {
    private func git(_ args: [String], in dir: URL) throws {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        p.arguments = ["-c", "user.name=t", "-c", "user.email=t@t", "-c", "commit.gpgsign=false"] + args
        p.currentDirectoryURL = dir
        p.standardOutput = FileHandle.nullDevice
        p.standardError = FileHandle.nullDevice
        try p.run()
        p.waitUntilExit()
        XCTAssertEqual(p.terminationStatus, 0, "git \(args)")
    }

    func testSignatureMovesOnCommitAndNewWorktreeOnly() throws {
        let repo = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: repo) }
        try FileManager.default.createDirectory(at: repo, withIntermediateDirectories: true)
        try git(["init", "-q"], in: repo)
        try git(["commit", "-q", "--allow-empty", "-m", "one"], in: repo)

        let first = SidebarListModel.worktreeSignature(rootPath: repo.path)
        XCTAssertNotNil(first)
        XCTAssertEqual(SidebarListModel.worktreeSignature(rootPath: repo.path), first, "nothing changed")

        Thread.sleep(forTimeInterval: 1.1) // mtime granularity
        try git(["commit", "-q", "--allow-empty", "-m", "two"], in: repo)
        let afterCommit = SidebarListModel.worktreeSignature(rootPath: repo.path)
        XCTAssertNotEqual(afterCommit, first, "a commit moves HEAD")

        try git(["worktree", "add", "-q", repo.appendingPathComponent("wt").path, "-b", "x"], in: repo)
        XCTAssertNotEqual(SidebarListModel.worktreeSignature(rootPath: repo.path), afterCommit, "a new worktree")

        XCTAssertNil(SidebarListModel.worktreeSignature(rootPath: repo.appendingPathComponent("wt").path),
                     "a linked worktree has a .git file, so callers fall back to the timer")
    }
}
