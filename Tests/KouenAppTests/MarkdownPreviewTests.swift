import XCTest
import AppKit
@testable import KouenApp
import KouenSyntaxResources

@MainActor
final class MarkdownPreviewTests: XCTestCase {
    func testBundledMarkdownScriptsExist() {
        XCTAssertNotNil(MarkdownBundle.resourceURL(filename: "purify.min.js"), "DOMPurify must be bundled")
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

    /// Regression guard for the 2026-09-15 blank-preview bug: a Swift `\n` (single backslash)
    /// inside the generateHTML `"""` template compiles to a real newline character, not the
    /// two-character JS escape — landing a raw line break inside a single-quoted JS string
    /// literal (`text.split('\n')`) breaks the whole inline `<script>` with a parse error, so
    /// `window.renderMarkdown` never gets defined and the pane silently renders nothing, with
    /// no error banner, no matter what markdown content is loaded. Swift-side visibility checks
    /// (`isShowingMarkdownPreview` etc.) stay green through this failure — only evaluating JS in
    /// the live webview catches it.
    func testRenderMarkdownIsDefinedAndActuallyRendersContent() throws {
        let view = MarkdownPreviewView(frame: NSRect(x: 0, y: 0, width: 600, height: 400))
        view.load(markdown: "# Hello\n\nSome **bold** text.", fileURL: nil)

        let expectation = expectation(description: "renderMarkdown produced content")
        // Poll briefly for the async WKWebView navigation to finish rather than a fixed sleep.
        func check(attemptsLeft: Int) {
            view.debugEvaluateJS(
                "JSON.stringify({fn: typeof window.renderMarkdown, len: (document.getElementById('content')||{}).innerHTML.length})"
            ) { result, _ in
                if let json = result as? String, json.contains("\"fn\":\"function\""), !json.contains("\"len\":0") {
                    expectation.fulfill()
                } else if attemptsLeft > 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { check(attemptsLeft: attemptsLeft - 1) }
                } else {
                    XCTFail("window.renderMarkdown never became defined / #content stayed empty; last diag: \(result ?? "nil")")
                    expectation.fulfill()
                }
            }
        }
        check(attemptsLeft: 25)
        wait(for: [expectation], timeout: 10)
    }

    private func assertJavaScript(_ expression: String, in view: MarkdownPreviewView,
                                  file: StaticString = #filePath, line: UInt = #line) {
        let ready = expectation(description: "Markdown DOM condition")
        let deadline = Date().addingTimeInterval(8)
        func check() {
            view.debugEvaluateJS(expression) { result, error in
                if result as? Bool == true {
                    ready.fulfill()
                } else if Date() < deadline {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { check() }
                } else {
                    view.debugEvaluateJS("JSON.stringify({text:document.body.innerText,images:[...document.images].map(i=>({src:i.src,width:i.naturalWidth})),svg:!!document.querySelector('.mermaid svg'),errors:window.__kouenBootErrors})") { diagnostic, _ in
                        XCTFail("DOM condition failed: \(expression); diagnostic=\(String(describing: diagnostic)), error=\(String(describing: error))", file: file, line: line)
                        ready.fulfill()
                    }
                }
            }
        }
        check()
        wait(for: [ready], timeout: 10)
    }

    func test_TC0401_FE_IT_UntrustedMarkdownCannotExecuteScript() {
        let view = MarkdownPreviewView(frame: NSRect(x: 0, y: 0, width: 600, height: 400))
        view.load(markdown: "# Security\n<img src=x onerror=\"window.__x=1\">\n<svg onload=\"window.__x=1\"></svg>\n<a href=\"javascript:window.__x=1\">unsafe</a>", fileURL: nil)
        assertJavaScript("document.querySelector('h1') !== null", in: view)
        assertJavaScript("typeof window.__x === 'undefined' && !document.querySelector('#content [onerror], #content [onload], #content a[href^=\"javascript:\"]')", in: view)
        view.update(markdown: "# Updated\n<img src=x onerror=\"window.__x=2\">")
        assertJavaScript("document.querySelector('h1')?.textContent === 'Updated' && typeof window.__x === 'undefined' && !document.querySelector('#content [onerror]')", in: view)
    }

    func test_TC0402_FE_IT_MermaidAndLocalImageStillRender() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        let bitmap = try XCTUnwrap(NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: 1, pixelsHigh: 1,
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .deviceRGB, bytesPerRow: 4, bitsPerPixel: 32))
        bitmap.setColor(.red, atX: 0, y: 0)
        let png = try XCTUnwrap(bitmap.representation(using: .png, properties: [:]))
        try png.write(to: dir.appendingPathComponent("pixel.png"))
        let view = MarkdownPreviewView(frame: NSRect(x: 0, y: 0, width: 600, height: 400))
        view.load(markdown: "# Regression\n![local](pixel.png)\n```mermaid\ngraph TD\n A[Start] --> B[End]\n```\n```swift\nlet x = 1\n```", fileURL: dir.appendingPathComponent("README.md"))
        assertJavaScript("document.querySelector('.mermaid svg') !== null && document.querySelector('img')?.naturalWidth === 1 && document.querySelector('.copy-btn') !== null", in: view)
        assertJavaScript("document.querySelector('meta[http-equiv=\"Content-Security-Policy\"]')?.content.includes(\"connect-src 'none'\") === true", in: view)
    }

    func test_TC0403_FE_UT_LocalImageReadsAreScopedToDocument() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let allowed = dir.appendingPathComponent("allowed")
        try FileManager.default.createDirectory(at: allowed, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        let outside = dir.appendingPathComponent("outside.png")
        try Data([0]).write(to: outside)
        let traversal = try XCTUnwrap(URL(string: "kouen-markdown://local" + outside.path))
        XCTAssertThrowsError(try MarkdownImageSchemeHandler.imageResource(for: traversal, directory: allowed)) {
            XCTAssertEqual(($0 as? URLError)?.code, .noPermissionsToReadFile)
        }
        try "secret".write(to: allowed.appendingPathComponent("secret.txt"), atomically: true, encoding: .utf8)
        let text = try XCTUnwrap(URL(string: "kouen-markdown://local" + allowed.appendingPathComponent("secret.txt").path))
        XCTAssertThrowsError(try MarkdownImageSchemeHandler.imageResource(for: text, directory: allowed))
        try FileManager.default.createSymbolicLink(at: allowed.appendingPathComponent("escape.png"), withDestinationURL: outside)
        let symlink = try XCTUnwrap(URL(string: "kouen-markdown://local" + allowed.appendingPathComponent("escape.png").path))
        XCTAssertThrowsError(try MarkdownImageSchemeHandler.imageResource(for: symlink, directory: allowed)) {
            XCTAssertEqual(($0 as? URLError)?.code, .noPermissionsToReadFile)
        }
    }

    func test_TC0404_FE_IT_CSPBlocksInjectedScriptsAndCopyStillResponds() {
        let view = MarkdownPreviewView(frame: NSRect(x: 0, y: 0, width: 600, height: 400))
        view.load(markdown: "```swift\nlet x = 1\n```", fileURL: nil)
        assertJavaScript("document.querySelector('.copy-btn') !== null", in: view)
        assertJavaScript("(() => { const s=document.createElement('script'); s.textContent='window.__cspBypass=1'; document.body.appendChild(s); return typeof window.__cspBypass === 'undefined'; })()", in: view)
        assertJavaScript("(() => { window.copyCode = () => { window.__copyClicked=true; }; document.querySelector('.copy-btn').click(); return window.__copyClicked === true; })()", in: view)
    }
}
