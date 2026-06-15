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

    func testRemovePaneNodeCollapsesBranch() {
        let coordinator = SessionCoordinator.shared.splitPaneCoordinator
        let firstBrowserID = UUID()
        let secondBrowserID = UUID()
        let termLeaf = PaneLeaf()

        // Test split: [ firstBrowser | [ secondBrowser | termLeaf ] ]
        let innerBranch = PaneNode.branch(
            direction: .vertical,
            ratio: 0.5,
            first: .browser(BrowserLeaf(id: secondBrowserID, url: URL(string: "https://example.com/2")!)),
            second: .leaf(termLeaf)
        )

        var root = PaneNode.branch(
            direction: .horizontal,
            ratio: 0.5,
            first: .browser(BrowserLeaf(id: firstBrowserID, url: URL(string: "https://example.com/1")!)),
            second: innerBranch
        )

        // 1. Remove secondBrowserID, should collapse innerBranch to just termLeaf
        let removedSecond = coordinator.removePaneNode(paneID: secondBrowserID, from: &root)
        XCTAssertTrue(removedSecond)

        // Verify root is now: [ firstBrowser | termLeaf ]
        guard case let .branch(_, _, firstNode, secondNode) = root else {
            XCTFail("Root should still be a branch after nested collapse")
            return
        }
        XCTAssertEqual(firstNode.paneID, firstBrowserID)
        XCTAssertEqual(secondNode.paneID, termLeaf.id)

        // 2. Remove firstBrowserID, should collapse the whole tree to just termLeaf
        let removedFirst = coordinator.removePaneNode(paneID: firstBrowserID, from: &root)
        XCTAssertTrue(removedFirst)
        XCTAssertEqual(root.paneID, termLeaf.id)
    }
}

private final class MockWebView: WKWebView {
    var mockURL: URL?
    override var url: URL? {
        return mockURL
    }
}
