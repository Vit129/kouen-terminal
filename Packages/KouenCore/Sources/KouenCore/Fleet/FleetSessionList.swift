import Foundation
import KouenIPC

/// One live tab, flattened out of the workspace/session tree for `FleetView`'s single
/// cross-session list. P46 Pillar 6 gap 6: today, seeing what six agents across six
/// worktrees are doing means clicking through six tabs one at a time — this is the one
/// screen that lists every session at once instead.
///
/// Lives in the headless core (not the UI layer) because it is plain data: the view only
/// renders it. See `FleetSessionList` for the flatten/sort/filter logic itself.
public struct FleetSessionItem: Identifiable, Sendable, Equatable {
    public let id: String // surfaceID (falls back to tabID for a tab with no root surface yet)
    public let tabID: String
    public let workspaceID: UUID
    public let workspaceName: String
    public let title: String
    public let agentName: String?
    public let status: TabStatus
    public let activity: String?
    public let cwd: String
    public let gitBranch: String?
    public let taskName: String?
    public let notificationText: String?
    /// True for the surface the user is looking at right now — two blank shell tabs opened in
    /// the same session/cwd otherwise render identically, so this is the only way to tell them
    /// apart (and to explain why clicking the one you're already on shows no visible change).
    public let isActive: Bool

    public var isWaiting: Bool { status == .waiting }
    /// Short, stable disambiguator shown in the row — the same 8-char prefix convention every
    /// `kouen` CLI listing already uses for a surface/tab id.
    public var shortID: String { String(id.prefix(8)) }
}

/// The Projects-tab chip selection (`All / Agents / Waiting`). `rawValue` doubles as the chip
/// label; the predicate it maps to is pure and lives in `FleetSessionList`.
public enum ProjectTabFilter: String, CaseIterable, Identifiable, Sendable {
    case all = "All"
    case agents = "Agents"
    case waiting = "Waiting"
    public var id: String { rawValue }
}

/// Pure flatten / sort / filter behind `FleetView` — no I/O, no UI, no state, so it can be
/// unit-tested without a window and reasoned about (and measured) on its own.
///
/// Memory investigation (Nov 2026): this used to live inside `FleetViewModel` in the UI layer
/// and was rebuilt on every `snapshotChanged`. Keeping the computation here lets the UI model
/// compare results and skip republishing when nothing changed.
public enum FleetSessionList {
    /// Flatten the cross-workspace snapshot into one list, needs-attention first.
    ///
    /// `activeSurfaceID` marks whichever row is the one currently being viewed (see
    /// `FleetSessionItem.isActive`) — pass `SessionCoordinator.shared.activeSurfaceID`.
    public static func flatten(_ snapshot: SessionSnapshot, activeSurfaceID: UUID? = nil) -> [FleetSessionItem] {
        let activeSurface = activeSurfaceID?.uuidString
        return snapshot.workspaces.flatMap { ws in
            ws.sessions.flatMap { session in
                session.tabs.map { tab -> FleetSessionItem in
                    let surfaceID = tab.rootPane.allSurfaceIDs().first?.uuidString ?? tab.id.uuidString
                    return FleetSessionItem(
                        id: surfaceID,
                        tabID: tab.id.uuidString,
                        workspaceID: ws.id,
                        workspaceName: ws.name,
                        title: tab.title,
                        agentName: tab.agent?.kind.displayName,
                        status: tab.status,
                        activity: tab.agent?.activity.rawValue,
                        cwd: tab.cwd,
                        gitBranch: tab.gitBranch,
                        taskName: tab.taskName,
                        notificationText: tab.notificationText,
                        isActive: activeSurface != nil && surfaceID == activeSurface
                    )
                }
            }
        }
        .sorted(by: ordered)
    }

    /// Needs-attention first, matching the Attention Beacon's own priority — a human scanning
    /// this list should see stuck agents before idle ones.
    public static func ordered(_ lhs: FleetSessionItem, _ rhs: FleetSessionItem) -> Bool {
        if lhs.isWaiting != rhs.isWaiting { return lhs.isWaiting }
        if lhs.workspaceName != rhs.workspaceName { return lhs.workspaceName < rhs.workspaceName }
        if lhs.title != rhs.title { return lhs.title < rhs.title }
        return lhs.id < rhs.id // stable order for otherwise-identical rows (same title/cwd)
    }

    /// Free-text filter over the rows a user can actually see (title/cwd/agent/task/branch).
    public static func filter(_ items: [FleetSessionItem], text: String) -> [FleetSessionItem] {
        guard !text.isEmpty else { return items }
        let q = text.lowercased()
        return items.filter {
            $0.title.lowercased().contains(q)
                || $0.workspaceName.lowercased().contains(q)
                || $0.cwd.lowercased().contains(q)
                || ($0.agentName?.lowercased().contains(q) ?? false)
                || ($0.taskName?.lowercased().contains(q) ?? false)
                || ($0.gitBranch?.lowercased().contains(q) ?? false)
        }
    }

    /// Chip filter for the Projects tab.
    public static func filtered(_ items: [FleetSessionItem], by filter: ProjectTabFilter) -> [FleetSessionItem] {
        switch filter {
        case .all:
            return items
        case .agents:
            return items.filter { $0.agentName != nil }
        case .waiting:
            return items.filter { $0.isWaiting }
        }
    }
}
