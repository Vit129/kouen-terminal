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

    private func run(_ command: [String], cwd: String) -> VerificationResult {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = command
        process.currentDirectoryURL = URL(fileURLWithPath: cwd)
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        do {
            try process.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            process.waitUntilExit()
            let output = String(data: data, encoding: .utf8) ?? ""
            return VerificationResult(passed: process.terminationStatus == 0, output: output, command: command.joined(separator: " "))
        } catch {
            return VerificationResult(passed: false, output: "\(error)", command: command.joined(separator: " "))
        }
    }
}
