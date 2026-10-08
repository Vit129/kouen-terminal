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

        var hits: [Hit] = []
        for record in records {
            let turnsContent = record.latestTurns.map(\.content).joined(separator: "\n")
            let ftsMatch = ftsMatches[record.id]

            var chatContent = "\(record.firstPrompt)\n\(turnsContent)"
            if let snippet = ftsMatch?.snippet, !snippet.isEmpty {
                chatContent += "\n\(snippet)"
            }

            var branchFilesTools = record.gitBranch ?? ""
            if let files = ftsMatch?.filesEdited, !files.isEmpty { branchFilesTools += " " + files }
            if let tools = ftsMatch?.toolsCalled, !tools.isEmpty { branchFilesTools += " " + tools }

            guard let match = matcher.matchHistory(
                title: record.title,
                branchFilesTools: branchFilesTools,
                repoAgent: "\(record.projectName) \(record.agentKind.displayName)",
                chatContent: chatContent
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

    /// SQLite's bm25() is negative, more negative = better. Maps it to [0, 1) so a stronger
    /// transcript hit adds more, without outweighing a title/branch match.
    static func bm25Boost(_ rank: Double) -> Double {
        let strength = max(0, -rank)
        return strength / (1 + strength)
    }
}
