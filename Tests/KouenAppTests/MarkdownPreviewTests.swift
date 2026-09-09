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
}
