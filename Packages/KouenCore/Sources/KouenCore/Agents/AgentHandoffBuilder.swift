import Foundation
import KouenIPC

/// Formats cross-agent handoff briefs and encodes bracketed paste payloads for terminal injection.
public enum AgentHandoffBuilder: Sendable {
    /// Formats a structured, high-signal handoff brief from an existing session record to pass to a new agent.
    public static func buildBrief(from record: AgentSessionRecord, targetAgent: AgentKind? = nil, handoffNotePath: String? = nil) -> String {
        var lines: [String] = []

        let targetName = targetAgent?.displayName ?? "New Agent"
        lines.append("📋 Task Handoff from \(record.agentKind.displayName) to \(targetName)")
        lines.append("")

        // 1. Goal
        lines.append("## Goal")
        let goal = record.firstPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        if !goal.isEmpty {
            lines.append(goal)
        } else {
            lines.append(record.title)
        }
        lines.append("")

        // 2. Full context by reference, not by copy (same rule as the `handoff` skill: don't
        // duplicate what already lives in an artifact). Truncated turns cost tokens and cut
        // sentences mid-way; every agent can open the transcript itself when it needs more.
        lines.append("## Previous Session")
        if let handoffNotePath {
            lines.append("Handoff note written by \(record.agentKind.displayName) — read this first: `\(handoffNotePath)`")
        }
        lines.append("Full \(record.agentKind.displayName) transcript (read only if you need more context): `\(record.transcriptPath)`")
        lines.append("")

        // 3. Handoff note from repository if exists (SignalFileRouter)
        if let handoff = SignalFileRouter.handoffInfo(at: record.projectPath) {
            lines.append("## Handoff Note (from repo)")
            lines.append(handoff.note)
            if let skills = handoff.suggestedSkills {
                lines.append("**Suggested skills:** \(skills)")
            }
            lines.append("")
        }

        // 4. Instructions
        lines.append("## Next Steps")
        lines.append("Please inspect `git status` and `git diff` to understand current progress, then continue working on the task.")

        return lines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Source-agent handoff note

    /// The `mattpocock-skills:handoff` skill's instructions, for agents that don't have the skill
    /// installed. Asks for the doc on stdout — a headless run can't answer a Write permission prompt.
    static let handoffInstructions = """
        Write a handoff document summarising this conversation so a fresh agent can continue the work. \
        Include a "suggested skills" section naming skills the next agent should use. \
        Do not duplicate content already captured in other artifacts (specs, plans, ADRs, issues, commits, diffs); \
        reference them by path or URL instead. Redact any sensitive information such as API keys, passwords, or PII. \
        Output the full document as your final reply; do not save any file.
        """

    /// argv for resuming `record` headlessly and printing a handoff doc; `nil` when that agent
    /// has no verified non-interactive resume (caller falls back to the transcript-only brief).
    public static func headlessHandoffArguments(for record: AgentSessionRecord) -> [String]? {
        switch record.agentKind {
        case .claudeCode:
            return ["claude", "--resume", record.id, "-p",
                    "/mattpocock-skills:handoff Output the full document as your final reply as well."]
        case .antigravity:
            return ["agy", "--conversation", record.id, "-p", handoffInstructions]
        case .codex:
            return ["codex", "exec", "--skip-git-repo-check", "resume", record.id, handoffInstructions]
        default:
            return nil
        }
    }

    /// Resumes the source session headlessly (through a login shell, so the GUI app gets the
    /// user's PATH) and returns the handoff doc it prints, or `nil` on failure/timeout/empty output —
    /// e.g. the source agent is out of quota, which is often why the user is handing off at all.
    public static func generateHandoffNote(for record: AgentSessionRecord, timeout: TimeInterval = 180) async -> String? {
        guard let args = headlessHandoffArguments(for: record) else { return nil }
        let shell = ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/zsh"
        let cwd = FileManager.default.fileExists(atPath: record.projectPath) ? record.projectPath : NSHomeDirectory()
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let process = Process()
                process.executableURL = URL(fileURLWithPath: shell)
                process.arguments = ["-l", "-c", "exec \"$@\"", "kouen-handoff"] + args
                process.currentDirectoryURL = URL(fileURLWithPath: cwd)
                process.standardInput = FileHandle.nullDevice
                process.standardError = FileHandle.nullDevice
                let out = Pipe()
                process.standardOutput = out
                do { try process.run() } catch { continuation.resume(returning: nil); return }
                let killer = DispatchWorkItem { if process.isRunning { process.terminate() } }
                DispatchQueue.global().asyncAfter(deadline: .now() + timeout, execute: killer)
                let data = out.fileHandleForReading.readDataToEndOfFile()
                process.waitUntilExit()
                killer.cancel()
                let text = String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
                continuation.resume(returning: process.terminationStatus == 0 && !text.isEmpty ? text : nil)
            }
        }
    }

    /// Wraps text in terminal bracketed-paste markers (`\e[200~` … `\e[201~`) followed by `submit`,
    /// so the terminal program receives multi-line input as one atomic paste. ESC bytes are stripped
    /// from `text` first: an embedded `\e[201~` (e.g. terminal output quoted in a transcript) would
    /// otherwise end the paste early and turn the rest into live keystrokes.
    public static func bracketedPasteData(for text: String, submit: String = "\r") -> Data {
        let safe = text.replacingOccurrences(of: "\u{1b}", with: "")
        var data = Data("\u{1b}[200~".utf8)
        data.append(Data(safe.utf8))
        data.append(Data(("\u{1b}[201~" + submit).utf8))
        return data
    }
}
