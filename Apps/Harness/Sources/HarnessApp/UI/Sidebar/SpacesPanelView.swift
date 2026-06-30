import SwiftUI
import HarnessCore

@Observable @MainActor
final class SpacesModel {
    var workspaces: [Workspace] = []
    var activeWorkspaceID: WorkspaceID?

    func update(from snapshot: SessionSnapshot) {
        workspaces = snapshot.workspaces
        activeWorkspaceID = snapshot.activeWorkspaceID
    }
}

struct SpacesPanelView: View {
    let model: SpacesModel

    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 6) {
                ForEach(model.workspaces, id: \.id) { workspace in
                    SpaceCardView(
                        workspace: workspace,
                        isActive: workspace.id == model.activeWorkspaceID
                    )
                }
            }
            .padding(.horizontal, HarnessDesign.horizontalInset)
            .padding(.vertical, 8)
        }
    }
}

private struct SpaceCardView: View {
    let workspace: Workspace
    let isActive: Bool

    private var allTabs: [Tab] { workspace.sessions.flatMap(\.tabs) }
    private var repoPath: String? { allTabs.compactMap(\.parentRepoPath).first ?? allTabs.first?.cwd }
    private var repoName: String {
        guard let p = repoPath else { return workspace.name }
        return URL(fileURLWithPath: p).lastPathComponent
    }
    private var branch: String? { allTabs.compactMap(\.gitBranch).first }
    private var sessionCount: Int { workspace.sessions.count }
    private var agentCount: Int { allTabs.filter { $0.agent != nil }.count }

    var body: some View {
        Button {
            SessionCoordinator.shared.selectWorkspace(workspace.id)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "square.on.square")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color(nsColor: HarnessDesign.chrome.textTertiary))
                    .frame(width: 16)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(repoName)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(nsColor: HarnessDesign.chrome.textPrimary))
                            .lineLimit(1)

                        if agentCount > 0 {
                            Text("\(agentCount)")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(Color.accentColor)
                                .clipShape(Capsule())
                        }
                    }

                    HStack(spacing: 6) {
                        if let branch {
                            Label(branch, systemImage: "arrow.triangle.branch")
                                .font(.system(size: 10))
                                .foregroundColor(Color(nsColor: HarnessDesign.chrome.textSecondary))
                                .lineLimit(1)
                        }
                        Text("\(sessionCount) session\(sessionCount == 1 ? "" : "s")")
                            .font(.system(size: 10))
                            .foregroundColor(Color(nsColor: HarnessDesign.chrome.textTertiary))
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isActive ? Color.accentColor.opacity(0.15) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}
