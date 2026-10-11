import Foundation
#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif

/// Administration is explicit. Probe failure and version skew never authorize a signal.
public enum DaemonRestart {
    public enum Failure: Error, CustomStringConvertible {
        case refused(String)
        public var description: String { switch self { case let .refused(message): return message } }
    }

    /// Stop only the verified local service, and wait until its process has exited.
    /// An old daemon has no atomic empty check, so it requires explicit force.
    public static func stop(force: Bool, timeout: TimeInterval = 8) throws -> URL {
        let client = DaemonClient()
        let stats: DaemonStats?
        if case let .daemonStats(value)? = try? client.request(.daemonStats, timeout: 1) { stats = value }
        else { stats = nil }
        guard let stats, case let .alive(pid) = DaemonOwnership.probe(),
              let identity = DaemonOwnership.liveIdentity(pid: pid, socket: HarnessPaths.socketURL),
              stats.pid == pid else {
            throw Failure.refused("Cannot verify the session-service owner. Existing shells have been preserved.")
        }
        let stoppedSocket = StoppedOwnerSocket(at: HarnessPaths.socketURL)
        let executable: URL
        if let path = identity.path { executable = URL(fileURLWithPath: path) }
        else if let current = Bundle.main.executableURL { executable = HarnessToolLocator.companion(identity.name, to: current) }
        else { executable = HarnessPaths.applicationSupport.appendingPathComponent("bin/" + identity.name) }
        if stats.supports(DaemonStats.guardedRestart) {
            let response = try client.requestFromLocalOwner(.shutdownDaemon(requireEmpty: !force), pid: pid, generation: identity.generation, timeout: 2)
            guard case .ok = response else {
                if case let .error(message) = response { throw Failure.refused(message) }
                throw Failure.refused("Shutdown was not acknowledged; existing shells have been preserved.")
            }
        } else {
            guard force else {
                throw Failure.refused("This daemon cannot atomically verify an empty session set. Close your work and use --force for an explicit restart.")
            }
            guard case let .daemonStats(confirmed) = try client.requestFromLocalOwner(.daemonStats, pid: pid, generation: identity.generation, timeout: 1),
                  confirmed.pid == pid, ProcessScan.generation(pid) == identity.generation, kill(pid, SIGTERM) == 0 else {
                throw Failure.refused("The verified daemon could not be stopped.")
            }
        }
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if StoppedOwnerSocket.hasExited(pid: pid, generation: identity.generation) {
                try stoppedSocket?.removeAfterExit(pid: pid, generation: identity.generation, pidFile: HarnessPaths.daemonPIDURL)
                return executable
            }
            Thread.sleep(forTimeInterval: 0.05)
        }
        throw Failure.refused("Shutdown is still in progress. No replacement was started; retry after the service exits.")
    }
}

/// An explicitly stopped legacy owner can leave its listening socket inherited by children.
/// Retain the verified pathname's identity so recovery cannot unlink a replacement's endpoint.
struct StoppedOwnerSocket {
    let url: URL
    private let device: dev_t
    private let inode: ino_t

    init?(at url: URL) {
        var info = stat()
        guard lstat(url.path, &info) == 0, info.st_uid == getuid(),
              info.st_mode & mode_t(S_IFMT) == mode_t(S_IFSOCK) else { return nil }
        self.url = url; device = info.st_dev; inode = info.st_ino
    }

    static func hasExited(pid: Int32, generation: String) -> Bool {
        if kill(pid, 0) != 0, errno == ESRCH { return true }
        if let current = ProcessScan.generation(pid), current != generation { return true }
        return ProcessScan.isZombie(pid)
    }

    func removeAfterExit(pid: Int32, generation: String, pidFile: URL) throws {
        guard Self.hasExited(pid: pid, generation: generation),
              let ownership = try? DaemonInstanceLock(directory: url.deletingLastPathComponent()) else { return }
        defer { withExtendedLifetime(ownership) {} }
        if FileManager.default.fileExists(atPath: pidFile.path) {
            guard let raw = try? String(contentsOf: pidFile, encoding: .utf8),
                  Int32(raw.trimmingCharacters(in: .whitespacesAndNewlines)) == pid,
                  case .absent = DaemonOwnership.probe(pidFile: pidFile, socket: url) else { return }
        }
        var current = stat()
        guard lstat(url.path, &current) == 0, current.st_dev == device, current.st_ino == inode,
              current.st_uid == getuid(), current.st_mode & mode_t(S_IFMT) == mode_t(S_IFSOCK) else { return }
        guard unlink(url.path) == 0 || errno == ENOENT else {
            throw DaemonRestart.Failure.refused("The stopped service's control socket could not be removed: \(POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO).localizedDescription)")
        }
    }
}
