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
        XCTAssertTrue(MarkdownPreviewView.isSupportedCodeExtension("dart"))
        for sqlDialectExt in ["sql", "pgsql", "psql", "mysql", "plsql", "pls"] {
            XCTAssertEqual(MarkdownPreviewView.codeExtensionToLanguage[sqlDialectExt], "sql", sqlDialectExt)
        }
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

    func testWrapContentIfNeededFencesSupportedCodeExtensionsWithLanguage() {
        let wrapped = MarkdownPreviewView.wrapContentIfNeeded(
            "let x = 1", fileURL: URL(fileURLWithPath: "/tmp/main.swift"))
        XCTAssertEqual(wrapped, "```swift\nlet x = 1\n```")
    }

    func testWrapContentIfNeededFencesDartFiles() {
        let wrapped = MarkdownPreviewView.wrapContentIfNeeded(
            "void main() {}", fileURL: URL(fileURLWithPath: "/tmp/main.dart"))
        XCTAssertEqual(wrapped, "```dart\nvoid main() {}\n```")
    }

    func testWrapContentIfNeededFencesBareDockerfileByName() {
        // "Dockerfile" has no extension — must be recognized by filename, not `pathExtension`.
        let wrapped = MarkdownPreviewView.wrapContentIfNeeded(
            "FROM alpine", fileURL: URL(fileURLWithPath: "/tmp/Dockerfile"))
        XCTAssertEqual(wrapped, "```dockerfile\nFROM alpine\n```")
    }

    func testWrapContentIfNeededFencesDockerfileVariants() {
        let wrapped = MarkdownPreviewView.wrapContentIfNeeded(
            "FROM alpine", fileURL: URL(fileURLWithPath: "/tmp/Dockerfile.prod"))
        XCTAssertEqual(wrapped, "```dockerfile\nFROM alpine\n```")
    }

    func testLanguageForFileRecognizesBareDockerfileCaseInsensitively() {
        XCTAssertEqual(MarkdownPreviewView.language(forFile: URL(fileURLWithPath: "/tmp/dockerfile")), "dockerfile")
        XCTAssertEqual(MarkdownPreviewView.language(forFile: URL(fileURLWithPath: "/tmp/DOCKERFILE")), "dockerfile")
        XCTAssertTrue(MarkdownPreviewView.isSupportedCodeFile(URL(fileURLWithPath: "/tmp/Dockerfile")))
        XCTAssertTrue(MarkdownPreviewView.isSupportedCodeFile(URL(fileURLWithPath: "/tmp/app.dart")))
    }

    func testWrapContentIfNeededLeavesUnsupportedExtensionsUnwrapped() {
        let raw = "some binary-ish content"
        let wrapped = MarkdownPreviewView.wrapContentIfNeeded(
            raw, fileURL: URL(fileURLWithPath: "/tmp/file.unknown_ext"))
        XCTAssertEqual(wrapped, raw)
    }

    func testWrapContentIfNeededWidensFenceAroundEmbeddedBackticks() {
        let code = "print(\"```\")"
        let wrapped = MarkdownPreviewView.wrapContentIfNeeded(
            code, fileURL: URL(fileURLWithPath: "/tmp/main.py"))
        XCTAssertEqual(wrapped, "````python\n\(code)\n````")
    }
}
