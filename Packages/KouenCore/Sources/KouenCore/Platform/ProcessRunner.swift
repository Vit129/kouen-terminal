import Foundation
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

/// Thread-safe buffer accumulator for child process pipes.
private final class OutputBuffer: @unchecked Sendable {
    static let maxCapturedBytes = 4 * 1024 * 1024
    private let lock = NSLock()
    private var data = Data()
    private var truncated = false

    func append(_ chunk: Data) {
        lock.lock()
        defer { lock.unlock() }
        let remaining = max(0, Self.maxCapturedBytes - data.count)
        if remaining > 0 { data.append(chunk.prefix(remaining)) }
        if chunk.count > remaining { truncated = true }
    }

    func toData() -> Data {
        lock.lock()
        defer { lock.unlock() }
        return data
    }

    func markIncomplete() {
        lock.lock(); truncated = true; lock.unlock()
    }

    func isTruncated() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return truncated
    }
}

private final class ReaderStop: @unchecked Sendable {
    private let lock = NSLock()
    private var stopped = false
    func stop() { lock.lock(); stopped = true; lock.unlock() }
    func shouldStop() -> Bool { lock.lock(); defer { lock.unlock() }; return stopped }
}

private struct OutputCapture {
    let data: Data
    let truncated: Bool
}

private func drainOutput(_ handle: FileHandle, into buffer: OutputBuffer, shouldStop: () -> Bool) -> OutputCapture {
    let fd = handle.fileDescriptor
    var failed = false
    while !shouldStop() {
        var descriptor = pollfd(fd: fd, events: Int16(POLLIN | POLLHUP), revents: 0)
        let ready = poll(&descriptor, 1, 100)
        if ready < 0 {
            if errno == EINTR { continue }
            failed = true
            break
        }
        guard ready > 0 else { continue }
        var bytes = [UInt8](repeating: 0, count: 64 * 1024)
        #if canImport(Darwin)
        let count = Darwin.read(fd, &bytes, bytes.count)
        #else
        let count = Glibc.read(fd, &bytes, bytes.count)
        #endif
        if count < 0 && errno == EINTR { continue }
        if count < 0 { failed = true; break }
        guard count > 0 else { break }
        buffer.append(Data(bytes.prefix(count)))
    }
    if failed { buffer.markIncomplete() }
    return OutputCapture(data: buffer.toData(), truncated: buffer.isTruncated())
}

/// Result of executing an external process.
public struct ProcessResult: Sendable, Equatable {
    public let exitCode: Int32
    public let stdout: String
    public let stderr: String
    public let isTimedOut: Bool
    public let stdoutWasTruncated: Bool
    public let stderrWasTruncated: Bool

    public var isSuccess: Bool { exitCode == 0 }

    public init(exitCode: Int32, stdout: String, stderr: String = "", isTimedOut: Bool = false, stdoutWasTruncated: Bool = false, stderrWasTruncated: Bool = false) {
        self.exitCode = exitCode
        self.stdout = stdout
        self.stderr = stderr
        self.isTimedOut = isTimedOut
        self.stdoutWasTruncated = stdoutWasTruncated
        self.stderrWasTruncated = stderrWasTruncated
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

    private let outBuffer = OutputBuffer()
    private let errBuffer = OutputBuffer()
    private var stopReaders = false
    private var outData: Data?
    private var errData: Data?
    private var outTruncated = false
    private var errTruncated = false
    private var terminationStatus: Int32?
    private var didTimeout = false
    private var didCancel = false
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

        lock.lock()
        guard !didCancel else {
            lock.unlock()
            resumeOnce(ProcessResult(exitCode: -1, stdout: "", stderr: "Process cancelled"))
            return
        }
        do {
            try process.run()
            lock.unlock()
        } catch {
            lock.unlock()
            resumeOnce(ProcessResult(exitCode: -1, stdout: "", stderr: error.localizedDescription, isTimedOut: false))
            return
        }

        if let timeout, timeout > 0 {
            let item = DispatchWorkItem { [weak self] in
                self?.handleTimeout()
            }
            lock.lock()
            let shouldSchedule = !isResumed
            if shouldSchedule { timeoutWorkItem = item }
            lock.unlock()
            if shouldSchedule {
                DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + timeout, execute: item)
            }
        }

        DispatchQueue.global(qos: .userInitiated).async { [self] in
            self.handleOutDrained(drainOutput(self.outPipe.fileHandleForReading, into: self.outBuffer, shouldStop: self.readersShouldStop))
        }

        DispatchQueue.global(qos: .userInitiated).async { [self] in
            self.handleErrDrained(drainOutput(self.errPipe.fileHandleForReading, into: self.errBuffer, shouldStop: self.readersShouldStop))
        }
    }

    private func readersShouldStop() -> Bool {
        lock.lock(); defer { lock.unlock() }
        return stopReaders
    }

    private func handleOutDrained(_ capture: OutputCapture) {
        lock.lock()
        outData = capture.data
        outTruncated = capture.truncated
        let ready = checkReadyUnderLock()
        lock.unlock()
        if ready {
            finalize()
        }
    }

    private func handleErrDrained(_ capture: OutputCapture) {
        lock.lock()
        errData = capture.data
        errTruncated = capture.truncated
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
        } else {
            // A descendant can inherit a pipe after the child exits. Stop waiting for EOF,
            // report incomplete output, and release reader threads after a bounded grace period.
            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 2) { [weak self] in
                self?.finalize()
            }
        }
    }

    private func checkReadyUnderLock() -> Bool {
        guard !isResumed else { return false }
        return outData != nil && errData != nil && terminationStatus != nil
    }

    func cancel() {
        lock.lock()
        guard !isResumed else { lock.unlock(); return }
        didCancel = true
        let running = process.isRunning
        lock.unlock()
        guard running else { return }
        process.terminate()
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self else { return }
            if self.process.isRunning { kill(self.process.processIdentifier, SIGKILL) }
            self.finalize()
        }
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
        stopReaders = true
        timeoutWorkItem?.cancel()
        timeoutWorkItem = nil
        process.terminationHandler = nil

        let out = outData ?? outBuffer.toData()
        let err = errData ?? errBuffer.toData()
        let rawStatus = terminationStatus ?? (process.isRunning ? -1 : process.terminationStatus)
        let timedOut = didTimeout
        let cancelled = didCancel
        let stdoutWasTruncated = outTruncated || outData == nil || outBuffer.isTruncated()
        let stderrWasTruncated = errTruncated || errData == nil || errBuffer.isTruncated()
        let timeoutVal = timeout
        lock.unlock()

        let stdoutStr = String(decoding: out, as: UTF8.self)
        var stderrStr = String(decoding: err, as: UTF8.self)

        let exitCode: Int32
        if timedOut || cancelled {
            exitCode = rawStatus != 0 ? rawStatus : -1
            let note = cancelled ? "Process cancelled" : "Process timed out after \(timeoutVal ?? 0)s"
            stderrStr = stderrStr.isEmpty ? note : "\(stderrStr)\n\(note)"
        } else {
            // Drain never finished (pipe held open): output is unreliable, so do not report success.
            exitCode = rawStatus == 0 && (outData == nil || errData == nil) ? -1 : rawStatus
        }

        continuation.resume(returning: ProcessResult(
            exitCode: exitCode,
            stdout: stdoutStr,
            stderr: stderrStr,
            isTimedOut: timedOut,
            stdoutWasTruncated: stdoutWasTruncated,
            stderrWasTruncated: stderrWasTruncated
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

private final class ProcessCancellation: @unchecked Sendable {
    private let lock = NSLock()
    private var coordinator: AsyncRunCoordinator?
    private var cancelled = false

    func install(_ coordinator: AsyncRunCoordinator) {
        lock.lock()
        self.coordinator = coordinator
        let shouldCancel = cancelled
        lock.unlock()
        if shouldCancel { coordinator.cancel() }
    }

    func cancel() {
        lock.lock()
        cancelled = true
        let target = coordinator
        lock.unlock()
        target?.cancel()
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

        return run(process: process, timeout: timeout)
    }

    /// Reuse the bounded runner for callers that already configure a Process (including fixtures).
    static func run(process: Process, timeout: TimeInterval?) -> ProcessResult {
        let outPipe = Pipe()
        let errPipe = Pipe()
        process.standardOutput = outPipe
        process.standardError = errPipe

        let exited = DispatchSemaphore(value: 0)
        process.terminationHandler = { _ in exited.signal() }
        do {
            try process.run()
        } catch {
            return ProcessResult(exitCode: -1, stdout: "", stderr: error.localizedDescription)
        }

        let outBuf = OutputBuffer()
        let errBuf = OutputBuffer()
        let stop = ReaderStop()
        let group = DispatchGroup()
        for (pipe, buffer) in [(outPipe, outBuf), (errPipe, errBuf)] {
            group.enter()
            DispatchQueue.global(qos: .userInitiated).async {
                _ = drainOutput(pipe.fileHandleForReading, into: buffer, shouldStop: stop.shouldStop)
                group.leave()
            }
        }

        let deadline: DispatchTime? = timeout.flatMap { $0 > 0 ? .now() + $0 : nil }
        var timedOut = false
        if let deadline {
            timedOut = exited.wait(timeout: deadline) == .timedOut
        } else {
            exited.wait()
        }
        if timedOut, process.isRunning {
            process.terminate()
            if exited.wait(timeout: .now() + 1.5) == .timedOut, process.isRunning {
                kill(process.processIdentifier, SIGKILL)
                _ = exited.wait(timeout: .now() + 1.5)
            }
        }
        // After exit, always allow a short grace so a process finishing right at the deadline is not
        // reported as timed out; a descendant holding the pipe open is still cut off by this bound.
        let graceDeadline: DispatchTime = .now() + 0.5
        let drainDeadline = deadline.map { max($0, graceDeadline) } ?? (.now() + 2)
        let incomplete = group.wait(timeout: drainDeadline) == .timedOut
        if incomplete {
            if deadline != nil { timedOut = true }
            stop.stop()
            _ = group.wait(timeout: .now() + 0.5)
        }
        let stdout = String(decoding: outBuf.toData(), as: UTF8.self)
        var stderr = String(decoding: errBuf.toData(), as: UTF8.self)
        if timedOut {
            let note = "Process timed out after \(timeout ?? 0)s"
            stderr = stderr.isEmpty ? note : "\(stderr)\n\(note)"
        }
        let status: Int32 = process.isRunning ? -1 : process.terminationStatus
        return ProcessResult(exitCode: (timedOut || incomplete) && status == 0 ? -1 : status,
                             stdout: stdout, stderr: stderr, isTimedOut: timedOut,
                             stdoutWasTruncated: incomplete || outBuf.isTruncated(),
                             stderrWasTruncated: incomplete || errBuf.isTruncated())
    }

    /// Asynchronously executes a binary non-blockingly with pipe draining and bounded timeout safety.
    public static func runAsync(
        executable: String,
        arguments: [String] = [],
        in directory: String? = nil,
        timeout: TimeInterval? = nil
    ) async -> ProcessResult {
        let cancellation = ProcessCancellation()
        return await withTaskCancellationHandler {
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

            cancellation.install(coordinator)
            coordinator.start()
            }
        } onCancel: {
            cancellation.cancel()
        }
    }
}
