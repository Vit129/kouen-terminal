import Foundation

/// Ranked loose search over agent session records, shared by the History sidebar and
/// `kouen history search` so both return the same results for the same query.
public enum AgentHistorySearch {
    public struct Hit: Sendable, Equatable {
        public let record: AgentSessionRecord
        public let score: Double
        public let snippet: String?
    }

    /// FTS5 narrows the full transcripts to candidates (id + snippet + bm25 only); `matchHistory`
    /// then scores light fields, so typo tolerance never runs over whole transcripts.
    public static func rank(
        query: String,
        records: [AgentSessionRecord],
        index: AgentHistoryFTSIndex = .shared,
        ftsLimit: Int = 200
    ) -> [Hit] {
        let matcher = SearchMatcher(query: query)
        guard matcher.hasQuery else { return [] }
        let ftsMatches = index.search(query: query, limit: ftsLimit)

        struct Fields { let title, branchFilesTools, repoAgent, chat: String }
        let fields: [Fields] = records.map { record in
            let ftsMatch = ftsMatches[record.id]
            var chat = "\(record.firstPrompt)\n" + record.latestTurns.map(\.content).joined(separator: "\n")
            if let snippet = ftsMatch?.snippet, !snippet.isEmpty { chat += "\n\(snippet)" }
            var branchFilesTools = record.gitBranch ?? ""
            if let files = ftsMatch?.filesEdited, !files.isEmpty { branchFilesTools += " " + files }
            if let tools = ftsMatch?.toolsCalled, !tools.isEmpty { branchFilesTools += " " + tools }
            return Fields(title: record.title, branchFilesTools: branchFilesTools,
                          repoAgent: "\(record.projectName) \(record.agentKind.displayName)", chat: chat)
        }
        let weights = rarityWeights(tokens: matcher.tokens, fields: fields.map {
            SearchMatcher.normalized("\($0.title) \($0.branchFilesTools) \($0.repoAgent) \($0.chat)")
        })

        var hits: [Hit] = []
        for (record, f) in zip(records, fields) {
            let ftsMatch = ftsMatches[record.id]
            guard let match = matcher.matchHistory(
                title: f.title,
                branchFilesTools: f.branchFilesTools,
                repoAgent: f.repoAgent,
                chatContent: f.chat,
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
    static func rarityWeights(tokens: [String], fields: [String]) -> [String: Double] {
        let n = Double(fields.count)
        var weights: [String: Double] = [:]
        for token in tokens where weights[token] == nil {
            let df = Double(fields.reduce(0) { $0 + (SearchMatcher.tokenHits(token, in: $1) ? 1 : 0) })
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
