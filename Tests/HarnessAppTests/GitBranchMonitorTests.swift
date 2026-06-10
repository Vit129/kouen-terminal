import Foundation
import XCTest
@testable import HarnessApp
import HarnessCore

/// `GitBranchMonitor` against hand-built `.git` fixtures (no `git` binary needed — the
/// reader only parses files). The monitor's I/O is async (background queue → main hop) and
/// its watcher events are debounced, so assertions use deadline polling on the main run
/// loop rather than fixed sleeps; "nothing fired" assertions use a short bounded window.
@MainActor
final class GitBranchMonitorTests: XCTestCase {
    // XCTest runs this class's synchronous lifecycle + test methods on the main thread, but
    // the setUp/tearDown overrides are nonisolated by signature, so the class-level
    // @MainActor can't reach them — `nonisolated(unsafe)` under that single-threaded
    // contract, with the @MainActor monitor constructed inside `assumeIsolated`.
    nonisolated(unsafe) private var root: URL!
    nonisolated(unsafe) private var monitor: GitBranchMonitor!
    nonisolated(unsafe) private var changes: [(workspaceID: WorkspaceID, tabID: TabID, branch: String?)] = []

    override func setUpWithError() throws {
        root = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("git-branch-monitor-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        changes = []
        MainActor.assumeIsolated {
            monitor = GitBranchMonitor()
            monitor.onBranchChange = { [weak self] workspaceID, tabID, branch in
                self?.changes.append((workspaceID, tabID, branch))
            }
        }
    }

    override func tearDownWithError() throws {
        monitor = nil
        try? FileManager.default.removeItem(at: root)
    }

    private func makeRepository(named name: String, branch: String) throws -> URL {
        let workTree = root.appendingPathComponent(name, isDirectory: true)
        let gitDir = workTree.appendingPathComponent(".git", isDirectory: true)
        try FileManager.default.createDirectory(at: gitDir, withIntermediateDirectories: true)
        try "ref: refs/heads/\(branch)\n"
            .write(to: gitDir.appendingPathComponent("HEAD"), atomically: true, encoding: .utf8)
        return workTree
    }

    private func record(
        workspaceID: WorkspaceID = UUID(),
        tabID: TabID = UUID(),
        cwd: String,
        snapshotBranch: String? = nil
    ) -> GitBranchMonitor.TabRecord {
        GitBranchMonitor.TabRecord(
            workspaceID: workspaceID, tabID: tabID, cwd: cwd, snapshotBranch: snapshotBranch
        )
    }

    /// Spin the main run loop until `condition` holds (the monitor's I/O completions hop to
    /// main, so the loop must turn for them to land). Fails the test on deadline.
    private func waitUntil(
        timeout: TimeInterval = 5,
        _ message: String,
        condition: () -> Bool
    ) {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if condition() { return }
            RunLoop.main.run(until: Date().addingTimeInterval(0.02))
        }
        XCTFail("timed out waiting for: \(message)")
    }

    /// Give async work a bounded window to (wrongly) fire, then assert it didn't.
    private func assertNoChanges(within window: TimeInterval = 0.7, _ message: String) {
        let deadline = Date().addingTimeInterval(window)
        while Date() < deadline {
            RunLoop.main.run(until: Date().addingTimeInterval(0.02))
            if !changes.isEmpty { break }
        }
        XCTAssertTrue(changes.isEmpty, "\(message) — got \(changes)")
    }

    func testStaleSnapshotBranchIsPushed() throws {
        let repo = try makeRepository(named: "repo", branch: "main")
        let tab = record(cwd: repo.path, snapshotBranch: nil)
        monitor.update(tabs: [tab])
        waitUntil("branch push for stale snapshot") { !changes.isEmpty }
        XCTAssertEqual(changes.first?.tabID, tab.tabID)
        XCTAssertEqual(changes.first?.branch, "main")
    }

    func testMatchingSnapshotProducesZeroIPC() throws {
        let repo = try makeRepository(named: "repo", branch: "main")
        monitor.update(tabs: [record(cwd: repo.path, snapshotBranch: "main")])
        assertNoChanges(within: 1.0, "steady state must not send updateTabGitBranch")
    }

    func testLeavingRepositoryClearsStaleLabel() throws {
        let plain = root.appendingPathComponent("plain", isDirectory: true)
        try FileManager.default.createDirectory(at: plain, withIntermediateDirectories: true)
        let tab = record(cwd: plain.path, snapshotBranch: "main")
        monitor.update(tabs: [tab])
        waitUntil("clear push for non-repo cwd") { !changes.isEmpty }
        XCTAssertEqual(changes.first?.tabID, tab.tabID)
        XCTAssertEqual(changes.count, 1)
        XCTAssertNil(changes[0].branch)
    }

    func testDuplicateSendIsSuppressedWhileSnapshotLags() throws {
        let repo = try makeRepository(named: "repo", branch: "main")
        let tab = record(cwd: repo.path, snapshotBranch: nil)
        monitor.update(tabs: [tab])
        waitUntil("first push") { changes.count == 1 }
        // The daemon hasn't echoed the new value back yet (snapshotBranch still nil):
        // re-reconciling must not re-send.
        changes = []
        monitor.update(tabs: [tab])
        assertNoChanges(within: 1.0, "in-flight value must not be re-sent")
    }

    func testCheckoutFiresWatcherAndPushesNewBranch() throws {
        let repo = try makeRepository(named: "repo", branch: "main")
        let tab = record(cwd: repo.path, snapshotBranch: "main")
        monitor.update(tabs: [tab])
        // Let the initial resolve land (no change expected — snapshot matches).
        assertNoChanges(within: 0.5, "no push before the checkout")

        // Same atomic rewrite a real `git checkout` performs on HEAD.
        let head = repo.appendingPathComponent(".git/HEAD")
        try "ref: refs/heads/feature\n".write(to: head, atomically: true, encoding: .utf8)
        waitUntil("push after checkout", condition: { !self.changes.isEmpty })
        XCTAssertEqual(changes.first?.branch, "feature")
    }

    func testTwoTabsInOneRepositoryShareOneWatcherAndBothUpdate() throws {
        let repo = try makeRepository(named: "repo", branch: "main")
        let sub = repo.appendingPathComponent("nested", isDirectory: true)
        try FileManager.default.createDirectory(at: sub, withIntermediateDirectories: true)
        let tabA = record(cwd: repo.path, snapshotBranch: "main")
        let tabB = record(cwd: sub.path, snapshotBranch: "main")
        monitor.update(tabs: [tabA, tabB])
        assertNoChanges(within: 0.5, "no push before the checkout")

        try "ref: refs/heads/release\n"
            .write(to: repo.appendingPathComponent(".git/HEAD"), atomically: true, encoding: .utf8)
        waitUntil("both tabs pushed", condition: { self.changes.count == 2 })
        XCTAssertEqual(Set(changes.map(\.tabID)), [tabA.tabID, tabB.tabID])
        XCTAssertTrue(changes.allSatisfy { $0.branch == "release" })
    }

    func testPausedMonitorStaysSilentAndResumeCatchesUp() throws {
        let repo = try makeRepository(named: "repo", branch: "main")
        let tab = record(cwd: repo.path, snapshotBranch: "main")
        monitor.update(tabs: [tab])
        assertNoChanges(within: 0.5, "steady state")

        monitor.pause()
        try "ref: refs/heads/away\n"
            .write(to: repo.appendingPathComponent(".git/HEAD"), atomically: true, encoding: .utf8)
        assertNoChanges(within: 0.7, "paused monitor must not push")

        monitor.resume()
        waitUntil("resume catches up on the missed checkout") { !self.changes.isEmpty }
        XCTAssertEqual(changes.first?.branch, "away")
    }

    func testCwdMoveIntoFreshRepositoryReChecksNegativeCache() throws {
        let dir = root.appendingPathComponent("becomes-repo", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let elsewhere = root.appendingPathComponent("elsewhere", isDirectory: true)
        try FileManager.default.createDirectory(at: elsewhere, withIntermediateDirectories: true)

        // First visit: cached as not-a-repository.
        let tabID = UUID()
        let workspaceID = UUID()
        monitor.update(tabs: [record(workspaceID: workspaceID, tabID: tabID, cwd: dir.path)])
        assertNoChanges(within: 0.5, "non-repo with nil snapshot stays silent")

        // The directory becomes a repository while the tab is elsewhere…
        let gitDir = dir.appendingPathComponent(".git", isDirectory: true)
        try FileManager.default.createDirectory(at: gitDir, withIntermediateDirectories: true)
        try "ref: refs/heads/fresh\n"
            .write(to: gitDir.appendingPathComponent("HEAD"), atomically: true, encoding: .utf8)
        monitor.update(tabs: [record(workspaceID: workspaceID, tabID: tabID, cwd: elsewhere.path)])

        // …and moving back in re-resolves instead of trusting the stale negative entry.
        monitor.update(tabs: [record(workspaceID: workspaceID, tabID: tabID, cwd: dir.path)])
        waitUntil("re-check after cwd moves into a fresh repo") { !self.changes.isEmpty }
        XCTAssertEqual(changes.first?.branch, "fresh")
    }
}
