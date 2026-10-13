import Foundation
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

/// What the kernel recorded about the process on the other end of a Unix socket at connect time.
/// Unlike anything the client sends, this can't be claimed.
public enum SocketPeer {
    public static func pid(_ fd: Int32) -> Int32? {
        #if os(macOS)
        var pid: Int32 = 0
        var size = socklen_t(MemoryLayout<Int32>.size)
        guard getsockopt(fd, SOL_LOCAL, LOCAL_PEERPID, &pid, &size) == 0, size == MemoryLayout<Int32>.size, pid > 0
        else { return nil }
        return pid
        #else
        struct Credentials { var pid: Int32 = 0; var uid: UInt32 = 0; var gid: UInt32 = 0 }
        var credentials = Credentials(), size = socklen_t(MemoryLayout<Credentials>.size)
        guard getsockopt(fd, SOL_SOCKET, SO_PEERCRED, &credentials, &size) == 0,
              size == MemoryLayout<Credentials>.size, credentials.pid > 0 else { return nil }
        return credentials.pid
        #endif
    }

    /// The SSH daemon executables that connect to a socket forwarded with `ssh -L` or `-R`.
    static let sshForwarders: Set<String> = ["sshd", "sshd-session"]

    /// Whether the peer is an SSH daemon forwarding the socket for a remote client. Such a
    /// connection is a tunnel whatever the client says about itself.
    public static func isSSHForward(_ fd: Int32) -> Bool {
        guard let pid = pid(fd), let path = DaemonOwnership.executablePath(pid: pid) else { return false }
        return sshForwarders.contains(URL(fileURLWithPath: path).lastPathComponent)
    }
}
