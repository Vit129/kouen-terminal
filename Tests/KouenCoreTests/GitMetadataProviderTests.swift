import XCTest
@testable import KouenCore

final class GitMetadataProviderTests: XCTestCase {
    func testTopLevelReturnsRepoRootForPathInsideThisRepo() {
        // This test file's own directory is inside the kouen-terminal checkout.
        let thisFile = URL(fileURLWithPath: #filePath)
        let root = GitMetadataProvider.topLevel(at: thisFile.deletingLastPathComponent().path)
        XCTAssertNotNil(root)
        XCTAssertTrue(FileManager.default.fileExists(atPath: "\(root!)/.git"))
    }

    func testTopLevelReturnsNilOutsideAGitRepo() {
        XCTAssertNil(GitMetadataProvider.topLevel(at: NSTemporaryDirectory()))
    }
}
