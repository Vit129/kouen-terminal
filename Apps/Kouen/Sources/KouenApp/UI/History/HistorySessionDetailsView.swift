import KouenCore
import SwiftUI

struct HistorySessionDetailsView: View {
    let record: AgentSessionRecord
    let projectRoot: (String) -> String
    let recoverTurnProjects: (AgentSessionRecord) async -> AgentSessionHistoryModel.RecoveredTurnProjects?
    @State private var recovered: AgentSessionHistoryModel.RecoveredTurnProjects?

    private var hasAvailableWorktree: Bool {
        var isDirectory: ObjCBool = false
        return record.worktreeAvailable
            && FileManager.default.fileExists(atPath: record.projectPath, isDirectory: &isDirectory)
            && isDirectory.boolValue
    }

    private var cleanPrompt: String? {
        let prompt = record.firstPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        return prompt.isEmpty ? nil : prompt
    }

    var body: some View {
        let c = KouenDesign.chrome
        let turns = recovered?.turns ?? record.latestTurns
        let sessionRoot = projectRoot(record.projectPath)
        let roots = turns.map { turn in
            let path = turn.projectPath ?? record.projectPath
            return recovered?.roots[path] ?? projectRoot(path)
        }
        let showProjects = roots.contains { $0 != sessionRoot }
        let latestTurns = showProjects ? turns : Array(turns.suffix(4))
        VStack(alignment: .leading, spacing: 7) {
            detailSection(title: "First Prompt") {
                if let cleanPrompt {
                    Text(cleanPrompt)
                        .font(.system(size: 9.5))
                        .foregroundStyle(Color(nsColor: c.textSecondary))
                        .textSelection(.enabled)
                        .lineLimit(5)
                } else {
                    unavailableText("No prompt was captured")
                }
            }

            detailSection(title: "Latest Turns") {
                if latestTurns.isEmpty {
                    unavailableText("No conversation turns were captured")
                } else {
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(Array(latestTurns.enumerated()), id: \.offset) { index, turn in
                            VStack(alignment: .leading, spacing: 2) {
                                if showProjects && (index == 0 || roots[index] != roots[index - 1]) {
                                    Text(ProjectGroupResolver.projectGroupDisplayName(forRootPath: roots[index]))
                                        .font(.system(size: 9.5, weight: .semibold))
                                        .foregroundStyle(Color(nsColor: c.textPrimary))
                                        .lineLimit(1)
                                        .help(roots[index])
                                }
                                Text(turn.role == "YOU" ? "You" : "Agent")
                                    .font(.system(size: 8.5, weight: .semibold))
                                    .foregroundStyle(Color(nsColor: c.textTertiary))
                                Text(turn.content.trimmingCharacters(in: .whitespacesAndNewlines))
                                    .font(.system(size: 9.5))
                                    .foregroundStyle(Color(nsColor: c.textSecondary))
                                    .textSelection(.enabled)
                                    .lineLimit(4)
                            }
                        }
                    }
                }
            }

            HStack(spacing: 4) {
                Image(systemName: hasAvailableWorktree ? "folder" : "folder.badge.questionmark")
                Text(hasAvailableWorktree ? "Worktree available" : "Worktree unavailable")
            }
            .font(.system(size: 8.5, weight: .medium))
            .foregroundStyle(Color(nsColor: hasAvailableWorktree ? c.success : c.danger))

            if let usage = record.usage {
                detailSection(title: "Usage") {
                    HStack(spacing: 8) {
                        usageValue("Context", value: usage.contextTokens ?? usage.inputTokens)
                        usageValue("Output", value: usage.outputTokens)
                        if let cost = usage.totalCostUSD {
                            Text(String(format: "$%.3f", cost))
                                .font(.system(size: 8.5, weight: .medium))
                                .foregroundStyle(Color(nsColor: c.textSecondary))
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .task(id: record) {
            recovered = nil
            let projects = await recoverTurnProjects(record)
            if !Task.isCancelled { recovered = projects }
        }
    }

    @ViewBuilder
    private func detailSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 8.5, weight: .bold))
                .foregroundStyle(Color(nsColor: KouenDesign.chrome.textTertiary))
            content()
        }
    }

    private func unavailableText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 9))
            .foregroundStyle(Color(nsColor: KouenDesign.chrome.textTertiary))
    }

    @ViewBuilder
    private func usageValue(_ title: String, value: Int?) -> some View {
        if let value {
            HStack(spacing: 2) {
                Text(title + ":")
                    .foregroundStyle(Color(nsColor: KouenDesign.chrome.textTertiary))
                Text("\(value)")
                    .foregroundStyle(Color(nsColor: KouenDesign.chrome.textSecondary))
            }
            .font(.system(size: 8.5, weight: .medium))
        }
    }
}
