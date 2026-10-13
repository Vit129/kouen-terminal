import AppKit
import Metal
import XCTest
@testable import HarnessTerminalKit

@MainActor
final class MouseReportingViewTests: XCTestCase {
    private var reports: [String] = []

    private func makeView() throws -> (HarnessTerminalSurfaceView, NSWindow) {
        guard MTLCreateSystemDefaultDevice() != nil else { throw XCTSkip("Metal unavailable") }
        let view = HarnessTerminalSurfaceView()
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 640, height: 480), styleMask: [.titled],
                              backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.contentView = view
        view.layoutSubtreeIfNeeded()
        view.testingResizeGrid(cols: 10, rows: 4)
        view.receive("\u{1B}[?1002h\u{1B}[?1006h")
        view.testingWaitForEmulatorIdle()
        reports = []
        view.onInput = { [weak self] data in self?.reports.append(String(decoding: data, as: UTF8.self)) }
        return (view, window)
    }

    private func event(_ type: NSEvent.EventType, at point: NSPoint, in window: NSWindow) -> NSEvent {
        NSEvent.mouseEvent(with: type, location: point, modifierFlags: [], timestamp: 0, windowNumber: window.windowNumber,
                           context: nil, eventNumber: 0, clickCount: 1, pressure: 1)!
    }

    func testDragReportsOncePerCell() throws {
        let (view, window) = try makeView()
        defer { window.contentView = nil; window.close() }
        guard let start = view.testingWindowPoint(row: 1, column: 1),
              let next = view.testingWindowPoint(row: 1, column: 2) else { throw XCTSkip("Cell geometry unavailable") }
        view.mouseDown(with: event(.leftMouseDown, at: start, in: window))
        for dx in [0.5, 1, 1.5, -1] as [CGFloat] {
            view.mouseDragged(with: event(.leftMouseDragged, at: NSPoint(x: start.x + dx, y: start.y), in: window))
        }
        view.mouseDragged(with: event(.leftMouseDragged, at: next, in: window))
        view.mouseDragged(with: event(.leftMouseDragged, at: NSPoint(x: next.x + 1, y: next.y), in: window))
        view.mouseUp(with: event(.leftMouseUp, at: next, in: window))
        XCTAssertEqual(reports, ["\u{1B}[<0;2;2M", "\u{1B}[<32;2;2M", "\u{1B}[<32;3;2M", "\u{1B}[<0;3;2m"])
    }

    func testPressInPaddingIsNotReported() throws {
        let (view, window) = try makeView()
        defer { window.contentView = nil; window.close() }
        guard let cell = view.testingWindowPoint(row: 1, column: 1) else { throw XCTSkip("Cell geometry unavailable") }
        let padding = view.convert(NSPoint(x: view.bounds.maxX - 2, y: view.bounds.minY + 2), to: nil)
        view.mouseDown(with: event(.leftMouseDown, at: padding, in: window))
        view.mouseDragged(with: event(.leftMouseDragged, at: cell, in: window))
        view.mouseUp(with: event(.leftMouseUp, at: cell, in: window))
        view.rightMouseDown(with: event(.rightMouseDown, at: padding, in: window))
        view.rightMouseUp(with: event(.rightMouseUp, at: cell, in: window))
        XCTAssertEqual(reports, [], "a press outside the grid, and its drag and release, stay local")

        view.mouseDown(with: event(.leftMouseDown, at: cell, in: window))
        view.mouseDragged(with: event(.leftMouseDragged, at: padding, in: window))
        view.mouseUp(with: event(.leftMouseUp, at: padding, in: window))
        XCTAssertEqual(reports, ["\u{1B}[<0;2;2M", "\u{1B}[<32;10;4M", "\u{1B}[<0;10;4m"],
                       "a press on the grid keeps reporting, clamped to the edge, until release")
    }
}
