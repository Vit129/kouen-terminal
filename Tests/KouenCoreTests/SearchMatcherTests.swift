import XCTest
@testable import KouenCore

final class SearchMatcherTests: XCTestCase {
    func testExactAndPrefixMatch() {
        let matcher = SearchMatcher(query: "package")
        let match1 = matcher.match(name: "Package.swift")
        XCTAssertNotNil(match1)
        XCTAssertEqual(match1?.category, .filenameStartsWith)

        let exact = SearchMatcher(query: "Package.swift")
        let match2 = exact.match(name: "Package.swift")
        XCTAssertEqual(match2?.category, .exactFilename)
    }

    func testTokenMatch() {
        let matcher = SearchMatcher(query: "agent scanner")
        let match = matcher.match(name: "AgentHistoryScanner.swift")
        XCTAssertNotNil(match)
        XCTAssertEqual(match?.category, .filenameContainsTokens)
    }

    func testContentMatchAndSnippetExtraction() {
        let matcher = SearchMatcher(query: "fatalError")
        let transcript = """
        User requested an agent review.
        Then the compiler raised fatalError while compiling KouenCore target.
        We resolved it by removing duplicate variable.
        """
        let match = matcher.match(
            name: "Review Session",
            relativePath: "Kouen",
            content: transcript
        )
        XCTAssertNotNil(match)
        XCTAssertEqual(match?.category, .contentContains)
        XCTAssertNotNil(match?.snippet)
        XCTAssertTrue(match!.snippet!.contains("fatalError"))
    }

    func testPathMatch() {
        let matcher = SearchMatcher(query: "Personal/kouen")
        let match = matcher.match(name: "App.swift", relativePath: "Personal/kouen-terminal/Apps")
        XCTAssertNotNil(match)
        XCTAssertEqual(match?.category, .pathContains)
    }

    func testFuzzyMatch() {
        let matcher = SearchMatcher(query: "flwtchr")
        let match = matcher.match(name: "FileTreeWatcher.swift")
        XCTAssertNotNil(match)
        XCTAssertEqual(match?.category, .fuzzy)
    }

    // MARK: - History Ranked Loose Search (Slice B)

    func testRankedHistoryMatchCrossField() {
        // "kouen happy" matches a record whose repo is kouen-terminal and chat contains happy
        let matcher = SearchMatcher(query: "kouen happy")
        let result = matcher.matchHistory(
            title: "General debugging session",
            branchFilesTools: "main",
            repoAgent: "kouen-terminal Claude",
            chatContent: "The user was very happy with the quick response."
        )
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.matchedTokensCount, 2)
        XCTAssertEqual(result?.highlightedTerms.count, 2)
        XCTAssertTrue(result?.highlightedTerms.contains("kouen") ?? false)
        XCTAssertTrue(result?.highlightedTerms.contains("happy") ?? false)
        XCTAssertNotNil(result?.snippet)
    }

    func testRankedHistoryMatchTypoTolerance() {
        // "brwser clse" matches "close browser pane" (1-edit typo tolerance for >= 4 chars)
        let matcher = SearchMatcher(query: "brwser clse")
        let result = matcher.matchHistory(
            title: "close browser pane",
            branchFilesTools: "feat/browser-close",
            repoAgent: "kouen-terminal Claude",
            chatContent: "Closed all agent browser panes."
        )
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.matchedTokensCount, 2)
    }

    func testRankedHistoryMatchPartialTokens() {
        // Query with one unmatched word ("auto") still matches if at least ceil(tokens/2) hit
        let matcher = SearchMatcher(query: "kouen close auto")
        // 3 tokens, ceil(3/2) = 2 required
        let result = matcher.matchHistory(
            title: "close browser pane",
            branchFilesTools: "feat/browser",
            repoAgent: "kouen-terminal Claude",
            chatContent: "Session finished"
        )
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.matchedTokensCount, 2)
        XCTAssertTrue(result?.highlightedTerms.contains("kouen") ?? false)
        XCTAssertTrue(result?.highlightedTerms.contains("close") ?? false)
        XCTAssertFalse(result?.highlightedTerms.contains("auto") ?? false)
    }

    func testRankedHistoryMatchFieldWeights() {
        // title (weight 3.0) scores higher than chat content (weight 1.0)
        let matcher = SearchMatcher(query: "refactor")
        let titleResult = matcher.matchHistory(
            title: "refactor auth logic",
            chatContent: "done"
        )
        let chatResult = matcher.matchHistory(
            title: "misc updates",
            chatContent: "we should refactor this later"
        )
        XCTAssertNotNil(titleResult)
        XCTAssertNotNil(chatResult)
        XCTAssertGreaterThan(titleResult!.score, chatResult!.score)
    }
}
