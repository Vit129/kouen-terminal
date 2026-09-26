import Foundation
import KouenIPC

/// Formats cross-agent handoff briefs and encodes bracketed paste payloads for terminal injection.
public enum AgentHandoffBuilder: Sendable {
    /// Formats a structured, high-signal handoff brief from an existing session record to pass to a new agent.
    public static func buildBrief(from record: AgentSessionRecord, targetAgent: AgentKind? = nil) -> String {
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

        // 2. Recent Context
        if !record.latestTurns.isEmpty {
            lines.append("## Recent Progress & Discussion")
            let turnsToInclude = record.latestTurns.suffix(3)
            for turn in turnsToInclude {
                let role = turn.role.capitalized
                let content = turn.content.trimmingCharacters(in: .whitespacesAndNewlines)
                lines.append("**[\(role)]** \(content)")
            }
            lines.append("")
        }

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
