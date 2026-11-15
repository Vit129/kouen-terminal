import XCTest
import KouenCore
import KouenIPC
@testable import KouenApp

/// [TC-0801][FE-UT] Local-only browser leaves must be re-attached to the tab they live in, matched by
/// workspace/session/tab id, not by array position (a tab closed before it shifts every index).
final class DaemonSyncServiceBrowserLeafIdentityTests: XCTestCase {
    private func termTab() -> Tab { Tab(rootPane: .leaf(PaneLeaf(id: PaneID(), surfaceID: SurfaceID()))) }

    func test_TC0801_FE_UT_closingEarlierTabKeepsBrowserLeafInItsOwnTab() {
        let first = termTab()
        var browserTab = termTab()
        let browser = BrowserLeaf(id: PaneID(), url: URL(string: "https://example.com")!)
        browserTab.rootPane = .branch(direction: .horizontal, ratio: 0.6, first: browserTab.rootPane, second: .browser(browser))
        let third = termTab()

        let session = SessionGroup(tabs: [first, browserTab, third])
        let ws = Workspace(sessions: [session])
        let local = SessionSnapshot(workspaces: [ws])

        // Daemon: `first` was closed, so every later tab moved up one position.
        var remoteSession = session
        remoteSession.tabs = [
            Tab(id: browserTab.id, rootPane: browserTab.rootPane.strippingBrowserLeaves(for: [browser])),
            third,
        ]
        let remote = SessionSnapshot(workspaces: [Workspace(id: ws.id, sessions: [remoteSession])])

        let merged = DaemonSyncService.snapshotPreservingBrowserPanes(local: local, remote: remote) { id, node in
            node = node.strippingBrowserLeaves(for: [BrowserLeaf(id: id, url: browser.url)])
        }

        let tabs = merged.workspaces[0].sessions[0].tabs
        XCTAssertEqual(tabs.first { $0.id == browserTab.id }?.rootPane.allBrowserLeaves().map(\.id), [browser.id])
        XCTAssertTrue(tabs.first { $0.id == third.id }?.rootPane.allBrowserLeaves().isEmpty == true,
                      "browser leaf must not migrate into a neighbouring tab")
    }
}

private extension PaneNode {
    func strippingBrowserLeaves(for leaves: [BrowserLeaf]) -> PaneNode {
        switch self {
        case let .branch(_, _, first, second):
            if case let .browser(leaf) = second, leaves.contains(where: { $0.id == leaf.id }) { return first }
            if case let .browser(leaf) = first, leaves.contains(where: { $0.id == leaf.id }) { return second }
            return self
        default: return self
        }
    }
}
