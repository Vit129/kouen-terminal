import XCTest
@testable import KouenCore

final class RepoResolverTests: XCTestCase {
    func testLooksLikeRepoSpec() {
        XCTAssertTrue(RepoResolver.looksLikeRepoSpec("Vit129/kouen-terminal"))
        XCTAssertFalse(RepoResolver.looksLikeRepoSpec("/Users/vit/repo"))
        XCTAssertFalse(RepoResolver.looksLikeRepoSpec("./repo"))
        XCTAssertFalse(RepoResolver.looksLikeRepoSpec("~/repo"))
        XCTAssertFalse(RepoResolver.looksLikeRepoSpec("just-a-name"))
        XCTAssertFalse(RepoResolver.looksLikeRepoSpec("org/repo/extra"))
    }

    func testResolveReturnsExistingLocalPathWithoutCloning() {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("kouen-repo-\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        let resolver = RepoResolver()
        XCTAssertEqual(resolver.resolve(dir.path), dir.path)
    }

    func testResolveReturnsNilForNonRepoSpecMissingPath() {
        let resolver = RepoResolver()
        XCTAssertNil(resolver.resolve("/definitely/not/a/real/path/\(UUID().uuidString)"))
    }
}
