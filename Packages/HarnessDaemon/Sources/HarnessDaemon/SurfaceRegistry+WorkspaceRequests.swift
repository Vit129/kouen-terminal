import Foundation
import HarnessCore
import HarnessTerminalEngine

/// Request handlers that `handle(_:)` calls with `lock` held.
extension SurfaceRegistry {
    func newSessionLocked(workspaceID: UUID, cwd: String?, name: String?, shell: String?) -> IPCResponse {
        guard let sessionID = editor.addSession(to: workspaceID, cwd: cwd, name: name) else {
            return .error("Workspace not found")
        }
        ensureSessionSurfaces(sessionID: sessionID, shell: shell)
        commit()
        fireHookLocked(.afterNewSession)
        fireHookLocked(.sessionCreated)
        return .sessionID(sessionID)
    }

    func newSessionInGroupLocked(targetSessionID: UUID, name: String?) -> IPCResponse {
        guard let sessionID = editor.addGroupedSession(groupWith: targetSessionID, name: name) else {
            return .error("Target session not found")
        }
        // Linked windows share live surfaces — ensure is an idempotent no-op for
        // them and a revival for any dead leaf.
        ensureSessionSurfaces(sessionID: sessionID, shell: nil)
        commit()
        fireHookLocked(.afterNewSession)
        fireHookLocked(.sessionCreated)
        return .sessionID(sessionID)
    }

    func newTabInSessionLocked(sessionID: SessionID, cwd: String) -> IPCResponse {
        guard let workspace = editor.snapshot.workspaces.first(where: { $0.sessions.contains(where: { $0.id == sessionID }) }) else { return .error("The source session has closed.") }
        _ = editor.selectSession(workspaceID: workspace.id, sessionID: sessionID)
        guard let tabID = editor.addTab(to: workspace.id, cwd: cwd) else { return .error("Could not create tab") }
        ensureTabSurfaces(tabID: tabID, shell: nil)
        editor.propagateNewTabToGroup(tabID)
        commit()
        fireHookLocked(.afterNewTab)
        return .tabID(tabID)
    }

    func newTabLocked(workspaceID: UUID, cwd: String?, shell: String?) -> IPCResponse {
        guard let tabID = editor.addTab(to: workspaceID, cwd: cwd) else {
            return .error("Workspace not found")
        }
        ensureTabSurfaces(tabID: tabID, shell: shell)
        editor.propagateNewTabToGroup(tabID)   // grouped sessions share the window list
        commit()
        fireHookLocked(.afterNewTab)
        emitFirstPaneCreated(tabID: tabID)
        return .tabID(tabID)
    }

    func newTabInWorkspaceLocked(named: String, cwd: String?, shell: String?) -> IPCResponse {
        guard let workspaceID = editor.resolveWorkspaceID(nameOrID: named) else {
            return .error("Workspace not found: \(named)")
        }
        guard let tabID = editor.addTab(to: workspaceID, cwd: cwd) else {
            return .error("Could not create tab")
        }
        ensureTabSurfaces(tabID: tabID, shell: shell)
        editor.propagateNewTabToGroup(tabID)
        commit()
        fireHookLocked(.afterNewTab)
        return .tabID(tabID)
    }

    func selectTabLocked(workspaceID: UUID, tabID: UUID) -> IPCResponse {
        guard editor.selectTab(workspaceID: workspaceID, tabID: tabID) else {
            return .error("Tab not found")
        }
        commit()
        if let event = FollowHookBridge.event(hook: "tab-selected", context: Self.followContext(buildFormatContext())) {
            emitFollow(event)
        }
        return .ok
    }

    func moveTabLocked(tabID: UUID, toSessionID: UUID?, index: Int?) -> IPCResponse {
        let source = editor.snapshot.workspaces.flatMap(\.sessions).first { $0.tabs.contains { $0.id == tabID } }
        // Moving a session's only tab dissolves it: capture its hook context first, as a close does.
        let closedContext = source?.tabs.count == 1
            ? buildFormatContext(surfaceKey: source?.tabs.first?.rootPane.allSurfaceIDs().first?.uuidString)
            : nil
        guard let session = editor.moveTab(tabID, toSessionID: toSessionID, index: index) else {
            return .error("Cannot move that tab (not found, or shared with or into a grouped session)")
        }
        let dissolved = source.map { source in
            !editor.snapshot.workspaces.contains { $0.sessions.contains { $0.id == source.id } }
        } ?? false
        if dissolved, let source { environmentStore.clearSession(source.id.uuidString) }
        // A workspace emptied by the move gets a fresh session, which needs its shell.
        ensureAllSnapshotSurfaces()
        commit()
        if dissolved, let closedContext { fireHookLocked(.sessionClosed, context: closedContext) }
        if toSessionID == nil, session != source?.id { fireHookLocked(.sessionCreated) }
        return .sessionID(session)
    }

    func closeTabLocked(tabID: UUID) -> IPCResponse {
        let owningSession = editor.snapshot.workspaces
            .flatMap(\.sessions)
            .first(where: { $0.tabs.contains { $0.id == tabID } })?.id
        // Grouped sessions: killing a window removes it from every member (tmux).
        // Counterparts + their surfaces gathered BEFORE the close mutates the snapshot.
        let counterparts = editor.groupCounterparts(of: tabID)
        let allTabs = editor.snapshot.workspaces.flatMap { $0.sessions.flatMap { $0.tabs } }
        // Union the surfaces of the window AND its counterparts: a peer's local split can
        // diverge the layout, so a counterpart may carry surfaces this copy doesn't — omit
        // them and those PTYs leak when the peer tab closes (closeSurfaces only reaps the
        // ids it's handed, and nothing else sweeps surfaces orphaned mid-run).
        let closedSurfaces = Array(Set(([tabID] + counterparts).flatMap { id in
            allTabs.first(where: { $0.id == id })?.rootPane.allSurfaceIDs().map(\.uuidString) ?? []
        }))
        let closingTab = allTabs.first { $0.id == tabID }
        guard editor.closeTab(tabID) else { return .error("Tab not found") }
        if let closingTab, let owningSession {
            recordClosed(.tab, sessionID: owningSession, name: closingTab.title, tabs: [closingTab])
        }
        for counterpart in counterparts { _ = editor.closeTab(counterpart) }
        closeSurfaces(closedSurfaces)
        ensureAllSnapshotSurfaces()
        // tmux `renumber-windows`: keep indices contiguous after a tab closes.
        if optionStore.get("renumber-windows")?.boolValue == true, let owningSession {
            _ = editor.renumberWindows(sessionID: owningSession)
        }
        commit()
        fireHookLocked(.afterKillTab)
        return .ok
    }

    func closeSessionLocked(sessionID: UUID) -> IPCResponse {
        let closingSession = editor.snapshot.workspaces
            .flatMap(\.sessions)
            .first(where: { $0.id == sessionID })
        let closedSurfaces = closingSession?
            .tabs
            .flatMap { $0.rootPane.allSurfaceIDs().map(\.uuidString) } ?? []
        // Hook context captured BEFORE the close: `#{session_name}` must describe
        // the session that closed, not whatever survives it.
        let closedContext = buildFormatContext(
            surfaceKey: (closingSession?.activeTab ?? closingSession?.tabs.first)?
                .rootPane.allSurfaceIDs().first?.uuidString
        )
        guard editor.closeSession(sessionID) else { return .error("Session not found") }
        if let closingSession { recordClosed(.session, sessionID: sessionID, name: closingSession.name, tabs: closingSession.tabs) }
        closeSurfaces(closedSurfaces)
        // Drop the session's per-session env so entries don't accumulate in environment.json.
        environmentStore.clearSession(sessionID.uuidString)
        ensureAllSnapshotSurfaces()
        commit()
        fireHookLocked(.sessionClosed, context: closedContext)
        return .ok
    }

    func closeWorkspaceLocked(id: UUID) -> IPCResponse {
        let workspaceSessionIDs = editor.snapshot.workspaces
            .first(where: { $0.id == id })?
            .sessions.map(\.id) ?? []
        let closedSurfaces = editor.snapshot.workspaces
            .first(where: { $0.id == id })?
            .sessions
            .flatMap { $0.tabs }
            .flatMap { $0.rootPane.allSurfaceIDs().map(\.uuidString) } ?? []
        let closingSessions = editor.snapshot.workspaces.first(where: { $0.id == id })?.sessions ?? []
        guard editor.closeWorkspace(id) else { return .error("Cannot close workspace") }
        for session in closingSessions { recordClosed(.session, sessionID: session.id, name: session.name, tabs: session.tabs) }
        closeSurfaces(closedSurfaces)
        for sessionID in workspaceSessionIDs { environmentStore.clearSession(sessionID.uuidString) }
        commit()
        return .ok
    }

    func closeEphemeralSessionsLocked() -> IPCResponse {
        // Close each ephemeral session inline (NOT via re-entrant handle(.closeSession),
        // which would deadlock on the non-recursive `lock` we already hold). Same helpers
        // the .closeSession case uses, so PTYs are killed and the layout stays consistent.
        let ids = editor.ephemeralSessionIDs()
        // Unpinned tabs kept alive only by a pinned sibling: close them individually so a
        // pinned tab keeps just itself (and its session container) across a clean quit.
        let tabIDs = editor.ephemeralTabIDs()
        guard !ids.isEmpty || !tabIDs.isEmpty else { return .ok }
        for sessionID in ids {
            let closedSurfaces = editor.snapshot.workspaces
                .flatMap(\.sessions)
                .first(where: { $0.id == sessionID })?
                .tabs
                .flatMap { $0.rootPane.allSurfaceIDs().map(\.uuidString) } ?? []
            guard editor.closeSession(sessionID) else { continue }
            closeSurfaces(closedSurfaces)
            environmentStore.clearSession(sessionID.uuidString)
        }
        for tabID in tabIDs {
            // Gather the tab's surfaces before removing it from the layout (mirrors the
            // session loop above), then kill those PTYs.
            let closedSurfaces = editor.snapshot.workspaces
                .flatMap(\.sessions).flatMap(\.tabs)
                .first(where: { $0.id == tabID })?
                .rootPane.allSurfaceIDs().map(\.uuidString) ?? []
            guard editor.closeTab(tabID) else { continue }
            closeSurfaces(closedSurfaces)
        }
        ensureAllSnapshotSurfaces()
        commit()
        return .ok
    }

    func updateTabTitleLocked(surfaceID: String, title: String) -> IPCResponse {
        // OSC/program-driven rename. Honor `allow-rename` (global) and the
        // per-tab `automatic-rename` flag — a manual `rename-tab` turns the
        // latter off so the chosen name sticks (tmux semantics).
        if let uuid = UUID(uuidString: surfaceID),
           optionStore.get("allow-rename")?.boolValue ?? true,
           automaticRenameEnabled(forSurfaceKey: surfaceID) {
            editor.updateTabTitle(surfaceID: uuid, title: title)
            commit()
            fireHookLocked(.windowRenamed, surfaceKey: surfaceID)
        }
        return .ok
    }

    func renameTabLocked(tabID: UUID, name: String) -> IPCResponse {
        guard editor.renameTab(tabID, name: name) else { return .error("Tab not found") }
        // A manual rename sticks: turn off automatic-rename for this tab so a
        // later OSC title doesn't clobber the chosen name.
        optionStore.set(.bool(false), key: "automatic-rename", scope: .tab, target: tabID.uuidString)
        commit()
        // Hook context follows the RENAMED tab (a `-t` can name a non-active one),
        // like the OSC automatic-rename path — never the focused tab's.
        fireHookLocked(.windowRenamed, surfaceKey: editor.snapshot.workspaces
            .flatMap { $0.sessions.flatMap(\.tabs) }
            .first(where: { $0.id == tabID })?
            .rootPane.allSurfaceIDs().first?.uuidString)
        return .ok
    }
}
