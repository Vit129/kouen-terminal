import Darwin
import Foundation
import KouenCore

enum StaleTemporaryFileSweeper {
    private static let patterns = [
        ("kouen-output-", ".spool"),
        ("kouen-attach-", ".spool"),
        ("kouen-history-", ".spool"),
        ("kouen-browser-", ".log"),
    ]

    static func processStartDate() -> Date? {
        var info = proc_bsdinfo()
        let bytes = proc_pidinfo(getpid(), PROC_PIDTBSDINFO, 0, &info, Int32(MemoryLayout<proc_bsdinfo>.size))
        guard bytes == Int32(MemoryLayout<proc_bsdinfo>.size) else { return nil }
        return Date(timeIntervalSince1970: TimeInterval(info.pbi_start_tvsec) + TimeInterval(info.pbi_start_tvusec) / 1_000_000)
    }

    static func hasOtherPotentialProducer() -> Bool {
        let pids = ProcessScan.livePIDs()
        guard !pids.isEmpty else { return true }
        for pid in pids where pid != getpid() {
            var info = proc_bsdinfo()
            let size = Int32(MemoryLayout<proc_bsdinfo>.size)
            guard proc_pidinfo(pid, PROC_PIDTBSDINFO, 0, &info, size) == size else { continue }
            guard info.pbi_uid == getuid() else { continue }
            var buffer = [UInt8](repeating: 0, count: Int(MAXPATHLEN))
            let length = buffer.withUnsafeMutableBufferPointer { proc_pidpath(pid, $0.baseAddress, UInt32(MAXPATHLEN)) }
            guard length > 0 else { return true }
            let name = URL(fileURLWithPath: String(decoding: buffer.prefix(Int(length)), as: UTF8.self)).lastPathComponent.lowercased()
            if name.contains("kouen") || name.contains("xctest") { return true }
        }
        return false
    }

    static func sweep(in directory: URL, processStart: Date, hasOtherProducer: () -> Bool = hasOtherPotentialProducer, log: (String) -> Void = { NSLog("Kouen: stale file cleanup: \($0)") }) {
        guard !hasOtherProducer() else { log("skipped because another potential producer is running or cannot be inspected"); return }
        guard let files = try? FileManager.default.contentsOfDirectory(atPath: directory.path) else { return }
        for name in files where patterns.contains(where: { name.hasPrefix($0.0) && name.hasSuffix($0.1) }) {
            let path = directory.appendingPathComponent(name).path
            var before = stat()
            guard lstat(path, &before) == 0, (before.st_mode & S_IFMT) == S_IFREG,
                  Date(timeIntervalSince1970: TimeInterval(before.st_mtimespec.tv_sec) + TimeInterval(before.st_mtimespec.tv_nsec) / 1_000_000_000) < processStart else { continue }
            guard !hasOtherProducer() else { log("stopped because another potential producer is running or cannot be inspected"); return }
            var current = stat()
            guard lstat(path, &current) == 0, before.st_dev == current.st_dev, before.st_ino == current.st_ino,
                  (current.st_mode & S_IFMT) == S_IFREG,
                  Date(timeIntervalSince1970: TimeInterval(current.st_mtimespec.tv_sec) + TimeInterval(current.st_mtimespec.tv_nsec) / 1_000_000_000) < processStart else { continue }
            if unlink(path) != 0 { log("\(name): \(String(cString: strerror(errno)))") }
        }
    }
}
