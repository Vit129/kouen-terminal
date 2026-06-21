import AppKit
import HarnessCore

/// Overlay drawn on a pane during a drag-over to show L/R/T/B/Center drop zones.
@MainActor
final class PaneDropZoneOverlay: NSView {
    enum Zone: Equatable {
        case left, right, top, bottom, center, none
    }

    private(set) var activeZone: Zone = .none
    let targetPaneID: PaneID

    init(targetPaneID: PaneID) {
        self.targetPaneID = targetPaneID
        super.init(frame: .zero)
        wantsLayer = true
        layer?.zPosition = 2000
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    func updateZone(for point: NSPoint) {
        let old = activeZone
        activeZone = zone(at: point)
        if old != activeZone { needsDisplay = true }
    }

    func clear() {
        activeZone = .none
        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        guard activeZone != .none else { return }
        let rect = zoneRect(activeZone)
        let path = NSBezierPath(roundedRect: rect, xRadius: 6, yRadius: 6)
        NSColor.controlAccentColor.withAlphaComponent(0.2).setFill()
        path.fill()
        NSColor.controlAccentColor.withAlphaComponent(0.5).setStroke()
        path.lineWidth = 2
        path.stroke()
    }

    override func hitTest(_ point: NSPoint) -> NSView? { nil }

    // MARK: - Zone geometry

    private func zone(at point: NSPoint) -> Zone {
        let b = bounds
        guard b.width > 0, b.height > 0 else { return .none }
        let insetX = b.width * 0.25
        let insetY = b.height * 0.25
        let center = b.insetBy(dx: insetX, dy: insetY)
        if center.contains(point) { return .center }
        // Edge detection by which edge is closest
        let distLeft = point.x
        let distRight = b.width - point.x
        let distBottom = point.y
        let distTop = b.height - point.y
        let minDist = min(distLeft, distRight, distBottom, distTop)
        if minDist == distLeft { return .left }
        if minDist == distRight { return .right }
        if minDist == distTop { return .top }
        return .bottom
    }

    private func zoneRect(_ zone: Zone) -> NSRect {
        let b = bounds
        switch zone {
        case .left: return NSRect(x: 0, y: 0, width: b.width * 0.5, height: b.height).insetBy(dx: 4, dy: 4)
        case .right: return NSRect(x: b.width * 0.5, y: 0, width: b.width * 0.5, height: b.height).insetBy(dx: 4, dy: 4)
        case .top: return NSRect(x: 0, y: b.height * 0.5, width: b.width, height: b.height * 0.5).insetBy(dx: 4, dy: 4)
        case .bottom: return NSRect(x: 0, y: 0, width: b.width, height: b.height * 0.5).insetBy(dx: 4, dy: 4)
        case .center: return b.insetBy(dx: b.width * 0.25, dy: b.height * 0.25)
        case .none: return .zero
        }
    }
}
