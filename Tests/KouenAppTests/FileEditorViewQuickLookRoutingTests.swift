import XCTest
import AppKit
@testable import KouenApp

/// Regression guard: `.md`/`.markdown` must use the same syntax-highlighted text view as
/// `.swift`/`.json`, not Quick Look. Quick Look is a separate renderer that doesn't wire
/// into this app's Edit > Copy / Cmd+F — a file routed there silently loses both.
@MainActor
final class FileEditorViewQuickLookRoutingTests: XCTestCase {
    private var tempDir: URL!

    override func setUp() async throws {
        try await super.setUp()
        tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    }

    override func tearDown() async throws {
        try? FileManager.default.removeItem(at: tempDir)
        try await super.tearDown()
    }

    private func writeFile(named name: String, contents: String = "hello") -> String {
        let url = tempDir.appendingPathComponent(name)
        try? contents.write(to: url, atomically: true, encoding: .utf8)
        return url.path
    }

    func testMarkdownUsesMarkdownPreviewAndCanToggleToSyntaxView() {
        let view = FileEditorView(frame: NSRect(x: 0, y: 0, width: 400, height: 400))
        view.load(path: writeFile(named: "notes.md", contents: "# Test\n```mermaid\ngraph TD\nA-->B\n```"))
        XCTAssertTrue(view.isShowingMarkdownPreview, ".md must use MarkdownPreviewView by default")
        XCTAssertFalse(view.isShowingQuickLook, ".md must not use Quick Look")

        // Toggle to edit mode
        view.toggleMarkdownMode()
        XCTAssertTrue(view.isShowingSyntaxView, "In edit mode, .md must use syntax text view")
        XCTAssertFalse(view.isShowingMarkdownPreview, "In edit mode, markdown preview is hidden")

        // Toggle back to preview mode
        view.toggleMarkdownMode()
        XCTAssertTrue(view.isShowingMarkdownPreview, "Toggling back returns to markdown preview")
        XCTAssertFalse(view.isShowingSyntaxView, "Syntax text view is hidden in preview mode")
    }

    func testSwiftUsesSyntaxViewDirectly() {
        let view = FileEditorView(frame: NSRect(x: 0, y: 0, width: 400, height: 400))
        view.load(path: writeFile(named: "main.swift", contents: "import Foundation\nprint(\"Hello Kouen\")"))
        XCTAssertTrue(view.isShowingSyntaxView, ".swift must use syntax text view directly")
        XCTAssertFalse(view.isShowingMarkdownPreview, ".swift must not use MarkdownPreviewView")
        XCTAssertFalse(view.isShowingQuickLook, ".swift must not use Quick Look")
    }

    func testPDFStillUsesQuickLook() {
        let view = FileEditorView(frame: NSRect(x: 0, y: 0, width: 400, height: 400))
        view.load(path: writeFile(named: "doc.pdf"))
        XCTAssertFalse(view.isShowingSyntaxView, ".pdf is binary — Quick Look is still correct here")
    }
}
