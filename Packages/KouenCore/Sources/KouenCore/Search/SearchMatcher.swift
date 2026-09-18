import Foundation

/// Unified, high-performance search matcher supporting name, path, content searching,
/// tokenization, and fuzzy matching with snippet extraction.
/// Shared across FileTree, AgentSessionHistory, and AutomationsFleet.
public struct SearchMatcher: Sendable {
    public enum MatchCategory: Int, Comparable, Sendable {
        case exactFilename = 1
        case filenameStartsWith = 2
        case filenameEndsWith = 3
        case filenameContains = 4
        case filenameContainsTokens = 5
        case pathContains = 6
        case pathContainsTokens = 7
        case contentContains = 8
        case contentContainsTokens = 9
        case fuzzy = 10

        public static func < (lhs: MatchCategory, rhs: MatchCategory) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    public struct MatchResult: Sendable, Equatable {
        public let category: MatchCategory
        public let snippet: String?

        public init(category: MatchCategory, snippet: String? = nil) {
            self.category = category
            self.snippet = snippet
        }
    }

    public let rawQuery: String
    public let wholeQuery: String
    public let tokens: [String]

    public init(query: String) {
        self.rawQuery = query
        self.wholeQuery = Self.normalized(query)
        self.tokens = wholeQuery
            .split(whereSeparator: Self.isTokenSeparator)
            .map(String.init)
            .filter { !$0.isEmpty }
    }

    public var hasQuery: Bool {
        !wholeQuery.isEmpty || !tokens.isEmpty
    }

    /// Convenience for callers needing only the MatchCategory (e.g. FileTreeWatcher).
    public func matchCategory(
        name: String,
        relativePath: String? = nil,
        content: String? = nil,
        allowFuzzy: Bool = true
    ) -> MatchCategory? {
        match(name: name, relativePath: relativePath, content: content, allowFuzzy: allowFuzzy)?.category
    }

    /// Evaluates a candidate by name, optional relative path, and optional content body.
    public func match(
        name: String,
        relativePath: String? = nil,
        content: String? = nil,
        allowFuzzy: Bool = true
    ) -> MatchResult? {
        guard hasQuery else { return nil }

        let normalizedName = Self.normalized(name)
        let normalizedPath = relativePath.map(Self.normalized) ?? ""

        // 1. Exact / prefix / suffix filename matches
        if normalizedName == wholeQuery {
            return MatchResult(category: .exactFilename)
        }
        if normalizedName.hasPrefix(wholeQuery) {
            return MatchResult(category: .filenameStartsWith)
        }
        if normalizedName.hasSuffix(wholeQuery) {
            return MatchResult(category: .filenameEndsWith)
        }
        if normalizedName.contains(wholeQuery) {
            return MatchResult(category: .filenameContains)
        }
        if !tokens.isEmpty, tokens.allSatisfy({ normalizedName.contains($0) }) {
            return MatchResult(category: .filenameContainsTokens)
        }

        // 2. Path-level matches
        if !normalizedPath.isEmpty {
            if normalizedPath.contains(wholeQuery) {
                return MatchResult(category: .pathContains)
            }
            if !tokens.isEmpty, tokens.allSatisfy({ normalizedPath.contains($0) }) {
                return MatchResult(category: .pathContainsTokens)
            }
        }

        // 3. Content-level matches (search transcript turns, prompts, or file text)
        if let content = content, !content.isEmpty {
            let normalizedContent = Self.normalized(content)
            if normalizedContent.contains(wholeQuery) {
                let snippet = extractSnippet(from: content, targetQuery: wholeQuery)
                return MatchResult(category: .contentContains, snippet: snippet)
            }
            if !tokens.isEmpty, tokens.allSatisfy({ normalizedContent.contains($0) }) {
                let firstMatch = tokens.first(where: { normalizedContent.contains($0) }) ?? wholeQuery
                let snippet = extractSnippet(from: content, targetQuery: firstMatch)
                return MatchResult(category: .contentContainsTokens, snippet: snippet)
            }
        }

        // 4. Fuzzy / subsequence fallback
        if allowFuzzy {
            if Self.isSubsequence(wholeQuery, in: normalizedName) ||
               (!normalizedPath.isEmpty && Self.isSubsequence(wholeQuery, in: normalizedPath)) {
                return MatchResult(category: .fuzzy)
            }
        }

        return nil
    }

    /// Tests if a single text contains the query or all tokens.
    public func matches(text: String) -> Bool {
        guard hasQuery else { return true }
        let norm = Self.normalized(text)
        if norm.contains(wholeQuery) { return true }
        if !tokens.isEmpty && tokens.allSatisfy({ norm.contains($0) }) { return true }
        return false
    }

    /// Extracts a context-bounded snippet around the matched query in content.
    public func extractSnippet(from content: String, targetQuery: String? = nil, maxChars: Int = 120) -> String? {
        let needle = (targetQuery ?? wholeQuery).lowercased()
        guard !needle.isEmpty else { return nil }

        let lowerContent = content.lowercased()
        guard let range = lowerContent.range(of: needle) else { return nil }

        let matchStart = range.lowerBound
        let matchEnd = range.upperBound

        let half = maxChars / 2
        let startDistance = content.distance(from: content.startIndex, to: matchStart)
        let snippetStartIndex = content.index(matchStart, offsetBy: -min(startDistance, half))
        let remainingDistance = content.distance(from: matchEnd, to: content.endIndex)
        let snippetEndIndex = content.index(matchEnd, offsetBy: min(remainingDistance, half))

        var snippet = String(content[snippetStartIndex..<snippetEndIndex])
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\t", with: " ")
            .trimmingCharacters(in: .whitespaces)

        if snippetStartIndex > content.startIndex {
            snippet = "…" + snippet
        }
        if snippetEndIndex < content.endIndex {
            snippet = snippet + "…"
        }
        return snippet
    }

    // MARK: - Utilities

    public static func isSubsequence(_ query: String, in haystack: String) -> Bool {
        if query.isEmpty { return true }
        var queryIdx = query.startIndex
        for char in haystack {
            if char == query[queryIdx] {
                queryIdx = query.index(after: queryIdx)
                if queryIdx == query.endIndex {
                    return true
                }
            }
        }
        return false
    }

    public static func normalized(_ value: String) -> String {
        value.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public static func isTokenSeparator(_ character: Character) -> Bool {
        character.isWhitespace || character == "/" || character == "." || character == "-" || character == "_"
    }
}
