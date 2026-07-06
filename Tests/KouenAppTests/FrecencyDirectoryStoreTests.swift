import XCTest
import KouenCore
@testable import KouenApp

final class FrecencyDirectoryStoreTests: XCTestCase {
    
    override func setUp() async throws {
        try await super.setUp()
        await MainActor.run {
            // Delete existing test frecency-dirs.json to have a clean state
            let url = KouenPaths.applicationSupport.appendingPathComponent("frecency-dirs.json")
            try? FileManager.default.removeItem(at: url)
            FrecencyDirectoryStore.shared.load()
        }
    }
    
    override func tearDown() async throws {
        await MainActor.run {
            let url = KouenPaths.applicationSupport.appendingPathComponent("frecency-dirs.json")
            try? FileManager.default.removeItem(at: url)
        }
        try await super.tearDown()
    }
    
    func testRecordVisit() async {
        await MainActor.run {
            let store = FrecencyDirectoryStore.shared
            XCTAssertTrue(store.entries.isEmpty)
            
            store.recordVisit(path: "/Users/test/dir1")
            XCTAssertEqual(store.entries["/Users/test/dir1"]?.count, 1)
            
            store.recordVisit(path: "/Users/test/dir1")
            XCTAssertEqual(store.entries["/Users/test/dir1"]?.count, 2)
        }
    }
    
    func testRanked() async {
        await MainActor.run {
            let store = FrecencyDirectoryStore.shared
            
            store.recordVisit(path: "/Users/test/dir1")
            store.recordVisit(path: "/Users/test/dir1")
            store.recordVisit(path: "/Users/test/dir2")
            
            let ranked = store.ranked()
            XCTAssertEqual(ranked.first, "/Users/test/dir1")
            XCTAssertEqual(ranked.last, "/Users/test/dir2")
        }
    }
}
