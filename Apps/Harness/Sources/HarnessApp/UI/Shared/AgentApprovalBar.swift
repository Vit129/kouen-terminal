import AppKit
import HarnessCore
import HarnessTerminalKit

/// Pure decision produced by `AgentApprovalBar.action(for:prompt:)`.
enum ApprovalBarAction: Equatable {
    case show(String)   // prompt text
    case hide
    case noop
}

/// Slim approval bar that slides up from the bottom of a pane when an agent
/// emits OSC 26 `status=waiting_input;prompt=<text>`.
/// Allow → sends `\n` to PTY (agent continues). Deny → sends `\x03` (Ctrl-C, agent aborts).
@MainActor
final class AgentApprovalBar: NSView {

    private weak var host: TerminalHostView?
    private var heightConstraint: NSLayoutConstraint?

    // MARK: - Static helpers

    /// Maps an OSC 26 activity string to the bar action. Pure — no AppKit dependency, fully testable.
    /// "working" is intentionally a no-op: concurrent Notification hooks must not hide a pending bar.
    nonisolated static func action(for activity: String, prompt: String?) -> ApprovalBarAction {
        switch activity {
        case "waiting_input":
            guard let p = prompt, !p.isEmpty else { return .noop }
            return .show(p)
        case "idle", "errored":
            return .hide
        default:
            return .noop
        }
    }

    static func show(on host: TerminalHostView, prompt: String, kind: AgentKind?) {
        if let existing = host.subviews.first(where: { $0 is AgentApprovalBar }) as? AgentApprovalBar {
            existing.update(prompt: prompt, kind: kind)
            return
        }
        let bar = AgentApprovalBar(host: host, prompt: prompt, kind: kind)
        bar.translatesAutoresizingMaskIntoConstraints = false
        host.addSubview(bar)
        NSLayoutConstraint.activate([
            bar.leadingAnchor.constraint(equalTo: host.leadingAnchor),
            bar.trailingAnchor.constraint(equalTo: host.trailingAnchor),
            bar.bottomAnchor.constraint(equalTo: host.bottomAnchor),
            bar.heightAnchor.constraint(equalToConstant: 44),
        ])
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.18
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            bar.animator().alphaValue = 1
        }
    }

    static func hide(from host: TerminalHostView) {
        guard let bar = host.subviews.first(where: { $0 is AgentApprovalBar }) as? AgentApprovalBar else { return }
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.15
            bar.animator().alphaValue = 0
        }, completionHandler: { bar.removeFromSuperview() })
    }

    // MARK: - Init

    private init(host: TerminalHostView, prompt: String, kind: AgentKind?) {
        self.host = host
        super.init(frame: .zero)
        alphaValue = 0
        wantsLayer = true
        layer?.backgroundColor = NSColor(white: 0.08, alpha: 0.94).cgColor
        layer?.borderWidth = 0.5
        layer?.borderColor = NSColor.white.withAlphaComponent(0.12).cgColor

        build(prompt: prompt, kind: kind)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Layout

    private var promptLabel: NSTextField?
    private var chipLabel: NSTextField?

    private func build(prompt: String, kind: AgentKind?) {
        let chip = makeChip(kind: kind)
        let label = makeLabel(prompt)
        let allowBtn = makeButton("Allow", action: #selector(allow), accent: true)
        let denyBtn  = makeButton("Deny",  action: #selector(deny),  accent: false)

        let stack = NSStackView(views: [chip, label, NSView(), allowBtn, denyBtn])
        stack.orientation = .horizontal
        stack.spacing = 8
        stack.alignment = .centerY
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        promptLabel = label
        chipLabel = chip
    }

    private func update(prompt: String, kind: AgentKind?) {
        promptLabel?.stringValue = prompt
        if let kind {
            chipLabel?.stringValue = kind.chip
            chipLabel?.textColor = NSColor(hex: kind.dotHex) ?? .secondaryLabelColor
        }
    }

    // MARK: - Subview factories

    private func makeChip(kind: AgentKind?) -> NSTextField {
        let tf = NSTextField(labelWithString: kind?.chip ?? "AG")
        tf.font = .monospacedSystemFont(ofSize: 10, weight: .bold)
        tf.textColor = kind.flatMap { NSColor(hex: $0.dotHex) } ?? .secondaryLabelColor
        tf.setContentHuggingPriority(.required, for: .horizontal)
        return tf
    }

    private func makeLabel(_ text: String) -> NSTextField {
        let tf = NSTextField(labelWithString: text)
        tf.font = .systemFont(ofSize: 11.5)
        tf.textColor = NSColor.white.withAlphaComponent(0.80)
        tf.lineBreakMode = .byTruncatingTail
        tf.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return tf
    }

    private func makeButton(_ title: String, action: Selector, accent: Bool) -> NSButton {
        let btn = NSButton(title: title, target: self, action: action)
        btn.bezelStyle = .regularSquare
        btn.isBordered = false
        btn.font = .systemFont(ofSize: 11, weight: .medium)
        btn.contentTintColor = accent
            ? NSColor.systemGreen.withAlphaComponent(0.9)
            : NSColor.white.withAlphaComponent(0.45)
        btn.setContentHuggingPriority(.required, for: .horizontal)
        return btn
    }

    // MARK: - Actions

    @objc private func allow() {
        guard let host else { return }
        host.sendInput(Data([0x0A]))  // \n
        AgentApprovalBar.hide(from: host)
    }

    @objc private func deny() {
        guard let host else { return }
        host.sendInput(Data([0x03]))  // Ctrl-C
        AgentApprovalBar.hide(from: host)
    }
}

// MARK: - NSColor hex helper (local to this file — avoids polluting global namespace)

private extension NSColor {
    convenience init?(hex: String) {
        var hex = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        guard hex.count == 6, let value = UInt64(hex, radix: 16) else { return nil }
        self.init(
            red:   CGFloat((value >> 16) & 0xFF) / 255,
            green: CGFloat((value >> 8)  & 0xFF) / 255,
            blue:  CGFloat( value        & 0xFF) / 255,
            alpha: 1
        )
    }
}
