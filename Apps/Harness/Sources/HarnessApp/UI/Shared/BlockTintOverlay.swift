import AppKit
import HarnessTerminalKit

/// Warp-style block output overlay: alternating background tint per command block + action bar on Cmd+Click.
/// Added as a subview of TerminalHostView, filling it entirely — rendered above the Metal surface via CA compositor.
@MainActor
final class BlockTintOverlay: NSView {
    private weak var surfaceView: HarnessTerminalSurfaceView?
    private var topLine = 0
    private var visibleRows = 24
    private var actionBar: BlockActionBar?

    // Even/odd block tint colors (very subtle — readable on any terminal theme)
    private static let evenTint = NSColor.white.withAlphaComponent(0.028)
    private static let oddTint  = NSColor.white.withAlphaComponent(0.058)

    init(surfaceView: HarnessTerminalSurfaceView) {
        self.surfaceView = surfaceView
        super.init(frame: .zero)
        wantsLayer = true
        layer?.isOpaque = false

        surfaceView.onScrollChanged = { [weak self] topLine, _, visibleRows in
            self?.topLine = topLine
            self?.visibleRows = visibleRows
            self?.needsDisplay = true
            self?.dismissActionBar()
        }
        surfaceView.onBlockSelected = { [weak self] start, end in
            self?.needsDisplay = true
            self?.showActionBar(startLine: start, endLine: end)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    // Flipped so row 0 = y=0 (top of view), matching terminal top-down layout
    override var isFlipped: Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        guard let sv = surfaceView, visibleRows > 0 else { return }
        let prompts = sv.promptRows
        guard !prompts.isEmpty else { return }
        let rowH = bounds.height / CGFloat(visibleRows)

        for (i, startLine) in prompts.enumerated() {
            let nextPrompt = i + 1 < prompts.count ? prompts[i + 1] : Int.max
            // Block: from this prompt to (next prompt - 1), clamped to viewport
            let vStart = max(startLine - topLine, 0)
            let vEnd   = min(nextPrompt - 1 - topLine, visibleRows - 1)
            guard vStart < visibleRows, vEnd >= 0, vEnd >= vStart else { continue }
            let rect = NSRect(x: 0, y: CGFloat(vStart) * rowH,
                              width: bounds.width, height: CGFloat(vEnd - vStart + 1) * rowH)
            (i.isMultiple(of: 2) ? Self.evenTint : Self.oddTint).setFill()
            rect.fill()
        }
    }

    // MARK: - Action bar

    private func showActionBar(startLine: Int, endLine: Int) {
        dismissActionBar()
        guard visibleRows > 0 else { return }
        let rowH = bounds.height / CGFloat(visibleRows)
        let blockEndRow = min(endLine - topLine, visibleRows - 1)
        guard blockEndRow >= 0 else { return }
        // Position bar at the bottom-right corner of the block
        let barW: CGFloat = 144, barH: CGFloat = 28
        let barX = bounds.width - barW - 8
        let barY = CGFloat(blockEndRow + 1) * rowH - barH - 4  // 4pt above block bottom edge
        let bar = BlockActionBar(frame: NSRect(x: barX, y: barY, width: barW, height: barH),
                                 surfaceView: surfaceView)
        addSubview(bar)
        actionBar = bar
    }

    private func dismissActionBar() {
        actionBar?.removeFromSuperview()
        actionBar = nil
    }
}

// MARK: - Action bar view

@MainActor
private final class BlockActionBar: NSView {
    private weak var surfaceView: HarnessTerminalSurfaceView?

    init(frame: NSRect, surfaceView: HarnessTerminalSurfaceView?) {
        self.surfaceView = surfaceView
        super.init(frame: frame)
        wantsLayer = true
        layer?.backgroundColor = NSColor(white: 0.10, alpha: 0.90).cgColor
        layer?.cornerRadius = 7
        layer?.cornerCurve = .continuous
        layer?.borderWidth = 0.5
        layer?.borderColor = NSColor.white.withAlphaComponent(0.15).cgColor

        let copyBtn  = makeButton(symbol: "doc.on.doc",  label: "Copy",    action: #selector(copyBlock))
        let aiBtn    = makeButton(symbol: "sparkles",    label: "AI ✦",    action: #selector(aiExplain))
        let stack    = NSStackView(views: [copyBtn, aiBtn])
        stack.orientation = .horizontal
        stack.spacing     = 1
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    private func makeButton(symbol: String, label: String, action: Selector) -> NSButton {
        let btn = NSButton(title: label, target: self, action: action)
        btn.bezelStyle = .regularSquare
        btn.isBordered = false
        btn.font = .systemFont(ofSize: 10.5, weight: .medium)
        if let img = NSImage(systemSymbolName: symbol, accessibilityDescription: nil)?
            .withSymbolConfiguration(.init(pointSize: 10, weight: .medium)) {
            btn.image = img
            btn.imagePosition = .imageLeading
        }
        btn.contentTintColor = NSColor.white.withAlphaComponent(0.85)
        return btn
    }

    @objc private func copyBlock() {
        surfaceView?.copyBlock()
        removeFromSuperview()
    }

    @objc private func aiExplain() {
        guard let sv = surfaceView else { return }
        let text = sv.selectionString ?? ""
        guard !text.isEmpty else { removeFromSuperview(); return }
        sv.onAskAI?("Explain this terminal output:\n\n```\n\(text)\n```")
        removeFromSuperview()
    }
}
