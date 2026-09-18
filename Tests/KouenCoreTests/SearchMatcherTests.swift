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
}
