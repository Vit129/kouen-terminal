import XCTest
import AppKit
@testable import HarnessApp

/// Covers the syntax-highlighting keyword/comment cases added for Objective-C (.m/.mm),
/// C# (.cs), and Robot Framework (.robot/.resource) — languages that already got LSP support
/// but had no color coding, silently falling through `defaultKeywords`'s `default: return []`.
@MainActor
final class SyntaxHighlightTests: XCTestCase {
    private func colorAt(_ attributed: NSAttributedString, of substring: String, in text: String) -> NSColor? {
        guard let range = text.range(of: substring) else { return nil }
        let nsRange = NSRange(range, in: text)
        return attributed.attribute(.foregroundColor, at: nsRange.location, effectiveRange: nil) as? NSColor
    }

    func testObjectiveCKeywordIsHighlighted() {
        let text = "self.view = nil;"
        let attributed = SyntaxHighlighter.highlight(text, fileExtension: "m")
        XCTAssertEqual(colorAt(attributed, of: "self", in: text), NSColor.systemBlue)
    }

    func testObjectiveCPlusPlusCommentIsHighlighted() {
        let text = "// comment\nself.view = nil;"
        let attributed = SyntaxHighlighter.highlight(text, fileExtension: "mm")
        XCTAssertEqual(colorAt(attributed, of: "// comment", in: text), NSColor.systemGreen.withAlphaComponent(0.8))
    }

    func testCSharpKeywordIsHighlighted() {
        let text = "public class Foo {}"
        let attributed = SyntaxHighlighter.highlight(text, fileExtension: "cs")
        XCTAssertEqual(colorAt(attributed, of: "class", in: text), NSColor.systemBlue)
    }

    func testRobotFrameworkKeywordAndCommentAreHighlighted() {
        let text = "# setup\nLog    hello"
        let attributed = SyntaxHighlighter.highlight(text, fileExtension: "robot")
        XCTAssertEqual(colorAt(attributed, of: "Log", in: text), NSColor.systemBlue)
        XCTAssertEqual(colorAt(attributed, of: "# setup", in: text), NSColor.systemGreen.withAlphaComponent(0.8))
    }

    func testGherkinKeywordIsHighlighted() {
        let text = "Feature: Login\n  Scenario: Valid login\n    Given I am on the login page"
        let attributed = SyntaxHighlighter.highlight(text, fileExtension: "feature")
        XCTAssertEqual(colorAt(attributed, of: "Feature", in: text), NSColor.systemBlue)
        XCTAssertEqual(colorAt(attributed, of: "Given", in: text), NSColor.systemBlue)
    }
}
