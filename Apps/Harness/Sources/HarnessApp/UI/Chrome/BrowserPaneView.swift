import AppKit
import WebKit
import HarnessCore

@MainActor
public final class BrowserPaneView: NSView {
    public let paneID: PaneID
    public private(set) var webView: WKWebView

    // MARK: - Tab Model

    struct BrowserTab {
        let id: UUID
        let webView: WKWebView
        var title: String
    }

    private var tabs: [BrowserTab] = []
    private var activeTabIndex: Int = 0
    private var activeTab: BrowserTab? { tabs.indices.contains(activeTabIndex) ? tabs[activeTabIndex] : nil }
    private var consoleLogs: [String] = []

    private let tabBar = NSScrollView()
    private let tabBarStack = NSStackView()
    private let newTabButton = NSButton()

    private let toolbar = NSView()
    private let backButton = SoftIconButton(frame: NSRect(x: 0, y: 0, width: 20, height: 20))
    private let forwardButton = SoftIconButton(frame: NSRect(x: 0, y: 0, width: 20, height: 20))
    internal let reloadStopButton = SoftIconButton(frame: NSRect(x: 0, y: 0, width: 20, height: 20))
    internal let urlTextField = NSTextField()
    internal let closePaneButton = SoftIconButton(frame: NSRect(x: 0, y: 0, width: 20, height: 20))
    /// Called when user taps the close (×) button in the toolbar.
    public var onClosePaneRequested: (() -> Void)?

    internal let errorBanner = NSView()
    internal let errorLabel = NSTextField(labelWithString: "")
    internal let errorDismissButton = NSButton()
    internal var errorBannerHeightConstraint: NSLayoutConstraint?

    private var retryTimer: Timer?
    private var retryCount = 0
    private static let maxRetries = 10  // 10 × 3s = 30s then auto-close

    private var loadStates: [LoadCompletionState] = []
    private let progressLine = BrowserProgressLine()
    private var progressObservation: NSKeyValueObservation?

    public convenience init(url: URL, paneID: PaneID = UUID()) {
        let config = WKWebViewConfiguration()
        config.limitsNavigationsToAppBoundDomains = false
        let web = WKWebView(frame: .zero, configuration: config)
        web.allowsMagnification = true
        web.allowsBackForwardNavigationGestures = true
#if DEBUG
        web.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
#endif
        self.init(url: url, paneID: paneID, webView: web)
    }

    internal init(url: URL, paneID: PaneID, webView: WKWebView) {
        self.paneID = paneID
        self.webView = webView

        super.init(frame: .zero)
        wantsLayer = true

        // Create first tab
        let firstTab = BrowserTab(id: UUID(), webView: webView, title: "New Tab")
        tabs.append(firstTab)

        let tempDir = NSTemporaryDirectory()
        let logPath = (tempDir as NSString).appendingPathComponent("harness-browser-\(paneID.uuidString).log")
        try? "".write(toFile: logPath, atomically: true, encoding: .utf8)

        setupConsoleLogRedirection(for: webView)

        setupUI()
        setupTabBar()
        setupConstraints()

        webView.navigationDelegate = self
        webView.uiDelegate = self

        BrowserPaneRegistry.shared.register(self)
        setupProgressObservation()

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

    override public func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        // When the browser pane is reattached after a pane tree rebuild, WKWebView
        // may show a blank/pink frame until the next draw cycle. Force a
        // display to ensure the web content process repaints.
        if superview != nil, window != nil {
            webView.setNeedsDisplay(webView.bounds)
            // Also nudge the web content process by evaluating a trivial script
            // — this is the most reliable way to wake WKWebView's compositor.
            webView.evaluateJavaScript("void(0)") { _, _ in }
        }
    }

    override public func viewWillMove(toWindow newWindow: NSWindow?) {
        super.viewWillMove(toWindow: newWindow)
        if newWindow == nil {
            // Defer unregister: during pane tree rebuilds, the view is briefly detached
            // then re-attached in the same runloop cycle. Only unregister if still
            // windowless after the rebuild completes.
            let id = paneID
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                if BrowserPaneRegistry.shared.get(id)?.window == nil {
                    BrowserPaneRegistry.shared.unregister(id)
                }
            }
        }
    }

    private func setupUI() {
        // Toolbar styling — translucent blur (CMUX-style)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.wantsLayer = true
        let blurView = NSVisualEffectView()
        blurView.material = .hudWindow
        blurView.blendingMode = .behindWindow
        blurView.state = .active
        blurView.translatesAutoresizingMaskIntoConstraints = false
        toolbar.addSubview(blurView, positioned: .below, relativeTo: nil)
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: toolbar.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: toolbar.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: toolbar.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: toolbar.bottomAnchor),
        ])

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

        // URL Text Field container & configuration
        let urlContainer = NSView()
        urlContainer.translatesAutoresizingMaskIntoConstraints = false
        urlContainer.wantsLayer = true
        urlContainer.layer?.cornerRadius = 6
        urlContainer.layer?.cornerCurve = .continuous
        urlContainer.layer?.backgroundColor = HarnessDesign.chrome.surfaceElevated.cgColor
        urlContainer.layer?.borderColor = HarnessDesign.chrome.borderStrong.cgColor
        urlContainer.layer?.borderWidth = 1

        urlTextField.translatesAutoresizingMaskIntoConstraints = false
        urlTextField.isEditable = true
        urlTextField.drawsBackground = false
        urlTextField.textColor = HarnessDesign.chrome.textPrimary
        urlTextField.isBezeled = false
        urlTextField.isBordered = false
        urlTextField.focusRingType = .none
        urlTextField.target = self
        urlTextField.action = #selector(urlEntered(_:))
        urlTextField.font = NSFont.systemFont(ofSize: HarnessDesign.FontSize.chromeBody)
        urlTextField.setAccessibilityIdentifier("browser-url-text-field")

        urlContainer.addSubview(urlTextField)
        urlContainer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        urlContainer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        NSLayoutConstraint.activate([
            urlTextField.leadingAnchor.constraint(equalTo: urlContainer.leadingAnchor, constant: 6),
            urlTextField.trailingAnchor.constraint(equalTo: urlContainer.trailingAnchor, constant: -6),
            urlTextField.centerYAnchor.constraint(equalTo: urlContainer.centerYAnchor),
        ])

        let toolbarStack = NSStackView(views: [backButton, forwardButton, reloadStopButton, urlContainer, closePaneButton])
        toolbarStack.orientation = .horizontal
        toolbarStack.spacing = 6
        toolbarStack.edgeInsets = NSEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
        toolbarStack.alignment = .centerY
        toolbarStack.distribution = .fill
        toolbarStack.translatesAutoresizingMaskIntoConstraints = false
        toolbar.addSubview(toolbarStack)

        urlContainer.setContentHuggingPriority(.init(1), for: .horizontal)

        NSLayoutConstraint.activate([
            toolbarStack.topAnchor.constraint(equalTo: toolbar.topAnchor),
            toolbarStack.leadingAnchor.constraint(equalTo: toolbar.leadingAnchor),
            toolbarStack.trailingAnchor.constraint(equalTo: toolbar.trailingAnchor),
            toolbarStack.bottomAnchor.constraint(equalTo: toolbar.bottomAnchor),
            urlContainer.heightAnchor.constraint(equalToConstant: 24),
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

    private func setupTabBar() {
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        tabBar.hasHorizontalScroller = false
        tabBar.hasVerticalScroller = false
        tabBar.drawsBackground = false
        tabBar.wantsLayer = true
        let tabBlur = NSVisualEffectView()
        tabBlur.material = .hudWindow
        tabBlur.blendingMode = .behindWindow
        tabBlur.state = .active
        tabBlur.translatesAutoresizingMaskIntoConstraints = false
        tabBar.addSubview(tabBlur, positioned: .below, relativeTo: nil)
        NSLayoutConstraint.activate([
            tabBlur.topAnchor.constraint(equalTo: tabBar.topAnchor),
            tabBlur.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
            tabBlur.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
            tabBlur.bottomAnchor.constraint(equalTo: tabBar.bottomAnchor),
        ])

        tabBarStack.orientation = .horizontal
        tabBarStack.spacing = 1
        tabBarStack.translatesAutoresizingMaskIntoConstraints = false
        tabBar.documentView = tabBarStack

        newTabButton.translatesAutoresizingMaskIntoConstraints = false
        newTabButton.image = NSImage(systemSymbolName: "plus", accessibilityDescription: "New Tab")
        newTabButton.isBordered = false
        newTabButton.target = self
        newTabButton.action = #selector(addNewTab)
        newTabButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        tabBarStack.addArrangedSubview(newTabButton)

        refreshTabBar()
    }

    private func refreshTabBar() {
        // Remove existing tab views (keep newTabButton)
        for view in tabBarStack.arrangedSubviews where view !== newTabButton {
            tabBarStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        // Add tab buttons
        for (i, tab) in tabs.enumerated() {
            let btn = BrowserTabButton(
                title: tab.title,
                isActive: i == activeTabIndex,
                onSelect: { [weak self] in self?.selectTab(at: i) },
                onClose: { [weak self] in self?.closeTab(at: i) }
            )
            tabBarStack.insertArrangedSubview(btn, at: i)
        }
        // Always show tab bar (like Chrome/Safari)
        tabBar.isHidden = false
    }

    @objc private func addNewTab() {
        createTab(url: URL(string: "about:blank")!)
    }

    func createTab(url: URL, configuration: WKWebViewConfiguration? = nil) {
        let config = configuration ?? WKWebViewConfiguration()
        if configuration == nil { config.limitsNavigationsToAppBoundDomains = false }
        let newWeb = WKWebView(frame: webView.frame, configuration: config)
        newWeb.navigationDelegate = self
        newWeb.uiDelegate = self
        newWeb.translatesAutoresizingMaskIntoConstraints = false

        setupConsoleLogRedirection(for: newWeb)

        let tab = BrowserTab(id: UUID(), webView: newWeb, title: "New Tab")
        tabs.append(tab)
        selectTab(at: tabs.count - 1)
        newWeb.load(URLRequest(url: url))
    }

    private var mainStack: NSStackView!

    private func selectTab(at index: Int) {
        guard tabs.indices.contains(index) else { return }
        let oldWeb = webView
        activeTabIndex = index
        let newWeb = tabs[index].webView

        if oldWeb !== newWeb {
            // Swap webView in the stack
            if let stackIndex = mainStack.arrangedSubviews.firstIndex(of: oldWeb) {
                mainStack.removeArrangedSubview(oldWeb)
                oldWeb.removeFromSuperview()
                newWeb.translatesAutoresizingMaskIntoConstraints = false
                mainStack.insertArrangedSubview(newWeb, at: stackIndex)
            }
            webView = newWeb
        }
        urlTextField.stringValue = newWeb.url?.absoluteString ?? ""
        refreshTabBar()
    }

    private func closeTab(at index: Int) {
        NSLog("BROWSER_DEBUG: closeTab(at: %d), tabs.count=%d", index, tabs.count)
        guard tabs.count > 1 else {
            // Last tab — close the entire browser pane
            SessionCoordinator.shared.splitPaneCoordinator.closeBrowserPane(paneID: paneID)
            return
        }
        tabs[index].webView.removeFromSuperview()
        tabs.remove(at: index)
        let newIndex = min(activeTabIndex, tabs.count - 1)
        selectTab(at: newIndex)
    }

    private func setupConstraints() {
        progressLine.translatesAutoresizingMaskIntoConstraints = false
        let mainStack = NSStackView(views: [tabBar, toolbar, progressLine, errorBanner, webView])
        mainStack.orientation = .vertical
        mainStack.spacing = 0
        mainStack.alignment = .width
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStack)
        self.mainStack = mainStack

        let errorConstraint = errorBanner.heightAnchor.constraint(equalToConstant: 0)
        errorBannerHeightConstraint = errorConstraint
        errorBanner.isHidden = true

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor),

            tabBar.heightAnchor.constraint(equalToConstant: 28),
            toolbar.heightAnchor.constraint(equalToConstant: 32),
            progressLine.heightAnchor.constraint(equalToConstant: 2),
            errorConstraint
        ])
    }

    private func setupProgressObservation() {
        progressObservation = webView.observe(\.estimatedProgress, options: []) { [weak self] wv, _ in
            DispatchQueue.main.async {
                self?.progressLine.setProgress(wv.estimatedProgress, isLoading: wv.isLoading)
            }
        }
    }

    private func setupConsoleLogRedirection(for webView: WKWebView) {
        let js = """
        (function() {
            if (window.__harnessConsoleRedirected) return;
            window.__harnessConsoleRedirected = true;
            var levels = ['log', 'info', 'warn', 'error', 'debug'];
            levels.forEach(function(level) {
                var original = console[level];
                console[level] = function() {
                    if (original) {
                        original.apply(console, arguments);
                    }
                    var args = Array.prototype.slice.call(arguments);
                    var msg = args.map(function(arg) {
                        if (typeof arg === 'object') {
                            try { return JSON.stringify(arg); } catch(e) { return String(arg); }
                        }
                        return String(arg);
                    }).join(' ');
                    try {
                        window.webkit.messageHandlers.harnessConsoleLog.postMessage({
                            level: level,
                            message: msg
                        });
                    } catch(e) {}
                };
            });
        })();
        """
        let userScript = WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        let controller = webView.configuration.userContentController
        controller.addUserScript(userScript)
        controller.add(WeakScriptMessageHandler(self), name: "harnessConsoleLog")
    }

    private func configureNavigationButton(_ button: SoftIconButton, symbolName: String, action: Selector) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setSymbol(symbolName, accessibilityDescription: nil, pointSize: 11, weight: .medium)
        button.target = self
        button.action = action
        button.widthAnchor.constraint(equalToConstant: 20).isActive = true
        button.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }

    // MARK: - Actions

    @objc private func closePaneClicked() {
        NSLog("BROWSER_DEBUG: closePaneClicked, onClosePaneRequested=%d", onClosePaneRequested != nil ? 1 : 0)
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
        let knownScheme = text.hasPrefix("http://") || text.hasPrefix("https://")
            || text.hasPrefix("file://") || text.hasPrefix("ftp://")
        let looksLikeDomain = !text.contains(" ")
            && (text.contains(".") || text.hasPrefix("localhost") || text.hasPrefix("127."))
        if knownScheme {
            url = URL(string: text) ?? searchURL(for: text)
        } else if looksLikeDomain {
            url = URL(string: "https://\(text)") ?? searchURL(for: text)
        } else {
            url = searchURL(for: text)
        }
        navigate(to: url)
    }

    private func searchURL(for query: String) -> URL {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        return URL(string: "https://www.google.com/search?q=\(encoded)") ?? URL(string: "about:blank")!
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

    // MARK: - Auto-retry on connection loss

    private func startRetryIfConnectionError(_ error: Error) {
        let nsError = error as NSError
        // NSURLErrorDomain connection failures (server down, refused, timeout, network lost)
        let retryableCodes: Set<Int> = [
            NSURLErrorCannotConnectToHost,      // -1004
            NSURLErrorNetworkConnectionLost,    // -1005
            NSURLErrorNotConnectedToInternet,   // -1009
            NSURLErrorTimedOut,                 // -1001
            NSURLErrorCannotFindHost,           // -1003
        ]
        guard nsError.domain == NSURLErrorDomain, retryableCodes.contains(nsError.code) else { return }
        guard retryTimer == nil else { return }
        retryCount = 0
        showErrorBanner(message: "Server disconnected — reconnecting…")
        retryTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.attemptRetry()
            }
        }
    }

    private func attemptRetry() {
        retryCount += 1
        if retryCount > Self.maxRetries {
            cancelRetry()
            // Auto-close: server didn't come back within 30s
            onClosePaneRequested?()
            return
        }
        errorLabel.stringValue = "Reconnecting… (\(retryCount)/\(Self.maxRetries))"
        webView.reload()
    }

    private func cancelRetry() {
        retryTimer?.invalidate()
        retryTimer = nil
        retryCount = 0
    }

    private func updateReloadStopButton(isLoading: Bool) {
        let symbol = isLoading ? "xmark" : "arrow.clockwise"
        reloadStopButton.setSymbol(symbol, accessibilityDescription: nil, pointSize: 11, weight: .medium)
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
        var snapshot = try JSONDecoder().decode(BrowserSnapshot.self, from: data)
        snapshot.logs = self.consoleLogs
        return snapshot
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
        cancelRetry()
        if let url = webView.url {
            urlTextField.stringValue = url.absoluteString
            UserDefaults.standard.set(url.absoluteString, forKey: "browserPane.\(paneID.uuidString).url")
        }
        // Update tab title
        if let idx = tabs.firstIndex(where: { $0.webView === webView }) {
            let title = webView.title ?? webView.url?.host ?? "Tab"
            tabs[idx].title = String(title.prefix(20))
            refreshTabBar()
        }
        completeLoading()
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        updateReloadStopButton(isLoading: false)
        showErrorBanner(message: error.localizedDescription)
        startRetryIfConnectionError(error)
        completeLoading(error: error)
    }

    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        updateReloadStopButton(isLoading: false)
        showErrorBanner(message: error.localizedDescription)
        startRetryIfConnectionError(error)
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
            let url = navigationAction.request.url ?? URL(string: "about:blank")!
            createTab(url: url, configuration: configuration)
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

// MARK: - Browser Tab Button

@MainActor
private final class BrowserTabButton: NSView {
    private let label = NSTextField(labelWithString: "")
    private let closeBtn = NSButton()
    private var onSelect: () -> Void
    private var onClose: () -> Void

    init(title: String, isActive: Bool, onSelect: @escaping () -> Void, onClose: @escaping () -> Void) {
        self.onSelect = onSelect
        self.onClose = onClose
        super.init(frame: .zero)
        wantsLayer = true
        layer?.cornerRadius = 6
        layer?.cornerCurve = .continuous
        layer?.backgroundColor = isActive
            ? HarnessDesign.chrome.surfaceElevated.cgColor
            : NSColor.clear.cgColor
        translatesAutoresizingMaskIntoConstraints = false

        label.stringValue = title.isEmpty ? "New Tab" : title
        label.font = .systemFont(ofSize: 11.5, weight: .regular)
        label.textColor = isActive ? HarnessDesign.chrome.textPrimary : HarnessDesign.chrome.textSecondary
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false

        closeBtn.image = NSImage(systemSymbolName: "xmark", accessibilityDescription: "Close Tab")?
            .withSymbolConfiguration(.init(pointSize: 7, weight: .semibold))
        closeBtn.isBordered = false
        closeBtn.target = self
        closeBtn.action = #selector(closeTapped)
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        closeBtn.contentTintColor = HarnessDesign.chrome.textSecondary

        addSubview(label)
        addSubview(closeBtn)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 26),
            widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            widthAnchor.constraint(lessThanOrEqualToConstant: 180),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.trailingAnchor.constraint(lessThanOrEqualTo: closeBtn.leadingAnchor, constant: -4),
            closeBtn.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6),
            closeBtn.centerYAnchor.constraint(equalTo: centerYAnchor),
            closeBtn.widthAnchor.constraint(equalToConstant: 20),
            closeBtn.heightAnchor.constraint(equalToConstant: 20),
        ])

        let click = NSClickGestureRecognizer(target: self, action: #selector(selectTapped(_:)))
        // delaysPrimaryMouseButtonEvents defaults to true which swallows the mouse-down before
        // it reaches the close button's NSButton. Setting false lets button + recognizer coexist.
        click.delaysPrimaryMouseButtonEvents = false
        addGestureRecognizer(click)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override func hitTest(_ point: NSPoint) -> NSView? {
        // CASE-038: NSClickGestureRecognizer intercepts NSButton clicks.
        // Return the close button directly so it receives the full mouse event.
        let localToClose = closeBtn.convert(point, from: self)
        if closeBtn.bounds.contains(localToClose) { return closeBtn }
        return super.hitTest(point)
    }

    @objc private func selectTapped(_ gesture: NSClickGestureRecognizer) {
        let loc = gesture.location(in: self)
        if closeBtn.frame.contains(loc) { return }
        onSelect()
    }
    @objc private func closeTapped() {
        NSLog("BROWSER_DEBUG: closeTapped fired")
        onClose()
    }
}

// MARK: - Progress bar

@MainActor
private final class BrowserProgressLine: NSView {
    private let fill = NSView()
    private var fillWidth: NSLayoutConstraint?

    override init(frame: NSRect) {
        super.init(frame: frame)
        wantsLayer = true
        fill.wantsLayer = true
        fill.layer?.backgroundColor = NSColor.controlAccentColor.cgColor
        fill.translatesAutoresizingMaskIntoConstraints = false
        addSubview(fill)
        let widthConstraint = fill.widthAnchor.constraint(equalToConstant: 0)
        fillWidth = widthConstraint
        NSLayoutConstraint.activate([
            fill.leadingAnchor.constraint(equalTo: leadingAnchor),
            fill.topAnchor.constraint(equalTo: topAnchor),
            fill.bottomAnchor.constraint(equalTo: bottomAnchor),
            widthConstraint,
        ])
        alphaValue = 0
    }
    required init?(coder: NSCoder) { fatalError() }

    func setProgress(_ progress: Double, isLoading: Bool) {
        let w = bounds.width > 0 ? bounds.width : superview?.bounds.width ?? 400
        let target = w * CGFloat(min(max(progress, 0), 1))
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.2
            fillWidth?.animator().constant = target
        }
        if isLoading {
            NSAnimationContext.runAnimationGroup { ctx in
                ctx.duration = 0.1
                self.animator().alphaValue = 1
            }
        } else {
            NSAnimationContext.runAnimationGroup({ ctx in
                ctx.duration = 0.2
                fillWidth?.animator().constant = w
            }, completionHandler: {
                NSAnimationContext.runAnimationGroup { ctx in
                    ctx.duration = 0.25
                    self.animator().alphaValue = 0
                }
                self.fillWidth?.constant = 0
            })
        }
    }
}

extension BrowserPaneView: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String: Any],
              let level = body["level"] as? String,
              let text = body["message"] as? String else {
            return
        }
        
        let logLine = "[\(level.uppercased())] \(text)"
        
        // Append to memory array (cap size to 200)
        consoleLogs.append(logLine)
        if consoleLogs.count > 200 {
            consoleLogs.removeFirst(consoleLogs.count - 200)
        }
        
        // Write/append to file asynchronously on a background queue to not block Main thread
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let timestamp = df.string(from: Date())
        
        let fileLine = "[\(timestamp)] [\(level.uppercased())] \(text)\n"
        let tempDir = NSTemporaryDirectory()
        let logPath = (tempDir as NSString).appendingPathComponent("harness-browser-\(paneID.uuidString).log")
        
        DispatchQueue.global(qos: .utility).async {
            let url = URL(fileURLWithPath: logPath)
            if let data = fileLine.data(using: .utf8) {
                if let fileHandle = try? FileHandle(forWritingTo: url) {
                    defer { try? fileHandle.close() }
                    _ = try? fileHandle.seekToEnd()
                    _ = try? fileHandle.write(contentsOf: data)
                } else {
                    _ = try? data.write(to: url, options: .atomic)
                }
            }
        }
    }
}

@MainActor
private final class WeakScriptMessageHandler: NSObject, WKScriptMessageHandler {
    private weak var handler: WKScriptMessageHandler?

    init(_ handler: WKScriptMessageHandler) {
        self.handler = handler
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        handler?.userContentController(userContentController, didReceive: message)
    }
}
