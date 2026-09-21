import Foundation
import Observation
import KouenCore
import KouenIPC

/// One live tab, flattened out of the workspace/session tree for `FleetView`'s single
/// cross-session list. P46 Pillar 6 gap 6: today, seeing what six agents across six
/// worktrees are doing means clicking through six tabs one at a time — this is the one
/// screen that lists every session at once instead.
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

/// Pattern mirrors `AutomationsFleetModel` (`@Observable @MainActor`, list + text filter) — not
/// the file itself, since that one lists scheduled jobs and their run history, not live sessions.
@Observable @MainActor
public final class FleetViewModel {
    public var items: [FleetSessionItem] = []
    public var filterText: String = ""

    public init() {}

    public var filteredItems: [FleetSessionItem] {
        guard !filterText.isEmpty else { return items }
        let q = filterText.lowercased()
        return items.filter {
            $0.title.lowercased().contains(q)
                || $0.workspaceName.lowercased().contains(q)
                || $0.cwd.lowercased().contains(q)
                || ($0.agentName?.lowercased().contains(q) ?? false)
                || ($0.taskName?.lowercased().contains(q) ?? false)
                || ($0.gitBranch?.lowercased().contains(q) ?? false)
        }
    }

    public var waitingCount: Int { items.count { $0.isWaiting } }

    /// Rebuild the flat list from the current cross-workspace snapshot. Cheap enough (plain
    /// array walk + sort, no I/O) to call on every `snapshotChanged` notification, the same
    /// cadence `AgentSessionHistoryModel.refresh` and the Attention Beacon already run at.
    /// `activeSurfaceID` marks whichever row is the one currently being viewed (see
    /// `FleetSessionItem.isActive`) — pass `SessionCoordinator.shared.activeSurfaceID`.
    public func refresh(from snapshot: SessionSnapshot, activeSurfaceID: UUID? = nil) {
        items = snapshot.workspaces.flatMap { ws in
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
                        isActive: activeSurfaceID != nil && surfaceID == activeSurfaceID?.uuidString
                    )
                }
            }
        }
        .sorted { lhs, rhs in
            // Needs-attention first, matching the Attention Beacon's own priority — a human
            // scanning this list should see stuck agents before idle ones.
            if lhs.isWaiting != rhs.isWaiting { return lhs.isWaiting }
            if lhs.workspaceName != rhs.workspaceName { return lhs.workspaceName < rhs.workspaceName }
            if lhs.title != rhs.title { return lhs.title < rhs.title }
            return lhs.id < rhs.id // stable order for otherwise-identical rows (same title/cwd)
        }
    }
}
