import Foundation

/// Finds clickable URLs in a line of terminal text — the fallback when a cell carries no OSC 8
/// hyperlink, so plain `https://...` output is still command-clickable.
/// Pure and Foundation-only (uses `NSDataDetector` on Darwin), so it's unit-testable off the GUI.
public enum URLDetection {
    /// A link found in terminal text.
    public enum Link: Equatable, Sendable {
        case web(String)
        /// A `path:line(:column)` reference from compiler, test, or grep output, with the path as
        /// printed: absolute, `~/`, or relative to the shell's working directory.
        case file(path: String)
    }

    /// The web URL covering character offset `column` in `line`, or nil. Callers should build
    /// `line` as one character per cell (so `column` is the clicked grid column); URLs are ASCII,
    /// so wide chars don't shift the mapping.
    public static func url(in line: String, at column: Int) -> String? {
        guard case let .web(url)? = match(in: line, at: column)?.link else { return nil }
        return url
    }

    /// The link covering `column` and its span as a half-open column range, so callers can
    /// underline it on hover. `columns` uses the same one-character-per-cell convention as `line`.
    /// File references win over scheme-less web matches: the data detector reads `main.rs:10` as
    /// `http://main.rs:10`.
    public static func match(in line: String, at column: Int) -> (link: Link, columns: Range<Int>)? {
        guard !line.isEmpty, column >= 0 else { return nil }
        let file = fileLocation(in: line, at: column).map { (link: Link.file(path: $0.path), columns: $0.columns) }
        #if canImport(Darwin)
        if let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) {
            let full = NSRange(line.startIndex ..< line.endIndex, in: line)
            var result: (link: Link, columns: Range<Int>)?
            detector.enumerateMatches(in: line, options: [], range: full) { match, _, stop in
                guard let match, let r = Range(match.range, in: line) else { return }
                let lower = line.distance(from: line.startIndex, to: r.lowerBound)
                let upper = line.distance(from: line.startIndex, to: r.upperBound)
                let text = line[r]
                if column >= lower, column < upper,
                   file == nil || text.contains("://") || text.lowercased().hasPrefix("mailto:"),
                   let scheme = match.url?.scheme?.lowercased(),
                   ["http", "https", "mailto", "ftp", "ftps"].contains(scheme) {
                    result = (.web(match.url?.absoluteString ?? String(text)), lower ..< upper)
                    stop.pointee = true
                }
            }
            if let result { return result }
        }
        return file
        #else
        // `NSDataDetector` isn't implemented in swift-corelibs-foundation (Linux). Fall back to a
        // whitespace-delimited token scan: the token covering `column` is a URL if it carries a
        // `scheme://`. Sufficient for the headless build (URL clicking is a GUI affordance).
        if let match = tokenMatch(in: line, at: column) { return (.web(match.url), match.columns) }
        return file
        #endif
    }

    /// Detects a `path:line` or `path:line:column` reference covering `column`.
    public static func fileLocation(in line: String, at column: Int) -> (path: String, columns: Range<Int>)? {
        let chars = Array(line)
        guard column >= 0, column < chars.count else { return nil }
        func isBoundary(_ c: Character) -> Bool {
            c == " " || c == "\t" || c == "\"" || c == "'" || c == "(" || c == ")"
                || c == "[" || c == "]" || c == "<" || c == ">"
        }
        guard !isBoundary(chars[column]) else { return nil }
        var lo = column
        var hi = column
        while lo > 0, !isBoundary(chars[lo - 1]) { lo -= 1 }
        while hi + 1 < chars.count, !isBoundary(chars[hi + 1]) { hi += 1 }
        while hi >= lo, ").,;!?'\\\"]>".contains(chars[hi]) { hi -= 1 }
        if hi >= lo, chars[hi] == ":" { hi -= 1 }
        guard lo <= hi, column >= lo, column <= hi else { return nil }
        let token = String(chars[lo ... hi])
        guard let path = filePath(inLocationToken: token) else { return nil }
        return (path, lo ..< (hi + 1))
    }

    /// The path of a `path:line(:column)` token, or nil when the token isn't one.
    private static func filePath(inLocationToken token: String) -> String? {
        guard !token.contains("://") else { return nil }
        let parts = token.split(separator: ":", omittingEmptySubsequences: false)
        guard parts.count == 2 || parts.count == 3,
              parts.dropFirst().allSatisfy({ Int($0).map { $0 >= 1 } ?? false })
        else { return nil }
        let path = String(parts[0])
        return isLikelyFilePath(path) ? path : nil
    }

    private static func isLikelyFilePath(_ candidate: String) -> Bool {
        guard !candidate.isEmpty,
              !candidate.allSatisfy(\.isNumber),
              candidate.first != "-" else { return false }
        if candidate.hasPrefix("/") || candidate.hasPrefix("./") || candidate.hasPrefix("../") || candidate.hasPrefix("~/") {
            return candidate.count > 2
        }
        if candidate.contains("/") {
            return true
        }
        guard let dot = candidate.lastIndex(of: "."),
              dot > candidate.startIndex,
              dot < candidate.index(before: candidate.endIndex) else {
            return false
        }
        // A letter in the extension keeps addresses like `127.0.0.1:8080` out.
        let ext = candidate[candidate.index(after: dot)...]
        return ext.count <= 12 && ext.allSatisfy { $0.isLetter || $0.isNumber } && ext.contains(where: \.isLetter)
    }

    #if !canImport(Darwin)
    private static func tokenMatch(in line: String, at column: Int) -> (url: String, columns: Range<Int>)? {
        let chars = Array(line)
        guard column < chars.count else { return nil }
        func isBoundary(_ c: Character) -> Bool { c == " " || c == "\t" }
        guard !isBoundary(chars[column]) else { return nil }
        var lo = column
        var hi = column
        while lo > 0, !isBoundary(chars[lo - 1]) { lo -= 1 }
        while hi + 1 < chars.count, !isBoundary(chars[hi + 1]) { hi += 1 }
        var token = String(chars[lo ... hi])
        while let last = token.last, ").,;:!?'\\\"]>".contains(last) { token.removeLast() }
        guard let schemeEnd = token.range(of: "://"),
              token[token.startIndex ..< schemeEnd.lowerBound].allSatisfy({ $0.isLetter }),
              schemeEnd.lowerBound != token.startIndex
        else { return nil }
        return (token, lo ..< (lo + token.count))
    }
    #endif
}
