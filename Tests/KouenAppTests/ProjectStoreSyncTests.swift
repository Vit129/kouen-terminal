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

    @MainActor
    func testTC6920_FE_BL_ExactDuplicateKeepsOriginalCategory() {
        let store = ProjectStore(userDefaultsSuite: UUID().uuidString)
        let personal = store.addCategory(name: "Personal")
        let company = store.addCategory(name: "Company")
        store.addProject(tempPath, categoryID: personal.id)
        store.addProject(tempPath, categoryID: company.id)
        XCTAssertEqual(store.projects.count, 1)
        XCTAssertEqual(store.projects.first?.categoryID, personal.id)
    }

    @MainActor
    func testTC6920_FE_BL_SymlinkDuplicateIsRejected() throws {
        let repo = tempDirURL.appendingPathComponent("repo")
        let alias = tempDirURL.appendingPathComponent("alias")
        try FileManager.default.createDirectory(at: repo, withIntermediateDirectories: false)
        try FileManager.default.createSymbolicLink(at: alias, withDestinationURL: repo)
        let store = ProjectStore(userDefaultsSuite: UUID().uuidString)
        store.addProject(repo.path)
        store.addProject(alias.path)
        XCTAssertEqual(store.projects.map(\.path), [repo.path])
    }

    @MainActor
    func testTC6920_FE_BL_TrailingSlashDuplicateIsRejected() {
        let store = ProjectStore(userDefaultsSuite: UUID().uuidString)
        store.addProject(tempPath)
        store.addProject(tempPath + "/")
        XCTAssertEqual(store.projects.map(\.path), [tempPath])
    }

    @MainActor
    func testTC6920_FE_BL_StoredAliasesRenderOnceAcrossCategories() throws {
        let suite = UUID().uuidString
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let rows = [ProjectEntry(path: tempPath, categoryID: "personal"),
                    ProjectEntry(path: tempPath + "/", categoryID: "company")]
        let data = try JSONEncoder().encode(rows)
        defaults.set(data, forKey: "ProjectEntries")
        let store = ProjectStore(userDefaults: defaults)
        XCTAssertEqual(store.projects(inCategory: "personal"), [rows[0]])
        XCTAssertTrue(store.projects(inCategory: "company").isEmpty)
        XCTAssertEqual(defaults.data(forKey: "ProjectEntries"), data)
    }

    @MainActor
    func testTC6920_FE_BL_FolderScanKeepsExistingAliasInItsCategory() async throws {
        let repo = tempDirURL.appendingPathComponent("repo")
        try FileManager.default.createDirectory(at: repo.appendingPathComponent(".git"), withIntermediateDirectories: true)
        let alias = tempDirURL.appendingPathComponent("alias")
        try FileManager.default.createSymbolicLink(at: alias, withDestinationURL: repo)
        let store = ProjectStore(userDefaultsSuite: UUID().uuidString)
        let personal = store.addCategory(name: "Personal")
        let company = store.addCategory(name: "Company", sourceFolder: tempPath)
        store.addProject(alias.path, categoryID: personal.id)

        await store.syncCategory(id: company.id)

        XCTAssertEqual(store.projects.map(\.path), [alias.path])
        XCTAssertEqual(store.projects.first?.categoryID, personal.id)
        let missing = tempDirURL.appendingPathComponent("missing").path
        store.addProject(missing)
        XCTAssertNil(store.previewMoves([missing: repo.path]))
    }

    @MainActor
    func testTC6920_FE_BL_SidebarListModelRevealsDuplicateInCollapsedCategory() throws {
        let store = ProjectStore(userDefaultsSuite: UUID().uuidString)
        let personal = store.addCategory(name: "Personal")
        let entry = try XCTUnwrap(store.addProject(tempPath, categoryID: personal.id)?.entry)
        let model = SidebarListModel()
        model.projectStore = store
        model.toggleCollapse(id: personal.id)
        XCTAssertFalse(model.rows.contains { $0.id == "proj-\(entry.path)" })

        let duplicate = try XCTUnwrap(store.addProject(tempPath + "/"))
        XCTAssertFalse(duplicate.inserted)
        model.revealProject(duplicate.entry)

        XCTAssertEqual(model.projectReveal?.path, entry.path)
        XCTAssertTrue(model.rows.contains { $0.id == "proj-\(entry.path)" })
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
    func testSyncCategoryPreservesMissingRepo() async throws {
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
        XCTAssertTrue(store.projects.contains { $0.path == repoA.path }, "Missing entries must be preserved")
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
