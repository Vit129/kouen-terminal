import AppKit
import KouenCore

/// Overlay drawn on a pane during drag-over to show drop zones (L/R/T/B/Center).
@MainActor
final class PaneDropZoneOverlay: NSView {
    enum Zone: Equatable {
        case left, right, top, bottom, center, none
    }

    private(set) var activeZone: Zone = .none
    let targetPaneID: PaneID
    /// When true, center zone (swap) is disabled — only edge zones are shown.
    var disableCenter = false

    private let highlightLayer = CAShapeLayer()

    init(targetPaneID: PaneID) {
        self.targetPaneID = targetPaneID
        super.init(frame: .zero)
        wantsLayer = true
        layer?.zPosition = 2000

        highlightLayer.fillColor = NSColor.controlAccentColor.withAlphaComponent(0.15).cgColor
        highlightLayer.strokeColor = NSColor.controlAccentColor.withAlphaComponent(0.6).cgColor
        highlightLayer.lineWidth = 2
        highlightLayer.cornerRadius = 6
        highlightLayer.opacity = 0
        layer?.addSublayer(highlightLayer)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override func layout() {
        super.layout()
        highlightLayer.frame = bounds
        if activeZone != .none { updateHighlight() }
    }

    func updateZone(for point: NSPoint) {
        let newZone = zone(at: point)
        guard newZone != activeZone else { return }
        activeZone = newZone
        updateHighlight()
    }

    func clear() {
        guard activeZone != .none else { return }
        activeZone = .none
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.15)
        highlightLayer.opacity = 0
        CATransaction.commit()
    }

    override func hitTest(_ point: NSPoint) -> NSView? { nil }

    // MARK: - Highlight

    private func updateHighlight() {
        let rect = zoneRect(activeZone)
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.12)
        if activeZone == .none {
            highlightLayer.opacity = 0
        } else {
            highlightLayer.path = CGPath(roundedRect: rect, cornerWidth: 6, cornerHeight: 6, transform: nil)
            highlightLayer.opacity = 1
        }
        CATransaction.commit()
    }

    // MARK: - Zone geometry

    private func zone(at point: NSPoint) -> Zone {
        let b = bounds
        guard b.width > 0, b.height > 0 else { return .none }

        if !disableCenter {
            let insetX = b.width * 0.3
            let insetY = b.height * 0.3
            let center = b.insetBy(dx: insetX, dy: insetY)
            if center.contains(point) { return .center }
        }

        // Edge: use proportional distance to determine closest edge
        let fracX = point.x / b.width   // 0=left, 1=right
        let fracY = point.y / b.height  // 0=bottom, 1=top

        let distLeft = fracX
        let distRight = 1 - fracX
        let distBottom = fracY
        let distTop = 1 - fracY

        let minDist = min(distLeft, distRight, distBottom, distTop)
        if minDist == distLeft { return .left }
        if minDist == distRight { return .right }
        if minDist == distTop { return .top }
        return .bottom
    }

    private func zoneRect(_ zone: Zone) -> NSRect {
        let b = bounds
        let pad: CGFloat = 6
        switch zone {
        case .left: return NSRect(x: pad, y: pad, width: b.width * 0.5 - pad, height: b.height - pad * 2)
        case .right: return NSRect(x: b.width * 0.5, y: pad, width: b.width * 0.5 - pad, height: b.height - pad * 2)
        case .top: return NSRect(x: pad, y: b.height * 0.5, width: b.width - pad * 2, height: b.height * 0.5 - pad)
        case .bottom: return NSRect(x: pad, y: pad, width: b.width - pad * 2, height: b.height * 0.5 - pad)
        case .center: return b.insetBy(dx: b.width * 0.25, dy: b.height * 0.25)
        case .none: return .zero
        }
    }
}
