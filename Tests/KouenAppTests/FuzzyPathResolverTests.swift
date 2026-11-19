import XCTest
@testable import KouenApp

final class FuzzyPathResolverTests: XCTestCase {
    func testFuzzyScorePrefersPrefixAndWordStarts() throws {
        let prefix = try XCTUnwrap(FileFuzzyMatcher.score(query: "file", in: "FileEditorView.swift"))
        let scattered = try XCTUnwrap(FileFuzzyMatcher.score(query: "file", in: "ProfileListEntry.swift"))
        XCTAssertGreaterThan(prefix, scattered)
    }

    func testFuzzyScoreRejectsMissingSubsequence() {
        XCTAssertNil(FileFuzzyMatcher.score(query: "xyz", in: "FileEditorView.swift"))
    }

    func testFuzzyRankUsesFileNameBeforeFullPathPenalty() {
        let ranked = FileFuzzyMatcher.rank(query: "editor", candidates: [
            "/tmp/project/Docs/EditorGuide.md",
            "/tmp/project/Apps/Kouen/Sources/KouenApp/UI/FileEditorView.swift",
            "/tmp/project/editor-notes.txt",
        ])
        XCTAssertEqual(ranked.first?.candidate, "/tmp/project/editor-notes.txt")
        XCTAssertTrue(ranked.contains { $0.candidate.hasSuffix("FileEditorView.swift") })
    }

    func testResolveReturnsUniqueForClearWinner() {
        let resolution = FuzzyPathResolver.resolve(query: "editor", ranked: [
            (candidate: "/tmp/project/editor-notes.txt", score: 100),
            (candidate: "/tmp/project/FileEditorView.swift", score: 80),
        ])
        XCTAssertEqual(resolution, .unique("/tmp/project/editor-notes.txt"))
    }

    func testResolveReturnsAmbiguousForCloseMatches() {
        let resolution = FuzzyPathResolver.resolve(query: "editor", ranked: [
            (candidate: "/tmp/project/FileEditorView.swift", score: 100),
            (candidate: "/tmp/project/EditorGuide.md", score: 95),
        ])
        XCTAssertEqual(resolution, .ambiguous([
            "/tmp/project/FileEditorView.swift",
            "/tmp/project/EditorGuide.md",
        ]))
    }

    // Nothing in the current project: a file in another recent project still resolves.
    func testResolveFallsBackToOtherRecentProjects() throws {
        // realpath: the enumerator reports /private/var/..., the temp URL says /var/...
        let tmp = try XCTUnwrap(realpath(FileManager.default.temporaryDirectory.path, nil))
        defer { free(tmp) }
        let base = URL(fileURLWithPath: String(cString: tmp)).appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: base) }
        let here = base.appendingPathComponent("kouen"), notes = base.appendingPathComponent("notes")
        try FileManager.default.createDirectory(at: here.appendingPathComponent("src"), withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: notes.appendingPathComponent("plans"), withIntermediateDirectories: true)
        try Data().write(to: here.appendingPathComponent("src/main.swift"))
        let plan = notes.appendingPathComponent("plans/p51-architecture.md")
        try Data().write(to: plan)

        XCTAssertEqual(FuzzyPathResolver.resolve(query: "p51-architecture.md", root: here.path, otherRoots: [notes.path]),
                       .unique(plan.path))
        XCTAssertEqual(FuzzyPathResolver.resolve(query: "p51-architecture.md", root: here.path, otherRoots: []), .none)
        // A local match wins; other projects are not consulted.
        XCTAssertEqual(FuzzyPathResolver.resolve(query: "main.swift", root: here.path, otherRoots: [notes.path]),
                       .unique(here.appendingPathComponent("src/main.swift").path))
    }

    // Agents print bare names that exist in every plan folder: the newest file is the one meant.
    func testNewestModifiedPicksTheMostRecentFile() throws {
        let base = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: base) }
        try FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        let old = base.appendingPathComponent("p57.md"), new = base.appendingPathComponent("p59.md")
        try Data().write(to: old); try Data().write(to: new)
        try FileManager.default.setAttributes([.modificationDate: Date(timeIntervalSinceNow: -3600)], ofItemAtPath: old.path)
        XCTAssertEqual(FuzzyPathResolver.newestModified([old.path, new.path]), new.path)
    }

    func testScannerFindsAgentMemoryFoldersAndSkipsWorktrees() throws {
        let tmp = try XCTUnwrap(realpath(FileManager.default.temporaryDirectory.path, nil))
        defer { free(tmp) }
        let base = URL(fileURLWithPath: String(cString: tmp)).appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: base) }
        let notes = base.appendingPathComponent("Personal/unified-memory-vault/memory-vault")
        try FileManager.default.createDirectory(at: notes.appendingPathComponent("kouen/plans"), withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: base.appendingPathComponent("Personal/app/.kouen-worktrees/x/agent-memory"), withIntermediateDirectories: true)
        let legacy = base.appendingPathComponent("Company/other/agent-memory")
        try FileManager.default.createDirectory(at: legacy, withIntermediateDirectories: true)
        try FileManager.default.createSymbolicLink(at: notes.deletingLastPathComponent().appendingPathComponent("agent-memory"),
                                                    withDestinationURL: notes)
        let note = notes.appendingPathComponent("kouen/plans/vault-smoke.md")
        try Data().write(to: note)
        let found = FileSearchRootScanner.scan(base: base).map { ($0 as NSString).resolvingSymlinksInPath }
        XCTAssertEqual(found, [legacy.path, notes.path].map { ($0 as NSString).resolvingSymlinksInPath }.sorted())
        let checkout = base.appendingPathComponent("Personal/app")
        guard case .unique(let match) = FuzzyPathResolver.resolve(
            query: "vault-smoke.md", root: checkout.path, otherRoots: found
        ) else { return XCTFail("Expected a unique file in the shared vault") }
        let matchedFile = try URL(fileURLWithPath: match).resourceValues(forKeys: [.fileResourceIdentifierKey])
        let expectedFile = try note.resourceValues(forKeys: [.fileResourceIdentifierKey])
        XCTAssertEqual(matchedFile.fileResourceIdentifier as? NSObject, expectedFile.fileResourceIdentifier as? NSObject)
    }

    func testResolveReturnsNoneForNoMatches() {
        XCTAssertEqual(FuzzyPathResolver.resolve(query: "missing", ranked: []), .none)
    }
}
