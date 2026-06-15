import Foundation

/// A single Kanban-style card representing one live session/tab in the board.
///
/// `BoardCard` is a read-only projection over `SessionSnapshot` — it carries no
/// state of its own and is recomputed each time `BoardModel.classify(snapshot:)`
/// runs. See `agent-memory/plans/p16-task-board.md` for the column model.
public struct BoardCard: Codable, Sendable, Equatable, Identifiable {
    public var id: TabID
    public var workspaceID: WorkspaceID
    public var sessionID: SessionID
    public var tabID: TabID
    public var paneID: PaneID?
    public var title: String
    public var cwd: String
    public var gitBranch: String?
    public var currentCommand: String?
    public var exitStatus: Int?
    public var agentKind: AgentKind?
    public var agentActivity: AgentActivity?
    public var column: BoardColumnKind

    public init(
        workspaceID: WorkspaceID,
        sessionID: SessionID,
        tabID: TabID,
        paneID: PaneID?,
        title: String,
        cwd: String,
        gitBranch: String?,
        currentCommand: String?,
        exitStatus: Int?,
        agentKind: AgentKind?,
        agentActivity: AgentActivity?,
        column: BoardColumnKind
    ) {
        self.id = tabID
        self.workspaceID = workspaceID
        self.sessionID = sessionID
        self.tabID = tabID
        self.paneID = paneID
        self.title = title
        self.cwd = cwd
        self.gitBranch = gitBranch
        self.currentCommand = currentCommand
        self.exitStatus = exitStatus
        self.agentKind = agentKind
        self.agentActivity = agentActivity
        self.column = column
    }
}

/// Column identity for a `BoardCard`. Ordering here is the canonical display
/// order used by all consumers (GUI, CLI, scripting, MCP).
public enum BoardColumnKind: String, Codable, Sendable, CaseIterable {
    case needsAttention
    case running
    case idle
    case done
    case error

    public var displayName: String {
        switch self {
        case .needsAttention: return "Needs Attention"
        case .running: return "Running"
        case .idle: return "Idle"
        case .done: return "Done"
        case .error: return "Error"
        }
    }
}

/// A column of cards. `BoardModel.classify` always returns one `BoardColumn`
/// per `BoardColumnKind` case, in `BoardColumnKind.allCases` order, even when
/// empty — so consumers can render a stable set of columns.
public struct BoardColumn: Codable, Sendable, Equatable {
    public var kind: BoardColumnKind
    public var cards: [BoardCard]

    public init(kind: BoardColumnKind, cards: [BoardCard]) {
        self.kind = kind
        self.cards = cards
    }

    public var name: String { kind.displayName }
}

/// Shared, pure classification of live session/tab state into Kanban-style
/// board columns. Used by the GUI sidebar board tab, `harness board` CLI,
/// `harness.board.list()` scripting, and the `harnessBoard` MCP tool — all four
/// consumers call `classify(snapshot:)` so column assignment never diverges.
///
/// Column precedence (a tab can only land in one column):
/// 1. **Needs Attention** — `agent.activity == .awaiting` (agent is waiting on
///    the user). Takes precedence over the process-exit-status classification
///    below, since an agent waiting for input is the most actionable state.
/// 2. **Error** — `tab.exitStatus != 0`.
/// 3. **Done** — `tab.exitStatus == 0`.
/// 4. **Running** — `tab.currentCommand` is set and is not a known interactive
///    shell name (mirrors the Session State Dot in `SidebarSessionRows`).
/// 5. **Idle** — everything else (shell idle, no foreground process).
public enum BoardModel {
    /// Interactive shell names that don't count as a "running" foreground
    /// command — mirrors the Session State Dot classification in
    /// `SidebarSessionRows.swift`.
    public static let shellNames: Set<String> = ["zsh", "bash", "sh", "fish", "csh", "tcsh", "login"]

    public static func classify(snapshot: SessionSnapshot) -> [BoardColumn] {
        var cardsByColumn: [BoardColumnKind: [BoardCard]] = [:]

        for workspace in snapshot.workspaces {
            for session in workspace.sessions {
                for tab in session.tabs {
                    let column = columnKind(for: tab)
                    let card = BoardCard(
                        workspaceID: workspace.id,
                        sessionID: session.id,
                        tabID: tab.id,
                        paneID: tab.activePaneID,
                        title: tab.title,
                        cwd: tab.cwd,
                        gitBranch: tab.gitBranch,
                        currentCommand: tab.currentCommand,
                        exitStatus: tab.exitStatus,
                        agentKind: tab.agent?.kind,
                        agentActivity: tab.agent?.activity,
                        column: column
                    )
                    cardsByColumn[column, default: []].append(card)
                }
            }
        }

        return BoardColumnKind.allCases.map { kind in
            BoardColumn(kind: kind, cards: cardsByColumn[kind] ?? [])
        }
    }

    public static func columnKind(for tab: Tab) -> BoardColumnKind {
        if tab.agent?.activity == .awaiting {
            return .needsAttention
        }
        if let exitStatus = tab.exitStatus {
            return exitStatus == 0 ? .done : .error
        }
        if let cmd = tab.currentCommand, !cmd.isEmpty, !shellNames.contains(cmd.lowercased()) {
            return .running
        }
        return .idle
    }
}
