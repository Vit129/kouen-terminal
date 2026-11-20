#if os(Linux)
import Foundation
import Glibc

/// Owns a Linux child directly. Foundation Process uses a notification socket inherited
/// by grandchildren, which can delay reaping the child until those grandchildren exit.
final class LinuxChildProcess: @unchecked Sendable {
    private let condition = NSCondition()
    private var pid: pid_t = 0
    private var status: Int32?

    func start(_ configuration: Process, onExit: @escaping @Sendable (Int32) -> Void) throws {
        guard let executable = configuration.executableURL?.path else {
            throw POSIXError(.EINVAL)
        }
        var actions = posix_spawn_file_actions_t()
        try check(posix_spawn_file_actions_init(&actions))
        defer { posix_spawn_file_actions_destroy(&actions) }
        if let directory = configuration.currentDirectoryURL?.path {
            try check(posix_spawn_file_actions_addchdir_np(&actions, directory))
        }
        for (destination, stream) in [
            (STDIN_FILENO, configuration.standardInput),
            (STDOUT_FILENO, configuration.standardOutput),
            (STDERR_FILENO, configuration.standardError)
        ] {
            let handle: FileHandle?
            if let pipe = stream as? Pipe {
                handle = destination == STDIN_FILENO ? pipe.fileHandleForReading : pipe.fileHandleForWriting
            } else {
                handle = stream as? FileHandle
            }
            if handle === FileHandle.nullDevice {
                let mode = destination == STDIN_FILENO ? O_RDONLY : O_WRONLY
                try check(posix_spawn_file_actions_addopen(&actions, destination, "/dev/null", mode, 0))
            } else if let handle {
                try check(posix_spawn_file_actions_adddup2(&actions, handle.fileDescriptor, destination))
            }
        }
        try check(posix_spawn_file_actions_addclosefrom_np(&actions, 3))

        var attributes = posix_spawnattr_t()
        try check(posix_spawnattr_init(&attributes))
        defer { posix_spawnattr_destroy(&attributes) }
        try check(posix_spawnattr_setflags(&attributes, Int16(POSIX_SPAWN_SETPGROUP)))
        var argv = ([executable] + (configuration.arguments ?? [])).map { strdup($0) } + [nil]
        var envp = (configuration.environment ?? ProcessInfo.processInfo.environment)
            .map { strdup("\($0.key)=\($0.value)") } + [nil]
        defer {
            argv.forEach { free($0) }
            envp.forEach { free($0) }
        }
        var spawnedPID: pid_t = 0
        try check(posix_spawn(&spawnedPID, executable, &actions, &attributes, &argv, &envp))
        let child = spawnedPID
        condition.lock()
        pid = child
        condition.unlock()
        Thread.detachNewThread { [self] in
            var info = siginfo_t()
            // Leave the exited child waitable until we take the lock, so a concurrent
            // timeout cannot signal a recycled PID between the wait and state update.
            while waitid(P_PID, id_t(child), &info, WEXITED | WNOWAIT) == -1 && errno == EINTR {}
            condition.lock()
            var raw: Int32 = 0
            var reaped: pid_t
            repeat { reaped = waitpid(child, &raw, 0) } while reaped == -1 && errno == EINTR
            let signal = raw & 0x7f
            let result = reaped == child ? (signal == 0 ? (raw >> 8) & 0xff : signal) : -1
            status = result
            condition.broadcast()
            condition.unlock()
            onExit(result)
        }
    }

    @discardableResult
    func signal(_ value: Int32) -> Bool {
        condition.lock()
        defer { condition.unlock() }
        guard pid > 0, status == nil else { return false }
        return kill(-pid, value) == 0
    }

    func wait() -> Int32 {
        condition.lock()
        defer { condition.unlock() }
        while status == nil { condition.wait() }
        return status ?? -1
    }

    private func check(_ code: Int32) throws {
        if code != 0 { throw POSIXError(POSIXErrorCode(rawValue: code) ?? .EIO) }
    }
}
#endif
