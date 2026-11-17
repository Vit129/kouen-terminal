import XCTest
@testable import KouenCore

final class GitMetadataProviderTests: XCTestCase {
    func test_TS_2360_BE_UT_topLevelResolvesOwnedRepositoryFixture() throws {
        // CI's checkout may have different ownership / safe.directory configuration.
        // Exercise Git discovery in a repository owned by this test process instead.
        let checkout = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        let fixture = checkout.appendingPathComponent(".tmp/git-metadata-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: fixture, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: fixture) }
        let initialized = ProcessRunner.run(
            executable: "/usr/bin/git", arguments: ["init", fixture.path], timeout: 3
        )
        XCTAssertTrue(initialized.isSuccess, initialized.stderr)
        let nested = fixture.appendingPathComponent("nested")
        try FileManager.default.createDirectory(at: nested, withIntermediateDirectories: true)
        let root = try XCTUnwrap(GitMetadataProvider.topLevel(at: nested.path))
        XCTAssertEqual(URL(fileURLWithPath: root).resolvingSymlinksInPath().path, fixture.resolvingSymlinksInPath().path)
        XCTAssertTrue(FileManager.default.fileExists(atPath: "\(root)/.git"))
    }

    func testTopLevelReturnsNilOutsideAGitRepo() {
        XCTAssertNil(GitMetadataProvider.topLevel(at: NSTemporaryDirectory()))
    }
}
