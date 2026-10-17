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

    func testResolveReturnsNoneForNoMatches() {
        XCTAssertEqual(FuzzyPathResolver.resolve(query: "missing", ranked: []), .none)
    }
}
