import Foundation

/// Lightweight parser for path:line:col tokens in compiler/grep/test output.
/// Lives in HarnessCore so all surfaces (gf, :errors, :grep, MCP, CLI) share one implementation.
public enum PathTokenParser {
    public struct PathToken: Sendable, Equatable {
        public let path: String
        public let line: Int?
        public let column: Int?

        public init(path: String, line: Int? = nil, column: Int? = nil) {
            self.path = path
            self.line = line
            self.column = column
        }
    }

    /// Parse `path:line:col`, `path:line`, or `path(line,col)` from text.
    /// Strips trailing `: message` or `: error:` suffixes.
    public static func parse(_ text: String) -> PathToken? {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }

        // Try path(line,col) or path(line)
        if let parenResult = parseParen(trimmed) { return parenResult }

        // Try path:line:col[:...] — split from the right
        return parseColon(trimmed)
    }

    private static func parseParen(_ text: String) -> PathToken? {
        guard let open = text.firstIndex(of: "("),
              let close = text.firstIndex(of: ")"),
              close > open
        else { return nil }

        let path = String(text[text.startIndex..<open])
        guard !path.isEmpty, looksLikePath(path) else { return nil }

        let inner = text[text.index(after: open)..<close]
        let parts = inner.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        guard let lineStr = parts.first, let line = Int(lineStr), line > 0 else { return nil }
        let col = parts.count > 1 ? Int(parts[1]) : nil
        return PathToken(path: path, line: line, column: col)
    }

    private static func parseColon(_ text: String) -> PathToken? {
        // Split on ":"
        let parts = text.split(separator: ":", omittingEmptySubsequences: false).map(String.init)
        guard parts.count >= 2 else { return nil }

        // Try from the end: last 2 might be line:col, last 1 might be line
        // path:line:col[:message]
        for end in stride(from: min(parts.count, parts.count), through: 2, by: -1) {
            // Try interpreting parts[end-2] as line and parts[end-1] as col
            if end >= 3,
               let line = Int(parts[end - 2].trimmingCharacters(in: .whitespaces)),
               let col = Int(parts[end - 1].trimmingCharacters(in: .whitespaces)),
               line > 0, col > 0 {
                let path = parts[0..<(end - 2)].joined(separator: ":")
                if !path.isEmpty, looksLikePath(path) {
                    return PathToken(path: path, line: line, column: col)
                }
            }
            // Try interpreting parts[end-1] as line only
            if let line = Int(parts[end - 1].trimmingCharacters(in: .whitespaces)), line > 0 {
                let path = parts[0..<(end - 1)].joined(separator: ":")
                if !path.isEmpty, looksLikePath(path) {
                    return PathToken(path: path, line: line, column: nil)
                }
            }
        }
        return nil
    }

    private static func looksLikePath(_ s: String) -> Bool {
        let trimmed = s.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return false }
        if trimmed.hasPrefix("/") || trimmed.hasPrefix("~") || trimmed.hasPrefix(".") { return true }
        // Relative path with extension or directory separator
        if trimmed.contains("/") || trimmed.contains(".") { return true }
        return false
    }
}
