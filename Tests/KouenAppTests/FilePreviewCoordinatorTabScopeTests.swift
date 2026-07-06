import XCTest
import AppKit
@testable import KouenApp

/// Regression guard for per-Tab file preview scoping: a file opened while tab A is
/// active must not be visible/active when tab B (which never opened it) becomes active.
@MainActor
final class FilePreviewCoordinatorTabScopeTests: XCTestCase {
    // FilePreviewCoordinator holds these `unowned` — the coordinator alone doesn't
    // keep them alive, so the test must retain them for as long as the coordinator.
    private var containerView: NSView!
    private var terminalHost: NSView!
    private var tabBarDivider: NSView!

    override func setUp() async throws {
        try await super.setUp()
        containerView = NSView(frame: NSRect(x: 0, y: 0, width: 800, height: 600))
        terminalHost = NSView()
        tabBarDivider = NSView()
        containerView.addSubview(terminalHost)
        containerView.addSubview(tabBarDivider)
    }

    private func makeCoordinator() -> FilePreviewCoordinator {
        FilePreviewCoordinator(containerView: containerView, terminalHost: terminalHost, tabBarDivider: tabBarDivider)
    }

    func testFileOpenedInOneTabIsHiddenAfterSwitchingToAnotherTab() {
        let coordinator = makeCoordinator()

        coordinator.switchToTab(tabID: "tab-A")
        coordinator.openFileTab(path: "/repo/CLAUDE.md")
        XCTAssertTrue(coordinator.isFileEditorVisible)
        XCTAssertEqual(coordinator.currentFilePath, "/repo/CLAUDE.md")

        coordinator.switchToTab(tabID: "tab-B")
        XCTAssertFalse(coordinator.isFileEditorVisible, "tab B never opened a file — panel must auto-hide")
    }

    func testSwitchingBackRestoresThatTabsOwnFile() {
        let coordinator = makeCoordinator()

        coordinator.switchToTab(tabID: "tab-A")
        coordinator.openFileTab(path: "/repo/CLAUDE.md")

        coordinator.switchToTab(tabID: "tab-B")
        coordinator.openFileTab(path: "/repo/README.md")
        XCTAssertEqual(coordinator.currentFilePath, "/repo/README.md")

        coordinator.switchToTab(tabID: "tab-A")
        XCTAssertTrue(coordinator.isFileEditorVisible)
        XCTAssertEqual(coordinator.currentFilePath, "/repo/CLAUDE.md", "switching back to tab A must restore its own file, not tab B's")
    }

    func testPruneRemovesManagersForClosedTabs() {
        let coordinator = makeCoordinator()

        coordinator.switchToTab(tabID: "tab-A")
        coordinator.openFileTab(path: "/repo/CLAUDE.md")

        coordinator.pruneFileTabManagers(keepingTabIDs: ["tab-B"])

        coordinator.switchToTab(tabID: "tab-C")
        coordinator.switchToTab(tabID: "tab-A")
        XCTAssertFalse(coordinator.isFileEditorVisible, "tab A's manager was pruned — revisiting it must start fresh, not resurrect the old file")
    }
}
