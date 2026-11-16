import XCTest
@testable import KouenApp

final class ProjectGroupWatcherTests: XCTestCase {
    @MainActor
    func test_TS_2285_BE_UT_CategoryRootChangeRequiresStreamReplacement() {
        XCTAssertTrue(ProjectGroupWatcher.shouldReplaceStream(existingRootPath: "/projects/old", newRootPath: "/projects/new"))
        XCTAssertFalse(ProjectGroupWatcher.shouldReplaceStream(existingRootPath: "/projects/current", newRootPath: "/projects/current"))
    }

    @MainActor
    func test_TS_2310_BE_IT_existingChildGitInitTriggersWatch() async throws {
        let repo = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        let root = repo.appendingPathComponent(".tmp/project-group-watch-\(UUID().uuidString)", isDirectory: true)
        let child = root.appendingPathComponent("repo", isDirectory: true)
        try FileManager.default.createDirectory(at: child, withIntermediateDirectories: true)
        let watcher = ProjectGroupWatcher()
        defer {
            watcher.stopAll()
            try? FileManager.default.removeItem(at: root)
        }
        let changed = expectation(description: "direct child git entry change")
        watcher.update(folders: [(id: "fixture", folder: root.path)], onChange: { _ in changed.fulfill() })
        try FileManager.default.createDirectory(at: child.appendingPathComponent(".git", isDirectory: true), withIntermediateDirectories: false)
        await fulfillment(of: [changed], timeout: 5)
    }
}
