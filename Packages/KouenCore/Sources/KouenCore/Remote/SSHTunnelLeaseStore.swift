import Foundation
#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif

/// A PID alone is not ownership: persist its birth identity as well, so a later
/// Kouen process never terminates an unrelated process that reused that PID.
package struct SSHTunnelProcessIdentity: Codable, Equatable {
    let pid: Int32
    package let birth: String
    let uid: UInt32
    let executable: String

    package static func read(_ pid: Int32) -> Self? {
        guard pid > 1 else { return nil }
        #if canImport(Darwin)
        var info = proc_bsdinfo()
        let size = Int32(MemoryLayout<proc_bsdinfo>.size)
        guard proc_pidinfo(pid, PROC_PIDTBSDINFO, 0, &info, size) == size else { return nil }
        var path = [CChar](repeating: 0, count: Int(MAXPATHLEN) * 4)
        guard proc_pidpath(pid, &path, UInt32(path.count)) > 0 else { return nil }
        let executable = String(decoding: path.prefix { $0 != 0 }.map { UInt8(bitPattern: $0) }, as: UTF8.self)
        return Self(pid: pid, birth: "\(info.pbi_start_tvsec):\(info.pbi_start_tvusec)",
                    uid: info.pbi_uid, executable: executable)
        #else
        let root = "/proc/\(pid)"
        guard let stat = try? String(contentsOfFile: root + "/stat", encoding: .utf8),
              let end = stat.lastIndex(of: ")"),
              let attributes = try? FileManager.default.attributesOfItem(atPath: root),
              let uid = attributes[.ownerAccountID] as? NSNumber,
              let executable = try? FileManager.default.destinationOfSymbolicLink(atPath: root + "/exe")
        else { return nil }
        let fields = stat[stat.index(after: end)...].split(separator: " ")
        guard fields.count > 19,
              let boot = try? String(contentsOfFile: "/proc/sys/kernel/random/boot_id", encoding: .utf8)
        else { return nil }
        return Self(pid: pid, birth: boot.trimmingCharacters(in: .whitespacesAndNewlines) + ":" + fields[19],
                    uid: uid.uint32Value, executable: executable)
        #endif
    }
}

/// Private lease files are written only for ssh children this manager launched.
/// All file operations and injected process observations are serialized by lock.
final class SSHTunnelLeaseStore: @unchecked Sendable {
    struct Lease: Codable {
        let owner: SSHTunnelProcessIdentity
        let child: SSHTunnelProcessIdentity
        let socketName: String
    }

    private let directory: URL
    private let snapshot: (Int32) -> SSHTunnelProcessIdentity?
    private let terminate: (Int32) -> Bool
    private let lock = NSLock()
    private var owned: [ObjectIdentifier: SSHTunnelProcessIdentity] = [:]

    init(directory: URL,
         snapshot: @escaping (Int32) -> SSHTunnelProcessIdentity? = SSHTunnelProcessIdentity.read,
         terminate: @escaping (Int32) -> Bool = { kill($0, SIGTERM) == 0 }) {
        self.directory = directory.resolvingSymlinksInPath().standardizedFileURL
        self.snapshot = snapshot
        self.terminate = terminate
    }

    func record(process: Process, socket: URL) {
        lock.lock(); defer { lock.unlock() }
        // Linux Foundation can encode the same directory URL with or without a trailing slash.
        guard isPrivateDirectory,
              socket.deletingLastPathComponent().resolvingSymlinksInPath().standardizedFileURL.path == directory.path,
              let owner = snapshot(Int32(getpid())),
              let child = snapshot(process.processIdentifier), child.uid == UInt32(getuid()),
              child.executable == "/usr/bin/ssh", process.arguments?.contains("-N") == true,
              let arguments = process.arguments, let forward = arguments.firstIndex(of: "-L"),
              arguments.indices.contains(forward + 1), arguments[forward + 1].hasPrefix(socket.path + ":")
        else { return }
        do {
            let file = leaseURL(socket: socket)
            try JSONEncoder().encode(Lease(owner: owner, child: child, socketName: socket.lastPathComponent))
                .write(to: file, options: .atomic)
            try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: file.path)
            owned[ObjectIdentifier(process)] = child
        } catch { report(error) }
    }

    func remove(process: Process, socket: URL) {
        lock.lock(); defer { lock.unlock() }
        let file = leaseURL(socket: socket)
        guard let expected = owned.removeValue(forKey: ObjectIdentifier(process)), isPrivateDirectory,
              let attributes = try? FileManager.default.attributesOfItem(atPath: file.path),
              attributes[.type] as? FileAttributeType == .typeRegular,
              let size = attributes[.size] as? NSNumber, size.intValue <= 16_384,
              let data = try? Data(contentsOf: file),
              let lease = try? JSONDecoder().decode(Lease.self, from: data),
              lease.child == expected else { return }
        do { try FileManager.default.removeItem(at: file) } catch { report(error) }
    }

    func sweep() {
        lock.lock(); defer { lock.unlock() }
        guard isPrivateDirectory,
              let files = try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
        else { return }
        for file in files where file.lastPathComponent.hasSuffix(".lease.json") {
            guard let attributes = try? FileManager.default.attributesOfItem(atPath: file.path),
                  attributes[.type] as? FileAttributeType == .typeRegular,
                  (attributes[.ownerAccountID] as? NSNumber)?.uint32Value == UInt32(getuid()),
                  let size = attributes[.size] as? NSNumber, size.intValue <= 16_384,
                  let data = try? Data(contentsOf: file),
                  let lease = try? JSONDecoder().decode(Lease.self, from: data),
                  lease.owner.pid > 1, lease.child.pid > 1, lease.owner.uid == UInt32(getuid()),
                  lease.child.uid == UInt32(getuid()), lease.child.executable == "/usr/bin/ssh",
                  lease.socketName == URL(fileURLWithPath: lease.socketName).lastPathComponent,
                  lease.socketName.hasSuffix(".sock"),
                  file.standardizedFileURL == leaseURL(socket: directory.appendingPathComponent(lease.socketName)).standardizedFileURL
            else { continue }
            // An unavailable observation may be permissions, not death. kill(0)
            // distinguishes a genuinely dead owner from an unreadable live owner.
            if snapshot(lease.owner.pid) == lease.owner { continue }
            if snapshot(lease.owner.pid) == nil, kill(lease.owner.pid, 0) == 0 || errno == EPERM { continue }
            guard let child = snapshot(lease.child.pid) else {
                if kill(lease.child.pid, 0) == 0 || errno == EPERM { continue }
                removeDeadLease(file: file)
                continue
            }
            guard child == lease.child else { continue }
            // Recheck immediately before signalling; no broad process-name sweep.
            guard snapshot(child.pid) == child else { continue }
            if !terminate(child.pid) { report(POSIXError(.ESRCH)) }
            // Keep the lease/socket until exit is observed on a subsequent sweep.
        }
    }

    private var isPrivateDirectory: Bool {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: directory.path),
              attributes[.type] as? FileAttributeType == .typeDirectory,
              (attributes[.ownerAccountID] as? NSNumber)?.uint32Value == UInt32(getuid()),
              let mode = attributes[.posixPermissions] as? NSNumber else { return false }
        return mode.intValue & 0o077 == 0
    }

    private func leaseURL(socket: URL) -> URL { directory.appendingPathComponent(socket.lastPathComponent).appendingPathExtension("lease.json") }

    private func removeDeadLease(file: URL) {
        // Another process may already have rebound the socket before writing its
        // lease. The owning endpoint handles socket unlink before its own bind.
        do { try FileManager.default.removeItem(at: file) } catch { report(error) }
    }

    private func report(_ error: Error) {
        FileHandle.standardError.write(Data("Kouen SSH lease cleanup: \(error)\n".utf8))
    }
}
