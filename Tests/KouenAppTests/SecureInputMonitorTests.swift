import Foundation
import XCTest
@testable import KouenApp

@MainActor
final class SecureInputMonitorTests: XCTestCase {
    private final class Focus {
        var isFocused = true
    }

    private func drain(_ queue: DispatchQueue) async {
        // The serial scan queue enqueues its main-thread result before this barrier.
        let drained = expectation(description: "scan results delivered")
        queue.async { DispatchQueue.main.async { drained.fulfill() } }
        await fulfillment(of: [drained], timeout: 2)
    }

    func test_TC0902_FE_IT_pendingScanCannotRearmAfterRelease() async {
        let queue = DispatchQueue(label: "test.secure-input.release")
        var enables = 0
        let monitor = SecureInputMonitor(scanQueue: queue, enable: { enables += 1 }, disable: {})
        let id = UUID()
        monitor.scanOutput(Data("Password: ".utf8), for: id, isFocused: { true })
        monitor.release(id)
        await drain(queue)
        XCTAssertEqual(enables, 0, "a released/retired surface must reject its pending scan")
        monitor.release(id)
    }

    func test_TC0902_FE_IT_focusIsRecheckedWhenScanResultArrives() async {
        let queue = DispatchQueue(label: "test.secure-input.focus")
        var enables = 0
        let focus = Focus()
        let monitor = SecureInputMonitor(scanQueue: queue, enable: { enables += 1 }, disable: {})
        let id = UUID()
        monitor.scanOutput(Data("Password: ".utf8), for: id, isFocused: { focus.isFocused })
        focus.isFocused = false
        await drain(queue)
        XCTAssertEqual(enables, 0, "a background pane must not arm from an earlier focused chunk")
        monitor.release(id)
    }

    func test_TC0902_FE_IT_newPromptAfterReleaseCanStillArm() async {
        let queue = DispatchQueue(label: "test.secure-input.new-prompt")
        var enables = 0
        var disables = 0
        let monitor = SecureInputMonitor(scanQueue: queue, enable: { enables += 1 }, disable: { disables += 1 })
        let id = UUID()
        monitor.scanOutput(Data("Password: ".utf8), for: id, isFocused: { true })
        await drain(queue)
        XCTAssertEqual(enables, 1)
        monitor.release(id)
        XCTAssertEqual(disables, 1)

        monitor.scanOutput(Data("Pass".utf8), for: id, isFocused: { true })
        monitor.scanOutput(Data("word: ".utf8), for: id, isFocused: { true })
        await drain(queue)
        XCTAssertEqual(enables, 2)
        monitor.release(id)
        XCTAssertEqual(disables, 2)
    }

    func test_TC0902_FE_IT_oldScanCannotArmNewGenerationForSameSurface() async {
        let queue = DispatchQueue(label: "test.secure-input.generation")
        var enables = 0
        let monitor = SecureInputMonitor(scanQueue: queue, enable: { enables += 1 }, disable: {})
        let id = UUID()
        monitor.scanOutput(Data("Password: ".utf8), for: id, isFocused: { true })
        monitor.release(id)
        monitor.scanOutput(Data("new command output".utf8), for: id, isFocused: { true })
        await drain(queue)
        XCTAssertEqual(enables, 0, "a fresh generation must not accept the old prompt's result")
        monitor.release(id)
    }
}
