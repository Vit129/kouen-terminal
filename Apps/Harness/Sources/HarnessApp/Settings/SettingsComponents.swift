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
        titleLabel.font = .systemFont(ofSize: 13 + HarnessDesign.Typography.delta)
        titleLabel.textColor = .labelColor
        titleLabel.isSelectable = false
        hintLabel.font = .systemFont(ofSize: 11.5 + HarnessDesign.Typography.delta)
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
        guard abs(hintLabel.preferredMaxLayoutWidth - room) > 0.5
            || abs(titleLabel.preferredMaxLayoutWidth - room) > 0.5 else { return }
        hintLabel.preferredMaxLayoutWidth = room
        titleLabel.preferredMaxLayoutWidth = room
        titleLabel.invalidateIntrinsicContentSize()
        hintLabel.invalidateIntrinsicContentSize()
        super.layout()
    }

    func applyChrome() {
        let delta = HarnessDesign.Typography.delta
        titleLabel.font = .systemFont(ofSize: 13 + delta)
        hintLabel.font = .systemFont(ofSize: 11.5 + delta)
        titleLabel.invalidateIntrinsicContentSize()
        hintLabel.invalidateIntrinsicContentSize()
        needsLayout = true
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
        label.font = .systemFont(ofSize: 13 + HarnessDesign.Typography.delta, weight: isSelected ? .semibold : .medium)
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

/// Live theme and typography specimen card shown in Settings.
@MainActor
final class TerminalSpecimenPreviewView: NSView {
    private(set) var resolvedAppearance: TerminalHostResolvedAppearance?
    private(set) var themeName: String = ""
    private(set) var fontFamily: String = "Menlo"
    private(set) var fontSize: CGFloat = 13
    private(set) var lineHeightMultiplier: CGFloat = 1.0
    private(set) var cellWidthMultiplier: CGFloat = 1.0
    private(set) var ligaturesEnabled: Bool = true
    let sampleLines: [String] = [
        "~/project main ❯ swift test",
        "if count != 0 => ok -> [✓]",
        "UTF-8 · 日本語 · 한글 · 🚀",
    ]

    override var isFlipped: Bool { true }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        translatesAutoresizingMaskIntoConstraints = false
        setAccessibilityElement(true)
        setAccessibilityRole(.group)
        setAccessibilityLabel("Terminal theme and font preview")
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: Form.wideControlWidth),
            heightAnchor.constraint(equalToConstant: 88),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    func update(themeName: String, settings: HarnessSettings, systemAppearance: HarnessSystemAppearance) {
        self.themeName = themeName
        self.resolvedAppearance = TerminalHostView.resolvedNativeAppearance(
            themeName: themeName,
            settings: settings,
            systemAppearance: systemAppearance
        )
        self.fontFamily = settings.fontFamily
        self.fontSize = CGFloat(HarnessSettings.clampedFontSize(settings.fontSize))
        self.lineHeightMultiplier = CGFloat(HarnessSettings.clampedLineHeight(settings.lineHeight))
        self.cellWidthMultiplier = CGFloat(HarnessSettings.clampedCellWidth(settings.cellWidth))
        self.ligaturesEnabled = settings.ligatures
        setAccessibilityValue("\(themeName), \(settings.fontFamily) \(Int(settings.fontSize.rounded()))pt")
        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let appearance = resolvedAppearance else { return }
        let bg = NSColor.fromHex(appearance.canvasBackgroundHex) ?? .black
        let fg = NSColor.fromHex(appearance.canvasForegroundHex) ?? .white
        let cursor = NSColor.fromHex(appearance.cursorHex) ?? fg
        let rect = bounds.insetBy(dx: 0.5, dy: 0.5)
        let path = NSBezierPath(roundedRect: rect, xRadius: HarnessDesign.Radius.control, yRadius: HarnessDesign.Radius.control)
        bg.setFill()
        path.fill()
        HarnessChrome.current.borderStrong.setStroke()
        path.lineWidth = 1
        path.stroke()

        let previewSize = min(13, max(10, fontSize * 0.78))
        let font = NSFont(name: fontFamily, size: previewSize)
            ?? .monospacedSystemFont(ofSize: previewSize, weight: .regular)
        let stepY = max(14, min(20, (previewSize + 3) * lineHeightMultiplier))
        let kern = (cellWidthMultiplier - 1.0) * 4.0
        let baseAttrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: fg,
            .ligature: ligaturesEnabled ? 1 : 0,
            .kern: kern,
        ]
        let accentGreen = paletteColor(2, in: appearance, fallback: fg)
        let accentBlue = paletteColor(4, in: appearance, fallback: fg)
        for (idx, line) in sampleLines.enumerated() {
            let attr = NSMutableAttributedString(string: line, attributes: baseAttrs)
            if idx == 0, let range = line.range(of: "~/project main") {
                attr.addAttribute(.foregroundColor, value: accentGreen, range: NSRange(range, in: line))
            } else if idx == 1 {
                attr.addAttribute(.foregroundColor, value: accentBlue, range: NSRange(location: 0, length: attr.length))
            }
            attr.draw(at: NSPoint(x: 10, y: 8 + CGFloat(idx) * stepY))
        }
        cursor.setFill()
        NSBezierPath(rect: NSRect(x: rect.maxX - 16, y: 10, width: 6, height: previewSize)).fill()

        let chipY = rect.maxY - 14
        let chipW = (rect.width - 20) / 16
        for i in 0..<16 {
            let color = paletteColor(i, in: appearance, fallback: fg)
            color.setFill()
            let chipRect = NSRect(x: 10 + CGFloat(i) * chipW, y: chipY, width: max(2, chipW - 2), height: 6)
            NSBezierPath(roundedRect: chipRect, xRadius: 1.5, yRadius: 1.5).fill()
        }
    }

    private func paletteColor(_ index: Int, in appearance: TerminalHostResolvedAppearance, fallback: NSColor) -> NSColor {
        let hex = (index < appearance.outputPaletteHex.count ? appearance.outputPaletteHex[index] : nil)
            ?? ThemeManager.defaultBaselinePaletteHex[index]
        return NSColor.fromHex(hex) ?? fallback
    }
}
