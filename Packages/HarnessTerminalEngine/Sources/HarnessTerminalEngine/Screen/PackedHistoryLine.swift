import Foundation

private struct HistoryStyle: Hashable, Sendable {
    let foregroundBackground: UInt64
    let underlineAttributes: UInt64

    init(_ cell: TerminalGridCell) {
        foregroundBackground = UInt64(cell.foregroundWord) | UInt64(cell.backgroundWord) << 32
        underlineAttributes = UInt64(cell.underlineColorWord) | UInt64(cell.attributes & ~0x1800) << 32
    }

    var cell: TerminalGridCell {
        var cell = TerminalGridCell()
        cell.foregroundWord = UInt32(truncatingIfNeeded: foregroundBackground)
        cell.backgroundWord = UInt32(truncatingIfNeeded: foregroundBackground >> 32)
        cell.underlineColorWord = UInt32(truncatingIfNeeded: underlineAttributes)
        cell.attributes = UInt16(truncatingIfNeeded: underlineAttributes >> 32)
        return cell
    }
}

private struct HistoryStyleRun: Sendable {
    let start: UInt16
    let style: UInt16
}

private struct HistoryMetadata: Sendable {
    let column: UInt16
    let width: UInt16
    let combining0: UInt32
    let combining1: UInt32
    let hyperlink: UInt32
    let placeholder: UInt16
}

private struct HistoryRowLocation: Sendable {
    let offset: Int
    let count: Int
    let ascii: Bool
    let runs: Range<Int>
    let metadata: Range<Int>
}

/// One bounded, append-only block owns row payloads. Snapshot reads and buffer growth
/// synchronize; rows retain offsets, so reallocating the byte slab cannot invalidate them.
final class PackedHistoryBlock: @unchecked Sendable {
    // Only the owning screen changes accounting; snapshot readers never access these.
    var retainedRows = 0
    var retainedBytes = 0
    private let lock = NSLock()
    private var characters: UnsafeMutableRawPointer?
    private var characterCount = 0
    private var characterCapacity = 0
    private var styles = [HistoryStyle(.blank)]
    private var indices: [HistoryStyle: UInt16] = [:]
    private var runs: [HistoryStyleRun] = []
    private var metadata: [HistoryMetadata] = []
    private var encodedRows = 0

    deinit { characters?.deallocate() }

    var isFull: Bool { encodedRows >= 128 || styles.count >= 512 }
    var bytes: Int {
        characterCapacity + styles.capacity * MemoryLayout<HistoryStyle>.stride + indices.capacity * 32 +
            runs.capacity * MemoryLayout<HistoryStyleRun>.stride + metadata.capacity * MemoryLayout<HistoryMetadata>.stride + 96
    }

    private func reserveCharacters(_ count: Int) {
        guard count > characterCapacity else { return }
        let capacity = max(256, 1 << (Int.bitWidth - (count - 1).leadingZeroBitCount))
        let next = UnsafeMutableRawPointer.allocate(byteCount: capacity, alignment: MemoryLayout<UInt32>.alignment)
        if let characters {
            next.copyMemory(from: characters, byteCount: characterCount)
            characters.deallocate()
        }
        characters = next
        characterCapacity = capacity
    }

    fileprivate func encode(_ cells: UnsafeBufferPointer<TerminalGridCell>) -> HistoryRowLocation {
        lock.lock()
        defer { lock.unlock() }
        var end = cells.count
        while end > 0, Self.isDefaultBlank(cells[end - 1]) { end -= 1 }
        let offset = characterCount
        let runStart = runs.count
        let metadataStart = metadata.count
        guard end > 0 else {
            encodedRows += 1
            return HistoryRowLocation(offset: offset, count: 0, ascii: true,
                runs: runStart..<runStart, metadata: metadataStart..<metadataStart)
        }
        reserveCharacters(offset + end * 4)
        let bytes = characters!.advanced(by: offset)
        let defaultStyle = styles[0]
        var ascii = true
        var previous = defaultStyle
        for column in 0..<end {
            let cell = cells[column]
            if ascii, cell.codepoint < 128 {
                bytes.storeBytes(of: UInt8(cell.codepoint), toByteOffset: column, as: UInt8.self)
            } else {
                if ascii {
                    for index in (0..<column).reversed() {
                        let value = UInt32(bytes.load(fromByteOffset: index, as: UInt8.self))
                        Self.writeScalar(value, to: bytes, at: index * 4)
                    }
                    ascii = false
                }
                Self.writeScalar(cell.codepoint, to: bytes, at: column * 4)
            }
            let style = HistoryStyle(cell)
            if column == 0 || style != previous {
                let id: UInt16
                if style == defaultStyle { id = 0 }
                else if let existing = indices[style] { id = existing }
                else { id = UInt16(styles.count); styles.append(style); indices[style] = id }
                runs.append(HistoryStyleRun(start: UInt16(column), style: id))
                previous = style
            }
            if cell.combining0 | cell.combining1 | cell.hyperlinkID | UInt32(cell.placeholderMark) | UInt32(cell.attributes & 0x1800) != 0 {
                metadata.append(HistoryMetadata(column: UInt16(column), width: cell.width.rawValue,
                    combining0: cell.combining0, combining1: cell.combining1,
                    hyperlink: cell.hyperlinkID, placeholder: cell.placeholderMark))
            }
        }
        characterCount += end * (ascii ? 1 : 4)
        encodedRows += 1
        return HistoryRowLocation(offset: offset, count: end, ascii: ascii,
            runs: runStart..<runs.count, metadata: metadataStart..<metadata.count)
    }

    @inline(__always)
    private static func writeScalar(_ scalar: UInt32, to bytes: UnsafeMutableRawPointer, at offset: Int) {
        bytes.storeBytes(of: UInt8(truncatingIfNeeded: scalar), toByteOffset: offset, as: UInt8.self)
        bytes.storeBytes(of: UInt8(truncatingIfNeeded: scalar >> 8), toByteOffset: offset + 1, as: UInt8.self)
        bytes.storeBytes(of: UInt8(truncatingIfNeeded: scalar >> 16), toByteOffset: offset + 2, as: UInt8.self)
        bytes.storeBytes(of: UInt8(truncatingIfNeeded: scalar >> 24), toByteOffset: offset + 3, as: UInt8.self)
    }

    @inline(__always)
    private static func isDefaultBlank(_ cell: TerminalGridCell) -> Bool {
        let words = SIMD8<UInt32>(cell.codepoint, cell.combining0, cell.combining1,
            cell.foregroundWord, cell.backgroundWord, cell.underlineColorWord,
            UInt32(cell.attributes) | UInt32(cell.placeholderMark) << 16, cell.hyperlinkID)
        return !any(words .!= .zero)
    }

    fileprivate func decode(_ location: HistoryRowLocation, columns: Int) -> [TerminalGridCell] {
        lock.lock()
        defer { lock.unlock() }
        let bytes = characters
        return Array(unsafeUninitializedCapacity: columns) { buffer, initialized in
            guard let base = buffer.baseAddress else { initialized = 0; return }
            for index in location.runs {
                let run = runs[index]
                let end = index + 1 < location.runs.upperBound ? Int(runs[index + 1].start) : location.count
                var cell = styles[Int(run.style)].cell
                for column in Int(run.start)..<end {
                    cell.codepoint = location.ascii
                        ? UInt32(bytes!.load(fromByteOffset: location.offset + column, as: UInt8.self))
                        : bytes!.loadUnaligned(fromByteOffset: location.offset + column * 4, as: UInt32.self).littleEndian
                    base.advanced(by: column).initialize(to: cell)
                }
            }
            for index in location.metadata {
                let entry = metadata[index]
                let column = Int(entry.column)
                base[column].combining0 = entry.combining0
                base[column].combining1 = entry.combining1
                base[column].hyperlinkID = entry.hyperlink
                base[column].placeholderMark = entry.placeholder
                base[column].width = TerminalCellWidth(rawValue: entry.width)!
            }
            if location.count < columns { base.advanced(by: location.count).initialize(repeating: .blank, count: columns - location.count) }
            initialized = columns
        }
    }

    fileprivate func collectClusterIDs(_ location: HistoryRowLocation, into live: inout Set<UInt32>) {
        lock.lock()
        defer { lock.unlock() }
        for index in location.metadata {
            let entry = metadata[index]
            if entry.combining1 & 0x8000_0000 != 0 { live.insert(entry.combining1 & 0x7fff_ffff) }
        }
    }
}

struct PackedHistoryLine: Sendable {
    let block: PackedHistoryBlock
    private let location: HistoryRowLocation
    private let columns: Int
    var wrapped: Bool
    var wideDeferred: Bool
    var mark: SemanticMark?

    init(
        cells: [TerminalGridCell],
        wrapped: Bool,
        wideDeferred: Bool = false,
        mark: SemanticMark? = nil,
        block: PackedHistoryBlock
    ) {
        self = cells.withUnsafeBufferPointer {
            Self(cells: $0, wrapped: wrapped, wideDeferred: wideDeferred, mark: mark, block: block)
        }
    }

    init(
        cells: UnsafeBufferPointer<TerminalGridCell>,
        wrapped: Bool,
        wideDeferred: Bool = false,
        mark: SemanticMark? = nil,
        block: PackedHistoryBlock
    ) {
        columns = cells.count
        self.wrapped = wrapped
        self.wideDeferred = wideDeferred
        self.mark = mark
        self.block = block
        location = block.encode(cells)
    }

    var cells: [TerminalGridCell] { block.decode(location, columns: columns) }
    var reflowCells: [TerminalGridCell] { block.decode(location, columns: wrapped ? columns : location.count) }

    func collectClusterIDs(into live: inout Set<UInt32>) { block.collectClusterIDs(location, into: &live) }
}
