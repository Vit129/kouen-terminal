import AppKit
import HarnessCore
import QuartzCore

@MainActor
private final class EffectiveAppearanceReportingView: NSView {
    override func viewDidChangeEffectiveAppearance() {
        super.viewDidChangeEffectiveAppearance()
        (window?.windowController as? MainWindowController)?.effectiveAppearanceDidChange()
    }
}

@MainActor
final class MainSplitViewController: NSViewController {
    /// The session this window shows (see `WindowContext`).
    let context: WindowContext
    private let split = SidebarSplitView()
    private let sidebar = HarnessSidebarPanelViewController()
    private let content = ContentAreaViewController()

    init(context: WindowContext) {
        self.context = context
        super.init(nibName: nil, bundle: nil)
        sidebar.context = context
        content.context = context
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    /// ⌃⌘S: drop the switcher from the sessions button when the tab row shows it.
    func showSessionSwitcher() {
        content.showSessionSwitcher()
    }
    private let statusLine = StatusLineView()
    var statusLineHeight: CGFloat { statusLine.isHidden ? 0 : statusLine.frame.height }
    /// 1px hairline along the inner edge of the sidebar — adds quiet definition
    /// between sidebar/terminal without resorting to a draggable divider line.
    private let edgeDivider = NSView()
    /// Bumped each time a sidebar collapse/expand starts so any in-flight animation
    /// frame bails out — prevents two toggles from fighting over the divider position.
    private var sidebarAnimation: DisplayAnimation?
    /// Owned (not a singleton) so collapse state is per-window. Carries the
    /// `allowFullCollapse` flag the divider min-coordinate reads.
    private let splitDelegate = SplitChromeDelegate()
    /// The vertical chain that places the status footer below the split (tmux
    /// `status-position bottom`, the default).
    private var statusBottomConstraints: [NSLayoutConstraint] = []
    /// The vertical chain that places the status footer above the split (`status-position top`).
    private var statusTopConstraints: [NSLayoutConstraint] = []
    /// Last applied position, so a metadata-only snapshot nudge only re-lays-out on a real change.
    private var appliedStatusPosition: StatusPosition?

    override func loadView() {
        // The root contentView must stay a plain, NON-layer-backed NSView. A plain NSView
        // draws nothing (transparent by default), so the window blur shows through — but it
        // is *not* layer-backed, so the window server rounds the frame + CGS background blur
        // together. Calling `makeClear` here would set `wantsLayer` and
        // layer-back the whole window, which clips the blur to a rectangle and leaves a dark
        // compositing seam at the rounded edge. See MainWindowController.applyTransparency.
        view = EffectiveAppearanceReportingView(frame: NSRect(origin: .zero, size: HarnessDesign.defaultWindowSize))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        split.frame = view.bounds
        split.isVertical = true
        split.dividerStyle = .thin
        // No autosaveName: visibility lives in `settings.sidebarVisible` and is
        // re-applied on load; an autosaved divider width would restore a stale
        // collapsed state and fight the settings-driven restore.
        split.delegate = splitDelegate
        content.setTabRowHidden(SessionCoordinator.shared.settings.sidebarVisible)

        // Container is a transparent wrapper so the sidebar.view's own chrome
        // backdrop is the only one in play. Stacking two ChromeBackdrops (one
        // here, one in HarnessSidebarPanelViewController.loadView) doubled up
        // the glass+tint and shifted the sidebar's perceived tint relative to
        // the terminal side — making the top of the window read as a darker
        // strip even though both regions request the same theme color.
        let sidebarContainer = NSView(frame: NSRect(x: 0, y: 0, width: HarnessDesign.sidebarWidth,
                                                    height: view.bounds.height))
        HarnessDesign.makeClear(sidebarContainer)
        sidebarContainer.layer?.masksToBounds = true
        sidebarContainer.translatesAutoresizingMaskIntoConstraints = false
        sidebar.view.translatesAutoresizingMaskIntoConstraints = false
        sidebarContainer.addSubview(sidebar.view)
        // Keep the sidebar's controls at a usable width while its wrapper collapses.
        // Squeezing their required constraints to zero makes AppKit break the layout.
        let sidebarWidth = sidebar.view.widthAnchor.constraint(equalTo: sidebarContainer.widthAnchor)
        sidebarWidth.priority = .defaultHigh
        NSLayoutConstraint.activate([
            sidebar.view.topAnchor.constraint(equalTo: sidebarContainer.topAnchor),
            sidebar.view.leadingAnchor.constraint(equalTo: sidebarContainer.leadingAnchor),
            sidebarWidth,
            sidebar.view.widthAnchor.constraint(greaterThanOrEqualToConstant: SplitChromeDelegate.minimumWidth),
            sidebar.view.bottomAnchor.constraint(equalTo: sidebarContainer.bottomAnchor),
        ])

        split.addSubview(sidebarContainer)
        split.addSubview(content.view)
        addChild(sidebar)
        addChild(content)

        split.translatesAutoresizingMaskIntoConstraints = false
        statusLine.translatesAutoresizingMaskIntoConstraints = false
        edgeDivider.wantsLayer = true
        edgeDivider.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(split)
        view.addSubview(statusLine)
        view.addSubview(edgeDivider)
        // Horizontal edges + the full-height divider are position-independent; the
        // split↔statusLine vertical chain is swapped by `applyStatusPosition()`.
        NSLayoutConstraint.activate([
            split.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            split.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            statusLine.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            statusLine.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            edgeDivider.topAnchor.constraint(equalTo: view.topAnchor),
            edgeDivider.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            edgeDivider.leadingAnchor.constraint(equalTo: sidebarContainer.trailingAnchor),
            edgeDivider.widthAnchor.constraint(equalToConstant: 1),
        ])
        // Footer at the bottom (default): split fills down to the footer's top.
        statusBottomConstraints = [
            split.topAnchor.constraint(equalTo: view.topAnchor),
            split.bottomAnchor.constraint(equalTo: statusLine.topAnchor),
            statusLine.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ]
        // Footer at the top: footer pins to the top, split fills below it.
        statusTopConstraints = [
            statusLine.topAnchor.constraint(equalTo: view.topAnchor),
            split.topAnchor.constraint(equalTo: statusLine.bottomAnchor),
            split.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ]
        applyStatusPosition()

        updateEdgeDivider()

        applySidebarVisibility(SessionCoordinator.shared.settings.sidebarVisible, animated: false)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(snapshotChanged),
            name: NotificationBus.shared.snapshotChanged,
            object: nil
        )
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        guard context.window == nil, let window = view.window else { return }
        context.window = window
        NotificationCenter.default.addObserver(
            self, selector: #selector(windowDidBecomeKey), name: NSWindow.didBecomeKeyNotification, object: window
        )
    }

    /// The window in front is the daemon's active session, so actions and the CLI's notion of
    /// "here" follow what you're looking at. Never waits on the daemon (it may be remote).
    @objc private func windowDidBecomeKey() {
        WindowContexts.lastKey = context
        SessionCoordinator.shared.activate(owner: context.owner, selecting: context.sessionID)
    }

    /// A custom divider color is an overlaid hairline. With no custom color the
    /// split itself has no thickness, so nothing transparent sits between the
    /// sidebar and the terminal.
    private func updateEdgeDivider() {
        if let hex = SessionCoordinator.shared.settings.dividerHex, let color = NSColor.fromHex(hex) {
            edgeDivider.isHidden = false
            edgeDivider.layer?.backgroundColor = color.cgColor
        } else {
            edgeDivider.isHidden = true
        }
    }

    func applyChrome() {
        // Never `makeClear(view)` here: the root contentView must stay non-layer-backed
        // (see loadView) so the window stays rounded with no dark perimeter seam. It is
        // transparent already; there is nothing to repaint on it.
        if let sidebarContainer = split.subviews.first {
            // Keep this transparent — the sidebar view inside owns the chrome. This is a
            // child layer-backing island and does not affect the root's backing.
            HarnessDesign.makeClear(sidebarContainer)
        }
        updateEdgeDivider()
        sidebar.applyChromeColors()
        content.applyChrome()
        statusLine.applyChrome()
        // Tell the window controller to repaint the window bg with the (possibly new)
        // chrome color × opacity.  Called once, after all child views have adopted the
        // new palette, so the window compositor sees the final resolved colors in one pass.
        (view.window?.windowController as? MainWindowController)?.applyTransparency()
    }

    @objc private func snapshotChanged(_ note: Notification) {
        guard context.update() else {
            // This window's session closed (or moved into another window): close it.
            view.window?.close()
            return
        }
        let metadataOnly = note.userInfo?["metadataOnly"] as? Bool ?? false
        if note.userInfo?["chromeChanged"] as? Bool == true {
            // Cross-dissolve the chrome (theme switch) instead of a hard color pop.
            // Re-arming the flag per cascade means rapid successive switches just
            // restart the fade rather than queueing.
            ChromeBackdrop.crossfadeNextUpdate = true
            applyChrome()
            (view.window?.windowController as? MainWindowController)?.applyChrome()
            ChromeBackdrop.crossfadeNextUpdate = false
        }
        if metadataOnly {
            sidebar.refreshMetadata()
        } else {
            sidebar.reload()
        }
        content.snapshotChanged(
            structureChanged: note.userInfo?["structureChanged"] as? Bool ?? true,
            metadataOnly: metadataOnly
        )
        applyStatusPosition()
        updateWindowTitle()
    }

    /// Anchor the status footer to the bottom (default) or top per the daemon-owned
    /// `status-position` option, and tell the footer which way to stack its rows so the
    /// main line sits against the terminal. No-ops when the position is unchanged so a
    /// metadata snapshot doesn't thrash autolayout.
    private func applyStatusPosition() {
        let position = StatusPosition(option: HarnessOptions.shared.get("status-position", scope: .global)?.stringValue ?? "bottom")
        guard position != appliedStatusPosition else { return }
        appliedStatusPosition = position
        switch position {
        case .bottom:
            NSLayoutConstraint.deactivate(statusTopConstraints)
            NSLayoutConstraint.activate(statusBottomConstraints)
        case .top:
            NSLayoutConstraint.deactivate(statusBottomConstraints)
            NSLayoutConstraint.activate(statusTopConstraints)
        }
        statusLine.position = position
    }

    private func updateWindowTitle() {
        guard let session = context.session, let workspace = context.workspace else {
            view.window?.title = "Harness"
            return
        }
        let host = context.owner == DaemonSidebar.localID ? "" : " — \(context.owner)"
        view.window?.title = "\(SessionDisplayName.title(of: session, in: workspace))\(host) — Harness"
    }

    func setSidebarVisible(_ visible: Bool) {
        setSidebarVisible(visible, animated: false)
    }

    /// Collapse/expand the sidebar. `NSSplitView.setPosition` is not animatable via the
    /// animator proxy, so for a genuinely fluid slide we drive the divider ourselves
    /// with an eased per-frame stepper. A token cancels any in-flight animation.
    ///
    /// `allowFullCollapse` is set on the delegate for the whole move so the divider's
    /// min-coordinate drops to 0 (it's 200 at rest, so a *user drag* can't shrink the
    /// sidebar to an unusable sliver — but a programmatic collapse must reach 0).
    func setSidebarVisible(_ visible: Bool, animated: Bool) {
        if SessionCoordinator.shared.settings.sidebarVisible != visible {
            SessionCoordinator.shared.settings.sidebarVisible = visible
            SessionCoordinator.shared.saveSettings()
        }
        applySidebarVisibility(visible, animated: animated)
    }

    /// Resolve the divider against the final window size before AppKit can display it.
    /// Loading the controller alone can happen before the split has usable bounds.
    func prepareForPresentation() {
        view.layoutSubtreeIfNeeded()
        applySidebarVisibility(SessionCoordinator.shared.settings.sidebarVisible, animated: false)
        view.layoutSubtreeIfNeeded()
    }

    private func applySidebarVisibility(_ visible: Bool, animated: Bool) {
        // Sidebar mode lists tabs in the sidebar; title-bar mode shows the tab row.
        content.setTabRowHidden(visible)
        sidebarAnimation?.cancel()
        sidebarAnimation = nil
        let target = visible ? HarnessDesign.sidebarWidth : 0
        splitDelegate.allowFullCollapse = true

        guard animated, !DisplayAnimation.reducesMotion, view.window != nil, let panel = split.subviews.first else {
            let panel = split.subviews.first
            panel?.isHidden = false              // unhide so setPosition can size it to 0
            if split.bounds.width > 1 { split.setPosition(target, ofDividerAt: 0) }
            panel?.isHidden = !visible
            splitDelegate.allowFullCollapse = false
            edgeDivider.isHidden = !visible
            updateContentLeadingInset(visible: visible)
            return
        }

        // Unhide before the slide so the panel is visible as it shrinks/grows.
        panel.isHidden = false
        // Show/hide the inner hairline immediately so it never strands over the terminal.
        edgeDivider.isHidden = !visible
        let start = panel.frame.width
        guard abs(target - start) > 0.5 else {
            split.setPosition(target, ofDividerAt: 0)
            if !visible { panel.isHidden = true }
            splitDelegate.allowFullCollapse = false
            updateContentLeadingInset(visible: visible)
            return
        }
        let animation = DisplayAnimation(duration: HarnessDesign.Motion.standard, step: { [weak self] raw in
            self?.stepSidebar(from: start, to: target, progress: raw)
        }, completion: { [weak self] in
            guard let self else { return }
            if !visible { panel.isHidden = true }
            self.splitDelegate.allowFullCollapse = false   // restore the 200pt drag floor
            self.updateContentLeadingInset(visible: visible)
        })
        sidebarAnimation = animation
        animation.start(on: view)
    }

    private func stepSidebar(from start: CGFloat, to target: CGFloat, progress raw: Double) {
        // easeInOutQuad — smooth start and settle.
        let eased = raw < 0.5 ? 2 * raw * raw : 1 - pow(-2 * raw + 2, 2) / 2
        let width = start + (target - start) * CGFloat(eased)
        // Drive the divider inside a transaction with implicit actions OFF and lay
        // out synchronously each frame. Without this, the manual per-frame
        // setPosition lets the sidebar's vibrancy/glass backdrop animate its bounds
        // a frame behind the divider — it re-samples at the stale width and smears
        // into the banding seen mid-collapse. Disabling actions + an immediate
        // layout keeps the backdrop locked to the divider every step.
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        split.setPosition(width, ofDividerAt: 0)
        // Interpolate the tab-strip inset against the live sidebar width so it slides
        // in lockstep with the divider rather than snapping at the end.
        setContentLeadingInset(forSidebarWidth: width)
        split.layoutSubtreeIfNeeded()
        CATransaction.commit()
    }

    /// Leading inset the title strip's path readout needs to clear the macOS traffic lights
    /// when the sidebar is fully collapsed (content shifts to x=0 under `.fullSizeContentView`).
    /// The tab bar itself sits below the lights and never needs one.
    private let trafficLightInset = HarnessDesign.trafficLightClearance

    /// Inset the strip readout proportionally to how collapsed the sidebar is: full inset
    /// at width 0, none once the sidebar is wide enough to cover the traffic lights.
    private func setContentLeadingInset(forSidebarWidth width: CGFloat) {
        let t = max(0, min(1, 1 - width / trafficLightInset))
        content.setTabBarLeadingInset(trafficLightInset * t)
    }

    private func updateContentLeadingInset(visible: Bool) {
        content.setTabBarLeadingInset(visible ? 0 : trafficLightInset)
    }

    func toggleSidebar() {
        setSidebarVisible(!SessionCoordinator.shared.settings.sidebarVisible, animated: true)
    }

}

/// Sidebar and terminal meet with no reserved divider strip. A 1pt gap on a
/// translucent window showed the desktop between them.
@MainActor
private final class SidebarSplitView: NSSplitView {
    override var dividerThickness: CGFloat { 0 }
    override var dividerColor: NSColor { .clear }
}

@MainActor
private final class SplitChromeDelegate: NSObject, NSSplitViewDelegate {
    static let minimumWidth: CGFloat = 200
    /// While a programmatic collapse/expand is running, let the divider reach 0 so the
    /// sidebar can fully disappear. At rest it's false, so a *user drag* still floors
    /// at 200pt and can't shrink the sidebar to an unusable sliver.
    var allowFullCollapse = false

    // Preserve the sidebar's chosen width as AppKit lays out or resizes the window.
    // Only the terminal absorbs width changes; proportional adjustment otherwise
    // changes the divider again during first presentation on macOS 26.
    func splitView(_ splitView: NSSplitView, shouldAdjustSizeOfSubview view: NSView) -> Bool {
        view !== splitView.subviews.first
    }

    func splitView(_ splitView: NSSplitView, constrainMinCoordinate proposedMinimum: CGFloat, ofSubviewAt index: Int) -> CGFloat {
        guard index == 0 else { return proposedMinimum }
        return allowFullCollapse ? 0 : Self.minimumWidth
    }

    func splitView(_ splitView: NSSplitView, constrainMaxCoordinate proposedMaximum: CGFloat, ofSubviewAt index: Int) -> CGFloat {
        index == 0 ? 320 : proposedMaximum
    }

    func splitView(_ splitView: NSSplitView, effectiveRect proposedEffectiveRect: NSRect, forDrawnRect drawnRect: NSRect, ofDividerAt dividerIndex: Int) -> NSRect {
        var rect = proposedEffectiveRect
        rect.size.width = 4
        return rect
    }
}
