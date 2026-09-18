import AppKit
import KouenCore
import KouenIPC
import SwiftUI

public enum HistoryScope: String, CaseIterable, Identifiable {
    case workspace = "Workspace"
    case project = "Project"
    case all = "All"

    public var id: String { rawValue }
}

@MainActor
public final class AgentSessionHistoryModel: ObservableObject {
    @Published public var records: [AgentSessionRecord] = []
    @Published public var searchQuery: String = ""
    @Published public var selectedScope: HistoryScope = .all
    @Published public var expandedSessionIDs: Set<String> = []
    @Published public var collapsedProjects: Set<String> = []
    @Published public var isLoading: Bool = false

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

    public func toggleProjectCollapse(projectName: String) {
        if collapsedProjects.contains(projectName) {
            collapsedProjects.remove(projectName)
        } else {
            collapsedProjects.insert(projectName)
        }
    }

    public var filteredRecords: [AgentSessionRecord] {
        let activeCWD = SessionCoordinator.shared.snapshot.activeWorkspace?.activeTab?.cwd ?? ""
        let matcher = SearchMatcher(query: searchQuery)

        return records.filter { record in
            // Scope filter
            switch selectedScope {
            case .workspace, .project:
                if !activeCWD.isEmpty && !record.projectPath.hasPrefix(activeCWD) && !activeCWD.hasPrefix(record.projectPath) {
                    return false
                }
            case .all:
                break
            }

            // Search query filter using centralized SearchMatcher (searching title, project, prompt, and turn messages)
            if matcher.hasQuery {
                let turnsContent = record.latestTurns.map(\.content).joined(separator: "\n")
                let fullContent = "\(record.firstPrompt)\n\(turnsContent)"
                return matcher.match(
                    name: record.title,
                    relativePath: "\(record.projectName) \(record.agentKind.displayName)",
                    content: fullContent
                ) != nil
            }
            return true
        }
    }

    /// Extracts matching snippet in prompt or turns for content search display
    public func matchSnippet(for record: AgentSessionRecord) -> String? {
        let matcher = SearchMatcher(query: searchQuery)
        guard matcher.hasQuery else { return nil }
        let turnsContent = record.latestTurns.map(\.content).joined(separator: "\n")
        let fullContent = "\(record.firstPrompt)\n\(turnsContent)"
        let result = matcher.match(
            name: record.title,
            relativePath: "\(record.projectName) \(record.agentKind.displayName)",
            content: fullContent
        )
        return result?.snippet
    }

    public var groupedRecords: [(project: String, records: [AgentSessionRecord])] {
        let list = filteredRecords
        var groups: [String: [AgentSessionRecord]] = [:]
        var order: [String] = []

        for record in list {
            let key = record.projectName.isEmpty ? "Other" : record.projectName
            if groups[key] == nil {
                order.append(key)
                groups[key] = []
            }
            groups[key]?.append(record)
        }

        return order.compactMap { key in
            guard let recs = groups[key], !recs.isEmpty else { return nil }
            return (project: key, records: recs)
        }
    }
}

public struct AgentSessionHistoryView: View {
    @ObservedObject var model: AgentSessionHistoryModel
    var onResume: ((AgentSessionRecord) -> Void)?
    var onViewLog: ((AgentSessionRecord) -> Void)?

    public init(
        model: AgentSessionHistoryModel,
        onResume: ((AgentSessionRecord) -> Void)? = nil,
        onViewLog: ((AgentSessionRecord) -> Void)? = nil
    ) {
        self.model = model
        self.onResume = onResume
        self.onViewLog = onViewLog
    }

    public var body: some View {
        let c = KouenDesign.chrome
        VStack(spacing: 0) {
            // Header Section
            headerView
                .padding(.horizontal, KouenDesign.Spacing.sm)
                .padding(.top, KouenDesign.Spacing.sm)
                .padding(.bottom, KouenDesign.Spacing.xs)

            // Scope Selector
            Picker("", selection: $model.selectedScope) {
                ForEach(HistoryScope.allCases) { scope in
                    Text(scope.rawValue).tag(scope)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .padding(.horizontal, KouenDesign.Spacing.sm)
            .padding(.bottom, KouenDesign.Spacing.xs)

            // Search bar
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 11))
                    .foregroundStyle(Color(nsColor: c.textTertiary))
                TextField("Search sessions", text: $model.searchQuery)
                    .textFieldStyle(.plain)
                    .font(.system(size: 11))
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
            .padding(.bottom, KouenDesign.Spacing.sm)

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
                    Text("No session history found")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color(nsColor: c.textSecondary))
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(model.groupedRecords, id: \.project) { group in
                            projectSection(group: group)
                        }
                    }
                    .padding(.horizontal, KouenDesign.Spacing.sm)
                    .padding(.vertical, KouenDesign.Spacing.sm)
                }
            }
        }
        .onAppear {
            if model.records.isEmpty {
                model.refresh(force: false)
            }
        }
    }

    // MARK: - Header
    @ViewBuilder
    private var headerView: some View {
        let c = KouenDesign.chrome
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Agent Session History")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color(nsColor: c.textPrimary))
                Text("\(model.filteredRecords.count) shown · \(model.records.count) recent")
                    .font(.system(size: 10))
                    .foregroundStyle(Color(nsColor: c.textTertiary))
            }
            Spacer()
            HStack(spacing: 6) {
                // Host pill
                HStack(spacing: 3) {
                    Image(systemName: "server.rack")
                        .font(.system(size: 9))
                    Text("Local Mac")
                        .font(.system(size: 9.5, weight: .medium))
                }
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(Color(nsColor: c.surfaceElevated))
                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                .foregroundStyle(Color(nsColor: c.textSecondary))

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
    }

    // MARK: - Project Group Section
    @ViewBuilder
    private func projectSection(group: (project: String, records: [AgentSessionRecord])) -> some View {
        let c = KouenDesign.chrome
        let isCollapsed = model.collapsedProjects.contains(group.project)

        VStack(spacing: 4) {
            Button {
                withAnimation(.easeInOut(duration: 0.15)) {
                    model.toggleProjectCollapse(projectName: group.project)
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: isCollapsed ? "chevron.right" : "chevron.down")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(Color(nsColor: c.textTertiary))
                    Text(group.project)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color(nsColor: c.textPrimary))
                    Spacer()
                    Text("\(group.records.count)")
                        .font(.system(size: 9.5, weight: .medium))
                        .foregroundStyle(Color(nsColor: c.textSecondary))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(Color(nsColor: c.surfaceElevated))
                        .clipShape(Capsule())
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.vertical, 2)

            if !isCollapsed {
                VStack(spacing: 6) {
                    ForEach(group.records) { record in
                        sessionCard(record: record)
                    }
                }
            }
        }
    }

    // MARK: - Session Card
    @ViewBuilder
    private func sessionCard(record: AgentSessionRecord) -> some View {
        let c = KouenDesign.chrome
        let isExpanded = model.expandedSessionIDs.contains(record.id)

        VStack(alignment: .leading, spacing: 6) {
            // Card Title & Expand toggle
            HStack(alignment: .top, spacing: 6) {
                Text(record.title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color(nsColor: c.textPrimary))
                    .lineLimit(isExpanded ? 4 : 2)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        model.toggleExpanded(sessionID: record.id)
                    }
                } label: {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(Color(nsColor: c.textTertiary))
                        .padding(2)
                }
                .buttonStyle(.plain)
            }

            // Agent Badge Row
            HStack(spacing: 5) {
                AgentBadgeView(kind: record.agentKind)

                Text("\(record.messageCount) msgs")
                    .font(.system(size: 9.5))
                    .foregroundStyle(Color(nsColor: c.textTertiary))

                Text("·")
                    .font(.system(size: 9))
                    .foregroundStyle(Color(nsColor: c.textTertiary))

                Text(relativeDate(record.updatedAt))
                    .font(.system(size: 9.5))
                    .foregroundStyle(Color(nsColor: c.textTertiary))
            }

            // Matched Content Snippet (when query matches inside chat turns or prompt)
            if let snippet = model.matchSnippet(for: record) {
                HStack(alignment: .top, spacing: 5) {
                    Image(systemName: "text.magnifyingglass")
                        .font(.system(size: 8.5))
                        .foregroundStyle(Color.accentColor)
                    Text(snippet)
                        .font(.system(size: 9.5))
                        .foregroundStyle(Color(nsColor: c.textSecondary))
                        .lineLimit(2)
                }
                .padding(5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.accentColor.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
            }

            // Worktree & Project pills
            HStack(spacing: 5) {
                Text(record.worktreeAvailable ? "Active worktree" : "Unavailable worktree")
                    .font(.system(size: 9))
                    .foregroundStyle(Color(nsColor: record.worktreeAvailable ? c.success : c.textTertiary))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                    .background(Color(nsColor: c.surfaceElevated))
                    .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))

                if let branch = record.gitBranch, !branch.isEmpty {
                    HStack(spacing: 3) {
                        Image(systemName: "arrow.triangle.branch")
                            .font(.system(size: 8))
                        Text(branch)
                            .font(.system(size: 9))
                    }
                    .foregroundStyle(Color(nsColor: c.textSecondary))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                    .background(Color(nsColor: c.surfaceElevated))
                    .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
                }

                HStack(spacing: 3) {
                    Image(systemName: "folder.fill")
                        .font(.system(size: 8))
                    Text(record.projectName)
                        .font(.system(size: 9))
                }
                .foregroundStyle(Color(nsColor: c.textSecondary))
                .padding(.horizontal, 4)
                .padding(.vertical, 1)
                .background(Color(nsColor: c.surfaceElevated))
                .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
            }

            // Expanded Details
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    // Action Buttons Row
                    HStack(spacing: 6) {
                        Button {
                            onResume?(record)
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 9))
                                Text("Resume in New Tab")
                                    .font(.system(size: 10, weight: .semibold))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.accentColor.opacity(0.15))
                            .foregroundStyle(Color.accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                        }
                        .buttonStyle(.plain)

                        Button {
                            onViewLog?(record)
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "doc.text")
                                    .font(.system(size: 9))
                                Text("View Log")
                                    .font(.system(size: 10))
                            }
                            .padding(.horizontal, 7)
                            .padding(.vertical, 4)
                            .background(Color(nsColor: c.surfaceElevated))
                            .foregroundStyle(Color(nsColor: c.textSecondary))
                            .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 2)

                    // First Prompt Box
                    if !record.firstPrompt.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("FIRST PROMPT")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(Color(nsColor: c.textTertiary))
                                Spacer()
                                Button {
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(record.firstPrompt, forType: .string)
                                } label: {
                                    HStack(spacing: 3) {
                                        Image(systemName: "doc.on.doc")
                                            .font(.system(size: 8))
                                        Text("Copy")
                                            .font(.system(size: 8.5))
                                    }
                                    .foregroundStyle(Color(nsColor: c.textTertiary))
                                }
                                .buttonStyle(.plain)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text("YOU")
                                    .font(.system(size: 8.5, weight: .bold))
                                    .foregroundStyle(Color(nsColor: c.textSecondary))
                                Text(record.firstPrompt)
                                    .font(.system(size: 10))
                                    .foregroundStyle(Color(nsColor: c.textPrimary))
                                    .lineLimit(4)
                            }
                            .padding(6)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(nsColor: c.surfaceElevated))
                            .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                        }
                    }

                    // Latest Turns Box
                    if !record.latestTurns.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("LATEST TURNS")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(Color(nsColor: c.textTertiary))

                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(Array(record.latestTurns.enumerated()), id: \.offset) { _, turn in
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(turn.role)
                                            .font(.system(size: 8, weight: .bold))
                                            .foregroundStyle(turn.role == "YOU" ? Color(nsColor: c.textSecondary) : Color.accentColor)
                                        Text(turn.content)
                                            .font(.system(size: 9.5))
                                            .foregroundStyle(Color(nsColor: c.textPrimary))
                                            .lineLimit(3)
                                    }
                                    .padding(5)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(nsColor: c.surfaceElevated))
                                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                                }
                            }
                        }
                    }

                    // Worktree Details
                    VStack(alignment: .leading, spacing: 2) {
                        Text("WORKTREE")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(Color(nsColor: c.textTertiary))
                        Text(record.projectPath)
                            .font(.system(size: 9.5, design: .monospaced))
                            .foregroundStyle(Color(nsColor: c.textSecondary))
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(8)
        .background(Color(nsColor: c.surfaceElevated))
        .clipShape(RoundedRectangle(cornerRadius: KouenDesign.Radius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: KouenDesign.Radius.card, style: .continuous)
                .stroke(Color(nsColor: c.border), lineWidth: 1)
        )
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
