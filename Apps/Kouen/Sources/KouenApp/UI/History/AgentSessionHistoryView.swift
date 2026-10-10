import AppKit
import Combine
import KouenCore
import KouenIPC
import SwiftUI

public struct AgentSessionHistoryView: View {
    @ObservedObject var model: AgentSessionHistoryModel
    var onResume: ((AgentSessionRecord) -> Void)?
    var onHandoff: ((AgentSessionRecord, AgentKind) -> Void)?
    var onGoToTab: ((AgentSessionRecord) -> Void)?

    @FocusState private var isSearchFocused: Bool

    public init(
        model: AgentSessionHistoryModel,
        onResume: ((AgentSessionRecord) -> Void)? = nil,
        onHandoff: ((AgentSessionRecord, AgentKind) -> Void)? = nil,
        onGoToTab: ((AgentSessionRecord) -> Void)? = nil
    ) {
        self.model = model
        self.onResume = onResume
        self.onHandoff = onHandoff
        self.onGoToTab = onGoToTab
    }

    public var body: some View {
        let c = KouenDesign.chrome
        VStack(spacing: 0) {
            // Search bar on top
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 11))
                    .foregroundStyle(Color(nsColor: c.textTertiary))
                TextField("Search sessions", text: $model.searchQuery)
                    .textFieldStyle(.plain)
                    .font(.system(size: 11))
                    .focused($isSearchFocused)
                if !model.searchQuery.isEmpty {
                    Button {
                        model.searchQuery = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(Color(nsColor: c.textTertiary))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(Color(nsColor: c.surfaceElevated))
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(Color(nsColor: c.border), lineWidth: 1)
            )
            .padding(.horizontal, KouenDesign.Spacing.sm)
            .padding(.top, KouenDesign.Spacing.sm)
            .padding(.bottom, KouenDesign.Spacing.xs)

            // Scope Selector (This repo / All repos)
            Picker("", selection: $model.selectedScope) {
                ForEach(HistoryScope.allCases) { scope in
                    Text(scope.rawValue).tag(scope)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .padding(.horizontal, KouenDesign.Spacing.sm)
            .padding(.bottom, KouenDesign.Spacing.xs)

            // Agent Filter Chips (Claude / Codex / Copilot / Antigravity)
            agentChipsView
                .padding(.horizontal, KouenDesign.Spacing.sm)
                .padding(.bottom, KouenDesign.Spacing.xs)

            // Sub-header with count and refresh
            subHeaderView
                .padding(.horizontal, KouenDesign.Spacing.sm)
                .padding(.bottom, KouenDesign.Spacing.xs)

            Divider()
                .overlay(Color(nsColor: c.border))

            // Sessions List
            if model.isLoading && model.records.isEmpty {
                VStack(spacing: 8) {
                    Spacer()
                    ProgressView()
                        .controlSize(.small)
                    Text("Scanning agent transcripts...")
                        .font(.system(size: 11))
                        .foregroundStyle(Color(nsColor: c.textTertiary))
                    Spacer()
                }
            } else if model.filteredRecords.isEmpty {
                VStack(spacing: 8) {
                    Spacer()
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 24))
                        .foregroundStyle(Color(nsColor: c.textTertiary))
                    Text(model.searchQuery.isEmpty ? "No session history found" : "No sessions match \"\(model.searchQuery)\"")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color(nsColor: c.textSecondary))
                    // Cloud Agents started on the web leave no local transcript to scan (P55).
                    Text("Antigravity Cloud Agents live on antigravity.google.com")
                        .font(.system(size: 10))
                        .foregroundStyle(Color(nsColor: c.textTertiary))
                    Spacer()
                }
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 6) {
                            ForEach(model.groupedRecords, id: \.title) { group in
                                historySection(group: group)
                            }
                            if model.hasMoreToLoad {
                                Button {
                                    model.loadMore()
                                } label: {
                                    Text("Load More")
                                        .font(.system(size: 10.5, weight: .medium))
                                        .foregroundStyle(Color(nsColor: c.textSecondary))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 6)
                                        .background(Color(nsColor: c.surfaceElevated))
                                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, KouenDesign.Spacing.sm)
                        .padding(.vertical, KouenDesign.Spacing.sm)
                    }
                    .onChange(of: model.selectedIndex) { _, newIndex in
                        let list = model.displayRecords
                        if newIndex >= 0 && newIndex < list.count {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                proxy.scrollTo(list[newIndex].id, anchor: .center)
                            }
                        }
                    }
                }
            }

            // Footer bar
            Divider()
                .overlay(Color(nsColor: c.border))
            footerView
                .padding(.horizontal, KouenDesign.Spacing.sm)
                .padding(.vertical, 5)
        }
        .onAppear {
            if model.records.isEmpty {
                model.refresh(force: false)
            }
        }
        .onKeyPress(.upArrow) {
            model.moveSelection(by: -1)
            return .handled
        }
        .onKeyPress(.downArrow) {
            model.moveSelection(by: 1)
            return .handled
        }
        .onKeyPress(.return, phases: .down) { press in
            guard let selected = model.selectedRecord else { return .ignored }
            if press.modifiers.contains(.option) {
                showOptionMenu(for: selected)
                return .handled
            } else {
                triggerPrimaryAction(for: selected)
                return .handled
            }
        }
    }

    // MARK: - Agent Filter Chips
    @ViewBuilder
    private var agentChipsView: some View {
        let c = KouenDesign.chrome
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(model.availableAgentKinds, id: \.self) { kind in
                    let isSelected = model.selectedAgents.contains(kind)
                    let brandColor = Color(nsColor: NSColor.fromHex(kind.dotHex) ?? .secondaryLabelColor)
                    Button {
                        model.toggleAgentFilter(kind)
                    } label: {
                        HStack(spacing: 3.5) {
                            Image(nsImage: AgentIconRenderer.templateOrMonogramImage(for: kind, size: 9))
                                .resizable()
                                .frame(width: 9, height: 9)
                                .foregroundStyle(isSelected ? brandColor : Color(nsColor: c.textTertiary))

                            Text(kind.filterChipName)
                                .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                                .foregroundStyle(isSelected ? Color(nsColor: c.textPrimary) : Color(nsColor: c.textSecondary))
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2.5)
                        .background(
                            isSelected
                                ? brandColor.opacity(0.14)
                                : Color(nsColor: c.surfaceElevated)
                        )
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(
                                    isSelected
                                        ? brandColor.opacity(0.55)
                                        : Color(nsColor: c.border),
                                    lineWidth: 1
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }

                if !model.selectedAgents.isEmpty {
                    Button {
                        model.selectedAgents.removeAll()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(Color(nsColor: c.textTertiary))
                    }
                    .buttonStyle(.plain)
                    .help("Clear AI filter")
                }
            }
            .padding(.horizontal, 1)
        }
    }

    // MARK: - Sub-header
    @ViewBuilder
    private var subHeaderView: some View {
        let c = KouenDesign.chrome
        HStack(alignment: .center) {
            Text("\(model.windowedRecords.count) shown · \(model.records.count) recent")
                .font(.system(size: 10))
                .foregroundStyle(Color(nsColor: c.textTertiary))
            Spacer()
            Button {
                model.refresh(force: true)
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color(nsColor: c.textSecondary))
            }
            .buttonStyle(.plain)
            .help("Refresh history from disk")
        }
    }

    // MARK: - Section
    @ViewBuilder
    private func historySection(group: (title: String, records: [AgentSessionRecord])) -> some View {
        let c = KouenDesign.chrome
        let isCollapsed = model.collapsedSections.contains(group.title)

        VStack(spacing: 3) {
            Button {
                withAnimation(.easeInOut(duration: 0.15)) {
                    model.toggleSectionCollapse(title: group.title)
                }
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: isCollapsed ? "chevron.right" : "chevron.down")
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundStyle(Color(nsColor: c.textTertiary))
                    Text(group.title.uppercased())
                        .font(.system(size: 9.5, weight: .bold))
                        .foregroundStyle(Color(nsColor: c.textTertiary))
                    Spacer()
                    Text("\(group.records.count)")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(Color(nsColor: c.textTertiary))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(Color(nsColor: c.surfaceElevated))
                        .clipShape(Capsule())
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.vertical, 3)

            if !isCollapsed {
                LazyVStack(spacing: 4) {
                    ForEach(group.records) { record in
                        sessionRow(record: record)
                    }
                }
            }
        }
    }

    // MARK: - Footer
    @ViewBuilder
    private var footerView: some View {
        let c = KouenDesign.chrome
        let totalCount = model.displayRecords.count
        let repoSuffix = (model.selectedScope == .all || !model.searchQuery.isEmpty) ? " · all repos" : ""
        let countText = "\(totalCount) session\(totalCount == 1 ? "" : "s")\(repoSuffix)"

        HStack {
            Text(countText)
                .font(.system(size: 10))
                .foregroundStyle(Color(nsColor: c.textTertiary))
            Spacer()
            Text("↑↓ · ⏎ resume · ⌥⏎ menu")
                .font(.system(size: 9.5))
                .foregroundStyle(Color(nsColor: c.textTertiary))
        }
    }

    // MARK: - Compact Row (Two-line & Cross-Repo Grouping)
    @ViewBuilder
    private func sessionRow(record: AgentSessionRecord) -> some View {
        let c = KouenDesign.chrome
        let isSelected = model.selectedRecordID == record.id
        let isLive = record.liveStatus != nil || record.placement == .cloud || record.placement == .background || record.placement == .remoteControl
        let showRepo = model.selectedScope == .all || !model.searchQuery.isEmpty
        let isNotMainBranch = record.gitBranch != nil && !record.gitBranch!.isEmpty && record.gitBranch != "main" && record.gitBranch != "master"
        let siblings = record.crossRepoSiblings ?? []
        let isCrossRepoGroup = siblings.count > 1

        VStack(alignment: .leading, spacing: 3) {
            Button {
                if let idx = model.displayRecords.firstIndex(where: { $0.id == record.id }) {
                    model.selectedIndex = idx
                }
            } label: {
                VStack(alignment: .leading, spacing: 3) {
                    // Line 1: Title
                    highlightedText(
                        record.title.isEmpty ? "Untitled Session" : record.title,
                        query: model.searchQuery,
                        baseColor: isSelected ? c.textPrimary : c.textSecondary,
                        highlightColor: NSColor.controlAccentColor,
                        fontSize: 11,
                        weight: isSelected ? .semibold : .medium
                    )
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    if !isCrossRepoGroup, let breadcrumbs = record.topicBreadcrumbs {
                        HStack(spacing: 3) {
                            Image(systemName: "signpost.right.and.left")
                                .font(.system(size: 8))
                                .foregroundStyle(Color(nsColor: c.textTertiary))
                            highlightedText(
                                breadcrumbs,
                                query: model.searchQuery,
                                baseColor: c.textTertiary,
                                highlightColor: NSColor.controlAccentColor,
                                fontSize: 8.5,
                                weight: .regular
                            )
                            .lineLimit(1)
                        }
                        .padding(.top, 0.5)
                    }

                    if isCrossRepoGroup {
                        // Line 2 for Cross-Repo group: age · ⇄ same task in N repos
                        HStack(spacing: 4) {
                            Text(relativeDate(record.updatedAt))
                                .font(.system(size: 9))
                                .foregroundStyle(Color(nsColor: c.textTertiary))

                            Text("·")
                                .font(.system(size: 8))
                                .foregroundStyle(Color(nsColor: c.textTertiary))

                            HStack(spacing: 2) {
                                Text("⇄")
                                    .font(.system(size: 9, weight: .bold))
                                Text("same task in \(siblings.count) repos")
                                    .font(.system(size: 9, weight: .semibold))
                            }
                            .foregroundStyle(Color(nsColor: c.success))

                            Spacer(minLength: 0)
                        }

                        // Sub-lines for each repo participating in the task
                        VStack(alignment: .leading, spacing: 2) {
                            ForEach(siblings) { sib in
                                HStack(spacing: 4) {
                                    AgentBadgeView(kind: sib.agentKind, iconSize: 9, fontSize: 8, showName: false)

                                    if let tag = sib.surfaceTag {
                                        Text(tag)
                                            .font(.system(size: 7.5, weight: .semibold))
                                            .padding(.horizontal, 2.5)
                                            .padding(.vertical, 0.5)
                                            .background(Color(nsColor: c.surfaceElevated))
                                            .cornerRadius(2.5)
                                            .foregroundStyle(Color(nsColor: c.textSecondary))
                                    }

                                    highlightedText(
                                        sib.projectName,
                                        query: model.searchQuery,
                                        baseColor: c.textPrimary,
                                        highlightColor: NSColor.controlAccentColor,
                                        fontSize: 9.5,
                                        weight: .semibold
                                    )

                                    if let branch = sib.gitBranch {
                                        HStack(spacing: 2) {
                                            Image(systemName: "arrow.triangle.branch")
                                                .font(.system(size: 7.5))
                                            highlightedText(
                                                branch,
                                                query: model.searchQuery,
                                                baseColor: c.textTertiary,
                                                highlightColor: NSColor.controlAccentColor,
                                                fontSize: 9,
                                                weight: .regular
                                            )
                                        }
                                    }
                                    Spacer(minLength: 0)
                                }
                                .padding(.leading, 6)
                                .overlay(
                                    Rectangle()
                                        .fill(Color(nsColor: c.border))
                                        .frame(width: 2),
                                    alignment: .leading
                                )
                            }
                        }
                        .padding(.top, 1)

                    } else {
                        // Line 2 for Standalone session: Metadata (agent · live · msgs · age · repo · branch)
                        HStack(spacing: 4) {
                            AgentBadgeView(kind: record.agentKind, iconSize: 10, fontSize: 8.5, showName: false)

                            if let tag = record.surfaceTag {
                                Text(tag)
                                    .font(.system(size: 8, weight: .semibold))
                                    .padding(.horizontal, 3)
                                    .padding(.vertical, 1)
                                    .background(Color(nsColor: c.surfaceElevated))
                                    .cornerRadius(3)
                                    .foregroundStyle(Color(nsColor: c.textSecondary))
                            }

                            if isLive {
                                HStack(spacing: 2) {
                                    Circle()
                                        .fill(Color(nsColor: c.success))
                                        .frame(width: 5, height: 5)
                                    Text("live")
                                        .font(.system(size: 9, weight: .medium))
                                        .foregroundStyle(Color(nsColor: c.success))
                                }
                                Text("·")
                                    .font(.system(size: 8))
                                    .foregroundStyle(Color(nsColor: c.textTertiary))
                            }

                            Text("\(record.messageCount) msgs")
                                .font(.system(size: 9))
                                .foregroundStyle(Color(nsColor: c.textTertiary))

                            Text("·")
                                .font(.system(size: 8))
                                .foregroundStyle(Color(nsColor: c.textTertiary))

                            Text(relativeDate(record.updatedAt))
                                .font(.system(size: 9))
                                .foregroundStyle(Color(nsColor: c.textTertiary))

                            if showRepo && !record.projectName.isEmpty {
                                Text("·")
                                    .font(.system(size: 8))
                                    .foregroundStyle(Color(nsColor: c.textTertiary))
                                highlightedText(
                                    record.projectName,
                                    query: model.searchQuery,
                                    baseColor: c.textSecondary,
                                    highlightColor: NSColor.controlAccentColor,
                                    fontSize: 9,
                                    weight: .regular
                                )
                                .lineLimit(1)
                            }

                            if isNotMainBranch, let branch = record.gitBranch {
                                Text("·")
                                    .font(.system(size: 8))
                                    .foregroundStyle(Color(nsColor: c.textTertiary))
                                HStack(spacing: 2) {
                                    Image(systemName: "arrow.triangle.branch")
                                        .font(.system(size: 7.5))
                                    highlightedText(
                                        branch,
                                        query: model.searchQuery,
                                        baseColor: c.textTertiary,
                                        highlightColor: NSColor.controlAccentColor,
                                        fontSize: 9,
                                        weight: .regular
                                    )
                                    .lineLimit(1)
                                }
                                .foregroundStyle(Color(nsColor: c.textTertiary))
                            }

                            if model.isSemanticMatch(for: record) {
                                Text("·")
                                    .font(.system(size: 8))
                                    .foregroundStyle(Color(nsColor: c.textTertiary))
                                Text("Semantic")
                                    .font(.system(size: 7.5, weight: .semibold))
                                    .padding(.horizontal, 3.5)
                                    .padding(.vertical, 0.5)
                                    .background(Color.purple.opacity(0.18))
                                    .foregroundStyle(Color.purple)
                                    .clipShape(RoundedRectangle(cornerRadius: 2.5))
                            }

                            if !model.searchQuery.isEmpty, let loc = model.matchLocation(for: record) {
                                Text("·")
                                    .font(.system(size: 8))
                                    .foregroundStyle(Color(nsColor: c.textTertiary))
                                Text(loc.description)
                                    .font(.system(size: 8.5, weight: .medium))
                                    .foregroundStyle(Color.accentColor)
                                    .lineLimit(1)
                            }

                            Spacer(minLength: 0)
                        }

                        // Content snippet if matching query
                        if let snippet = model.matchSnippet(for: record) {
                            HStack(alignment: .top, spacing: 4) {
                                Image(systemName: "text.magnifyingglass")
                                    .font(.system(size: 8))
                                    .foregroundStyle(Color.accentColor)
                                highlightedText(
                                    snippet,
                                    query: model.searchQuery,
                                    baseColor: c.textSecondary,
                                    highlightColor: NSColor.controlAccentColor,
                                    fontSize: 9,
                                    weight: .regular
                                )
                                .lineLimit(1)
                            }
                            .padding(.top, 1)
                        }
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            // Selected Row Details & Actions
            if isSelected {
                if isCrossRepoGroup {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(siblings) { sib in
                            let sibIsLive = sib.liveStatus != nil || sib.placement == .cloud || sib.placement == .background || sib.placement == .remoteControl
                            VStack(alignment: .leading, spacing: 3) {
                                HStack(spacing: 4) {
                                    AgentBadgeView(kind: sib.agentKind, iconSize: 9, fontSize: 8, showName: false)
                                    Text(sib.projectName)
                                        .font(.system(size: 9.5, weight: .bold))
                                        .foregroundStyle(Color(nsColor: c.textPrimary))
                                    Text("·")
                                        .font(.system(size: 8))
                                        .foregroundStyle(Color(nsColor: c.textTertiary))
                                    Text(relativeDate(sib.updatedAt))
                                        .font(.system(size: 8.5))
                                        .foregroundStyle(Color(nsColor: c.textTertiary))
                                    Spacer()
                                }
                                if let snippet = latestTurnSnippet(for: sib) {
                                    highlightedText(
                                        snippet,
                                        query: model.searchQuery,
                                        baseColor: c.textSecondary,
                                        highlightColor: NSColor.controlAccentColor,
                                        fontSize: 9.5,
                                        weight: .regular
                                    )
                                    .lineLimit(2)
                                }
                                HStack(spacing: 0) {
                                    Spacer()
                                    splitActionButton(for: sib, isLive: sibIsLive)
                                }
                            }
                            .padding(.vertical, 2)

                            if sib.id != siblings.last?.id {
                                Divider().overlay(Color(nsColor: c.border).opacity(0.4))
                            }
                        }
                    }
                    .padding(.top, 4)
                } else {
                    VStack(alignment: .leading, spacing: 4) {
                        if let snippet = latestTurnSnippet(for: record) {
                            highlightedText(
                                snippet,
                                query: model.searchQuery,
                                baseColor: c.textPrimary,
                                highlightColor: NSColor.controlAccentColor,
                                fontSize: 10,
                                weight: .regular
                            )
                            .lineLimit(3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 1)
                        }
                        HStack(spacing: 0) {
                            Spacer()
                            splitActionButton(for: record, isLive: isLive)
                        }
                    }
                    .padding(.top, 2)
                }
            }
        }
        .id(record.id)
        .padding(.horizontal, 7)
        .padding(.vertical, 5)
        .background(isSelected ? Color.accentColor.opacity(0.12) : Color(nsColor: c.surfaceElevated))
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(isSelected ? Color.accentColor.opacity(0.4) : Color(nsColor: c.border), lineWidth: 1)
        )
        .contextMenu {
            sessionContextMenuItems(for: record)
        }
    }

    // MARK: - Split Action Button
    @ViewBuilder
    private func splitActionButton(for record: AgentSessionRecord, isLive: Bool) -> some View {
        let mainTitle = isLive ? "Go to tab" : "Resume"
        let mainIcon = isLive ? "arrow.right.circle.fill" : "play.fill"

        HStack(spacing: 0) {
            // Main button
            Button {
                triggerPrimaryAction(for: record)
            } label: {
                HStack(spacing: 3) {
                    Image(systemName: mainIcon)
                        .font(.system(size: 8.5))
                    Text(mainTitle)
                        .font(.system(size: 9.5, weight: .semibold))
                }
                .padding(.horizontal, 7)
                .padding(.vertical, 3.5)
                .background(Color.accentColor)
                .foregroundStyle(Color.white)
            }
            .buttonStyle(.plain)

            Divider()
                .frame(height: 12)
                .overlay(Color.white.opacity(0.3))

            // Caret dropdown menu
            Menu {
                sessionContextMenuItems(for: record)
            } label: {
                Image(systemName: "chevron.down")
                    .font(.system(size: 7.5, weight: .bold))
                    .padding(.horizontal, 5)
                    .padding(.vertical, 3.5)
                    .background(Color.accentColor)
                    .foregroundStyle(Color.white)
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
        }
        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
    }

    @ViewBuilder
    private func sessionContextMenuItems(for record: AgentSessionRecord) -> some View {
        let isLive = record.liveStatus != nil || record.placement == .cloud || record.placement == .background || record.placement == .remoteControl
        let mainTitle = isLive ? "Go to tab" : "Resume"
        let mainIcon = isLive ? "arrow.right.circle.fill" : "play.fill"
        let candidates = AgentLaunchCommands.configs.keys
            .filter { $0 != .cursor && $0 != record.agentKind }
            .sorted { $0.displayName < $1.displayName }

        Button {
            triggerPrimaryAction(for: record)
        } label: {
            Label(mainTitle, systemImage: mainIcon)
        }

        if isLive {
            Button {
                onResume?(record)
            } label: {
                Label("Resume in new tab", systemImage: "play.fill")
            }
        }

        if !candidates.isEmpty {
            Divider()
            ForEach(candidates, id: \.self) { target in
                Button {
                    onHandoff?(record, target)
                } label: {
                    Text("Hand off to \(target.displayName)")
                }
            }
        }

        Divider()

        if let loc = model.matchLocation(for: record), let turn = loc.turnIndex {
            Button {
                copyResumeCommand(record, turnIndex: turn)
            } label: {
                Label("Copy command for turn #\(turn + 1) (\(loc.relativePosition))", systemImage: "arrow.turn.down.right")
            }
        }

        Button {
            copyResumeCommand(record)
        } label: {
            Label("Copy resume command", systemImage: "doc.on.doc")
        }

        Button {
            copyToPasteboard(record.id)
        } label: {
            Label("Copy session ID", systemImage: "number")
        }
    }

    private func showOptionMenu(for record: AgentSessionRecord) {
        let menu = NSMenu(title: "Session Options")
        let isLive = record.liveStatus != nil || record.placement == .cloud || record.placement == .background || record.placement == .remoteControl
        let mainTitle = isLive ? "Go to tab" : "Resume"
        let mainIcon = isLive ? "arrow.right.circle.fill" : "play.fill"
        let candidates = AgentLaunchCommands.configs.keys
            .filter { $0 != .cursor && $0 != record.agentKind }
            .sorted { $0.displayName < $1.displayName }

        menu.addItem(makeMenuItem(title: mainTitle, systemImage: mainIcon) { [self] in
            self.triggerPrimaryAction(for: record)
        })

        if isLive {
            menu.addItem(makeMenuItem(title: "Resume in new tab", systemImage: "play.fill") { [self] in
                self.onResume?(record)
            })
        }

        if !candidates.isEmpty {
            menu.addItem(NSMenuItem.separator())
            for target in candidates {
                menu.addItem(makeMenuItem(title: "Hand off to \(target.displayName)") { [self] in
                    self.onHandoff?(record, target)
                })
            }
        }

        menu.addItem(NSMenuItem.separator())
        if let loc = model.matchLocation(for: record), let turn = loc.turnIndex {
            menu.addItem(makeMenuItem(title: "Copy command for turn #\(turn + 1) (\(loc.relativePosition))", systemImage: "arrow.turn.down.right") { [self] in
                self.copyResumeCommand(record, turnIndex: turn)
            })
        }
        menu.addItem(makeMenuItem(title: "Copy resume command", systemImage: "doc.on.doc") { [self] in
            self.copyResumeCommand(record)
        })
        // Antigravity 2.0 / summary-only rows have no CLI resume; the ID is what the app needs.
        menu.addItem(makeMenuItem(title: "Copy session ID", systemImage: "number") { [self] in
            self.copyToPasteboard(record.id)
        })

        menu.popUp(positioning: nil, at: NSEvent.mouseLocation, in: nil)
    }

    private func makeMenuItem(title: String, systemImage: String? = nil, action: @escaping () -> Void) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: #selector(HistoryMenuProxy.menuAction(_:)), keyEquivalent: "")
        let proxy = HistoryMenuProxy(action: action)
        item.target = proxy
        item.representedObject = proxy
        if let systemImage, let img = NSImage(systemSymbolName: systemImage, accessibilityDescription: nil) {
            item.image = img
        }
        return item
    }

    private func latestTurnSnippet(for record: AgentSessionRecord) -> String? {
        if let lastTurn = record.latestTurns.last?.content.trimmingCharacters(in: .whitespacesAndNewlines), !lastTurn.isEmpty {
            return lastTurn
        }
        let prompt = record.firstPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        return prompt.isEmpty ? nil : prompt
    }

    private func highlightedText(
        _ text: String,
        query: String,
        baseColor: NSColor,
        highlightColor: NSColor = .controlAccentColor,
        fontSize: CGFloat = 11,
        weight: NSFont.Weight = .regular
    ) -> Text {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return Text(text)
        }
        let tokens = trimmed.lowercased()
            .split(whereSeparator: \.isWhitespace)
            .map(String.init)
            .filter { $0.count >= 2 }
        guard !tokens.isEmpty else {
            return Text(text)
        }

        let baseFont = NSFont.systemFont(ofSize: fontSize, weight: weight)
        let boldFont = NSFont.systemFont(ofSize: fontSize, weight: .bold)

        let mas = NSMutableAttributedString(string: text, attributes: [
            .font: baseFont,
            .foregroundColor: baseColor
        ])

        let lower = text.lowercased()
        for token in tokens {
            var searchStart = lower.startIndex
            while searchStart < lower.endIndex,
                  let range = lower.range(of: token, range: searchStart..<lower.endIndex) {
                let nsRange = NSRange(range, in: text)
                mas.addAttributes([
                    .foregroundColor: highlightColor,
                    .font: boldFont
                ], range: nsRange)
                searchStart = range.upperBound
            }
        }

        return Text(AttributedString(mas))
    }

    private func triggerPrimaryAction(for record: AgentSessionRecord) {
        let isLive = record.liveStatus != nil || record.placement == .cloud || record.placement == .background || record.placement == .remoteControl
        if isLive, let onGoToTab {
            onGoToTab(record)
        } else {
            onResume?(record)
        }
    }

    private func copyResumeCommand(_ record: AgentSessionRecord, turnIndex: Int? = nil) {
        let settings = KouenSettings.load()
        let mode = settings.sessionMode(for: record.agentKind)
        let baseCmd = record.effectiveResumeCommand(mode: mode)
        let cmd: String
        if let turnIndex {
            cmd = "\(baseCmd) # turn \(turnIndex + 1)"
        } else {
            cmd = baseCmd
        }
        copyToPasteboard(cmd)
    }

    private func copyToPasteboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }

    private func relativeDate(_ date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 60 {
            return "just now"
        } else if interval < 3600 {
            let mins = max(1, Int(interval / 60))
            return "\(mins)m ago"
        } else if interval < 86400 {
            let hours = max(1, Int(interval / 3600))
            return "\(hours)h ago"
        } else {
            let days = max(1, Int(interval / 86400))
            return "\(days)d ago"
        }
    }
}

@MainActor
private final class HistoryMenuProxy: NSObject {
    let action: () -> Void
    init(action: @escaping () -> Void) {
        self.action = action
    }
    @objc func menuAction(_ sender: Any?) {
        action()
    }
}

private extension AgentKind {
    var filterChipName: String {
        switch self {
        case .claudeCode: return "Claude"
        case .copilot: return "Copilot"
        case .codex: return "Codex"
        case .antigravity: return "Antigravity"
        default: return displayName
        }
    }
}

