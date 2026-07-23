import XCTest
import KouenCore
import KouenIPC
@testable import KouenApp

/// RL-068: a tab with an open (local-only) browser pane must not have the daemon's real
/// structural changes silently discarded on the next sync. Regression for the bug where ⌘D/⌘⇧D
/// ("Split Right"/"Split Down") appeared to do nothing while a browser pane was focused — the
/// split reached the daemon and succeeded, then got erased by this merge before ever rendering.
final class DaemonSyncServiceBrowserPaneMergeTests: XCTestCase {
    private func terminalLeaf(_ id: PaneID = PaneID()) -> PaneNode {
        .leaf(PaneLeaf(id: id, surfaceID: SurfaceID()))
    }

    func testKeepsLocalTreeWhenTerminalStructureUnchanged() {
        let terminal = terminalLeaf()
        let browser = BrowserLeaf(id: PaneID(), url: URL(string: "https://example.com")!)
        let localTree = PaneNode.branch(direction: .horizontal, ratio: 0.6, first: terminal, second: .browser(browser))

        // Daemon's incoming tree for this tab never has the browser leaf (local-only), but its
        // terminal-only structure is identical to local's — nothing daemon-side changed.
        let merged = DaemonSyncService.mergedRootPane(
            localTree: localTree,
            localTerminalOnly: terminal,
            incomingTree: terminal,
            browserLeaves: [browser]
        )

        XCTAssertEqual(merged.allPaneIDs(), localTree.allPaneIDs(), "unchanged terminal structure must keep the local tree verbatim")
        XCTAssertEqual(merged.allBrowserLeaves().map(\.id), [browser.id])
    }

    func testAdoptsDaemonSplitInsteadOfDiscardingIt() {
        let originalTerminal = terminalLeaf()
        let browser = BrowserLeaf(id: PaneID(), url: URL(string: "https://example.com")!)
        let localTree = PaneNode.branch(direction: .horizontal, ratio: 0.6, first: originalTerminal, second: .browser(browser))

        // Daemon successfully split the terminal pane (⌘D) — its incoming tree now has TWO
        // terminal leaves where local only knew about one.
        let newTerminal = terminalLeaf()
        let incomingSplit = PaneNode.branch(direction: .vertical, ratio: 0.5, first: originalTerminal, second: newTerminal)

        let merged = DaemonSyncService.mergedRootPane(
            localTree: localTree,
            localTerminalOnly: originalTerminal,
            incomingTree: incomingSplit,
            browserLeaves: [browser]
        )

        XCTAssertTrue(merged.allPaneIDs().contains(newTerminal.allPaneIDs()[0]), "the daemon's new split must survive the merge, not be discarded")
        XCTAssertEqual(merged.allBrowserLeaves().map(\.id), [browser.id], "the browser leaf must still be present after adopting the daemon's tree")
    }
}
