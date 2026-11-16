import Foundation

/// Drain temporary Foundation JSON objects once per record during long history scans.
func historyJSONObject(_ line: Data) -> [String: Any]? {
    #if canImport(ObjectiveC)
    autoreleasepool { try? JSONSerialization.jsonObject(with: line) as? [String: Any] }
    #else
    try? JSONSerialization.jsonObject(with: line) as? [String: Any]
    #endif
}

/// Repeatable bounded reader for history parser passes. Errors remain visible to the caller.
final class AgentHistoryJSONLSequence: Sequence {
    private let url: URL
    private(set) var failed = false
    let count: Int
    let fileSize: Int
    private let modifiedAt: Date

    var isValid: Bool {
        guard !failed, let values = try? url.resourceValues(forKeys: [.contentModificationDateKey, .fileSizeKey]) else { return false }
        return values.fileSize == fileSize && values.contentModificationDate == modifiedAt
    }

    init?(url: URL) {
        self.url = url
        guard let values = try? url.resourceValues(forKeys: [.contentModificationDateKey, .fileSizeKey]),
              let modifiedAt = values.contentModificationDate else { return nil }
        self.modifiedAt = modifiedAt
        guard let result = try? AgentHistoryScanner.forEachJSONLLine(from: url, { _, _ in }), result.lineCount > 0 else { return nil }
        count = result.lineCount
        fileSize = result.fileSize
        guard values.fileSize == fileSize, isValid else { return nil }
    }

    func makeIterator() -> Iterator {
        Iterator(owner: self, url: url)
    }

    final class Iterator: IteratorProtocol {
        private let owner: AgentHistoryJSONLSequence
        private var handle: FileHandle?
        private var chunk = Data()
        private var position = 0
        private var record = Data()
        private var eof = false

        init(owner: AgentHistoryJSONLSequence, url: URL) {
            self.owner = owner
            do { handle = try FileHandle(forReadingFrom: url) }
            catch { owner.failed = true; eof = true }
        }

        deinit { try? handle?.close() }

        func next() -> Data? {
            while true {
                if position == chunk.count && !eof {
                    do {
                        chunk = try handle?.read(upToCount: 64 * 1024) ?? Data()
                        position = 0
                        eof = chunk.isEmpty
                    } catch {
                        owner.failed = true
                        eof = true
                        return nil
                    }
                }
                if eof && position == chunk.count {
                    guard !record.isEmpty else { return nil }
                    let line = trimmedRecord()
                    if let line { return line }
                    return nil
                }
                let end = chunk[position...].firstIndex(of: 10) ?? chunk.endIndex
                record.append(chunk[position..<end])
                position = end < chunk.endIndex ? end + 1 : end
                if record.count > AgentHistoryScanner.maxJSONLRecordBytes {
                    owner.failed = true
                    eof = true
                    return nil
                }
                if end < chunk.endIndex, let line = trimmedRecord() { return line }
            }
        }

        private func trimmedRecord() -> Data? {
            defer { record.removeAll(keepingCapacity: false) }
            var start = record.startIndex
            var end = record.endIndex
            while start < end && [UInt8(0x20), 0x09, 0x0D].contains(record[start]) { start += 1 }
            while end > start && [UInt8(0x20), 0x09, 0x0D].contains(record[end - 1]) { end -= 1 }
            return start < end ? Data(record[start..<end]) : nil
        }
    }
}
