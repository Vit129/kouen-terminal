import XCTest
import KouenCore
@testable import KouenApp

final class ProjectReconciliationTests: XCTestCase {
    @MainActor
    func test_TS_0003_FE_IT_legacyProjectGetsPersistentIdentifier() throws {
        let suite = "project-id-\(UUID())"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defaults.set(Data("[{\"path\":\"/legacy\"}]".utf8), forKey: "ProjectEntries")
        let first = ProjectStore(userDefaults: defaults)
        let identifier = try XCTUnwrap(first.projects.first?.stableID)
        let second = ProjectStore(userDefaults: defaults)
        XCTAssertEqual(second.projects.first?.stableID, identifier)
    }

    @MainActor
    func test_TS_0002_FE_IT_rescanLeavesMoveCandidateForReview() async throws {
        let root = FileManager.default.temporaryDirectory.resolvingSymlinksInPath().appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        let old = root.appendingPathComponent("old/project")
        let new = root.appendingPathComponent("new/project")
        try FileManager.default.createDirectory(at: old.appendingPathComponent(".git"), withIntermediateDirectories: true)
        let store = ProjectStore(userDefaultsSuite: "reconcile_\(UUID())")
        let category = store.addCategory(name: "Test", sourceFolder: root.path)
        await store.syncCategory(id: category.id)
        let savedPath = try XCTUnwrap(store.projects.first(where: { $0.categoryID == category.id })?.path)
        try FileManager.default.createDirectory(at: new.deletingLastPathComponent(), withIntermediateDirectories: true)
        try FileManager.default.moveItem(at: old, to: new)
        await store.syncCategory(id: category.id)
        let discoveredPath = try XCTUnwrap(WorkspaceRepositoryScanner.scan(root: root.path).first)
        XCTAssertFalse(store.projects.contains { $0.path == discoveredPath })
        let preview = try XCTUnwrap(store.previewMoves([savedPath: discoveredPath]))
        XCTAssertTrue(store.applyMoves(preview))
        XCTAssertEqual(store.projects.first(where: { $0.categoryID == category.id })?.path, discoveredPath)
    }

    @MainActor
    func test_TS_0002_FE_IT_previewDoesNotWriteAndStaleBatchIsRejected() throws {
        let root = FileManager.default.temporaryDirectory.resolvingSymlinksInPath().appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        let destination = root.appendingPathComponent("new")
        try FileManager.default.createDirectory(at: destination.appendingPathComponent(".git"), withIntermediateDirectories: true)
        let store = ProjectStore(userDefaultsSuite: "reconcile_\(UUID())")
        let old = root.appendingPathComponent("old").path
        store.addProject(old)
        let preview = try XCTUnwrap(store.previewMoves([old: destination.path]))
        XCTAssertEqual(store.projects.map(\.path), [old])
        store.moveProject(old, toCategory: "changed")
        XCTAssertFalse(store.applyMoves(preview))
        XCTAssertEqual(store.projects.map(\.path), [old])
    }
}
