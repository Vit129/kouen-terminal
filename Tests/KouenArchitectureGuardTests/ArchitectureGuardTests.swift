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
            "Packages/KouenCompositor",
        ]

        var violations: [String] = []

        for relDir in headlessPackageDirs {
            let dirURL = repoRoot.appendingPathComponent(relDir)
            guard FileManager.default.fileExists(atPath: dirURL.path) else { continue }
            let swiftFiles = findSwiftFiles(in: dirURL)
            violations.append(contentsOf: try scanUIImportViolations(in: swiftFiles))
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

        var totalCount = 0

        for relDir in uiDirs {
            let dirURL = repoRoot.appendingPathComponent(relDir)
            guard FileManager.default.fileExists(atPath: dirURL.path) else { continue }
            let swiftFiles = findSwiftFiles(in: dirURL)
            totalCount += try countProcessCalls(in: swiftFiles)
        }

        // Ratchet: Current baseline ceiling is 12 (ratcheted down from 19 after KouenGit migration).
        let maxAllowedProcessCalls = 12
        XCTAssertLessThanOrEqual(
            totalCount,
            maxAllowedProcessCalls,
            "G3 Violation: Process() calls in UI exceeded baseline (\(totalCount) > \(maxAllowedProcessCalls)). Process() must be moved to KouenGit or Core services."
        )
    }

    // MARK: - G7: Zero Cross-Package File Duplication

    func testG7_ZeroCrossPackageFileDuplication() throws {
        let packagesURL = repoRoot.appendingPathComponent("Packages")
        guard FileManager.default.fileExists(atPath: packagesURL.path) else { return }

        let swiftFiles = findSwiftFiles(in: packagesURL)
        var filesByName: [String: [String]] = [:]

        for file in swiftFiles {
            let filename = file.lastPathComponent
            let relPath = file.path.replacingOccurrences(of: repoRoot.path + "/", with: "")
            filesByName[filename, default: []].append(relPath)
        }

        var duplicates: [String: [String]] = [:]
        for (name, paths) in filesByName where paths.count > 1 {
            duplicates[name] = paths
        }

        XCTAssertTrue(
            duplicates.isEmpty,
            "G7 Violation: Duplicate Swift filenames found across Packages/. Each package must own unique modules without copy-pasting:\n" +
            duplicates.map { "\($0.key): \($0.value.joined(separator: ", "))" }.joined(separator: "\n")
        )
    }


    // MARK: - G10: Negative Controls (Self-Testing The Guard)

    func testG10_NegativeControlCatchesViolations() throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let badSource = """
        import Foundation
        import AppKit

        final class LeakyClass {
            // Process() in comment should be ignored
            func run() {
                let p = Process()
            }
        }
        """
        let badFile = tempDir.appendingPathComponent("BadFile.swift")
        try badSource.write(to: badFile, atomically: true, encoding: .utf8)

        let caughtViolations = try scanUIImportViolations(in: [badFile])
        let caughtProcessCount = try countProcessCalls(in: [badFile])

        XCTAssertFalse(caughtViolations.isEmpty, "Negative control must catch import AppKit using real scanner")
        XCTAssertEqual(caughtProcessCount, 1, "Negative control must catch exactly 1 un-commented Process() call using real scanner")
    }

    // MARK: - Helpers

    private func scanUIImportViolations(in files: [URL]) throws -> [String] {
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
        for file in files {
            let content = try String(contentsOf: file, encoding: .utf8)
            for pattern in forbiddenImportPatterns {
                if content.contains(pattern) {
                    let relPath = file.path.replacingOccurrences(of: repoRoot.path + "/", with: "")
                    violations.append("\(relPath): contains '\(pattern)'")
                }
            }
        }
        return violations
    }

    private func countProcessCalls(in files: [URL]) throws -> Int {
        var count = 0
        for file in files {
            let content = try String(contentsOf: file, encoding: .utf8)
            let lines = content.components(separatedBy: .newlines)
            for line in lines {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if !trimmed.hasPrefix("//") && trimmed.contains("Process()") {
                    count += 1
                }
            }
        }
        return count
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
