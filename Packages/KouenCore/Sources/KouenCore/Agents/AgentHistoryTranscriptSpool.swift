import Foundation

/// Disk-backed UTF-8 transcript text used while building an FTS entry. Appending a transcript does
/// not retain its contents in memory; indexing reads bounded chunks with overlap for cross-boundary
/// search terms.
public final class AgentHistoryTranscriptSpool: @unchecked Sendable {
    final class Budget: @unchecked Sendable {
        let perSpool: Int
        private let total: Int
        private let lock = NSLock()
        private var reserved = 0

        init(perSpool: Int, total: Int) {
            precondition(perSpool > 0 && total > 0)
            self.perSpool = perSpool
            self.total = total
        }

        func reserve(_ bytes: Int) -> Bool {
            lock.withLock {
                guard bytes <= total - reserved else { return false }
                reserved += bytes
                return true
            }
        }

        func release(_ bytes: Int) {
            lock.withLock { reserved -= bytes }
        }
    }

    private static let directoryName = "kouen-history-spools"
    private static let filePrefix = "kouen-history-"
    private static let fileSuffix = ".spool"
    private static let sharedBudget = Budget(perSpool: 32 * 1024 * 1024, total: 256 * 1024 * 1024)
    private static let startupSweep: Void = {
        let temp = FileManager.default.temporaryDirectory
        sweepStale(
            in: temp,
            directory: temp.appendingPathComponent(directoryName),
            olderThan: Date().addingTimeInterval(-24 * 60 * 60)
        )
    }()

    static func sweepAtStartup() {
        _ = startupSweep
    }

    private let directoryFD: Int32
    private let name: String
    private let writer: FileHandle
    private let budget: Budget
    private let lock = NSLock()
    private var reserved = 0
    private var writeFailed = false

    public convenience init() throws {
        try self.init(budget: Self.sharedBudget)
    }

    init(budget: Budget, directory: URL? = nil) throws {
        Self.sweepAtStartup()
        let root = try directory ?? Self.prepareDirectory(in: FileManager.default.temporaryDirectory)
        let dirFD = Self.openPrivateDirectory(root)
        guard dirFD >= 0 else { throw CocoaError(.fileWriteUnknown) }
        let filename = Self.filePrefix + UUID().uuidString + Self.fileSuffix
        let fd = openat(dirFD, filename, O_RDWR | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC, 0o600)
        guard fd >= 0 else {
            close(dirFD)
            throw CocoaError(.fileWriteUnknown)
        }
        guard flock(fd, LOCK_EX | LOCK_NB) == 0 else {
            unlinkat(dirFD, filename, 0)
            close(fd)
            close(dirFD)
            throw CocoaError(.fileWriteUnknown)
        }
        directoryFD = dirFD
        name = filename
        writer = FileHandle(fileDescriptor: fd, closeOnDealloc: true)
        self.budget = budget
    }

    static func prepareDirectory(in temp: URL) throws -> URL {
        let directory = temp.appendingPathComponent(directoryName)
        guard mkdir(directory.path, 0o700) == 0 || errno == EEXIST else {
            throw CocoaError(.fileWriteUnknown)
        }
        guard let resolved = validatedDirectory(in: temp, directory: directory) else {
            throw CocoaError(.fileWriteNoPermission)
        }
        return resolved
    }

    private static func validatedDirectory(in temp: URL, directory: URL) -> URL? {
        let expected = temp.resolvingSymlinksInPath().standardizedFileURL.appendingPathComponent(directoryName)
        let resolved = directory.resolvingSymlinksInPath().standardizedFileURL
        guard resolved.path == expected.path,
              directory.lastPathComponent == directoryName,
              let values = try? directory.resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey]),
              values.isDirectory == true, values.isSymbolicLink == false else { return nil }
        return resolved
    }

    private static func openPrivateDirectory(_ root: URL) -> Int32 {
        let fd = open(root.path, O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC)
        guard fd >= 0 else { return -1 }
        var info = stat()
        guard fstat(fd, &info) == 0, info.st_uid == geteuid(), info.st_mode & 0o077 == 0 else {
            close(fd)
            return -1
        }
        return fd
    }

    static func sweepStale(in temp: URL, directory: URL, olderThan cutoff: Date) {
        guard let root = validatedDirectory(in: temp, directory: directory) else { return }
        let dirFD = openPrivateDirectory(root)
        guard dirFD >= 0 else { return }
        defer { close(dirFD) }
        guard let names = try? FileManager.default.contentsOfDirectory(atPath: root.path) else { return }
        for name in names {
            guard name.hasPrefix(filePrefix), name.hasSuffix(fileSuffix),
                  UUID(uuidString: String(name.dropFirst(filePrefix.count).dropLast(fileSuffix.count))) != nil else { continue }
            let candidate = root.appendingPathComponent(name).resolvingSymlinksInPath().standardizedFileURL
            guard candidate.path.hasPrefix(root.path + "/") else { continue }

            // Anchor lookup and deletion to the opened directory. A no-follow open plus an
            // exclusive nonblocking lock excludes symlinks and spools in use by another process.
            let fd = openat(dirFD, name, O_RDONLY | O_NOFOLLOW | O_NONBLOCK | O_CLOEXEC)
            guard fd >= 0 else { continue }
            defer { close(fd) }
            var info = stat()
            guard fstat(fd, &info) == 0, info.st_mode & S_IFMT == S_IFREG,
                  flock(fd, LOCK_EX | LOCK_NB) == 0 else { continue }
            #if canImport(Darwin)
            let modified = info.st_mtimespec
            #else
            let modified = info.st_mtim
            #endif
            let timestamp = Double(modified.tv_sec) + Double(modified.tv_nsec) / 1_000_000_000
            var current = stat()
            guard timestamp < cutoff.timeIntervalSince1970,
                  fstatat(dirFD, name, &current, AT_SYMLINK_NOFOLLOW) == 0,
                  current.st_dev == info.st_dev, current.st_ino == info.st_ino else { continue }
            unlinkat(dirFD, name, 0)
        }
    }

    public func append(_ text: String) throws {
        let bytes = text.utf8.count
        guard bytes > 0 else { return }
        guard lock.try() else { throw CocoaError(.fileWriteUnknown) }
        defer { lock.unlock() }
        guard !writeFailed, bytes <= budget.perSpool - reserved, budget.reserve(bytes) else {
            throw CocoaError(.fileWriteOutOfSpace)
        }
        reserved += bytes
        do {
            try writer.write(contentsOf: Data(text.utf8))
        } catch {
            writeFailed = true
            throw error
        }
    }

    /// Emits FTS strings bounded to `chunkBytes + overlapBytes`. The overlap retains search terms
    /// that cross a chunk boundary; the consumer must deduplicate session-level search results.
    public func forEachChunk(
        chunkBytes: Int = 256 * 1024,
        overlapBytes: Int = 16 * 1024,
        _ body: (String) throws -> Void
    ) throws {
        lock.lock()
        defer { lock.unlock() }
        guard !writeFailed else { throw CocoaError(.fileReadCorruptFile) }
        let fd = openat(directoryFD, name, O_RDONLY | O_NOFOLLOW | O_CLOEXEC)
        guard fd >= 0 else { throw CocoaError(.fileReadUnknown) }
        let reader = FileHandle(fileDescriptor: fd, closeOnDealloc: true)
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
        unlinkat(directoryFD, name, 0)
        try? writer.close()
        close(directoryFD)
        budget.release(reserved)
    }
}
