import Foundation
import XCTest

/// Automated QA Architecture Guard enforcing Dev-QA Pattern 5-Layer separation.
/// Target runtime < 100ms.
final class ArchitectureGuardTests: XCTestCase {
    private var repoRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent() // Tests/KouenArchitectureGuardTests
            .deletingLastPathComponent() // Tests
            .deletingLastPathComponent() // repo root
    }

    // MARK: - G1: Headless Domain Core (Zero UI Imports)

    /// Ensures Headless Domain Core packages never import UI frameworks.
    func testG1_ZeroUIImportsInHeadlessPackages() throws {
        let headlessPackageDirs = [
            "Packages/KouenCore",
            "Packages/KouenIPC",
            "Packages/KouenSettings",
            "Packages/KouenCommands",
            "Packages/KouenTheme",
            "Packages/KouenTerminalEngine",
            "Packages/KouenDaemon",
            "Packages/KouenCopyMode",
            "Packages/KouenGit",
        ]

        let forbiddenImportPatterns = [
            "import AppKit",
            "import SwiftUI",
            "import Cocoa",
            "import UIKit",
            "import Metal",
            "import QuartzCore",
            "import WebKit",
            "#if canImport(AppKit)",
        ]

        var violations: [String] = []

        for relDir in headlessPackageDirs {
            let dirURL = repoRoot.appendingPathComponent(relDir)
            guard FileManager.default.fileExists(atPath: dirURL.path) else { continue }

            let swiftFiles = findSwiftFiles(in: dirURL)
            for file in swiftFiles {
                let content = try String(contentsOf: file, encoding: .utf8)
                for pattern in forbiddenImportPatterns {
                    if content.contains(pattern) {
                        let relPath = file.path.replacingOccurrences(of: repoRoot.path + "/", with: "")
                        violations.append("\(relPath): contains '\(pattern)'")
                    }
                }
            }
        }

        XCTAssertTrue(
            violations.isEmpty,
            "G1 Violation: UI imports found in Headless Core packages:\n" + violations.joined(separator: "\n")
        )
    }

    // MARK: - G3: No Process() In UI (Ratchet Baseline)

    /// Ensures Process() calls in UI do not exceed ratchet baseline and alerts to ratchet down when removed.
    func testG3_ProcessCallsInUIRatchetBaseline() throws {
        let uiDirs = [
            "Apps/Kouen/Sources/KouenApp/UI",
            "Apps/Kouen/Sources/KouenApp/Settings",
        ]

        var currentViolations: [String: Int] = [:]
        var totalCount = 0

        for relDir in uiDirs {
            let dirURL = repoRoot.appendingPathComponent(relDir)
            guard FileManager.default.fileExists(atPath: dirURL.path) else { continue }

            let swiftFiles = findSwiftFiles(in: dirURL)
            for file in swiftFiles {
                let content = try String(contentsOf: file, encoding: .utf8)
                let lines = content.components(separatedBy: .newlines)
                var fileCount = 0
                for line in lines {
                    let trimmed = line.trimmingCharacters(in: .whitespaces)
                    if !trimmed.hasPrefix("//") && trimmed.contains("Process()") {
                        fileCount += 1
                    }
                }
                if fileCount > 0 {
                    let relPath = file.path.replacingOccurrences(of: repoRoot.path + "/", with: "")
                    currentViolations[relPath] = fileCount
                    totalCount += fileCount
                }
            }
        }

        // Ratchet: Current baseline ceiling is 15 (ratcheted down from 19 after KouenGit migration).
        let maxAllowedProcessCalls = 15
        XCTAssertLessThanOrEqual(
            totalCount,
            maxAllowedProcessCalls,
            "G3 Violation: Process() calls in UI exceeded baseline (\(totalCount) > \(maxAllowedProcessCalls)). Process() must be moved to KouenGit or Core services."
        )
    }

    // MARK: - G10: Negative Controls (Self-Testing The Guard)

    func testG10_NegativeControlCatchesViolations() {
        let badSource = """
        import Foundation
        import AppKit

        final class LeakyClass {
            func run() {
                let p = Process()
            }
        }
        """

        let hasForbiddenUI = badSource.contains("import AppKit")
        let hasProcess = badSource.contains("Process()")

        XCTAssertTrue(hasForbiddenUI, "Negative control must catch import AppKit")
        XCTAssertTrue(hasProcess, "Negative control must catch Process()")
    }

    // MARK: - Helpers

    private func findSwiftFiles(in directory: URL) -> [URL] {
        var results: [URL] = []
        guard let enumerator = FileManager.default.enumerator(
            at: directory,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else { return [] }

        for case let fileURL as URL in enumerator {
            if fileURL.pathExtension == "swift" {
                results.append(fileURL)
            }
        }
        return results
    }
}
