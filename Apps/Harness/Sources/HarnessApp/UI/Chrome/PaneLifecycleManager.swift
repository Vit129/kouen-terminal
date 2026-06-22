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
    /// Holds the previous container for one runloop cycle after removal so AppKit's pending
    /// layout/display passes complete before ARC deallocates the view tree (RL-040/041).
    private var retiredContainer: PaneContainerView?
    /// Hosts detached during rebuild — held 1.5s so in-flight AppKit events drain (RL-040/041).
    private var retiredHosts: [TerminalHostView] = []

    private var lastStructureKey = ""
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
        let key = "\(coordinator.structureRevision)|\(workspace.id)|\(tab.id)|\(tab.zoomedPaneID?.uuidString ?? "all")|\(paneKey(displayNode))"
        guard force || key != lastStructureKey else {
            paneContainer?.refreshChrome(snapshot: coordinator.snapshot)
            return
        }
        fputs("BLINKDBG reloadIfNeeded REBUILD: force=\(force) oldKey=\(lastStructureKey) newKey=\(key)\n", harnessStderr)
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
        retiredHosts.append(contentsOf: detached)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self else { return }
            self.retiredHosts.removeAll { host in detached.contains { $0 === host } }
        }

        let oldContainer = paneContainer
        paneContainer?.removeFromSuperview()
        retiredContainer = oldContainer
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in self?.retiredContainer = nil }

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
        coordinator.ensureActivePane(for: tab)

        CATransaction.begin()
        CATransaction.setCompletionBlock {
            allHosts.forEach { $0.setPresentsWithTransaction(false) }
        }
        containerView.layoutSubtreeIfNeeded()
        CATransaction.commit()
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
