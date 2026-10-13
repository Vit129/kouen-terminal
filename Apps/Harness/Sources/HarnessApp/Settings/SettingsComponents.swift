import AppKit
import HarnessCore
import HarnessTerminalKit
import HarnessTheme
import UniformTypeIdentifiers
import UserNotifications

@MainActor
final class SettingsFlippedView: NSView {
    override var isFlipped: Bool { true }
}

/// A wrapping caption that takes its width from its constraints: it re-wraps to the width it
/// was given after each layout pass, so a footnote never clips its last line.
@MainActor
final class SettingsCaption: NSTextField {
    override func layout() {
        super.layout()
        guard bounds.width > 0, abs(preferredMaxLayoutWidth - bounds.width) > 0.5 else { return }
        preferredMaxLayoutWidth = bounds.width
        invalidateIntrinsicContentSize()
    }
}

/// Settings layout metrics, on the `HarnessDesign` spacing scale.
enum Form {
    static let sidebarWidth: CGFloat = 220
    static let maxWidth: CGFloat = 680
    static let pageInsetX: CGFloat = 32
    static let pageInsetTop: CGFloat = 30
    static let pageInsetBottom: CGFloat = 36
    static let groupSpacing: CGFloat = HarnessDesign.Spacing.xxl
    static let rowInsetX: CGFloat = HarnessDesign.Spacing.xl
    static let rowInsetY: CGFloat = 9
    static let rowMinHeight: CGFloat = 26
    static let labelGap: CGFloat = HarnessDesign.Spacing.xl
    static let hintMaxWidth: CGFloat = 340
    static let wideControlWidth: CGFloat = 240
    static let sliderWidth: CGFloat = 190
    static let sliderValueWidth: CGFloat = 44
    static let numberFieldWidth: CGFloat = 56
    static let wideNumberFieldWidth: CGFloat = 96
    static let hexFieldWidth: CGFloat = 84
    static let swatchWidth: CGFloat = 40
    static let swatchHeight: CGFloat = 24
}

/// One row of a settings card: the title (with an optional hint under it) on the left, the
/// control on the right, vertically centered. The hint wraps in whatever room the control
/// leaves, so a long hint never pushes the control out of its column.
@MainActor
final class SettingsFormRow: NSView {
    let title: String
    private let titleLabel: NSTextField
    private let hintLabel = NSTextField(wrappingLabelWithString: "")
    private let control: NSView

    var hint: String? {
        get { hintLabel.isHidden ? nil : hintLabel.stringValue }
        set {
            hintLabel.stringValue = newValue ?? ""
            hintLabel.isHidden = (newValue ?? "").isEmpty
            needsLayout = true
        }
    }

    init(title: String, hint: String?, control: NSView) {
        self.title = title
        titleLabel = NSTextField(wrappingLabelWithString: title)
        self.control = control
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 13)
        titleLabel.textColor = .labelColor
        titleLabel.isSelectable = false
        hintLabel.font = .systemFont(ofSize: 11.5)
        hintLabel.textColor = .secondaryLabelColor
        hintLabel.isSelectable = false
        for label in [titleLabel, hintLabel] {
            label.preferredMaxLayoutWidth = Form.hintMaxWidth
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        }
        self.hint = hint

        let text = NSStackView(views: [titleLabel, hintLabel])
        text.orientation = .vertical
        text.alignment = .leading
        text.spacing = 2
        text.translatesAutoresizingMaskIntoConstraints = false
        text.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        control.translatesAutoresizingMaskIntoConstraints = false
        control.setContentHuggingPriority(.required, for: .horizontal)
        control.setContentCompressionResistancePriority(.required, for: .horizontal)
        addSubview(text)
        addSubview(control)

        let collapse = heightAnchor.constraint(equalToConstant: 0)
        collapse.priority = .fittingSizeCompression
        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: Form.rowMinHeight),
            collapse,
            text.leadingAnchor.constraint(equalTo: leadingAnchor),
            text.centerYAnchor.constraint(equalTo: centerYAnchor),
            text.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            text.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
            control.trailingAnchor.constraint(equalTo: trailingAnchor),
            control.centerYAnchor.constraint(equalTo: centerYAnchor),
            control.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            control.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
            control.leadingAnchor.constraint(greaterThanOrEqualTo: text.trailingAnchor, constant: Form.labelGap),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    /// Tints the row's full-width wrapper while it is the current search match.
    func setSearchHighlight(_ on: Bool) {
        guard let wrapper = superview else { return }
        wrapper.wantsLayer = true
        wrapper.layer?.cornerRadius = HarnessDesign.Radius.control
        wrapper.layer?.backgroundColor = on ? HarnessChrome.current.accentSoft.cgColor : nil
        setAccessibilityLabel(on ? "\(title), search match" : nil)
    }

    /// Wrap the text to the room left of the control. Wrapping labels size from
    /// `preferredMaxLayoutWidth`, so it follows the row's real width after each pass.
    override func layout() {
        super.layout()
        let room = max(80, min(Form.hintMaxWidth, control.frame.minX - Form.labelGap))
        guard abs(hintLabel.preferredMaxLayoutWidth - room) > 0.5 else { return }
        hintLabel.preferredMaxLayoutWidth = room
        titleLabel.preferredMaxLayoutWidth = room
        super.layout()
    }
}

/// A heading, a card of rows, and a footnote. Tracks each row's wrapper and the hairline
/// above it, so a row can hide without leaving a doubled or dangling divider.
@MainActor
final class SettingsGroupView: NSStackView {
    private var entries: [(row: NSView, wrapper: NSView, divider: NSView?)] = []

    init() {
        super.init(frame: .zero)
        orientation = .vertical
        alignment = .leading
        spacing = HarnessDesign.Spacing.md
        translatesAutoresizingMaskIntoConstraints = false
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    func track(row: NSView, wrapper: NSView, divider: NSView?) {
        entries.append((row, wrapper, divider))
    }

    func setRow(_ row: NSView, hidden: Bool) {
        guard let entry = entries.first(where: { $0.row === row }) else { return }
        entry.wrapper.isHidden = hidden
        var anyVisible = false
        for entry in entries {
            entry.divider?.isHidden = entry.wrapper.isHidden || !anyVisible
            if !entry.wrapper.isHidden { anyVisible = true }
        }
    }
}

@MainActor
final class SettingsSidebarButton: NSControl {
    private let iconView = NSImageView()
    private let label = NSTextField(labelWithString: "")
    private var trackingArea: NSTrackingArea?
    private var isHovered = false { didSet { applyChrome() } }
    private var isFocused = false { didSet { applyChrome() } }
    var isSelected = false { didSet { applyChrome(); setAccessibilityValue(isSelected) } }
    let buttonTitle: String
    /// ↑ (-1) / ↓ (+1) while the row has keyboard focus.
    var onArrow: ((Int) -> Void)?

    init(title: String, symbol: String) {
        self.buttonTitle = title
        super.init(frame: .zero)
        wantsLayer = true
        layer?.cornerRadius = HarnessDesign.Radius.control
        layer?.cornerCurve = .continuous
        translatesAutoresizingMaskIntoConstraints = false

        let iconConfig = NSImage.SymbolConfiguration(pointSize: 13, weight: .regular)
        iconView.image = NSImage(systemSymbolName: symbol, accessibilityDescription: nil)?
            .withSymbolConfiguration(iconConfig)
        iconView.imageScaling = .scaleProportionallyUpOrDown
        iconView.translatesAutoresizingMaskIntoConstraints = false

        label.stringValue = title
        label.font = .systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false

        addSubview(iconView)
        addSubview(label)
        setAccessibilityElement(true)
        setAccessibilityRole(.radioButton)
        setAccessibilityLabel(title)
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 32),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 16),
            iconView.heightAnchor.constraint(equalToConstant: 16),
            label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -10),
        ])
        applyChrome()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let trackingArea { removeTrackingArea(trackingArea) }
        let area = NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(area)
        trackingArea = area
    }

    override func mouseEntered(with event: NSEvent) { isHovered = true }
    override func mouseExited(with event: NSEvent) { isHovered = false }
    override func mouseDown(with event: NSEvent) {}

    override func mouseUp(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        guard bounds.contains(point) else { return }
        press()
    }

    override var acceptsFirstResponder: Bool { HarnessFocusRing.controlsTakeFocus }
    override func becomeFirstResponder() -> Bool { isFocused = true; return true }
    override func resignFirstResponder() -> Bool { isFocused = false; return true }
    override func accessibilityPerformPress() -> Bool { press(); return true }

    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 126: onArrow?(-1)
        case 125: onArrow?(1)
        case 36, 49: press()
        default: super.keyDown(with: event)
        }
    }

    private func press() {
        if let target, let action {
            _ = NSApp.sendAction(action, to: target, from: self)
        }
    }

    func applyChrome() {
        let c = HarnessChrome.current
        layer?.borderWidth = isFocused ? 2 : 0
        layer?.borderColor = c.focusRing.withAlphaComponent(0.85).cgColor
        if isSelected {
            layer?.backgroundColor = c.rowSelectedFill.cgColor
            iconView.contentTintColor = c.accent
            label.textColor = c.textPrimary
        } else if isHovered {
            layer?.backgroundColor = c.rowHoverFill.cgColor
            iconView.contentTintColor = c.textSecondary
            label.textColor = c.textPrimary
        } else {
            layer?.backgroundColor = NSColor.clear.cgColor
            iconView.contentTintColor = c.textTertiary
            label.textColor = c.textSecondary
        }
    }
}
