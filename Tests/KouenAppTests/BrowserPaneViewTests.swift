import AppKit
import XCTest
import WebKit
import KouenCore
@testable import KouenApp

@MainActor
final class BrowserPaneViewTests: XCTestCase {
    func testURLBarUpdatesOnCommitAndFinish() {
        let mockWebView = MockWebView(frame: .zero, configuration: WKWebViewConfiguration())
        let testURL = URL(string: "https://example.com/test")!
        mockWebView.mockURL = testURL

        let paneView = BrowserPaneView(url: testURL, paneID: UUID(), webView: mockWebView)

        // Simulating didCommit
        paneView.webView(mockWebView, didCommit: nil)
        // Verify URL text field matches testURL
        XCTAssertEqual(paneView.urlTextField.stringValue, "https://example.com/test")

        // Simulating didFinish
        let finishURL = URL(string: "https://example.com/finish")!
        mockWebView.mockURL = finishURL
        paneView.webView(mockWebView, didFinish: nil)
        XCTAssertEqual(paneView.urlTextField.stringValue, "https://example.com/finish")
    }

    // Regression for the black screen during load: WKWebView is transparent
    // (drawsBackground=false) so the container's solid terminalBackground canvas shows
    // through until WebKit actually composites the page. Waiting solely for didFinish
    // leaves the pane pitch black while heavy subresources (JS bundles, stylesheets)
    // are being fetched on slow networks or large pages. didCommit must also force
    // that compositor commit so initial HTML paint appears immediately.
    func testDidCommitTriggersCompositorKickToForcePaint() {
        let mockWebView = MockWebView(frame: .zero, configuration: WKWebViewConfiguration())
        let testURL = URL(string: "https://example.com/test")!
        mockWebView.mockURL = testURL
        mockWebView.allowsMagnification = true

        let paneView = BrowserPaneView(url: testURL, paneID: UUID(), webView: mockWebView)
        paneView.webView(mockWebView, didCommit: nil)

        XCTAssertFalse(mockWebView.setMagnificationCalls.isEmpty,
            "didCommit should kick the compositor so initial HTML paint is not stuck black waiting for didFinish")
    }

    func testBackToBackCompositorKicksDoNotDropOrDriftMagnification() {
        let mockWebView = MockWebView(frame: .zero, configuration: WKWebViewConfiguration())
        let testURL = URL(string: "https://example.com/test")!
        mockWebView.mockURL = testURL
        mockWebView.allowsMagnification = true

        let paneView = BrowserPaneView(url: testURL, paneID: UUID(), webView: mockWebView)
        paneView.webView(mockWebView, didCommit: nil)
        mockWebView.setMagnificationCalls.removeAll()

        // didFinish arriving immediately (< 50ms) after didCommit must still kick
        // the compositor rather than being dropped by an in-flight guard.
        paneView.webView(mockWebView, didFinish: nil)
        XCTAssertFalse(mockWebView.setMagnificationCalls.isEmpty,
            "didFinish arriving within 50ms of didCommit must still kick the compositor")

        let settled = expectation(description: "magnification restored to base")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { settled.fulfill() }
        wait(for: [settled], timeout: 1)

        XCTAssertEqual(mockWebView.setMagnificationCalls.last?.magnification ?? 0, 1.0, accuracy: 0.0001,
            "Magnification must restore to the original base value without drifting")
    }

    func testViewDidMoveToWindowTriggersForceRepaint() {
        let mockWebView = MockWebView(frame: .zero, configuration: WKWebViewConfiguration())
        let testURL = URL(string: "https://example.com/test")!
        mockWebView.mockURL = testURL
        mockWebView.allowsMagnification = true

        let paneView = BrowserPaneView(url: testURL, paneID: UUID(), webView: mockWebView)
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 600, height: 400), styleMask: [.titled], backing: .buffered, defer: false)
        mockWebView.evaluateJavaScriptCalls.removeAll()

        window.contentView?.addSubview(paneView)

        XCTAssertFalse(mockWebView.evaluateJavaScriptCalls.isEmpty,
            "Moving to window must trigger forceRepaint() to wake WKWebView's compositor")
    }

    func testDidCommitUpdatesTabTitleWhenAvailable() {
        let mockWebView = MockWebView(frame: .zero, configuration: WKWebViewConfiguration())
        let testURL = URL(string: "https://github.com/Vit129/My-Investment-Port/pull/112")!
        mockWebView.mockURL = testURL
        mockWebView.mockTitle = "PR #112 · Vit129"

        let paneView = BrowserPaneView(url: testURL, paneID: UUID(), webView: mockWebView)
        paneView.webView(mockWebView, didCommit: nil)

        XCTAssertEqual(paneView.activeTabTitle, "PR #112 · Vit129")
    }

    // Regression for the intermittent fully-black content area: WKWebView is
    // deliberately transparent (drawsBackground=false) so the container's solid
    // terminalBackground canvas shows through until WebKit actually composites the
    // page. didFinish must force that compositor commit (kickCompositorRelayout) so
    // a page that finishes loading but loses the paint race doesn't stay black
    // until a manual reload.
    func testDidFinishTriggersCompositorKickToForcePaint() {
        let mockWebView = MockWebView(frame: .zero, configuration: WKWebViewConfiguration())
        let testURL = URL(string: "https://example.com/test")!
        mockWebView.mockURL = testURL
        mockWebView.allowsMagnification = true

        let paneView = BrowserPaneView(url: testURL, paneID: UUID(), webView: mockWebView)
        paneView.webView(mockWebView, didFinish: nil)

        XCTAssertFalse(mockWebView.setMagnificationCalls.isEmpty,
            "didFinish should kick the compositor so a completed load can't stay stuck black")
    }

    // Regression: a tab opened via createTab() (Cmd+T, or a link/window.open that pops
    // a new tab) must also get allowsMagnification=true, same as the pane's first tab —
    // otherwise kickCompositorRelayout()'s guard silently no-ops for it forever, and no
    // amount of reload can fix its stuck-black first paint.
    func testCreateTabSetsAllowsMagnificationForCompositorKick() {
        let testURL = URL(string: "https://example.com/test")!
        let mockWebView = MockWebView(frame: .zero, configuration: WKWebViewConfiguration())
        mockWebView.mockURL = testURL
        let paneView = BrowserPaneView(url: testURL, paneID: UUID(), webView: mockWebView)

        let newTabWebView = paneView.createTab(url: URL(string: "https://example.com/new-tab")!)

        XCTAssertTrue(newTabWebView.allowsMagnification,
            "createTab()'s webview must allow magnification, or the compositor kick in didFinish is a permanent no-op for this tab")
    }

    // Regression for the black screen on tab switch: PaneLifecycleManager's fast path
    // reveals a cached (previously hidden) pane container by toggling `isHidden` alone,
    // never re-adding it to the view hierarchy — so WKWebView's remote layer can stay
    // stale/black unless something explicitly nudges its compositor. forceRepaint()
    // is that nudge; it must actually fire once the pane is attached to a real window.
    func testForceRepaintWakesWebViewWhenAttachedToWindow() {
        let mockWebView = MockWebView(frame: .zero, configuration: WKWebViewConfiguration())
        let testURL = URL(string: "https://example.com/test")!
        mockWebView.mockURL = testURL
        mockWebView.allowsMagnification = true
        let paneView = BrowserPaneView(url: testURL, paneID: UUID(), webView: mockWebView)

        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 400, height: 300), styleMask: [.titled], backing: .buffered, defer: false)
        window.contentView?.addSubview(paneView)
        mockWebView.evaluateJavaScriptCalls.removeAll()

        paneView.forceRepaint()

        XCTAssertFalse(mockWebView.evaluateJavaScriptCalls.isEmpty,
            "forceRepaint() must wake WKWebView's compositor once the pane is in a real window, or a revealed-from-cache tab stays black")
        // setNeedsDisplay/evaluateJavaScript alone don't force a synchronous compositor
        // commit — the magnification-nudge kick (already proven in didFinish, see
        // testDidFinishTriggersCompositorKickToForcePaint) must fire too.
        XCTAssertFalse(mockWebView.setMagnificationCalls.isEmpty,
            "forceRepaint() must also kick the compositor via magnification nudge, or a revealed-from-cache tab can still stay stuck black")
    }

    // Regression for the black screen on tab switch (both plain tab-bar clicks and
    // closeTab, which both funnel through selectTab): dbc950c3 only wired forceRepaint()
    // into viewDidMoveToSuperview() and PaneLifecycleManager's cache-reveal path — it
    // never touched selectTab()'s own webView swap, so switching back to a
    // previously-detached tab's WKWebView left its compositor layer stale/black with no
    // nudge to wake it.
    func testSelectTabWakesRevealedWebViewCompositor() {
        let mockWebView = MockWebView(frame: .zero, configuration: WKWebViewConfiguration())
        let testURL = URL(string: "https://example.com/test")!
        mockWebView.mockURL = testURL
        mockWebView.allowsMagnification = true
        let paneView = BrowserPaneView(url: testURL, paneID: UUID(), webView: mockWebView)

        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 400, height: 300), styleMask: [.titled], backing: .buffered, defer: false)
        window.contentView?.addSubview(paneView)

        // Open a second tab — mockWebView (tab 0) is now detached from the stack.
        _ = paneView.createTab(url: URL(string: "https://example.com/tab2")!)

        // createTab()'s own tab switch just kicked the compositor; let that in-flight
        // guard (compositorKickInFlight) clear before switching again, or the kick below
        // gets silently skipped for an unrelated reason and the test proves nothing.
        let settled = expectation(description: "compositor kick in-flight guard cleared")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { settled.fulfill() }
        wait(for: [settled], timeout: 1)

        mockWebView.evaluateJavaScriptCalls.removeAll()
        mockWebView.setMagnificationCalls.removeAll()

        // Switch back to tab 0 — reattaches mockWebView to the stack.
        paneView.selectTab(at: 0)

        XCTAssertFalse(mockWebView.evaluateJavaScriptCalls.isEmpty,
            "selectTab() must wake the revealed tab's WKWebView compositor, or switching back to a tab stays black")
        XCTAssertFalse(mockWebView.setMagnificationCalls.isEmpty,
            "selectTab() must also kick the compositor via magnification nudge, or the revealed tab can still stay stuck black")
    }

    // MARK: - Design Mode (M3)

    func testDesignModeButtonHasExpectedIdentifierAndTooltip() {
        let testURL = URL(string: "https://example.com/test")!
        let mockWebView = MockWebView(frame: .zero, configuration: WKWebViewConfiguration())
        mockWebView.mockURL = testURL
        let paneView = BrowserPaneView(url: testURL, paneID: UUID(), webView: mockWebView)

        XCTAssertEqual(paneView.designModeButton.accessibilityIdentifier(), "browser-design-mode-button")
        XCTAssertNotNil(paneView.designModeButton.toolTip)
    }

    func testCssPropertyNameConvertsCamelCaseToKebabCase() {
        XCTAssertEqual(BrowserPaneView.cssPropertyName("backgroundColor"), "background-color")
        XCTAssertEqual(BrowserPaneView.cssPropertyName("fontSize"), "font-size")
        XCTAssertEqual(BrowserPaneView.cssPropertyName("color"), "color")
        XCTAssertEqual(BrowserPaneView.cssPropertyName("border"), "border")
    }

    func testCssSelectorPrefersID() {
        let info = BrowserPaneView.DesignModeElementInfo(tag: "button", id: "submit-btn", className: "btn btn-primary", styles: [:])
        XCTAssertEqual(BrowserPaneView.cssSelector(for: info), "#submit-btn")
    }

    func testCssSelectorFallsBackToTagAndAllClasses() {
        let info = BrowserPaneView.DesignModeElementInfo(tag: "button", id: "", className: "btn btn-primary", styles: [:])
        XCTAssertEqual(BrowserPaneView.cssSelector(for: info), "button.btn.btn-primary")
    }

    func testCssSelectorFallsBackToBareTagWhenNoIdOrClass() {
        let info = BrowserPaneView.DesignModeElementInfo(tag: "div", id: "", className: "", styles: [:])
        XCTAssertEqual(BrowserPaneView.cssSelector(for: info), "div")
    }

    func testViewSourceButtonVisibleOnlyForLocalHTML() {
        let mockWebView = MockWebView(frame: .zero, configuration: WKWebViewConfiguration())
        let testURL = URL(string: "https://example.com/test")!
        mockWebView.mockURL = testURL

        let paneView = BrowserPaneView(url: testURL, paneID: UUID(), webView: mockWebView)
        paneView.webView(mockWebView, didCommit: nil)
        XCTAssertTrue(paneView.viewSourceButton.isHidden, "remote URL should not show View Source")

        let fileURL = URL(fileURLWithPath: "/tmp/report.html")
        mockWebView.mockURL = fileURL
        paneView.webView(mockWebView, didCommit: nil)
        XCTAssertFalse(paneView.viewSourceButton.isHidden, "local .html file:// URL should show View Source")
    }

    func testRemovePaneNodeCollapsesBranch() {
        let coordinator = SessionCoordinator.shared.splitPaneCoordinator
        let firstBrowserID = UUID()
        let secondBrowserID = UUID()
        let termLeaf = PaneLeaf()

        // Test split: [ firstBrowser | [ secondBrowser | termLeaf ] ]
        let innerBranch = PaneNode.branch(
            direction: .vertical,
            ratio: 0.5,
            first: .browser(BrowserLeaf(id: secondBrowserID, url: URL(string: "https://example.com/2")!)),
            second: .leaf(termLeaf)
        )

        var root = PaneNode.branch(
            direction: .horizontal,
            ratio: 0.5,
            first: .browser(BrowserLeaf(id: firstBrowserID, url: URL(string: "https://example.com/1")!)),
            second: innerBranch
        )

        // 1. Remove secondBrowserID, should collapse innerBranch to just termLeaf
        let removedSecond = coordinator.removePaneNode(paneID: secondBrowserID, from: &root)
        XCTAssertTrue(removedSecond)

        // Verify root is now: [ firstBrowser | termLeaf ]
        guard case let .branch(_, _, firstNode, secondNode) = root else {
            XCTFail("Root should still be a branch after nested collapse")
            return
        }
        XCTAssertEqual(firstNode.paneID, firstBrowserID)
        XCTAssertEqual(secondNode.paneID, termLeaf.id)

        // 2. Remove firstBrowserID, should collapse the whole tree to just termLeaf
        let removedFirst = coordinator.removePaneNode(paneID: firstBrowserID, from: &root)
        XCTAssertTrue(removedFirst)
        XCTAssertEqual(root.paneID, termLeaf.id)
    }

    func testOpenBrowserPaneReusesExistingBrowserPaneInTab() {
        let initialURL = URL(string: "https://example.com/initial")!
        let newURL = URL(string: "https://example.com/new-pr")!
        let browserPaneID = UUID()

        let mockWebView = MockWebView(frame: .zero, configuration: WKWebViewConfiguration())
        let paneView = BrowserPaneView(url: initialURL, paneID: browserPaneID, webView: mockWebView)
        BrowserPaneRegistry.shared.register(paneView)
        defer {
            BrowserPaneRegistry.shared.unregister(browserPaneID)
        }

        let browserLeaf = BrowserLeaf(id: browserPaneID, url: initialURL)
        let tab = Tab(id: TabID(), cwd: "/tmp", rootPane: .browser(browserLeaf))
        let session = SessionGroup(id: SessionID(), tabs: [tab], activeTabID: tab.id)
        let workspace = Workspace(id: WorkspaceID(), name: "Test", sessions: [session], activeSessionID: session.id)
        let snapshot = SessionSnapshot(workspaces: [workspace], activeWorkspaceID: workspace.id)

        SessionCoordinator.shared.daemonSyncService.applyLocalSnapshot(snapshot)

        XCTAssertEqual(paneView.tabCount, 1)

        let returnedPaneID = SessionCoordinator.shared.splitPaneCoordinator.openBrowserPane(
            url: newURL,
            direction: .horizontal
        )

        XCTAssertEqual(returnedPaneID, browserPaneID, "Should reuse the existing browser pane ID")
        XCTAssertEqual(paneView.tabCount, 2, "Should create a new tab in the existing browser pane instead of splitting")
    }

    func testBrowserPaneHitTestAndActions() {
        let mockWebView = MockWebView(frame: .zero, configuration: WKWebViewConfiguration())
        let testURL = URL(string: "https://example.com/test")!
        mockWebView.mockURL = testURL

        let paneView = BrowserPaneView(url: testURL, paneID: UUID(), webView: mockWebView)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.contentView = paneView

        // Force layout
        window.contentView?.layoutSubtreeIfNeeded()
        paneView.layoutSubtreeIfNeeded()

        // Assert initial state: errorBanner is hidden
        XCTAssertTrue(paneView.errorBanner.isHidden)
        XCTAssertEqual(paneView.errorBannerHeightConstraint?.constant, 0)

        // Compute center point of closePaneButton
        let closeCenter = CGPoint(x: paneView.closePaneButton.bounds.midX, y: paneView.closePaneButton.bounds.midY)
        guard let superview = paneView.superview else {
            XCTFail("Expected paneView to have a superview")
            return
        }
        let closeCenterInSuper = superview.convert(closeCenter, from: paneView.closePaneButton)
        let hitViewClose = paneView.hitTest(closeCenterInSuper)
        XCTAssertNotNil(hitViewClose)
        XCTAssertTrue(hitViewClose === paneView.closePaneButton || hitViewClose!.isDescendant(of: paneView.closePaneButton))
        XCTAssertNotEqual(hitViewClose, paneView.errorDismissButton)
        XCTAssertFalse(hitViewClose!.isDescendant(of: paneView.errorDismissButton))

        // Compute center point of reloadStopButton
        let reloadCenter = CGPoint(x: paneView.reloadStopButton.bounds.midX, y: paneView.reloadStopButton.bounds.midY)
        let reloadCenterInSuper = superview.convert(reloadCenter, from: paneView.reloadStopButton)
        let hitViewReload = paneView.hitTest(reloadCenterInSuper)
        XCTAssertNotNil(hitViewReload)
        XCTAssertTrue(hitViewReload === paneView.reloadStopButton || hitViewReload!.isDescendant(of: paneView.reloadStopButton))

        // Action test: close pane
        var closeCalled = false
        paneView.onClosePaneRequested = {
            closeCalled = true
        }
        paneView.closePaneButton.performClick(nil)
        XCTAssertTrue(closeCalled)

        // Action test: reload click when webView is not loading
        mockWebView.mockIsLoading = false
        paneView.reloadStopButton.performClick(nil)
        XCTAssertTrue(mockWebView.reloadCalled)

        // Action test: stop click when webView is loading
        mockWebView.mockIsLoading = true
        paneView.webView(mockWebView, didStartProvisionalNavigation: nil)
        paneView.reloadStopButton.performClick(nil)
        XCTAssertTrue(mockWebView.stopLoadingCalled)
    }

    func testDisposingUnclaimedBrowserPaneReleasesPaneAndKeepsReusedPaneAlive() {
        let closedID = UUID()
        let keptID = UUID()
        var controller: BrowserIntegrationController?
        var didStopClosedWebView = false
        var closedDelegatesWereCleared = false
        weak var releasedPane: BrowserPaneView?
        weak var reusedPane: BrowserPaneView?
        let host = NSView()

        autoreleasepool {
            let closedWebView = MockWebView(frame: .zero, configuration: WKWebViewConfiguration())
            let keptWebView = MockWebView(frame: .zero, configuration: WKWebViewConfiguration())
            let closedPane = BrowserPaneView(
                url: URL(string: "https://example.com/closed")!, paneID: closedID, webView: closedWebView
            )
            let keptPane = BrowserPaneView(
                url: URL(string: "https://example.com/kept")!, paneID: keptID, webView: keptWebView
            )
            releasedPane = closedPane
            reusedPane = keptPane

            controller = BrowserIntegrationController(existingPanes: [closedID: closedPane, keptID: keptPane])
            controller?.buildNode(
                BrowserLeaf(id: keptID, url: URL(string: "https://example.com/kept")!), into: host
            )
            controller?.disposeUnclaimedPanes()
            didStopClosedWebView = closedWebView.stopLoadingCalled
            closedDelegatesWereCleared = closedWebView.navigationDelegate == nil && closedWebView.uiDelegate == nil
        }

        XCTAssertTrue(didStopClosedWebView)
        XCTAssertTrue(closedDelegatesWereCleared)
        XCTAssertNil(releasedPane, "the closed pane must be released after its references are dropped")
        XCTAssertNotNil(reusedPane, "the browser pane retained by the new tree must stay alive")
        XCTAssertTrue(controller?.collectBrowserPanes(in: host)[keptID] === reusedPane)
        XCTAssertTrue(reusedPane?.webView.navigationDelegate === reusedPane)
    }

    func testDidFinishAndCommitFallBackToHostWhenWebViewTitleIsEmptyString() {
        let mockWebView = MockWebView(frame: .zero, configuration: WKWebViewConfiguration())
        let testURL = URL(string: "https://github.com/Vit129/space-")!
        mockWebView.mockURL = testURL
        // WKWebView returns "" (empty string, not nil) when <title> is missing or not yet parsed.
        mockWebView.mockTitle = ""

        let paneView = BrowserPaneView(url: testURL, paneID: UUID(), webView: mockWebView)
        paneView.webView(mockWebView, didFinish: nil)

        XCTAssertEqual(paneView.activeTabTitle, "github.com",
            "Empty webView.title must fall back to URL host instead of leaving the tab stuck at 'New Tab'")
    }

    func testProgressLineHidesOnFinishAndFail() {
        let mockWebView = MockWebView(frame: .zero, configuration: WKWebViewConfiguration())
        let testURL = URL(string: "https://example.com/test")!
        mockWebView.mockURL = testURL

        let paneView = BrowserPaneView(url: testURL, paneID: UUID(), webView: mockWebView)
        paneView.webView(mockWebView, didStartProvisionalNavigation: nil)
        XCTAssertTrue(paneView.progressLine.isShowingProgress,
            "didStartProvisionalNavigation must mark progressLine as showing")

        paneView.webView(mockWebView, didFinish: nil)
        XCTAssertFalse(paneView.progressLine.isShowingProgress,
            "didFinish must hide progressLine so it does not stay stuck blue after load completes")

        paneView.webView(mockWebView, didStartProvisionalNavigation: nil)
        XCTAssertTrue(paneView.progressLine.isShowingProgress)
        paneView.webView(mockWebView, didFailProvisionalNavigation: nil, withError: NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut))
        XCTAssertFalse(paneView.progressLine.isShowingProgress,
            "didFailProvisionalNavigation must hide progressLine")
    }

    func testWebViewAndProgressLineSpanFullPaneWidthAfterLayout() {
        let mockWebView = MockWebView(frame: .zero, configuration: WKWebViewConfiguration())
        let testURL = URL(string: "https://example.com/test")!
        mockWebView.mockURL = testURL

        let paneView = BrowserPaneView(url: testURL, paneID: UUID(), webView: mockWebView)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
            styleMask: [.titled],
            backing: .buffered,
            defer: false
        )
        window.contentView = paneView
        window.contentView?.layoutSubtreeIfNeeded()
        paneView.layoutSubtreeIfNeeded()

        XCTAssertEqual(paneView.webView.frame.width, 600, accuracy: 0.5,
            "webView must be pinned to the full width of mainStack")
        XCTAssertEqual(paneView.progressLine.frame.width, 600, accuracy: 0.5,
            "progressLine must be pinned to the full width of mainStack")
    }
}

private final class MockWebView: WKWebView {
    var mockURL: URL?
    override var url: URL? {
        return mockURL
    }

    var mockTitle: String?
    override var title: String? {
        return mockTitle
    }

    var mockIsLoading: Bool = false
    override var isLoading: Bool {
        return mockIsLoading
    }

    var reloadCalled = false
    override func reload() -> WKNavigation? {
        reloadCalled = true
        return nil
    }

    var stopLoadingCalled = false
    override func stopLoading() {
        stopLoadingCalled = true
    }

    var setMagnificationCalls: [(magnification: CGFloat, centeredAt: CGPoint)] = []
    override func setMagnification(_ magnification: CGFloat, centeredAt point: CGPoint) {
        setMagnificationCalls.append((magnification, point))
    }

    var evaluateJavaScriptCalls: [String] = []
    override func evaluateJavaScript(_ javaScriptString: String, completionHandler: (@MainActor @Sendable (Any?, (any Error)?) -> Void)? = nil) {
        evaluateJavaScriptCalls.append(javaScriptString)
        completionHandler?(nil, nil)
    }
}
