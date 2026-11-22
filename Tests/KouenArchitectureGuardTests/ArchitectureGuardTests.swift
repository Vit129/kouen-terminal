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

    // MARK: - G2: Zero Rogue Colors Outside Design Tokens (Rule 2)

    /// Ensures UI views never declare rogue inline #hex or Color(red:...) outside Design Tokens.
    func testG2_ZeroRogueColorsOutsideDesignTokens() throws {
        let uiDir = repoRoot.appendingPathComponent("Apps/Kouen/Sources/KouenApp/UI")
        guard FileManager.default.fileExists(atPath: uiDir.path) else { return }

        let swiftFiles = findSwiftFiles(in: uiDir)
        let violations = try scanColorViolations(in: swiftFiles)

        XCTAssertTrue(
            violations.isEmpty,
            "G2 Violation: Rogue color literals found in UI outside KouenDesign tokens:\n" + violations.joined(separator: "\n")
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

        // Ratchet: Baseline ceiling is now 0 (all 12 Process() calls migrated to KouenCore / KouenGit).
        let maxAllowedProcessCalls = 0
        XCTAssertEqual(
            totalCount,
            maxAllowedProcessCalls,
            "G3 Violation: Process() calls in UI exceeded baseline (\(totalCount) > \(maxAllowedProcessCalls)). Process() must be moved to KouenGit or Core services."
        )
    }

    // MARK: - G4: Zero Unmanaged Language Literals (Rule 3)

    /// Ensures Swift source code contains zero unmanaged foreign language characters outside translation files/assets.
    func testG4_ZeroUnmanagedLanguageLiteralsOutsideStrings() throws {
        let scanDirs = [
            "Apps/Kouen/Sources",
            "Packages",
        ]

        var violations: [String] = []

        for relDir in scanDirs {
            let dirURL = repoRoot.appendingPathComponent(relDir)
            guard FileManager.default.fileExists(atPath: dirURL.path) else { continue }
            let swiftFiles = findSwiftFiles(in: dirURL)
            violations.append(contentsOf: try scanLanguageViolations(in: swiftFiles))
        }

        XCTAssertTrue(
            violations.isEmpty,
            "G4 Violation: Unmanaged foreign language literals found outside strings files:\n" + violations.joined(separator: "\n")
        )
    }

    // MARK: - G5: Layered Behavioral Tests Tagging (Rule 4.2)

    /// Verifies that test suites for headless domain packages contain [BE-UT] or [BE-BL] tags.
    func testG5_LayeredBehavioralTestsTagging() throws {
        let coreTestDirs = [
            "Tests/KouenGitTests",
            "Tests/KouenCompositorTests",
        ]

        var missingTagFiles: [String] = []

        for relDir in coreTestDirs {
            let dirURL = repoRoot.appendingPathComponent(relDir)
            guard FileManager.default.fileExists(atPath: dirURL.path) else { continue }
            let swiftFiles = findSwiftFiles(in: dirURL)

            for file in swiftFiles {
                let content = try String(contentsOf: file, encoding: .utf8)
                if !content.contains("[BE-UT]") && !content.contains("[BE-BL]") && !content.contains("[BE-IT]") {
                    let relPath = file.path.replacingOccurrences(of: repoRoot.path + "/", with: "")
                    missingTagFiles.append(relPath)
                }
            }
        }

        XCTAssertTrue(
            missingTagFiles.isEmpty,
            "G5 Violation: Core tests missing [BE-UT]/[BE-BL]/[BE-IT] tagging:\n" + missingTagFiles.joined(separator: "\n")
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
                let rogueColor = Color(red: 1.0, green: 0.0, blue: 0.0)
                let rogueHex = "#FF00AA"
                let leakedText = "สวัสดี"
            }
        }
        """
        let badFile = tempDir.appendingPathComponent("BadFile.swift")
        try badSource.write(to: badFile, atomically: true, encoding: .utf8)

        let caughtViolations = try scanUIImportViolations(in: [badFile])
        let caughtProcessCount = try countProcessCalls(in: [badFile])
        let caughtColorViolations = try scanColorViolations(in: [badFile])
        let caughtLanguageViolations = try scanLanguageViolations(in: [badFile])

        XCTAssertFalse(caughtViolations.isEmpty, "Negative control must catch import AppKit using real scanner")
        XCTAssertEqual(caughtProcessCount, 1, "Negative control must catch exactly 1 un-commented Process() call using real scanner")
        XCTAssertEqual(caughtColorViolations.count, 2, "Negative control must catch inline Color(red:) and rogue hex")
        XCTAssertEqual(caughtLanguageViolations.count, 1, "Negative control must catch Thai character literal")
    }

    // MARK: - Helpers

    private func scanColorViolations(in files: [URL]) throws -> [String] {
        let allowedFiles: Set<String> = [
            "KouenDesign.swift",
            "KouenChrome.swift",
            "MarkdownPreviewView.swift",
            "BrowserPaneView.swift",
            "StatusLineView.swift",
        ]

        var violations: [String] = []
        let hexRegex = try NSRegularExpression(pattern: #"#[0-9a-fA-F]{3,8}\b"#)
        let rgbRegex = try NSRegularExpression(pattern: #"\b(NSColor|Color)\s*\(\s*(red|srgbRed):"#)

        for file in files {
            let filename = file.lastPathComponent
            if allowedFiles.contains(filename) { continue }

            let content = try String(contentsOf: file, encoding: .utf8)
            let lines = content.components(separatedBy: .newlines)
            let relPath = file.path.replacingOccurrences(of: repoRoot.path + "/", with: "")

            for (idx, line) in lines.enumerated() {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if trimmed.hasPrefix("//") || trimmed.hasPrefix("/*") || trimmed.hasPrefix("*") { continue }

                let fullRange = NSRange(location: 0, length: line.utf16.count)
                if let hexMatch = hexRegex.firstMatch(in: line, options: [], range: fullRange) {
                    let matchedHex = (line as NSString).substring(with: hexMatch.range)
                    if !line.contains("key: \"AB#") {
                        violations.append("\(relPath):\(idx + 1): rogue hex literal '\(matchedHex)': \(trimmed)")
                    }
                }
                if rgbRegex.firstMatch(in: line, options: [], range: fullRange) != nil {
                    violations.append("\(relPath):\(idx + 1): inline RGB color: \(trimmed)")
                }
            }
        }
        return violations
    }

    private func scanLanguageViolations(in files: [URL]) throws -> [String] {
        let allowedFiles: Set<String> = [
            "MobileBridgeWebAssets.swift",
        ]

        var violations: [String] = []
        let thaiRegex = try NSRegularExpression(pattern: #"[\u0E01-\u0E3A\u0E40-\u0E7F]"#)

        for file in files {
            let filename = file.lastPathComponent
            if allowedFiles.contains(filename) { continue }

            let content = try String(contentsOf: file, encoding: .utf8)
            let lines = content.components(separatedBy: .newlines)
            let relPath = file.path.replacingOccurrences(of: repoRoot.path + "/", with: "")

            for (idx, line) in lines.enumerated() {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if trimmed.hasPrefix("//") || trimmed.hasPrefix("/*") || trimmed.hasPrefix("*") { continue }

                let fullRange = NSRange(location: 0, length: line.utf16.count)
                if thaiRegex.firstMatch(in: line, options: [], range: fullRange) != nil {
                    violations.append("\(relPath):\(idx + 1): unmanaged language literal: \(trimmed)")
                }
            }
        }
        return violations
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
