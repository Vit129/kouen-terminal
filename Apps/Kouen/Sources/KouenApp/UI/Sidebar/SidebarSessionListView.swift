import SwiftUI
import KouenCommands
import KouenCore
import KouenIPC

// MARK: - Main container

struct SidebarSessionListView: View {
    var model: SidebarListModel
    var fleetModel: FleetViewModel? = nil
    var onSelect: (SessionID) -> Void
    var onSelectFleetItem: ((FleetSessionItem) -> Void)? = nil
    var onOpenProject: (String) -> Void
    var onAddInGroup: (ProjectAddAction, ProjectAddScope) -> Void
    var onReviewGroupMoves: (String) -> Void = { _ in }
    var onCloseSession: (SessionID) -> Void
    var onRemoveProject: (String) -> Void
    var onPRClick: (String) -> Void
    var onWorktreeActivate: (SidebarWorktreeEntry, WorkspaceID?) -> Void

    @State private var selectedFilter: ProjectTabFilter = .all
    @State private var projectSearchQuery = ""
    @State private var handledProjectRevealID: UUID?
    @State private var lastScrolledProject: ProjectScrollRequest?

    private struct ProjectScrollRequest: Equatable {
        let explicitRevealID: UUID?
        let activeSessionID: SessionID?
        let activeProjectPath: String?
        let activeProjectIsListed: Bool
        let explicitProjectIsListed: Bool
    }

    private var projectScrollRequest: ProjectScrollRequest? {
        guard projectSearchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        let reveal = model.projectReveal
        let pendingReveal = reveal?.id == handledProjectRevealID ? nil : reveal
        guard pendingReveal != nil || model.isSidebarVisible else { return nil }
        let path = model.activeProjectPath
        func isListed(_ path: String?) -> Bool {
            guard let path else { return false }
            return model.rows.contains {
                guard case let .projectHeader(item) = $0 else { return false }
                return item.path == path
            }
        }
        return ProjectScrollRequest(
            explicitRevealID: reveal?.id,
            activeSessionID: model.activeSessionID,
            activeProjectPath: model.activeProjectPath,
            activeProjectIsListed: isListed(path),
            explicitProjectIsListed: isListed(reveal?.path)
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            filterChipsHeader
            Divider()
                .overlay(Color.primary.opacity(0.06))

            if selectedFilter == .all {
                if !projectSearchQuery.isEmpty && filteredProjectRows.isEmpty {
                    VStack {
                        Spacer()
                        Text("No projects or branches found")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    let scrollRequest = projectScrollRequest
                    ScrollViewReader { proxy in
                        ScrollView(.vertical, showsIndicators: false) {
                            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                                let rows = filteredProjectRows
                                let boundaries = rows.indices.filter { index in
                                    switch rows[index] {
                                    case .groupHeader, .divider: true
                                    default: index == rows.startIndex
                                    }
                                }
                                ForEach(boundaries.indices, id: \.self) { sectionIndex in
                                    let start = boundaries[sectionIndex]
                                    let next = sectionIndex + 1
                                    let end = next < boundaries.endIndex ? boundaries[next] : rows.endIndex
                                    if case .groupHeader = rows[start] {
                                        Section {
                                            ForEach(rows[(start + 1)..<end]) { row in
                                                rowContent(row)
                                            }
                                        } header: {
                                            rowContent(rows[start])
                                                .background(Color(nsColor: KouenDesign.chrome.sidebarBackground))
                                        }
                                        .id(rows[start].id)
                                    } else {
                                        ForEach(rows[start..<end]) { row in
                                            rowContent(row)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .onDisappear { lastScrolledProject = nil }
                        .task(id: scrollRequest) {
                            guard !Task.isCancelled else { return }
                            guard let request = scrollRequest else {
                                lastScrolledProject = nil
                                return
                            }
                            if let reveal = model.projectReveal, reveal.id != handledProjectRevealID {
                                guard request.explicitProjectIsListed else { return }
                                proxy.scrollTo("proj-\(reveal.path)", anchor: .center)
                                handledProjectRevealID = reveal.id
                            } else {
                                guard let path = request.activeProjectPath else {
                                    lastScrolledProject = nil
                                    return
                                }
                                guard lastScrolledProject?.activeProjectPath != path
                                    || lastScrolledProject?.activeSessionID != request.activeSessionID else { return }
                                if request.activeProjectIsListed {
                                    lastScrolledProject = request
                                    proxy.scrollTo("proj-\(path)")
                                } else {
                                    model.expandActiveProjectGroup()
                                }
                            }
                        }
                    }
                }
            } else if let fleetModel {
                let items = fleetModel.itemsFor(filter: selectedFilter)
                if items.isEmpty {
                    VStack(spacing: 6) {
                        Spacer()
                        Text(selectedFilter == .agents ? "No active agents" : "No waiting sessions")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(items) { item in
                                Button {
                                    onSelectFleetItem?(item)
                                } label: {
                                    FleetRowView(item: item)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .task(id: model.isSidebarVisible && selectedFilter == .all) {
            guard model.isSidebarVisible, selectedFilter == .all, let store = model.projectStore else { return }
            while !Task.isCancelled {
                do {
                    try await Task.sleep(for: .seconds(3))
                } catch {
                    return
                }
                guard !Task.isCancelled else { return }
                await store.refreshProjectAvailability()
            }
        }
        .onChange(of: model.projectStore?.missingProjectPaths) { _, _ in model.scheduleRebuild() }
        .onChange(of: model.projectStore?.pendingReconciliationPaths) { _, _ in model.scheduleRebuild() }
        .onChange(of: model.projectStore?.projects) { _, _ in model.scheduleRebuild() }
        .onAppear {
            model.setProjectSearchActive(selectedFilter == .all && !projectSearchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .onDisappear { model.setProjectSearchActive(false) }
        .onChange(of: model.projectReveal?.id) { _, _ in
            selectedFilter = .all
            projectSearchQuery = ""
        }
        .onChange(of: projectSearchQuery) { _, query in
            model.setProjectSearchActive(selectedFilter == .all && !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .onChange(of: selectedFilter) { _, filter in
            model.setProjectSearchActive(filter == .all && !projectSearchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    private var filterChipsHeader: some View {
        VStack(spacing: 4) {
            if selectedFilter == .all {
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                    TextField("Find a project or branch", text: $projectSearchQuery)
                        .textFieldStyle(.plain)
                        .font(.system(size: 11))
                        .accessibilityIdentifier("field_projectSearch_projectsSidebar")
                    if !projectSearchQuery.isEmpty {
                        Button {
                            projectSearchQuery = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 7)
                .frame(height: 24)
                .background(Color.primary.opacity(0.06), in: RoundedRectangle(cornerRadius: 6))
                .padding(.horizontal, KouenDesign.horizontalInset)
            }

            HStack(spacing: 4) {
                ForEach(ProjectTabFilter.allCases) { filter in
                    Button {
                        selectedFilter = filter
                    } label: {
                        HStack(spacing: 3) {
                            Text(filter.rawValue)
                                .font(.system(size: 10.5, weight: selectedFilter == filter ? .semibold : .regular))
                            if filter == .waiting, let count = fleetModel?.waitingCount, count > 0 {
                                Text("\(count)")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 1)
                                    .background(Capsule().fill(Color.orange))
                            }
                        }
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2.5)
                        .background(
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .fill(selectedFilter == filter
                                      ? Color.primary.opacity(0.10)
                                      : Color.clear)
                        )
                        .foregroundStyle(selectedFilter == filter ? Color.primary : Color.secondary)
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            .padding(.horizontal, KouenDesign.horizontalInset)
        }
        .padding(.vertical, 5)
    }

    private var filteredProjectRows: [SidebarSessionRow] {
        let query = projectSearchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return model.rows }

        var result: [SidebarSessionRow] = []
        var currentGroup: SidebarSessionRow?
        var groupWasAdded = false
        var index = 0

        while index < model.rows.count {
            let row = model.rows[index]
            switch row {
            case .groupHeader(_, _, _, _, _, _):
                currentGroup = row
                groupWasAdded = false
                index += 1
            case .divider:
                if let last = result.last, case .divider = last { }
                else if !result.isEmpty { result.append(row) }
                currentGroup = nil
                groupWasAdded = false
                index += 1
            case let .projectHeader(item):
                var end = index + 1
                while end < model.rows.count {
                    switch model.rows[end] {
                    case .projectHeader(_), .groupHeader(_, _, _, _, _, _), .divider: break
                    default: end += 1; continue
                    }
                    break
                }
                let block = Array(model.rows[index..<end])
                let projectMatches = contains(item.name, query) || contains(item.path, query)
                let childMatches = block.dropFirst().contains { row in
                    switch row {
                    case let .sessionItem(card):
                        return contains(card.title, query) || contains(card.branch, query)
                            || contains(card.subtitle ?? "", query) || contains(card.worktreePath ?? "", query)
                    case let .worktreeDisclosure(path, _, _):
                        return contains(path, query)
                    default:
                        return false
                    }
                }
                if projectMatches || childMatches {
                    if let currentGroup, !groupWasAdded {
                        result.append(currentGroup)
                        groupWasAdded = true
                    }
                    result.append(contentsOf: block)
                }
                index = end
            default:
                index += 1
            }
        }
        return result
    }

    private func contains(_ value: String, _ query: String) -> Bool {
        value.localizedCaseInsensitiveContains(query)
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
                onAdd: { onAddInGroup($0, .group(name: name, id: id)) },
                onReviewMoves: { onReviewGroupMoves(id) }
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

        case let .worktreeDisclosure(path, count, isExpanded):
            Button {
                model.toggleWorktreeCollapse(rootPath: path)
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 8, weight: .semibold))
                    Text(count == 1 ? "1 discovered worktree" : "\(count) discovered worktrees")
                        .font(.system(size: 11))
                        .lineLimit(1)
                    Spacer(minLength: 0)
                }
                .foregroundStyle(Color(nsColor: KouenDesign.chrome.textSecondary))
                .padding(.leading, 26)
                .padding(.trailing, 8)
                .frame(height: 24)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("btn_discoveredWorktrees-\(path)_projectsSidebar")
            .accessibilityHint(isExpanded ? "Collapses discovered worktrees" : "Expands discovered worktrees")

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
    var onAdd: (ProjectAddAction) -> Void
    var onReviewMoves: () -> Void

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

            ProjectAddMenu(scope: .group(name: name, id: id), onSelect: onAdd)

            Menu {
                Button("Browse folder…") { onAdd(.browse) }
                Button("Review Moved Repositories…") { onReviewMoves() }
                    .accessibilityIdentifier("project-group-review-moves")
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
            .accessibilityLabel("Options for \(name)")
            .accessibilityIdentifier("btn_groupOptions-\(id)_projectsSidebar")
            .help("Group options")
        }
        .padding(.horizontal, KouenDesign.horizontalInset)
        .contentShape(Rectangle())
        .onTapGesture { onToggleCollapse() }
        .onHover { isHovered = $0 }
    }
}

// MARK: - Project Header row

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
            // Repository icon distinguishes the saved repo root from branch/session rows.
            Image(systemName: item.isCollapsed ? "chevron.right" : "chevron.down")
                .font(.system(size: 8.5, weight: .semibold))
                .foregroundStyle(isHovered ? Color(nsColor: c.textPrimary) : Color(nsColor: c.textTertiary))
                .frame(width: 10, height: 10)

            Image(systemName: "folder")
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(Color(nsColor: c.textSecondary))
                .accessibilityHidden(true)

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

            if item.isMissing {
                Text("missing")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.orange)
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
        .help(item.path)
        .onTapGesture { onToggleCollapse() }
        .onHover { isHovered = $0 }
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

        if item.isMissing {
            Button("Relocate…") { relocate() }
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

    private func relocate() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "Relocate"
        panel.message = "Choose the new folder for \(item.name)"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        guard model.projectStore?.relocateProject(item.path, to: url.path) == true else {
            let alert = NSAlert()
            alert.messageText = "Could not relocate repository"
            alert.informativeText = "The destination must be an untracked primary repository, and the original path must still be missing."
            alert.runModal()
            return
        }
        model.scheduleRebuild()
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

    private func activityDot(_ color: Color, label: String) -> some View {
        Circle()
            .fill(color)
            .frame(width: 6, height: 6)
            .accessibilityLabel(label)
            .help(label)
    }

    var body: some View {
        let c = KouenDesign.chrome
        let isSelected = card.isSelected

        let selectedFill = Color(nsColor: c.accent).opacity(c.isDark ? 0.24 : 0.18)
        let selectedBorder = Color(nsColor: c.accent).opacity(0.85)
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
                Group {
                    switch card.status {
                    case .running:
                        activityDot(.blue, label: "Agent working")
                    case .done:
                        activityDot(.green, label: "Agent finished")
                    case .waiting:
                        activityDot(.yellow, label: "Agent waiting for input")
                    case .error:
                        activityDot(.red, label: "Agent errored")
                    case .idle:
                        Image(systemName: card.worktreePath == nil ? "house" : "arrow.triangle.branch")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color(nsColor: card.isRunning ? c.textSecondary : c.textTertiary))
                            .accessibilityLabel(card.worktreePath == nil ? "Idle" : "Discovered worktree")
                    }
                }
                .frame(width: 12, height: 12)
                .padding(.leading, 8)

                // Title + Subtitle
                VStack(alignment: .leading, spacing: 1) {
                    Text(card.title)
                        .font(.system(size: 12, weight: isSelected ? .semibold : .medium))
                        .foregroundStyle(isSelected
                            ? Color(nsColor: c.textPrimary)
                            : Color(nsColor: card.isPrimaryCheckout && !card.isRunning
                                ? c.textTertiary : (isHovered ? c.textPrimary : c.textSecondary)))
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

                if let lastActivityAt = card.lastActivityAt {
                    Text(AgentListFormatter.age(from: lastActivityAt))
                        .font(.system(size: 9.5, design: .monospaced))
                        .foregroundStyle(Color(nsColor: c.textTertiary))
                        .padding(.trailing, 6)
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
        .accessibilityAddTraits(isSelected ? .isSelected : [])
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
