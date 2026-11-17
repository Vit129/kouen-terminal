import AppKit
import XCTest
import KouenCore
@testable import KouenApp

final class MenuBarControllerTests: XCTestCase {
    @MainActor
    func test_TS_2402_FE_IT_menuBarIconStartsHiddenWhenDisabled() {
        let controller = MenuBarController(visibilityProvider: { false })
        defer { NSStatusBar.system.removeStatusItem(controller.statusItem) }
        XCTAssertFalse(controller.statusItem.isVisible)
        XCTAssertNotNil(controller.statusItem.menu)
    }

    @MainActor
    func test_TS_2403_FE_IT_settingsChangesHideAndRestoreTheSameMenu() {
        var visible = true
        let controller = MenuBarController(visibilityProvider: { visible })
        defer { NSStatusBar.system.removeStatusItem(controller.statusItem) }
        let menu = controller.statusItem.menu
        XCTAssertTrue(controller.statusItem.isVisible)
        for value in [false, true, false, true] {
            visible = value
            NotificationCenter.default.post(name: NotificationBus.shared.snapshotChanged, object: nil)
            XCTAssertEqual(controller.statusItem.isVisible, value)
            XCTAssertTrue(controller.statusItem.menu === menu)
        }
    }
}
