import XCTest
import KouenCore
@testable import KouenApp

/// `kouenBrowserOpen` used to reuse ANY browser pane open anywhere in the app
/// (`BrowserPaneRegistry.anyPane()`) instead of scoping reuse to the request's own target tab —
/// an agent's browser-open call could get silently redirected into a completely different
/// session's browser pane just because one happened to already be open there, and concurrent
/// callers with no pane open yet could each spawn their own separate pane. This covers the
/// target-tab resolution and per-tab reuse lookup that replaced it.
@MainActor
final class BrowserPaneReuseScopeTests: XCTestCase {
    private func makeTab(id: TabID = TabID(), rootPane: PaneNode) -> Tab {
        Tab(id: id, cwd: "/tmp", rootPane: rootPane)
    }

    // MARK: - targetTab resolution

    func testTargetTabPrefersOriginSurfaceOverActiveTab() {
        let originSurfaceID = SurfaceID()
        let originTab = makeTab(rootPane: .leaf(PaneLeaf()))
        let activeTab = makeTab(rootPane: .leaf(PaneLeaf()))

        let resolved = DaemonSyncService.targetTab(
            originSurfaceID: originSurfaceID,
            surfaceIndex: [originSurfaceID: (tab: originTab, tabID: originTab.id)],
            activeTab: activeTab
        )

        XCTAssertEqual(resolved?.id, originTab.id, "origin surface's own tab must win over whatever tab is active")
    }

    func testTargetTabFallsBackToActiveWhenOriginUnknown() {
        let activeTab = makeTab(rootPane: .leaf(PaneLeaf()))

        let resolved = DaemonSyncService.targetTab(originSurfaceID: nil, surfaceIndex: [:], activeTab: activeTab)

        XCTAssertEqual(resolved?.id, activeTab.id, "menu/keyboard-triggered opens have no origin surface")
    }

    func testTargetTabReturnsNilWhenOriginSurfacePresentButNotFound() {
        let staleSurfaceID = SurfaceID() // not present in surfaceIndex — e.g. a stale KOUEN_SURFACE
        let activeTab = makeTab(rootPane: .leaf(PaneLeaf()))

        let resolved = DaemonSyncService.targetTab(originSurfaceID: staleSurfaceID, surfaceIndex: [:], activeTab: activeTab)

        XCTAssertNil(
            resolved,
            "an agent call with a real origin surface that fails to resolve must never silently land on whatever tab is active"
        )
    }

    // MARK: - existingBrowserPaneID scoping (the actual bug)

    func testExistingBrowserPaneIDOnlyLooksAtTheGivenTab() {
        let browserLeaf = BrowserLeaf(url: URL(string: "https://example.com")!)
        let tabWithBrowser = makeTab(rootPane: .browser(browserLeaf))
        let tabWithoutBrowser = makeTab(rootPane: .leaf(PaneLeaf()))

        XCTAssertEqual(
            DaemonSyncService.existingBrowserPaneID(inTab: tabWithBrowser), browserLeaf.id,
            "a tab that already has a browser pane must report it for reuse"
        )
        XCTAssertNil(
            DaemonSyncService.existingBrowserPaneID(inTab: tabWithoutBrowser),
            "a DIFFERENT tab with no browser pane of its own must never reuse another tab's pane"
        )
    }

    func testExistingBrowserPaneIDNilForNilTab() {
        XCTAssertNil(DaemonSyncService.existingBrowserPaneID(inTab: nil))
    }

    func testExistingBrowserPaneIDFindsLeafInsideSplitBranch() {
        let browserLeaf = BrowserLeaf(url: URL(string: "https://example.com")!)
        let root = PaneNode.branch(direction: .horizontal, ratio: 0.5, first: .leaf(PaneLeaf()), second: .browser(browserLeaf))
        let tab = makeTab(rootPane: root)

        XCTAssertEqual(DaemonSyncService.existingBrowserPaneID(inTab: tab), browserLeaf.id)
    }
}
