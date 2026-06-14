import AppKit
import Foundation
import HarnessCore
import HarnessTerminalKit

/// Handles split pane creation, focus, killing, and pane-tree navigation.
@MainActor
final class SplitPaneCoordinator {
    private unowned let coord: SessionCoordinator

    init(coordinator: SessionCoordinator) {
        self.coord = coordinator
    }

    func splitActivePane(direction: SplitDirection) {
        guard let workspace = coord.snapshot.activeWorkspace,
              let tab = workspace.activeTab,
              let paneID = coord.activeSurfaceID.flatMap({ paneID(for: $0, in: tab.rootPane) })
                ?? tab.rootPane.allPaneIDs().last
        else { return }
        Task {
            await coord.requestDaemon(.newSplit(tabID: tab.id, paneID: paneID, direction: direction, shell: coord.settings.defaultShell))
            await coord.syncFromDaemon()
        }
    }

    func splitActivePaneAndRun(direction: SplitDirection, command: String) {
        guard let workspace = coord.snapshot.activeWorkspace,
              let tab = workspace.activeTab,
              let paneID = coord.activeSurfaceID.flatMap({ paneID(for: $0, in: tab.rootPane) })
                ?? tab.rootPane.allPaneIDs().last
        else { return }
        Task {
            guard case let .paneID(newPaneID)? = await coord.requestDaemon(.newSplit(
                tabID: tab.id,
                paneID: paneID,
                direction: direction,
                shell: coord.settings.defaultShell
            )) else {
                await coord.syncFromDaemon()
                return
            }
            await coord.syncFromDaemon()
            guard let activeTab = coord.snapshot.activeWorkspace?.activeTab,
                  let surfaceID = surfaceID(forPaneID: newPaneID, in: activeTab.rootPane)
            else { return }
            coord.setActiveSurface(surfaceID)
            coord.terminalHosts.host(for: surfaceID)?.focusTerminal()
            await coord.requestDaemon(.sendData(surfaceID: surfaceID.uuidString, data: Data((command + "\r").utf8)))
        }
    }

    func focusPaneDirectional(_ direction: DirectionalAxis) {
        guard let workspace = coord.snapshot.activeWorkspace,
              let tab = workspace.activeTab,
              let paneID = coord.activeSurfaceID.flatMap({ paneID(for: $0, in: tab.rootPane) })
                ?? tab.rootPane.allPaneIDs().last
        else { return }
        Task {
            if case let .surfaceID(raw)? = await coord.requestDaemon(.selectPaneDirectional(currentPaneID: paneID, direction: direction)),
               let surfaceID = UUID(uuidString: raw) {
                await coord.syncFromDaemon()
                coord.setActiveSurface(surfaceID)
                coord.terminalHosts.host(for: surfaceID)?.focusTerminal()
            } else {
                await coord.syncFromDaemon()
            }
        }
    }

    func splitPaneSurface(
        tabID: TabID,
        sourcePaneID: PaneID,
        surfaceID: SurfaceID,
        targetPaneID: PaneID,
        direction: SplitDirection,
        beforeTarget: Bool
    ) {
        coord.requestDaemon(.splitPaneSurface(
            tabID: tabID,
            sourcePaneID: sourcePaneID,
            surfaceID: surfaceID,
            targetPaneID: targetPaneID,
            direction: direction,
            beforeTarget: beforeTarget
        ))
        coord.syncFromDaemon()
    }

    func splitTab(workspaceID: WorkspaceID, tabID: TabID, direction: SplitDirection) {
        coord.selectTab(workspaceID: workspaceID, tabID: tabID)
        splitActivePane(direction: direction)
    }

    func splitSession(workspaceID: WorkspaceID, sessionID: SessionID, direction: SplitDirection) {
        coord.selectSession(workspaceID: workspaceID, sessionID: sessionID)
        splitActivePane(direction: direction)
    }

    func killActivePane() {
        guard let workspace = coord.snapshot.activeWorkspace,
              let tab = workspace.activeTab,
              let paneID = coord.activeSurfaceID.flatMap({ paneID(for: $0, in: tab.rootPane) })
                ?? tab.rootPane.allPaneIDs().last
        else { return }
        coord.requestDaemon(.killPane(paneID: paneID))
        coord.syncFromDaemon()
    }

    func killPane(paneID: PaneID) {
        coord.requestDaemon(.killPane(paneID: paneID))
        coord.syncFromDaemon()
    }

    // MARK: - Pane tree helpers

    func paneID(for surfaceID: SurfaceID, in node: PaneNode) -> PaneID? {
        switch node {
        case let .leaf(leaf) where leaf.surfaceIDs.contains(surfaceID):
            return leaf.id
        case let .branch(_, _, first, second):
            return paneID(for: surfaceID, in: first) ?? paneID(for: surfaceID, in: second)
        default:
            return nil
        }
    }

    func firstSurfaceID(forTab tabID: TabID) -> SurfaceID? {
        for workspace in coord.snapshot.workspaces {
            for session in workspace.sessions {
                if let tab = session.tabs.first(where: { $0.id == tabID }) {
                    return tab.rootPane.allSurfaceIDs().first
                }
            }
        }
        return nil
    }

    func surfaceID(forPaneID paneID: PaneID, in node: PaneNode) -> SurfaceID? {
        switch node {
        case let .leaf(leaf): return leaf.id == paneID ? leaf.surfaceID : nil
        case let .branch(_, _, first, second):
            return surfaceID(forPaneID: paneID, in: first) ?? surfaceID(forPaneID: paneID, in: second)
        }
    }

    func surfaceID(forPane paneID: PaneID, in node: PaneNode) -> SurfaceID? {
        switch node {
        case let .leaf(leaf) where leaf.id == paneID:
            return leaf.activeSurfaceID ?? leaf.surfaceID
        case let .branch(_, _, first, second):
            return surfaceID(forPane: paneID, in: first) ?? surfaceID(forPane: paneID, in: second)
        default:
            return nil
        }
    }
}
