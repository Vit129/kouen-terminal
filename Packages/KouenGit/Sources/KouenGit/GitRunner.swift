import Foundation

private final class DataBox: @unchecked Sendable {
    private let lock = NSLock()
    private var storage = Data()

    func set(_ data: Data) {
        lock.lock()
        defer { lock.unlock() }
        storage = data
    }

    func get() -> Data {
        lock.lock()
        defer { lock.unlock() }
        return storage
    }
}

/// Safe, timed Git execution wrapper ensuring proper pipe-draining and timeout boundaries.
public final class GitRunner: Sendable {
    public static let shared = GitRunner()

    public let gitExecutableURL: URL

    public init(executablePath: String? = nil) {
        if let executablePath, FileManager.default.isExecutableFile(atPath: executablePath) {
            self.gitExecutableURL = URL(fileURLWithPath: executablePath)
        } else {
            let candidates = [
                "/usr/bin/git",
                "/opt/homebrew/bin/git",
                "/usr/local/bin/git",
            ]
            let resolved = candidates.first { FileManager.default.isExecutableFile(atPath: $0) } ?? "/usr/bin/git"
            self.gitExecutableURL = URL(fileURLWithPath: resolved)
        }
    }

    /// Executes git with the specified arguments in a given directory with a bounded timeout.
    @discardableResult
    public func execute(
        _ args: [String],
        in directory: String? = nil,
        timeout: TimeInterval = 30
    ) -> GitResult {
        let process = Process()
        process.executableURL = gitExecutableURL

        var finalArgs: [String] = []
        if let directory, !directory.isEmpty {
            finalArgs.append(contentsOf: ["-C", directory])
            process.currentDirectoryURL = URL(fileURLWithPath: directory)
        }
        finalArgs.append(contentsOf: args)
        process.arguments = finalArgs

        let outPipe = Pipe()
        let errPipe = Pipe()
        process.standardOutput = outPipe
        process.standardError = errPipe

        do {
            try process.run()
        } catch {
            return GitResult(exitCode: -1, stdout: "", stderr: error.localizedDescription)
        }

        let outBox = DataBox()
        let errBox = DataBox()
        let group = DispatchGroup()

        group.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            let data = outPipe.fileHandleForReading.readDataToEndOfFile()
            outBox.set(data)
            group.leave()
        }

        group.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            let data = errPipe.fileHandleForReading.readDataToEndOfFile()
            errBox.set(data)
            group.leave()
        }

        let waitResult = group.wait(timeout: .now() + timeout)
        if waitResult == .timedOut {
            process.terminate()
            return GitResult(exitCode: -2, stdout: "", stderr: "Git command timed out after \(timeout)s")
        }

        process.waitUntilExit()

        let stdoutStr = String(data: outBox.get(), encoding: .utf8) ?? ""
        let stderrStr = String(data: errBox.get(), encoding: .utf8) ?? ""
        return GitResult(exitCode: process.terminationStatus, stdout: stdoutStr, stderr: stderrStr)
    }

    /// Convenience for returning trimmed standard output on success.
    public func executeOutput(
        _ args: [String],
        in directory: String? = nil,
        timeout: TimeInterval = 30
    ) -> String? {
        let res = execute(args, in: directory, timeout: timeout)
        guard res.isSuccess else { return nil }
        return res.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
