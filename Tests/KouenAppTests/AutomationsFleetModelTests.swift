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

    /// Every runner resolves to its repo, not `~`: bash -c "<x>.sh >> log", node <x>.js,
    /// python3 <x>.py --flag, and npm with only a WorkingDirectory.
    func testLocateJobResolvesRepoForAnyRunner() throws {
        let tmp = FileManager.default.temporaryDirectory
            .appendingPathComponent("AutomationsFleetModelTests-\(UUID().uuidString)")
        let scripts = tmp.appendingPathComponent("scripts")
        try FileManager.default.createDirectory(at: scripts, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: tmp.appendingPathComponent(".git"), withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tmp) }
        for name in ["run.sh", "proxy.js", "report.py"] {
            FileManager.default.createFile(atPath: scripts.appendingPathComponent(name).path, contents: Data())
        }
        let log = tmp.appendingPathComponent("logs/x.log").path
        FileManager.default.createFile(atPath: log, contents: Data())
        let s = scripts.path

        let bash = AutomationsFleetModel.locateJob(programArgs: ["/bin/bash", "-c", "\(s)/run.sh >> \(log) 2>&1"], workingDirectory: nil)
        XCTAssertEqual(bash.script, "\(s)/run.sh"); XCTAssertEqual(bash.repo, tmp.path)
        let node = AutomationsFleetModel.locateJob(programArgs: ["/usr/local/bin/node", "\(s)/proxy.js"], workingDirectory: nil)
        XCTAssertEqual(node.script, "\(s)/proxy.js"); XCTAssertEqual(node.repo, tmp.path)
        let py = AutomationsFleetModel.locateJob(programArgs: ["/usr/bin/python3", "\(s)/report.py", "--auto"], workingDirectory: nil)
        XCTAssertEqual(py.script, "\(s)/report.py"); XCTAssertEqual(py.repo, tmp.path)
        let npm = AutomationsFleetModel.locateJob(programArgs: ["/usr/local/bin/npm", "run", "backup"], workingDirectory: s)
        XCTAssertNil(npm.script); XCTAssertEqual(npm.repo, tmp.path)
        // a log inside the repo after `>>` is never taken as the script
        let onlyLog = AutomationsFleetModel.locateJob(programArgs: ["/bin/bash", "-c", "echo hi >> \(log)"], workingDirectory: nil)
        XCTAssertNil(onlyLog.script)
        XCTAssertEqual(AutomationsFleetModel.locateJob(programArgs: ["/usr/bin/true"], workingDirectory: nil).repo,
                       FileManager.default.homeDirectoryForCurrentUser.path)
    }
}
