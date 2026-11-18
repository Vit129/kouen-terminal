import AppKit

@MainActor
final class SessionHistoryPanelController: NSObject {
    private static let visibleKey = "Kouen.SessionHistoryPanel.visible"
    private static let widthKey = "Kouen.SessionHistoryPanel.width"

    let view = NSView()
    private let bodyView = NSView()
    private let dividerView = HistoryPanelDividerView()
    private var widthConstraint: NSLayoutConstraint?
    private var hostingView: NSView?
    private(set) var isVisible = false
    var onVisibilityChanged: ((Bool) -> Void)?

    override init() {
        super.init()
        view.translatesAutoresizingMaskIntoConstraints = false
        bodyView.translatesAutoresizingMaskIntoConstraints = false
        bodyView.wantsLayer = true
        bodyView.layer?.borderWidth = 1
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        dividerView.onResize = { [weak self] delta in self?.resize(by: delta) }
        view.addSubview(dividerView)
        view.addSubview(bodyView)
        NSLayoutConstraint.activate([
            dividerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dividerView.trailingAnchor.constraint(equalTo: bodyView.leadingAnchor),
            dividerView.topAnchor.constraint(equalTo: view.topAnchor),
            dividerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dividerView.widthAnchor.constraint(equalToConstant: 5),
            bodyView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bodyView.topAnchor.constraint(equalTo: view.topAnchor),
            bodyView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        applyChrome()
    }

    func install(in container: NSView, below topAnchor: NSLayoutYAxisAnchor) {
        container.addSubview(view)
        NSLayoutConstraint.activate([
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            view.topAnchor.constraint(equalTo: topAnchor),
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
        let width = view.widthAnchor.constraint(equalToConstant: 0)
        width.isActive = true
        widthConstraint = width
        view.isHidden = true
    }

    func install(hostingView: NSView) {
        self.hostingView?.removeFromSuperview()
        self.hostingView = hostingView
        hostingView.translatesAutoresizingMaskIntoConstraints = false

        let header = NSTextField(labelWithString: "Agent Session History")
        header.font = KouenDesign.Typography.sectionLabel
        header.textColor = KouenDesign.chrome.textSecondary
        header.translatesAutoresizingMaskIntoConstraints = false
        header.identifier = NSUserInterfaceItemIdentifier("label_sessionHistoryPanelTitle")

        let closeButton = SoftIconButton(frame: .zero)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setSymbol("xmark", accessibilityDescription: "Close Session History", pointSize: 10, weight: .medium)
        closeButton.target = self
        closeButton.action = #selector(close)
        closeButton.toolTip = "Close Session History"

        bodyView.addSubview(header)
        bodyView.addSubview(closeButton)
        bodyView.addSubview(hostingView)
        NSLayoutConstraint.activate([
            header.leadingAnchor.constraint(equalTo: bodyView.leadingAnchor, constant: 12),
            header.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            closeButton.topAnchor.constraint(equalTo: bodyView.topAnchor, constant: 6),
            closeButton.trailingAnchor.constraint(equalTo: bodyView.trailingAnchor, constant: -6),
            closeButton.widthAnchor.constraint(equalToConstant: 22),
            closeButton.heightAnchor.constraint(equalToConstant: 22),
            hostingView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 4),
            hostingView.leadingAnchor.constraint(equalTo: bodyView.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: bodyView.trailingAnchor),
            hostingView.bottomAnchor.constraint(equalTo: bodyView.bottomAnchor),
        ])

        if UserDefaults.standard.bool(forKey: Self.visibleKey) {
            setVisible(true, notify: false)
        }
    }

    func toggle() {
        setVisible(!isVisible)
    }

    func setVisible(_ visible: Bool, notify: Bool = true) {
        isVisible = visible
        let savedWidth = UserDefaults.standard.double(forKey: Self.widthKey)
        let width = savedWidth > 0 ? CGFloat(savedWidth) : 360
        widthConstraint?.constant = visible ? clampedWidth(width) : 0
        view.isHidden = !visible
        UserDefaults.standard.set(visible, forKey: Self.visibleKey)
        if notify { onVisibilityChanged?(visible) }
        view.superview?.needsLayout = true
        view.superview?.layoutSubtreeIfNeeded()
    }

    func constrainToAvailableWidth() {
        guard isVisible, let widthConstraint else { return }
        widthConstraint.constant = clampedWidth(widthConstraint.constant)
    }

    func applyChrome() {
        bodyView.layer?.backgroundColor = KouenDesign.chrome.sidebarBackground.cgColor
        bodyView.layer?.borderColor = KouenDesign.chrome.border.cgColor
    }

    private func resize(by delta: CGFloat) {
        guard isVisible, let widthConstraint else { return }
        let width = clampedWidth(widthConstraint.constant + delta)
        widthConstraint.constant = width
        UserDefaults.standard.set(Double(width), forKey: Self.widthKey)
    }

    private func clampedWidth(_ width: CGFloat) -> CGFloat {
        let containerWidth = view.superview?.bounds.width ?? 0
        let available = containerWidth > 1 ? max(220, containerWidth - 300) : 520
        return min(max(width, 220), min(520, available))
    }

    @objc private func close() {
        setVisible(false)
    }
}

@MainActor
private final class HistoryPanelDividerView: NSView {
    var onResize: ((CGFloat) -> Void)?
    private var lastX: CGFloat?

    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .resizeLeftRight)
    }

    override func mouseDown(with event: NSEvent) {
        lastX = event.locationInWindow.x
    }

    override func mouseDragged(with event: NSEvent) {
        guard let lastX else { return }
        let currentX = event.locationInWindow.x
        onResize?(lastX - currentX)
        self.lastX = currentX
    }

    override func mouseUp(with event: NSEvent) {
        lastX = nil
    }
}
