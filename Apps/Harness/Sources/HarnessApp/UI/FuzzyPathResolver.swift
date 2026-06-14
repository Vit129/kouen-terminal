import Foundation

enum FileFuzzyMatcher {
    /// Score `string` against `query`. Returns nil when no subsequence match.
    /// Higher scores rank earlier.
    static func score(query: String, in string: String) -> Int? {
        guard !query.isEmpty else { return 0 }
        let lowerQ = Array(query.lowercased())
        let lowerS = Array(string.lowercased())
        let originalS = Array(string)
        let originalQ = Array(query)

        var score = 0
        var sIdx = 0
        var lastMatch = -1
        for (qIdx, q) in lowerQ.enumerated() {
            var matched = false
            while sIdx < lowerS.count {
                if lowerS[sIdx] == q {
                    score += 3
                    if originalS[sIdx] == originalQ[qIdx] { score += 1 }
                    if sIdx == 0 || isWordStart(lowerS, at: sIdx) { score += 20 }
                    if lastMatch >= 0 && sIdx == lastMatch + 1 { score += 6 }
                    let gap = sIdx - (lastMatch + 1)
                    if gap > 0 { score -= gap }
                    lastMatch = sIdx
                    sIdx += 1
                    matched = true
                    break
                }
                sIdx += 1
            }
            if !matched { return nil }
        }
        if lowerS.starts(with: lowerQ) { score += 60 }
        return score
    }

    static func rank(query: String, candidates: [String], limit: Int = 20) -> [(candidate: String, score: Int)] {
        candidates.compactMap { candidate -> (String, Int)? in
            let name = (candidate as NSString).lastPathComponent
            let nameScore = score(query: query, in: name) ?? -1
            let pathScore = score(query: query, in: candidate) ?? -1
            let best = max(nameScore, pathScore >= 0 ? pathScore - 4 : -1)
            return best >= 0 ? (candidate, best) : nil
        }
        .sorted { lhs, rhs in
            lhs.1 == rhs.1 ? lhs.0 < rhs.0 : lhs.1 > rhs.1
        }
        .prefix(limit)
        .map { $0 }
    }

    private static func isWordStart(_ chars: [Character], at idx: Int) -> Bool {
        guard idx > 0 else { return true }
        switch chars[idx - 1] {
        case " ", ".", "-", "_", "/", ":": return true
        default: return false
        }
    }
}

enum FuzzyPathResolver {
    static func bestMatch(query: String, root: String, fileManager: FileManager = .default) -> String? {
        let candidates = scanFiles(root: root, fileManager: fileManager)
        return FileFuzzyMatcher.rank(query: query, candidates: candidates, limit: 2).first?.candidate
    }

    static func rankedMatches(query: String, root: String, limit: Int = 10, fileManager: FileManager = .default) -> [String] {
        FileFuzzyMatcher.rank(query: query, candidates: scanFiles(root: root, fileManager: fileManager), limit: limit)
            .map(\.candidate)
    }

    private static func scanFiles(root: String, fileManager: FileManager) -> [String] {
        guard let enumerator = fileManager.enumerator(
            at: URL(fileURLWithPath: root),
            includingPropertiesForKeys: [.isRegularFileKey, .isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else { return [] }
        var files: [String] = []
        for case let url as URL in enumerator {
            let name = url.lastPathComponent
            if ["node_modules", ".build", "DerivedData", "dist"].contains(name) {
                enumerator.skipDescendants()
                continue
            }
            guard (try? url.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile) == true else { continue }
            files.append(url.path)
            if files.count >= 5_000 { break }
        }
        return files
    }
}
