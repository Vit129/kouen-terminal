import AppKit
import AVFoundation
import Foundation
import Network
import HarnessCore
import HarnessTerminalEngine
import HarnessTerminalKit
import HarnessTheme
import UserNotifications

@MainActor
final class SessionCoordinator: NSObject {
    static let shared = SessionCoordinator()

    let daemon = DaemonSessionService()
    // Until hydration there are no real sessions to mount. A default Workspace would
    // invent a pane, start an attach for it, then discard it when the daemon answers.
    var snapshot = SessionSnapshot(workspaces: [])
    var lastRevision = -1
    let terminalHosts = TerminalPaneRegistry()
    var previewHosts: [String: PreviewPaneView] = [:]
    /// Event-driven branch labels: watches each repository's `HEAD` and pushes
    /// `updateTabGitBranch` only on real change (replaced the 2 s git-subprocess poll).
    let gitBranchMonitor = GitBranchMonitor()
    /// Long-lived push channel: the daemon sends every committed revision, the handler
    /// syncs when it differs from `lastRevision`. This is how external structure changes
    /// (`harness-cli split-pane` against a GUI session) reach the app now that the
    /// 2 s metadata poll is gone.
    var snapshotSubscription: DaemonSubscription?
    /// Invalidates stale subscription callbacks: bumped on every (re)subscribe, checked by
    /// the previous subscription's `onEnd` (its `cancel()` fires `onEnd` too — without the
    /// guard, replacing a subscription would schedule a duplicate resubscribe).
    var snapshotSubscriptionGeneration = 0
    var snapshotResubscribeDelay: TimeInterval = 1
    /// Push-loss insurance, not the mechanism: the daemon drops subscribers whose write
    /// backlog exceeds its cap, and a dropped fd silently stops pushes. Runs only while
    /// the app is active.
    var safetyPollTimer: Timer?
    var settings = HarnessSettings.load()
    /// Hot-reload watchers for `settings.json` / `keybindings.json` (reload on save).
    /// Held for the coordinator's lifetime.
    private var configWatchers: [FileWatcher] = []
    /// Which daemon the GUI currently drives: the local one, or a remote daemon over an SSH tunnel.
    /// New terminal panes are bound to this endpoint, and `daemon` (session/layout IPC) tracks it.
    private var hookPolicyWindow: HookPolicyWindowController?
    func presentHookPolicy() {
        guard activeOwner == DaemonSidebar.localID else { DisplayMessage.show("Policy trust and installation are local to the recorded host."); return }
        if let hookPolicyWindow { hookPolicyWindow.showWindow(nil); return }
        let controller = HookPolicyWindowController(endpoint: activeEndpoint)
        hookPolicyWindow = controller; controller.onClose = { [weak self] in self?.hookPolicyWindow = nil }; controller.showWindow(nil)
    }
    private var schedulesWindow: ScheduleWindowController?
    private var historyPrivacyWindow: HistoryPrivacyWindowController?
    func presentHistoryPrivacy() {
        if let historyPrivacyWindow { historyPrivacyWindow.showWindow(nil); return }
        let leaf = activeSurfaceID.flatMap { id in snapshot.workspaces.flatMap(\.sessions).flatMap(\.tabs).flatMap({ $0.rootPane.allLeaves() }).first(where: { $0.surfaceID == id && $0.paneContent.isTerminal }) }
        let controller = HistoryPrivacyWindowController(endpoint: activeEndpoint, pane: leaf, owner: activeOwner)
        historyPrivacyWindow = controller; controller.onClose = { [weak self] in self?.historyPrivacyWindow = nil }; controller.showWindow(nil)
    }
    private var aiSummaryWindow: AISummaryWindowController?
    func presentAISummaries() {
        guard activeOwner == DaemonSidebar.localID else { DisplayMessage.show("Configure and generate summaries locally on the recorded host."); return }
        if let aiSummaryWindow { aiSummaryWindow.showWindow(nil); return }
        let controller = AISummaryWindowController(endpoint: activeEndpoint, workspaceID: snapshot.activeWorkspaceID)
        aiSummaryWindow = controller; controller.onClose = { [weak self] in self?.aiSummaryWindow = nil }; controller.showWindow(nil)
    }
    func presentSchedules() {
        guard activeOwner == DaemonSidebar.localID else { DisplayMessage.show("Configure schedules locally on their recorded host."); return }
        if let schedulesWindow { schedulesWindow.showWindow(nil); return }
        let controller = ScheduleWindowController(endpoint: activeEndpoint, workspaceID: snapshot.activeWorkspaceID, directory: activeTabCWD ?? settings.defaultCWD)
        schedulesWindow = controller; controller.onClose = { [weak self] in self?.schedulesWindow = nil }; controller.showWindow(nil)
    }
    private var tmuxImportWindow: TmuxImportWindowController?
    func presentTmuxImport() {
        if let tmuxImportWindow { tmuxImportWindow.showWindow(nil); return }
        let controller = TmuxImportWindowController(owner: activeOwner, localCapture: activeOwner == DaemonSidebar.localID)
        tmuxImportWindow = controller; controller.onClose = { [weak self] in self?.tmuxImportWindow = nil }; controller.showWindow(nil)
    }
    private var recordingWindow: RecordingReviewWindowController?
    func presentRecordings() {
        if let recordingWindow { recordingWindow.showWindow(nil); return }
        let leaf = activeSurfaceID.flatMap { id in snapshot.workspaces.flatMap(\.sessions).flatMap(\.tabs).flatMap({ $0.rootPane.allLeaves() }).first(where: { $0.surfaceID == id }) }
        let controller = RecordingReviewWindowController(endpoint: activeEndpoint, surfaceID: leaf?.paneContent.isTerminal == true ? leaf?.surfaceID : nil, owner: activeOwner)
        recordingWindow = controller; controller.onClose = { [weak self] in self?.recordingWindow = nil }; controller.showWindow(nil)
    }
    private var fanoutWindow: FanoutWindowController?
    func presentFanout() {
        if let fanoutWindow { fanoutWindow.showWindow(nil); return }
        let controller = FanoutWindowController(endpoint: activeEndpoint, directory: activeTabCWD ?? settings.defaultCWD, owner: activeOwner)
        fanoutWindow = controller; controller.onClose = { [weak self] in self?.fanoutWindow = nil }; controller.showWindow(nil)
    }
    private var managedWorktreesWindow: ManagedWorktreesWindowController?
    func presentManagedWorktrees() {
        if let managedWorktreesWindow { managedWorktreesWindow.showWindow(nil); return }
        let controller = ManagedWorktreesWindowController(endpoint: activeEndpoint, directory: activeTabCWD ?? settings.defaultCWD, host: activeOwner)
        managedWorktreesWindow = controller
        controller.onClose = { [weak self] in self?.managedWorktreesWindow = nil }
        controller.showWindow(nil)
    }
    var activeEndpoint: Endpoint = .localControlSocket
    var activeSurfaceID: SurfaceID?
    /// Most-recently-active pane within the current tab, for `select-pane -l`
    /// (last-pane). Updated only on genuine intra-tab pane switches.
    var lastActiveSurfaceID: SurfaceID?
    /// Set while reflecting the daemon's `activePaneID` into local focus, so the
    /// `setActiveSurface` push doesn't echo back to the daemon (feedback loop).
    var suppressActivePaneSync = false
    /// The marked pane (`select-pane -m`) — implicit source for `join-pane`.
    var markedSurfaceID: SurfaceID?
    /// Last finished command's duration per pane (OSC 133 C→D, via the host delegate) — feeds
    /// `#{command_duration}`. GUI vantage only; entries die with the process (never persisted).
    var lastCommandDurations: [SurfaceID: TimeInterval] = [:]
    /// Tabs with `synchronize-panes` on — input typed in any pane mirrors to all.
    var synchronizedTabIDs: Set<TabID> = []
    var structureRevision = 0

    /// The active tab's live working directory (kept current by host metadata),
    /// used as the default for new tabs/sessions so they open where the user is
    /// working — matching Terminal.app / iTerm. `nil` when unknown.
    var activeTabCWD: String? {
        // `window-inherit-cwd` (default on): off pins new tabs/sessions to `defaultCWD`
        // by making the inherited value resolve to nil at every consumer.
        guard settings.windowInheritCWD,
              let cwd = snapshot.activeWorkspace?.activeTab?.cwd, !cwd.isEmpty else { return nil }
        return cwd
    }

    enum ActiveTabCloseDisposition {
        case tab
        case session
        case workspace
        case window
    }

    struct CloseConfirmationCopy {
        var message: String
        var informative: String
        var button: String
    }

    private override init() {
        super.init()
        // Deliberately do NOT hydrate from the daemon here. This singleton is first
        // touched while building the window (before `showWindow`), and `syncFromDaemon`
        // is a blocking daemon IPC — doing it here freezes first paint on a cold/slow
        // daemon. We start from an empty `snapshot` + already-loaded local `settings`
        // (chrome resolves correctly from `settings.custom*Hex`), and the async
        // `DaemonLauncher.ensureRunning` callback in AppDelegate performs the first
        // hydration the moment the daemon answers — after the window is on screen.
        observeNotifications()
        configureGitBranchMonitor()
        observeAppActivation()
        startSafetyPoll()
        startConfigWatchers()
        observeRemoteConnectivity()
    }

    /// Watch the on-disk config so an external edit (a text editor, `harness-cli set-option`, a
    /// dotfile sync) applies live when the file changes. The `fresh != settings` guard
    /// makes the app's OWN saves a no-op: it already updated the in-memory `settings` before writing,
    /// so the reload loads identical values and does nothing. `FileWatcher` delivers on the main
    /// queue, so `assumeIsolated` is safe (and hop-free) for this @MainActor coordinator.
    private func startConfigWatchers() {
        let settingsWatcher = FileWatcher(url: HarnessPaths.settingsURL) { [weak self] in
            MainActor.assumeIsolated {
                guard let self else { return }
                let fresh: HarnessSettings
                do { fresh = try HarnessSettings.reload() }
                catch {
                    DisplayMessage.show("Could not reload settings.json. Your working settings are unchanged. Fix the file and save again.")
                    fputs("Harness: settings reload failed — \(error)\n", harnessStderr)
                    return
                }
                guard fresh != self.settings else { return }
                self.settings = fresh
                self.applySettingsToHosts()
                // Palette shortcuts live in settings.json too (`harness-cli keymap` already reads them).
                PaletteShortcuts.shared.reload()
                // An external toggle of `secureKeyboardEntry` must re-sync the process-global
                // secure-input lock, exactly as `setSecureKeyboardEntry` does — otherwise the
                // lock can stay held after the setting is turned off via an editor / harness-cli.
                SecureKeyboardEntry.shared.settingChanged()
            }
        }
        let keybindingsWatcher = FileWatcher(url: KeybindingsStore.fileURL) { [weak self] in
            MainActor.assumeIsolated {
                guard self != nil else { return }
                KeybindingsService.shared.reload()
            }
        }
        configWatchers = [settingsWatcher, keybindingsWatcher]
    }

    private func observeNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(snapshotChangedNotification(_:)),
            name: NotificationBus.shared.snapshotChanged,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(notificationPosted(_:)),
            name: NotificationBus.shared.notificationPosted,
            object: nil
        )
    }

    @objc private func snapshotChangedNotification(_ note: Notification) {
        let revision = note.userInfo?["revision"] as? Int ?? -1
        guard revision != lastRevision else { return }
        refreshSnapshot()
    }

    @objc private func notificationPosted(_ note: Notification) {
        guard note.userInfo?["notification"] is AgentNotification else { return }
        NotificationCenter.default.post(name: NotificationBus.shared.tabStatusChanged, object: nil)
    }

    /// Hydrate from the daemon's snapshot. Returns whether the fetch succeeded so launch-time callers
    /// can gate work (e.g. draining queued external opens) on a real hydration rather than guessing.
    // MARK: - Per-host/per-command profiles

    /// Last OSC 7-reported hostname per surface (nil entries are removed — "no host known").
    var surfaceRemoteHosts: [SurfaceID: String] = [:]

    func terminalHostDidChangeRemoteHost(_ host: String?, surfaceID: SurfaceID) {
        if let host {
            surfaceRemoteHosts[surfaceID] = host
        } else {
            surfaceRemoteHosts.removeValue(forKey: surfaceID)
        }
        applyProfileOverride(for: surfaceID)
    }

    /// Re-evaluate the profile match for one surface and push (or clear) its canvas theme
    /// override. First matching rule wins; no match reverts to the global theme.
    private func applyProfileOverride(for surfaceID: SurfaceID) {
        guard let host = terminalHostIfExists(for: surfaceID) else { return }
        let profiles = settings.profiles
        guard !profiles.isEmpty else {
            host.profileThemeOverride = nil
            return
        }
        let remoteHost = surfaceRemoteHosts[surfaceID]
        let command = owningTab(forSurface: surfaceID)?.currentCommand
        host.profileThemeOverride = profiles
            .first { $0.matches(host: remoteHost, command: command, surface: surfaceID.uuidString) }?
            .theme
    }

    func applyProfileOverridesToAllHosts() {
        // With no profiles configured, still clear any leftovers (rules were just deleted).
        for workspace in snapshot.workspaces {
            for session in workspace.sessions {
                for tab in session.tabs {
                    for surfaceID in tab.rootPane.allSurfaceIDs() {
                        applyProfileOverride(for: surfaceID)
                    }
                }
            }
        }
    }

    /// The tab whose split tree carries `surfaceID`, for per-pane profile context.
    private func owningTab(forSurface surfaceID: SurfaceID) -> Tab? {
        for workspace in snapshot.workspaces {
            for session in workspace.sessions {
                for tab in session.tabs where tab.rootPane.allSurfaceIDs().contains(surfaceID) {
                    return tab
                }
            }
        }
        return nil
    }

    private func refreshChromePalette(systemAppearance: HarnessSystemAppearance? = nil) {
        HarnessChrome.update(
            themeName: snapshot.themeName,
            opacity: CGFloat(settings.backgroundOpacity),
            blur: settings.backgroundBlur,
            appearanceMode: settings.appearanceMode,
            systemAppearance: systemAppearance,
            systemLightThemeName: settings.systemLightThemeName,
            systemDarkThemeName: settings.systemDarkThemeName,
            backgroundHex: settings.customBackgroundHex,
            foregroundHex: settings.customForegroundHex,
            cursorHex: settings.customCursorHex,
            accessibility: .system
        )
    }

    @discardableResult
    func refreshChromeForEffectiveAppearanceChange(systemAppearance: HarnessSystemAppearance? = nil) -> Bool {
        guard HarnessEffectiveAppearanceRefreshPolicy.shouldRefreshOnEffectiveAppearanceChange(
            appearanceMode: settings.appearanceMode
        ) else {
            return false
        }
        // The flip must re-skin the TERMINAL CANVAS, not just the window chrome: route
        // through the same full host re-apply the settings path uses (theme + appearance
        // + borders per host), or the canvas keeps rendering the pre-flip palette until
        // an unrelated settings change forces a reapply.
        updateChromeAndHosts(systemAppearance: systemAppearance)
        NotificationCenter.default.post(
            name: NotificationBus.shared.snapshotChanged,
            object: nil,
            userInfo: [
                "revision": snapshot.revision,
                "structureChanged": false,
                "chromeChanged": true,
                "metadataOnly": true,
            ]
        )
        return true
    }

    /// Push the current `terminal-identity` option to a host so its XTVERSION / secondary-DA
    /// replies match the `TERM_PROGRAM` the daemon exports (single source: `options.json`).
    private func applyTerminalIdentity(to host: TerminalHostView) {
        let spec = TerminalIdentity.spec(forOption: HarnessOptions.shared.get(TerminalIdentity.optionKey)?.stringValue)
        host.setTerminalIdentity(name: spec.name, version: spec.version, daVersion: spec.daVersion)
    }

    /// Push the theme's focus-ring / waiting colors into a host (the terminal package
    /// can't reach the app palette, so the app owns these indicator colors).
    private func pushBorderColors(to host: TerminalHostView) {
        let chrome = HarnessChrome.current
        host.applyBorderColors(
            active: chrome.focusRing,
            waiting: chrome.waiting
        )
    }

    // syncWaitingRings() was removed: the function iterated all hosts × all tabs with a
    // completely empty `if let match` body — it found the owning tab for each host but then
    // did nothing with it.  Searching the codebase for "waiting ring", "waitingRing", and
    // "ring" found no TerminalHostView API to call (the border colours are pushed once via
    // pushBorderColors; there is no per-tab waiting-ring toggle on the host).  The only live
    // call site was in syncFromDaemon, which is updated below to remove the call.  If a
    // per-host waiting indicator is needed in the future, add an `applyWaiting(_:)` API to
    // TerminalHostView and re-introduce the loop at that point.

    var notificationOwners: [String: Bool] = [:]
    let notificationSpeech = AVSpeechSynthesizer()
    private var attentionAlerts: [String: PaneAttentionAlerts] = [:]

    func pushAgentNotifications() {
        let items = attentionList()
        for owner in connectedOwners where !disconnectedHosts.contains(owner) {
            var tracker = attentionAlerts[owner] ?? PaneAttentionAlerts()
            let alerts = tracker.alerts(for: items.filter { $0.owner == owner }.map(\.entry))
            attentionAlerts[owner] = tracker
            for alert in alerts where notificationOwners[owner] != true {
                if NSApp.isActive, owner == activeOwner, alert.entry.surfaceID == activeSurfaceID { continue }
                let name = alert.entry.activity.mark?.app ?? alert.entry.activity.agent?.kind.displayName ?? "Harness"
                deliverAgentAlert(event: alert.event, title: "\(name) · \(alert.entry.tabTitle)", body: alert.message, owner: owner, surfaceID: alert.entry.surfaceID)
            }
        }
        attentionAlerts = attentionAlerts.filter { connectedOwners.contains($0.key) }
        announceAttentionChanges(in: connectedOwners.flatMap { snapshot(for: $0).workspaces })
    }

    /// Each tab's mark at the last snapshot, so VoiceOver hears when one starts needing you.
    private var announcedActivity: [TabID: TabActivity] = [:]
    private var lastAnnouncement = Date.distantPast

    /// VoiceOver: say when a tab comes to need you, fails, or finishes ("drifting cedar ›
    /// claude: needs you"). One announcement covers several tabs changing at once, and they're
    /// spaced at least two seconds apart so a busy session can't talk over everything.
    private func announceAttentionChanges(in workspaces: [Workspace]) {
        var changed: [String] = []
        var current: [TabID: TabActivity] = [:]
        for workspace in workspaces {
            for session in workspace.sessions {
                for tab in session.tabs {
                    let activity = TabActivity.of(tab)
                    current[tab.id] = activity
                    guard activity != announcedActivity[tab.id], activity == .blocked || activity == .error || activity == .done,
                          announcedActivity[tab.id] != nil, let state = TabStatusView.label(activity)
                    else { continue }
                    let name = SurfaceIdentity.label(directory: tab.cwd, program: tab.currentCommand, agent: tab.agent?.kind.commandToken)
                    changed.append("\(SessionDisplayName.title(of: session, in: workspace)) › \(name): \(state)")
                }
            }
        }
        announcedActivity = current
        guard !changed.isEmpty, NSWorkspace.shared.isVoiceOverEnabled, Date().timeIntervalSince(lastAnnouncement) >= 2 else { return }
        lastAnnouncement = Date()
        NSAccessibility.post(
            element: NSApp.mainWindow ?? NSApp as Any,
            notification: .announcementRequested,
            userInfo: [.announcement: changed.prefix(3).joined(separator: ". "), .priority: NSAccessibilityPriorityLevel.high.rawValue]
        )
    }

    /// Single delivery point for agent alerts. First gates on the per-event "which events
    /// notify me" choice (`isEventEnabled`); then honors the two delivery toggles:
    /// `systemNotificationsEnabled` (push banner) and `notificationSoundEnabled` (chime).
    /// Banner-on carries the sound; banner-off-but-chime-on still plays an in-app chime,
    /// so an enabled event is audible even when banners are suppressed.
    func deliverAgentAlert(event: NotificationEvent, title: String, body: String, owner: String? = nil, surfaceID: SurfaceID? = nil) {
        guard settings.isEventEnabled(event) else { return }
        let wantBanner = settings.systemNotificationsEnabled
        let wantChime = settings.notificationSoundEnabled
        guard wantBanner || wantChime else { return }
        if wantBanner {
            DesktopNotifier.show(title: title, body: body, withSound: wantChime, owner: owner, surfaceID: surfaceID?.uuidString)
        } else if wantChime {
            NSSound(named: "Glass")?.play()
        }
    }

    func updateDockBadge(from snapshot: SessionSnapshot) {
        DockTileRenderer.shared.update(from: snapshot)
    }

    func saveImmediately() {
        refreshSnapshot()
    }

    /// Switch appearance and repaint. Light uses the configured light theme even when the
    /// Mac is dark. Stored opacity and blur stay put.
    func setAppearanceMode(_ mode: HarnessAppearanceMode) {
        guard settings.appearanceMode != mode else { return }
        settings.appearanceMode = mode
        settings.clearThemeColorOverrides()
        if mode == .light || mode == .macOSSystem {
            if settings.systemLightThemeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                settings.systemLightThemeName = ThemeManager.defaultSystemLightThemeName
            }
            if settings.systemDarkThemeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                settings.systemDarkThemeName = ThemeManager.defaultSystemDarkThemeName
            }
        }
        saveSettings()
        applySettingsToHosts()
    }

    /// Push the current `settings` to every live terminal host and refresh chrome.
    func applySettingsToHosts() {
        updateChromeAndHosts()
        // applySettingsToHosts does NOT call adoptSynchronizeOptions / refreshSyncSiblings /
        // reassertMarkedPane because it runs on pure settings changes (font, opacity, colours)
        // that cannot affect the synchronize-panes or marked-pane state.  A post below notifies
        // chrome consumers (window, sidebar, status line) so they repaint with the new palette.
        NotificationCenter.default.post(
            name: NotificationBus.shared.snapshotChanged,
            object: nil,
            userInfo: [
                "revision": snapshot.revision,
                "structureChanged": false,
                "chromeChanged": true,
            ]
        )
    }

    /// Shared per-host update loop: refresh the global chrome palette and push the current
    /// theme + settings + identity + border colours to every live terminal host.
    /// Called by both `applyThemeToAllHosts` and `applySettingsToHosts`; each caller adds
    /// its own divergent extras after this returns. Chrome goes through the appearance-aware
    /// `refreshChromePalette()` so `.macOSSystem` resolution applies on every path.
    func updateChromeAndHosts(systemAppearance: HarnessSystemAppearance? = nil) {
        refreshChromePalette(systemAppearance: systemAppearance)
        QuickTerminalController.shared.applyTransparency()
        let allowClipboard = HarnessOptions.shared.get("set-clipboard")?.boolValue ?? true
        let allowClipboardRead = HarnessOptions.shared.get("allow-clipboard-read")?.boolValue ?? false
        for host in terminalHosts.allHosts() {
            host.applyTheme(named: snapshot.themeName)
            host.applySettings(settings)
            host.allowProgramClipboardAccess = allowClipboard
            host.allowProgramClipboardRead = allowClipboardRead
            applyTerminalIdentity(to: host)
            pushBorderColors(to: host)
        }
    }

    /// The live `FormatString` context for the active workspace/session/tab/pane.
    /// Shared by the status line and `display-message` so both render the same tokens.
    func currentFormatContext() -> FormatContext {
        let workspace = snapshot.activeWorkspace
        let session = workspace?.activeSession
        let tab = workspace?.activeTab
        var context = FormatContext(
            paneID: activeSurfaceID?.uuidString,
            paneTitle: tab?.title,
            paneCwd: tab?.cwd,
            paneActive: activeSurfaceID != nil,
            paneIndex: nil,
            sessionName: session?.name.isEmpty == false ? session?.name : nil,
            tabName: tab?.title,
            tabIndex: session?.tabs.firstIndex(where: { $0.id == tab?.id }),
            workspaceName: workspace?.name,
            agentKind: tab?.agent?.kind.rawValue,
            agentActivity: tab?.agent?.activity.rawValue,
            gitBranch: tab?.gitBranch,
            clientName: "Harness.app"
        )
        // Extended tmux-parity fields derivable from the snapshot (PTY-backed values —
        // pane_pid, pane_width, history_bytes — are daemon vantage; left nil here).
        context.paneCurrentCommand = tab?.currentCommand
        context.paneDead = tab.map { $0.exitStatus != nil }
        context.paneExitStatus = tab?.exitStatus
        context.sessionID = session?.id.uuidString
        context.windowID = tab?.id.uuidString
        context.sessionWindows = session?.tabs.count
        context.windowPanes = tab?.rootPane.allPaneIDs().count
        if let tab, let session { context.windowActive = tab.id == session.activeTabID }
        context.sessionGroup = session.flatMap { snapshot.groupName(of: $0) }
        // Same expression as the daemon's builder so `#{window_flags}` agrees between
        // GUI display-message and CLI/hook output.
        context.windowFlags = tab.map { ($0.zoomedPaneID != nil ? "Z" : "") + $0.alertFlags }
        // GUI vantage: OSC 133 command timing arrives via the host delegate, not the snapshot.
        context.commandDurationSeconds = activeSurfaceID.flatMap { lastCommandDurations[$0] }
        return context
    }

    /// Apply a theme. By default this seeds the full editable color set from the
    /// theme preset (overwriting prior color edits) so the whole canvas — terminal
    /// and chrome — adopts the theme. Pass `seedColors: false` for programmatic /
    /// restore paths that must preserve already-resolved colors (e.g. a fresh
    /// config re-import, where the imported config colors must win).
    func setTheme(_ name: String, seedColors: Bool = true) {
        if seedColors {
            settings.clearThemeColorOverrides()
            saveSettings()
        }
        let unchanged = snapshot.themeName == name
        requestDaemonAsync(.setTheme(name: name))
        refreshSnapshot()
        // Re-picking the current theme resets its colors: the sync alone doesn't re-skin.
        if unchanged { applySettingsToHosts() }
    }

    /// Apply an imported `.harnesstheme` document. Custom themes aren't in the static catalog,
    /// so the colors are seeded straight from the document (not resolved by name like `setTheme`).
    /// Any appearance knobs the document carries (opacity/blur/font/padding/terminal-output sync)
    /// are applied too; absent keys leave the current setting untouched. `themeName` is set on the
    /// daemon so the canvas + chrome adopt the imported name.
    func applyImportedTheme(_ document: ThemeDocument) throws {
        var proposed = settings
        let colors = document.colors
        proposed.customBackgroundHex = colors.background.hexString
        proposed.customForegroundHex = colors.foreground.hexString
        proposed.customCursorHex = colors.cursor?.hexString
        proposed.cursorTextHex = colors.cursorText?.hexString
        proposed.selectionBackgroundHex = colors.selectionBackground?.hexString
        proposed.selectionForegroundHex = colors.selectionForeground?.hexString
        proposed.boldColorHex = colors.bold?.hexString
        proposed.paletteHex = HarnessSettings.normalizedPalette(colors.palette.map { $0.hexString })
        // Chrome accents re-derive from the imported colors unless re-set by the user.
        proposed.dividerHex = nil
        proposed.statusLineHex = nil
        if let appearance = document.appearance {
            if let opacity = appearance.backgroundOpacity {
                proposed.backgroundOpacity = HarnessSettings.clampedOpacity(Float(opacity))
            }
            if let blur = appearance.backgroundBlur {
                proposed.backgroundBlur = HarnessSettings.clampedBlur(blur)
            }
            if let family = appearance.fontFamily, !family.isEmpty {
                proposed.fontFamily = family
            }
            if let size = appearance.fontSize {
                proposed.fontSize = HarnessSettings.clampedFontSize(Float(size))
            }
            if let px = appearance.windowPaddingX {
                proposed.windowPaddingX = HarnessSettings.clampedPadding(Float(px))
            }
            if let py = appearance.windowPaddingY {
                proposed.windowPaddingY = HarnessSettings.clampedPadding(Float(py))
            }
            if let applyToOutput = appearance.applyToTerminalOutput {
                proposed.applyThemeToTerminalOutput = applyToOutput
            }
        }
        try proposed.save(backup: true)
        settings = proposed
        requestDaemonAsync(.setTheme(name: document.name))
        refreshSnapshot()
        // The document may carry new colors under the theme name already in use.
        applySettingsToHosts()
    }

    func beginRenameActiveTab() {
        guard let tab = snapshot.activeWorkspace?.activeTab else { return }
        let alert = NSAlert()
        alert.messageText = "Rename Tab"
        alert.addButton(withTitle: "Rename")
        alert.addButton(withTitle: "Cancel")
        let field = NSTextField(string: tab.title)
        field.frame = NSRect(x: 0, y: 0, width: 280, height: 24)
        field.placeholderString = "Tab name"
        alert.accessoryView = field
        alert.window.initialFirstResponder = field
        let tabID = tab.id
        let apply: (NSApplication.ModalResponse) -> Void = { [weak self] response in
            let name = field.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            guard response == .alertFirstButtonReturn, !name.isEmpty, let self else { return }
            self.requestDaemonAsync(.renameTab(tabID: tabID, name: name))
            refreshSnapshot()
        }
        if let window = NSApp.keyWindow ?? NSApp.mainWindow {
            alert.beginSheetModal(for: window, completionHandler: apply)
        } else {
            apply(alert.runModal())
        }
    }

    func reimportTerminalConfig() {
        SettingsImportController.present()
    }

    func applyImportedSettings(_ imported: HarnessSettings, persist: Bool = true) throws {
        if persist { try imported.save(backup: true) }
        settings = imported
        PaletteShortcuts.shared.reload()
        applySettingsToHosts()
        NotificationCenter.default.post(name: NotificationBus.shared.snapshotChanged, object: self)
    }

    func closeActiveWorkspace() {
        guard let id = snapshot.activeWorkspaceID, snapshot.workspaces.count > 1 else { return }
        closeWorkspace(id: id)
    }

    func closeWorkspace(id: WorkspaceID) {
        guard snapshot.workspaces.count > 1 else { return }
        guard snapshot.workspaces.contains(where: { $0.id == id }) else { return }
        requestDaemonAsync(.closeWorkspace(id: id))
        refreshSnapshot()
    }

    func previewHost(for leaf: PaneLeaf, owner: String) -> PreviewPaneView {
        let key = owner + ":" + leaf.surfaceID.uuidString
        if let existing = previewHosts[key] {
            if case let .preview(value) = leaf.paneContent { existing.update(value) }
            return existing
        }
        let host = PreviewPaneView(surfaceID: leaf.surfaceID, hostOwner: owner)
        host.onEdit = { [weak self] value in
            guard let self, let endpoint = self.endpoint(forOwner: owner) else { return }
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let response = (try? DaemonClient(endpoint: endpoint).request(.previewPane(surfaceID: leaf.surfaceID.uuidString, specification: value, updateExisting: true, capabilities: [DaemonStats.paneContent]))) ?? .error("The preview host is unavailable.")
                DispatchQueue.main.async { [weak self] in
                    if case let .error(message) = response { DisplayMessage.show(message) }
                    self?.refreshSnapshot()
                }
            }
        }
        previewHosts[key] = host
        if case let .preview(value) = leaf.paneContent { host.update(value) }
        return host
    }
    func focusPaneContent(_ surfaceID: SurfaceID) {
        if let host = previewHosts[activeOwner + ":" + surfaceID.uuidString] { host.focusContent() }
        else { terminalHosts.host(for: surfaceID)?.focusTerminal() }
    }
    func presentPreview() {
        guard let surface = activeSurfaceID else { DisplayMessage.show("Select a pane before opening a preview."); return }
        let alert = NSAlert(); alert.messageText = "Open preview beside this pane"
        alert.informativeText = "Enter a loopback URL on \(activeOwner). Remote previews use a private SSH forward."
        let input = HarnessTextField(); input.frame = NSRect(x: 0, y: 0, width: 420, height: HarnessDesign.formControlHeight); input.stringValue = "http://localhost:3000"; input.setAccessibilityLabel("Preview URL")
        alert.accessoryView = input; alert.addButton(withTitle: "Open preview"); alert.addButton(withTitle: "Cancel")
        guard HarnessToolPage.runModal(alert) == .alertFirstButtonReturn else { return }
        let value = PreviewSpecification(url: input.stringValue)
        do { _ = try value.validatedURL() } catch { DisplayMessage.show(error.localizedDescription); return }
        requestDaemonAsync(.previewPane(surfaceID: surface.uuidString, specification: value, updateExisting: false, capabilities: [DaemonStats.paneContent]))
    }

    func terminalHostIfExists(for surfaceID: SurfaceID) -> TerminalHostView? {
        terminalHosts.host(for: surfaceID)
    }

    func terminalHost(for surfaceID: SurfaceID, cwd: String) -> TerminalHostView {
        if let existing = terminalHosts.host(for: surfaceID) {
            return existing
        }
        let host = TerminalHostView(
            surfaceID: surfaceID,
            workingDirectory: cwd,
            harnessSurfaceEnv: surfaceID.uuidString,
            settings: settings,
            themeName: snapshot.themeName,
            endpoint: endpoint(forSurface: surfaceID),
            requiresSessionLayout: connectedOwners.contains { Self.surfaces(in: snapshot(for: $0)).contains(surfaceID) }
        )
        host.hostDelegate = self
        host.applyTheme(named: snapshot.themeName)
        host.applySettings(settings)
        applyTerminalIdentity(to: host)
        pushBorderColors(to: host)
        // Hover × (#168): same kill-pane path as `prefix x`. The affordance itself is armed
        // per mount (multi-pane tabs only) by ContentAreaViewController.
        host.onPaneCloseRequested = { [weak self] in self?.killPane(surfaceID: surfaceID) }
        terminalHosts.register(host)
        return host
    }

    /// Kill the pane hosting `surfaceID` — the hover-close affordance's target is the pane
    /// under the pointer, not necessarily the active one, and (multi-window) not necessarily
    /// in the active tab. Routes the same daemon command as `kill-pane`.
    func killPane(surfaceID: SurfaceID) {
        for workspace in snapshot.workspaces {
            for session in workspace.sessions {
                for tab in session.tabs {
                    guard let paneID = paneID(for: surfaceID, in: tab.rootPane) else { continue }
                    requestDaemonAsync(.killPane(paneID: paneID))
                    refreshSnapshot()
                    return
                }
            }
        }
    }

    func jumpToLatestNotification() {
        guard let item = attentionList().first(where: { $0.connected && $0.entry.activity.rank.needsYou }) else { return }
        openAttention(item)
    }

    /// All tabs currently `.waiting` plus enough context to render a notification
    /// dropdown row (workspace name, tab title, agent kind, notification body).
    func attentionList() -> [HostedAttention] {
        let entries = connectedOwners.flatMap { owner in
            SessionEditor(snapshot: snapshot(for: owner)).listAttention().map {
                HostedAttention(owner: owner, entry: $0, connected: !disconnectedHosts.contains(owner))
            }
        }
        return AttentionRank.sorted(entries, rank: { $0.entry.activity.rank }, lastActivity: { $0.entry.activity.updatedAt })
    }

    func openAttention(_ item: HostedAttention) {
        guard isConnected(item.owner), !disconnectedHosts.contains(item.owner) else {
            DisplayMessage.show("Reconnect to \(item.owner) to open this pane.")
            return
        }
        let entry = item.entry
        guard Self.surfaces(in: snapshot(for: item.owner)).contains(entry.surfaceID) else {
            DisplayMessage.show("This pane has closed.")
            return
        }
        showDaemon(item.owner, session: entry.sessionID)
        activate(owner: item.owner, selecting: entry.sessionID)
        selectTab(workspaceID: entry.workspaceID, tabID: entry.tabID)
        setActiveSurface(entry.surfaceID)
        terminalHosts.host(for: entry.surfaceID)?.focusTerminal()
        markAttentionRead(item)
    }

    func openSearchResult(_ match: OutputSearchMatch, owner: String, query: String, caseSensitive: Bool, regex: Bool = false) -> Bool {
        guard isConnected(owner), Self.surfaces(in: snapshot(for: owner)).contains(match.surfaceID) else { return false }
        showDaemon(owner, session: match.sessionID)
        activate(owner: owner, selecting: match.sessionID)
        selectTab(workspaceID: match.workspaceID, tabID: match.tabID)
        setActiveSurface(match.surfaceID)
        guard let host = terminalHosts.host(for: match.surfaceID) else { return false }
        return host.revealSearchResult(match, query: query, caseSensitive: caseSensitive, regex: regex)
    }

    func markAttentionRead(_ item: HostedAttention) {
        updateAttention(.acknowledgeAttention(surfaceID: item.entry.surfaceID.uuidString), item: item)
    }

    func snoozeAttention(_ item: HostedAttention, minutes: Int) {
        updateAttention(.snoozeAttention(surfaceID: item.entry.surfaceID.uuidString, minutes: minutes), item: item)
    }

    private func updateAttention(_ request: IPCRequest, item: HostedAttention) {
        guard item.connected, let endpoint = endpoint(forOwner: item.owner) else { DisplayMessage.show("Reconnect to this host first."); return }
        DispatchQueue.global(qos: .utility).async {
            do {
                let response = try DaemonClient(endpoint: endpoint).request(request)
                if case let .error(message) = response { throw SetupError.invalid(message) }
            } catch {
                let message = error.localizedDescription
                DispatchQueue.main.async { DisplayMessage.show(message) }
            }
        }
    }

    private func firstWaitingTab() -> (workspaceID: WorkspaceID, tabID: TabID)? {
        // Prefer panes whose agent is awaiting input (or a tab is .waiting and
        // the agent is NOT actively generating). Skip panes whose agent is
        // still hammering tokens — those aren't blocked yet.
        for workspace in snapshot.workspaces {
            for session in workspace.sessions {
                for tab in session.tabs {
                let isWaiting = tab.status == .waiting
                let agentBlocked = tab.agent?.activity == .awaiting
                let agentBusy = tab.agent?.activity == .working
                if (isWaiting && !agentBusy) || agentBlocked {
                    return (workspace.id, tab.id)
                }
                }
            }
        }
        // Fallback: any tab that's `.waiting`, even if its agent is still working.
        for workspace in snapshot.workspaces {
            for session in workspace.sessions {
                for tab in session.tabs where tab.status == .waiting {
                    return (workspace.id, tab.id)
                }
            }
        }
        return nil
    }

    /// Store the report on its source pane; the unified activity stream delivers alerts.
    func handleNotification(for surfaceID: SurfaceID, event: NotificationEvent, title: String, body: String) {
        guard !attentionList().contains(where: { $0.entry.surfaceID == surfaceID && $0.entry.activity.notification == body }) else { return }
        requestDaemonBatch([.notify(surfaceID: surfaceID.uuidString, title: title, body: body)], endpoint: endpoint(forSurface: surfaceID))
        refreshSnapshot()
    }

    func clearNotification(for surfaceID: SurfaceID) {
        requestDaemonBatch([.clearNotification(surfaceID: surfaceID.uuidString)], endpoint: endpoint(forSurface: surfaceID))
        refreshSnapshot()
    }

    func updateFontSize(delta: Float) {
        applyFontSize(settings.fontSize + delta)
    }

    /// ⌘0 — restore the default font size, completing the ⌘+/⌘-/⌘0 trio.
    func resetFontSize() {
        applyFontSize(HarnessSettings().fontSize)
    }

    private func applyFontSize(_ size: Float) {
        settings.fontSize = max(8, min(32, size))
        saveSettings()
        for host in terminalHosts.allHosts() {
            host.applySettings(settings)
        }
    }

    /// Persist the secure-keyboard-entry setting and apply it immediately (takes/releases the
    /// process-global secure-input lock based on the new value + current app-active state).
    func saveSettings() {
        do { try settings.save() }
        catch { DisplayMessage.show("Settings could not be saved: \(error.localizedDescription)") }
    }

    func setSecureKeyboardEntry(_ enabled: Bool) {
        guard settings.secureKeyboardEntry != enabled else { return }
        settings.secureKeyboardEntry = enabled
        saveSettings()
        SecureKeyboardEntry.shared.settingChanged()
    }

    /// The daemon the key window shows: `DaemonSidebar.localID` or a remote host's name.
    /// Commands, new panes, and `snapshot` belong to it.
    var activeOwner = DaemonSidebar.localID
    /// Every other daemon a window is on, kept live in the background. This Mac is always
    /// attached: it is either active or here.
    var links: [String: DaemonLink] = [:]
    /// Hosts with a reconnect chain running, so drops during it don't start another.
    var reconnectingHosts: Set<String> = []
    var reconnectGenerations: [String: UUID] = [:]
    var remoteProbePending: Set<String> = []
    let networkMonitor = NWPathMonitor()
    var wakeObserver: NSObjectProtocol?
    let remoteProbeQueue: OperationQueue = {
        let queue = OperationQueue(); queue.maxConcurrentOperationCount = 4; queue.qualityOfService = .utility; return queue
    }()
    var disconnectedHosts: Set<String> = []
    var remoteAttachmentErrors: [String: String] = [:]
    /// Attach to a saved remote daemon in the background, then call back on the main actor
    /// with whether it's attached. Bringing up the SSH tunnel blocks, so it runs off-main;
    /// failures show and change nothing.
    var pendingRemoteAttachments: [String: (id: UUID, callbacks: [@MainActor @Sendable (Bool) -> Void])] = [:]
    /// Bumped by every applied snapshot, so an off-main fetch that started earlier can tell a
    /// newer sync already landed and drop its (possibly older) answer.
    var appliedSnapshots = 0
    var hasLocalSnapshot = false
    var localStartupState = SessionStartupState.connecting
    var localServiceReady = false
    var localConnectionCompletions: [@MainActor @Sendable (Bool) -> Void] = []
    /// Subscribe to the daemon's snapshot pushes if not already subscribed. Called after
    /// every successful sync, so the channel comes up as soon as the daemon answers; the
    /// follow-up background fetch closes the fetch→subscribe race (a revision committed
    /// between the snapshot we just fetched and the subscription registering).
    var snapshotSubscriptionPending = false
    /// Selections waiting to go out, one queue per daemon: fetches and commands wait only for
    /// their own daemon's, so a slow (or silently dead) remote never holds up this Mac.
    var selectionQueues: [Endpoint: SelectionQueue] = [:]
    /// Bumped by every selection sent, so a background fetch that started earlier can tell its
    /// answer may predate it (an old active pane would pull focus back).
    var selectionsSent = 0
    /// A background fetch is in flight / another was asked for while it was.
    var fetchInFlight = false
    var refetch = false
    var lastDaemonErrorNotice: Date?
    /// Pending `SetUserVar` pushes, coalesced per (surface, name): a flood of sequences
    /// becomes at most one synchronous daemon `setOption` per name per flush window,
    /// instead of one main-thread IPC round trip (plus a snapshot-subscriber broadcast)
    /// per escape sequence.
    var pendingUserVariables: [SurfaceID: [String: String]] = [:]
    /// Names already pushed to the daemon per surface — the per-surface population cap
    /// (mirroring the engine's per-epoch cap) and the set a RIS must reset.
    var pushedUserVariableNames: [SurfaceID: Set<String>] = [:]
    var userVariableFlushScheduled = false
    var pendingDaemonOperations: [Endpoint: Int] = [:]
    var daemonFailureRevision = 0

    func diagnosticsReport() -> HarnessDiagnosticsReport {
        let sessions = snapshot.workspaces.flatMap(\.sessions)
        let tabs = sessions.flatMap(\.tabs)
        let panes = tabs.flatMap { $0.rootPane.allLeaves() }
        return HarnessDiagnosticsReport(
            daemonReachable: FileManager.default.fileExists(atPath: HarnessPaths.socketURL.path),
            sessionCount: sessions.count,
            windowCount: tabs.count,
            paneCount: panes.count,
            themeName: snapshot.themeName,
            settings: settings
        )
    }

    @discardableResult
    func copyDiagnosticsReport() -> String {
        let text = diagnosticsReport().formatted()
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        return text
    }
}

enum HarnessPathDisplay {
    static func title(for path: String, fallback: String) -> String {
        if path == "/" { return "/" }
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        if path == home { return "~" }
        let shortened = path.hasPrefix(home + "/") ? "~" + path.dropFirst(home.count) : path
        let last = (String(shortened) as NSString).lastPathComponent
        if !last.isEmpty { return last }
        if !fallback.isEmpty, fallback != "Shell" { return fallback }
        return "Terminal"
    }
}

extension Notification.Name {
    static let harnessLocalStartupChanged = Notification.Name("HarnessLocalStartupChanged")
    /// The focused pane changed (pane headers re-dim on this).
    static let harnessActiveSurfaceDidChange = Notification.Name("HarnessActiveSurfaceDidChange")
    /// Some pane's size owner changed (its header shows or hides "Viewing at …").
    static let harnessSizeOwnershipDidChange = Notification.Name("HarnessSizeOwnershipDidChange")
}
