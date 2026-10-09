import XCTest
@testable import KouenCore

/// [TS-P53-01] Regression test for WorktreeManager.runGitOutput pipe buffer deadlock:
/// Calling process.waitUntilExit() before readDataToEndOfFile() deadlocks when subprocess
/// output exceeds the kernel pipe buffer (64KB on macOS).
final class WorktreeLargeOutputRegressionTests: XCTestCase {

    func testIsDirtyCompletesWithoutDeadlockOnLargeOutput() async throws {
        let tempDir = try makeTempGitRepoWithLargeDirtyTree(fileCount: 2500)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let manager = WorktreeManager()

        // Run isDirty with a 5-second timeout.
        // Before the P53 fix, this deadlocks indefinitely because output > 64KB.
        let isDirtyResult = try await withThrowingTaskGroup(of: Bool.self) { group in
            group.addTask {
                manager.isDirty(worktreePath: tempDir.path)
            }
            group.addTask {
                try await Task.sleep(nanoseconds: 5_000_000_000)
                throw TimeoutError()
            }
            let first = try await group.next()!
            group.cancelAll()
            return first
        }

        XCTAssertTrue(isDirtyResult, "Repository with 2500 dirty files must be reported as dirty")
    }

    // MARK: - Helpers

    private struct TimeoutError: Error {}

    private func makeTempGitRepoWithLargeDirtyTree(fileCount: Int) throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("kouen-worktree-large-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)

        let initProc = Process()
        initProc.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        initProc.arguments = ["init", "-q", url.path]
        initProc.standardOutput = FileHandle.nullDevice
        initProc.standardError = FileHandle.nullDevice
        try initProc.run()
        initProc.waitUntilExit()

        // Each untracked entry is "??" followed by space and path + newline (~30-35 bytes).
        // 2500 files comfortably produces ~75KB - 90KB output, exceeding 64KB pipe buffer.
        for i in 0..<fileCount {
            let fileURL = url.appendingPathComponent("dirty_test_file_padding_\(i).txt")
            try Data("x".utf8).write(to: fileURL)
        }

        return url
    }
}
