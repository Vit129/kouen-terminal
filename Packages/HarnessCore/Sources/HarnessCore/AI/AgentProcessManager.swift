import Foundation

/// Spawns an AI agent CLI in print/exec mode and streams its stdout line-by-line.
///
/// Uses `claude -p`, `codex exec`, `agy -p`, etc. — no ACP framing, no API key.
/// Context is injected on stdin (last N pane lines); the query is a CLI argument.
///
/// Thread-safety: all public methods are `async` and callable from any context.
/// Each `query()` call creates a fresh Process; earlier streams are not cancelled
/// automatically — the caller must cancel via the AsyncStream's on-termination block.
public actor AgentProcessManager {

    public enum Chunk: Sendable {
        case text(String)
        case done
        case error(String)
    }

    // Cached resolved binary paths: binaryName → absolute path
    private var resolvedPaths: [String: String] = [:]

    public init() {}

    // MARK: - Public API

    /// Resolve the agent binary path using a login shell `which` call.
    /// Result is cached for the lifetime of this actor.
    public func resolvePath(for config: AIAgentConfig) async -> String? {
        if let override = config.binaryPathOverride, !override.isEmpty {
            return override
        }
        let name = config.binaryName
        if let cached = resolvedPaths[name] { return cached }

        let path = await resolveViLoginShell(name)
        if let path { resolvedPaths[name] = path }
        return path
    }

    /// Spawn the agent CLI with `query` as the positional argument, inject `context`
    /// on stdin, and stream stdout chunks back. The stream ends with `.done` or `.error`.
    public func query(
        _ text: String,
        context: String,
        config: AIAgentConfig
    ) -> AsyncStream<Chunk> {
        AsyncStream<Chunk> { continuation in
            Task {
                guard let path = await self.resolvePath(for: config) else {
                    continuation.yield(.error("'\(config.binaryName)' not found on PATH. Install it or set a path override in Settings → AI."))
                    continuation.finish()
                    return
                }

                let proc = Process()
                proc.executableURL = URL(fileURLWithPath: path)
                proc.arguments = config.cliArgs(query: text)

                // Stdin: inject terminal context before the query
                let stdinPipe = Pipe()
                proc.standardInput = stdinPipe

                let stdoutPipe = Pipe()
                proc.standardOutput = stdoutPipe

                let stderrPipe = Pipe()
                proc.standardError = stderrPipe

                // Write context to stdin and close before launch so the agent reads EOF
                let contextData = (context.isEmpty ? "" : context + "\n").data(using: .utf8) ?? Data()
                stdinPipe.fileHandleForWriting.write(contextData)
                stdinPipe.fileHandleForWriting.closeFile()

                do {
                    try proc.run()
                } catch {
                    continuation.yield(.error("Failed to launch \(config.binaryName): \(error.localizedDescription)"))
                    continuation.finish()
                    return
                }

                // Stream stdout line-by-line
                let handle = stdoutPipe.fileHandleForReading
                var buffer = Data()
                while proc.isRunning || handle.availableData.count > 0 {
                    let chunk = handle.availableData
                    if chunk.isEmpty { break }
                    buffer.append(chunk)
                    // Yield complete lines, hold partial last line in buffer
                    while let newline = buffer.firstIndex(of: UInt8(ascii: "\n")) {
                        let lineData = buffer[buffer.startIndex...newline]
                        if let line = String(data: lineData, encoding: .utf8) {
                            continuation.yield(.text(line))
                        }
                        buffer = buffer[buffer.index(after: newline)...]
                    }
                }
                // Flush remaining partial line (no trailing newline)
                if !buffer.isEmpty, let tail = String(data: buffer, encoding: .utf8) {
                    continuation.yield(.text(tail))
                }

                proc.waitUntilExit()
                let status = proc.terminationStatus
                if status != 0 {
                    let errData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
                    let errMsg = String(data: errData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    if !errMsg.isEmpty {
                        continuation.yield(.error(errMsg))
                    }
                }
                continuation.finish()
            }
        }
    }

    // MARK: - Private

    /// Resolve a binary name via `/bin/zsh -l -c "which <name>"` so PATH from the
    /// user's shell profile (homebrew, nix, mise, etc.) is respected.
    private func resolveViLoginShell(_ name: String) async -> String? {
        await withCheckedContinuation { continuation in
            let proc = Process()
            proc.executableURL = URL(fileURLWithPath: "/bin/zsh")
            proc.arguments = ["-l", "-c", "which \(name)"]
            let pipe = Pipe()
            proc.standardOutput = pipe
            proc.standardError = Pipe()
            do {
                try proc.run()
                proc.waitUntilExit()
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let path = String(data: data, encoding: .utf8)?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                continuation.resume(returning: (path?.isEmpty == false) ? path : nil)
            } catch {
                continuation.resume(returning: nil)
            }
        }
    }
}
