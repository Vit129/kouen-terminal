import XCTest
@testable import KouenApp

final class ProjectGroupWatcherTests: XCTestCase {
    @MainActor
    func test_TS_2285_BE_UT_CategoryRootChangeRequiresStreamReplacement() {
        XCTAssertTrue(ProjectGroupWatcher.shouldReplaceStream(existingRootPath: "/projects/old", newRootPath: "/projects/new"))
        XCTAssertFalse(ProjectGroupWatcher.shouldReplaceStream(existingRootPath: "/projects/current", newRootPath: "/projects/current"))
    }

    @MainActor
    func test_TS_0001_FE_IT_watchesNestedDiscoveryDirectories() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        let nested = root.appendingPathComponent("group/nested")
        try FileManager.default.createDirectory(at: nested, withIntermediateDirectories: true)
        let watched = ProjectGroupWatcher.discoveryWatchPaths(rootPath: root.path)
        XCTAssertTrue(watched.map { URL(fileURLWithPath: $0).resolvingSymlinksInPath().path }.contains(nested.resolvingSymlinksInPath().path))
    }

    @MainActor
    func test_TS_0001_FE_IT_nestedGitInitTriggersWatch() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let nested = root.appendingPathComponent("one/two")
        try FileManager.default.createDirectory(at: nested, withIntermediateDirectories: true)
        let watcher = ProjectGroupWatcher()
        defer { watcher.stopAll(); try? FileManager.default.removeItem(at: root) }
        let ready = expectation(description: "initial discovery complete")
        let changed = expectation(description: "nested git initialized")
        var installed = false
        watcher.update(folders: [(id: "fixture", folder: root.path)]) { _ in
            if !installed { installed = true; ready.fulfill() }
            else { changed.fulfill() }
        }
        await fulfillment(of: [ready], timeout: 5)
        try FileManager.default.createDirectory(at: nested.appendingPathComponent(".git"), withIntermediateDirectories: false)
        await fulfillment(of: [changed], timeout: 5)
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
