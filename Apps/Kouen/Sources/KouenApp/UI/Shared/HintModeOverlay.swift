import AppKit
import KouenTerminalKit

/// Vimium-style hint mode: labels all visible links with key sequences,
/// then opens the link whose label the user types.
@MainActor
final class HintModeOverlay {
    static let shared = HintModeOverlay()
    private init() {}

    private var chips: [(label: String, url: String, view: NSView)] = []
    private var monitor: Any?
    private var typed = ""
    private weak var surface: KouenTerminalSurfaceView?

    func show(on surface: KouenTerminalSurfaceView) {
        dismiss()
        guard let contentView = surface.window?.contentView else { return }
        let links = surface.visibleLinks()
        guard !links.isEmpty else { return }
        self.surface = surface

        let labels = Self.generateLabels(count: links.count)
        for (i, link) in links.enumerated() {
            let label = labels[i]
            let frameInContent = surface.convert(link.frame, to: contentView)
            let chip = makeChip(label)
            let w = CGFloat(label.count) * 9 + 10
            chip.frame = NSRect(x: frameInContent.minX, y: frameInContent.midY - 9, width: w, height: 18)
            contentView.addSubview(chip)
            chips.append((label, link.url, chip))
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in self?.dismiss() }
        monitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self else { return event }
            if event.type != .keyDown { dismiss(); return event }
            return handle(event) ?? event
        }
    }

    private func handle(_ event: NSEvent) -> NSEvent? {
        guard let surface else { dismiss(); return event }
        if event.keyCode == 53 { dismiss(); return nil } // Esc
        guard let ch = event.charactersIgnoringModifiers?.lowercased(),
              ch.allSatisfy({ $0.isLetter }) else { dismiss(); return nil }
        typed += ch
        let matching = chips.filter { $0.label.hasPrefix(typed) }
        if matching.count == 1 {
            surface.activateHintLink(matching[0].url)
            dismiss()
        } else if matching.isEmpty {
            dismiss()
        } else {
            for chip in chips { chip.view.alphaValue = chip.label.hasPrefix(typed) ? 1.0 : 0.2 }
        }
        return nil
    }

    func dismiss() {
        chips.forEach { $0.view.removeFromSuperview() }
        chips.removeAll(); typed = ""
        if let m = monitor { NSEvent.removeMonitor(m); monitor = nil }
    }

    // ponytail: home-row keys first so the most common links need fewest keystrokes
    private static func generateLabels(count: Int) -> [String] {
        let keys = Array("asdfghjklqwertyuiopzxcvbnm")
        if count <= keys.count { return (0..<count).map { String(keys[$0]) }  }
        var out: [String] = []
        outer: for a in keys { for b in keys { out.append("\(a)\(b)"); if out.count == count { break outer } } }
        return out
    }

    private func makeChip(_ label: String) -> NSView {
        let box = NSView()
        box.wantsLayer = true
        box.layer?.cornerRadius = 3
        box.layer?.backgroundColor = NSColor(red: 0.98, green: 0.87, blue: 0.18, alpha: 0.93).cgColor
        box.layer?.borderWidth = 1
        box.layer?.borderColor = NSColor.black.withAlphaComponent(0.35).cgColor

        let tf = NSTextField(labelWithString: label.uppercased())
        tf.font = .monospacedSystemFont(ofSize: 10, weight: .bold)
        tf.textColor = NSColor(white: 0.08, alpha: 1)
        tf.translatesAutoresizingMaskIntoConstraints = false
        box.addSubview(tf)
        NSLayoutConstraint.activate([
            tf.centerXAnchor.constraint(equalTo: box.centerXAnchor),
            tf.centerYAnchor.constraint(equalTo: box.centerYAnchor),
        ])
        return box
    }
}
