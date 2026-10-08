import AppKit
import KouenCore
import KouenIPC
import SwiftUI

public enum HistoryScope: String, CaseIterable, Identifiable {
    case repo = "This repo"
    case all = "All repos"

    public var id: String { rawValue }
}

public enum AgentHistoryDateGroup: String, CaseIterable, Comparable {
    case today = "Today"
    case yesterday = "Yesterday"
    case thisWeek = "This week"
    case older = "Older"

    private var sortOrder: Int {
        switch self {
        case .today: return 0
        case .yesterday: return 1
        case .thisWeek: return 2
        case .older: return 3
        }
    }

    public static func < (lhs: AgentHistoryDateGroup, rhs: AgentHistoryDateGroup) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }

    public static func group(for date: Date, relativeTo now: Date = Date(), calendar: Calendar = .current) -> AgentHistoryDateGroup {
        let startOfTarget = calendar.startOfDay(for: date)
        let startOfNow = calendar.startOfDay(for: now)
        let dayDiff = calendar.dateComponents([.day], from: startOfTarget, to: startOfNow).day ?? 0

        if dayDiff <= 0 {
            return .today
        } else if dayDiff == 1 {
            return .yesterday
        } else if dayDiff < 7 {
            return .thisWeek
        } else {
            return .older
        }
    }
}

@MainActor
public final class AgentSessionHistoryModel: ObservableObject {
    @Published public var records: [AgentSessionRecord] = []
    @Published public var searchQuery: String = "" {
        didSet {
            extraRecordsShown = 0
            if selectedIndex >= displayRecords.count {
                selectedIndex = max(0, displayRecords.count - 1)
            }
        }
    }
    @Published public var selectedScope: HistoryScope = .repo {
        didSet {
            extraRecordsShown = 0
            if selectedIndex >= displayRecords.count {
                selectedIndex = max(0, displayRecords.count - 1)
            }
            refresh(force: false)
        }
    }
    @Published public var selectedIndex: Int = 0
    @Published public var expandedSessionIDs: Set<String> = []
    @Published public var collapsedSections: Set<String> = []
    @Published public var isLoading: Bool = false

    /// How many records beyond the default 14-day window are currently revealed via "Load More".
    @Published public var extraRecordsShown: Int = 0

    private let loadMoreBatchSize = 20
    private var minimumWindowStart: Date {
        Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? .distantPast
    }

    public init() {}

    public func refresh(force: Bool = true) {
        isLoading = true
        Task { [weak self] in
            let scanned = await AgentHistoryScanner.shared.getOrScan(force: force)
            await MainActor.run {
                self?.records = scanned
                self?.isLoading = false
            }
        }
    }

    public func toggleExpanded(sessionID: String) {
        if expandedSessionIDs.contains(sessionID) {
            expandedSessionIDs.remove(sessionID)
        } else {
            expandedSessionIDs.insert(sessionID)
        }
    }

    public func toggleSectionCollapse(title: String) {
        if collapsedSections.contains(title) {
            collapsedSections.remove(title)
        } else {
            collapsedSections.insert(title)
        }
    }

    public func moveSelection(by delta: Int) {
        let total = displayRecords.count
        guard total > 0 else {
            selectedIndex = 0
            return
        }
        let next = selectedIndex + delta
        selectedIndex = max(0, min(total - 1, next))
    }

    public var filteredRecords: [AgentSessionRecord] {
        let matcher = SearchMatcher(query: searchQuery)

        // When a search query is active, ignore scope entirely and search all repos using ranked loose search
        if matcher.hasQuery {
            let ftsMatches = AgentHistoryFTSIndex.shared.search(query: searchQuery)
            var scored: [(record: AgentSessionRecord, score: Double)] = []

            for record in records {
                let turnsContent = record.latestTurns.map(\.content).joined(separator: "\n")
                let ftsMatch = ftsMatches[record.id]

                // Combine latest turns with full transcript if indexed by FTS
                let fullText = ftsMatch?.fullTranscript ?? ""
                let chatContent = fullText.isEmpty ? "\(record.firstPrompt)\n\(turnsContent)" : "\(record.firstPrompt)\n\(turnsContent)\n\(fullText)"

                var branchFilesTools = record.gitBranch ?? ""
                if let files = ftsMatch?.filesEdited, !files.isEmpty {
                    branchFilesTools += " " + files
                }
                if let tools = ftsMatch?.toolsCalled, !tools.isEmpty {
                    branchFilesTools += " " + tools
                }

                let repoAgent = "\(record.projectName) \(record.agentKind.displayName)"

                if let match = matcher.matchHistory(
                    title: record.title,
                    branchFilesTools: branchFilesTools,
                    repoAgent: repoAgent,
                    chatContent: chatContent
                ) {
                    scored.append((record: record, score: match.score))
                }
            }
            // Sort primarily by score descending, then by updatedAt descending (recency)
            scored.sort { lhs, rhs in
                if abs(lhs.score - rhs.score) > 0.001 {
                    return lhs.score > rhs.score
                }
                return lhs.record.updatedAt > rhs.record.updatedAt
            }
            return scored.map(\.record)
        }

        // When search query is empty, apply the selected scope
        let activeCWD = SessionCoordinator.shared.snapshot.activeWorkspace?.activeTab?.cwd ?? ""
        let activeRepoRoot = WorktreeManager().repoRoot(for: activeCWD) ?? activeCWD

        return records.filter { record in
            switch selectedScope {
            case .repo:
                guard !activeRepoRoot.isEmpty else { return true }
                let recordRepoRoot = WorktreeManager().repoRoot(for: record.projectPath) ?? record.projectPath
                if recordRepoRoot == activeRepoRoot {
                    return true
                }
                if record.projectPath.hasPrefix(activeRepoRoot) || activeRepoRoot.hasPrefix(record.projectPath) {
                    return true
                }
                return false
            case .all:
                return true
            }
        }
    }

    /// Extracts matching snippet in prompt or turns for content search display
    public func matchSnippet(for record: AgentSessionRecord) -> String? {
        let matcher = SearchMatcher(query: searchQuery)
        guard matcher.hasQuery else { return nil }
        let turnsContent = record.latestTurns.map(\.content).joined(separator: "\n")
        let chatContent = "\(record.firstPrompt)\n\(turnsContent)"
        let branchFiles = record.gitBranch ?? ""
        let repoAgent = "\(record.projectName) \(record.agentKind.displayName)"

        let match = matcher.matchHistory(
            title: record.title,
            branchFilesTools: branchFiles,
            repoAgent: repoAgent,
            chatContent: chatContent
        )
        return match?.snippet
    }

    /// Records actually shown right now:
    /// When search is active, the 14-day window is ignored completely.
    /// When empty query, always at least the last 14 days, plus whatever extra batches "Load More" revealed.
    public var windowedRecords: [AgentSessionRecord] {
        if !searchQuery.isEmpty {
            return filteredRecords
        }
        let list = filteredRecords
        let withinMinimumWindow = list.prefix(while: { $0.updatedAt >= minimumWindowStart }).count
        let visibleCount = max(withinMinimumWindow, extraRecordsShown)
        return Array(list.prefix(visibleCount))
    }

    public var hasMoreToLoad: Bool {
        guard searchQuery.isEmpty else { return false }
        return windowedRecords.count < filteredRecords.count
    }

    public func loadMore() {
        extraRecordsShown = windowedRecords.count + loadMoreBatchSize
    }

    /// Flat list of currently displayed records in section order
    public var displayRecords: [AgentSessionRecord] {
        groupedRecords.flatMap(\.records)
    }

    public var selectedRecord: AgentSessionRecord? {
        let list = displayRecords
        guard selectedIndex >= 0, selectedIndex < list.count else { return nil }
        return list[selectedIndex]
    }

    public var groupedRecords: [(title: String, records: [AgentSessionRecord])] {
        let list = windowedRecords

        // When search is active, all results are grouped under "Best matches"
        if !searchQuery.isEmpty {
            guard !list.isEmpty else { return [] }
            return [(title: "Best matches", records: list)]
        }

        // When empty query, group by date: Today / Yesterday / This week / Older
        var buckets: [AgentHistoryDateGroup: [AgentSessionRecord]] = [:]
        for record in list {
            let grp = AgentHistoryDateGroup.group(for: record.updatedAt)
            buckets[grp, default: []].append(record)
        }

        var result: [(title: String, records: [AgentSessionRecord])] = []
        for grp in AgentHistoryDateGroup.allCases {
            if let items = buckets[grp], !items.isEmpty {
                result.append((title: grp.rawValue, records: items))
            }
        }
        return result
    }
}

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
        .onKeyPress(.return, phases: .down) { _ in
            if let selected = model.selectedRecord {
                triggerPrimaryAction(for: selected)
                return .handled
            }
            return .ignored
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
                VStack(spacing: 4) {
                    ForEach(group.records) { record in
                        sessionRow(record: record)
                    }
                }
            }
        }
    }

    // MARK: - Compact Row (Two-line)
    @ViewBuilder
    private func sessionRow(record: AgentSessionRecord) -> some View {
        let c = KouenDesign.chrome
        let isSelected = model.selectedRecord?.id == record.id
        let isLive = record.liveStatus != nil || record.placement == .cloud || record.placement == .background || record.placement == .remoteControl
        let showRepo = model.selectedScope == .all || !model.searchQuery.isEmpty
        let isNotMainBranch = record.gitBranch != nil && !record.gitBranch!.isEmpty && record.gitBranch != "main"

        VStack(alignment: .leading, spacing: 3) {
            Button {
                if let idx = model.displayRecords.firstIndex(where: { $0.id == record.id }) {
                    model.selectedIndex = idx
                }
            } label: {
                VStack(alignment: .leading, spacing: 3) {
                    // Line 1: Title (Truncated)
                    Text(record.title.isEmpty ? "Untitled Session" : record.title)
                        .font(.system(size: 11, weight: isSelected ? .semibold : .medium))
                        .foregroundStyle(Color(nsColor: isSelected ? c.textPrimary : c.textSecondary))
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Line 2: Metadata (agent · live · msgs · age · repo · branch)
                    HStack(spacing: 4) {
                        AgentBadgeView(kind: record.agentKind, iconSize: 10, fontSize: 8.5, showName: false)

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
                            Text(record.projectName)
                                .font(.system(size: 9))
                                .foregroundStyle(Color(nsColor: c.textSecondary))
                                .lineLimit(1)
                        }

                        if isNotMainBranch, let branch = record.gitBranch {
                            Text("·")
                                .font(.system(size: 8))
                                .foregroundStyle(Color(nsColor: c.textTertiary))
                            HStack(spacing: 2) {
                                Image(systemName: "arrow.triangle.branch")
                                    .font(.system(size: 7.5))
                                Text(branch)
                                    .font(.system(size: 9))
                                    .lineLimit(1)
                            }
                            .foregroundStyle(Color(nsColor: c.textTertiary))
                        }

                        Spacer(minLength: 0)
                    }

                    // Content snippet if matching query
                    if let snippet = model.matchSnippet(for: record) {
                        HStack(alignment: .top, spacing: 4) {
                            Image(systemName: "text.magnifyingglass")
                                .font(.system(size: 8))
                                .foregroundStyle(Color.accentColor)
                            Text(snippet)
                                .font(.system(size: 9))
                                .foregroundStyle(Color(nsColor: c.textSecondary))
                                .lineLimit(1)
                        }
                        .padding(.top, 1)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            // Selected Row Actions (Single split button)
            if isSelected {
                HStack(spacing: 0) {
                    Spacer()
                    splitActionButton(for: record, isLive: isLive)
                }
                .padding(.top, 2)
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
    }

    // MARK: - Split Action Button
    @ViewBuilder
    private func splitActionButton(for record: AgentSessionRecord, isLive: Bool) -> some View {
        let mainTitle = isLive ? "Go to tab" : "Resume"
        let mainIcon = isLive ? "arrow.right.circle.fill" : "play.fill"
        let candidates = AgentLaunchCommands.configs.keys
            .filter { $0 != .cursor && $0 != record.agentKind }
            .sorted { $0.displayName < $1.displayName }

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

                Button {
                    copyResumeCommand(record)
                } label: {
                    Label("Copy resume command", systemImage: "doc.on.doc")
                }
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

    private func triggerPrimaryAction(for record: AgentSessionRecord) {
        let isLive = record.liveStatus != nil || record.placement == .cloud || record.placement == .background || record.placement == .remoteControl
        if isLive, let onGoToTab {
            onGoToTab(record)
        } else {
            onResume?(record)
        }
    }

    private func copyResumeCommand(_ record: AgentSessionRecord) {
        let settings = KouenSettings.load()
        let mode = settings.sessionMode(for: record.agentKind)
        let cmd = record.effectiveResumeCommand(mode: mode)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(cmd, forType: .string)
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
