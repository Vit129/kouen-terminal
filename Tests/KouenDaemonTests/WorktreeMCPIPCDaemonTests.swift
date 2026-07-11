import XCTest
@testable import KouenCore
@testable import KouenDaemonCore

/// Integration tests for Worktree (MCP resource, P40 F2) IPC via SurfaceRegistry.handle()
/// directly against a real temp git repo — same pattern as WorktreeIsolationDaemonTests.
final class WorktreeMCPIPCDaemonTests: XCTestCase {
    private var root: URL!
    private var repoPath: String!
    private var previousHome: String?

    override func setUpWithError() throws {
        previousHome = getenv("KOUEN_HOME").map { String(cString: $0) }
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("kouen-wt-mcp-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        root = dir
        setenv("KOUEN_HOME", dir.path, 1)
        try KouenPaths.ensureDirectories()

        repoPath = dir.appendingPathComponent("repo").path
        try FileManager.default.createDirectory(atPath: repoPath, withIntermediateDirectories: true)
        shell("git init && git commit --allow-empty -m init", in: repoPath)
    }

    override func tearDownWithError() throws {
        if let previousHome { setenv("KOUEN_HOME", previousHome, 1) } else { unsetenv("KOUEN_HOME") }
        try? FileManager.default.removeItem(at: root)
    }

    func testCreateListRemoveRoundTripViaIPC() throws {
        let registry = SurfaceRegistry()

        guard case let .worktreePath(path?) = registry.handle(.worktreeCreate(
            repoPath: repoPath, sessionID: "mcp-test", branch: "feat-mcp", baseRef: nil
        )) else {
            return XCTFail("Expected .worktreePath from worktreeCreate")
        }
        XCTAssertTrue(FileManager.default.fileExists(atPath: path))

        guard case let .worktrees(infos) = registry.handle(.worktreeList(repoPath: repoPath)) else {
            return XCTFail("Expected .worktrees from worktreeList")
        }
        // git canonicalizes the path in `worktree list --porcelain` output (e.g. macOS
        // /var -> /private/var), so compare by branch, not exact path — same precedent
        // as WorktreeIsolationTests.testCreateAndListWorktree.
        XCTAssertEqual(infos.count, 2) // main worktree + the one just created
        XCTAssertTrue(infos.contains { $0.branch == "feat-mcp" })

        guard case .ok = registry.handle(.worktreeRemove(repoPath: repoPath, worktreePath: path, force: false)) else {
            return XCTFail("Expected .ok from worktreeRemove")
        }
        guard case let .worktrees(afterRemove) = registry.handle(.worktreeList(repoPath: repoPath)) else {
            return XCTFail("Expected .worktrees from worktreeList after remove")
        }
        XCTAssertFalse(afterRemove.contains { $0.path == path })
    }

    func testRemoveNonexistentWorktreeReturnsError() {
        let registry = SurfaceRegistry()
        guard case .error = registry.handle(.worktreeRemove(
            repoPath: repoPath, worktreePath: "\(repoPath!)/.kouen-worktrees/does-not-exist", force: false
        )) else {
            return XCTFail("Expected .error from worktreeRemove on a nonexistent path")
        }
    }

    private func shell(_ command: String, in dir: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/sh")
        process.arguments = ["-c", command]
        process.currentDirectoryURL = URL(fileURLWithPath: dir)
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        try? process.run()
        process.waitUntilExit()
    }
}
