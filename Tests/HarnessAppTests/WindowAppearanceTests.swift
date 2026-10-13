import AppKit
import XCTest
import HarnessCore
@testable import HarnessApp

@MainActor
final class WindowAppearanceTests: XCTestCase {
    func testStartupNoticeProvidesRecoveryWithoutRestartingUnknownOwners() {
        let view = SessionStartupView()
        XCTAssertEqual(view.heading.stringValue, "Connecting to your sessions…")
        XCTAssertTrue(view.retry.isHidden)
        XCTAssertTrue(view.restart.isHidden)
        view.configure(.blocked(DaemonUpgrade(stats: nil)))
        XCTAssertFalse(view.retry.isHidden)
        XCTAssertTrue(view.restart.isHidden, "An unverified owner cannot offer a destructive restart")
        let stats = DaemonStats(pid: 123, uptimeSeconds: 0, surfaceCount: 3, totalScrollbackBytes: 0,
            clientCount: 0, subscriberCount: 0, snapshotRevision: 0, version: "2.1.0", build: 132)
        view.configure(.blocked(DaemonUpgrade(stats: stats)))
        XCTAssertEqual(view.heading.stringValue, "Finish updating Harness")
        XCTAssertFalse(view.restart.isHidden)
        XCTAssertTrue(view.detail.stringValue.contains("Save your work"))
        var unavailable = stats
        unavailable.daemonAvailable = false
        unavailable.sessionHostProtocolLevel = DaemonStats.currentSessionHostProtocolLevel
        view.configure(.blocked(DaemonUpgrade(stats: unavailable)))
        XCTAssertEqual(view.heading.stringValue, "Reconnect to your sessions")
        XCTAssertFalse(view.retry.isHidden)
        XCTAssertTrue(view.restart.isHidden, "An unavailable worker should offer session-preserving recovery first")
        view.configure(.unavailable)
        XCTAssertEqual(view.heading.stringValue, "Couldn’t load your sessions")
        XCTAssertFalse(view.retry.isHidden)
        XCTAssertTrue(view.restart.isHidden)
    }

    func testBackgroundRefreshCannotHydrateBeforeTheCompatibilityHandshake() async {
        let coordinator = SessionCoordinator.shared
        coordinator.refreshSnapshot()
        let refreshed = await withCheckedContinuation { continuation in
            coordinator.syncFromDaemon { continuation.resume(returning: $0) }
        }
        XCTAssertFalse(refreshed)
        XCTAssertTrue(coordinator.isAwaitingInitialSnapshot)
        XCTAssertTrue(coordinator.snapshot.workspaces.isEmpty)
    }

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
            let terminalHost = try XCTUnwrap(content.subviews.first { $0.subviews.contains { $0 is SessionStartupView } })
            let startup = try XCTUnwrap(terminalHost.subviews.first { $0 is SessionStartupView } as? SessionStartupView)
            XCTAssertFalse(startup.isHidden, "An unhydrated window must have a visible startup state")
            XCTAssertEqual(SessionCoordinator.shared.settings.sidebarVisible, visible)
            window.setContentSize(NSSize(width: 1120, height: 660))
            root.view.layoutSubtreeIfNeeded()
            XCTAssertEqual(content.frame.minX, visible ? HarnessDesign.sidebarWidth : 0, accuracy: 1)
            XCTAssertEqual(content.frame.maxX, split.bounds.maxX, accuracy: 1)
        }
    }

    private func makePanel() -> QuickTerminalPanel {
        _ = NSApplication.shared
        return QuickTerminalPanel(contentRect: NSRect(x: 0, y: 0, width: 100, height: 100))
    }

    func testNotificationsAreUnavailableOutsideAnAppBundle() async throws {
        guard Bundle.main.bundleURL.pathExtension != "app" else { throw XCTSkip("Requires an unpackaged test host") }
        DesktopNotifier.configurePresentation()
        DesktopNotifier.show(title: "Fixture", body: "Must not deliver", withSound: false)
        DesktopNotifier.requestOrOpenSettings()
        var result: String?
        DesktopNotifier.sendTest { result = $0 }
        let clock = ContinuousClock()
        let deadline = clock.now.advanced(by: .seconds(2))
        while result == nil, clock.now < deadline { try await Task.sleep(for: .milliseconds(10)) }
        XCTAssertEqual(result, "Notifications require a packaged macOS application.")
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
