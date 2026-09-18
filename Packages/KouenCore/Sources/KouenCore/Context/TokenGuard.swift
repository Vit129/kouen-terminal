import Foundation

/// Protects LLM context windows by filtering lockfiles, minified bundles,
/// and truncating oversized text/diff outputs with clear summary markers.
public enum TokenGuard: Sendable {
    /// File patterns that should be omitted from automatic diff contexts.
    public static let ignoredDiffPatterns: [String] = [
        "package-lock.json",
        "pnpm-lock.yaml",
        "yarn.lock",
        "Cargo.lock",
        "Gemfile.lock",
        "composer.lock",
        "poetry.lock",
        "flake.lock",
        ".pbxproj",
        ".min.js",
        ".min.css",
        ".map",
    ]

    /// Checks if a file path is considered a lockfile or generated bundle.
    public static func shouldIgnore(path: String) -> Bool {
        let lower = path.lowercased()
        for pattern in ignoredDiffPatterns {
            if lower.hasSuffix(pattern.lowercased()) || lower.contains("/" + pattern.lowercased()) {
                return true
            }
        }
        return false
    }

    /// Filters and truncates git diff output.
    /// - Parameters:
    ///   - diff: Raw git diff output string.
    ///   - maxLines: Maximum number of output lines to keep (default 400).
    ///   - filterLockfiles: If true, removes lockfiles from the diff output.
    /// - Returns: Sanitized and bounded diff string.
    public static func sanitizeDiff(_ diff: String, maxLines: Int = 400, filterLockfiles: Bool = true) -> String {
        guard !diff.isEmpty else { return "" }

        let rawLines = diff.components(separatedBy: .newlines)
        var filteredLines: [String] = []
        var skippingFile = false
        var skippedFiles: [String] = []

        for line in rawLines {
            if line.hasPrefix("diff --git ") {
                let parts = line.components(separatedBy: " ")
                let filePath = parts.last ?? ""
                if filterLockfiles && shouldIgnore(path: filePath) {
                    skippingFile = true
                    skippedFiles.append(filePath)
                } else {
                    skippingFile = false
                }
            }

            if !skippingFile {
                filteredLines.append(line)
            }
        }

        var header = ""
        if !skippedFiles.isEmpty {
            header += "<!-- TokenGuard: Filtered \(skippedFiles.count) generated/lockfile(s) -->\n"
        }

        if filteredLines.count <= maxLines {
            return header + filteredLines.joined(separator: "\n")
        }

        let kept = filteredLines.prefix(maxLines)
        let dropped = filteredLines.count - maxLines
        let footer = "\n<!-- TokenGuard: Truncated (\(dropped) lines omitted). Use 'kouen context diff --all' for full diff -->"

        return header + kept.joined(separator: "\n") + footer
    }

    /// Truncates general text/logs to a safe maximum line count from the tail.
    public static func truncateTail(_ text: String, maxLines: Int = 100) -> String {
        let lines = text.components(separatedBy: .newlines)
        guard lines.count > maxLines else { return text }

        let tail = lines.suffix(maxLines)
        let dropped = lines.count - maxLines
        return "<!-- TokenGuard: Truncated (\(dropped) earlier lines omitted) -->\n" + tail.joined(separator: "\n")
    }
}
