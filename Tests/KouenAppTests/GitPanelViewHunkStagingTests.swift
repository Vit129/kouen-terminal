import XCTest
@testable import KouenApp

/// P39 G4 — per-hunk staging. `parseDiffHunks` is the load-bearing logic: it must split a
/// `git diff -- file` blob into a reusable file header plus independently-patchable hunks, or
/// `git apply --cached` rejects the reconstructed per-hunk patch outright.
final class GitPanelViewHunkStagingTests: XCTestCase {
    private let sampleDiff = """
    diff --git a/foo.swift b/foo.swift
    index abc123..def456 100644
    --- a/foo.swift
    +++ b/foo.swift
    @@ -1,3 +1,3 @@
     line1
    -line2
    +line2 changed
     line3
    @@ -10,2 +10,3 @@
     line10
    +line11 added
    """

    func testSplitsHeaderFromEachHunk() {
        let (header, hunks) = GitPanelView.parseDiffHunks(sampleDiff)
        XCTAssertEqual(header, [
            "diff --git a/foo.swift b/foo.swift",
            "index abc123..def456 100644",
            "--- a/foo.swift",
            "+++ b/foo.swift",
        ])
        XCTAssertEqual(hunks.count, 2)
        XCTAssertEqual(hunks[0].first, "@@ -1,3 +1,3 @@")
        XCTAssertEqual(hunks[1].first, "@@ -10,2 +10,3 @@")
    }

    func testNoHunksReturnsWholeTextAsHeader() {
        let (header, hunks) = GitPanelView.parseDiffHunks("")
        XCTAssertEqual(header, [""])
        XCTAssertTrue(hunks.isEmpty)
    }

    func testPatchTextReconstructsAValidStandalonePatch() {
        let (header, hunks) = GitPanelView.parseDiffHunks(sampleDiff)
        let patch = GitPanelView.patchText(header: header, hunk: hunks[0])
        XCTAssertTrue(patch.hasPrefix("diff --git a/foo.swift b/foo.swift\n"))
        XCTAssertTrue(patch.contains("@@ -1,3 +1,3 @@\n"))
        XCTAssertTrue(patch.hasSuffix(" line3\n"), "a valid patch file must end with a trailing newline")
        XCTAssertFalse(patch.contains("@@ -10,2"), "the second hunk must not leak into the first hunk's patch")
    }

    // MARK: - Real `git apply --cached` round-trip

    /// Parsing tests above prove the patch text is well-formed; they don't prove `git apply
    /// --cached` actually accepts it against a real index — the two-hunk-file / partial-stage
    /// case is exactly where a subtly wrong header or line-offset would surface. Runs a real
    /// `git` binary against a throwaway temp repo (no daemon/IPC — that layer is a pure
    /// pass-through already covered by `SSHTunnelManagerTests`-style process tests elsewhere).
    private func makeTempRepo() throws -> URL {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("kouen-hunk-test-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        try run(["init", "-q"], in: dir)
        try run(["config", "user.email", "test@example.com"], in: dir)
        try run(["config", "user.name", "Test"], in: dir)
        return dir
    }

    @discardableResult
    private func run(_ args: [String], in dir: URL) throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = args
        process.currentDirectoryURL = dir
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        try process.run()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        let output = String(data: data, encoding: .utf8) ?? ""
        guard process.terminationStatus == 0 else {
            throw NSError(domain: "git", code: Int(process.terminationStatus), userInfo: [NSLocalizedDescriptionKey: output])
        }
        return output
    }

    func testStagingOneHunkLeavesTheOtherUnstaged() throws {
        let repo = try makeTempRepo()
        defer { try? FileManager.default.removeItem(at: repo) }

        // Default `git diff` context is 3 lines each side of a change — the two edits below
        // need >6 unchanged lines between them or git merges them into a single hunk.
        let lines = (1...20).map { "line\($0)" }
        let original = lines.joined(separator: "\n") + "\n"
        try original.write(to: repo.appendingPathComponent("f.txt"), atomically: true, encoding: .utf8)
        try run(["add", "f.txt"], in: repo)
        try run(["commit", "-q", "-m", "initial"], in: repo)

        var modifiedLines = lines
        modifiedLines[1] = "line2 CHANGED"
        modifiedLines[17] = "line18 CHANGED"
        let modified = modifiedLines.joined(separator: "\n") + "\n"
        try modified.write(to: repo.appendingPathComponent("f.txt"), atomically: true, encoding: .utf8)

        let diffText = try run(["diff", "--", "f.txt"], in: repo)
        let (header, hunks) = GitPanelView.parseDiffHunks(diffText)
        XCTAssertEqual(hunks.count, 2, "fixture must produce two independent hunks to prove partial staging")

        let patch = GitPanelView.patchText(header: header, hunk: hunks[0])
        let patchPath = repo.appendingPathComponent("one.patch")
        try patch.write(to: patchPath, atomically: true, encoding: .utf8)
        try run(["apply", "--cached", patchPath.path], in: repo)

        let staged = try run(["diff", "--cached", "--", "f.txt"], in: repo)
        XCTAssertTrue(staged.contains("line2 CHANGED"), "the staged hunk must be in the index")
        XCTAssertFalse(staged.contains("line18 CHANGED"), "the second hunk must NOT have been staged")

        let stillUnstaged = try run(["diff", "--", "f.txt"], in: repo)
        XCTAssertTrue(stillUnstaged.contains("line18 CHANGED"), "the untouched hunk must still show as unstaged")
        XCTAssertFalse(stillUnstaged.contains("line2 CHANGED"), "the staged hunk must no longer show as unstaged")

        // Reverse: unstage the same hunk via `git diff --cached` + `apply --cached -R`.
        let stagedDiffForReverse = try run(["diff", "--cached", "--", "f.txt"], in: repo)
        let (reverseHeader, reverseHunks) = GitPanelView.parseDiffHunks(stagedDiffForReverse)
        XCTAssertEqual(reverseHunks.count, 1)
        let reversePatch = GitPanelView.patchText(header: reverseHeader, hunk: reverseHunks[0])
        let reversePatchPath = repo.appendingPathComponent("reverse.patch")
        try reversePatch.write(to: reversePatchPath, atomically: true, encoding: .utf8)
        try run(["apply", "--cached", "-R", reversePatchPath.path], in: repo)

        let indexAfterUnstage = try run(["diff", "--cached"], in: repo)
        XCTAssertTrue(indexAfterUnstage.isEmpty, "index must be clean again after reversing the only staged hunk")
    }
}
