import Foundation
import KouenCore

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

    /// Executes git with the specified arguments in a given directory with an optional timeout.
    @discardableResult
    public func execute(
        _ args: [String],
        in directory: String? = nil,
        timeout: TimeInterval? = nil
    ) -> GitResult {
        var finalArgs: [String] = []
        if let directory, !directory.isEmpty {
            finalArgs.append(contentsOf: ["-C", directory])
        }
        finalArgs.append(contentsOf: args)

        let res = ProcessRunner.run(
            executable: gitExecutableURL.path,
            arguments: finalArgs,
            in: directory,
            timeout: timeout
        )
        return GitResult(exitCode: res.exitCode, stdout: res.stdout, stderr: res.stderr)
    }

    /// Convenience for returning trimmed standard output on success.
    public func executeOutput(
        _ args: [String],
        in directory: String? = nil,
        timeout: TimeInterval? = nil
    ) -> String? {
        let res = execute(args, in: directory, timeout: timeout)
        guard res.isSuccess else { return nil }
        return res.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
