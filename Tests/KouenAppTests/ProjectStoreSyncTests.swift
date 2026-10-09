import XCTest
import KouenCore
@testable import KouenApp

final class ProjectStoreSyncTests: XCTestCase {
    private var tempDirURL: URL!
    private var tempPath: String { tempDirURL.path }

    override func setUp() {
        super.setUp()
        tempDirURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("kouen_p54_tests_\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: tempDirURL, withIntermediateDirectories: true)
    }

    override func tearDown() {
        if let tempDirURL {
            try? FileManager.default.removeItem(at: tempDirURL)
        }
        super.tearDown()
    }

    // MARK: - [TS-P54-001] [FE-UT] Legacy JSON Decoding
    func testProjectCategoryLegacyJSONDecoding() throws {
        let legacyJSON = """
        {
            "id": "cat-123",
            "name": "Personal"
        }
        """.data(using: .utf8)!

        let category = try JSONDecoder().decode(ProjectCategory.self, from: legacyJSON)
        XCTAssertEqual(category.id, "cat-123")
        XCTAssertEqual(category.name, "Personal")
        XCTAssertNil(category.sourceFolder)
        XCTAssertTrue(category.excludedPaths.isEmpty)
    }

    // MARK: - [TS-P54-002] [FE-UT] Sync Detects Added Repo
    @MainActor
    func testSyncCategoryDetectsAddedRepo() async throws {
        let repoA = tempDirURL.appendingPathComponent("repoA")
        let gitDirA = repoA.appendingPathComponent(".git")
        try FileManager.default.createDirectory(at: gitDirA, withIntermediateDirectories: true)

        let store = ProjectStore(userDefaultsSuite: "test_sync_\(UUID().uuidString)")
        let cat = store.addCategory(name: "TestGroup", sourceFolder: tempPath)

        await store.syncCategory(id: cat.id)

        let tracked = store.projects.filter { $0.categoryID == cat.id }
        XCTAssertTrue(tracked.contains { $0.path == repoA.path }, "Newly added repoA should be synced into category")
    }

    // MARK: - [TS-P54-003] [FE-UT] Sync Prunes Deleted Repo
    @MainActor
    func testSyncCategoryPrunesDeletedRepo() async throws {
        let repoA = tempDirURL.appendingPathComponent("repoA")
        let gitDirA = repoA.appendingPathComponent(".git")
        try FileManager.default.createDirectory(at: gitDirA, withIntermediateDirectories: true)

        let store = ProjectStore(userDefaultsSuite: "test_sync_\(UUID().uuidString)")
        let cat = store.addCategory(name: "TestGroup", sourceFolder: tempPath)

        await store.syncCategory(id: cat.id)
        XCTAssertTrue(store.projects.contains { $0.path == repoA.path })

        // Now delete repoA from disk
        try FileManager.default.removeItem(at: repoA)

        await store.syncCategory(id: cat.id)
        XCTAssertFalse(store.projects.contains { $0.path == repoA.path }, "Deleted repoA should be pruned from category")
    }

    // MARK: - [TS-P54-004] [FE-UT] Manual Removal Adds to ExcludedPaths
    @MainActor
    func testManualRemovalAddsToExcludedPathsAndPreventsResync() async throws {
        let repoA = tempDirURL.appendingPathComponent("repoA")
        let gitDirA = repoA.appendingPathComponent(".git")
        try FileManager.default.createDirectory(at: gitDirA, withIntermediateDirectories: true)

        let store = ProjectStore(userDefaultsSuite: "test_sync_\(UUID().uuidString)")
        let cat = store.addCategory(name: "TestGroup", sourceFolder: tempPath)

        await store.syncCategory(id: cat.id)
        XCTAssertTrue(store.projects.contains { $0.path == repoA.path })

        // Manually remove project from group
        store.removeProject(repoA.path)
        XCTAssertFalse(store.projects.contains { $0.path == repoA.path })

        let updatedCat = store.categories.first { $0.id == cat.id }
        XCTAssertTrue(updatedCat?.excludedPaths.contains(repoA.path) == true, "Removed repo should be recorded in excludedPaths")

        // Resync should NOT re-add repoA
        await store.syncCategory(id: cat.id)
        XCTAssertFalse(store.projects.contains { $0.path == repoA.path }, "Excluded repo should not be re-added by sync")
    }

    // MARK: - [TS-P54-005] [FE-UT] Preserve External Entries
    @MainActor
    func testSyncPreservesExternalEntriesOutsideSourceFolder() async throws {
        let externalPath = "/tmp/some_external_project_\(UUID().uuidString)"

        let store = ProjectStore(userDefaultsSuite: "test_sync_\(UUID().uuidString)")
        let cat = store.addCategory(name: "TestGroup", sourceFolder: tempPath)

        store.addProject(externalPath, categoryID: cat.id)
        XCTAssertTrue(store.projects.contains { $0.path == externalPath })

        await store.syncCategory(id: cat.id)
        XCTAssertTrue(store.projects.contains { $0.path == externalPath }, "External entry outside sourceFolder must be preserved")
    }

    // MARK: - [TS-P54-006] [FE-UT] Missing SourceFolder Safety Guard
    @MainActor
    func testMissingSourceFolderPreservesExistingEntries() async throws {
        let missingPath = tempPath + "/non_existent_folder"
        let fakeRepo = missingPath + "/repoX"

        let store = ProjectStore(userDefaultsSuite: "test_sync_\(UUID().uuidString)")
        let cat = store.addCategory(name: "TestGroup", sourceFolder: missingPath)
        store.addProject(fakeRepo, categoryID: cat.id)

        await store.syncCategory(id: cat.id)
        XCTAssertTrue(store.projects.contains { $0.path == fakeRepo }, "Entries must be preserved if sourceFolder itself is missing/unmounted")
    }
}
