import Foundation

public struct WorkbenchContext: Codable, Sendable, Equatable {
    public enum Source: String, Codable, Sendable {
        case focusedSurface
        case focusedPane
        case activePane
        case activeTab
    }

    public var source: Source
    public var workspaceID: WorkspaceID
    public var sessionID: SessionID
    public var tabID: TabID
    public var paneID: PaneID?
    public var surfaceID: SurfaceID?
    public var cwd: String
    public var tabCWD: String
    public var currentFilePath: String?
    public var gitBranch: String?
    public var currentCommand: String?

    public init(
        source: Source,
        workspaceID: WorkspaceID,
        sessionID: SessionID,
        tabID: TabID,
        paneID: PaneID?,
        surfaceID: SurfaceID?,
        cwd: String,
        tabCWD: String,
        currentFilePath: String? = nil,
        gitBranch: String? = nil,
        currentCommand: String? = nil
    ) {
        self.source = source
        self.workspaceID = workspaceID
        self.sessionID = sessionID
        self.tabID = tabID
        self.paneID = paneID
        self.surfaceID = surfaceID
        self.cwd = cwd
        self.tabCWD = tabCWD
        self.currentFilePath = currentFilePath
        self.gitBranch = gitBranch
        self.currentCommand = currentCommand
    }
}

public enum WorkbenchContextResolver {
    public static func resolve(
        snapshot: SessionSnapshot,
        focusedSurfaceID: SurfaceID? = nil,
        focusedPaneID: PaneID? = nil,
        currentFilePath: String? = nil
    ) -> WorkbenchContext? {
        let cleanFile = cleanPath(currentFilePath)

        if let focusedSurfaceID,
           let context = locateSurface(focusedSurfaceID, in: snapshot, currentFilePath: cleanFile) {
            return context
        }

        if let focusedPaneID,
           let context = locatePane(focusedPaneID, in: snapshot, currentFilePath: cleanFile, source: .focusedPane) {
            return context
        }

        guard let workspace = snapshot.activeWorkspace,
              let session = workspace.activeSession,
              let tab = session.activeTab
        else {
            return nil
        }

        if let activePaneID = tab.activePaneID,
           let leaf = leaf(paneID: activePaneID, in: tab.rootPane) {
            return context(
                source: .activePane,
                workspace: workspace,
                session: session,
                tab: tab,
                leaf: leaf,
                preferredSurfaceID: leaf.activeSurfaceID ?? leaf.surfaceID,
                currentFilePath: cleanFile
            )
        }

        return WorkbenchContext(
            source: .activeTab,
            workspaceID: workspace.id,
            sessionID: session.id,
            tabID: tab.id,
            paneID: nil,
            surfaceID: nil,
            cwd: tab.cwd,
            tabCWD: tab.cwd,
            currentFilePath: cleanFile,
            gitBranch: tab.gitBranch,
            currentCommand: tab.currentCommand
        )
    }

    private static func locateSurface(
        _ surfaceID: SurfaceID,
        in snapshot: SessionSnapshot,
        currentFilePath: String?
    ) -> WorkbenchContext? {
        for workspace in snapshot.workspaces {
            for session in workspace.sessions {
                for tab in session.tabs {
                    guard let leaf = leaf(surfaceID: surfaceID, in: tab.rootPane) else { continue }
                    return context(
                        source: .focusedSurface,
                        workspace: workspace,
                        session: session,
                        tab: tab,
                        leaf: leaf,
                        preferredSurfaceID: surfaceID,
                        currentFilePath: currentFilePath
                    )
                }
            }
        }
        return nil
    }

    private static func locatePane(
        _ paneID: PaneID,
        in snapshot: SessionSnapshot,
        currentFilePath: String?,
        source: WorkbenchContext.Source
    ) -> WorkbenchContext? {
        for workspace in snapshot.workspaces {
            for session in workspace.sessions {
                for tab in session.tabs {
                    guard let leaf = leaf(paneID: paneID, in: tab.rootPane) else { continue }
                    return context(
                        source: source,
                        workspace: workspace,
                        session: session,
                        tab: tab,
                        leaf: leaf,
                        preferredSurfaceID: leaf.activeSurfaceID ?? leaf.surfaceID,
                        currentFilePath: currentFilePath
                    )
                }
            }
        }
        return nil
    }

    private static func context(
        source: WorkbenchContext.Source,
        workspace: Workspace,
        session: SessionGroup,
        tab: Tab,
        leaf: PaneLeaf,
        preferredSurfaceID: SurfaceID?,
        currentFilePath: String?
    ) -> WorkbenchContext {
        let surfaceID = preferredSurfaceID ?? leaf.activeSurfaceID ?? leaf.surfaceID
        let surface = leaf.surfaces.first { $0.id == surfaceID }
        let cwd = nonEmpty(surface?.cwd) ?? tab.cwd
        return WorkbenchContext(
            source: source,
            workspaceID: workspace.id,
            sessionID: session.id,
            tabID: tab.id,
            paneID: leaf.id,
            surfaceID: surfaceID,
            cwd: cwd,
            tabCWD: tab.cwd,
            currentFilePath: currentFilePath,
            gitBranch: tab.gitBranch,
            currentCommand: tab.currentCommand
        )
    }

    private static func leaf(surfaceID: SurfaceID, in node: PaneNode) -> PaneLeaf? {
        switch node {
        case let .leaf(leaf):
            return leaf.surfaceIDs.contains(surfaceID) ? leaf : nil
        case .browser:
            return nil
        case let .branch(_, _, first, second):
            return leaf(surfaceID: surfaceID, in: first) ?? leaf(surfaceID: surfaceID, in: second)
        }
    }

    private static func leaf(paneID: PaneID, in node: PaneNode) -> PaneLeaf? {
        switch node {
        case let .leaf(leaf):
            return leaf.id == paneID ? leaf : nil
        case .browser:
            return nil
        case let .branch(_, _, first, second):
            return leaf(paneID: paneID, in: first) ?? leaf(paneID: paneID, in: second)
        }
    }

    private static func cleanPath(_ value: String?) -> String? {
        guard let value = value?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else {
            return nil
        }
        return value
    }

    private static func nonEmpty(_ value: String?) -> String? {
        guard let value, !value.isEmpty else { return nil }
        return value
    }
}
