import AppKit
import Combine
import KouenCore
import KouenIPC
import KouenGit
import os.signpost
import SwiftUI

private let historySignposter = OSSignposter(subsystem: "com.vit129.kouen", category: "history")

public enum HistoryScope: String, CaseIterable, Identifiable, Sendable {
    case workspace = "Workspace"
    case repo = "Project"
    case all = "All"

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
    public struct Section: Identifiable {
        public let id: String
        public let title: String
        public let records: [AgentSessionRecord]
        let projectRoot: String?
    }

    static let agentShortcutKindsDefaultsKey = "Kouen.AgentSessionHistory.shortcutAgentKinds"
    static let defaultAgentShortcutKinds: [AgentKind] = [.claudeCode, .codex, .antigravity, .copilot]

    @Published public var records: [AgentSessionRecord] = [] {
        didSet {
            scheduleFilter(debounceMs: 0)
        }
    }
    @Published public var searchQuery: String = "" {
        didSet {
            extraRecordsShown = 0
            scheduleFilter(debounceMs: 50)
        }
    }
    @Published public var selectedScope: HistoryScope = .repo {
        didSet {
            extraRecordsShown = 0
            scheduleFilter(debounceMs: 0)
        }
    }
    /// Selected agent filters for multi-selection. If empty, all agents are shown.
    @Published public var selectedAgents: Set<AgentKind> = [] {
        didSet {
            extraRecordsShown = 0
            scheduleFilter(debounceMs: 0)
        }
    }
    @Published public private(set) var agentShortcutKinds: [AgentKind]
    @Published public var filteredRecords: [AgentSessionRecord] = [] {
        didSet {
            recomputeDerivedLists()
        }
    }
    @Published public var selectedIndex: Int = 0 {
        didSet {
            updateSelectedRecordID()
        }
    }
    @Published public var expandedSessionIDs: Set<String> = []
    @Published public var collapsedSections: Set<String> = []
    @Published public var isLoading: Bool = false
    @Published public private(set) var isSearching: Bool = false
    @Published public private(set) var searchableRecordsCount: Int = 0
    @Published public private(set) var selectedRecordID: String?

    /// How many records beyond the default 14-day window are currently revealed via "Load More".
    @Published public var extraRecordsShown: Int = 0 {
        didSet {
            recomputeDerivedLists()
        }
    }

    private var cachedGroupedRecords: [Section] = []
    private var cachedDisplayRecords: [AgentSessionRecord] = []

    /// Snippets extracted during search scoring, keyed by session id.
    private var searchSnippets: [String: String] = [:]
    private var searchMetadata: [String: [String: String]] = [:]
    private var hydratedEvidenceIDs: Set<String> = []
    /// Match locations extracted during search scoring, keyed by session id.
    private var searchMatchLocations: [String: AgentSessionRecord.MatchLocationInfo] = [:]
    /// Set of session IDs that were matched via semantic search fallback.
    private var semanticMatchIDs: Set<String> = []

    /// Repo root resolver injected for testing or production.
    public var repoRootResolver: @Sendable (String) -> String?
    /// Active CWD provider injected for testing or production.
    public var activeCWDProvider: @Sendable () -> String
    /// Working directories represented by tabs in the active workspace.
    public var workspaceCWDsProvider: @Sendable () -> [String]

    private let preferences: UserDefaults

    /// Memoized repo root cache keyed by projectPath.
    private var repoRootCache: [String: String] = [:]

    private var filterTask: Task<Void, Never>?
    private var snapshotCancellable: AnyCancellable?
    private var lastFilterContextSignature = ""

    private let loadMoreBatchSize = 20
    private var minimumWindowStart: Date {
        Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? .distantPast
    }

    public init(
        repoRootResolver: @escaping @Sendable (String) -> String? = { GitService.shared.resolveRepoRoot(for: $0) },
        activeCWDProvider: (@Sendable () -> String)? = nil,
        workspaceCWDsProvider: (@Sendable () -> [String])? = nil,
        userDefaults: UserDefaults = .standard
    ) {
        self.repoRootResolver = repoRootResolver
        self.preferences = userDefaults
        self.agentShortcutKinds = Self.loadAgentShortcutKinds(from: userDefaults)
        if let activeCWDProvider {
            self.activeCWDProvider = activeCWDProvider
        } else {
            self.activeCWDProvider = {
                MainActor.assumeIsolated {
                    SessionCoordinator.shared.snapshot.activeWorkspace?.activeTab?.cwd ?? ""
                }
            }
        }
        if let workspaceCWDsProvider {
            self.workspaceCWDsProvider = workspaceCWDsProvider
        } else {
            self.workspaceCWDsProvider = {
                MainActor.assumeIsolated {
                    SessionCoordinator.shared.snapshot.activeWorkspace?.sessions
                        .flatMap(\.tabs)
                        .compactMap(\.cwd) ?? []
                }
            }
        }
        lastFilterContextSignature = filterContextSignature

        self.snapshotCancellable = NotificationCenter.default
            .publisher(for: NotificationBus.shared.snapshotChanged)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    let signature = self.filterContextSignature
                    guard signature != self.lastFilterContextSignature else { return }
                    self.lastFilterContextSignature = signature
                    if self.selectedScope != .all {
                        self.scheduleFilter(debounceMs: 0)
                    }
                }
            }
    }

    public func refresh(force: Bool = true) {
        isLoading = true
        Task { [weak self] in
            let scanned = await AgentHistoryScanner.shared.getOrScan(force: force)
            guard let self else { return }
            if force { self.repoRootCache.removeAll() }
            if self.records != scanned {
                self.records = scanned
            } else if force {
                self.scheduleFilter(debounceMs: 0)
            }
            self.isLoading = false
        }
    }

    public func toggleExpanded(sessionID: String) {
        if expandedSessionIDs.contains(sessionID) {
            expandedSessionIDs.remove(sessionID)
        } else {
            expandedSessionIDs.insert(sessionID)
        }
    }

    public func toggleSectionCollapse(id: String) {
        if collapsedSections.contains(id) {
            collapsedSections.remove(id)
        } else {
            collapsedSections.insert(id)
        }
    }

    public func toggleAgentFilter(_ kind: AgentKind) {
        if selectedAgents.contains(kind) {
            selectedAgents.remove(kind)
        } else {
            selectedAgents.insert(kind)
        }
    }

    /// Persists the ordered, visible agent shortcut list without changing active filters.
    public func setAgentShortcutKinds(_ kinds: [AgentKind]) {
        var seen = Set<AgentKind>()
        let normalized = Array(kinds.filter { seen.insert($0).inserted }.prefix(5))
        guard normalized != agentShortcutKinds else { return }
        agentShortcutKinds = normalized
        ProjectDirectoryPersistence.set(preferences, normalized.map(\.rawValue), forKey: Self.agentShortcutKindsDefaultsKey)
    }

    /// Moves a selected shortcut into the destination shortcut's current slot.
    public func moveAgentShortcut(_ kind: AgentKind, to destination: AgentKind) {
        var kinds = agentShortcutKinds
        guard
            kind != destination,
            let sourceIndex = kinds.firstIndex(of: kind),
            let destinationIndex = kinds.firstIndex(of: destination)
        else { return }
        kinds.remove(at: sourceIndex)
        kinds.insert(kind, at: min(destinationIndex, kinds.count))
        setAgentShortcutKinds(kinds)
    }

    public func toggleAgentShortcut(_ kind: AgentKind) {
        var kinds = agentShortcutKinds
        if let index = kinds.firstIndex(of: kind) {
            kinds.remove(at: index)
        } else if kinds.count < 5 {
            kinds.append(kind)
        }
        setAgentShortcutKinds(kinds)
    }

    private static func loadAgentShortcutKinds(from preferences: UserDefaults) -> [AgentKind] {
        guard preferences.object(forKey: agentShortcutKindsDefaultsKey) != nil else {
            return defaultAgentShortcutKinds
        }
        let savedValues = preferences.stringArray(forKey: agentShortcutKindsDefaultsKey) ?? []
        var seen = Set<AgentKind>()
        let normalized = Array(savedValues.compactMap(AgentKind.init(rawValue:)).filter { seen.insert($0).inserted }.prefix(5))
        let normalizedValues = normalized.map(\.rawValue)
        if savedValues != normalizedValues {
            ProjectDirectoryPersistence.set(preferences, normalizedValues, forKey: agentShortcutKindsDefaultsKey)
        }
        return normalized
    }

    public var availableAgentKinds: [AgentKind] {
        let distinct = Set(records.map(\.agentKind))
        let canonical: [AgentKind] = [.claudeCode, .codex, .copilot, .antigravity]
        var result = canonical.filter { distinct.contains($0) || $0 == .antigravity }
        for kind in distinct where !canonical.contains(kind) {
            result.append(kind)
        }
        return result.isEmpty ? canonical : result
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

    private func recomputeDerivedLists() {
        let rawWindowed: [AgentSessionRecord]
        if !searchQuery.isEmpty {
            rawWindowed = filteredRecords
        } else {
            let withinMinimumWindow = filteredRecords.prefix(while: { $0.updatedAt >= minimumWindowStart }).count
            rawWindowed = Array(filteredRecords.prefix(max(withinMinimumWindow, extraRecordsShown)))
        }

        if !searchQuery.isEmpty {
            cachedGroupedRecords = rawWindowed.isEmpty ? [] : [
                Section(id: "search", title: "Best matches", records: rawWindowed, projectRoot: nil)
            ]
        } else if selectedScope == .repo {
            let byDate = Dictionary(grouping: rawWindowed) { AgentHistoryDateGroup.group(for: $0.updatedAt) }
            cachedGroupedRecords = AgentHistoryDateGroup.allCases.compactMap { group in
                byDate[group].map { Section(id: group.rawValue, title: group.rawValue, records: $0, projectRoot: nil) }
            }
        } else {
            cachedGroupedRecords = projectSections(for: rawWindowed)
        }

        let previousID = selectedRecordID
        cachedDisplayRecords = cachedGroupedRecords.flatMap(\.records)
        let restoredIndex = cachedDisplayRecords.firstIndex { $0.id == previousID }
        let index = restoredIndex ?? min(selectedIndex, max(0, cachedDisplayRecords.count - 1))
        if selectedIndex != index {
            selectedIndex = index
        } else {
            updateSelectedRecordID()
        }
    }

    private func projectSections(for records: [AgentSessionRecord]) -> [Section] {
        var orderedRoots: [String] = []
        var byProject: [String: [AgentSessionRecord]] = [:]
        for record in records {
            let root = projectRoot(for: record.projectPath)
            if byProject[root] == nil { orderedRoots.append(root) }
            byProject[root, default: []].append(record)
        }

        let activeRoot = selectedScope == .workspace ? repoRootCache[activeCWDProvider()] : nil
        if let activeRoot, let index = orderedRoots.firstIndex(of: activeRoot) {
            orderedRoots.remove(at: index)
            orderedRoots.insert(activeRoot, at: 0)
        }

        let nameCounts = Dictionary(grouping: orderedRoots, by: projectName(for:)).mapValues(\.count)
        return orderedRoots.compactMap { root in
            guard let records = byProject[root] else { return nil }
            let name = projectName(for: root)
            let label = nameCounts[name, default: 0] > 1
                ? "\(name) · \((root as NSString).deletingLastPathComponent)"
                : name
            let title = root == activeRoot ? "Current Project · \(label)" : label
            return Section(id: "project:\(root)", title: title, records: records, projectRoot: root)
        }
    }

    func projectRoot(for path: String) -> String {
        repoRootCache[path] ?? path
    }

    func projectName(for path: String) -> String {
        let root = projectRoot(for: path)
        let name = (root as NSString).lastPathComponent
        return name.isEmpty ? "Unknown Project" : name
    }

    struct RecoveredTurnProjects: Sendable {
        let turns: [AgentHistoryTurn]
        let roots: [String: String]
    }

    func recoverTurnProjects(for record: AgentSessionRecord) async -> RecoveredTurnProjects? {
        let resolver = repoRootResolver
        let initialCache = repoRootCache
        return await Task.detached(priority: .utility) {
            guard let turns = AgentHistoryScanner.recoverTurnProjects(for: record) else { return nil }
            var roots: [String: String] = [:]
            for path in turns.compactMap(\.projectPath) where roots[path] == nil {
                roots[path] = initialCache[path] ?? Self.resolveProjectRoot(path, resolver: resolver)
            }
            return RecoveredTurnProjects(turns: turns, roots: roots)
        }.value
    }

    private nonisolated static func resolveProjectRoot(_ path: String, resolver: (String) -> String?) -> String {
        if let root = resolver(path) { return root }
        if path.contains("/\(WorktreeManager.worktreeDir)/") {
            return ProjectGroupResolver.projectGroupRootPath(for: path)
        }
        return path
    }

    private func updateSelectedRecordID() {
        let id = cachedDisplayRecords.indices.contains(selectedIndex) ? cachedDisplayRecords[selectedIndex].id : nil
        if selectedRecordID != id { selectedRecordID = id }
    }

    /// Pre-warms the session history by loading cached records from SQLite in the background
    /// without waiting for the user to click the History tab.
    public func warmUp() {
        guard records.isEmpty else { return }
        Task { [weak self] in
            let cached = await AgentHistoryScanner.shared.getOrScan(force: false)
            await MainActor.run { [weak self] in
                guard let self, self.records.isEmpty else { return }
                self.records = cached
            }
        }
    }

    /// Applies filtering synchronously immediately (useful for unit tests or immediate refreshes).
    public func applyFilterNow() {
        filterTask?.cancel()
        filterTask = nil
        isSearching = false
        let state = historySignposter.beginInterval("applyFilterNow")
        let (filtered, newCache, snippets, matchLocations, semanticIDs, metadata, hydratedIDs, searchableCount) = Self.computeFiltered(
            query: searchQuery,
            scope: selectedScope,
            selectedAgents: selectedAgents,
            records: records,
            activeCWD: activeCWDProvider(),
            workspaceCWDs: workspaceCWDsProvider(),
            resolver: repoRootResolver,
            initialCache: repoRootCache
        )
        historySignposter.endInterval("applyFilterNow", state)
        self.repoRootCache = newCache
        self.searchSnippets = snippets
        self.searchMetadata = metadata
        self.hydratedEvidenceIDs = hydratedIDs
        self.searchMatchLocations = matchLocations
        self.semanticMatchIDs = semanticIDs
        self.searchableRecordsCount = searchableCount
        self.filteredRecords = filtered
    }

    /// Schedules an asynchronous recomputation of filteredRecords.
    /// Debounced ~50ms for query typing; stale search tasks are cancelled immediately.
    public func scheduleFilter(debounceMs: UInt64 = 50) {
        filterTask?.cancel()

        let currentQuery = searchQuery
        isSearching = !currentQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let currentScope = selectedScope
        let currentAgents = selectedAgents
        let currentRecords = records
        let activeCWD = activeCWDProvider()
        let workspaceCWDs = workspaceCWDsProvider()
        let resolver = repoRootResolver

        let localCache = repoRootCache

        filterTask = Task(priority: .userInitiated) { [weak self] in
            if debounceMs > 0 {
                try? await Task.sleep(nanoseconds: debounceMs * 1_000_000)
            }
            guard !Task.isCancelled else { return }

            // Start on the main actor so synchronous filter changes can coalesce
            // before any worktree resolution starts on the background executor.
            let worker = Task.detached(priority: .userInitiated) {
                let state = historySignposter.beginInterval("computeFiltered")
                defer { historySignposter.endInterval("computeFiltered", state) }
                return Self.computeFiltered(
                    query: currentQuery,
                    scope: currentScope,
                    selectedAgents: currentAgents,
                    records: currentRecords,
                    activeCWD: activeCWD,
                    workspaceCWDs: workspaceCWDs,
                    resolver: resolver,
                    initialCache: localCache
                )
            }
            let (filtered, newCache, snippets, matchLocations, semanticIDs, metadata, hydratedIDs, searchableCount) =
                await withTaskCancellationHandler {
                    await worker.value
                } onCancel: {
                    worker.cancel()
                }

            guard let self, !Task.isCancelled else { return }
            self.repoRootCache = newCache
            self.isSearching = false
            self.searchSnippets = snippets
            self.searchMetadata = metadata
            self.hydratedEvidenceIDs = hydratedIDs
            self.searchMatchLocations = matchLocations
            self.semanticMatchIDs = semanticIDs
            self.searchableRecordsCount = searchableCount
            self.filteredRecords = filtered
        }
    }

    private var filterContextSignature: String {
        activeCWDProvider() + "\0" + workspaceCWDsProvider().sorted().joined(separator: "\n")
    }

    nonisolated package static func computeFiltered(
        query: String,
        scope: HistoryScope,
        selectedAgents: Set<AgentKind> = [],
        records: [AgentSessionRecord],
        activeCWD: String,
        workspaceCWDs: [String] = [],
        resolver: @Sendable (String) -> String?,
        initialCache: [String: String]
    ) -> (
        filtered: [AgentSessionRecord],
        cache: [String: String],
        snippets: [String: String],
        matchLocations: [String: AgentSessionRecord.MatchLocationInfo],
        semanticMatchIDs: Set<String>,
        metadata: [String: [String: String]],
        hydratedIDs: Set<String>,
        searchableCount: Int
    ) {
        let baseRecords: [AgentSessionRecord]
        if selectedAgents.isEmpty {
            baseRecords = records
        } else {
            baseRecords = records.filter { selectedAgents.contains($0.agentKind) }
        }

        var cache = initialCache
        func resolveRoot(for path: String) -> String {
            if let cached = cache[path] { return cached }
            let root = resolveProjectRoot(path, resolver: resolver)
            cache[path] = root
            return root
        }

        let activeRepoRoot = activeCWD.isEmpty ? nil : resolveRoot(for: activeCWD)
        let workspacePaths = ([activeCWD] + workspaceCWDs).filter { !$0.isEmpty }
        let workspaceRepoRoots = scope == .workspace ? Set(workspacePaths.map(resolveRoot)) : []
        let scopedRecords = baseRecords.filter { record in
            guard !Task.isCancelled else { return false }
            let projectRoot = resolveRoot(for: record.projectPath)
            switch scope {
            case .all:
                return true
            case .workspace:
                return workspaceRepoRoots.contains(projectRoot)
            case .repo:
                return projectRoot == activeRepoRoot
            }
        }
        for record in scopedRecords {
            if Task.isCancelled { break }
            for turn in record.latestTurns {
                if let path = turn.projectPath { _ = resolveRoot(for: path) }
            }
        }
        let matcher = SearchMatcher(query: query)

        // Search respects the same repo and agent filters as the unfiltered list.
        if matcher.hasQuery && !Task.isCancelled {
            let hits = AgentHistorySearch.rank(query: query, records: scopedRecords)
            var snippets: [String: String] = [:]
            var matchLocations: [String: AgentSessionRecord.MatchLocationInfo] = [:]
            var semanticMatchIDs = Set<String>()
            var metadata: [String: [String: String]] = [:]

            for hit in hits {
                var fields: [String: String] = [:]
                fields["File"] = hit.fileEvidence
                fields["Tool"] = hit.toolEvidence
                if !fields.isEmpty { metadata[hit.record.id] = fields }
                if let loc = hit.matchLocation {
                    matchLocations[hit.record.id] = loc
                }
                if hit.isSemanticMatch {
                    semanticMatchIDs.insert(hit.record.id)
                }
            }

            // Keep indexed evidence for every result, including those below the first screen.
            for hit in hits {
                if let snippet = hit.snippet, !snippet.isEmpty {
                    snippets[hit.record.id] = snippet
                }
            }
            return (hits.map(\.record), cache, snippets, matchLocations, semanticMatchIDs, metadata, Set(hits.prefix(50).map { $0.record.id }), scopedRecords.count)
        }

        let newestFirst = scopedRecords.sorted {
            if $0.updatedAt == $1.updatedAt { return $0.id < $1.id }
            return $0.updatedAt > $1.updatedAt
        }
        return (newestFirst, cache, [:], [:], [], [:], [], scopedRecords.count)
    }

    /// Fetch evidence only when a result outside the initial screen becomes visible.
    public func loadEvidence(for record: AgentSessionRecord) async {
        let query = searchQuery
        guard !query.isEmpty, hydratedEvidenceIDs.insert(record.id).inserted else { return }
        let hit = await Task.detached(priority: .userInitiated) {
            AgentHistorySearch.evidence(query: query, record: record)
        }.value
        guard searchQuery == query, let hit else { return }
        objectWillChange.send()
        if let snippet = hit.snippet { searchSnippets[record.id] = snippet }
        var fields: [String: String] = [:]
        fields["File"] = hit.fileEvidence
        fields["Tool"] = hit.toolEvidence
        if !fields.isEmpty { searchMetadata[record.id] = fields }
    }

    public func matchMetadata(for record: AgentSessionRecord, field: String) -> String? {
        searchMetadata[record.id]?[field]
    }

    /// Match location info (e.g. "late in session · turn 42/50") for active query (O(1) dictionary read).
    public func matchLocation(for record: AgentSessionRecord) -> AgentSessionRecord.MatchLocationInfo? {
        searchMatchLocations[record.id]
    }

    /// Whether this hit was returned by local semantic search fallback.
    public func isSemanticMatch(for record: AgentSessionRecord) -> Bool {
        semanticMatchIDs.contains(record.id)
    }

    /// Extracts matching snippet in prompt or turns for content search display (O(1) dictionary read).
    public func matchSnippet(for record: AgentSessionRecord) -> String? {
        if let snip = searchSnippets[record.id] {
            return snip.isEmpty ? nil : snip
        }
        let matcher = SearchMatcher(query: searchQuery)
        guard matcher.hasQuery else { return nil }
        let turnsContent = record.latestTurns.map(\.content).joined(separator: "\n")
        let chatContent = "\(record.firstPrompt)\n\(turnsContent)"
        let match = matcher.matchHistory(title: "", chatContent: chatContent)
        let snippet = match?.snippet ?? ""
        searchSnippets[record.id] = snippet
        return snippet.isEmpty ? nil : snippet
    }

    /// Records actually shown right now:
    /// When search is active, the 14-day window is ignored completely.
    /// When empty query, always at least the last 14 days, plus whatever extra batches "Load More" revealed.
    public var windowedRecords: [AgentSessionRecord] {
        cachedDisplayRecords
    }

    public var hasMoreToLoad: Bool {
        guard searchQuery.isEmpty else { return false }
        return cachedDisplayRecords.count < filteredRecords.count
    }

    public func loadMore() {
        extraRecordsShown = cachedDisplayRecords.count + loadMoreBatchSize
    }

    /// Flat list of currently displayed records in section order
    public var displayRecords: [AgentSessionRecord] {
        cachedDisplayRecords
    }

    public var selectedRecord: AgentSessionRecord? {
        guard selectedIndex >= 0, selectedIndex < cachedDisplayRecords.count else { return nil }
        return cachedDisplayRecords[selectedIndex]
    }

    public var groupedRecords: [Section] {
        cachedGroupedRecords
    }
}
