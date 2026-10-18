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
        var done: (() -> Void)?
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { done?(); done = nil }
    }

    func testReloadPicksUpEditedFileAndSiblingScript() async throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        let page = dir.appendingPathComponent("page.html"), js = dir.appendingPathComponent("app.js")
        try "<body>A<script src=\"app.js\"></script></body>".write(to: page, atomically: true, encoding: .utf8)
        try "document.body.append('1')".write(to: js, atomically: true, encoding: .utf8)

        let web = WKWebView(frame: .init(x: 0, y: 0, width: 300, height: 200))
        let nav = Nav(); web.navigationDelegate = nav
        func load(_ action: () -> Void) async {
            await withCheckedContinuation { (c: CheckedContinuation<Void, Never>) in nav.done = { c.resume() }; action() }
        }
        await load { web.loadFileURL(page, allowingReadAccessTo: dir) }
        let before = try await web.evaluateJavaScript("document.body.innerText") as? String
        XCTAssertEqual(before, "A1")

        try "<body>B<script src=\"app.js\"></script></body>".write(to: page, atomically: true, encoding: .utf8)
        try "document.body.append('2')".write(to: js, atomically: true, encoding: .utf8)
        await load { web.reload() }
        let after = try await web.evaluateJavaScript("document.body.innerText") as? String
        XCTAssertEqual(after, "B2")
    }
}
