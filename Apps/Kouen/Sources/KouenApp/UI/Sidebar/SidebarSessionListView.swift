import SwiftUI
import KouenCore
import KouenIPC

@MainActor
fileprivate func agentColor(for kind: AgentKind) -> Color {
    Color(nsColor: NSColor.fromHex(SessionCoordinator.shared.settings.agentColorHex(for: kind)) ?? KouenDesign.chrome.textSecondary)
}

// MARK: - Main container

struct SidebarSessionListView: View {
    var model: SidebarListModel
    var onSelect: (SessionID) -> Void
    var onOpenProject: (String) -> Void
    var onAddInGroup: (String, String?) -> Void
    var onCloseSession: (SessionID) -> Void
    var onRemoveProject: (String) -> Void
    var onPRClick: (String) -> Void
    var onWorktreeActivate: (SidebarWorktreeEntry, WorkspaceID?) -> Void

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(model.rows) { row in
                    rowContent(row)
                }
            }
            .padding(.vertical, 4)
        }
    }

    @ViewBuilder
    private func rowContent(_ row: SidebarSessionRow) -> some View {
        switch row {
        case let .groupHeader(id, name, rootPath, count, isCollapsed, status):
            SidebarGroupHeaderRow(
                id: id,
                name: name,
                rootPath: rootPath,
                count: count,
                isCollapsed: isCollapsed,
                status: status,
                model: model,
                onToggleCollapse: { model.toggleCollapse(id: id) },
                onAdd: { onAddInGroup(name, id) }
            )
            .frame(height: 28)

        case let .projectHeader(item):
            SidebarProjectHeaderRow(
                item: item,
                model: model,
                onAddSession: {
                    if let wsID = model.activeWorkspaceID {
                        SessionCoordinator.shared.addSession(to: wsID, cwd: item.path, name: item.name)
                        model.scheduleRebuild()
                    }
                },
                onRemoveProject: {
                    onRemoveProject(item.path)
                },
                onToggleCollapse: {
                    model.toggleProjectCollapse(path: item.path)
                }
            )
            .frame(height: 26)

        case let .sessionItem(card):
            SidebarSessionCardRow(
                card: card,
                model: model,
                onSelect: {
                    if let sid = card.sessionID {
                        onSelect(sid)
                    } else if let wtPath = card.worktreePath {
                        if let wsID = model.activeWorkspaceID {
                            SessionCoordinator.shared.addSession(to: wsID, cwd: wtPath, name: card.title)
                            model.scheduleRebuild()
                        }
                    } else {
                        if let wsID = model.activeWorkspaceID {
                            SessionCoordinator.shared.addSession(to: wsID, cwd: card.projectPath, name: card.title)
                            model.scheduleRebuild()
                        }
                    }
                },
                onClose: {
                    if let sid = card.sessionID {
                        onCloseSession(sid)
                    }
                }
            )
            .frame(height: 34)

        case .divider:
            SidebarDividerRow()
                .frame(height: 10)
        }
    }
}

// MARK: - Group header row

private struct SidebarGroupHeaderRow: View {
    let id: String
    let name: String
    let rootPath: String?
    let count: Int
    let isCollapsed: Bool
    let status: BoardColumnKind
    var model: SidebarListModel
    var onToggleCollapse: () -> Void
    var onAdd: () -> Void

    @State private var isHovered = false

    var body: some View {
        let c = KouenDesign.chrome
        HStack(spacing: 6) {
            Image(systemName: isCollapsed ? "chevron.right" : "chevron.down")
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(isHovered
                    ? Color(nsColor: c.textPrimary)
                    : Color(nsColor: c.textSecondary))
                .frame(width: 10, height: 10)

            Image(systemName: "folder")
                .font(.system(size: 11))
                .foregroundStyle(Color(nsColor: c.textSecondary))

            Text(name)
                .font(.system(size: 12.5, weight: .bold))
                .foregroundStyle(Color(nsColor: c.textPrimary))
                .lineLimit(1)
                .truncationMode(.tail)

            Text("\(count)")
                .font(.system(size: 10.5, weight: .medium))
                .foregroundStyle(Color(nsColor: c.textTertiary))

            Spacer()

            if isHovered {
                Button(action: onAdd) {
                    Image(systemName: "plus")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color(nsColor: c.textSecondary))
                }
                .buttonStyle(.plain)
                .frame(width: 20, height: 20)
                .help("Add repository to \(name)")

                Menu {
                    Button("Add Repository to \(name)...") { onAdd() }
                    Divider()
                    Button("Delete Group", role: .destructive) {
                        let alert = NSAlert()
                        alert.messageText = "Delete Group '\(name)'?"
                        let countText = count == 1 ? "1 repository" : "\(count) repositories"
                        alert.informativeText = "Are you sure you want to delete this group? All \(countText) in this group will be removed from your project list.\n\n(Your files on disk will not be deleted.)"
                        alert.alertStyle = .warning
                        alert.addButton(withTitle: "Delete Group and Repositories")
                        alert.addButton(withTitle: "Cancel")
                        if alert.runModal() == .alertFirstButtonReturn {
                            model.projectStore?.removeCategoryAndProjects(id)
                            model.scheduleRebuild()
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color(nsColor: c.textSecondary))
                }
                .menuStyle(.borderlessButton)
                .menuIndicator(.hidden)
                .frame(width: 20, height: 20)
                .help("Group options")
            }
        }
        .padding(.horizontal, KouenDesign.horizontalInset)
        .contentShape(Rectangle())
        .onTapGesture { onToggleCollapse() }
        .onHover { isHovered = $0 }
    }
}

// MARK: - Project Header row (Clean text, NO icon/logo in front!)

private struct SidebarProjectHeaderRow: View {
    let item: SidebarProjectHeaderItem
    var model: SidebarListModel
    var onAddSession: () -> Void
    var onRemoveProject: () -> Void
    var onToggleCollapse: () -> Void

    @State private var isHovered = false

    var body: some View {
        let c = KouenDesign.chrome
        let indent: CGFloat = item.categoryID != nil ? 10 : 0
        HStack(spacing: 5) {
            // Expand / collapse chevron (NO icon/logo in front!)
            Image(systemName: item.isCollapsed ? "chevron.right" : "chevron.down")
                .font(.system(size: 8.5, weight: .semibold))
                .foregroundStyle(isHovered ? Color(nsColor: c.textPrimary) : Color(nsColor: c.textTertiary))
                .frame(width: 10, height: 10)

            // Clean project name text
            Text(item.name)
                .font(.system(size: 12.5, weight: .semibold))
                .foregroundStyle(Color(nsColor: c.textPrimary))
                .lineLimit(1)
                .truncationMode(.tail)

            if item.sessionsCount > 1 || item.isCollapsed {
                Text("• \(item.sessionsCount)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color(nsColor: c.textTertiary))
            }

            if item.hasWorktrees {
                Image(systemName: "arrow.triangle.branch")
                    .font(.system(size: 9.5, weight: .semibold))
                    .foregroundStyle(Color(nsColor: c.textTertiary))
            }

            Spacer()

            if isHovered {
                HStack(spacing: 2) {
                    Button(action: onAddSession) {
                        Image(systemName: "plus")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Color(nsColor: c.textSecondary))
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(.plain)
                    .help("New session in \(item.name)")

                    Menu {
                        projectActionsMenuContent
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Color(nsColor: c.textSecondary))
                    }
                    .menuStyle(.borderlessButton)
                    .menuIndicator(.hidden)
                    .frame(width: 20, height: 20)
                    .help("Project options")

                    Button(action: onRemoveProject) {
                        Image(systemName: "xmark")
                            .font(.system(size: 9.5, weight: .medium))
                            .foregroundStyle(Color(nsColor: c.textSecondary))
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(.plain)
                    .help("Remove \(item.name) from workspace")
                }
                .padding(.trailing, 4)
            }
        }
        .padding(.leading, KouenDesign.horizontalInset + indent)
        .padding(.trailing, KouenDesign.horizontalInset)
        .padding(.top, 4)
        .contentShape(Rectangle())
        .onTapGesture { onToggleCollapse() }
        .onHover { isHovered = $0 }
        .contextMenu {
            projectActionsMenuContent
        }
    }

    @ViewBuilder
    private var projectActionsMenuContent: some View {
        Button("New Session Here") { onAddSession() }
        Divider()

        // If categories exist, show "Move to Group >" with group list
        if let categories = model.projectStore?.categories, !categories.isEmpty {
            Menu("Move to Group") {
                ForEach(categories) { cat in
                    Button(cat.name) {
                        model.projectStore?.moveProject(item.path, toCategory: cat.id)
                        model.scheduleRebuild()
                    }
                    .disabled(item.categoryID == cat.id)
                }
            }
        }

        // "Add to Group…" creates a new group and moves this project into it
        Button("Add to Group…") {
            promptNewGroup(for: item.path)
        }

        if item.categoryID != nil {
            Button("Remove from Group") {
                model.projectStore?.moveProject(item.path, toCategory: nil)
                model.scheduleRebuild()
            }
        }

        Divider()
        Button("Reveal in Finder") {
            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: item.path)
        }
        Divider()
        Button("Remove from Workspace", role: .destructive) {
            onRemoveProject()
        }
    }

    private func promptNewGroup(for projectPath: String) {
        let alert = NSAlert()
        alert.messageText = "Add to Group"
        alert.informativeText = "Enter a name for the new group:"
        alert.alertStyle = .informational
        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 220, height: 24))
        input.placeholderString = "e.g. Personal, Work, Open Source"
        alert.accessoryView = input
        alert.addButton(withTitle: "Create & Move")
        alert.addButton(withTitle: "Cancel")
        alert.window.initialFirstResponder = input
        guard alert.runModal() == .alertFirstButtonReturn else { return }
        let name = input.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        if let store = model.projectStore {
            let cat = store.addCategory(name: name)
            store.moveProject(projectPath, toCategory: cat.id)
            model.scheduleRebuild()
        }
    }
}

// MARK: - Session card row (Indented under project, exactly like prod)

private struct SidebarSessionCardRow: View {
    let card: SidebarSessionCardItem
    var model: SidebarListModel
    var onSelect: () -> Void
    var onClose: () -> Void

    @State private var isHovered = false

    var body: some View {
        let c = KouenDesign.chrome
        let isSelected = card.isSelected

        let selectedFill = Color(nsColor: c.accent).opacity(c.isDark ? 0.14 : 0.10)
        let selectedBorder = Color(nsColor: c.focusRing).opacity(c.isDark ? 0.48 : 0.52)
        let fillColor = isSelected ? selectedFill : (isHovered ? Color(nsColor: c.rowHoverFill) : Color.clear)
        let borderColor = isSelected ? selectedBorder : Color.clear

        ZStack {
            RoundedRectangle(cornerRadius: KouenDesign.Radius.card, style: .continuous)
                .fill(fillColor)
                .overlay(
                    RoundedRectangle(cornerRadius: KouenDesign.Radius.card, style: .continuous)
                        .stroke(borderColor, lineWidth: 1)
                )

            HStack(spacing: 6) {
                // Leading: Agent icon(s) OR status dot OR branch symbol
                if !card.detectedAgents.isEmpty {
                    HStack(spacing: 3) {
                        ForEach(card.detectedAgents.prefix(3)) { agent in
                            Image(nsImage: AgentIconRenderer.templateOrMonogramImage(for: agent.kind, size: 12))
                                .resizable()
                                .renderingMode(.template)
                                .foregroundStyle(agentColor(for: agent.kind))
                                .frame(width: 12, height: 12)
                                .help(agent.kind.rawValue)
                        }
                    }
                    .padding(.leading, 8)
                } else if let kind = card.agentKind {
                    Image(nsImage: AgentIconRenderer.templateOrMonogramImage(for: kind, size: 12))
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(agentColor(for: kind))
                        .frame(width: 12, height: 12)
                        .padding(.leading, 8)
                } else if card.worktreePath != nil {
                    Image(systemName: "arrow.triangle.branch")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Color(nsColor: c.textTertiary))
                        .frame(width: 12, height: 12)
                        .padding(.leading, 8)
                } else {
                    Circle()
                        .fill(card.isRunning ? (card.isDirty ? Color.orange : Color.green) : Color.secondary.opacity(0.35))
                        .frame(width: 6, height: 6)
                        .padding(.leading, 8)
                }

                // Title + Subtitle
                VStack(alignment: .leading, spacing: 1) {
                    Text(card.title)
                        .font(.system(size: 12, weight: isSelected ? .semibold : .medium))
                        .foregroundStyle(isSelected
                            ? Color(nsColor: c.textPrimary)
                            : Color(nsColor: isHovered ? c.textPrimary : c.textSecondary))
                        .lineLimit(1)
                        .truncationMode(.tail)

                    HStack(spacing: 4) {
                        if let sub = card.subtitle, !sub.isEmpty {
                            Text(sub)
                                .font(.system(size: 9.5))
                                .foregroundStyle(Color(nsColor: c.textTertiary))
                                .lineLimit(1)
                                .truncationMode(.tail)
                        } else if card.isRunning {
                            Text("Running")
                                .font(.system(size: 9.5))
                                .foregroundStyle(Color(nsColor: c.textTertiary))
                        }
                    }
                }

                Spacer()

                // Localhost port badge (like :51683 in prod)
                if let port = card.localhostPort {
                    Button(action: {
                        if let url = URL(string: "http://localhost:\(port)") {
                            NotificationCenter.default.post(
                                name: Notification.Name("KouenOpenInBrowserPaneURL"),
                                object: nil,
                                userInfo: ["url": url]
                            )
                        }
                    }) {
                        Text(":\(port)")
                            .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                            .foregroundStyle(Color(nsColor: c.textTertiary))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color(nsColor: c.textTertiary).opacity(0.15), in: RoundedRectangle(cornerRadius: 3))
                    }
                    .buttonStyle(.plain)
                    .help("Open http://localhost:\(port) in browser pane")
                }

                // Close button on hover
                if isHovered && card.isRunning {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 8.5, weight: .medium))
                            .foregroundStyle(Color(nsColor: c.textTertiary))
                            .frame(width: 14, height: 14)
                    }
                    .buttonStyle(.plain)
                    .help("Close session")
                    .padding(.trailing, 6)
                }
            }
        }
        .padding(.leading, KouenDesign.horizontalInset + (card.categoryID != nil ? 18 : 8))
        .padding(.trailing, KouenDesign.horizontalInset)
        .padding(.vertical, 1)
        .contentShape(Rectangle())
        .onTapGesture { onSelect() }
        .onHover { isHovered = $0 }
    }
}


// MARK: - Divider

private struct SidebarDividerRow: View {
    var body: some View {
        Rectangle()
            .fill(Color(nsColor: KouenDesign.chrome.border).opacity(0.5))
            .frame(height: 1)
            .padding(.horizontal, KouenDesign.horizontalInset)
    }
}

// MARK: - Badge

private struct SidebarBadgeLabel: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.system(size: 9, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(color, in: RoundedRectangle(cornerRadius: 4, style: .continuous))
    }
}

extension Notification.Name {
    static let kouenOpenDiffView = Notification.Name("KouenOpenDiffView")
}
