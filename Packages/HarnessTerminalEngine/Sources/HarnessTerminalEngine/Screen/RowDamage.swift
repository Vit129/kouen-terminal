import Foundation

/// Fixed-size viewport damage. Scrolls shift words in place rather than allocating IndexSets.
struct RowDamage {
    private var words: [UInt64]
    private let rowCount: Int

    init(rows: Int) {
        rowCount = rows
        words = Array(repeating: 0, count: (rows + 63) / 64)
    }

    var isEmpty: Bool { words.allSatisfy { $0 == 0 } }

    mutating func insert(_ row: Int) {
        words[row >> 6] |= UInt64(1) << (row & 63)
    }

    mutating func insert(_ range: Range<Int>) {
        guard !range.isEmpty else { return }
        let first = range.lowerBound >> 6
        let last = (range.upperBound - 1) >> 6
        for index in first...last {
            let low = index == first ? range.lowerBound & 63 : 0
            let high = index == last ? ((range.upperBound - 1) & 63) + 1 : 64
            let upperMask = high == 64 ? UInt64.max : (UInt64(1) << high) - 1
            words[index] |= upperMask & (UInt64.max << low)
        }
    }

    mutating func shift(by delta: Int) {
        guard delta != 0 else { return }
        guard abs(delta) < rowCount else { clear(); return }
        let offset = abs(delta) >> 6
        let bits = abs(delta) & 63
        if delta > 0 {
            for destination in words.indices.reversed() {
                let source = destination - offset
                var value: UInt64 = source >= 0 ? words[source] << bits : 0
                if bits != 0, source > 0 { value |= words[source - 1] >> (64 - bits) }
                words[destination] = value
            }
        } else {
            for destination in words.indices {
                let source = destination + offset
                var value: UInt64 = source < words.count ? words[source] >> bits : 0
                if bits != 0, source + 1 < words.count { value |= words[source + 1] << (64 - bits) }
                words[destination] = value
            }
        }
        if rowCount & 63 != 0 { words[words.count - 1] &= (UInt64(1) << (rowCount & 63)) - 1 }
    }

    mutating func clear() {
        words.withUnsafeMutableBufferPointer { $0.baseAddress!.update(repeating: 0, count: $0.count) }
    }

    var indexSet: IndexSet {
        var result = IndexSet()
        for (index, word) in words.enumerated() {
            var remaining = word
            while remaining != 0 {
                result.insert(index * 64 + remaining.trailingZeroBitCount)
                remaining &= remaining - 1
            }
        }
        return result
    }
}
