import SwiftUI
import HarnessCore

// MARK: - Main container

struct SidebarSessionListView: View {
    var model: SidebarListModel
    var onSelect: (SessionID) -> Void
    var onAddInGroup: (String) -> Void
    var onGroupOptions: (String, String) -> Void
    var onCloseSession: (SessionID) -> Void
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
        case let .groupHeader(name, rootPath, count, isCollapsed, status):
            SidebarGroupHeaderRow(
                name: name,
                rootPath: rootPath,
                count: count,
                isCollapsed: isCollapsed,
                status: status,
                model: model,
                onToggleCollapse: { model.toggleCollapse(rootPath: rootPath) },
                onAdd: { onAddInGroup(rootPath) },
                onOptions: { onGroupOptions(rootPath, name) }
            )
            .frame(height: 28)

        case let .session(session):
            SidebarSessionItemRow(
                session: session,
                isSelected: session.id == model.activeSessionID,
                model: model,
                onSelect: { onSelect(session.id) },
                onClose: { onCloseSession(session.id) },
                onPRClick: onPRClick
            )
            .frame(height: 40)

        case let .worktreeHeader(rootPath, count, isCollapsed):
            SidebarWorktreeHeaderRow(
                count: count,
                isCollapsed: isCollapsed,
                onToggleCollapse: { model.toggleWorktreeCollapse(rootPath: rootPath) }
            )
            .frame(height: 24)

        case let .worktree(entry, _):
            SidebarWorktreeItemRow(
                entry: entry,
                model: model,
                onActivate: { onWorktreeActivate(entry, model.activeWorkspaceID) }
            )
            .frame(height: 40)

        case .divider:
            SidebarDividerRow()
                .frame(height: 10)
        }
    }
}

// MARK: - Group header row

private struct SidebarGroupHeaderRow: View {
    let name: String
    let rootPath: String
    let count: Int
    let isCollapsed: Bool
    let status: BoardColumnKind
    var model: SidebarListModel
    var onToggleCollapse: () -> Void
    var onAdd: () -> Void
    var onOptions: () -> Void

    @State private var isHovered = false

    var body: some View {
        let c = HarnessDesign.chrome
        HStack(spacing: 6) {
            Image(systemName: isCollapsed ? "chevron.right" : "chevron.down")
                .font(.system(size: 9, weight: .regular))
                .foregroundStyle(isHovered
                    ? Color(nsColor: c.textPrimary)
                    : Color(nsColor: c.textSecondary))
                .frame(width: 10, height: 10)

            Text(name)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color(nsColor: c.textPrimary))
                .lineLimit(1)
                .truncationMode(.tail)

            Circle()
                .fill(statusColor(status))
                .frame(width: 6, height: 6)

            Text("\(count)")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(isHovered
                    ? Color(nsColor: c.textSecondary)
                    : Color(nsColor: c.textTertiary))

            Spacer()

            if isHovered {
                Button(action: onAdd) {
                    Image(systemName: "plus")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color(nsColor: c.textSecondary))
                }
                .buttonStyle(.plain)
                .frame(width: 20, height: 20)
                .help("New session in group")

                Button(action: onOptions) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color(nsColor: c.textSecondary))
                }
                .buttonStyle(.plain)
                .frame(width: 20, height: 20)
                .help("Group options")
            }
        }
        .padding(.horizontal, HarnessDesign.horizontalInset)
        .contentShape(Rectangle())
        .onTapGesture { onToggleCollapse() }
        .onHover { isHovered = $0 }
        .contextMenu {
            let isPinned = model.pinnedRepos.contains(rootPath)
            Button(isPinned ? "Unpin Repo" : "Pin Repo") {
                model.togglePinRepo(rootPath: rootPath)
            }
            Divider()
            Button("Close all sessions in \(name)", role: .destructive) {
                closeAllSessions(name: name)
            }
        }
    }

    private func closeAllSessions(name: String) {
        let groupSessions = model.sessions.filter { model.repoRootForSession($0) == rootPath }
        guard !groupSessions.isEmpty else { return }
        let alert = NSAlert()
        alert.messageText = "Close all sessions in \(name)?"
        alert.informativeText = "This will close \(groupSessions.count) session\(groupSessions.count == 1 ? "" : "s") and all their tabs."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Close All")
        alert.addButton(withTitle: "Cancel")
        alert.buttons[0].keyEquivalent = ""
        alert.buttons[1].keyEquivalent = ""
        guard alert.runModal() == .alertFirstButtonReturn else { return }
        for session in groupSessions {
            SessionCoordinator.shared.closeSession(session)
        }
        SessionCoordinator.shared.syncFromDaemon()
    }

    private func statusColor(_ status: BoardColumnKind) -> Color {
        switch status {
        case .needsAttention: .orange
        case .running: .blue
        case .done: .green
        case .error: .red
        case .idle: Color(nsColor: HarnessDesign.chrome.idleStatus)
        }
    }
}

// MARK: - Session card row

private struct SidebarSessionItemRow: View {
    let session: SessionGroup
    let isSelected: Bool
    var model: SidebarListModel
    var onSelect: () -> Void
    var onClose: () -> Void
    var onPRClick: (String) -> Void

    @State private var isHovered = false

    var body: some View {
        let c = HarnessDesign.chrome
        let tab = session.activeTab ?? session.tabs.first
        let branch = tab?.gitBranch?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let cwd = tab?.cwd ?? ""
        let sessionTitle = session.name.isEmpty ? HarnessDesign.pathDisplayName(cwd) : session.name
        let displayTitle = branch.isEmpty ? sessionTitle : branch
        let subtitle = HarnessDesign.shortenPath(cwd)
        let metadata = model.gitMetadata(forPath: cwd, branch: branch)

        let selectedFill = Color(nsColor: c.accent).opacity(c.isDark ? 0.13 : 0.10)
        let selectedBorder = Color(nsColor: c.focusRing).opacity(c.isDark ? 0.48 : 0.52)
        let fillColor = isSelected ? selectedFill : (isHovered ? Color(nsColor: c.rowHoverFill) : Color.clear)
        let borderColor = isSelected ? selectedBorder : Color.clear

        ZStack {
            RoundedRectangle(cornerRadius: HarnessDesign.Radius.card, style: .continuous)
                .fill(fillColor)
                .overlay(
                    RoundedRectangle(cornerRadius: HarnessDesign.Radius.card, style: .continuous)
                        .stroke(borderColor, lineWidth: 1)
                )

            HStack(spacing: 0) {
                Circle()
                    .fill(Color(nsColor: agentDotColor(c: c)))
                    .frame(width: 6, height: 6)
                    .padding(.leading, 8)

                Image(systemName: "arrow.triangle.branch")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color(nsColor: agentDotColor(c: c)))
                    .frame(width: 12, height: 12)
                    .padding(.leading, 6)

                VStack(alignment: .leading, spacing: 1) {
                    Text(displayTitle)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(isSelected
                            ? Color(nsColor: c.textPrimary)
                            : Color(nsColor: c.textSecondary))
                        .lineLimit(1)
                        .truncationMode(.tail)

                    Text(subtitle)
                        .font(.system(size: 10))
                        .foregroundStyle(Color(nsColor: c.textSecondary).opacity(0.6))
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                .padding(.leading, 6)

                Spacer()

                HStack(spacing: 4) {
                    if let pr = metadata?.prNumber {
                        let prColor: Color = (metadata?.aheadCount ?? 0) > 0
                            ? .green : Color(nsColor: c.accent)
                        SidebarBadgeLabel(text: "#\(pr)", color: prColor)
                            .onTapGesture {
                                if let url = metadata?.prURL { onPRClick(url) }
                            }
                    }
                    if let ahead = metadata?.aheadCount, ahead > 0 {
                        SidebarBadgeLabel(text: "+\(ahead)", color: .green)
                    }
                    if let behind = metadata?.behindCount, behind > 0 {
                        SidebarBadgeLabel(text: "-\(behind)", color: .red)
                    }
                    if isHovered {
                        Button(action: onClose) {
                            Text("×")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundStyle(Color(nsColor: c.textSecondary))
                        }
                        .buttonStyle(.plain)
                        .frame(width: 18, height: 18)
                        .help("Close session")
                    }
                }
                .padding(.trailing, 6)
            }
        }
        .padding(.leading, HarnessDesign.horizontalInset + 8)
        .padding(.trailing, HarnessDesign.horizontalInset - 4)
        .padding(.vertical, 1)
        .contentShape(Rectangle())
        .onTapGesture { onSelect() }
        .onHover { isHovered = $0 }
        .contextMenu {
            sessionContextMenuItems(cwd: cwd, branch: branch, sessionTitle: sessionTitle)
        }
    }

    @ViewBuilder
    private func sessionContextMenuItems(cwd: String, branch: String, sessionTitle: String) -> some View {
        Button("Rename session…") {
            renameSession(currentTitle: sessionTitle)
        }
        Button("Copy working directory") {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(cwd, forType: .string)
        }
        Button("Copy session title") {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(sessionTitle, forType: .string)
        }
        Button("Copy Session ID") {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(session.id.uuidString, forType: .string)
        }
        Divider()
        Button("Split session right") {
            guard let wsID = model.activeWorkspaceID else { return }
            SessionCoordinator.shared.splitSession(workspaceID: wsID, sessionID: session.id, direction: .horizontal)
        }
        Button("Split session down") {
            guard let wsID = model.activeWorkspaceID else { return }
            SessionCoordinator.shared.splitSession(workspaceID: wsID, sessionID: session.id, direction: .vertical)
        }
        Divider()
        let globallyKept = SessionCoordinator.shared.snapshot.keepSessionsOnQuit
        Button(globallyKept ? "Keep running after quit (all sessions kept)" : "Keep running after quit") {
            SessionCoordinator.shared.requestDaemon(
                .setSessionPersistent(sessionID: session.id, persistent: !session.persistent)
            )
            SessionCoordinator.shared.syncFromDaemon()
        }
        Divider()
        Button("Close session", role: .destructive) {
            confirmClose()
        }
        if model.sessions.count > 1 {
            Button("Close other sessions", role: .destructive) {
                closeOtherSessions()
            }
        }
    }

    private func renameSession(currentTitle: String) {
        let alert = NSAlert()
        alert.messageText = "Rename session"
        alert.informativeText = "Enter a new name for this session."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Rename")
        alert.addButton(withTitle: "Cancel")
        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 240, height: 22))
        input.stringValue = currentTitle
        alert.accessoryView = input
        alert.window.initialFirstResponder = input
        guard alert.runModal() == .alertFirstButtonReturn else { return }
        let trimmed = input.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed != session.name else { return }
        SessionCoordinator.shared.requestDaemon(.renameSession(sessionID: session.id, name: trimmed))
        SessionCoordinator.shared.syncFromDaemon()
    }

    private func confirmClose() {
        let alert = NSAlert()
        alert.messageText = "Close session?"
        alert.informativeText = session.tabs.count > 1
            ? "This will close \(session.tabs.count) tabs and their running shells."
            : "This will close the session and its running shell."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Close Session")
        alert.addButton(withTitle: "Cancel")
        alert.buttons[0].keyEquivalent = ""
        alert.buttons[1].keyEquivalent = ""
        guard alert.runModal() == .alertFirstButtonReturn else { return }
        onClose()
    }

    private func closeOtherSessions() {
        guard let wsID = model.activeWorkspaceID else { return }
        let others = model.sessions.filter { $0.id != session.id }
        guard !others.isEmpty else { return }
        let alert = NSAlert()
        alert.messageText = "Close \(others.count) other session\(others.count == 1 ? "" : "s")?"
        alert.informativeText = "Their tabs and running shells will be closed."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Close Others")
        alert.addButton(withTitle: "Cancel")
        alert.buttons[0].keyEquivalent = ""
        alert.buttons[1].keyEquivalent = ""
        guard alert.runModal() == .alertFirstButtonReturn else { return }
        for other in others {
            SessionCoordinator.shared.closeSession(other)
        }
        SessionCoordinator.shared.selectSession(workspaceID: wsID, sessionID: session.id)
        SessionCoordinator.shared.syncFromDaemon()
    }

    private func agentDotColor(c: HarnessChromePalette) -> NSColor {
        let tabsWithAgents = session.tabs.filter { $0.effectiveAgentKind != nil }
        guard !tabsWithAgents.isEmpty else { return c.idleStatus }
        if tabsWithAgents.contains(where: { $0.agent?.activity == .errored }) { return .systemRed }
        if tabsWithAgents.contains(where: { $0.agent?.activity == .awaiting }) { return .systemOrange }
        if tabsWithAgents.contains(where: { $0.agent?.activity == .working }) { return .systemGreen }
        return .systemYellow
    }
}

// MARK: - Worktree header row

private struct SidebarWorktreeHeaderRow: View {
    let count: Int
    let isCollapsed: Bool
    var onToggleCollapse: () -> Void

    var body: some View {
        let c = HarnessDesign.chrome
        HStack(spacing: 6) {
            Image(systemName: isCollapsed ? "chevron.right" : "chevron.down")
                .font(.system(size: 8, weight: .regular))
                .foregroundStyle(Color(nsColor: c.textTertiary))

            Text("WORKTREES")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Color(nsColor: c.textTertiary))
                .kerning(0.5)

            Text("\(count)")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color(nsColor: c.textTertiary))

            Spacer()
        }
        .padding(.horizontal, HarnessDesign.horizontalInset + 12)
        .contentShape(Rectangle())
        .onTapGesture { onToggleCollapse() }
    }
}

// MARK: - Worktree item row

private struct SidebarWorktreeItemRow: View {
    let entry: SidebarWorktreeEntry
    var model: SidebarListModel
    var onActivate: () -> Void

    @State private var isHovered = false

    var body: some View {
        let c = HarnessDesign.chrome
        let metadata = model.gitMetadata(forPath: entry.path, branch: entry.branch)

        ZStack {
            RoundedRectangle(cornerRadius: HarnessDesign.Radius.card, style: .continuous)
                .fill(isHovered ? Color(nsColor: c.rowHoverFill) : Color.clear)

            HStack(spacing: 0) {
                Image(systemName: "arrow.triangle.branch")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color(nsColor: c.textTertiary))
                    .frame(width: 12, height: 12)
                    .padding(.leading, 8)

                VStack(alignment: .leading, spacing: 1) {
                    Text(entry.branch)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color(nsColor: c.textSecondary))
                        .lineLimit(1)
                        .truncationMode(.tail)

                    Text(HarnessDesign.shortenPath(entry.path))
                        .font(.system(size: 10))
                        .foregroundStyle(Color(nsColor: c.textSecondary).opacity(0.6))
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                .padding(.leading, 6)

                Spacer()

                HStack(spacing: 4) {
                    if let pr = metadata?.prNumber {
                        SidebarBadgeLabel(text: "#\(pr)", color: Color(nsColor: c.accent))
                    }
                    if let ahead = metadata?.aheadCount, ahead > 0 {
                        SidebarBadgeLabel(text: "+\(ahead)", color: .green)
                    }
                }
                .padding(.trailing, 6)
            }
        }
        .padding(.leading, HarnessDesign.horizontalInset + 16)
        .padding(.trailing, HarnessDesign.horizontalInset - 4)
        .padding(.vertical, 1)
        .contentShape(Rectangle())
        .onTapGesture { onActivate() }
        .onHover { isHovered = $0 }
        .help("Open \(entry.branch) in new session")
    }
}

// MARK: - Divider

private struct SidebarDividerRow: View {
    var body: some View {
        Rectangle()
            .fill(Color(nsColor: HarnessDesign.chrome.border).opacity(0.5))
            .frame(height: 1)
            .padding(.horizontal, HarnessDesign.horizontalInset)
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
