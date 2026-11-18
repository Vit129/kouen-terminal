import Foundation
import XCTest
@testable import KouenCore

final class WorkspaceReconciliationTests: XCTestCase {
    func test_TS_0002_BE_UT_weakAndAmbiguousMatchesAreReportedWithoutMutation() throws {
        let missing = ["/old/project", "/other/project"]
        let discovered = ["/new/project"]
        let result = WorkspaceReconciliation.candidates(missing: missing, discovered: discovered)
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.allSatisfy { $0.confidence == "ambiguous" })
        XCTAssertEqual(missing, ["/old/project", "/other/project"])
    }
}
