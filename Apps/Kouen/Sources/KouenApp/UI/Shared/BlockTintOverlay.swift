import AppKit
import KouenTerminalKit

/// Warp-style block output overlay: per-command tint, rounded border, collapse/expand.
/// Added as a subview of TerminalHostView filling it entirely — rendered above the Metal surface via CA compositor.
/// Block *actions* (Copy Output/Command Only, Re-run) live on the right-click context menu
/// (`KouenTerminalSurfaceView.menu(for:)`) — not here; a ⌘-click-triggered floating action bar
/// was tried first and dropped for poor discoverability (no on-screen hint).
@MainActor
final class BlockTintOverlay: NSView {
    private weak var surfaceView: KouenTerminalSurfaceView?
    private var topLine = 0
    private var visibleRows = 24
    private var collapsedBlocks = Set<Int>()  // buffer-line indices of collapsed prompt rows
    private var cachedPromptRows: [Int] = []  // refreshed on command-finish, not on every draw/hitTest

    private static let evenTint   = NSColor.white.withAlphaComponent(0.028)
    private static let oddTint    = NSColor.white.withAlphaComponent(0.055)
    private static let borderColor = NSColor.white.withAlphaComponent(0.10)
    private static let collapseW: CGFloat = 18  // gutter width for collapse triangles

    init(surfaceView: KouenTerminalSurfaceView) {
        self.surfaceView = surfaceView
        super.init(frame: .zero)
        wantsLayer = true
        layer?.isOpaque = false

        // Seed prompt cache once — no lock held during mouse moves or draws after this.
        cachedPromptRows = surfaceView.promptRows

        // Chain onScrollChanged — the previous closure wires the transient scrollbar; don't
        // replace it or the scrollbar goes dark the moment this overlay is installed.
        let prevScroll = surfaceView.onScrollChanged
        surfaceView.onScrollChanged = { [weak self] topLine, totalLines, visibleRows in
            prevScroll?(topLine, totalLines, visibleRows)
            self?.topLine = topLine
            self?.visibleRows = visibleRows
            // Only redraw if there are visible blocks — avoids CPU draw on every scroll
            // tick when the terminal has no OSC 133-delimited prompt rows.
            if let self, !self.cachedPromptRows.isEmpty || !self.collapsedBlocks.isEmpty {
                self.needsDisplay = true
            }
        }

        // Refresh prompt cache when a new shell prompt appears (OSC 133 command-finish).
        // emulatorSync is called once per command, not on every mouse move or draw tick.
        let prevFinished = surfaceView.onCommandFinished
        surfaceView.onCommandFinished = { [weak self, weak surfaceView] duration, exitCode in
            prevFinished?(duration, exitCode)
            self?.cachedPromptRows = surfaceView?.promptRows ?? []
            self?.needsDisplay = true
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override var isFlipped: Bool { true }

    // MARK: - Drawing

    override func draw(_ dirtyRect: NSRect) {
        guard visibleRows > 0 else { return }
        let prompts = cachedPromptRows
        guard !prompts.isEmpty else { return }
        let rowH = bounds.height / CGFloat(visibleRows)

        for (i, startLine) in prompts.enumerated() {
            let nextPrompt = i + 1 < prompts.count ? prompts[i + 1] : Int.max
            let collapsed = collapsedBlocks.contains(startLine)

            // Viewport rows
            let vStart = max(startLine - topLine, 0)
            let rawEnd = collapsed ? startLine : (nextPrompt - 1)  // collapsed = only prompt row visible
            let vEnd   = min(rawEnd - topLine, visibleRows - 1)
            guard vStart < visibleRows, vEnd >= 0, vEnd >= vStart else {
                // Block entirely off-screen — still draw triangle if prompt is visible
                drawTriangle(row: startLine - topLine, rowH: rowH, collapsed: collapsed)
                continue
            }

            let blockRect = NSRect(x: 0, y: CGFloat(vStart) * rowH,
                                   width: bounds.width, height: CGFloat(vEnd - vStart + 1) * rowH)

            // Tint
            (i.isMultiple(of: 2) ? Self.evenTint : Self.oddTint).setFill()
            blockRect.fill()

            // Rounded border
            let borderPath = NSBezierPath(roundedRect: blockRect.insetBy(dx: 0.5, dy: 0.5), xRadius: 4, yRadius: 4)
            borderPath.lineWidth = 0.5
            Self.borderColor.setStroke()
            borderPath.stroke()

            // Collapsed cover
            if collapsed {
                let outputStart = startLine + 1
                let coveredLines = nextPrompt - outputStart
                if coveredLines > 0 {
                    let coverY = CGFloat(vEnd + 1) * rowH
                    let coverRect = NSRect(x: 0, y: coverY, width: bounds.width, height: rowH * 0.75)
                    NSColor.black.withAlphaComponent(0.75).setFill()
                    NSBezierPath(roundedRect: coverRect, xRadius: 4, yRadius: 4).fill()
                    let label = "▶  \(coveredLines) line\(coveredLines == 1 ? "" : "s") hidden"
                    let attrs: [NSAttributedString.Key: Any] = [
                        .font: NSFont.monospacedSystemFont(ofSize: 10.5, weight: .regular),
                        .foregroundColor: NSColor.white.withAlphaComponent(0.42),
                    ]
                    label.draw(at: NSPoint(x: Self.collapseW + 4, y: coverY + 6), withAttributes: attrs)
                }
            }

            // Collapse triangle on prompt row
            drawTriangle(row: vStart, rowH: rowH, collapsed: collapsed)
        }
    }

    private func drawTriangle(row: Int, rowH: CGFloat, collapsed: Bool) {
        guard row >= 0, row < visibleRows else { return }
        let cy = CGFloat(row) * rowH + rowH / 2
        let cx: CGFloat = 8
        let path = NSBezierPath()
        if collapsed {
            // ▶ right-pointing
            path.move(to: NSPoint(x: cx - 3, y: cy - 4))
            path.line(to: NSPoint(x: cx + 4, y: cy))
            path.line(to: NSPoint(x: cx - 3, y: cy + 4))
        } else {
            // ▼ down-pointing
            path.move(to: NSPoint(x: cx - 4, y: cy - 2))
            path.line(to: NSPoint(x: cx + 4, y: cy - 2))
            path.line(to: NSPoint(x: cx, y: cy + 3))
        }
        path.close()
        NSColor.white.withAlphaComponent(0.35).setFill()
        path.fill()
    }

    // MARK: - Hit testing (pass-through except triangle gutter + action bar)

    override func hitTest(_ point: NSPoint) -> NSView? {
        for sub in subviews.reversed() {
            let local = sub.convert(point, from: self)
            if let hit = sub.hitTest(local) { return hit }
        }
        guard visibleRows > 0 else { return nil }
        let rowH = bounds.height / CGFloat(visibleRows)
        for startLine in cachedPromptRows {
            let vRow = startLine - topLine
            guard vRow >= 0, vRow < visibleRows else { continue }
            if NSRect(x: 0, y: CGFloat(vRow) * rowH, width: Self.collapseW, height: rowH).contains(point) {
                return self
            }
        }
        return nil
    }

    override func mouseDown(with event: NSEvent) {
        let pt = convert(event.locationInWindow, from: nil)
        guard visibleRows > 0 else { return }
        let rowH = bounds.height / CGFloat(visibleRows)
        for startLine in cachedPromptRows {
            let vRow = startLine - topLine
            guard vRow >= 0, vRow < visibleRows else { continue }
            if NSRect(x: 0, y: CGFloat(vRow) * rowH, width: Self.collapseW, height: rowH).contains(pt) {
                if collapsedBlocks.contains(startLine) { collapsedBlocks.remove(startLine) }
                else { collapsedBlocks.insert(startLine) }
                needsDisplay = true
                return
            }
        }
    }

}
