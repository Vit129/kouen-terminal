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

    func testMarkdownUsesSyntaxViewNotQuickLook() {
        let view = FileEditorView(frame: NSRect(x: 0, y: 0, width: 400, height: 400))
        view.load(path: writeFile(named: "notes.md"))
        XCTAssertTrue(view.isShowingSyntaxView, ".md must use the syntax text view, not Quick Look")
    }

    func testSwiftUsesSyntaxView() {
        let view = FileEditorView(frame: NSRect(x: 0, y: 0, width: 400, height: 400))
        view.load(path: writeFile(named: "main.swift"))
        XCTAssertTrue(view.isShowingSyntaxView)
    }

    func testPDFStillUsesQuickLook() {
        let view = FileEditorView(frame: NSRect(x: 0, y: 0, width: 400, height: 400))
        view.load(path: writeFile(named: "doc.pdf"))
        XCTAssertFalse(view.isShowingSyntaxView, ".pdf is binary — Quick Look is still correct here")
    }
}
