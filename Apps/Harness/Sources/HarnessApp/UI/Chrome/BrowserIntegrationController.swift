import AppKit
import HarnessCore

/// Manages browser pane creation, collection, and detachment within a PaneContainerView.
/// Owned by PaneContainerView; extracted from the build/collect/detach cluster there.
@MainActor
final class BrowserIntegrationController {
    private var panes: [PaneID: BrowserPaneView]

    init(existingPanes: [PaneID: BrowserPaneView] = [:]) {
        self.panes = existingPanes
    }

    // MARK: - Build

    func buildNode(_ leaf: BrowserLeaf, into parent: NSView) {
        let bv: BrowserPaneView
        if let existing = panes.removeValue(forKey: leaf.id) {
            bv = existing
        } else {
            bv = BrowserPaneView(url: leaf.url, paneID: leaf.id)
        }
        let paneIDCopy = leaf.id
        bv.onClosePaneRequested = {
            SessionCoordinator.shared.splitPaneCoordinator.closeBrowserPane(paneID: paneIDCopy)
        }
        bv.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(bv)
        NSLayoutConstraint.activate([
            bv.topAnchor.constraint(equalTo: parent.topAnchor),
            bv.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            bv.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
            bv.bottomAnchor.constraint(equalTo: parent.bottomAnchor),
        ])
    }

    // MARK: - Collect

    func collectBrowserPanes(in view: NSView) -> [PaneID: BrowserPaneView] {
        var result: [PaneID: BrowserPaneView] = [:]
        collect(in: view, into: &result)
        return result
    }

    // MARK: - Detach

    func detachBrowsers(in view: NSView) {
        for sub in view.subviews {
            if sub is BrowserPaneView {
                sub.removeFromSuperview()
            } else {
                detachBrowsers(in: sub)
            }
        }
    }

    // MARK: - Private

    private func collect(in view: NSView, into result: inout [PaneID: BrowserPaneView]) {
        for sub in view.subviews {
            if let browser = sub as? BrowserPaneView {
                result[browser.paneID] = browser
            } else {
                collect(in: sub, into: &result)
            }
        }
    }
}
