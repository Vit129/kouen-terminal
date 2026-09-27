import XCTest
@testable import KouenApp

@MainActor
final class SyntaxLineIndexTests: XCTestCase {
    func testLineNumberTracksEdits() {
        let view = SyntaxTextViewInner()
        view.string = "a\nbb\n\nccc"
        XCTAssertEqual(view.lineNumber(at: 0), 1)
        XCTAssertEqual(view.lineNumber(at: 2), 2)
        XCTAssertEqual(view.lineNumber(at: 5), 3)
        XCTAssertEqual(view.lineNumber(at: 6), 4)
        view.textStorage?.replaceCharacters(in: NSRange(location: 0, length: 0), with: "x\n")
        XCTAssertEqual(view.lineNumber(at: 6), 3) // cache invalidated by the edit
    }
}
