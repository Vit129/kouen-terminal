import XCTest
@testable import KouenApp

final class ProjectGroupWatcherTests: XCTestCase {
    @MainActor
    func test_TS_2285_BE_UT_CategoryRootChangeRequiresStreamReplacement() {
        XCTAssertTrue(ProjectGroupWatcher.shouldReplaceStream(existingRootPath: "/projects/old", newRootPath: "/projects/new"))
        XCTAssertFalse(ProjectGroupWatcher.shouldReplaceStream(existingRootPath: "/projects/current", newRootPath: "/projects/current"))
    }
}
