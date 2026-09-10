import XCTest
import AppKit
@testable import KouenApp
import KouenSyntaxResources

@MainActor
final class MarkdownPreviewTests: XCTestCase {
    func testBundledMarkdownScriptsExist() {
        XCTAssertNotNil(MarkdownBundle.resourceURL(filename: "marked.min.js"), "marked.min.js must be bundled")
        XCTAssertNotNil(MarkdownBundle.resourceURL(filename: "mermaid.min.js"), "mermaid.min.js must be bundled")
        XCTAssertNotNil(MarkdownBundle.resourceURL(filename: "highlight.min.js"), "highlight.min.js must be bundled")

        let markedScript = MarkdownBundle.scriptString(filename: "marked.min.js")
        XCTAssertNotNil(markedScript)
        XCTAssertTrue(markedScript?.contains("marked") == true)

        let mermaidScript = MarkdownBundle.scriptString(filename: "mermaid.min.js")
        XCTAssertNotNil(mermaidScript)
        XCTAssertTrue(mermaidScript?.contains("mermaid") == true)
    }

    func testMarkdownPreviewViewInitialization() {
        let view = MarkdownPreviewView(frame: NSRect(x: 0, y: 0, width: 600, height: 400))
        XCTAssertNotNil(view)

        let testMarkdown = """
        # Kouen Markdown Test
        - [x] GFM Task list
        - [ ] Pending item

        | Col 1 | Col 2 |
        |---|---|
        | Foo | Bar |

        ```mermaid
        graph TD
            A[Start] --> B[Process]
            B --> C[End]
        ```

        ```swift
        let greeting = "Hello Kouen"
        ```
        """

        view.load(markdown: testMarkdown, fileURL: nil)
        view.update(markdown: "# Updated Title")
    }

    func testSidebarFileViewerUsesMarkdownPreviewForMarkdown() {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let mdFile = tempDir.appendingPathComponent("test.md")
        try? "# Hello Sidebar".write(to: mdFile, atomically: true, encoding: .utf8)

        let vc = FileViewerViewController()
        _ = vc.view
        vc.load(path: mdFile.path)

        // Toggle to edit mode
        vc.toggleMarkdownMode()
        // Toggle back
        vc.toggleMarkdownMode()
    }

    func testCodeExtensionsRecognition() {
        XCTAssertTrue(MarkdownPreviewView.isSupportedCodeExtension("swift"))
        XCTAssertTrue(MarkdownPreviewView.isSupportedCodeExtension("py"))
        XCTAssertTrue(MarkdownPreviewView.isSupportedCodeExtension("ts"))
        XCTAssertTrue(MarkdownPreviewView.isSupportedCodeExtension("json"))
        XCTAssertTrue(MarkdownPreviewView.isSupportedCodeExtension("yaml"))
        XCTAssertFalse(MarkdownPreviewView.isSupportedCodeExtension("unknown_ext"))

        XCTAssertTrue(MarkdownPreviewView.isRichPreviewExtension("md"))
        XCTAssertTrue(MarkdownPreviewView.isRichPreviewExtension("markdown"))
        XCTAssertTrue(MarkdownPreviewView.isRichPreviewExtension("mermaid"))
        XCTAssertTrue(MarkdownPreviewView.isRichPreviewExtension("mmd"))
        XCTAssertFalse(MarkdownPreviewView.isRichPreviewExtension("swift"))
        XCTAssertFalse(MarkdownPreviewView.isRichPreviewExtension("py"))
        XCTAssertFalse(MarkdownPreviewView.isRichPreviewExtension("pdf"))
        XCTAssertFalse(MarkdownPreviewView.isRichPreviewExtension("png"))
    }

    func testLoadCodeFileInMarkdownPreview() {
        let view = MarkdownPreviewView(frame: NSRect(x: 0, y: 0, width: 600, height: 400))
        let code = """
        import Foundation

        struct User: Codable {
            let id: Int
            let name: String
        }
        """
        view.load(markdown: code, fileURL: URL(fileURLWithPath: "/tmp/User.swift"))
        view.update(markdown: code + "\n// updated")
    }

    func testMarkdownPreviewRendersContent() async throws {
        let view = MarkdownPreviewView(frame: NSRect(x: 0, y: 0, width: 600, height: 400))
        let sampleMarkdown = """
        # New Machine Setup
        First-time installation checklist.
        ```bash
        brew install git
        ```
        """
        view.load(markdown: sampleMarkdown, fileURL: URL(fileURLWithPath: "/tmp/sample.md"))

        var renderedHTML: String?
        for _ in 0..<30 {
            try await Task.sleep(nanoseconds: 100_000_000)
            if let content = try? await view.webView.evaluateJavaScript("document.getElementById('content')?.innerHTML") as? String, !content.isEmpty {
                renderedHTML = content
                break
            }
        }

        let errorsCount = try? await view.webView.evaluateJavaScript("window.__errors ? window.__errors.length : 0") as? Int
        XCTAssertEqual(errorsCount, 0, "Expected no JavaScript runtime errors")
        XCTAssertNotNil(renderedHTML, "Expected rendered content but it was nil/empty")
        XCTAssertTrue(renderedHTML?.contains("New Machine Setup") == true)
        XCTAssertTrue(renderedHTML?.contains("language-bash") == true)
    }
}
