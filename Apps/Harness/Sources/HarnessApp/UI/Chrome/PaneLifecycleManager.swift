import AppKit
import HarnessCore
import HarnessTerminalKit

/// Manages pane rebuild lifecycle: structural reloads, zombie-hold of detached views,
/// and pane lookup. Owned by ContentAreaViewController.
@MainActor
final class PaneLifecycleManager {
    private unowned let terminalHost: NSView
    private unowned let containerView: NSView

    private(set) var paneContainer: PaneContainerView?
    private var lastStructureKey = ""
    private var containerCache: [String: PaneContainerView] = [:] // tabID → cached container
    private var activeTabID: String?
    var pendingReload: Bool?

    init(terminalHost: NSView, containerView: NSView) {
        self.terminalHost = terminalHost
        self.containerView = containerView
    }

    // MARK: - Reload

    func reloadIfNeeded(force: Bool) {
        guard terminalHost.bounds.width > 1, terminalHost.bounds.height > 1 else {
            pendingReload = (pendingReload ?? false) || force
            return
        }

        let coordinator = SessionCoordinator.shared
        guard let workspace = coordinator.snapshot.activeWorkspace,
              let tab = workspace.activeTab
        else { return }

        let displayNode = zoomedNode(for: tab) ?? tab.rootPane
        let paneStructureKey = paneKey(displayNode)
        let key = "\(coordinator.structureRevision)|\(workspace.id)|\(tab.id)|\(tab.zoomedPaneID?.uuidString ?? "all")|\(paneStructureKey)"
        guard force || key != lastStructureKey else {
            paneContainer?.refreshChrome(snapshot: coordinator.snapshot)
            return
        }

        let tabID = tab.id.uuidString

        // Fast path: if we have a cached container for THIS tab from a previous visit,
        // just swap visibility. Guard `cached !== paneContainer` ensures we only take
        // this path for tab-switch restores, not for in-place structural changes
        // (e.g. adding a browser pane) where a full rebuild is required.
        if !force, let cached = containerCache[tabID], cached !== paneContainer, cached.superview == terminalHost {
            paneContainer?.isHidden = true
            cached.isHidden = false
            paneContainer = cached
            lastStructureKey = key
            activeTabID = tabID
            coordinator.ensureActivePane(for: tab)
            paneContainer?.refreshChrome(snapshot: coordinator.snapshot)
            // The display link on each surface is paused while idle. Toggling isHidden
            // doesn't wake it, so the Metal layer shows black until new PTY output arrives.
            // Wake every renderer in the now-visible container.
            cached.collectTerminalHosts().values.forEach { $0.scheduleRepaint() }
            return
        }

        lastStructureKey = key

        if let window = containerView.window, window.firstResponder is HarnessTerminalSurfaceView {
            window.makeFirstResponder(nil)
        }

        let allHosts = coordinator.terminalHosts.allHosts()
        allHosts.forEach { $0.setPresentsWithTransaction(true) }

        let existingHosts = paneContainer?.collectTerminalHosts() ?? [:]
        let existingBrowserPanes = paneContainer?.collectBrowserPanes() ?? [:]
        paneContainer?.detachHostsOnly()

        let detached = Array(existingHosts.values)
        for host in detached { ZombieHoldRegistry.shared.hold(host) }

        // Hide old container (keep in cache if it belongs to a tab)
        if let old = paneContainer {
            old.isHidden = true
            if let prevTabID = activeTabID {
                containerCache[prevTabID] = old
            } else {
                ZombieHoldRegistry.shared.hold(old)
                old.removeFromSuperview()
            }
        }

        let container = PaneContainerView(
            node: displayNode,
            cwd: tab.cwd,
            themeName: coordinator.snapshot.themeName,
            existingHosts: existingHosts,
            existingBrowserPanes: existingBrowserPanes
        )
        container.translatesAutoresizingMaskIntoConstraints = false
        terminalHost.addSubview(container)
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: terminalHost.topAnchor),
            container.leadingAnchor.constraint(equalTo: terminalHost.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: terminalHost.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: terminalHost.bottomAnchor),
        ])
        paneContainer = container
        activeTabID = tabID
        containerCache[tabID] = container
        coordinator.ensureActivePane(for: tab)

        CATransaction.begin()
        CATransaction.setCompletionBlock {
            allHosts.forEach { $0.setPresentsWithTransaction(false) }
        }
        containerView.layout()
        CATransaction.commit()
    }

    // MARK: - Cache Pruning

    /// Remove cached containers for tabs that no longer exist. Without pruning, every
    /// tab ever visited accumulates a hidden Metal-rendered container in memory forever.
    func pruneCache(keepingTabIDs liveTabIDs: Set<String>) {
        let staleKeys = containerCache.keys.filter { !liveTabIDs.contains($0) }
        for key in staleKeys {
            let container = containerCache.removeValue(forKey: key)
            container?.removeFromSuperview()
        }
    }

    // MARK: - Pane Lookup

    func paneShell(for paneID: PaneID) -> NSView? {
        let id = NSUserInterfaceItemIdentifier("pane-\(paneID.uuidString)")
        return paneContainer?.findDescendant(withIdentifier: id)
    }

    // MARK: - Helpers

    private func paneKey(_ node: PaneNode) -> String {
        switch node {
        case let .leaf(leaf):
            return "l:\((leaf.activeSurfaceID ?? leaf.surfaceID).uuidString)"
        case let .browser(leaf):
            return "br:\(leaf.id.uuidString)"
        case let .branch(direction, _, first, second):
            return "b:\(direction.rawValue):\(paneKey(first)):\(paneKey(second))"
        }
    }

    private func zoomedNode(for tab: Tab) -> PaneNode? {
        guard let zoomedPaneID = tab.zoomedPaneID else { return nil }
        return leafNode(paneID: zoomedPaneID, in: tab.rootPane)
    }

    private func leafNode(paneID: PaneID, in node: PaneNode) -> PaneNode? {
        switch node {
        case let .leaf(leaf) where leaf.id == paneID:
            return .leaf(leaf)
        case let .branch(_, _, first, second):
            return leafNode(paneID: paneID, in: first) ?? leafNode(paneID: paneID, in: second)
        default:
            return nil
        }
    }
}
