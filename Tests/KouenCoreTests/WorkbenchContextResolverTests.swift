import XCTest
@testable import KouenCore

final class WorkbenchContextResolverTests: XCTestCase {
    func testActivePaneCWDWinsOverTabCWD() {
        let leftSurface = UUID()
        let rightSurface = UUID()
        let leftPane = PaneLeaf(
            id: UUID(),
            surfaceID: leftSurface,
            surfaces: [PaneSurface(id: leftSurface, cwd: "/repo/left")]
        )
        let rightPane = PaneLeaf(
            id: UUID(),
            surfaceID: rightSurface,
            surfaces: [PaneSurface(id: rightSurface, cwd: "/repo/right")]
        )
        let root = PaneNode.branch(direction: .horizontal, ratio: 0.5, first: .leaf(leftPane), second: .leaf(rightPane))
        let tab = Tab(cwd: "/repo/tab", rootPane: root, activePaneID: rightPane.id)
        let snapshot = snapshot(tab: tab)

        let context = WorkbenchContextResolver.resolve(snapshot: snapshot)

        XCTAssertEqual(context?.cwd, "/repo/right")
        XCTAssertEqual(context?.tabCWD, "/repo/tab")
        XCTAssertEqual(context?.paneID, rightPane.id)
        XCTAssertEqual(context?.surfaceID, rightSurface)
        XCTAssertEqual(context?.source, .activePane)
    }

    func testFocusedSurfaceWinsOverActivePane() {
        let leftSurface = UUID()
        let rightSurface = UUID()
        let leftPane = PaneLeaf(
            id: UUID(),
            surfaceID: leftSurface,
            surfaces: [PaneSurface(id: leftSurface, cwd: "/repo/left")]
        )
        let rightPane = PaneLeaf(
            id: UUID(),
            surfaceID: rightSurface,
            surfaces: [PaneSurface(id: rightSurface, cwd: "/repo/right")]
        )
        let root = PaneNode.branch(direction: .horizontal, ratio: 0.5, first: .leaf(leftPane), second: .leaf(rightPane))
        let tab = Tab(cwd: "/repo/tab", rootPane: root, activePaneID: rightPane.id)
        let snapshot = snapshot(tab: tab)

        let context = WorkbenchContextResolver.resolve(snapshot: snapshot, focusedSurfaceID: leftSurface)

        XCTAssertEqual(context?.cwd, "/repo/left")
        XCTAssertEqual(context?.paneID, leftPane.id)
        XCTAssertEqual(context?.surfaceID, leftSurface)
        XCTAssertEqual(context?.source, .focusedSurface)
    }

    func testCurrentFileIsCarriedWithoutReplacingTerminalCWD() {
        let surface = UUID()
        let pane = PaneLeaf(
            id: UUID(),
            surfaceID: surface,
            surfaces: [PaneSurface(id: surface, cwd: "/repo/terminal")]
        )
        let tab = Tab(cwd: "/repo/tab", rootPane: .leaf(pane), activePaneID: pane.id)
        let snapshot = snapshot(tab: tab)

        let context = WorkbenchContextResolver.resolve(
            snapshot: snapshot,
            focusedSurfaceID: surface,
            currentFilePath: "/repo/editor/Sources/App.swift"
        )

        XCTAssertEqual(context?.cwd, "/repo/terminal")
        XCTAssertEqual(context?.currentFilePath, "/repo/editor/Sources/App.swift")
    }

    private func snapshot(tab: Tab) -> SessionSnapshot {
        let session = SessionGroup(id: UUID(), name: "session", tabs: [tab], activeTabID: tab.id)
        let workspace = Workspace(id: UUID(), name: "workspace", sessions: [session], activeSessionID: session.id)
        return SessionSnapshot(workspaces: [workspace], activeWorkspaceID: workspace.id)
    }
}
