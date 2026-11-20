import Foundation
import KouenGit
import XCTest

final class GitRunnerTests: XCTestCase {
    // MARK: - [BE-UT] GitRunner Binary Execution
    func testGitRunnerVersion() {
        let runner = GitRunner()
        let result = runner.execute(["--version"])
        XCTAssertTrue(result.isSuccess)
        XCTAssertTrue(result.stdout.contains("git version"))
        XCTAssertEqual(result.exitCode, 0)
    }

    // MARK: - [BE-UT] GitRunner Output Capture
    func testGitRunnerOutput() {
        let runner = GitRunner()
        let output = runner.executeOutput(["--version"])
        XCTAssertNotNil(output)
        XCTAssertTrue(output?.hasPrefix("git version") == true)
    }

    // MARK: - [BE-IT] GitService Repository Discovery
    func testGitServiceDiscoversRepositoryAndRemote() throws {
        let fileManager = FileManager.default
        let repo = fileManager.temporaryDirectory
            .appendingPathComponent("kouen-git-discovery-\(UUID().uuidString)", isDirectory: true)
        try fileManager.createDirectory(at: repo, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: repo) }

        let service = GitService()
        let initialize = service.run(["init", "--template="], in: repo.path)
        XCTAssertTrue(initialize.isSuccess, initialize.stderr)
        XCTAssertNotNil(service.resolveRepoRoot(for: repo.path))
        XCTAssertFalse(service.hasRemote(for: repo.path))

        let addRemote = service.run(
            ["remote", "add", "origin", "https://example.invalid/kouen.git"],
            in: repo.path
        )
        XCTAssertTrue(addRemote.isSuccess, addRemote.stderr)
        XCTAssertTrue(service.hasRemote(for: repo.path))
    }
}
