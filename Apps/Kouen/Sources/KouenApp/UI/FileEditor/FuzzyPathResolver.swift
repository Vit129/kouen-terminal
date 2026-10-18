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

enum FuzzyPathResolution: Equatable {
    case none
    case unique(String)
    case ambiguous([String])
}

enum FuzzyPathResolver {
    private static let clearWinnerMargin = 12

    static func bestMatch(query: String, root: String, fileManager: FileManager = .default) -> String? {
        switch resolve(query: query, root: root, limit: 5, fileManager: fileManager) {
        case .unique(let path): return path
        default: return nil
        }
    }

    static func rankedMatches(query: String, root: String, limit: Int = 10, fileManager: FileManager = .default) -> [String] {
        FileFuzzyMatcher.rank(query: query, candidates: scanFiles(root: root, fileManager: fileManager), limit: limit)
            .map(\.candidate)
    }

    static func resolve(
        query: String, root: String, limit: Int = 10,
        otherRoots: [String] = FuzzyPathResolver.defaultOtherRoots(),
        fileManager: FileManager = .default
    ) -> FuzzyPathResolution {
        // Absolute path that exists on disk → skip fuzzy scan entirely
        if query.hasPrefix("/"), fileManager.fileExists(atPath: query) { return .unique(query) }
        let local = resolve(query: query, ranked: FileFuzzyMatcher.rank(query: query, candidates: scanFiles(root: root, fileManager: fileManager), limit: limit))
        guard local == .none else { return local }
        // Nothing in this project: try the other recent projects, so a file named in another
        // repo (e.g. a central notes repo) still opens.
        // ponytail: scans each recent project in full on a miss; fine for the 10 recents kept.
        // Upgrade: a per-root file index if misses get slow.
        let others = otherRoots.filter { $0 != root && !root.hasPrefix($0 + "/") }
        return resolve(query: query, ranked: FileFuzzyMatcher.rank(
            query: query, candidates: others.flatMap { scanFiles(root: $0, fileManager: fileManager) }, limit: limit))
    }

    /// Settings › Files search folders first, then the recent projects. Settings live on the
    /// main actor; an off-main caller gets the recents only.
    static func defaultOtherRoots() -> [String] {
        let extra = Thread.isMainThread ? MainActor.assumeIsolated { SessionCoordinator.shared.settings.fileSearchRoots } : []
        var seen = Set<String>()
        return (extra + (UserDefaults.standard.stringArray(forKey: "RecentProjectPaths") ?? []))
            .filter { seen.insert($0).inserted }
    }

    static func newestModified(_ paths: [String]) -> String? {
        paths.max {
            let a = (try? FileManager.default.attributesOfItem(atPath: $0)[.modificationDate] as? Date) ?? .distantPast
            let b = (try? FileManager.default.attributesOfItem(atPath: $1)[.modificationDate] as? Date) ?? .distantPast
            return a < b
        }
    }

    static func resolve(query: String, ranked: [(candidate: String, score: Int)]) -> FuzzyPathResolution {
        guard let first = ranked.first else { return .none }
        guard ranked.count > 1 else { return .unique(first.candidate) }
        let second = ranked[1]
        if first.score - second.score >= clearWinnerMargin {
            return .unique(first.candidate)
        }
        return .ambiguous(ranked.map(\.candidate))
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

/// Finds folders worth adding to Settings › Files › search folders: notes repos that agents write
/// plans and memory to outside the project (`agent-memory` folders under `~/Git`).
enum FileSearchRootScanner {
    static func scan(base: URL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Git"),
                     maxDepth: Int = 4, fileManager: FileManager = .default) -> [String] {
        guard let walker = fileManager.enumerator(at: base, includingPropertiesForKeys: [.isDirectoryKey],
                                                  options: [.skipsHiddenFiles, .skipsPackageDescendants]) else { return [] }
        var found: [String] = []
        for case let url as URL in walker {
            guard (try? url.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true else { continue }
            let name = url.lastPathComponent
            if walker.level > maxDepth || ["node_modules", ".build", "DerivedData", "dist", ".kouen-worktrees"].contains(name) {
                walker.skipDescendants(); continue
            }
            if name == "agent-memory" { found.append(url.path); walker.skipDescendants() }
        }
        return found.sorted()
    }
}
