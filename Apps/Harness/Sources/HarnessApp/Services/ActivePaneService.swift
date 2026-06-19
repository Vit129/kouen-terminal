import AppKit
import HarnessCore
import HarnessTerminalKit

/// Handles active surface tracking, pane borders, sync-panes, zoom, and cycle.
@MainActor
final class ActivePaneService {
    private unowned let coord: SessionCoordinator
    private(set) var markedSurfaceID: SurfaceID?
    private(set) var synchronizedTabIDs: Set<TabID> = []

    init(coordinator: SessionCoordinator) {
        self.coord = coordinator
    }

    func setActiveSurface(_ surfaceID: SurfaceID?) {
        if let old = coord.activeSurfaceID, let new = surfaceID, old != new,
           let oldTab = tabID(forSurface: old), oldTab == tabID(forSurface: new) {
            coord.lastActiveSurfaceID = old
        }
        coord.activeSurfaceID = surfaceID
        refreshPaneStyles()
        let showBorder: Bool
        if let surfaceID { showBorder = paneCount(forSurface: surfaceID) > 1 }
        else { showBorder = false }
        for host in coord.terminalHosts.allHosts() {
            host.showsActiveBorder = showBorder && host.surfaceID == surfaceID
        }
        refreshPaneBorders()
        if !coord.suppressActivePaneSync, let surfaceID, let loc = tabAndPane(forSurface: surfaceID) {
            _ = coord.requestDaemon(.selectPane(tabID: loc.tabID, paneID: loc.paneID))
        }
    }

    func reflectRemoteActivePane() {
        guard let tab = coord.snapshot.activeWorkspace?.activeTab,
              let paneID = tab.activePaneID,
              let surfaceID = surfaceID(forPaneID: paneID, in: tab.rootPane),
              surfaceID != coord.activeSurfaceID
        else { return }
        coord.suppressActivePaneSync = true
        setActiveSurface(surfaceID)
        coord.suppressActivePaneSync = false
    }

    func refreshPaneStyles() {
        let opts = OptionStore()
        func value(_ key: String) -> String { opts.get(key, scope: .global)?.stringValue ?? "" }
        let styles = PaneStyleSet(
            window: value("window-style"),
            windowActive: value("window-active-style"),
            pane: value("pane-style"),
            paneActive: value("pane-active-style")
        )
        for host in coord.terminalHosts.allHosts() { host.applyPaneStyles(styles) }
    }

    func refreshPaneBorders() {
        let opts = OptionStore()
        let status = PaneBorderStatus(option: opts.get("pane-border-status", scope: .global)?.stringValue ?? "off")
        let atTop = status == .top
        let format = opts.get("pane-border-format", scope: .global)?.stringValue ?? ""
        for host in coord.terminalHosts.allHosts() {
            if status == .off || format.isEmpty {
                host.setPaneBorderLabel(nil, atTop: atTop)
            } else {
                let label = FormatString.evaluate(format, context: coord.paneBorderContext(forSurface: host.surfaceID))
                host.setPaneBorderLabel(label, atTop: atTop)
            }
        }
    }

    func setMarkedPane(_ set: Bool) {
        markedSurfaceID = set ? coord.activeSurfaceID : nil
        for host in coord.terminalHosts.allHosts() {
            host.showsMarkedBorder = host.surfaceID == markedSurfaceID
        }
    }

    func reassertMarkedPane() {
        for host in coord.terminalHosts.allHosts() {
            host.showsMarkedBorder = markedSurfaceID != nil && host.surfaceID == markedSurfaceID
        }
    }

    func setSynchronizePanes(_ on: Bool?) {
        guard let tab = coord.snapshot.activeWorkspace?.activeTab else { return }
        let nowOn = on ?? !synchronizedTabIDs.contains(tab.id)
        if nowOn { synchronizedTabIDs.insert(tab.id) } else { synchronizedTabIDs.remove(tab.id) }
        coord.requestDaemon(.setOption(
            scope: "tab", target: tab.id.uuidString,
            key: "synchronize-panes", rawValue: nowOn ? "on" : "off"
        ))
        refreshSyncSiblings()
        DisplayMessage.show(nowOn ? "synchronize-panes: on" : "synchronize-panes: off")
    }

    func adoptSynchronizeOptions() {
        guard case let .options(entries)? = coord.requestDaemon(.showOptions(scope: "tab")) else { return }
        var changed = false
        for entry in entries where entry.key == "synchronize-panes" {
            guard let target = entry.target, let tabID = TabID(uuidString: target) else { continue }
            let on = entry.value == "on" || entry.value == "true" || entry.value == "1"
            if on != synchronizedTabIDs.contains(tabID) {
                if on { synchronizedTabIDs.insert(tabID) } else { synchronizedTabIDs.remove(tabID) }
                changed = true
            }
        }
        if changed { refreshSyncSiblings() }
    }

    func refreshSyncSiblings() {
        let liveTabIDs = Set(coord.surfaceIndex.values.map(\.tabID))
        synchronizedTabIDs.formIntersection(liveTabIDs)
        var seenTabIDs = Set<TabID>()
        for (_, entry) in coord.surfaceIndex {
            guard seenTabIDs.insert(entry.tabID).inserted else { continue }
            let surfaceIDs = entry.tab.rootPane.allSurfaceIDs()
            let synced = synchronizedTabIDs.contains(entry.tabID) && surfaceIDs.count > 1
            for sid in surfaceIDs {
                guard let host = coord.terminalHosts.host(for: sid) else { continue }
                host.setSyncSiblings(synced ? surfaceIDs.filter { $0 != sid }.map(\.uuidString) : [])
            }
        }
    }

    func zoomActivePane() {
        guard let workspace = coord.snapshot.activeWorkspace,
              let tab = workspace.activeTab,
              let paneID = coord.activeSurfaceID.flatMap({ coord.paneID(for: $0, in: tab.rootPane) })
                ?? tab.rootPane.allPaneIDs().last
        else { return }
        coord.requestDaemon(.zoomPane(paneID: paneID))
        coord.syncFromDaemon()
    }

    func cycleActivePane(forward: Bool) {
        guard let tab = coord.snapshot.activeWorkspace?.activeTab else { return }
        let panes = tab.rootPane.allPaneIDs()
        guard !panes.isEmpty else { return }
        let currentIndex: Int
        if let surfaceID = coord.activeSurfaceID,
           let pane = coord.paneID(for: surfaceID, in: tab.rootPane),
           let idx = panes.firstIndex(of: pane) {
            currentIndex = idx
        } else {
            currentIndex = 0
        }
        let nextIndex = (currentIndex + (forward ? 1 : -1) + panes.count) % panes.count
        let targetPane = panes[nextIndex]
        if let surfaceID = surfaceID(forPane: targetPane, in: tab.rootPane) {
            setActiveSurface(surfaceID)
            coord.terminalHosts.host(for: surfaceID)?.focusTerminal()
        }
    }

    func ensureActivePane(for tab: Tab) {
        let surfaces = tab.rootPane.allSurfaceIDs()
        guard !surfaces.isEmpty else { return }
        // Prefer current activeSurfaceID if it belongs to this tab; otherwise
        // restore the tab's daemon-authoritative activePaneID (survives tab switches).
        let target: SurfaceID?
        if let active = coord.activeSurfaceID, surfaces.contains(active) {
            target = active
        } else if let paneID = tab.activePaneID,
                  let sid = surfaceID(forPane: paneID, in: tab.rootPane) {
            target = sid
        } else {
            target = surfaces.first
        }
        setActiveSurface(target)
        if let target { coord.terminalHosts.host(for: target)?.focusTerminal() }
    }

    func selectLastPane() {
        guard let tab = coord.snapshot.activeWorkspace?.activeTab,
              let last = coord.lastActiveSurfaceID,
              tab.rootPane.allSurfaceIDs().contains(last)
        else { return }
        setActiveSurface(last)
        coord.terminalHosts.host(for: last)?.focusTerminal()
    }

    // MARK: - Helpers

    func tabID(forSurface surfaceID: SurfaceID) -> TabID? {
        coord.surfaceIndex[surfaceID]?.tabID
    }

    func paneCount(forSurface surfaceID: SurfaceID) -> Int {
        guard let tab = coord.surfaceIndex[surfaceID]?.tab else { return 0 }
        return tab.rootPane.allSurfaceIDs().count
    }

    func tabAndPane(forSurface surfaceID: SurfaceID) -> (tabID: TabID, paneID: PaneID)? {
        guard let entry = coord.surfaceIndex[surfaceID],
              let pane = coord.paneID(for: surfaceID, in: entry.tab.rootPane)
        else { return nil }
        return (entry.tabID, pane)
    }

    func surfaceID(forPaneID paneID: PaneID, in node: PaneNode) -> SurfaceID? {
        coord.splitPaneCoordinator.surfaceID(forPaneID: paneID, in: node)
    }

    func surfaceID(forPane paneID: PaneID, in node: PaneNode) -> SurfaceID? {
        coord.splitPaneCoordinator.surfaceID(forPane: paneID, in: node)
    }
}
