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
    public let isTimedOut: Bool

    public var isSuccess: Bool { exitCode == 0 }

    public init(exitCode: Int32, stdout: String, stderr: String = "", isTimedOut: Bool = false) {
        self.exitCode = exitCode
        self.stdout = stdout
        self.stderr = stderr
        self.isTimedOut = isTimedOut
    }
}

/// Asynchronous execution coordinator managing pipes, process lifecycle, bounded timeouts,
/// and ensuring the continuation is resumed exactly once.
private final class AsyncRunCoordinator: @unchecked Sendable {
    private let lock = NSLock()
    private let process: Process
    private let outPipe: Pipe
    private let errPipe: Pipe
    private let timeout: TimeInterval?
    private let continuation: CheckedContinuation<ProcessResult, Never>

    private var outData: Data?
    private var errData: Data?
    private var terminationStatus: Int32?
    private var didTimeout = false
    private var isResumed = false
    private var timeoutWorkItem: DispatchWorkItem?

    init(
        process: Process,
        outPipe: Pipe,
        errPipe: Pipe,
        timeout: TimeInterval?,
        continuation: CheckedContinuation<ProcessResult, Never>
    ) {
        self.process = process
        self.outPipe = outPipe
        self.errPipe = errPipe
        self.timeout = timeout
        self.continuation = continuation
    }

    func start() {
        process.terminationHandler = { [self] proc in
            self.handleProcessTerminated(status: proc.terminationStatus)
        }

        do {
            try process.run()
        } catch {
            resumeOnce(ProcessResult(exitCode: -1, stdout: "", stderr: error.localizedDescription, isTimedOut: false))
            return
        }

        if let timeout, timeout > 0 {
            let item = DispatchWorkItem { [weak self] in
                self?.handleTimeout()
            }
            timeoutWorkItem = item
            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + timeout, execute: item)
        }

        DispatchQueue.global(qos: .userInitiated).async { [self] in
            let data = self.outPipe.fileHandleForReading.readDataToEndOfFile()
            self.handleOutDrained(data)
        }

        DispatchQueue.global(qos: .userInitiated).async { [self] in
            let data = self.errPipe.fileHandleForReading.readDataToEndOfFile()
            self.handleErrDrained(data)
        }
    }

    private func handleOutDrained(_ data: Data) {
        lock.lock()
        outData = data
        let ready = checkReadyUnderLock()
        lock.unlock()
        if ready {
            finalize()
        }
    }

    private func handleErrDrained(_ data: Data) {
        lock.lock()
        errData = data
        let ready = checkReadyUnderLock()
        lock.unlock()
        if ready {
            finalize()
        }
    }

    private func handleProcessTerminated(status: Int32) {
        lock.lock()
        terminationStatus = status
        let ready = checkReadyUnderLock()
        lock.unlock()
        if ready {
            finalize()
        }
    }

    private func checkReadyUnderLock() -> Bool {
        guard !isResumed else { return false }
        return outData != nil && errData != nil && terminationStatus != nil
    }

    private func handleTimeout() {
        lock.lock()
        guard !isResumed else {
            lock.unlock()
            return
        }
        didTimeout = true
        lock.unlock()

        if process.isRunning {
            process.terminate()
        }

        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self else { return }
            self.lock.lock()
            let alreadyResumed = self.isResumed
            self.lock.unlock()
            guard !alreadyResumed else { return }

            if self.process.isRunning {
                kill(self.process.processIdentifier, SIGKILL)
            }
            self.finalize()
        }
    }

    private func finalize() {
        lock.lock()
        guard !isResumed else {
            lock.unlock()
            return
        }
        isResumed = true
        timeoutWorkItem?.cancel()
        timeoutWorkItem = nil
        process.terminationHandler = nil

        let out = outData ?? Data()
        let err = errData ?? Data()
        let rawStatus = terminationStatus ?? (process.isRunning ? -1 : process.terminationStatus)
        let timedOut = didTimeout
        let timeoutVal = timeout
        lock.unlock()

        let stdoutStr = String(data: out, encoding: .utf8) ?? ""
        var stderrStr = String(data: err, encoding: .utf8) ?? ""

        let exitCode: Int32
        if timedOut {
            exitCode = rawStatus != 0 ? rawStatus : -1
            let note = "Process timed out after \(timeoutVal ?? 0)s"
            stderrStr = stderrStr.isEmpty ? note : "\(stderrStr)\n\(note)"
        } else {
            exitCode = rawStatus
        }

        continuation.resume(returning: ProcessResult(
            exitCode: exitCode,
            stdout: stdoutStr,
            stderr: stderrStr,
            isTimedOut: timedOut
        ))
    }

    private func resumeOnce(_ result: ProcessResult) {
        lock.lock()
        guard !isResumed else {
            lock.unlock()
            return
        }
        isResumed = true
        timeoutWorkItem?.cancel()
        timeoutWorkItem = nil
        process.terminationHandler = nil
        lock.unlock()

        continuation.resume(returning: result)
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

    /// Synchronously executes a binary with arguments, directory, and optional timeout.
    @discardableResult
    public static func run(
        executable: String,
        arguments: [String] = [],
        in directory: String? = nil,
        timeout: TimeInterval? = nil
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
            return ProcessResult(exitCode: -1, stdout: "", stderr: error.localizedDescription, isTimedOut: false)
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

        if let timeout, timeout > 0 {
            let timeoutResult = group.wait(timeout: .now() + timeout)
            if timeoutResult == .timedOut {
                if process.isRunning {
                    process.terminate()
                }
                let boundedWait = group.wait(timeout: .now() + 1.5)
                if boundedWait == .timedOut && process.isRunning {
                    kill(process.processIdentifier, SIGKILL)
                }
                process.waitUntilExit()

                let stdoutStr = String(data: outBuf.toData(), encoding: .utf8) ?? ""
                var stderrStr = String(data: errBuf.toData(), encoding: .utf8) ?? ""
                let timeoutNote = "Process timed out after \(timeout)s"
                stderrStr = stderrStr.isEmpty ? timeoutNote : "\(stderrStr)\n\(timeoutNote)"
                let status = process.terminationStatus != 0 ? process.terminationStatus : -1
                return ProcessResult(exitCode: status, stdout: stdoutStr, stderr: stderrStr, isTimedOut: true)
            }
        } else {
            group.wait()
        }

        process.waitUntilExit()

        let stdoutStr = String(data: outBuf.toData(), encoding: .utf8) ?? ""
        let stderrStr = String(data: errBuf.toData(), encoding: .utf8) ?? ""
        return ProcessResult(exitCode: process.terminationStatus, stdout: stdoutStr, stderr: stderrStr, isTimedOut: false)
    }

    /// Asynchronously executes a binary non-blockingly with pipe draining and bounded timeout safety.
    public static func runAsync(
        executable: String,
        arguments: [String] = [],
        in directory: String? = nil,
        timeout: TimeInterval? = nil
    ) async -> ProcessResult {
        await withCheckedContinuation { continuation in
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

            let coordinator = AsyncRunCoordinator(
                process: process,
                outPipe: outPipe,
                errPipe: errPipe,
                timeout: timeout,
                continuation: continuation
            )

            coordinator.start()
        }
    }
}
