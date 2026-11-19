import AppKit
import Combine
import KouenCore
import KouenIPC
import KouenGit
import os.signpost
import SwiftUI

private let historySignposter = OSSignposter(subsystem: "com.vit129.kouen", category: "history")

final class RepoRootCache: @unchecked Sendable {
    static let shared = RepoRootCache()
    private let lock = NSLock()
    private var cache: [String: (root: String, cachedAt: Date)] = [:]
    private static let ttl: TimeInterval = 60.0

    func get(_ path: String) -> String? {
        lock.lock()
        defer { lock.unlock() }
        guard let entry = cache[path] else { return nil }
        if Date().timeIntervalSince(entry.cachedAt) < Self.ttl {
            return entry.root
        }
        cache.removeValue(forKey: path)
        return nil
    }

    func set(_ root: String, for path: String) {
        lock.lock()
        defer { lock.unlock() }
        cache[path] = (root, Date())
    }

    func clear() {
        lock.lock()
        defer { lock.unlock() }
        cache.removeAll()
    }
}

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

    private var cachedWindowedRecords: [AgentSessionRecord] = []
    private var cachedGroupedRecords: [(title: String, records: [AgentSessionRecord])] = []
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
    private var updateCancellable: AnyCancellable?
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

        self.updateCancellable = NotificationCenter.default
            .publisher(for: AgentHistoryScanner.didUpdateNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    let updated = await AgentHistoryScanner.shared.getOrScan(force: false)
                    self.records = updated
                    self.isLoading = false
                }
            }
    }

    public func refresh(force: Bool = true) {
        if force {
            RepoRootCache.shared.clear()
        }
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
        preferences.set(normalized.map(\.rawValue), forKey: Self.agentShortcutKindsDefaultsKey)
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
            preferences.set(normalizedValues, forKey: agentShortcutKindsDefaultsKey)
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

    /// Groups sessions across different repositories working on the same task into a single composite entry.
    public static func groupCrossRepoTasks(_ records: [AgentSessionRecord]) -> [AgentSessionRecord] {
        guard records.count > 1 else { return records }

        // Find candidate branches that are not main/master and occur across multiple projects
        var branchMap: [String: [AgentSessionRecord]] = [:]
        for record in records {
            guard let branch = record.gitBranch,
                  !branch.isEmpty,
                  branch != "main",
                  branch != "master" else { continue }
            branchMap[branch, default: []].append(record)
        }

        // Keep only branches where distinct project names > 1, picking the latest session per repo
        var validGroups: [String: [AgentSessionRecord]] = [:]
        for (branch, sessions) in branchMap {
            let sorted = sessions.sorted { $0.updatedAt > $1.updatedAt }
            var seenProjects = Set<String>()
            var perRepoSessions: [AgentSessionRecord] = []
            for s in sorted {
                if !seenProjects.contains(s.projectName) {
                    seenProjects.insert(s.projectName)
                    perRepoSessions.append(s)
                }
            }
            if perRepoSessions.count > 1 {
                validGroups[branch] = perRepoSessions
            }
        }

        guard !validGroups.isEmpty else { return records }

        // Only the per-repo latest sessions fold into the composite row; older sessions on the
        // same branch stay as their own rows (grouping suggests, it never hides history).
        let foldedIDs = Set(validGroups.values.flatMap { $0.map(\.id) })
        var seenGroupBranches = Set<String>()
        var result: [AgentSessionRecord] = []

        for record in records {
            if let branch = record.gitBranch, let siblings = validGroups[branch], foldedIDs.contains(record.id) {
                if seenGroupBranches.contains(branch) {
                    continue
                }
                seenGroupBranches.insert(branch)
                let primary = siblings.first ?? record
                result.append(primary.withCrossRepoSiblings(siblings))
            } else {
                result.append(record)
            }
        }

        return result
    }

    private func recomputeDerivedLists() {
        let rawWindowed: [AgentSessionRecord]
        if !searchQuery.isEmpty {
            rawWindowed = filteredRecords
        } else {
            let list = filteredRecords
            let withinMinimumWindow = list.prefix(while: { $0.updatedAt >= minimumWindowStart }).count
            let visibleCount = max(withinMinimumWindow, extraRecordsShown)
            rawWindowed = Array(list.prefix(visibleCount))
        }

        var currentProjectRecords: [AgentSessionRecord] = []
        var remainingRecords = rawWindowed
        if searchQuery.isEmpty, selectedScope == .workspace,
           let activeRoot = repoRootCache[activeCWDProvider()] {
            remainingRecords.removeAll { record in
                guard repoRootCache[record.projectPath] == activeRoot else { return false }
                currentProjectRecords.append(record)
                return true
            }
        }

        // Search results must remain individual: grouping can hide the actual matching session.
        let windowed = searchQuery.isEmpty ? Self.groupCrossRepoTasks(remainingRecords) : remainingRecords
        cachedWindowedRecords = currentProjectRecords + windowed

        let grouped: [(title: String, records: [AgentSessionRecord])]
        if !searchQuery.isEmpty {
            if windowed.isEmpty {
                grouped = []
            } else {
                grouped = [(title: "Best matches", records: windowed)]
            }
        } else {
            var buckets: [AgentHistoryDateGroup: [AgentSessionRecord]] = [:]
            for record in windowed {
                let grp = AgentHistoryDateGroup.group(for: record.updatedAt)
                buckets[grp, default: []].append(record)
            }
            var result: [(title: String, records: [AgentSessionRecord])] = []
            if !currentProjectRecords.isEmpty {
                result.append((title: "Current Project", records: currentProjectRecords))
            }
            for grp in AgentHistoryDateGroup.allCases {
                if let items = buckets[grp], !items.isEmpty {
                    result.append((title: grp.rawValue, records: items))
                }
            }
            grouped = result
        }
        cachedGroupedRecords = grouped
        cachedDisplayRecords = grouped.flatMap(\.records)

        if selectedIndex >= cachedDisplayRecords.count {
            selectedIndex = max(0, cachedDisplayRecords.count - 1)
        }
        updateSelectedRecordID()
    }

    private func updateSelectedRecordID() {
        if selectedIndex >= 0 && selectedIndex < cachedDisplayRecords.count {
            selectedRecordID = cachedDisplayRecords[selectedIndex].id
        } else {
            selectedRecordID = nil
        }
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

        filterTask = Task.detached(priority: .userInitiated) { [weak self] in
            if debounceMs > 0 {
                try? await Task.sleep(nanoseconds: debounceMs * 1_000_000)
            }
            if Task.isCancelled { return }

            let state = historySignposter.beginInterval("computeFiltered")
            let (filtered, newCache, snippets, matchLocations, semanticIDs, metadata, hydratedIDs, searchableCount) = Self.computeFiltered(
                query: currentQuery,
                scope: currentScope,
                selectedAgents: currentAgents,
                records: currentRecords,
                activeCWD: activeCWD,
                workspaceCWDs: workspaceCWDs,
                resolver: resolver,
                initialCache: localCache
            )
            historySignposter.endInterval("computeFiltered", state)

            if Task.isCancelled { return }

            await MainActor.run { [weak self] in
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
            if let cached = RepoRootCache.shared.get(path) {
                cache[path] = cached
                return cached
            }
            let root = resolver(path) ?? path
            cache[path] = root
            RepoRootCache.shared.set(root, for: path)
            return root
        }

        let activeRepoRoot = activeCWD.isEmpty ? "" : resolveRoot(for: activeCWD)
        let workspaceRepoRoots = Set(workspaceCWDs.filter { !$0.isEmpty }.map(resolveRoot))
        let scopedRecords = baseRecords.filter { record in
            switch scope {
            case .all:
                return true
            case .workspace:
                guard !workspaceRepoRoots.isEmpty else { return false }
                return workspaceRepoRoots.contains(resolveRoot(for: record.projectPath))
            case .repo:
                guard !activeRepoRoot.isEmpty else { return false }
                if record.projectPath == activeRepoRoot || record.projectPath.hasPrefix(activeRepoRoot + "/") {
                    return true
                }
                return resolveRoot(for: record.projectPath) == activeRepoRoot
            }
        }
        let matcher = SearchMatcher(query: query)

        // Search respects the same repo and agent filters as the unfiltered list.
        if matcher.hasQuery {
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

        return (scopedRecords, cache, [:], [:], [], [:], [], scopedRecords.count)
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
        cachedWindowedRecords
    }

    public var hasMoreToLoad: Bool {
        guard searchQuery.isEmpty else { return false }
        return cachedWindowedRecords.count < filteredRecords.count
    }

    public func loadMore() {
        extraRecordsShown = cachedWindowedRecords.count + loadMoreBatchSize
    }

    /// Flat list of currently displayed records in section order
    public var displayRecords: [AgentSessionRecord] {
        cachedDisplayRecords
    }

    public var selectedRecord: AgentSessionRecord? {
        guard selectedIndex >= 0, selectedIndex < cachedDisplayRecords.count else { return nil }
        return cachedDisplayRecords[selectedIndex]
    }

    public var groupedRecords: [(title: String, records: [AgentSessionRecord])] {
        cachedGroupedRecords
    }
}
