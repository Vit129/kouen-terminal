import AppKit
import WebKit
import XCTest
@testable import KouenApp

/// Black or stale tabs: one pane holds several web views, so a compositor kick for one tab
/// must not disturb another, and a tab switch must repaint again once layout has settled.
@MainActor
final class BrowserTabRepaintTests: XCTestCase {
    private func settle(_ seconds: TimeInterval = 0.2) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    func testConcurrentKicksRestoreEveryTabsMagnification() {
        let first = WKWebView(frame: NSRect(x: 0, y: 0, width: 400, height: 300), configuration: WKWebViewConfiguration())
        first.allowsMagnification = true
        let pane = BrowserPaneView(url: URL(string: "about:blank")!, paneID: UUID(), webView: first)
        let second = pane.createTab(url: URL(string: "about:blank")!, skipLoad: true)
        settle()

        // A background tab finishing its load lands between the kick and its restore.
        pane.webView(first, didFinish: nil)
        pane.webView(second, didFinish: nil)
        settle()

        XCTAssertEqual(first.magnification, 1, accuracy: 0.001, "the first tab's kick was never restored")
        XCTAssertEqual(second.magnification, 1, accuracy: 0.001)
    }

    func testSelectTabRepaintsAgainAfterLayoutSettles() {
        let first = RepaintCountingWebView(frame: NSRect(x: 0, y: 0, width: 400, height: 300), configuration: WKWebViewConfiguration())
        first.allowsMagnification = true
        let pane = BrowserPaneView(url: URL(string: "about:blank")!, paneID: UUID(), webView: first)
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 400, height: 300), styleMask: [.titled], backing: .buffered, defer: false)
        pane.frame = NSRect(x: 0, y: 0, width: 400, height: 300)
        window.contentView?.addSubview(pane)
        pane.createTab(url: URL(string: "about:blank")!, skipLoad: true)
        settle()

        first.repaintScripts = 0
        pane.selectTab(at: 0)
        let duringSwitch = first.repaintScripts
        settle()

        XCTAssertGreaterThan(first.repaintScripts, duringSwitch, "no repaint after the swap's layout pass")
    }
}

private final class RepaintCountingWebView: WKWebView {
    var repaintScripts = 0
    override func evaluateJavaScript(_ javaScriptString: String, completionHandler: (@MainActor @Sendable (Any?, (any Error)?) -> Void)? = nil) {
        if javaScriptString == "void(0)" { repaintScripts += 1 }
        completionHandler?(nil, nil)
    }
}

/// macOS can report a window the user is looking at as occluded. WebKit then marks the page
/// hidden and stops painting, which shows as a black pane that repaint nudges cannot wake.
@MainActor
final class BrowserOcclusionTests: XCTestCase {
    private func detectsOcclusion(_ webView: WKWebView) -> Bool? {
        webView.value(forKey: "_windowOcclusionDetectionEnabled") as? Bool
    }

    func testEveryTabIgnoresWindowOcclusion() {
        let first = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        XCTAssertEqual(detectsOcclusion(first), true, "WebKit no longer exposes the occlusion switch")
        let pane = BrowserPaneView(url: URL(string: "about:blank")!, paneID: UUID(), webView: first)
        let second = pane.createTab(url: URL(string: "about:blank")!, skipLoad: true)

        XCTAssertEqual(detectsOcclusion(first), false)
        XCTAssertEqual(detectsOcclusion(second), false)
    }
}
