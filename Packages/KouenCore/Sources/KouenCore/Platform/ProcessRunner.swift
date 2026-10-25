import Foundation

/// Thread-safe buffer accumulator for child process pipes.
private final class OutputBuffer: @unchecked Sendable {
    private let lock = NSLock()
    private var data = Data()

    func append(_ chunk: Data) {
        lock.lock()
        defer { lock.unlock() }
        data.append(chunk)
    }

    func toData() -> Data {
        lock.lock()
        defer { lock.unlock() }
        return data
    }
}

/// Result of executing an external process.
public struct ProcessResult: Sendable, Equatable {
    public let exitCode: Int32
    public let stdout: String
    public let stderr: String

    public var isSuccess: Bool { exitCode == 0 }

    public init(exitCode: Int32, stdout: String, stderr: String = "") {
        self.exitCode = exitCode
        self.stdout = stdout
        self.stderr = stderr
    }
}

/// Headless, dead-lock free process execution engine for POSIX CLI tools.
/// Enforces concurrent pipe draining and timeout safety in Layer 1 Foundation.
public enum ProcessRunner {
    /// Common bin directories searched when resolving bare commands.
    public static let standardBinSearchPaths: [String] = [
        "/opt/homebrew/bin",
        "/usr/local/bin",
        "/usr/bin",
        "/bin",
        "/usr/sbin",
        "/sbin",
    ]

    /// Resolves the absolute path for an executable command name.
    public static func resolveBinary(_ name: String) -> String? {
        if name.hasPrefix("/") && FileManager.default.isExecutableFile(atPath: name) {
            return name
        }
        for dir in standardBinSearchPaths {
            let candidate = "\(dir)/\(name)"
            if FileManager.default.isExecutableFile(atPath: candidate) {
                return candidate
            }
        }
        return nil
    }

    /// Synchronously executes a binary with arguments, directory, and timeout.
    @discardableResult
    public static func run(
        executable: String,
        arguments: [String] = [],
        in directory: String? = nil,
        timeout: TimeInterval = 30
    ) -> ProcessResult {
        let process = Process()
        let resolvedExec = resolveBinary(executable) ?? (executable.hasPrefix("/") ? executable : "/usr/bin/env")
        process.executableURL = URL(fileURLWithPath: resolvedExec)

        if resolvedExec == "/usr/bin/env" && !executable.hasPrefix("/") {
            process.arguments = [executable] + arguments
        } else {
            process.arguments = arguments
        }

        if let directory, !directory.isEmpty {
            process.currentDirectoryURL = URL(fileURLWithPath: directory)
        }

        let outPipe = Pipe()
        let errPipe = Pipe()
        process.standardOutput = outPipe
        process.standardError = errPipe

        do {
            try process.run()
        } catch {
            return ProcessResult(exitCode: -1, stdout: "", stderr: error.localizedDescription)
        }

        let outBuf = OutputBuffer()
        let errBuf = OutputBuffer()
        let group = DispatchGroup()

        group.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            let data = outPipe.fileHandleForReading.readDataToEndOfFile()
            outBuf.append(data)
            group.leave()
        }

        group.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            let data = errPipe.fileHandleForReading.readDataToEndOfFile()
            errBuf.append(data)
            group.leave()
        }

        let timeoutResult = group.wait(timeout: .now() + timeout)
        if timeoutResult == .timedOut {
            process.terminate()
            return ProcessResult(exitCode: -1, stdout: "", stderr: "Process timed out after \(timeout)s")
        }

        process.waitUntilExit()

        let stdoutStr = String(data: outBuf.toData(), encoding: .utf8) ?? ""
        let stderrStr = String(data: errBuf.toData(), encoding: .utf8) ?? ""
        return ProcessResult(exitCode: process.terminationStatus, stdout: stdoutStr, stderr: stderrStr)
    }

    /// Asynchronously executes a binary with user-initiated priority.
    public static func runAsync(
        executable: String,
        arguments: [String] = [],
        in directory: String? = nil,
        timeout: TimeInterval = 30
    ) async -> ProcessResult {
        await Task.detached(priority: .userInitiated) {
            run(executable: executable, arguments: arguments, in: directory, timeout: timeout)
        }.value
    }
}
