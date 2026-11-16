import XCTest
@testable import KouenApp

/// Regression guard for the FSEvent noise filter fixed in this session: it must
/// keep ignoring the panel's own auto-stage writes (.git/index) but must NOT
/// swallow the ref/log changes an external `git commit`/`push` produces —
/// f6ffb0a's blanket `.git/` filter broke exactly that.
final class GitPanelViewFSEventFilterTests: XCTestCase {
    func test_TS_2324_BE_UT_refreshGateRunsOneTrailingRefreshWithoutOverlap() {
        var gate = GitPanelRefreshGate()
        XCTAssertTrue(gate.begin())
        XCTAssertFalse(gate.begin())
        XCTAssertFalse(gate.begin())
        XCTAssertTrue(gate.isRunning)
        XCTAssertTrue(gate.finish(), "bursts coalesce into one rerun after active git work completes")
        XCTAssertTrue(gate.begin())
        XCTAssertFalse(gate.finish())
    }

    @MainActor
    func test_TS_2284_BE_UT_RapidWatcherStartStopCyclesRetainCallbackContextUntilQueueDrains() {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("git-panel-watch-\(UUID().uuidString)", isDirectory: true)
        try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let panel = GitPanelView(frame: .zero)
        for _ in 0..<200 {
            panel.updateRoot(path: root.path)
            panel.clearRoot()
        }
    }

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
