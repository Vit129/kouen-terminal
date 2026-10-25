import Foundation
import KouenGit
import XCTest

final class GitRunnerTests: XCTestCase {
    func testGitRunnerVersion() {
        let runner = GitRunner()
        let result = runner.execute(["--version"])
        XCTAssertTrue(result.isSuccess)
        XCTAssertTrue(result.stdout.contains("git version"))
        XCTAssertEqual(result.exitCode, 0)
    }

    func testGitRunnerOutput() {
        let runner = GitRunner()
        let output = runner.executeOutput(["--version"])
        XCTAssertNotNil(output)
        XCTAssertTrue(output?.hasPrefix("git version") == true)
    }

    func testGitServiceHasRemoteInCurrentRepo() {
        let repoRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent() // Tests/KouenGitTests
            .deletingLastPathComponent() // Tests
            .deletingLastPathComponent() // repo root
            .path
        let service = GitService()
        XCTAssertTrue(service.hasRemote(for: repoRoot))
        XCTAssertNotNil(service.resolveRepoRoot(for: repoRoot))
    }
}
