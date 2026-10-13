import AppKit
import HarnessCore
import Metal
import XCTest
@testable import HarnessApp
@testable import HarnessTerminalKit

@MainActor
final class PaneLayoutTests: XCTestCase {
    private final class Content: NSView {
        var mounts = 0
        var removals = 0
        override var acceptsFirstResponder: Bool { true }
        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            if window == nil { removals += 1 } else { mounts += 1 }
        }
    }

    private func fixture(_ node: PaneNode) -> (NSWindow, PaneContainerView) {
        _ = NSApplication.shared
        let container = PaneContainerView(tabID: UUID(), owner: DaemonSidebar.localID,
            node: node, cwd: "/tmp",
            contentProvider: { _ in Content() })
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 960, height: 640),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.contentView = container
        container.layoutSubtreeIfNeeded()
        return (window, container)
    }

    func testSplitAndCloseKeepSurvivorsMountedAndFocused() throws {
        let first = PaneLeaf(), second = PaneLeaf(), third = PaneLeaf()
        let (window, container) = fixture(.leaf(first))
        defer { window.close() }
        let island = try XCTUnwrap(container.island(for: first.surfaceID))
        let content = try XCTUnwrap(island.contentView as? Content)
        XCTAssertTrue(window.makeFirstResponder(content))
        let initial = island.frame
        for _ in 0..<20 {
            let split = PaneNode.branch(direction: .horizontal, ratio: 0.37, first: .leaf(first),
                second: .branch(direction: .vertical, ratio: 0.64, first: .leaf(second), second: .leaf(third)))
            container.update(node: split, animated: false)
            XCTAssertTrue(container.island(for: first.surfaceID) === island)
            XCTAssertTrue(window.firstResponder === content)
            XCTAssertEqual(content.mounts, 1)
            XCTAssertEqual(content.removals, 0)
            XCTAssertLessThan(island.frame.width, initial.width / 2)
            let upper = try XCTUnwrap(container.island(for: second.surfaceID))
            let lower = try XCTUnwrap(container.island(for: third.surfaceID))
            XCTAssertGreaterThan(upper.frame.midY, lower.frame.midY)
            let closed = try XCTUnwrap(lower.contentView as? Content)
            container.update(node: .leaf(first), animated: false)
            XCTAssertEqual(island.frame, initial)
            XCTAssertTrue(window.firstResponder === content)
            XCTAssertEqual(content.removals, 0)
            XCTAssertNil(closed.window)
            XCTAssertEqual(closed.removals, 1)
        }
    }

    func testInterruptedCloseUsesActualContentAndSettlesAtLatestLayout() throws {
        let first = PaneLeaf(), second = PaneLeaf(), third = PaneLeaf()
        let split = PaneNode.branch(direction: .horizontal, ratio: 0.5, first: .leaf(first), second: .leaf(second))
        let (window, container) = fixture(split)
        defer { window.close() }
        let survivor = try XCTUnwrap(container.island(for: first.surfaceID))
        let closing = try XCTUnwrap(container.island(for: second.surfaceID))
        let content = try XCTUnwrap(survivor.contentView as? Content)
        let old = survivor.frame
        container.update(node: .leaf(first), animated: true)
        if let transition = container.transition {
            XCTAssertTrue(closing.superview === container, "Retain the real closing pane until its neighbor covers it")
            XCTAssertNil(closing.hitTest(closing.frame.origin), "A closed pane must not accept more input")
            XCTAssertEqual(survivor.frame, old)
            transition.apply(progress: 0.5)
            XCTAssertGreaterThan(survivor.frame.width, old.width)
        }
        container.update(node: .branch(direction: .vertical, ratio: 0.4, first: .leaf(first), second: .leaf(third)), animated: true)
        container.transition?.apply(progress: 0.3)
        window.setContentSize(NSSize(width: 1100, height: 720))
        container.layoutSubtreeIfNeeded()
        XCTAssertNil(container.transition, "Window resizing must retire the old geometry animation")
        XCTAssertNil(closing.superview)
        XCTAssertEqual(content.mounts, 1)
        XCTAssertEqual(content.removals, 0)
        let lower = try XCTUnwrap(container.island(for: third.surfaceID))
        XCTAssertGreaterThan(survivor.frame.midY, lower.frame.midY)
        XCTAssertEqual(survivor.frame.width, lower.frame.width, accuracy: 0.5)
        XCTAssertEqual(survivor.frame.maxX, container.bounds.maxX - survivor.frame.minX, accuracy: 1)
    }

    func testSavedRatiosAreCorrectOnFirstLayoutAndStayStableAcrossResizing() {
        for vertical in [false, true] {
            let split = HarnessSplitView(frame: NSRect(x: 0, y: 0, width: 800, height: 600))
            split.isVertical = vertical
            split.tabID = UUID(); split.firstPaneID = UUID(); split.secondPaneID = UUID()
            split.preferredRatio = 0.27
            split.addSubview(NSView())
            split.addSubview(NSView())
            for size in [NSSize(width: 800, height: 600), NSSize(width: 1020, height: 740), NSSize(width: 640, height: 420)] {
                split.frame.size = size
                split.resizeSubviews(withOldSize: .zero)
                let total = (vertical ? size.width : size.height) - split.dividerThickness
                let length = vertical ? split.subviews[0].frame.width : split.subviews[0].frame.height
                XCTAssertEqual(length, total * 0.27, accuracy: 0.5)
                XCTAssertEqual(split.preferredRatio, 0.27, accuracy: 0.0001)
            }
            split.adopt(ratio: 0.273)
            XCTAssertEqual(split.preferredRatio, 0.273, accuracy: 0.0001, "Small but visible ratio changes cannot be discarded")
            XCTAssertFalse(split.isSavingRatio, "Programmatic layout notifications must never write a user divider position")
        }
    }

    func testDividerHitTestingWorksAboveRetainedContent() throws {
        let first = PaneLeaf(), second = PaneLeaf()
        let (window, container) = fixture(.branch(direction: .horizontal, ratio: 0.5, first: .leaf(first), second: .leaf(second)))
        defer { window.close() }
        let left = try XCTUnwrap(container.island(for: first.surfaceID))
        let right = try XCTUnwrap(container.island(for: second.surfaceID))
        let point = NSPoint(x: (left.frame.maxX + right.frame.minX) / 2, y: left.frame.midY)
        XCTAssertTrue(container.hitTest(container.convert(point, to: container.superview)) is HarnessSplitView)
        let inside = NSPoint(x: left.frame.midX, y: left.frame.midY)
        XCTAssertTrue(container.hitTest(container.convert(inside, to: container.superview)) === left.contentView)
    }

    func testAnimatedSplitAndClosePreserveMetalResourcesAndCoalescePTYResizes() async throws {
        guard MTLCreateSystemDefaultDevice() != nil else { throw XCTSkip("Metal unavailable") }
        let first = PaneLeaf(), second = PaneLeaf()
        var views: [SurfaceID: HarnessTerminalSurfaceView] = [:]
        let container = PaneContainerView(tabID: UUID(), owner: DaemonSidebar.localID, node: .leaf(first), cwd: "/tmp") { leaf in
            let view = HarnessTerminalSurfaceView()
            views[leaf.surfaceID] = view
            return view
        }
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 960, height: 640),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        defer { window.contentView = nil; window.close() }
        window.contentView = container
        container.layoutSubtreeIfNeeded()
        let view = try XCTUnwrap(views[first.surfaceID])
        guard view.testingHasRenderer else { throw XCTSkip("Renderer unavailable") }
        view.receive("preserved output")
        view.testingWaitForEmulatorIdle()
        let layer = view.testingMetalLayer, renderer = view.testingRendererIdentity
        var resizes: [(Int, Int)] = []
        view.onResize = { resizes.append(($0, $1)) }
        let split = PaneNode.branch(direction: .horizontal, ratio: 0.5, first: .leaf(first), second: .leaf(second))
        for node in [split, .leaf(first)] {
            resizes.removeAll()
            container.update(node: node, animated: true)
            for step in 0...12 { container.transition?.apply(progress: Double(step) / 12) }
            container.finishTransition()
            try await Task.sleep(for: .milliseconds(150))
            view.testingWaitForEmulatorIdle()
            XCTAssertTrue(view.testingMetalLayer === layer, "A surviving pane must never discard its drawable pool")
            XCTAssertEqual(view.testingRendererIdentity, renderer)
            XCTAssertEqual(resizes.count, 1, "An animation must settle to one authoritative PTY resize")
            XCTAssertGreaterThan(resizes.first?.0 ?? 0, 1)
            XCTAssertEqual(view.testingReadGridSnapshot().cell(row: 0, col: 0)?.codepoint, 112)
        }
    }

    func testContentKindChangesReplaceOnlyTheAffectedIsland() throws {
        let first = PaneLeaf(), second = PaneLeaf()
        let node = PaneNode.branch(direction: .horizontal, ratio: 0.5, first: .leaf(first), second: .leaf(second))
        let (window, container) = fixture(node)
        defer { window.close() }
        let unchanged = try XCTUnwrap(container.island(for: first.surfaceID))
        let old = try XCTUnwrap(container.island(for: second.surfaceID))
        var replacement = second
        replacement.content = .unsupported(kind: "future-pane", payload: [:])
        container.update(node: .branch(direction: .horizontal, ratio: 0.5, first: .leaf(first), second: .leaf(replacement)), animated: true)
        XCTAssertTrue(container.island(for: first.surfaceID) === unchanged)
        XCTAssertFalse(container.island(for: second.surfaceID) === old)
        XCTAssertNil(old.superview)
        XCTAssertNil(container.transition)
    }

    func testRemoteRatioChangeInterruptsAnimationWithoutRemounting() throws {
        let first = PaneLeaf(), second = PaneLeaf()
        let (window, container) = fixture(.leaf(first))
        defer { window.close() }
        let original = try XCTUnwrap(container.island(for: first.surfaceID))
        container.update(node: .branch(direction: .horizontal, ratio: 0.5, first: .leaf(first), second: .leaf(second)), animated: true)
        container.transition?.apply(progress: 0.25)
        container.applyRatios(from: .branch(direction: .horizontal, ratio: 0.7, first: .leaf(first), second: .leaf(second)))
        XCTAssertNil(container.transition)
        XCTAssertTrue(container.island(for: first.surfaceID) === original)
        let right = try XCTUnwrap(container.island(for: second.surfaceID))
        XCTAssertGreaterThan(original.frame.width, right.frame.width * 2)
        XCTAssertEqual((original.contentView as? Content)?.removals, 0)
    }

    func testPaneDensitiesKeepCorrectGapsHeadersAndDividerTargets() throws {
        let saved = SessionCoordinator.shared.settings
        defer { SessionCoordinator.shared.settings = saved }
        for density in [PaneDensity.compact, .comfortable] {
            for headers in [false, true] {
                SessionCoordinator.shared.settings.paneDensity = density
                SessionCoordinator.shared.settings.paneHeaders = headers
                let first = PaneLeaf(), second = PaneLeaf()
                let (window, container) = fixture(.branch(direction: .horizontal, ratio: 0.5, first: .leaf(first), second: .leaf(second)))
                defer { window.close() }
                let left = try XCTUnwrap(container.island(for: first.surfaceID))
                let right = try XCTUnwrap(container.island(for: second.surfaceID))
                let gap = density == .comfortable ? saved.paneSpacing : 1
                XCTAssertEqual(right.frame.minX - left.frame.maxX, gap, accuracy: 0.5)
                XCTAssertEqual(left.header != nil, density == .comfortable && headers)
                let point = NSPoint(x: (left.frame.maxX + right.frame.minX) / 2, y: left.frame.midY)
                XCTAssertTrue(container.hitTest(container.convert(point, to: container.superview)) is HarnessSplitView)
                container.update(node: .leaf(first), animated: false)
                XCTAssertTrue(container.island(for: first.surfaceID) === left)
                XCTAssertGreaterThan(left.contentView?.bounds.height ?? 0, 0)
            }
        }
    }

    func testTranslucentTransitionsNeverCompositeTwoTerminalContentsAtTheSamePixel() throws {
        let first = PaneLeaf(), second = PaneLeaf()
        let (window, container) = fixture(.leaf(first))
        defer { window.close() }
        let split = PaneNode.branch(direction: .horizontal, ratio: 0.5, first: .leaf(first), second: .leaf(second))
        container.update(node: split, animated: true)
        let left = try XCTUnwrap(container.island(for: first.surfaceID))
        let right = try XCTUnwrap(container.island(for: second.surfaceID))
        if let transition = container.transition {
            for progress in [0.0, 0.2, 0.5, 0.8] {
                transition.apply(progress: progress)
                let overlap = left.frame.intersection(right.frame)
                if !overlap.isEmpty {
                    let point = right.convert(NSPoint(x: overlap.midX, y: overlap.midY), from: container)
                    XCTAssertFalse(try XCTUnwrap(right.transitionMask).contains(point))
                }
            }
        }
        container.finishTransition()
        XCTAssertNil(right.transitionMask)
        container.update(node: .leaf(first), animated: true)
        if let transition = container.transition {
            transition.apply(progress: 0.5)
            let overlap = left.frame.intersection(right.frame)
            XCTAssertFalse(overlap.isEmpty)
            let point = right.convert(NSPoint(x: overlap.midX, y: overlap.midY), from: container)
            XCTAssertFalse(try XCTUnwrap(right.transitionMask).contains(point))
        }
        container.finishTransition()
        XCTAssertNil(left.transitionMask)
        XCTAssertNil(right.superview)
    }
}
