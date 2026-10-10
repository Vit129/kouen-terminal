import Foundation

/// In-memory cache for graphify symbols and god nodes per project repository.
/// Reads `.graphify_labels.json` and `GRAPH_SUMMARY.md` at index-time to enrich FTS search terms
/// without any runtime overhead during search queries.
public final class GraphifyIndexCache: @unchecked Sendable {
    public static let shared = GraphifyIndexCache()
    private var cache: [String: Set<String>] = [:]
    private let lock = NSLock()

    public init() {}

    public func symbols(for projectPath: String) -> Set<String> {
        lock.lock()
        defer { lock.unlock() }
        if let cached = cache[projectPath] { return cached }

        var result = Set<String>()
        let labelsURL = URL(fileURLWithPath: projectPath).appendingPathComponent("graphify-out/.graphify_labels.json")
        if let data = try? Data(contentsOf: labelsURL),
           let dict = try? JSONSerialization.jsonObject(with: data) as? [String: String] {
            for label in dict.values {
                let clean = label.trimmingCharacters(in: .whitespacesAndNewlines)
                if clean.count >= 4 && !clean.hasPrefix("code:") && !clean.hasPrefix(".") {
                    result.insert(clean)
                }
            }
        }

        let summaryURL = URL(fileURLWithPath: projectPath).appendingPathComponent("graphify-out/GRAPH_SUMMARY.md")
        if let content = try? String(contentsOf: summaryURL, encoding: .utf8) {
            for line in content.components(separatedBy: .newlines) {
                if line.range(of: #"^\d+\.\s+`([^`]+)`"#, options: .regularExpression) != nil {
                    let sym = line.replacingOccurrences(of: #"^\d+\.\s+`"#, with: "", options: .regularExpression)
                                  .replacingOccurrences(of: #"`.*$"#, with: "", options: .regularExpression)
                    if sym.count >= 4 {
                        result.insert(sym)
                    }
                }
            }
        }

        cache[projectPath] = result
        return result
    }

    /// Enriches touched file paths with relevant symbol and god node names from graphify.
    public func enrich<S: Sequence>(files: S, projectPath: String) -> [String] where S.Element == String {
        let allSymbols = symbols(for: projectPath)
        guard !allSymbols.isEmpty else { return [] }

        var enriched = Set<String>()
        for file in files {
            let base = URL(fileURLWithPath: file).deletingPathExtension().lastPathComponent
            guard base.count >= 4 else { continue }
            if allSymbols.contains(base) {
                enriched.insert(base)
            }
            for s in allSymbols {
                if s.count >= 5 && (s.contains(base) || (base.count >= 8 && base.contains(s))) {
                    enriched.insert(s)
                    if enriched.count >= 20 { break }
                }
            }
        }
        return Array(enriched)
    }

    public func clear() {
        lock.lock()
        defer { lock.unlock() }
        cache.removeAll()
    }
}
