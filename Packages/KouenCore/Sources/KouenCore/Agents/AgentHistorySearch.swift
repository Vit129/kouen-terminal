import Foundation
#if canImport(NaturalLanguage)
import NaturalLanguage
#endif

/// Ranked loose search over agent session records, shared by the History sidebar and
/// `kouen history search` so both return the same results for the same query.
public enum AgentHistorySearch {
    public struct Hit: Sendable, Equatable {
        public let record: AgentSessionRecord
        public let score: Double
        public let snippet: String?
        public let matchLocation: AgentSessionRecord.MatchLocationInfo?
        public let isSemanticMatch: Bool

        public init(
            record: AgentSessionRecord,
            score: Double,
            snippet: String?,
            matchLocation: AgentSessionRecord.MatchLocationInfo? = nil,
            isSemanticMatch: Bool = false
        ) {
            self.record = record
            self.score = score
            self.snippet = snippet
            self.matchLocation = matchLocation ?? record.matchLocation(for: snippet ?? "")
            self.isSemanticMatch = isSemanticMatch
        }
    }

    final class IDFCache: @unchecked Sendable {
        private let lock = NSLock()
        private var corpusFingerprint: Int = 0
        private var tokenDocFreqs: [String: Int] = [:]

        func getWeights(
            tokens: [String],
            records: [AgentSessionRecord],
            computeFields: () -> [String]
        ) -> [String: Double] {
            lock.lock()
            defer { lock.unlock() }

            var hasher = Hasher()
            hasher.combine(records.count)
            if let first = records.first { hasher.combine(first.id) }
            if let last = records.last { hasher.combine(last.id) }
            let fp = hasher.finalize()

            if fp != corpusFingerprint {
                corpusFingerprint = fp
                tokenDocFreqs.removeAll(keepingCapacity: true)
            }

            let n = Double(records.count)
            var weights: [String: Double] = [:]
            var missingTokens: [String] = []

            for token in tokens {
                if let df = tokenDocFreqs[token] {
                    weights[token] = max(0.1, log((n + 1) / (Double(df) + 1)))
                } else {
                    missingTokens.append(token)
                }
            }

            if !missingTokens.isEmpty {
                let fields = computeFields()
                for token in missingTokens {
                    let df = fields.reduce(0) { $0 + (SearchMatcher.tokenHits(token, inNormalized: $1) ? 1 : 0) }
                    tokenDocFreqs[token] = df
                    weights[token] = max(0.1, log((n + 1) / (Double(df) + 1)))
                }
            }

            return weights
        }
    }

    private static let idfCache = IDFCache()

    private static func containsNonSegmentedScript(_ text: String) -> Bool {
        text.unicodeScalars.contains { scalar in
            // Thai Unicode block: 0x0E00...0x0E7F
            (0x0E00...0x0E7F).contains(scalar.value)
        }
    }

    /// Uses SQLite FTS5 bm25() with column weights for sub-millisecond ranking across keystrokes.
    /// Falls back to the Swift ranker for queries FTS cannot express (Thai, fuzzy/subsequence)
    /// or when FTS has no indexed matches.
    public static func rank(
        query: String,
        records: [AgentSessionRecord],
        index: AgentHistoryFTSIndex = .shared,
        ftsLimit: Int = 200
    ) -> [Hit] {
        let matcher = SearchMatcher(query: query)
        guard matcher.hasQuery else { return [] }

        let isNonSegmented = containsNonSegmentedScript(query)

        // For standard alphanumeric queries, try fast SQLite FTS5 search first.
        // For non-segmented scripts (Thai), standard FTS tokenizer does not segment words,
        // so we route directly to Swift ranker with full substring coverage.
        let ftsMatches = isNonSegmented ? [] : index.searchRanked(query: query, limit: ftsLimit, includeSnippet: false)
        if !ftsMatches.isEmpty {
            var recordMap: [String: AgentSessionRecord] = [:]
            recordMap.reserveCapacity(records.count)
            for r in records {
                recordMap[r.id] = r
            }

            var hits: [Hit] = []
            hits.reserveCapacity(ftsMatches.count)

            var matchedIDs = Set<String>()
            for match in ftsMatches {
                guard let record = recordMap[match.sessionID] else { continue }
                matchedIDs.insert(record.id)
                // FTS5 bm25 rank is negative (more negative = better match).
                let score = -match.rank
                let snippet = match.snippet.isEmpty ? nil : match.snippet
                hits.append(Hit(record: record, score: score, snippet: snippet, matchLocation: record.matchLocation(for: query), isSemanticMatch: false))
            }

            // Check for unindexed records in `records` (regardless of records.count limit)
            if matchedIDs.count < records.count {
                for record in records where !matchedIDs.contains(record.id) {
                    var titleMatched = false
                    var branchMatched = false

                    for token in matcher.tokens {
                        if record.title.range(of: token, options: .caseInsensitive) != nil {
                            titleMatched = true
                            break
                        } else if let branch = record.gitBranch, branch.range(of: token, options: .caseInsensitive) != nil {
                            branchMatched = true
                            break
                        }
                    }

                    if titleMatched || branchMatched {
                        let score = titleMatched ? 10.0 : 5.0
                        hits.append(Hit(record: record, score: score, snippet: nil, matchLocation: record.matchLocation(for: query), isSemanticMatch: false))
                    }
                }
            }

            hits.sort { lhs, rhs in
                if abs(lhs.score - rhs.score) > 1e-9 { return lhs.score > rhs.score }
                return lhs.record.updatedAt > rhs.record.updatedAt
            }
            if !hits.isEmpty {
                return hits
            }
        }

        // Fallback for non-segmented scripts (Thai), fuzzy queries, or when FTS index has no matching records
        let fallbackHits = rankSwiftFallback(query: query, records: records, matcher: matcher, index: index, ftsLimit: ftsLimit, isNonSegmented: isNonSegmented)
        if fallbackHits.isEmpty {
            return semanticSearchFallback(query: query, records: records)
        }
        return fallbackHits
    }

    /// Swift-side scoring fallback using IDFCache and typo tolerance.
    private static func rankSwiftFallback(
        query: String,
        records: [AgentSessionRecord],
        matcher: SearchMatcher,
        index: AgentHistoryFTSIndex,
        ftsLimit: Int,
        isNonSegmented: Bool = false
    ) -> [Hit] {
        let ftsMatches = index.search(query: query, limit: ftsLimit)

        // Fast candidate pre-filtering to avoid normalizing hundreds of unrelated sessions
        var candidates: [AgentSessionRecord] = []
        candidates.reserveCapacity(records.count)

        for record in records {
            if ftsMatches[record.id] != nil {
                candidates.append(record)
                continue
            }
            var isCandidate = false
            for token in matcher.tokens {
                if record.title.range(of: token, options: .caseInsensitive) != nil ||
                   (record.gitBranch != nil && record.gitBranch!.range(of: token, options: .caseInsensitive) != nil) {
                    isCandidate = true
                    break
                }
                if records.count <= ftsLimit || isNonSegmented {
                    if record.projectName.range(of: token, options: .caseInsensitive) != nil ||
                       record.firstPrompt.range(of: token, options: .caseInsensitive) != nil {
                        isCandidate = true
                        break
                    }
                }
            }
            // Only search transcript turns if FTS matches were empty or non-segmented script
            if !isCandidate && (ftsMatches.isEmpty || isNonSegmented || records.count <= ftsLimit) {
                for turn in record.latestTurns {
                    for token in matcher.tokens {
                        if turn.content.range(of: token, options: .caseInsensitive) != nil {
                            isCandidate = true
                            break
                        }
                    }
                    if isCandidate { break }
                }
            }
            if !isCandidate {
                for token in matcher.tokens where token.count >= 4 && token.count <= 16 {
                    if SearchMatcher.tokenHits(token, inNormalized: SearchMatcher.normalized(record.title)) ||
                       SearchMatcher.tokenHits(token, inNormalized: SearchMatcher.normalized(record.gitBranch ?? "")) {
                        isCandidate = true
                        break
                    }
                }
            }
            if isCandidate {
                candidates.append(record)
            }
        }

        guard !candidates.isEmpty else { return [] }

        struct Fields {
            let title: String
            let normTitle: String
            let branchFilesTools: String
            let normBranch: String
            let repoAgent: String
            let normRepo: String
            let chat: String
            let normChat: String
        }

        var fields: [Fields] = []
        fields.reserveCapacity(candidates.count)

        var normalizedFieldsForIDF: [String] = []
        normalizedFieldsForIDF.reserveCapacity(candidates.count)

        for record in candidates {
            let ftsMatch = ftsMatches[record.id]
            var chat = "\(record.firstPrompt)\n" + record.latestTurns.map(\.content).joined(separator: "\n")
            if let snippet = ftsMatch?.snippet, !snippet.isEmpty { chat += "\n\(snippet)" }
            var branchFilesTools = record.gitBranch ?? ""
            if let files = ftsMatch?.filesEdited, !files.isEmpty { branchFilesTools += " " + files }
            if let tools = ftsMatch?.toolsCalled, !tools.isEmpty { branchFilesTools += " " + tools }
            let repoAgent = "\(record.projectName) \(record.agentKind.displayName)"

            let normTitle = SearchMatcher.normalized(record.title)
            let normBranch = SearchMatcher.normalized(branchFilesTools)
            let normRepo = SearchMatcher.normalized(repoAgent)
            let normChat = SearchMatcher.normalized(chat)

            fields.append(Fields(
                title: record.title,
                normTitle: normTitle,
                branchFilesTools: branchFilesTools,
                normBranch: normBranch,
                repoAgent: repoAgent,
                normRepo: normRepo,
                chat: chat,
                normChat: normChat
            ))
            normalizedFieldsForIDF.append("\(normTitle) \(normBranch) \(normRepo) \(normChat)")
        }

        let weights = idfCache.getWeights(tokens: matcher.tokens, records: candidates) {
            normalizedFieldsForIDF
        }

        var hits: [Hit] = []
        for (record, f) in zip(candidates, fields) {
            let ftsMatch = ftsMatches[record.id]
            guard let match = matcher.matchHistory(
                normalizedTitle: f.normTitle,
                normalizedBranchFilesTools: f.normBranch,
                normalizedRepoAgent: f.normRepo,
                normalizedChatContent: f.normChat,
                rawChatContent: f.chat,
                rawBranchFilesTools: f.branchFilesTools,
                tokenWeights: weights
            ) else { continue }

            var score = match.score
            if let rank = ftsMatch?.rank {
                score += bm25Boost(rank)
            }
            hits.append(Hit(
                record: record,
                score: score,
                snippet: match.snippet ?? ftsMatch?.snippet,
                matchLocation: record.matchLocation(for: query),
                isSemanticMatch: false
            ))
        }

        hits.sort { lhs, rhs in
            if abs(lhs.score - rhs.score) > 0.001 { return lhs.score > rhs.score }
            return lhs.record.updatedAt > rhs.record.updatedAt
        }
        return hits
    }

    /// Zero-dependency semantic fallback using macOS NaturalLanguage sentence/word embeddings.
    /// Only invoked when exact keyword, token, and FTS5 search return 0 hits.
    public static func semanticSearchFallback(
        query: String,
        records: [AgentSessionRecord],
        limit: Int = 10,
        distanceThreshold: Double = 0.95
    ) -> [Hit] {
        #if canImport(NaturalLanguage)
        guard let embedding = NLEmbedding.sentenceEmbedding(for: .english) ?? NLEmbedding.wordEmbedding(for: .english) else {
            return []
        }
        let cleanQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard cleanQuery.count >= 3 else { return [] }

        var results: [(record: AgentSessionRecord, score: Double, snippet: String?)] = []

        for record in records {
            var minDistance = Double.greatestFiniteMagnitude
            var bestSnippet: String?

            // Test title
            let titleDist = embedding.distance(between: cleanQuery, and: record.title)
            if titleDist < minDistance {
                minDistance = titleDist
                bestSnippet = record.title
            }

            // Test first prompt (shortened)
            if !record.firstPrompt.isEmpty {
                let firstLine = record.firstPrompt.components(separatedBy: .newlines).first ?? record.firstPrompt
                let promptDist = embedding.distance(between: cleanQuery, and: String(firstLine.prefix(120)))
                if promptDist < minDistance {
                    minDistance = promptDist
                    bestSnippet = String(firstLine.prefix(100))
                }
            }

            // Test topic segments if available
            if let segments = record.topicSegments {
                for seg in segments {
                    let segDist = embedding.distance(between: cleanQuery, and: seg)
                    if segDist < minDistance {
                        minDistance = segDist
                        bestSnippet = seg
                    }
                }
            }

            // Test recent turns
            for turn in record.latestTurns.prefix(5) {
                let turnSnippet = String(turn.content.prefix(100))
                let turnDist = embedding.distance(between: cleanQuery, and: turnSnippet)
                if turnDist < minDistance {
                    minDistance = turnDist
                    bestSnippet = turnSnippet
                }
            }

            if minDistance <= distanceThreshold {
                let score = max(0.1, (1.0 - minDistance) * 10.0)
                results.append((record: record, score: score, snippet: bestSnippet))
            }
        }

        results.sort { lhs, rhs in
            if abs(lhs.score - rhs.score) > 0.001 { return lhs.score > rhs.score }
            return lhs.record.updatedAt > rhs.record.updatedAt
        }

        let prefix = results.prefix(limit)
        return prefix.map { item in
            Hit(
                record: item.record,
                score: item.score,
                snippet: item.snippet,
                matchLocation: item.record.matchLocation(for: item.snippet ?? query),
                isSemanticMatch: true
            )
        }
        #else
        return []
        #endif
    }

    /// IDF per query token over the candidate sessions: a word found in nearly every session
    /// ("kouen", "agent") weighs far less than one found in a few ("browser"). Floor keeps a
    /// universal word from dropping to zero so it still breaks ties.
    public static func rarityWeights(tokens: [String], fields: [String]) -> [String: Double] {
        let n = Double(fields.count)
        var weights: [String: Double] = [:]
        for token in tokens where weights[token] == nil {
            let df = Double(fields.reduce(0) { $0 + (SearchMatcher.tokenHits(token, inNormalized: $1) ? 1 : 0) })
            weights[token] = max(0.1, log((n + 1) / (df + 1)))
        }
        return weights
    }

    /// SQLite's bm25() is negative, more negative = better. Maps it to [0, 1) so a stronger
    /// transcript hit adds more, without outweighing a title/branch match.
    static func bm25Boost(_ rank: Double) -> Double {
        let strength = max(0, -rank)
        return strength / (1 + strength)
    }
}
