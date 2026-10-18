import XCTest
import Foundation
@testable import KouenApp

@MainActor
final class WorkspaceSymbolIndexTests: XCTestCase {
    func testCurrentFileSymbolsAndCompletions() {
        let index = WorkspaceSymbolIndex()
        let content = """
        func calculateTotalSum() -> Int {
            let calculationResult = 42
            return calculationResult
        }
        """
        index.updateCurrentFileSymbols(text: content)

        let completions = index.completions(prefix: "calc")
        XCTAssertTrue(completions.contains("calculateTotalSum"))
        XCTAssertTrue(completions.contains("calculationResult"))

        // Exact match should be excluded
        let exact = index.completions(prefix: "calculateTotalSum")
        XCTAssertFalse(exact.contains("calculateTotalSum"))
    }

    func testScanWorkspaceDirectory() async throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }

        let swiftFile = tempDir.appendingPathComponent("TestService.swift")
        let code = """
        class TestService {
            func processOrder() {}
            var activeSessionCount: Int = 0
        }
        """
        try code.write(to: swiftFile, atomically: true, encoding: .utf8)

        let index = WorkspaceSymbolIndex()
        index.scan(root: tempDir.path)
        _ = await index.scanTask?.value

        XCTAssertTrue(index.symbols.contains("TestService"))
        XCTAssertTrue(index.symbols.contains("processOrder"))
        XCTAssertTrue(index.symbols.contains("activeSessionCount"))

        let completions = index.completions(prefix: "proc")
        XCTAssertEqual(completions, ["processOrder"])
    }
}
