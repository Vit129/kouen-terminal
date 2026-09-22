import Foundation
import KouenCore

/// Browser-style back/forward navigation through the order tab/session switches actually
/// happened in (MRU history) — distinct from `SessionLifecycleService.selectAdjacentSession`,
/// which cycles the current session list in list order. Hooked into the two funnels every
/// switch already goes through: `SessionCoordinator.selectSession`/`.selectTab`.
@MainActor
final class SessionHistoryNavigator {
    static let shared = SessionHistoryNavigator()

    struct HistoryEntry: Equatable {
        let workspaceID: WorkspaceID
        let sessionID: SessionID
        let tabID: TabID?
    }

    private(set) var backStack: [HistoryEntry] = []
    private(set) var forwardStack: [HistoryEntry] = []
    /// Re-entrancy guard: `goBack()`/`goForward()` call back into
    /// `SessionCoordinator.selectSession`/`.selectTab` to perform the actual switch, which would
    /// otherwise record that switch as a new navigation and wipe the stack it just popped from.
    private var isNavigating = false

    init() {}

    var canGoBack: Bool { !backStack.isEmpty }
    var canGoForward: Bool { !forwardStack.isEmpty }

    /// Call right before a switch actually happens, passing the entry that is *about to become*
    /// the previous one. A no-op while `goBack()`/`goForward()` itself is driving the switch.
    func recordIfNeeded(previous: HistoryEntry?) {
        guard !isNavigating, let previous else { return }
        backStack.append(previous)
        forwardStack.removeAll()
    }

    /// Pure stack step for a back navigation: pops `backStack`, pushes `current` onto
    /// `forwardStack`, returns the entry to navigate to (or nil if there's nothing to go back to,
    /// in which case nothing is mutated). Separated from `goBack()` so the stack mechanics are
    /// unit-testable without a live `SessionCoordinator`/daemon.
    func popForBack(current: HistoryEntry?) -> HistoryEntry? {
        guard let target = backStack.popLast() else { return nil }
        if let current { forwardStack.append(current) }
        return target
    }

    /// Pure counterpart of `popForBack(current:)` for a forward navigation.
    func popForForward(current: HistoryEntry?) -> HistoryEntry? {
        guard let target = forwardStack.popLast() else { return nil }
        if let current { backStack.append(current) }
        return target
    }

    func goBack() {
        let coord = SessionCoordinator.shared
        guard let target = popForBack(current: Self.currentEntry(from: coord)) else { return }
        perform(target, on: coord)
    }

    func goForward() {
        let coord = SessionCoordinator.shared
        guard let target = popForForward(current: Self.currentEntry(from: coord)) else { return }
        perform(target, on: coord)
    }

    private func perform(_ target: HistoryEntry, on coord: SessionCoordinator) {
        isNavigating = true
        if let tabID = target.tabID {
            coord.selectTab(workspaceID: target.workspaceID, tabID: tabID)
        } else {
            coord.selectSession(workspaceID: target.workspaceID, sessionID: target.sessionID)
        }
        isNavigating = false
    }

    /// The currently active workspace/session/tab, or nil if nothing is active yet (e.g. at
    /// launch before the daemon snapshot has populated).
    static func currentEntry(from coord: SessionCoordinator) -> HistoryEntry? {
        guard let workspace = coord.snapshot.activeWorkspace,
              let sessionID = workspace.activeSessionID
        else { return nil }
        return HistoryEntry(workspaceID: workspace.id, sessionID: sessionID, tabID: workspace.activeTabID)
    }
}
