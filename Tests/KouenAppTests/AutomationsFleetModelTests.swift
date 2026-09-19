import Foundation
import XCTest
@testable import KouenApp

final class AutomationsFleetModelTests: XCTestCase {
    /// Regression for the v4.17.1 fallback bug: with no script path to anchor on, the search
    /// must start AT the home directory, not its parent (`.deletingLastPathComponent` applied
    /// to `home.path` unconditionally used to strip it to e.g. `/Users`, which never contains
    /// a `.git` and made every no-script LaunchAgent resolve to the wrong repoPath).
    func testResolveProjectRootWithNoScriptPathSearchesFromHomeItself() {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        let result = AutomationsFleetModel.resolveProjectRoot(from: nil)
        // No `.git` is expected directly at/above home in a normal environment, so the
        // search should bottom out returning `home` itself — never home's parent.
        XCTAssertFalse(result.hasSuffix("/Users"), "must not have stripped home to its parent")
        XCTAssertEqual(result, home)
    }

    func testResolveProjectRootFindsGitRootAboveScript() throws {
        let tmp = FileManager.default.temporaryDirectory
            .appendingPathComponent("AutomationsFleetModelTests-\(UUID().uuidString)")
        let scriptsDir = tmp.appendingPathComponent("scripts")
        try FileManager.default.createDirectory(at: scriptsDir, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: tmp.appendingPathComponent(".git"), withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tmp) }

        let scriptPath = scriptsDir.appendingPathComponent("report.sh").path
        let result = AutomationsFleetModel.resolveProjectRoot(from: scriptPath)
        XCTAssertEqual(result, tmp.path)
    }
}
