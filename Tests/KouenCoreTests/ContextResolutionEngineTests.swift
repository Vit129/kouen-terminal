import Foundation
@testable import KouenCore
import XCTest

final class ContextResolutionEngineTests: XCTestCase {
    func testTokenGuardFiltersLockfiles() {
        XCTAssertTrue(TokenGuard.shouldIgnore(path: "package-lock.json"))
        XCTAssertTrue(TokenGuard.shouldIgnore(path: "subfolder/Cargo.lock"))
        XCTAssertTrue(TokenGuard.shouldIgnore(path: "project.pbxproj"))
        XCTAssertFalse(TokenGuard.shouldIgnore(path: "App.swift"))
        XCTAssertFalse(TokenGuard.shouldIgnore(path: "index.ts"))
    }

    func testTokenGuardSanitizeDiffOmitsLockfiles() {
        let diffWithLockfile = """
        diff --git a/src/index.ts b/src/index.ts
        +console.log("hello");
        diff --git a/package-lock.json b/package-lock.json
        +  "version": "1.0.0"
        diff --git a/README.md b/README.md
        +# Project
        """

        let sanitized = TokenGuard.sanitizeDiff(diffWithLockfile)
        XCTAssertTrue(sanitized.contains("src/index.ts"))
        XCTAssertTrue(sanitized.contains("README.md"))
        XCTAssertFalse(sanitized.contains("package-lock.json"))
        XCTAssertTrue(sanitized.contains("<!-- TokenGuard: Filtered 1 generated/lockfile(s) -->"))
    }

    func testTokenGuardTruncatesLongOutput() {
        let lines = (1...600).map { "line \($0)" }.joined(separator: "\n")
        let diff = "diff --git a/file.txt b/file.txt\n" + lines
        let truncated = TokenGuard.sanitizeDiff(diff, maxLines: 50)
        XCTAssertTrue(truncated.contains("TokenGuard: Truncated"))
    }

    func testContextResolutionEngineResolvesFile() {
        let engine = ContextResolutionEngine()
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let sampleFile = tempDir.appendingPathComponent("test.txt")
        try? "hello world from test".write(to: sampleFile, atomically: true, encoding: .utf8)

        let result = engine.resolveFile(path: "test.txt", cwd: tempDir.path)
        XCTAssertTrue(result.contains("### File: test.txt"))
        XCTAssertTrue(result.contains("hello world from test"))
    }

    func testContextResolutionEngineResolvesTemplate() async {
        let engine = ContextResolutionEngine()
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let sampleFile = tempDir.appendingPathComponent("main.swift")
        try? "print(42)".write(to: sampleFile, atomically: true, encoding: .utf8)

        let template = "Explain this code: @file:main.swift please"
        let resolved = await engine.resolveTemplate(template, cwd: tempDir.path)
        XCTAssertTrue(resolved.contains("Explain this code:"))
        XCTAssertTrue(resolved.contains("### File: main.swift"))
        XCTAssertTrue(resolved.contains("print(42)"))
    }
}
