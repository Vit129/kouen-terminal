import Foundation

/// Ranked loose search over agent session records, shared by the History sidebar and
/// `kouen history search` so both return the same results for the same query.
public enum AgentHistorySearch {
    public struct Hit: Sendable, Equatable {
        public let record: AgentSessionRecord
        public let score: Double
        public let snippet: String?
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

        // Check if query contains Thai or non-space characters that FTS5 unicode61 tokenizer cannot segment
        let isThaiOrSpecial = query.unicodeScalars.contains { (0x0E00...0x0E7F).contains($0.value) }

        if !isThaiOrSpecial {
            let ftsMatches = index.searchRanked(query: query, limit: ftsLimit)
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
                    hits.append(Hit(record: record, score: score, snippet: snippet))
                }

                // Check for unindexed records in `records` (e.g. from unit tests where
                // records are created in-memory without indexing in SQLite).
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
                            hits.append(Hit(record: record, score: score, snippet: nil))
                        }
                    }
                }

                hits.sort { lhs, rhs in
                    if abs(lhs.score - rhs.score) > 1e-9 { return lhs.score > rhs.score }
                    return lhs.record.updatedAt > rhs.record.updatedAt
                }
                return hits
            }
        }

        // Fallback for Thai / fuzzy queries, or when FTS index has no matching records
        return rankSwiftFallback(query: query, records: records, matcher: matcher, index: index, ftsLimit: ftsLimit)
    }

    /// Swift-side scoring fallback using IDFCache and typo tolerance.
    private static func rankSwiftFallback(
        query: String,
        records: [AgentSessionRecord],
        matcher: SearchMatcher,
        index: AgentHistoryFTSIndex,
        ftsLimit: Int
    ) -> [Hit] {
        let ftsMatches = index.search(query: query, limit: ftsLimit)

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
        fields.reserveCapacity(records.count)

        var normalizedFieldsForIDF: [String] = []
        normalizedFieldsForIDF.reserveCapacity(records.count)

        for record in records {
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

        let weights = idfCache.getWeights(tokens: matcher.tokens, records: records) {
            normalizedFieldsForIDF
        }

        var hits: [Hit] = []
        for (record, f) in zip(records, fields) {
            let ftsMatch = ftsMatches[record.id]

            if ftsMatch == nil {
                var candidate = false
                for token in matcher.tokens {
                    if f.normTitle.contains(token) || f.normBranch.contains(token) || f.normRepo.contains(token) || f.normChat.contains(token) {
                        candidate = true
                        break
                    }
                }
                if !candidate {
                    var typoCandidate = false
                    for token in matcher.tokens where token.count >= 4 {
                        if SearchMatcher.tokenHits(token, inNormalized: f.normTitle) || SearchMatcher.tokenHits(token, inNormalized: f.normBranch) {
                            typoCandidate = true
                            break
                        }
                    }
                    if !typoCandidate {
                        continue
                    }
                }
            }

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
            hits.append(Hit(record: record, score: score, snippet: match.snippet ?? ftsMatch?.snippet))
        }

        hits.sort { lhs, rhs in
            if abs(lhs.score - rhs.score) > 0.001 { return lhs.score > rhs.score }
            return lhs.record.updatedAt > rhs.record.updatedAt
        }
        return hits
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
