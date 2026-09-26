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

        return lines.joined(separator: "\n")
    }

    /// Wraps text in terminal bracketed-paste markers (`\e[200~` and `\e[201~`) followed by a carriage return (`\r`)
    /// so the terminal program receives the multi-line input as a single atomic paste rather than individual lines.
    public static func bracketedPasteData(for text: String) -> Data {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        var data = Data("\u{1b}[200~".utf8)
        data.append(Data(trimmed.utf8))
        data.append(Data("\u{1b}[201~\r".utf8))
        return data
    }
}
