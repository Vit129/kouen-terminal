import Foundation
import HarnessCore
import HarnessTerminalEngine

/// Request handlers that `handle(_:)` calls with `lock` held.
extension SurfaceRegistry {
    func newSplitLocked(tabID: UUID, paneID: UUID?, direction: SplitDirection, shell: String?, requestedCwd: String?) -> IPCResponse {
        guard let workspace = editor.snapshot.workspaces.first(where: { ws in
            ws.sessions.contains { session in session.tabs.contains { $0.id == tabID } }
        }) else { return .error("Tab not found") }
        let tab = workspace.sessions.flatMap { $0.tabs }.first { $0.id == tabID }
        // Target-less split focuses the tab's active pane (falling back to its
        // first leaf), matching tmux's "split the current pane".
        let targetPane = paneID ?? tab?.activePaneID ?? tab?.rootPane.allPaneIDs().first
        guard let paneID = targetPane,
              let newPaneID = editor.splitPane(
                  in: workspace.id,
                  tabID: tabID,
                  paneID: paneID,
                  direction: direction
              )
        else { return .error("Could not split pane") }
        if let surfaceID = editor.surfaceID(forPaneID: newPaneID) {
            let cwd = requestedCwd ?? editor.snapshot.workspaces
                .flatMap { workspace in workspace.sessions.flatMap { $0.tabs } }
                .first(where: { $0.id == tabID })?
                .cwd
            _ = createOrEnsureSurface(
                surfaceID: surfaceID.uuidString,
                cwd: cwd,
                shell: shell,
                rows: 24,
                cols: 80,
                scrollbackBytes: nil,
                freshlyCreated: true
            )
        }
        commit()
        fireHookLocked(.afterSplitPane, surfaceKey: editor.surfaceID(forPaneID: newPaneID)?.uuidString)
        return .paneID(newPaneID)
    }

    func pipePaneLocked(surfaceID: String, shellCommand: String?) -> IPCResponse {
        guard sessions[surfaceID] != nil else { return .error("Surface not found") }
        if let shellCommand, !shellCommand.isEmpty {
            if let error = startPipe(surfaceID: surfaceID, shellCommand: shellCommand) { return .error(error) }
        } else {
            guard !pipeChanges.contains(surfaceID) else { return .error("The pipe is being launched; retry after it finishes.") }
            stopPipe(surfaceID: surfaceID)
        }
        return .ok
    }

    func unlinkWindowLocked(tabID: UUID) -> IPCResponse {
        let removed = editor.snapshot.workspaces
            .flatMap { $0.sessions }.flatMap { $0.tabs }
            .first(where: { $0.id == tabID })?
            .rootPane.allSurfaceIDs().map(\.uuidString) ?? []
        guard editor.unlinkWindow(tabID) else { return .error("Window is not linked") }
        closeSurfaces(removed)   // ref-counted: shared surfaces survive
        commit()
        fireHookLocked(.windowUnlinked)
        return .ok
    }

    func killPaneLocked(paneID: UUID) -> IPCResponse {
        let killedSurfaceID = editor.surfaceID(forPaneID: paneID)?.uuidString
        let closingSession = editor.snapshot.workspaces.flatMap(\.sessions)
            .first { $0.tabs.contains { $0.rootPane.allPaneIDs().contains(paneID) } }
        let closingTab = closingSession?.tabs.first { $0.rootPane.allPaneIDs().contains(paneID) }
        let leaf = closingTab?.rootPane.allLeaves().first { $0.id == paneID }
        guard editor.killPane(paneID) else { return .error("Pane not found") }
        if let closingSession, let closingTab, let leaf {
            let tab = Tab(title: closingTab.title, cwd: leaf.cwd ?? closingTab.cwd, rootPane: .leaf(leaf))
            recordClosed(.pane, sessionID: closingSession.id, name: closingTab.title, tabs: [tab])
        }
        if let killedSurfaceID { closeSurfaces([killedSurfaceID]) }
        commit()
        fireHookLocked(.afterKillPane, surfaceKey: killedSurfaceID)
        return .ok
    }

    func resizePaneRatioLocked(tabID: UUID, firstPaneID: UUID, secondPaneID: UUID, ratio: Double) -> IPCResponse {
        guard editor.setSplitRatio(
            tabID: tabID,
            firstPaneID: firstPaneID,
            secondPaneID: secondPaneID,
            ratio: ratio
        ) else {
            return .error("Split not found")
        }
        commit()
        fireHookLocked(.afterResizePane)
        return .ok
    }

    func selectPaneDirectionalLocked(currentPaneID: UUID, direction: DirectionalAxis) -> IPCResponse {
        let target: Command.PaneTarget
        switch direction {
        case .left: target = .left
        case .right: target = .right
        case .up: target = .up
        case .down: target = .down
        }
        guard let neighbor = editor.directionalNeighbor(of: currentPaneID, direction: target) else {
            return .error("No neighbor in that direction")
        }
        // Persist the new focus server-side so every client agrees on the active
        // pane (not just the caller). Best-effort: the neighbor is in the same tab.
        if let loc = editor.tab(containingPaneID: neighbor) {
            let previousFocus = activeSurfaceKeyLocked(workspaceID: loc.workspaceID, tabID: loc.tabID)
            _ = editor.setActivePane(workspaceID: loc.workspaceID, tabID: loc.tabID, paneID: neighbor)
            commit()
            firePaneFocusChangeLocked(previousSurfaceKey: previousFocus, newPaneID: neighbor)
        }
        return .paneID(neighbor)
    }

    func selectPaneLocked(tabID: UUID, paneID: UUID) -> IPCResponse {
        guard let loc = editor.tab(containingPaneID: paneID), loc.tabID == tabID else {
            return .error("Pane not found in tab")
        }
        let previousFocus = activeSurfaceKeyLocked(workspaceID: loc.workspaceID, tabID: tabID)
        guard editor.setActivePane(workspaceID: loc.workspaceID, tabID: tabID, paneID: paneID) else {
            return .error("Could not select pane")
        }
        commit()
        firePaneFocusChangeLocked(previousSurfaceKey: previousFocus, newPaneID: paneID)
        return .ok
    }

    func applyLayoutLocked(tabID: UUID, layout: String, mainPaneID: UUID?) -> IPCResponse {
        guard let template = LayoutTemplate(rawValue: layout) else {
            return .error("Unknown layout: \(layout)")
        }
        guard editor.applyLayout(tabID: tabID, layout: template, mainPaneID: mainPaneID) else {
            return .error("Tab not found or has fewer than 2 panes")
        }
        commit()
        fireHookLocked(.windowLayoutChanged)
        return .ok
    }

    func nextLayoutLocked(tabID: UUID) -> IPCResponse {
        // No per-tab "last layout" memory yet (lands in Phase 6 with the
        // option store); we cycle from `evenHorizontal` each call. That's
        // already a useful "give me a different layout" gesture.
        guard editor.applyLayout(tabID: tabID, layout: .evenHorizontal.next(), mainPaneID: nil) else {
            return .error("Tab not found")
        }
        commit()
        fireHookLocked(.windowLayoutChanged)
        return .ok
    }

    func respawnPaneLocked(surfaceID: String, keepHistory: Bool) -> IPCResponse {
        // Last-known tab cwd as the fallback: after a natural shell exit there is no
        // live PID left to probe, and respawning into $HOME instead of where the user
        // was working would lose their place.
        let surfaceTab = editor.tab(forSurfaceKey: surfaceID)
        var fallbackCwd: String?
        if let match = surfaceTab {
            fallbackCwd = editor.snapshot.workspaces
                .first(where: { $0.id == match.workspaceID })?
                .sessions.flatMap { $0.tabs }
                .first(where: { $0.id == match.tabID })?
                .cwd
        }
        if let session = sessions[surfaceID] {
            session.respawn(clearHistory: !keepHistory, fallbackCwd: fallbackCwd)
            return .ok
        }
        // A naturally-exited `remain-on-exit` pane keeps its dead leaf in the layout, but its
        // SessionPty was dropped from `sessions` on exit — so respawn-pane (whose entire purpose is
        // reviving such a pane) must recreate the surface rather than fail "Surface not found".
        // Only when the dead leaf still resolves; an unknown surface is a real error.
        guard surfaceTab != nil else { return .error("Surface not found") }
        let scrollbackURL = HarnessPaths.scrollbackFileURL(forSurfaceID: surfaceID)
        var reviveScrollbackBytes: Int?
        if keepHistory {
            // Size the revived scrollback cap to at least the on-disk history (and the usual
            // default floor) so reviving never TRIMS scrollback a normal reattach would keep:
            // createOrEnsureSurface's nil default (1 MiB) would otherwise compact a larger
            // persisted log on load. The live-respawn path above keeps the original cap; this
            // is the dead-pane equivalent.
            let onDisk = (try? FileManager.default.attributesOfItem(atPath: scrollbackURL.path)[.size]) as? Int ?? 0
            reviveScrollbackBytes = onDisk > 0 ? max(onDisk, 1024 * 1024) : nil
        } else {
            // Honor `-k`: drop the persisted scrollback before the revived surface seeds its ring
            // from disk, so it starts clean. The SessionPty that normally owns this file is gone, so
            // delete it directly; the default cap is fine on a now-empty history.
            try? FileManager.default.removeItem(at: scrollbackURL)
            try? FileManager.default.removeItem(at: scrollbackURL.appendingPathExtension("sizes"))
        }
        let revived = createOrEnsureSurface(
            surfaceID: surfaceID, cwd: fallbackCwd, shell: nil, rows: 24, cols: 80, scrollbackBytes: reviveScrollbackBytes
        )
        guard revived != nil else {
            return .error("Could not respawn surface")
        }
        return .ok
    }
}
