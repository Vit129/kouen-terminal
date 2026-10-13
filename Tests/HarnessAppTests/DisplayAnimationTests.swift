import AppKit
import XCTest
@testable import HarnessApp

@MainActor
final class DisplayAnimationTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        MainActor.assumeIsolated { _ = NSApplication.shared }
    }

    private func makeWindow() -> NSWindow {
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 200, height: 100),
                              styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.orderFrontRegardless()
        return window
    }

    private func spin(until condition: () -> Bool, timeout: TimeInterval = 3) {
        let deadline = Date().addingTimeInterval(timeout)
        while !condition(), Date() < deadline {
            RunLoop.main.run(until: Date().addingTimeInterval(0.005))
        }
    }

    func testRunsFromZeroToOneThenCompletesOnce() throws {
        let window = makeWindow()
        defer { window.close() }
        var steps: [Double] = []
        var completions = 0
        let animation = DisplayAnimation(duration: 0.08, step: { steps.append($0) }, completion: { completions += 1 })
        animation.start(on: try XCTUnwrap(window.contentView))
        spin(until: { completions > 0 })
        XCTAssertEqual(completions, 1)
        XCTAssertEqual(steps.first, 0)
        XCTAssertEqual(steps.last, 1)
        XCTAssertEqual(steps, steps.sorted(), "progress never moves backward")
        XCTAssertGreaterThan(steps.count, 2, "frames arrive between the endpoints")
        XCTAssertFalse(animation.isRunning)
    }

    func testCancelStopsWithoutCompleting() throws {
        let window = makeWindow()
        defer { window.close() }
        var completions = 0
        var steps = 0
        let animation = DisplayAnimation(duration: 0.2, step: { _ in steps += 1 }, completion: { completions += 1 })
        animation.start(on: try XCTUnwrap(window.contentView))
        animation.cancel()
        let afterCancel = steps
        spin(until: { false }, timeout: 0.3)
        XCTAssertEqual(steps, afterCancel)
        XCTAssertEqual(completions, 0)
    }
}
