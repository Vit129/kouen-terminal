import AppKit
import Combine
import KouenCore
import KouenIPC
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
    /// Match locations extracted during search scoring, keyed by session id.
    private var searchMatchLocations: [String: AgentSessionRecord.MatchLocationInfo] = [:]
    /// Set of session IDs that were matched via semantic search fallback.
    private var semanticMatchIDs: Set<String> = []

    /// Repo root resolver injected for testing or production.
    public var repoRootResolver: @Sendable (String) -> String?
    /// Active CWD provider injected for testing or production.
    public var activeCWDProvider: @Sendable () -> String

    /// Memoized repo root cache keyed by projectPath.
    private var repoRootCache: [String: String] = [:]

    private var filterTask: Task<Void, Never>?
    private var updateCancellable: AnyCancellable?

    private let loadMoreBatchSize = 20
    private var minimumWindowStart: Date {
        Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? .distantPast
    }

    public init(
        repoRootResolver: @escaping @Sendable (String) -> String? = { WorktreeManager().repoRoot(for: $0) },
        activeCWDProvider: (@Sendable () -> String)? = nil
    ) {
        self.repoRootResolver = repoRootResolver
        if let activeCWDProvider {
            self.activeCWDProvider = activeCWDProvider
        } else {
            self.activeCWDProvider = {
                MainActor.assumeIsolated {
                    SessionCoordinator.shared.snapshot.activeWorkspace?.activeTab?.cwd ?? ""
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

    public var availableAgentKinds: [AgentKind] {
        let distinct = Set(records.map(\.agentKind))
        let canonical: [AgentKind] = [.claudeCode, .codex, .copilot, .antigravity]
        var result = canonical.filter { distinct.contains($0) }
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

        let windowed = Self.groupCrossRepoTasks(rawWindowed)
        cachedWindowedRecords = windowed

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
        let state = historySignposter.beginInterval("applyFilterNow")
        let (filtered, newCache, snippets, matchLocations, semanticIDs) = Self.computeFiltered(
            query: searchQuery,
            scope: selectedScope,
            selectedAgents: selectedAgents,
            records: records,
            activeCWD: activeCWDProvider(),
            resolver: repoRootResolver,
            initialCache: repoRootCache
        )
        historySignposter.endInterval("applyFilterNow", state)
        self.repoRootCache = newCache
        self.searchSnippets = snippets
        self.searchMatchLocations = matchLocations
        self.semanticMatchIDs = semanticIDs
        self.filteredRecords = filtered
    }

    /// Schedules an asynchronous recomputation of filteredRecords.
    /// Debounced ~50ms for query typing; stale search tasks are cancelled immediately.
    public func scheduleFilter(debounceMs: UInt64 = 50) {
        filterTask?.cancel()

        let currentQuery = searchQuery
        let currentScope = selectedScope
        let currentAgents = selectedAgents
        let currentRecords = records
        let activeCWD = activeCWDProvider()
        let resolver = repoRootResolver

        let localCache = repoRootCache

        filterTask = Task.detached(priority: .userInitiated) { [weak self] in
            if debounceMs > 0 {
                try? await Task.sleep(nanoseconds: debounceMs * 1_000_000)
            }
            if Task.isCancelled { return }

            let state = historySignposter.beginInterval("computeFiltered")
            let (filtered, newCache, snippets, matchLocations, semanticIDs) = Self.computeFiltered(
                query: currentQuery,
                scope: currentScope,
                selectedAgents: currentAgents,
                records: currentRecords,
                activeCWD: activeCWD,
                resolver: resolver,
                initialCache: localCache
            )
            historySignposter.endInterval("computeFiltered", state)

            if Task.isCancelled { return }

            await MainActor.run { [weak self] in
                guard let self, !Task.isCancelled else { return }
                self.repoRootCache = newCache
                self.searchSnippets = snippets
                self.searchMatchLocations = matchLocations
                self.semanticMatchIDs = semanticIDs
                self.filteredRecords = filtered
            }
        }
    }

    nonisolated package static func computeFiltered(
        query: String,
        scope: HistoryScope,
        selectedAgents: Set<AgentKind> = [],
        records: [AgentSessionRecord],
        activeCWD: String,
        resolver: @Sendable (String) -> String?,
        initialCache: [String: String]
    ) -> (
        filtered: [AgentSessionRecord],
        cache: [String: String],
        snippets: [String: String],
        matchLocations: [String: AgentSessionRecord.MatchLocationInfo],
        semanticMatchIDs: Set<String>
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

        let matcher = SearchMatcher(query: query)

        // 1. When search query is active, ignore scope entirely and search all records using ranked search
        if matcher.hasQuery {
            let hits = AgentHistorySearch.rank(query: query, records: baseRecords)
            var snippets: [String: String] = [:]
            var matchLocations: [String: AgentSessionRecord.MatchLocationInfo] = [:]
            var semanticMatchIDs = Set<String>()

            for hit in hits {
                if let loc = hit.matchLocation {
                    matchLocations[hit.record.id] = loc
                }
                if hit.isSemanticMatch {
                    semanticMatchIDs.insert(hit.record.id)
                }
            }

            // Pre-extract snippets on the background thread for top visible results so UI render doesn't block MainActor
            for hit in hits.prefix(50) {
                if let snip = hit.snippet, !snip.isEmpty {
                    snippets[hit.record.id] = snip
                } else {
                    let turnsContent = hit.record.latestTurns.map(\.content).joined(separator: "\n")
                    let chatContent = "\(hit.record.firstPrompt)\n\(turnsContent)"
                    let branchFiles = hit.record.gitBranch ?? ""
                    let repoAgent = "\(hit.record.projectName) \(hit.record.agentKind.displayName)"
                    if let match = matcher.matchHistory(
                        title: hit.record.title,
                        branchFilesTools: branchFiles,
                        repoAgent: repoAgent,
                        chatContent: chatContent
                    ), let snippet = match.snippet {
                        snippets[hit.record.id] = snippet
                    }
                }
            }
            return (hits.map(\.record), cache, snippets, matchLocations, semanticMatchIDs)
        }

        // 2. When search query is empty, apply the selected scope with cached repo roots
        let activeRepoRoot = resolveRoot(for: activeCWD)

        let filtered = baseRecords.filter { record in
            switch scope {
            case .repo:
                guard !activeRepoRoot.isEmpty else { return true }
                if record.projectPath == activeRepoRoot ||
                   record.projectPath.hasPrefix(activeRepoRoot + "/") {
                    return true
                }
                let recordRepoRoot = resolveRoot(for: record.projectPath)
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
        return (filtered, cache, [:], [:], [])
    }

    /// Match location info (e.g. "late in session · turn 42/50") for active query (O(1) dictionary read).
    public func matchLocation(for record: AgentSessionRecord) -> AgentSessionRecord.MatchLocationInfo? {
        searchMatchLocations[record.id] ?? (searchQuery.isEmpty ? nil : record.matchLocation(for: searchQuery))
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
        let branchFiles = record.gitBranch ?? ""
        let repoAgent = "\(record.projectName) \(record.agentKind.displayName)"

        let match = matcher.matchHistory(
            title: record.title,
            branchFilesTools: branchFiles,
            repoAgent: repoAgent,
            chatContent: chatContent
        )
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
