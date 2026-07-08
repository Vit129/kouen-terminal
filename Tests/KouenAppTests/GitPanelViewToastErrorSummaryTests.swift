import XCTest
@testable import KouenApp

/// Regression guard: git panel toast used to show `stderr.prefix(120)` raw —
/// noisy `hint:` lines drowned out the real error and the cut landed mid-word
/// with no ellipsis, reading as a broken message instead of a truncated one.
final class GitPanelViewToastErrorSummaryTests: XCTestCase {
    func testPrefersErrorAndFatalLinesOverHints() {
        let stderr = """
        To git@github.com:Vit129/kouen-terminal.git
         ! [rejected]        main -> main (non-fast-forward)
        error: failed to push some refs to 'git@github.com:Vit129/kouen-terminal.git'
        hint: Updates were rejected because the tip of your current branch is behind
        hint: use 'git pull' before pushing again.
        """
        let summary = GitPanelView.toastErrorSummary(stderr)
        XCTAssertTrue(summary.hasPrefix("error: failed to push"), "expected the error: line first, got: \(summary)")
        XCTAssertFalse(summary.contains("hint:"), "hint: boilerplate must be dropped, got: \(summary)")
    }

    func testFatalLineSurvivesSingleLineError() {
        let stderr = "fatal: unable to access 'https://nonexistent-host.invalid/repo.git/': Could not resolve host: nonexistent-host.invalid"
        XCTAssertEqual(GitPanelView.toastErrorSummary(stderr), stderr)
    }

    func testLongSummaryIsTruncatedWithEllipsisNotMidWordSilently() {
        let stderr = "fatal: " + String(repeating: "x", count: 200)
        let summary = GitPanelView.toastErrorSummary(stderr)
        XCTAssertTrue(summary.hasSuffix("…"), "truncated output must end with an ellipsis marker, got: \(summary)")
        XCTAssertEqual(summary.count, 121, "120 chars of content plus the ellipsis marker")
    }

    func testFallsBackToRawLinesWhenNoErrorOrFatalLinePresent() {
        let stderr = """
        From git@github.com:Vit129/kouen-terminal.git
         * branch            main       -> FETCH_HEAD
        Rebasing (1/1)Could not apply 361806d... a conflicting change
        """
        let summary = GitPanelView.toastErrorSummary(stderr)
        XCTAssertTrue(summary.contains("Could not apply"), "expected the rebase failure text to survive, got: \(summary)")
        XCTAssertFalse(summary.isEmpty)
    }
}
