import AppKit
import XCTest
import HarnessCore
@testable import HarnessApp

@MainActor
final class WindowAppearanceTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        setenv("HARNESS_HOME", "/tmp/hwa-\(UUID().uuidString.prefix(6))", 1)
        MainActor.assumeIsolated { _ = NSApplication.shared }
    }

    func testSidebarHasFinalGeometryBeforeFirstPresentation() throws {
        let savedSettings = SessionCoordinator.shared.settings
        defer { SessionCoordinator.shared.settings = savedSettings }
        for visible in [false, true] {
            SessionCoordinator.shared.settings.sidebarVisible = visible
            SessionCoordinator.shared.settings.restoreWindowSize = false
            let controller = MainWindowController(sessionID: nil)
            let window = try XCTUnwrap(controller.window)
            defer { window.close() }
            // Restoring a frame can resize the window after controller construction.
            window.setContentSize(NSSize(width: 1080, height: 640))
            let root = try XCTUnwrap(controller.contentViewController as? MainSplitViewController)
            XCTAssertTrue(root.context.snapshot.workspaces.isEmpty, "Launch must not invent a terminal to attach")
            XCTAssertTrue(root.context.update(), "Settings refresh must retain the window while it awaits hydration")
            let split = try XCTUnwrap(root.view.subviews.compactMap { $0 as? NSSplitView }.first)
            let sidebar = try XCTUnwrap(split.subviews.first)
            let content = try XCTUnwrap(split.subviews.last)
            XCTAssertFalse(window.isVisible)
            controller.showWindow(nil)
            // No run-loop hop: the first visible frame must already be correct.
            XCTAssertTrue(window.isVisible)
            XCTAssertEqual(sidebar.isHidden, !visible)
            XCTAssertEqual(content.frame.minX, visible ? HarnessDesign.sidebarWidth : 0, accuracy: 1)
            XCTAssertEqual(content.frame.maxX, split.bounds.maxX, accuracy: 1)
            let tabBar = try XCTUnwrap(content.subviews.first { $0 is TerminalTabBarView })
            XCTAssertEqual(tabBar.isHidden, visible)
            XCTAssertEqual(SessionCoordinator.shared.settings.sidebarVisible, visible)
        }
    }

    private func makePanel() -> QuickTerminalPanel {
        _ = NSApplication.shared
        return QuickTerminalPanel(contentRect: NSRect(x: 0, y: 0, width: 100, height: 100))
    }

    func testQuickTerminalCanTransitionBetweenOpaqueAndTranslucent() {
        let panel = makePanel()
        defer { panel.close() }

        // Reuse the same panel, as the controller does across settings changes and toggles.
        for opacity: Float in [1, 0.8, 1, 0.5] {
            WindowAppearance.applyTransparency(opacity: opacity, blur: 20, opaqueBackground: .red, to: panel)
            let opaque = opacity == 1
            XCTAssertEqual(panel.isOpaque, opaque)
            XCTAssertEqual(panel.backgroundColor, opaque ? .red : .clear)
            XCTAssertEqual(panel.hasShadow, opaque)
        }
    }

    func testOpacityThresholdMatchesMainWindow() {
        let panel = makePanel()
        defer { panel.close() }

        for (opacity, opaque): (Float, Bool) in [(0.998, false), (0.999, true), (2, true), (-1, false)] {
            WindowAppearance.applyTransparency(opacity: opacity, blur: 20, opaqueBackground: .blue, to: panel)
            XCTAssertEqual(panel.isOpaque, opaque, "opacity: \(opacity)")
            XCTAssertEqual(panel.backgroundColor, opaque ? .blue : .clear)
        }
    }

    func testOpaquePanelUpdatesItsBackgroundColor() {
        let panel = makePanel()
        defer { panel.close() }

        for color in [NSColor.red, .blue] {
            WindowAppearance.applyTransparency(opacity: 1, blur: 20, opaqueBackground: color, to: panel)
            XCTAssertEqual(panel.backgroundColor, color)
        }
    }
}
