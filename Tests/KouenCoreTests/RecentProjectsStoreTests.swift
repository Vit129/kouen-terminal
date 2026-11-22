import Foundation
import XCTest
@testable import KouenCore

final class RecentProjectsStoreTests: XCTestCase {
    func test_TS_0001_BE_IT_RecordsRecentsUsingExistingKeyAndLimit() throws {
        let suite = "RecentProjectsStoreTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }

        XCTAssertEqual(RecentProjectsStore.load(defaults: defaults), [])
        defaults.set((0..<11).map(String.init), forKey: "RecentProjectPaths")
        RecentProjectsStore.record("5", defaults: defaults)
        XCTAssertEqual(defaults.stringArray(forKey: "RecentProjectPaths"),
                       ["5", "0", "1", "2", "3", "4", "6", "7", "8", "9"])
    }
}
