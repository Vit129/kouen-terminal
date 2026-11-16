import XCTest
import AppKit
import WebKit
@testable import KouenApp

@MainActor
final class FilePreviewReleaseTests: XCTestCase {
    func test_TS_2342_FE_UT_dirtyDetectsSameLengthEditAndRevert() {
        let view = SyntaxTextView(frame: NSRect(x: 0, y: 0, width: 400, height: 400))
        view.load(text: "hello world", fileExtension: "txt")
        view.debugSetText("hello_world")          // same UTF-16 length, different content
        XCTAssertTrue(view.isDirty)
        view.debugSetText("hello world!")         // length fast path
        XCTAssertTrue(view.isDirty)
        view.debugSetText("hello world")
        XCTAssertFalse(view.isDirty)
    }

    func test_TS_2343_FE_UT_markdownReleaseDropsWebViewAndUpdateRecreatesIt() {
        let view = MarkdownPreviewView(frame: NSRect(x: 0, y: 0, width: 600, height: 400))
        view.load(markdown: "# hi", fileURL: nil)
        XCTAssertTrue(view.subviews.contains { $0 is WKWebView })
        view.releaseWebView()
        XCTAssertFalse(view.subviews.contains { $0 is WKWebView })
        view.update(markdown: "# again")          // must reload, not silently render nothing
        XCTAssertTrue(view.subviews.contains { $0 is WKWebView })
    }
}
