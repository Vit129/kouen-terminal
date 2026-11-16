import Foundation

/// Disk-backed UTF-8 transcript text used while building an FTS entry. Appending a transcript does
/// not retain its contents in memory; indexing reads bounded chunks with overlap for cross-boundary
/// search terms.
public final class AgentHistoryTranscriptSpool: @unchecked Sendable {
    private let url: URL
    private let writer: FileHandle

    public init() throws {
        url = FileManager.default.temporaryDirectory.appendingPathComponent("kouen-history-\(UUID().uuidString).spool")
        guard FileManager.default.createFile(atPath: url.path, contents: nil, attributes: [.posixPermissions: 0o600]) else {
            throw CocoaError(.fileWriteUnknown)
        }
        do {
            writer = try FileHandle(forWritingTo: url)
        } catch {
            try? FileManager.default.removeItem(at: url)
            throw error
        }
    }

    public func append(_ text: String) throws {
        guard !text.isEmpty else { return }
        try writer.write(contentsOf: Data(text.utf8))
    }

    /// Emits FTS strings bounded to `chunkBytes + overlapBytes`. The overlap retains search terms
    /// that cross a chunk boundary; the consumer must deduplicate session-level search results.
    public func forEachChunk(
        chunkBytes: Int = 256 * 1024,
        overlapBytes: Int = 16 * 1024,
        _ body: (String) throws -> Void
    ) throws {
        try writer.synchronize()
        let reader = try FileHandle(forReadingFrom: url)
        defer { try? reader.close() }

        var pending = Data()
        var carry = Data()
        var eof = false
        var consumed = 0
        while !eof || consumed < pending.count {
            if !eof {
                // Look ahead so a UTF-8 scalar split exactly at a read boundary can be
                // moved intact into the following chunk.
                let next = try reader.read(upToCount: chunkBytes + 4) ?? Data()
                eof = next.isEmpty
                pending.append(next)
            }
            let available = pending.count - consumed
            guard available > 0 else { continue }
            let target = min(available, chunkBytes)
            guard eof || available > chunkBytes else { continue }

            var end = consumed + target
            while end > consumed, end < pending.count, pending[end] & 0xC0 == 0x80 { end -= 1 }
            guard end > consumed else { throw CocoaError(.fileReadCorruptFile) }
            var chunk = carry
            chunk.append(pending[consumed..<end])
            guard let text = String(data: chunk, encoding: .utf8) else { throw CocoaError(.fileReadCorruptFile) }
            try body(text)

            let tailStart = max(0, chunk.count - overlapBytes)
            var safeTailStart = tailStart
            while safeTailStart < chunk.count, chunk[safeTailStart] & 0xC0 == 0x80 { safeTailStart += 1 }
            carry = Data(chunk[safeTailStart...])
            consumed = end
            if consumed > chunkBytes {
                pending.removeSubrange(0..<consumed)
                consumed = 0
            }
        }
    }

    deinit {
        try? writer.close()
        try? FileManager.default.removeItem(at: url)
    }
}
