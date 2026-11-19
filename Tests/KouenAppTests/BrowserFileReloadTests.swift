import AppKit
import XCTest
import WebKit
@testable import KouenApp

/// A browser pane showing a local `file://` page must pick up edits on reload. ⌘R / ⌘⇧R did
/// nothing (no handler: WKWebView has none and Kouen's menu doesn't claim ⌘R).
@MainActor
final class BrowserFileReloadTests: XCTestCase {
    private final class CountingWebView: WKWebView {
        var reloads = 0, originReloads = 0
        override func reload() -> WKNavigation? { reloads += 1; return nil }
        override func reloadFromOrigin() -> WKNavigation? { originReloads += 1; return nil }
    }

    private func key(_ chars: String, _ flags: NSEvent.ModifierFlags) -> NSEvent {
        NSEvent.keyEvent(with: .keyDown, location: .zero, modifierFlags: flags, timestamp: 0, windowNumber: 0,
                         context: nil, characters: chars, charactersIgnoringModifiers: chars, isARepeat: false, keyCode: 15)!
    }

    func testCmdRReloadsAndCmdShiftRReloadsFromOrigin() {
        let web = CountingWebView(frame: .zero, configuration: WKWebViewConfiguration())
        let pane = BrowserPaneView(url: URL(fileURLWithPath: "/tmp/x.html"), paneID: UUID(), webView: web)
        XCTAssertTrue(pane.performKeyEquivalent(with: key("r", [.command])))
        XCTAssertTrue(pane.performKeyEquivalent(with: key("R", [.command, .shift])))
        XCTAssertEqual(web.reloads, 1)
        XCTAssertEqual(web.originReloads, 1)
    }

    // Guard for the other half of the report: WebKit re-reads an edited file:// page and its
    // sibling script on a plain reload, so a stale page after reload is not a cache problem.
    private final class Nav: NSObject, WKNavigationDelegate {
        var done: ((Error?) -> Void)?

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            complete()
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            complete(error)
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            complete(error)
        }

        private func complete(_ error: Error? = nil) {
            let callback = done
            done = nil
            callback?(error)
        }
    }

    func testReloadPicksUpEditedFileAndSiblingScript() async throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        let page = dir.appendingPathComponent("page.html"), js = dir.appendingPathComponent("app.js")
        try "<body>A<script src=\"app.js\"></script></body>".write(to: page, atomically: true, encoding: .utf8)
        try "document.body.append('1')".write(to: js, atomically: true, encoding: .utf8)

        let frame = NSRect(x: 0, y: 0, width: 300, height: 200)
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .nonPersistent()
        let web = WKWebView(frame: frame, configuration: configuration)
        let window = NSWindow(contentRect: frame, styleMask: [.titled], backing: .buffered, defer: false)
        window.contentView = web
        defer { window.contentView = nil }
        let nav = Nav()
        web.navigationDelegate = nav
        func load(_ action: () -> Void) async throws {
            let completed = XCTestExpectation(description: "WebKit navigation completes")
            var navigationError: Error?
            nav.done = { error in
                navigationError = error
                completed.fulfill()
            }
            defer { nav.done = nil }
            action()
            guard await XCTWaiter.fulfillment(of: [completed], timeout: 5) == .completed else {
                throw URLError(.timedOut)
            }
            if let navigationError { throw navigationError }
        }
        try await load { web.loadFileURL(page, allowingReadAccessTo: dir) }
        let before = try await web.evaluateJavaScript("document.body.innerText") as? String
        XCTAssertEqual(before, "A1")

        try "<body>B<script src=\"app.js\"></script></body>".write(to: page, atomically: true, encoding: .utf8)
        try "document.body.append('2')".write(to: js, atomically: true, encoding: .utf8)
        try await load { web.reload() }
        let after = try await web.evaluateJavaScript("document.body.innerText") as? String
        XCTAssertEqual(after, "B2")
    }
}
