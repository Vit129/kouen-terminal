import Foundation

/// Finds clickable URLs in a line of terminal text — the fallback when a cell carries no OSC 8
/// hyperlink, so plain `https://...` output is still command-clickable.
/// Pure and Foundation-only (uses `NSDataDetector` on Darwin), so it's unit-testable off the GUI.
public enum URLDetection {
    /// Parsed `path:line(:column)` token from compiler/test/grep output.
    public struct FileLocationTarget: Equatable, Sendable {
        public let path: String
        public let line: Int
        public let column: Int?

        public init(path: String, line: Int, column: Int? = nil) {
            self.path = path
            self.line = line
            self.column = column
        }

        public var urlString: String {
            var components = URLComponents()
            components.scheme = "harness-file"
            components.host = "open"
            var items = [
                URLQueryItem(name: "path", value: path),
                URLQueryItem(name: "line", value: String(line)),
            ]
            if let column {
                items.append(URLQueryItem(name: "column", value: String(column)))
            }
            components.queryItems = items
            return components.string ?? ""
        }

        public init?(urlString: String) {
            guard let components = URLComponents(string: urlString),
                  components.scheme?.lowercased() == "harness-file",
                  components.host == "open",
                  let items = components.queryItems,
                  let path = items.first(where: { $0.name == "path" })?.value,
                  !path.isEmpty,
                  let lineText = items.first(where: { $0.name == "line" })?.value,
                  let line = Int(lineText), line >= 1 else {
                return nil
            }
            let column = items.first(where: { $0.name == "column" })?.value.flatMap(Int.init)
            if let column, column < 1 { return nil }
            self.init(path: path, line: line, column: column)
        }
    }

    /// The URL covering character offset `column` in `line`, or nil. Callers should build `line`
    /// as one character per cell (so `column` is the clicked grid column); URLs are ASCII, so wide
    /// chars don't shift the mapping.
    public static func url(in line: String, at column: Int) -> String? {
        match(in: line, at: column)?.url
    }

    /// As `url(in:at:)`, but also returns the matched span as a half-open column range,
    /// so callers can underline the link on hover. `columns` uses the same one-character-
    /// per-cell convention as the input `line`.
    public static func match(in line: String, at column: Int) -> (url: String, columns: Range<Int>)? {
        guard !line.isEmpty, column >= 0 else { return nil }
        #if canImport(Darwin)
        if let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) {
            let full = NSRange(line.startIndex ..< line.endIndex, in: line)
            var result: (url: String, columns: Range<Int>)?
            detector.enumerateMatches(in: line, options: [], range: full) { match, _, stop in
                guard let match, let r = Range(match.range, in: line) else { return }
                let lower = line.distance(from: line.startIndex, to: r.lowerBound)
                let upper = line.distance(from: line.startIndex, to: r.upperBound)
                if column >= lower, column < upper,
                   let scheme = match.url?.scheme?.lowercased(),
                   ["http", "https", "mailto", "ftp", "ftps"].contains(scheme) {
                    result = (match.url?.absoluteString ?? String(line[r]), lower ..< upper)
                    stop.pointee = true
                }
            }
            if let result { return result }
        }
        if let fileMatch = fileLocation(in: line, at: column) {
            return (fileMatch.target.urlString, fileMatch.columns)
        }
        return nil
        #else
        // `NSDataDetector` isn't implemented in swift-corelibs-foundation (Linux). Fall back to a
        // whitespace-delimited token scan: the token covering `column` is a URL if it carries a
        // `scheme://`. Sufficient for the headless build (URL clicking is a GUI affordance).
        if let match = tokenMatch(in: line, at: column) { return match }
        if let fileMatch = fileLocation(in: line, at: column) {
            return (fileMatch.target.urlString, fileMatch.columns)
        }
        return nil
        #endif
    }

    /// Detects a `path:line` or `path:line:column` reference covering `column`.
    public static func fileLocation(
        in line: String,
        at column: Int
    ) -> (target: FileLocationTarget, columns: Range<Int>)? {
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
        guard let target = parseFileLocationToken(token) else { return nil }
        return (target, lo ..< (hi + 1))
    }

    private static func parseFileLocationToken(_ token: String) -> FileLocationTarget? {
        guard !token.contains("://") else { return nil }
        let parts = token.split(separator: ":", omittingEmptySubsequences: false)
        guard parts.count == 2 || parts.count == 3 else { return nil }
        let pathPart = String(parts[0])
        guard let line = Int(parts[1]), line >= 1 else { return nil }
        let column: Int?
        if parts.count == 3 {
            guard let parsedCol = Int(parts[2]), parsedCol >= 1 else { return nil }
            column = parsedCol
        } else {
            column = nil
        }
        guard isLikelyFilePath(pathPart) else { return nil }
        return FileLocationTarget(path: pathPart, line: line, column: column)
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
        let ext = candidate[candidate.index(after: dot)...]
        return ext.count <= 12 && ext.allSatisfy { $0.isLetter || $0.isNumber }
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
