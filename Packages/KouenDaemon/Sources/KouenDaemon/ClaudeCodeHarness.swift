import Foundation
import KouenCore

/// Drives headless CLI subprocesses (such as `claude -p --output-format stream-json`)
/// instead of the pty-pane screen-scrape `kouenSpawnAgent` uses. Built to
/// replace the shelved ACP integration's motivation: no adapter binary (spawns
/// the user's own CLI install), tool control via profile-driven CLI arguments, and
/// a PATH-resolution fix for the launchd-minimal-PATH problem that broke ACP.
///
/// One-shot only in this version: a run is prompt-in, result-out. Mid-run steering stays
/// the pty pane's job (`kouenSpawnAgent`); a follow-up turn is a new `start()` call with
/// `resumeSessionID` set to a prior run's id. See `agent-memory/plans/claude-code-harness/
/// design.md` for the full design and the empirical verification behind these choices.
///
/// Specific CLI behavior (argument construction, line decoding, binary probe commands)
/// is abstracted behind `HeadlessCLIAdapter`, one per supported `AgentKind` (`ClaudeAdapter`,
/// `CodexAdapter`, `AgyAdapter`, `CopilotAdapter` by default) — the engine looks one up per
/// `start()` call by the caller-supplied `agentKind`.
public actor ClaudeCodeHarness {
    public enum Profile: String, Sendable {
        case readonly
        case edit
    }

    public enum RunState: String, Codable, Sendable {
        case running
        case succeeded
        case failed
        case cancelled
    }

    public struct RunSummary: Codable, Sendable, Equatable {
        public var id: UUID
        public var state: RunState
        public var cwd: String
        public var startedAt: Date
        public var lastAssistantText: String?
        public var resultText: String?
        public var totalCostUSD: Double?
        public var exitCode: Int32?
        public var agentSessionID: String?

        public init(
            id: UUID,
            state: RunState,
            cwd: String,
            startedAt: Date,
            lastAssistantText: String? = nil,
            resultText: String? = nil,
            totalCostUSD: Double? = nil,
            exitCode: Int32? = nil,
            agentSessionID: String? = nil
        ) {
            self.id = id
            self.state = state
            self.cwd = cwd
            self.startedAt = startedAt
            self.lastAssistantText = lastAssistantText
            self.resultText = resultText
            self.totalCostUSD = totalCostUSD
            self.exitCode = exitCode
            self.agentSessionID = agentSessionID
        }
    }

    private struct Run {
        var summary: RunSummary
        var process: Process?
        let agentKind: AgentKind
        var stdoutBuffer = Data()
        /// Finish after both independent events: child exit and consumption of the last
        /// stdout chunk. The final line can carry the result or a terminal error.
        var exitCode: Int32?
        var stdoutDrained = false
    }

    public static let defaultAdapters: [any HeadlessCLIAdapter] = [ClaudeAdapter(), CodexAdapter(), AgyAdapter(), CopilotAdapter()]

    public static var registeredAgentKinds: [AgentKind] {
        defaultAdapters.map(\.agentKind)
    }

    public static func hasAdapter(for kind: AgentKind) -> Bool {
        registeredAgentKinds.contains(kind)
    }

    private let adapters: [AgentKind: any HeadlessCLIAdapter]
    private var runs: [UUID: Run] = [:]
    /// Per-adapter binary path cache — different agent kinds are different binaries, unlike
    /// the single-adapter version this replaced.
    private var cachedBinaryPaths: [AgentKind: String] = [:]
    private let transcriptsDirectory: URL

    public nonisolated var registeredAgentKinds: [AgentKind] {
        Array(adapters.keys)
    }

    public nonisolated func hasAdapter(for kind: AgentKind) -> Bool {
        adapters[kind] != nil
    }

    public init(adapters: [any HeadlessCLIAdapter] = ClaudeCodeHarness.defaultAdapters) {
        self.adapters = Dictionary(uniqueKeysWithValues: adapters.map { ($0.agentKind, $0) })
        transcriptsDirectory = KouenPaths.applicationSupport.appendingPathComponent("claude-runs", isDirectory: true)
        try? FileManager.default.createDirectory(at: transcriptsDirectory, withIntermediateDirectories: true)
    }

    // MARK: - Public API

    @discardableResult
    public func start(
        id: UUID,
        agentKind: AgentKind = .claudeCode,
        prompt: String,
        cwd: String,
        profile: Profile,
        model: String?,
        effort: String?,
        resumeSessionID: UUID?
    ) async -> RunSummary {
        let summary = RunSummary(id: id, state: .running, cwd: cwd, startedAt: Date())

        guard let adapter = adapters[agentKind] else {
            var failed = summary
            failed.state = .failed
            failed.resultText = "no headless adapter registered for '\(agentKind.rawValue)'"
            return failed
        }

        guard let binaryPath = await resolveBinary(for: adapter) else {
            var failed = summary
            failed.state = .failed
            failed.resultText = "\(adapter.binaryName) binary not found on PATH"
            return failed
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: binaryPath)
        process.arguments = adapter.buildArguments(
            id: id, prompt: prompt, profile: profile, model: model, effort: effort, resumeSessionID: resumeSessionID
        )
        process.currentDirectoryURL = URL(fileURLWithPath: cwd)
        var env = ProcessInfo.processInfo.environment
        if let path = await resolvedPATH() { env["PATH"] = path }
        // A resumed Claude run loads user settings (for plugin skills) and with them the user's
        // Stop hooks — the skill-capture nudge would otherwise replace the final reply.
        env["CLAUDE_SKILL_CAPTURE"] = "0"
        process.environment = env
        // Some adapters' CLIs (Codex's `exec`) read and append stdin even when a prompt is
        // given as an argument — closed explicitly so a daemon whose own stdin happens to be
        // a live, never-closed pipe can't make a headless run hang waiting for EOF. Claude
        // never reads stdin, so this is a no-op for it.
        process.standardInput = FileHandle.nullDevice

        let stdoutPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = FileHandle.nullDevice

        let transcriptURL = transcriptsDirectory.appendingPathComponent("\(id.uuidString).jsonl")
        FileManager.default.createFile(atPath: transcriptURL.path, contents: nil)
        let transcriptHandle = try? FileHandle(forWritingTo: transcriptURL)
        let reader = stdoutPipe.fileHandleForReading
        let writer = stdoutPipe.fileHandleForWriting

        process.terminationHandler = { [weak self] proc in
            let status = proc.terminationStatus
            Task { await self?.markProcessExited(id: id, exitCode: status) }
        }

        do {
            try process.run()
        } catch {
            process.terminationHandler = nil
            try? reader.close()
            try? writer.close()
            try? transcriptHandle?.close()
            var failed = summary
            failed.state = .failed
            failed.resultText = "failed to launch \(adapter.binaryName): \(error.localizedDescription)"
            return failed
        }

        try? writer.close()
        runs[id] = Run(summary: summary, process: process, agentKind: agentKind)
        let (chunks, stream) = AsyncStream<Data>.makeStream()
        DispatchQueue.global(qos: .userInitiated).async {
            DaemonPipeReader.drain(reader, from: process) { chunk in
                _ = try? transcriptHandle?.write(contentsOf: chunk)
                stream.yield(chunk)
            }
            try? transcriptHandle?.close()
            stream.finish()
        }
        Task { [weak self] in
            for await chunk in chunks {
                await self?.consume(chunk, forRun: id)
            }
            await self?.markStdoutDrained(id: id)
        }

        return summary
    }

    public func get(id: UUID) -> RunSummary? {
        runs[id]?.summary
    }

    public func list() -> [RunSummary] {
        runs.values.map(\.summary).sorted { $0.startedAt < $1.startedAt }
    }

    public func cancel(id: UUID) -> Bool {
        guard let run = runs[id], run.summary.state == .running else { return false }
        guard let process = run.process, process.isRunning else { return false }
        ProcessRunner.terminateWithEscalation(process)
        runs[id]?.summary.state = .cancelled
        return true
    }

    // MARK: - Stream-json parsing

    private func consume(_ chunk: Data, forRun id: UUID) {
        guard var run = runs[id] else { return }
        run.stdoutBuffer.append(chunk)
        while let newlineRange = run.stdoutBuffer.range(of: Data([0x0A])) {
            let lineData = run.stdoutBuffer.subdata(in: run.stdoutBuffer.startIndex..<newlineRange.lowerBound)
            run.stdoutBuffer.removeSubrange(run.stdoutBuffer.startIndex..<newlineRange.upperBound)
            parseLine(lineData, into: &run.summary, agentKind: run.agentKind)
        }
        runs[id] = run
    }

    /// `internal` (not `private`) so `ClaudeCodeHarnessTests` can exercise it directly via
    /// `@testable import` against real captured stream-json fixtures, without spawning an
    /// actual subprocess. `agentKind` defaults to `.claudeCode` so those existing calls (which
    /// predate multi-adapter support) keep compiling unchanged.
    func parseLine(_ lineData: Data, into summary: inout RunSummary, agentKind: AgentKind = .claudeCode) {
        guard let adapter = adapters[agentKind] else { return }
        let events = adapter.parseLine(lineData)
        for event in events {
            switch event {
            case .assistantText(let text):
                summary.lastAssistantText = text
            case .result(let text, let costUSD, let isError):
                summary.resultText = text
                summary.totalCostUSD = costUSD
                summary.state = isError ? .failed : .succeeded
            case .sessionID(let sessionID):
                summary.agentSessionID = sessionID
            }
        }
    }

    private func markProcessExited(id: UUID, exitCode: Int32) {
        guard runs[id] != nil else { return }
        runs[id]!.process = nil
        runs[id]!.exitCode = exitCode
        maybeFinish(id: id)
    }

    private func markStdoutDrained(id: UUID) {
        guard runs[id] != nil else { return }
        runs[id]!.stdoutDrained = true
        maybeFinish(id: id)
    }

    /// Runs `finish()` exactly once, only once both the process has exited and its stdout is
    /// fully drained — see `Run.exitCode`/`stdoutDrained`'s doc comment for why both are
    /// required. Whichever of `markProcessExited`/`markStdoutDrained` observes the run
    /// already satisfying both is the one that actually triggers it; the other is a no-op.
    private func maybeFinish(id: UUID) {
        guard let run = runs[id], run.stdoutDrained, let exitCode = run.exitCode else { return }
        finish(id: id, exitCode: exitCode)
    }

    private func finish(id: UUID, exitCode: Int32) {
        guard var run = runs[id] else { return }
        run.summary.exitCode = exitCode
        // A `result` line normally already set state; a process that exits without one
        // (crash, killed) falls back to exit-code interpretation here.
        if run.summary.state == .running {
            run.summary.state = exitCode == 0 ? .succeeded : .failed
        }
        // Some adapters' CLIs report completion with no separate "final text" field of their
        // own (Codex's `turn.completed`, Copilot's `result` line both carry only status/usage)
        // — the adapter emits `.assistantText` for the last real answer and no `.result` text
        // at all, so it falls back to whatever `.assistantText` already set here. Claude always
        // supplies `.result`'s own `text`, so this is a no-op for it.
        if run.summary.resultText == nil {
            run.summary.resultText = run.summary.lastAssistantText
        }
        runs[id] = run
    }

    // MARK: - Binary / PATH resolution

    /// Resolves the executable path using the adapter's probe command, falling back to its
    /// candidate fallback paths. Probed once per daemon lifetime and cached; this is also what
    /// fixes the launchd-minimal-PATH problem that shelved the ACP integration
    /// (`Kouen.entitlements` has App Sandbox off, so it was never a sandbox restriction — just a PATH one).
    private func resolveBinary(for adapter: any HeadlessCLIAdapter) async -> String? {
        if let cached = cachedBinaryPaths[adapter.agentKind] { return cached }
        let shellPath = ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/zsh"
        let probeCommand = adapter.probeCommand(shellPath: shellPath)
        if let resolved = await runProbe(shellPath: shellPath, command: probeCommand) {
            cachedBinaryPaths[adapter.agentKind] = resolved
            return resolved
        }
        for candidate in adapter.candidateBinaryPaths {
            let expanded = (candidate as NSString).expandingTildeInPath
            if FileManager.default.isExecutableFile(atPath: expanded) {
                cachedBinaryPaths[adapter.agentKind] = expanded
                return expanded
            }
        }
        return nil
    }

    private func resolvedPATH() async -> String? {
        let shellPath = ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/zsh"
        return await runProbe(shellPath: shellPath, command: "echo $PATH")
    }

    func runProbe(shellPath: String, command: String) async -> String? {
        let result = await ProcessRunner.runAsync(
            executable: shellPath, arguments: ["-l", "-c", command], timeout: 5
        )
        guard !result.isTimedOut, result.exitCode != -1 else { return nil }
        let output = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        return output.isEmpty ? nil : output
    }
}
