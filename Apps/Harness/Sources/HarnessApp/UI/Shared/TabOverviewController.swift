import AppKit
import HarnessCore
import HarnessTerminalKit

/// Tab Overview — ⌘⇧\ opens a panel showing all tabs as thumbnails; click to switch.
@MainActor
final class TabOverviewController {
    static let shared = TabOverviewController()
    private var panel: NSPanel?
    private init() {}

    func toggle() {
        if let p = panel, p.isVisible { dismiss(); return }
        present()
    }

    private func dismiss() {
        panel?.orderOut(nil)
        panel = nil
    }

    private func present() {
        let coord = SessionCoordinator.shared
        guard let ws = coord.snapshot.activeWorkspace else { return }
        let tabs = ws.tabs
        guard !tabs.isEmpty else { return }
        let wsID = ws.id

        // Grid constants
        let cellW: CGFloat = 200, cellH: CGFloat = 150, gap: CGFloat = 12, cols = 4
        let rows = (tabs.count + cols - 1) / cols
        let gridW = CGFloat(min(tabs.count, cols)) * (cellW + gap) + gap
        let gridH = CGFloat(rows) * (cellH + gap) + gap
        let screenH = NSScreen.main?.visibleFrame.height ?? 800
        let panelW = gridW, panelH = min(gridH + 8, screenH * 0.85)

        let screen = NSScreen.main ?? NSScreen.screens[0]
        let panelFrame = NSRect(
            x: screen.frame.midX - panelW / 2,
            y: screen.frame.midY - panelH / 2,
            width: panelW, height: panelH)

        let p = NSPanel(contentRect: panelFrame,
                        styleMask: [.titled, .closable, .fullSizeContentView, .nonactivatingPanel],
                        backing: .buffered, defer: false)
        p.isFloatingPanel = true
        p.level = .floating
        p.title = ""
        p.titlebarAppearsTransparent = true
        p.titleVisibility = .hidden
        p.collectionBehavior = [.canJoinAllSpaces]

        let blur = NSVisualEffectView(frame: .zero)
        blur.material = .hudWindow
        blur.blendingMode = .behindWindow
        blur.state = .active
        blur.translatesAutoresizingMaskIntoConstraints = false
        p.contentView?.addSubview(blur)
        if let cv = p.contentView {
            NSLayoutConstraint.activate([
                blur.topAnchor.constraint(equalTo: cv.topAnchor),
                blur.leadingAnchor.constraint(equalTo: cv.leadingAnchor),
                blur.trailingAnchor.constraint(equalTo: cv.trailingAnchor),
                blur.bottomAnchor.constraint(equalTo: cv.bottomAnchor),
            ])
        }

        let container = NSView()
        var y = gridH - cellH - gap
        for (i, tab) in tabs.enumerated() {
            let col = i % cols
            let row = i / cols
            let x = gap + CGFloat(col) * (cellW + gap)
            y = gridH - CGFloat(row + 1) * (cellH + gap)
            let image = tab.rootPane.allSurfaceIDs().first
                .flatMap { coord.terminalHostIfExists(for: $0) }
                .flatMap { $0.surfaceView.renderThumbnail(size: NSSize(width: cellW - 8, height: cellH - 28)) }
            let title = tab.title.isEmpty ? "Terminal" : tab.title
            let tabID = tab.id
            let cell = TabCell(frame: NSRect(x: x, y: y, width: cellW, height: cellH),
                               title: title, image: image) { [weak self] in
                self?.dismiss()
                coord.selectTab(workspaceID: wsID, tabID: tabID)
            }
            container.addSubview(cell)
        }
        container.frame = NSRect(origin: .zero, size: NSSize(width: gridW, height: gridH))

        let scrollView = NSScrollView()
        scrollView.documentView = container
        scrollView.hasVerticalScroller = true
        scrollView.drawsBackground = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        blur.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: blur.topAnchor, constant: 8),
            scrollView.leadingAnchor.constraint(equalTo: blur.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: blur.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: blur.bottomAnchor),
        ])

        panel = p
        p.makeKeyAndOrderFront(nil)
    }
}

// MARK: - Tab Cell

@MainActor
private final class TabCell: NSView {
    private let action: () -> Void

    init(frame: NSRect, title: String, image: NSImage?, action: @escaping () -> Void) {
        self.action = action
        super.init(frame: frame)
        wantsLayer = true
        layer?.cornerRadius = 8
        layer?.cornerCurve = .continuous
        layer?.backgroundColor = NSColor.black.withAlphaComponent(0.35).cgColor

        let thumbH = frame.height - 28
        let imageView = NSImageView(frame: NSRect(x: 4, y: 24, width: frame.width - 8, height: thumbH))
        imageView.imageScaling = .scaleProportionallyUpOrDown
        if let img = image {
            imageView.image = img
        } else {
            imageView.wantsLayer = true
            imageView.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.5).cgColor
            imageView.layer?.cornerRadius = 4
        }
        addSubview(imageView)

        let label = NSTextField(labelWithString: title)
        label.frame = NSRect(x: 6, y: 4, width: frame.width - 12, height: 18)
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.textColor = .white
        label.lineBreakMode = .byTruncatingTail
        addSubview(label)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override func mouseUp(with event: NSEvent) { action() }

    override func mouseEntered(with event: NSEvent) {
        layer?.backgroundColor = NSColor.white.withAlphaComponent(0.15).cgColor
    }

    override func mouseExited(with event: NSEvent) {
        layer?.backgroundColor = NSColor.black.withAlphaComponent(0.35).cgColor
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        trackingAreas.forEach { removeTrackingArea($0) }
        addTrackingArea(NSTrackingArea(rect: bounds,
            options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil))
    }
}
