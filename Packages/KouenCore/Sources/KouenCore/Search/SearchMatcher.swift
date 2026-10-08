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

    // MARK: - Ranked Loose History Search (Slice B)

    public struct RankedHistoryMatchResult: Sendable, Equatable {
        public let score: Double
        public let matchedTokensCount: Int
        public let snippet: String?
        public let highlightedTerms: [String]

        public init(
            score: Double,
            matchedTokensCount: Int,
            snippet: String? = nil,
            highlightedTerms: [String] = []
        ) {
            self.score = score
            self.matchedTokensCount = matchedTokensCount
            self.snippet = snippet
            self.highlightedTerms = highlightedTerms
        }
    }

    /// Evaluates if token `k` matches `word` either by prefix, substring (for k >= 4), or 1-edit typo tolerance (for k >= 4).
    public static func tokenNear(_ k: String, in word: String) -> Bool {
        if word.hasPrefix(k) { return true }
        if k.count > 3 && word.contains(k) { return true }
        if k.count < 4 || abs(k.count - word.count) > 1 { return false }

        let kArr = Array(k)
        let wArr = Array(word)
        var i = 0
        var j = 0
        var edits = 0

        while i < kArr.count && j < wArr.count {
            if kArr[i] == wArr[j] {
                i += 1
                j += 1
            } else {
                edits += 1
                if edits > 1 { return false }
                if kArr.count > wArr.count {
                    i += 1
                } else if wArr.count > kArr.count {
                    j += 1
                } else {
                    i += 1
                    j += 1
                }
            }
        }
        return edits + (kArr.count - i) + (wArr.count - j) <= 1
    }

    /// Tests if a single token `token` matches a target text by exact containment or word-level prefix/typo tolerance.
    public static func tokenHits(_ token: String, in text: String) -> Bool {
        let norm = normalized(text)
        if norm.contains(token) { return true }
        let words = norm.split(whereSeparator: isTokenSeparator).map(String.init)
        return words.contains(where: { tokenNear(token, in: $0) })
    }

    /// Evaluates a session candidate across multiple fields with weights:
    /// - title: 3.0
    /// - branch / files / tools: 2.5
    /// - repo / agent: 1.5
    /// - chat content: 1.0
    ///
    /// Requires at least `ceil(tokens.count / 2)` token matches.
    public func matchHistory(
        title: String,
        branchFilesTools: String? = nil,
        repoAgent: String? = nil,
        chatContent: String? = nil
    ) -> RankedHistoryMatchResult? {
        guard hasQuery, !tokens.isEmpty else { return nil }

        let requiredMatches = Int(ceil(Double(tokens.count) / 2.0))
        var matchedTokensCount = 0
        var totalScore: Double = 0.0
        var matchedTerms: [String] = []

        let normTitle = Self.normalized(title)
        let normBranch = branchFilesTools.map(Self.normalized) ?? ""
        let normRepo = repoAgent.map(Self.normalized) ?? ""
        let normChat = chatContent.map(Self.normalized) ?? ""

        for token in tokens {
            if Self.tokenHits(token, in: normTitle) {
                totalScore += 3.0
                matchedTokensCount += 1
                matchedTerms.append(token)
            } else if !normBranch.isEmpty && Self.tokenHits(token, in: normBranch) {
                totalScore += 2.5
                matchedTokensCount += 1
                matchedTerms.append(token)
            } else if !normRepo.isEmpty && Self.tokenHits(token, in: normRepo) {
                totalScore += 1.5
                matchedTokensCount += 1
                matchedTerms.append(token)
            } else if !normChat.isEmpty && Self.tokenHits(token, in: normChat) {
                totalScore += 1.0
                matchedTokensCount += 1
                matchedTerms.append(token)
            }
        }

        guard matchedTokensCount >= requiredMatches else { return nil }

        let normalizedScore = totalScore / Double(tokens.count)

        // Snippet extraction from chatContent or branchFilesTools
        var snippet: String?
        if let chatContent, !chatContent.isEmpty {
            let targetToken = matchedTerms.first(where: { Self.tokenHits($0, in: normChat) })
            if let targetToken {
                snippet = extractSnippet(from: chatContent, targetQuery: targetToken)
            }
        } else if let branchFilesTools, !branchFilesTools.isEmpty {
            let targetToken = matchedTerms.first(where: { Self.tokenHits($0, in: normBranch) })
            if let targetToken {
                snippet = extractSnippet(from: branchFilesTools, targetQuery: targetToken)
            }
        }

        return RankedHistoryMatchResult(
            score: normalizedScore,
            matchedTokensCount: matchedTokensCount,
            snippet: snippet,
            highlightedTerms: matchedTerms
        )
    }
}
