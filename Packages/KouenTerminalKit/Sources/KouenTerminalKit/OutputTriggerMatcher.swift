import Foundation

/// Matches output-trigger patterns across chunk boundaries by keeping the tail of the
/// previous chunk. A pattern that lies wholly inside that tail already fired and is not
/// reported again.
struct OutputTriggerMatcher {
    private var tail = ""

    mutating func matches(in text: String, patterns: [String]) -> [String] {
        let window = tail + text
        let hits = patterns.filter { p in
            !p.isEmpty && window.localizedCaseInsensitiveContains(p) && !tail.localizedCaseInsensitiveContains(p)
        }
        let keep = max(0, (patterns.map(\.count).max() ?? 1) - 1)
        tail = String(window.suffix(keep))
        return hits
    }
}
