import XCTest
@testable import HarnessApp

/// Regression guard: `runGit`'s shared helper (~20 call sites) piped stderr but never read it,
/// so a failed `git show`/`git diff` returned "" — indistinguishable from "no changes" at the
/// diff-popover call sites, which meant clicking a commit card or a worktree's diff button did
/// nothing with zero feedback on failure. `runGitDiff` is the scoped fix (only the two
/// diff-preview call sites, not the shared helper) — this exercises it against a real git repo.
final class GitPanelViewDiffErrorTests: XCTestCase {
    private func makeRepo() -> String {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).path
        try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
        run(["init", "-q"], in: dir)
        run(["-c", "user.email=t@t.com", "-c", "user.name=t", "commit", "--allow-empty", "-q", "-m", "init"], in: dir)
        return dir
    }

    private func run(_ args: [String], in dir: String) {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        p.arguments = args
        p.currentDirectoryURL = URL(fileURLWithPath: dir)
        p.standardOutput = Pipe()
        p.standardError = Pipe()
        try? p.run()
        p.waitUntilExit()
    }

    func testSuccessfulShowReturnsDiffText() async {
        let repo = makeRepo()
        let hash = await GitPanelView.runGitDiff(["rev-parse", "HEAD"], in: repo)
        let detail = await GitPanelView.runGitDiff(["show", "--stat", "--patch", hash], in: repo)
        XCTAssertTrue(detail.contains("init"), "expected the commit message in the show output, got: \(detail)")
    }

    func testFailingCommandSurfacesStderrInsteadOfEmptyString() async {
        let repo = makeRepo()
        let detail = await GitPanelView.runGitDiff(["show", "--stat", "--patch", "not-a-real-ref"], in: repo)
        XCTAssertFalse(detail.isEmpty, "a failed git command must not silently return an empty string")
        XCTAssertTrue(detail.contains("git show failed"), "expected the error to be labeled with the failing subcommand, got: \(detail)")
    }

    func testNoChangesVsMainReturnsEmptyNotError() async {
        let repo = makeRepo()
        run(["branch", "main"], in: repo)
        let detail = await GitPanelView.runGitDiff(["diff", "--stat", "--patch", "main...HEAD"], in: repo)
        XCTAssertTrue(detail.isEmpty, "identical branches have no diff — this must stay empty, not an error")
    }
}
