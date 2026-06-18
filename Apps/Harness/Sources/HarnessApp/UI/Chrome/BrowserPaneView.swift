import AppKit
import WebKit
import HarnessCore

@MainActor
public final class BrowserPaneView: NSView {
    public let paneID: PaneID
    public let webView: WKWebView

    private let toolbar = NSView()
    private let backButton = NSButton()
    private let forwardButton = NSButton()
    internal let reloadStopButton = NSButton()
    internal let urlTextField = NSTextField()
    internal let closePaneButton = NSButton()
    /// Called when user taps the close (×) button in the toolbar.
    public var onClosePaneRequested: (() -> Void)?

    internal let errorBanner = NSView()
    internal let errorLabel = NSTextField(labelWithString: "")
    internal let errorDismissButton = NSButton()
    internal var errorBannerHeightConstraint: NSLayoutConstraint?

    private var loadStates: [LoadCompletionState] = []

    public convenience init(url: URL, paneID: PaneID = UUID()) {
        let config = WKWebViewConfiguration()
        config.limitsNavigationsToAppBoundDomains = false
        let web = WKWebView(frame: .zero, configuration: config)
        self.init(url: url, paneID: paneID, webView: web)
    }

    internal init(url: URL, paneID: PaneID, webView: WKWebView) {
        self.paneID = paneID
        self.webView = webView

        super.init(frame: .zero)

        // Layer-backed so the toolbar sits above the WKWebView in z-order
        // and receives mouse events correctly.
        wantsLayer = true

        setupUI()
        setupConstraints()

        webView.navigationDelegate = self
        webView.uiDelegate = self

        // Register in the registry
        BrowserPaneRegistry.shared.register(self)

        // Load the initial URL (or restore it from UserDefaults if available)
        let resolvedURL: URL
        if let savedURLString = UserDefaults.standard.string(forKey: "browserPane.\(paneID.uuidString).url"),
           let savedURL = URL(string: savedURLString) {
            resolvedURL = savedURL
        } else {
            resolvedURL = url
        }

        navigate(to: resolvedURL)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        let uuid = paneID.uuidString
        NSLog("[BrowserPane] deinit \(uuid)")
    }

    override public func removeFromSuperview() {
        super.removeFromSuperview()
    }

    override public func viewWillMove(toWindow newWindow: NSWindow?) {
        super.viewWillMove(toWindow: newWindow)
        if newWindow == nil {
            BrowserPaneRegistry.shared.unregister(self.paneID)
        }
    }

    private func setupUI() {
        // Toolbar styling
        toolbar.wantsLayer = true
        toolbar.layer?.backgroundColor = HarnessDesign.chrome.sidebarBackground.cgColor
        toolbar.translatesAutoresizingMaskIntoConstraints = false

        let border = NSView()
        border.wantsLayer = true
        border.layer?.backgroundColor = HarnessDesign.chrome.border.cgColor
        border.translatesAutoresizingMaskIntoConstraints = false
        toolbar.addSubview(border)
        NSLayoutConstraint.activate([
            border.leadingAnchor.constraint(equalTo: toolbar.leadingAnchor),
            border.trailingAnchor.constraint(equalTo: toolbar.trailingAnchor),
            border.bottomAnchor.constraint(equalTo: toolbar.bottomAnchor),
            border.heightAnchor.constraint(equalToConstant: 1)
        ])

        // Buttons configuration
        configureNavigationButton(backButton, symbolName: "chevron.left", action: #selector(backClicked))
        backButton.setAccessibilityIdentifier("browser-back-button")
        configureNavigationButton(forwardButton, symbolName: "chevron.right", action: #selector(forwardClicked))
        forwardButton.setAccessibilityIdentifier("browser-forward-button")
        configureNavigationButton(reloadStopButton, symbolName: "arrow.clockwise", action: #selector(reloadStopClicked))
        reloadStopButton.setAccessibilityIdentifier("browser-reload-button")
        configureNavigationButton(closePaneButton, symbolName: "xmark", action: #selector(closePaneClicked))
        closePaneButton.setAccessibilityIdentifier("browser-close-button")
        closePaneButton.toolTip = "Close Browser Pane"
        closePaneButton.setContentHuggingPriority(.required, for: .horizontal)
        closePaneButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        // URL Text Field configuration
        urlTextField.translatesAutoresizingMaskIntoConstraints = false
        urlTextField.isEditable = true
        urlTextField.drawsBackground = true
        urlTextField.backgroundColor = HarnessDesign.chrome.surfaceElevated
        urlTextField.textColor = HarnessDesign.chrome.textPrimary
        urlTextField.isBezeled = true
        urlTextField.bezelStyle = .roundedBezel
        urlTextField.focusRingType = .none
        urlTextField.target = self
        urlTextField.action = #selector(urlEntered(_:))
        urlTextField.font = NSFont.systemFont(ofSize: HarnessDesign.FontSize.chromeBody)
        urlTextField.setAccessibilityIdentifier("browser-url-text-field")
        urlTextField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        urlTextField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let toolbarStack = NSStackView(views: [backButton, forwardButton, reloadStopButton, urlTextField, closePaneButton])
        toolbarStack.orientation = .horizontal
        toolbarStack.spacing = 8
        toolbarStack.edgeInsets = NSEdgeInsets(top: 4, left: 8, bottom: 4, right: 12)
        toolbarStack.alignment = .centerY
        toolbarStack.translatesAutoresizingMaskIntoConstraints = false
        toolbar.addSubview(toolbarStack)

        NSLayoutConstraint.activate([
            toolbarStack.topAnchor.constraint(equalTo: toolbar.topAnchor),
            toolbarStack.leadingAnchor.constraint(equalTo: toolbar.leadingAnchor),
            toolbarStack.trailingAnchor.constraint(equalTo: toolbar.trailingAnchor),
            toolbarStack.bottomAnchor.constraint(equalTo: toolbar.bottomAnchor)
        ])

        // Error Banner configuration
        errorBanner.wantsLayer = true
        errorBanner.layer?.backgroundColor = HarnessDesign.chrome.danger.withAlphaComponent(0.15).cgColor
        errorBanner.translatesAutoresizingMaskIntoConstraints = false

        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.textColor = HarnessDesign.chrome.danger
        errorLabel.font = NSFont.systemFont(ofSize: HarnessDesign.FontSize.chromeSmall)
        errorLabel.lineBreakMode = .byTruncatingTail
        errorBanner.addSubview(errorLabel)

        errorDismissButton.translatesAutoresizingMaskIntoConstraints = false
        errorDismissButton.title = ""
        errorDismissButton.image = NSImage(systemSymbolName: "xmark.circle.fill", accessibilityDescription: "Dismiss")
        errorDismissButton.isBordered = false
        errorDismissButton.bezelStyle = .regularSquare
        errorDismissButton.target = self
        errorDismissButton.action = #selector(dismissErrorBanner)
        errorDismissButton.widthAnchor.constraint(equalToConstant: 16).isActive = true
        errorDismissButton.heightAnchor.constraint(equalToConstant: 16).isActive = true
        errorBanner.addSubview(errorDismissButton)

        NSLayoutConstraint.activate([
            errorLabel.leadingAnchor.constraint(equalTo: errorBanner.leadingAnchor, constant: 8),
            errorLabel.centerYAnchor.constraint(equalTo: errorBanner.centerYAnchor),
            errorLabel.trailingAnchor.constraint(lessThanOrEqualTo: errorDismissButton.leadingAnchor, constant: -8),

            errorDismissButton.trailingAnchor.constraint(equalTo: errorBanner.trailingAnchor, constant: -8),
            errorDismissButton.centerYAnchor.constraint(equalTo: errorBanner.centerYAnchor)
        ])

        webView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupConstraints() {
        let mainStack = NSStackView(views: [toolbar, errorBanner, webView])
        mainStack.orientation = .vertical
        mainStack.spacing = 0
        mainStack.alignment = .width
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStack)

        errorBannerHeightConstraint = errorBanner.heightAnchor.constraint(equalToConstant: 0)
        errorBanner.isHidden = true

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor),

            toolbar.heightAnchor.constraint(equalToConstant: 32),
            errorBannerHeightConstraint!
        ])
    }

    private func configureNavigationButton(_ button: NSButton, symbolName: String, action: Selector) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.image = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)
        button.isBordered = false
        button.bezelStyle = .regularSquare
        button.target = self
        button.action = action
        button.widthAnchor.constraint(equalToConstant: 20).isActive = true
        button.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }

    // MARK: - Actions

    @objc private func closePaneClicked() {
        if let cb = onClosePaneRequested {
            cb()
        } else {
            // Fallback: remove from pane tree via coordinator
            SessionCoordinator.shared.splitPaneCoordinator.closeBrowserPane(paneID: paneID)
        }
    }

    @objc private func backClicked() {
        if webView.canGoBack {
            webView.goBack()
        }
    }

    @objc private func forwardClicked() {
        if webView.canGoForward {
            webView.goForward()
        }
    }

    @objc private func reloadStopClicked() {
        if webView.isLoading {
            webView.stopLoading()
        } else {
            webView.reload()
        }
    }

    @objc private func urlEntered(_ sender: NSTextField) {
        let text = sender.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        let url: URL
        if text.contains("://") {
            url = URL(string: text) ?? URL(string: "about:blank")!
        } else {
            url = URL(string: "http://\(text)") ?? URL(string: "about:blank")!
        }
        navigate(to: url)
    }

    @objc private func dismissErrorBanner() {
        errorBannerHeightConstraint?.constant = 0
        errorBanner.isHidden = true
    }

    private func showErrorBanner(message: String) {
        errorLabel.stringValue = message
        errorBannerHeightConstraint?.constant = 24
        errorBanner.isHidden = false
    }

    private func updateReloadStopButton(isLoading: Bool) {
        let symbol = isLoading ? "xmark" : "arrow.clockwise"
        reloadStopButton.image = NSImage(systemSymbolName: symbol, accessibilityDescription: nil)
    }

    // MARK: - Public API

    public func navigate(to url: URL) {
        let request = URLRequest(url: url)
        webView.load(request)
        urlTextField.stringValue = url.absoluteString
        dismissErrorBanner()
    }

    public func evaluateJS(_ script: String) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            webView.evaluateJavaScript(script) { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let resultString = result as? String {
                    continuation.resume(returning: resultString)
                } else {
                    continuation.resume(returning: "")
                }
            }
        }
    }

    public func snapshot(interactive: Bool) async throws -> BrowserSnapshot {
        let script = """
        (function(){
          var els=[],i=0;
          document.querySelectorAll('a,button,input,select,textarea,[role=button]').forEach(function(el){
            els.push({id:'e'+(++i),tag:el.tagName.toLowerCase(),
              text:(el.innerText||'').trim().slice(0,80),
              value:el.value||'',placeholder:el.placeholder||'',href:el.href||''});
          });
          return JSON.stringify({url:location.href,title:document.title,
            text:document.body.innerText.slice(0,3000),elements:els});
        })()
        """
        let jsonString = try await evaluateJS(script)
        guard let data = jsonString.data(using: .utf8) else {
            throw NSError(domain: "BrowserPaneView", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid snapshot format"])
        }
        return try JSONDecoder().decode(BrowserSnapshot.self, from: data)
    }

    public func waitForLoad(timeout: TimeInterval) async throws {
        if !webView.isLoading {
            return
        }
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            let state = LoadCompletionState(continuation: continuation)
            self.loadStates.append(state)

            Task {
                try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                state.complete(error: NSError(domain: "BrowserPaneView", code: 1, userInfo: [NSLocalizedDescriptionKey: "Loading timed out"]))
            }
        }
    }

    private func completeLoading(error: Error? = nil) {
        let current = loadStates
        loadStates.removeAll()
        for state in current {
            state.complete(error: error)
        }
    }

    // MARK: - Key Equivalents

    override public func performKeyEquivalent(with event: NSEvent) -> Bool {
        guard let characters = event.charactersIgnoringModifiers, characters == "l" else {
            return super.performKeyEquivalent(with: event)
        }
        if event.modifierFlags.contains(.command) {
            self.window?.makeFirstResponder(urlTextField)
            return true
        }
        return super.performKeyEquivalent(with: event)
    }
}

extension BrowserPaneView: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        if let url = webView.url {
            urlTextField.stringValue = url.absoluteString
        }
    }

    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        updateReloadStopButton(isLoading: true)
        dismissErrorBanner()
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        updateReloadStopButton(isLoading: false)
        if let url = webView.url {
            urlTextField.stringValue = url.absoluteString
            UserDefaults.standard.set(url.absoluteString, forKey: "browserPane.\(paneID.uuidString).url")
        }
        completeLoading()
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        updateReloadStopButton(isLoading: false)
        showErrorBanner(message: error.localizedDescription)
        completeLoading(error: error)
    }

    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        updateReloadStopButton(isLoading: false)
        showErrorBanner(message: error.localizedDescription)
        completeLoading(error: error)
    }

    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        showErrorBanner(message: "Page crashed, reloading…")
        webView.reload()
    }
}

extension BrowserPaneView: WKUIDelegate {
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}

// MARK: - Registry Definition

@MainActor
public final class BrowserPaneRegistry {
    public static let shared = BrowserPaneRegistry()
    private var panes: [PaneID: WeakBrowserPaneView] = [:]

    private struct WeakBrowserPaneView {
        weak var view: BrowserPaneView?
    }

    public func register(_ view: BrowserPaneView) {
        panes[view.paneID] = WeakBrowserPaneView(view: view)
    }

    public func unregister(_ paneID: PaneID) {
        panes.removeValue(forKey: paneID)
    }

    public func get(_ paneID: PaneID) -> BrowserPaneView? {
        return panes[paneID]?.view
    }
}

private final class LoadCompletionState: @unchecked Sendable {
    private let lock = NSLock()
    private var continuation: CheckedContinuation<Void, Error>?
    private var isCompleted = false

    init(continuation: CheckedContinuation<Void, Error>) {
        self.continuation = continuation
    }

    func complete(error: Error? = nil) {
        lock.lock()
        defer { lock.unlock() }
        guard !isCompleted else { return }
        isCompleted = true
        if let error = error {
            continuation?.resume(throwing: error)
        } else {
            continuation?.resume(returning: ())
        }
        continuation = nil
    }
}
