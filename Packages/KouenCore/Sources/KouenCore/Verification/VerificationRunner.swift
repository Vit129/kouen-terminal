import Foundation

/// P46 Phase 4: Multi-Stage Continuous Verification. Tier 1 is a fast syntax/typecheck pass
/// (no full test run) picked by the project's own marker file — matches `rules/core.md`'s
/// Test-Before-Deliver rule ("run the project's static type/syntax checker if one exists")
/// applied automatically after each agent turn instead of only at Done-gate time. Tier 2 is the
/// project's own full test command; ponytail: "targeted" here means "the project's own test
/// command," not per-file test selection (that needs build-graph knowledge — e.g. Graphify —
/// this runner doesn't have; upgrade path if false-negative-from-irrelevant-test-noise becomes
/// a real problem).
public struct VerificationResult: Sendable, Equatable {
    public let passed: Bool
    public let output: String
    public let command: String

    public init(passed: Bool, output: String, command: String) {
        self.passed = passed
        self.output = output
        self.command = command
    }
}

public struct VerificationRunner: Sendable {
    public init() {}

    /// Runs the fast syntax/typecheck command for whatever toolchain `cwd` looks like it uses.
    /// Nil (not failure) when no known marker file is found — an unrecognized project type is
    /// silently skipped, not reported as a failure.
    public func tier1SyntaxCheck(cwd: String) -> VerificationResult? {
        guard let command = Self.detectTier1Command(cwd: cwd) else { return nil }
        return run(command, cwd: cwd)
    }

    /// Runs the project's own full test command.
    public func tier2TestRun(cwd: String) -> VerificationResult? {
        guard let command = Self.detectTier2Command(cwd: cwd) else { return nil }
        return run(command, cwd: cwd)
    }

    // MARK: - Detection (pure — no process execution, safe to unit test without the toolchains installed)

    /// `internal` (not `private`) so `VerificationRunnerTests` can exercise detection without
    /// actually running `swift build`/`tsc`/etc. — those are slow and depend on tools that may
    /// not be installed in every test environment.
    static func detectTier1Command(cwd: String) -> [String]? {
        let fm = FileManager.default
        if fm.fileExists(atPath: cwd + "/tsconfig.json") { return ["npx", "--no-install", "tsc", "--noEmit"] }
        if fm.fileExists(atPath: cwd + "/Package.swift") { return ["swift", "build"] }
        if fm.fileExists(atPath: cwd + "/go.mod") { return ["go", "vet", "./..."] }
        if fm.fileExists(atPath: cwd + "/Cargo.toml") { return ["cargo", "check"] }
        if fm.fileExists(atPath: cwd + "/pyproject.toml") { return ["ruff", "check", "."] }
        return nil
    }

    static func detectTier2Command(cwd: String) -> [String]? {
        let fm = FileManager.default
        if fm.fileExists(atPath: cwd + "/Package.swift") { return ["swift", "test"] }
        if fm.fileExists(atPath: cwd + "/package.json") { return ["npm", "test", "--silent"] }
        if fm.fileExists(atPath: cwd + "/go.mod") { return ["go", "test", "./..."] }
        if fm.fileExists(atPath: cwd + "/Cargo.toml") { return ["cargo", "test"] }
        if fm.fileExists(atPath: cwd + "/pyproject.toml") || fm.fileExists(atPath: cwd + "/setup.py") { return ["pytest", "-q"] }
        return nil
    }

    // MARK: - Execution

    /// Ceiling on any single verification run — `.notifyDone`'s `hookQueue` is a shared serial
    /// queue other daemon background work (automations, checkpoints) also runs on, so a runaway
    /// `swift build`/`npm test` must never be allowed to hang it forever. Matches the same
    /// kill-after-timeout pattern `runGitCommandInDaemon` already uses for its own subprocess.
    private static let timeout: TimeInterval = 120

    /// Boxes the "did our own timeout fire" flag so the `DispatchWorkItem` closure and `run(_:in:)`
    /// can share it — `DispatchWorkItem.isCancelled` only reflects whether `.cancel()` was called,
    /// never whether the work item had already run by that point, so it can't answer this.
    private final class TimeoutFlag: @unchecked Sendable {
        private let lock = NSLock()
        private var fired = false
        func markFired() { lock.lock(); fired = true; lock.unlock() }
        var didFire: Bool { lock.lock(); defer { lock.unlock() }; return fired }
    }

    private func run(_ command: [String], cwd: String) -> VerificationResult {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = command
        process.currentDirectoryURL = URL(fileURLWithPath: cwd)
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        let timeoutFlag = TimeoutFlag()
        let timeoutWork = DispatchWorkItem {
            guard process.isRunning else { return }
            timeoutFlag.markFired()
            process.terminate()
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + Self.timeout, execute: timeoutWork)

        do {
            try process.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            process.waitUntilExit()
            timeoutWork.cancel() // no-op if it already fired; prevents a late-firing no-op after a fast exit
            let output = String(data: data, encoding: .utf8) ?? ""
            if timeoutFlag.didFire {
                return VerificationResult(passed: false, output: output + "\n[killed: exceeded \(Int(Self.timeout))s timeout]", command: command.joined(separator: " "))
            }
            return VerificationResult(passed: process.terminationStatus == 0, output: output, command: command.joined(separator: " "))
        } catch {
            timeoutWork.cancel()
            return VerificationResult(passed: false, output: "\(error)", command: command.joined(separator: " "))
        }
    }
}
