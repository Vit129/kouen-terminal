import AppKit
import Foundation
import HarnessCore
import HarnessTerminalKit

/// Handles workspace/session/tab open, select, close, and reorder operations.
@MainActor
final class SessionLifecycleService {
    private unowned let coord: SessionCoordinator
    private var isShowingCloseConfirmation = false

    init(coordinator: SessionCoordinator) {
        self.coord = coordinator
    }

    // MARK: - Open

    func addWorkspace(name: String) {
        Task {
            await coord.requestDaemon(.newWorkspace(name: name))
            await coord.syncFromDaemon()
        }
    }

    func addSession(to workspaceID: WorkspaceID, cwd: String? = nil, name: String? = nil) {
        let resolvedCWD = cwd ?? coord.activeTabCWD ?? coord.settings.defaultCWD
        let targetRoot = HarnessDesign.projectGroupRootPath(for: resolvedCWD)
        let targetIndex: Int?
        if let sessions = coord.snapshot.activeWorkspace?.sessions {
            var matchIndex: Int?
            for index in sessions.indices.reversed() {
                let session = sessions[index]
                let path = (session.activeTab ?? session.tabs.first)?.cwd ?? ""
                if HarnessDesign.projectGroupRootPath(for: path) == targetRoot {
                    matchIndex = index
                    break
                }
            }
            targetIndex = matchIndex.map { $0 + 1 }
        } else {
            targetIndex = nil
        }

        Task {
            guard case let .sessionID(sessionID)? = await coord.requestDaemon(.newSession(
                workspaceID: workspaceID,
                cwd: resolvedCWD,
                name: name,
                shell: coord.settings.defaultShell
            )) else {
                await coord.syncFromDaemon()
                return
            }
            await coord.syncFromDaemon()
            if let targetIndex,
               let workspace = coord.snapshot.activeWorkspace,
               workspace.sessions.firstIndex(where: { $0.id == sessionID }) != targetIndex {
                coord.reorderSession(workspaceID: workspaceID, sessionID: sessionID, toIndex: targetIndex)
            }
            // P24: Auto-execute setupScript from harness.json
            if let config = ProjectConfig.load(from: resolvedCWD), let setup = config.setupScript, !setup.isEmpty {
                if let tab = coord.snapshot.activeWorkspace?.sessions.first(where: { $0.id == sessionID })?.tabs.first,
                   let surfaceID = tab.rootPane.allSurfaceIDs().first {
                    // Small delay to let shell initialize before sending command
                    try? await Task.sleep(for: .milliseconds(500))
                    await coord.requestDaemon(.sendData(surfaceID: surfaceID.uuidString, data: Data((setup + "\r").utf8)))
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                SurfaceShellTracker.shared.bumpScan()
            }
        }
    }

    func addTab(to workspaceID: WorkspaceID, cwd: String? = nil) {
        Task {
            await coord.requestDaemon(.newTab(workspaceID: workspaceID, cwd: cwd ?? coord.activeTabCWD ?? coord.settings.defaultCWD, shell: coord.settings.defaultShell))
            await coord.syncFromDaemon()
            try? await Task.sleep(for: .milliseconds(600))
            await coord.syncFromDaemon()
        }
    }

    func openDefaultTerminalLaunch(_ launch: DefaultTerminalLaunchRequest) {
        guard let workspaceID = coord.snapshot.activeWorkspace?.id ?? coord.snapshot.workspaces.first?.id else { return }
        let cwd = launch.cwd ?? coord.settings.defaultCWD
        Task {
            guard case let .tabID(tabID)? = await coord.requestDaemon(.newTab(workspaceID: workspaceID, cwd: cwd, shell: coord.settings.defaultShell)) else {
                await coord.syncFromDaemon()
                return
            }
            if let title = launch.title, !title.isEmpty {
                await coord.requestDaemon(.renameTab(tabID: tabID, name: title))
            }
            await coord.syncFromDaemon()
            guard let surfaceID = coord.splitPaneCoordinator.firstSurfaceID(forTab: tabID) else { return }
            coord.setActiveSurface(surfaceID)
            coord.terminalHosts.host(for: surfaceID)?.focusTerminal()
            if let command = launch.command, !command.isEmpty {
                await coord.requestDaemon(.sendData(surfaceID: surfaceID.uuidString, data: Data((command + "\r").utf8)))
            }
        }
    }

    // MARK: - Select

    func selectWorkspace(_ id: WorkspaceID) {
        coord.requestDaemon(.selectWorkspace(id: id))
        coord.activeSurfaceID = nil
        coord.syncFromDaemon()
    }

    func selectSession(workspaceID: WorkspaceID, sessionID: SessionID) {
        if coord.snapshot.activeWorkspaceID == workspaceID,
           coord.snapshot.activeWorkspace?.activeSessionID == sessionID {
            return
        }
        coord.requestDaemon(.selectSession(workspaceID: workspaceID, sessionID: sessionID))
        coord.activeSurfaceID = nil
        coord.syncFromDaemon()
    }

    func selectTab(workspaceID: WorkspaceID, tabID: TabID) {
        if coord.snapshot.activeWorkspaceID == workspaceID,
           coord.snapshot.activeWorkspace?.activeTabID == tabID {
            return
        }
        coord.requestDaemon(.selectTab(workspaceID: workspaceID, tabID: tabID))
        coord.activeSurfaceID = nil
        coord.syncFromDaemon()
    }

    func selectAdjacentSession(offset: Int) {
        guard let workspace = coord.snapshot.activeWorkspace,
              let activeSessionID = workspace.activeSessionID,
              let index = workspace.sessions.firstIndex(where: { $0.id == activeSessionID }),
              !workspace.sessions.isEmpty
        else { return }
        let count = workspace.sessions.count
        let nextIndex = (index + offset % count + count) % count
        selectSession(workspaceID: workspace.id, sessionID: workspace.sessions[nextIndex].id)
    }

    func moveActiveSession(offset: Int) {
        guard offset != 0,
              let workspace = coord.snapshot.activeWorkspace,
              let activeSessionID = workspace.activeSessionID,
              let index = workspace.sessions.firstIndex(where: { $0.id == activeSessionID })
        else { return }
        let targetIndex = index + offset
        guard workspace.sessions.indices.contains(targetIndex) else { return }
        coord.reorderSession(workspaceID: workspace.id, sessionID: activeSessionID, toIndex: targetIndex)
    }

    // MARK: - Close

    func closeActiveTab() {
        guard let disposition = activeTabCloseDisposition() else { return }
        performClose(disposition)
    }

    func closeActiveTabWithConfirmation() {
        guard !isShowingCloseConfirmation else { return }
        guard let disposition = activeTabCloseDisposition(),
              let copy = closeConfirmationCopy(for: disposition)
        else { return }
        isShowingCloseConfirmation = true
        let alert = NSAlert()
        alert.messageText = copy.message
        alert.informativeText = copy.informative
        alert.alertStyle = .warning
        alert.addButton(withTitle: copy.button)
        alert.addButton(withTitle: "Cancel")
        // No default button — neither is auto-triggered by Enter. User must
        // Tab to select a button, then press Space to confirm.
        alert.buttons[0].keyEquivalent = ""
        alert.buttons[1].keyEquivalent = ""

        if let window = NSApp.keyWindow ?? NSApp.mainWindow {
            alert.beginSheetModal(for: window) { [weak self, weak window] response in
                Task { @MainActor in
                    self?.isShowingCloseConfirmation = false
                    guard response == .alertFirstButtonReturn else { return }
                    self?.performClose(disposition, closingWindow: window)
                }
            }
        } else {
            let response = alert.runModal()
            isShowingCloseConfirmation = false
            guard response == .alertFirstButtonReturn else { return }
            performClose(disposition)
        }
    }

    func closeActiveTabOnly() {
        guard let tab = coord.snapshot.activeWorkspace?.activeTab else { return }
        rememberTabForReopen(tab)
        let surfaces = tab.rootPane.allSurfaceIDs()
        for surfaceID in surfaces {
            coord.terminalHosts.removeHost(for: surfaceID)
        }
        coord.requestDaemon(.closeTab(tabID: tab.id))
        coord.syncFromDaemon()
    }

    func closeActiveSession() {
        guard let session = coord.snapshot.activeWorkspace?.activeSession else { return }
        closeSession(session)
    }

    func closeSession(_ session: SessionGroup) {
        if let tab = session.activeTab { rememberTabForReopen(tab) }
        let surfaces = session.tabs.flatMap { $0.rootPane.allSurfaceIDs() }
        for surfaceID in surfaces {
            coord.terminalHosts.removeHost(for: surfaceID)
        }
        coord.requestDaemon(.closeSession(sessionID: session.id))
        coord.syncFromDaemon()
    }

    func closeActiveWorkspace() {
        guard let id = coord.snapshot.activeWorkspaceID, coord.snapshot.workspaces.count > 1 else { return }
        closeWorkspace(id: id)
    }

    func closeWorkspace(id: WorkspaceID) {
        guard coord.snapshot.workspaces.count > 1 else { return }
        guard let workspace = coord.snapshot.workspaces.first(where: { $0.id == id }) else { return }
        if let session = workspace.activeSession, let tab = session.activeTab {
            rememberTabForReopen(tab)
        }
        let surfaces = workspace.sessions.flatMap { session in
            session.tabs.flatMap { $0.rootPane.allSurfaceIDs() }
        }
        for surfaceID in surfaces {
            coord.terminalHosts.removeHost(for: surfaceID)
        }
        coord.requestDaemon(.closeWorkspace(id: id))
        coord.syncFromDaemon()
    }

    func closeOtherTabs(keeping keepID: TabID) {
        guard let workspace = coord.snapshot.activeWorkspace, let session = workspace.activeSession else { return }
        let others = session.tabs.filter { $0.id != keepID }
        guard !others.isEmpty else { return }
        for tab in others {
            for surfaceID in tab.rootPane.allSurfaceIDs() {
                coord.terminalHosts.removeHost(for: surfaceID)
            }
            coord.requestDaemon(.closeTab(tabID: tab.id))
        }
        coord.selectTab(workspaceID: workspace.id, tabID: keepID)
        coord.syncFromDaemon()
    }

    func closeTabs(under path: String) async {
        let standardParent = (path as NSString).standardizingPath
        var tabsToClose: [(tabID: TabID, surfaceIDs: [SurfaceID])] = []
        for workspace in coord.snapshot.workspaces {
            for session in workspace.sessions {
                for tab in session.tabs {
                    let standardTabPath = (tab.cwd as NSString).standardizingPath
                    if standardTabPath == standardParent || standardTabPath.hasPrefix(standardParent + "/") {
                        tabsToClose.append((tab.id, tab.rootPane.allSurfaceIDs()))
                    }
                }
            }
        }
        guard !tabsToClose.isEmpty else { return }
        for item in tabsToClose {
            for surfaceID in item.surfaceIDs {
                coord.terminalHosts.removeHost(for: surfaceID)
            }
            _ = await coord.requestDaemon(.closeTab(tabID: item.tabID))
        }
        _ = await coord.syncFromDaemon()
    }

    func reopenLastClosedTab() {
        guard let workspace = coord.snapshot.activeWorkspace, let closed = coord.lastClosedTab else { return }
        let cwd = closed.cwd.isEmpty ? coord.settings.defaultCWD : closed.cwd
        guard case let .tabID(tabID)? = coord.requestDaemon(.newTab(workspaceID: workspace.id, cwd: cwd, shell: coord.settings.defaultShell)) else {
            coord.syncFromDaemon()
            return
        }
        coord.lastClosedTab = nil
        if !closed.title.isEmpty, closed.title != "Shell" {
            coord.requestDaemon(.renameTab(tabID: tabID, name: closed.title))
        }
        coord.syncFromDaemon()
        if let surfaceID = coord.splitPaneCoordinator.firstSurfaceID(forTab: tabID) {
            coord.setActiveSurface(surfaceID)
            coord.terminalHosts.host(for: surfaceID)?.focusTerminal()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            SurfaceShellTracker.shared.bumpScan()
        }
    }

    func openTabInActiveWorkspace() {
        guard let workspace = coord.snapshot.activeWorkspace else { return }
        addTab(to: workspace.id)
    }

    // MARK: - Remembered last closed

    func rememberTabForReopen(_ tab: Tab) {
        coord.lastClosedTab = (cwd: tab.cwd, title: tab.title)
    }

    // MARK: - Private

    private enum ActiveTabCloseDisposition {
        case tab, session, workspace, window
    }

    private struct CloseConfirmationCopy {
        var message: String
        var informative: String
        var button: String
    }

    private func activeTabCloseDisposition() -> ActiveTabCloseDisposition? {
        guard let workspace = coord.snapshot.activeWorkspace,
              let session = workspace.activeSession,
              session.activeTab != nil
        else { return nil }
        if session.tabs.count > 1 { return .tab }
        if workspace.sessions.count > 1 { return .session }
        if coord.snapshot.workspaces.count > 1 { return .workspace }
        return .window
    }

    private func closeConfirmationCopy(for disposition: ActiveTabCloseDisposition) -> CloseConfirmationCopy? {
        guard let workspace = coord.snapshot.activeWorkspace,
              let session = workspace.activeSession,
              let tab = session.activeTab
        else { return nil }
        let tabTitle = HarnessPathDisplay.title(for: tab.cwd, fallback: tab.title)
        switch disposition {
        case .tab:
            return CloseConfirmationCopy(
                message: "Close tab \"\(tabTitle)\"?",
                informative: "This will close the tab and its running shell.",
                button: "Close Tab"
            )
        case .session:
            let sessionTitle = session.name.isEmpty ? tabTitle : session.name
            return CloseConfirmationCopy(
                message: "Close session \"\(sessionTitle)\"?",
                informative: "This is the last tab in the session. The session and its running shell will close.",
                button: "Close Session"
            )
        case .workspace:
            return CloseConfirmationCopy(
                message: "Close workspace \"\(workspace.name)\"?",
                informative: "This is the last tab in the workspace. The workspace and its running shell will close.",
                button: "Close Workspace"
            )
        case .window:
            return CloseConfirmationCopy(
                message: "Close Harness window?",
                informative: "This is the last tab in the window. The running shell will close and the window will close.",
                button: "Close Window"
            )
        }
    }

    private func performClose(_ disposition: ActiveTabCloseDisposition, closingWindow: NSWindow? = nil) {
        switch disposition {
        case .tab:
            closeActiveTabOnly()
        case .session:
            closeActiveSession()
        case .workspace:
            closeActiveWorkspace()
        case .window:
            closeActiveTabOnly()
            (closingWindow ?? NSApp.keyWindow ?? NSApp.mainWindow)?.close()
        }
    }
}
