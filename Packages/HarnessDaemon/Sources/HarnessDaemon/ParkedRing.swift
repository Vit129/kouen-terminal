import Foundation

/// Sealed history blocks remain compressed while new output grows a separate hot tail.
struct ParkedRing: Equatable {
    private struct Block: Equatable {
        var stored: Data
        var rawCount: Int
        var compressed: Bool
        init(_ bytes: Data) {
            rawCount = bytes.count
            if let packed = RingCodec.compress(bytes), packed.count < bytes.count {
                stored = packed; compressed = true
            } else { stored = bytes; compressed = false }
        }
        var bytes: Data {
            guard compressed else { return stored }
            guard let bytes = RingCodec.decompress(stored), bytes.count == rawCount else {
                preconditionFailure("In-memory terminal history block is corrupt")
            }
            return bytes
        }
    }
    var sequence: UInt64
    private var blocks: [Block?] = []
    private var head = 0
    private var liveBlocks: ArraySlice<Block?> { blocks[head...] }
    private(set) var rawCount = 0
    var storedByteCount: Int { liveBlocks.reduce(0) { $0 + $1!.stored.count } }
    var stored: Data { liveBlocks.reduce(into: Data()) { $0.append($1!.stored) } }
    var compressed: Bool { liveBlocks.contains { $0!.compressed } }
    var bytes: Data { liveBlocks.reduce(into: Data()) { $0.append($1!.bytes) } }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.sequence == rhs.sequence && lhs.rawCount == rhs.rawCount && lhs.liveBlocks.elementsEqual(rhs.liveBlocks)
    }

    init(sequence: UInt64, bytes: Data) {
        self.sequence = sequence
        append(bytes)
    }
    mutating func append(_ bytes: Data) {
        var offset = 0
        while offset < bytes.count {
            let end = min(offset + 16384, bytes.count)
            blocks.append(Block(bytes.subdata(in: offset..<end)))
            offset = end
        }
        rawCount += bytes.count
    }
    mutating func keepSuffix(atMost budget: Int) {
        while rawCount > budget, head < blocks.count {
            let removed = blocks[head]!.rawCount
            blocks[head] = nil // Release the payload immediately, without shifting survivors.
            head += 1
            rawCount -= removed
            sequence += UInt64(removed)
        }
        if head == blocks.count {
            blocks.removeAll(keepingCapacity: false)
            head = 0
        } else if head >= 1024, head >= blocks.count - head {
            // Each compaction moves no more blocks than have been evicted since the last
            // compaction, keeping sustained output eviction amortized O(1) per block.
            blocks.removeFirst(head)
            head = 0
        }
    }
    func segments(fromSequence floor: UInt64? = nil, toSequence end: UInt64? = nil) -> [RealPty.ScrollbackReplaySegment] {
        var start = sequence
        return liveBlocks.compactMap { storedBlock in
            let block = storedBlock!
            defer { start += UInt64(block.rawCount) }
            if let floor, start + UInt64(block.rawCount) <= floor { return nil }
            if let end, start >= end { return nil }
            return RealPty.ScrollbackReplaySegment(sequence: start, data: block.bytes)
        }
    }
}

/// LZ4 through Apple's Compression framework, which favors speed over ratio: terminal output
/// is repetitive enough that LZ4 alone shrinks it several times over. Platforms without it keep
/// the bytes as they are.
enum RingCodec {
    static func compress(_ data: Data) -> Data? {
        #if canImport(Darwin)
        guard !data.isEmpty else { return nil }
        return try? (data as NSData).compressed(using: .lz4) as Data
        #else
        return nil
        #endif
    }

    static func decompress(_ data: Data) -> Data? {
        #if canImport(Darwin)
        return try? (data as NSData).decompressed(using: .lz4) as Data
        #else
        return nil
        #endif
    }
}
