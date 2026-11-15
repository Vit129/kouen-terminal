import Foundation

/// Matches output-trigger patterns across chunk boundaries by keeping the tail of the
/// previous chunk. A pattern that lies wholly inside that tail already fired and is not
/// reported again.
struct OutputTriggerMatcher {
    private var tail = ""
    private var pendingUTF8 = Data()

    mutating func matches(in data: Data, patterns: [String]) -> [String] {
        var bytes = pendingUTF8
        bytes.append(data)
        var end = bytes.endIndex
        // A capped PTY slice can end mid-scalar. Retain only that incomplete suffix
        // (at most three bytes); repair malformed interior bytes instead of dropping output.
        for index in bytes.indices.reversed().prefix(3) {
            let byte = bytes[index]
            if byte & 0xC0 == 0x80 { continue }
            let length: Int
            switch byte {
            case 0xC2...0xDF: length = 2
            case 0xE0...0xEF: length = 3
            case 0xF0...0xF4: length = 4
            default: length = 1
            }
            if bytes.distance(from: index, to: bytes.endIndex) < length { end = index }
            break
        }
        pendingUTF8 = Data(bytes[end...])
        return matches(in: String(decoding: bytes[..<end], as: UTF8.self), patterns: patterns)
    }

    mutating func matches(in text: String, patterns: [String]) -> [String] {
        let window = tail + text
        let previousEnd = tail.utf16.count
        let hits = patterns.filter { p in
            guard !p.isEmpty,
                  let match = window.range(of: p, options: [.caseInsensitive, .backwards], locale: .current) else { return false }
            return NSRange(match, in: window).upperBound > previousEnd
        }
        // Keep the final grapheme too: a following combining scalar or ZWJ can extend it.
        let keep = patterns.map(\.count).max() ?? 0
        tail = String(window.suffix(keep))
        return hits
    }
}
