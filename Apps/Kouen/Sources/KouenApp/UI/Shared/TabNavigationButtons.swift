import AppKit

/// Which tab a previous/next control lands on; nil at either end of the strip.
enum TabNavigation {
    static func target(from activeIndex: Int, delta: Int, count: Int) -> Int? {
        let next = activeIndex + delta
        return (0..<count).contains(next) ? next : nil
    }
}

/// Previous/next tab controls for any AppKit tab strip. They switch tabs rather than scroll
/// the strip, so they do something whether or not the tabs overflow.
@MainActor
final class TabNavigationButtons: NSStackView {
    private static let disabledAlpha: CGFloat = 0.35

    private let previousButton = SoftIconButton(frame: NSRect(x: 0, y: 0, width: 20, height: 20))
    private let nextButton = SoftIconButton(frame: NSRect(x: 0, y: 0, width: 20, height: 20))
    private var activeIndex = 0
    private var count = 0

    var onSelect: ((Int) -> Void)?

    init(accessibilityPrefix: String) {
        super.init(frame: .zero)
        orientation = .horizontal
        spacing = 2
        translatesAutoresizingMaskIntoConstraints = false
        configure(previousButton, symbol: "chevron.left", label: "Previous Tab", action: #selector(previousClicked))
        configure(nextButton, symbol: "chevron.right", label: "Next Tab", action: #selector(nextClicked))
        previousButton.setAccessibilityIdentifier("\(accessibilityPrefix)-previous-tab")
        nextButton.setAccessibilityIdentifier("\(accessibilityPrefix)-next-tab")
        addArrangedSubview(previousButton)
        addArrangedSubview(nextButton)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    func update(activeIndex: Int, count: Int) {
        self.activeIndex = activeIndex
        self.count = count
        setAvailable(previousButton, TabNavigation.target(from: activeIndex, delta: -1, count: count) != nil)
        setAvailable(nextButton, TabNavigation.target(from: activeIndex, delta: 1, count: count) != nil)
    }

    private func configure(_ button: SoftIconButton, symbol: String, label: String, action: Selector) {
        button.setSymbol(symbol, accessibilityDescription: label, pointSize: 9, weight: .semibold)
        button.toolTip = label
        button.target = self
        button.action = action
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 20),
            button.heightAnchor.constraint(equalToConstant: 20),
        ])
    }

    private func setAvailable(_ button: SoftIconButton, _ available: Bool) {
        button.isEnabled = available
        button.alphaValue = available ? 1 : Self.disabledAlpha
    }

    @objc private func previousClicked() { move(by: -1) }
    @objc private func nextClicked() { move(by: 1) }

    private func move(by delta: Int) {
        guard let target = TabNavigation.target(from: activeIndex, delta: delta, count: count) else { return }
        onSelect?(target)
    }
}

extension KouenDesign {
    /// Same selected look as the file editor's tab pills, so tabs with identical titles can
    /// still be told apart.
    @MainActor
    static func applyTabSelection(to view: NSView, isActive: Bool) {
        view.wantsLayer = true
        view.layer?.backgroundColor = isActive ? chrome.rowSelectedFill.cgColor : NSColor.clear.cgColor
        view.layer?.borderWidth = isActive ? 1 : 0
        view.layer?.borderColor = chrome.accent.withAlphaComponent(0.5).cgColor
    }
}
