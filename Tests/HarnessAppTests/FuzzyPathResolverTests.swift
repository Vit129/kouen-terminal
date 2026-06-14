import XCTest
@testable import HarnessApp

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
            "/tmp/project/Apps/Harness/Sources/HarnessApp/UI/FileEditorView.swift",
            "/tmp/project/editor-notes.txt",
        ])
        XCTAssertEqual(ranked.first?.candidate, "/tmp/project/editor-notes.txt")
        XCTAssertTrue(ranked.contains { $0.candidate.hasSuffix("FileEditorView.swift") })
    }
}
