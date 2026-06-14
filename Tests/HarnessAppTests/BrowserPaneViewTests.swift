import AppKit
import XCTest
import WebKit
import HarnessCore
@testable import HarnessApp

@MainActor
final class BrowserPaneViewTests: XCTestCase {
    func testURLBarUpdatesOnCommitAndFinish() {
        let mockWebView = MockWebView(frame: .zero, configuration: WKWebViewConfiguration())
        let testURL = URL(string: "https://example.com/test")!
        mockWebView.mockURL = testURL

        let paneView = BrowserPaneView(url: testURL, paneID: UUID(), webView: mockWebView)

        // Simulating didCommit
        paneView.webView(mockWebView, didCommit: nil)
        // Verify URL text field matches testURL
        XCTAssertEqual(paneView.urlTextField.stringValue, "https://example.com/test")

        // Simulating didFinish
        let finishURL = URL(string: "https://example.com/finish")!
        mockWebView.mockURL = finishURL
        paneView.webView(mockWebView, didFinish: nil)
        XCTAssertEqual(paneView.urlTextField.stringValue, "https://example.com/finish")
    }
}

private final class MockWebView: WKWebView {
    var mockURL: URL?
    override var url: URL? {
        return mockURL
    }
}
