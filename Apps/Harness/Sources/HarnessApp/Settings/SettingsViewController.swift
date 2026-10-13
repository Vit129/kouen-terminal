import AppKit
import HarnessCore
import HarnessTerminalKit
import HarnessTheme
import UniformTypeIdentifiers
import UserNotifications

@MainActor
final class SettingsViewController: NSViewController, NSFontChanging {
    // Theme
    let appearanceModeSegment = HarnessSegmented(frame: .zero)
    let themePopup = HarnessSelect(frame: .zero)
    let systemLightThemePopup = HarnessSelect(frame: .zero)
    let systemDarkThemePopup = HarnessSelect(frame: .zero)
    var appearanceModeRow: SettingsFormRow?
    var themeRow: SettingsFormRow?
    var lightThemeRow: SettingsFormRow?
    var darkThemeRow: SettingsFormRow?
    // Window + panes
    let opacitySlider = HarnessSlider(frame: .zero)
    let opacityLabel = NSTextField(labelWithString: "")
    let blurSlider = HarnessSlider(frame: .zero)
    let blurLabel = NSTextField(labelWithString: "")
    let windowBorderOpacitySlider = HarnessSlider(frame: .zero)
    let windowBorderOpacityLabel = NSTextField(labelWithString: "")
    let transparentTitlebarToggle = HarnessToggle(frame: .zero)
    let machineIndicatorToggle = HarnessToggle(frame: .zero)
    let sidebarVisibleToggle = HarnessToggle(frame: .zero)
    let restoreWindowSizeToggle = HarnessToggle(frame: .zero)
    let paneDensitySegment = HarnessSegmented(frame: .zero)
    let paneHeadersToggle = HarnessToggle(frame: .zero)
    let paneSpacingField = HarnessTextField()
    let paddingXField = HarnessTextField()
    let paddingYField = HarnessTextField()
    let paddingBalanceToggle = HarnessToggle(frame: .zero)
    let resizeOverlaySegment = HarnessSegmented(frame: .zero)
    let resizeOverlayPositionSegment = HarnessSegmented(frame: .zero)
    var resizeOverlayPositionRow: SettingsFormRow?
    // Colors
    private let backgroundHexField = HarnessTextField()
    private let foregroundHexField = HarnessTextField()
    private let cursorHexField = HarnessTextField()
    private let cursorTextHexField = HarnessTextField()
    private let selectionBgHexField = HarnessTextField()
    private let selectionFgHexField = HarnessTextField()
    private let boldHexField = HarnessTextField()
    private let dividerHexField = HarnessTextField()
    private let statusLineHexField = HarnessTextField()
    private let windowBorderHexField = HarnessTextField()
    private let backgroundWell = HarnessSwatchWell(frame: .zero)
    private let foregroundWell = HarnessSwatchWell(frame: .zero)
    private let cursorWell = HarnessSwatchWell(frame: .zero)
    private let cursorTextWell = HarnessSwatchWell(frame: .zero)
    private let selectionBgWell = HarnessSwatchWell(frame: .zero)
    private let selectionFgWell = HarnessSwatchWell(frame: .zero)
    private let boldWell = HarnessSwatchWell(frame: .zero)
    private let dividerWell = HarnessSwatchWell(frame: .zero)
    private let statusLineWell = HarnessSwatchWell(frame: .zero)
    private let windowBorderWell = HarnessSwatchWell(frame: .zero)
    let minContrastSlider = HarnessSlider(frame: .zero)
    let minContrastLabel = NSTextField(labelWithString: "")
    let boldIsBrightToggle = HarnessToggle(frame: .zero)
    let themeFitToggle = HarnessToggle(frame: .zero)
    let themeTerminalOutputToggle = HarnessToggle(frame: .zero)
    let vividColorsToggle = HarnessToggle(frame: .zero)
    // Terminal
    let experienceSegment = HarnessSegmented(frame: .zero)
    let experienceSummaryLabel = SettingsCaption(wrappingLabelWithString: "")
    // Per-component overrides for the chrome the experience preset would otherwise bundle. Each is
    // tri-state (Auto / On / Off): Auto follows the selected preset; On/Off pin the component
    // independently, so e.g. a Plain terminal can show a status line without arming the prefix.
    let prefixControlSegment = HarnessSegmented(frame: .zero)
    let statusLineControlSegment = HarnessSegmented(frame: .zero)
    let fontSizeField = HarnessTextField()
    let fontFallbackField = HarnessTextField()
    let fontFeaturesField = HarnessTextField()
    let fontFamilyField = NSTextField() // backing store for the chosen font (not shown)
    let fontReadout = NSTextField(labelWithString: "")
    let textRenderingSegment = HarnessSegmented(frame: .zero)
    let ligaturesToggle = HarnessToggle(frame: .zero)
    let cursorStyleSegment = HarnessSegmented(frame: .zero)
    let cursorBlinkToggle = HarnessToggle(frame: .zero)
    let shellField = HarnessTextField()
    let cwdField = HarnessTextField()
    let inheritCWDToggle = HarnessToggle(frame: .zero)
    let scrollbackField = HarnessTextField()
    let scrollMultiplierSlider = HarnessSlider(frame: .zero)
    let scrollMultiplierLabel = NSTextField(labelWithString: "")
    let copyOnSelectToggle = HarnessToggle(frame: .zero)
    let mouseHideToggle = HarnessToggle(frame: .zero)
    let bellSegment = HarnessSegmented(frame: .zero)
    let promptGutterToggle = HarnessToggle(frame: .zero)
    let pasteProtectionToggle = HarnessToggle(frame: .zero)
    let secureKeyboardToggle = HarnessToggle(frame: .zero)
    let remoteControlToggle = HarnessToggle(frame: .zero)
    let keepSessionsToggle = HarnessToggle(frame: .zero)
    let defaultTerminalButton = NSButton(title: "Make Default", target: nil, action: nil)
    var defaultTerminalRow: SettingsFormRow?
    // Keys
    var keyRecorder: KeyRecorderView!
    let optionKeySegment = HarnessSegmented(frame: .zero)
    let quickTerminalToggle = HarnessToggle(frame: .zero)
    var quickTerminalHotkeyRecorder: KeyRecorderView!
    // Notifications
    /// One toggle per `NotificationEvent` ("which events notify me"). Built from the enum so a
    /// new case automatically gets a wired row. Lazy so its (main-actor) `HarnessToggle`
    /// construction runs at first access inside a method, not in a stored-property initializer.
    lazy var eventToggles: [NotificationEvent: HarnessToggle] = {
        var toggles: [NotificationEvent: HarnessToggle] = [:]
        for event in NotificationEvent.allCases {
            toggles[event] = HarnessToggle(frame: .zero)
        }
        return toggles
    }()
    let commandFinishedThresholdField = HarnessTextField()
    let systemNotificationsToggle = HarnessToggle(frame: .zero)
    let notificationSoundToggle = HarnessToggle(frame: .zero)
    let notificationTestButton = NSButton(title: "Send Test", target: nil, action: nil)
    let notificationPermissionButton = NSButton(title: "Open System Settings…", target: nil, action: nil)
    var notificationStatusRow: SettingsFormRow?
    // Advanced
    let liveResizeReflowToggle = HarnessToggle(frame: .zero)

    private let pageContainer = NSView()
    var pages: [SettingsPane: NSView] = [:]
    /// The pane shown first; `SettingsWindowController.show(pane:)` sets it before the view loads.
    var initialPane: SettingsPane = .appearance
    /// Opens with this text in the search field, landing on its first matching control.
    var initialSearch: String?
    private(set) var currentPane: SettingsPane = .appearance
    /// Group-card surfaces + hairline dividers, tracked so a live theme change can
    /// re-skin them (they're created inline by the `settingsGroup` factory rather than
    /// stored individually).
    private var groupSurfaces: [NSView] = []
    private var groupDividers: [NSView] = []
    /// Text-link buttons (accent baked into the attributed title) re-tinted on theme change.
    var linkButtons: [NSButton] = []
    var paletteWells: [HarnessSwatchWell] = []
    private var paletteNote: NSTextField?
    var paletteHexValues: [String?] = Array(repeating: nil, count: 16)
    var colorBindings: [ColorBinding] = []
    /// Live "Install Hooks / Reinstall Hooks" buttons keyed by agent (Agents page).
    var notificationPolicy: NotificationPolicyWindowController?
    var powerSettings: PowerSettingsWindowController?
    var activityProfiles: ActivityProfileWindowController?
    var hookButtons: [AgentKind: NSButton] = [:]

    struct ColorBinding {
        let field: HarnessTextField
        let well: HarnessSwatchWell
        let reset: NSButton
        let keyPath: WritableKeyPath<HarnessSettings, String?>
        let themeColor: () -> String?
    }

    private static let defaultAnsiPalette = ThemeManager.defaultBaselinePaletteHex
    private static let ansiNames = [
        "Black", "Red", "Green", "Yellow", "Blue", "Magenta", "Cyan", "White",
        "Bright Black", "Bright Red", "Bright Green", "Bright Yellow",
        "Bright Blue", "Bright Magenta", "Bright Cyan", "Bright White",
    ]
    static let agentKinds = AgentKind.allCases.filter { $0 != .generic }

    deinit {
        // A fresh controller is built on each open and the previous one is torn down; drop
        // its observers (the chrome-change observer + the per-field text-change observers
        // registered in `configureLiveAppearanceField`) so a closed window stops reacting.
        NotificationCenter.default.removeObserver(self)
    }

    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 940, height: 680))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureControls()
        layoutShell()
        showPage(initialPane)
        observeChromeChanges()
        if let initialSearch, !initialSearch.isEmpty {
            settingsSearch.stringValue = initialSearch
            filterSections(initialSearch)
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        if !(initialSearch ?? "").isEmpty { view.window?.makeFirstResponder(settingsSearch) }
    }

    // MARK: - Control configuration (initial state from settings)

    private func configureControls() {
        let coordinator = SessionCoordinator.shared
        let settings = coordinator.settings

        appearanceModeSegment.setSegments(HarnessAppearanceMode.allCases.map(Self.appearanceModeTitle))
        appearanceModeSegment.selectItem(withTitle: Self.appearanceModeTitle(settings.appearanceMode))
        appearanceModeSegment.target = self
        appearanceModeSegment.action = #selector(appearanceTextDidCommit)

        populateThemePopup(themePopup, selectedThemeName: coordinator.snapshot.themeName)
        themePopup.target = self
        themePopup.action = #selector(themeDidChange)
        populateThemePopup(systemLightThemePopup, selectedThemeName: settings.systemLightThemeName)
        systemLightThemePopup.target = self
        systemLightThemePopup.action = #selector(systemLightThemeDidChange)
        populateThemePopup(systemDarkThemePopup, selectedThemeName: settings.systemDarkThemeName)
        systemDarkThemePopup.target = self
        systemDarkThemePopup.action = #selector(systemDarkThemeDidChange)

        configureSlider(opacitySlider, label: opacityLabel, range: 0.05 ... 1, value: Double(settings.backgroundOpacity),
                        action: #selector(opacityDidChange))
        opacityLabel.stringValue = formatPercent(settings.backgroundOpacity)
        configureSlider(blurSlider, label: blurLabel, range: 0 ... 100, value: Double(settings.backgroundBlur),
                        action: #selector(blurDidChange))
        blurLabel.stringValue = formatBlur(settings.backgroundBlur)
        configureSlider(windowBorderOpacitySlider, label: windowBorderOpacityLabel, range: 0 ... 1,
                        value: Double(settings.windowBorderOpacity), action: #selector(windowBorderOpacityDidChange))
        windowBorderOpacityLabel.stringValue = formatPercent(settings.windowBorderOpacity)
        configureSlider(minContrastSlider, label: minContrastLabel, range: 1 ... 21, value: settings.minimumContrast,
                        action: #selector(minContrastChanged))
        updateMinContrastLabel()
        configureSlider(scrollMultiplierSlider, label: scrollMultiplierLabel, range: 0.1 ... 10,
                        value: settings.scrollMultiplier, action: #selector(scrollMultiplierChanged))
        updateScrollMultiplierLabel()

        for (field, value) in [
            (paneSpacingField, String(format: "%.0f", settings.paneSpacing)),
            (paddingXField, String(format: "%.0f", settings.windowPaddingX)),
            (paddingYField, String(format: "%.0f", settings.windowPaddingY)),
            (fontSizeField, String(format: "%.0f", settings.fontSize)),
            (fontFallbackField, settings.fontFallbackFamilies.joined(separator: ", ")),
            (fontFeaturesField, settings.fontFeatures.sorted { $0.key < $1.key }.map { "\($0.key)=\($0.value)" }.joined(separator: ", ")),
            (shellField, settings.defaultShell),
            (cwdField, settings.defaultCWD),
            (scrollbackField, String(settings.scrollbackLines)),
            (commandFinishedThresholdField, String(settings.commandFinishedThresholdSeconds)),
        ] {
            field.stringValue = value
            field.target = self
            field.action = #selector(appearanceTextDidCommit)
        }
        fontFamilyField.stringValue = settings.fontFamily

        colorBindings = [
            ColorBinding(
                field: backgroundHexField, well: backgroundWell, reset: makeResetButton(),
                keyPath: \.customBackgroundHex,
                themeColor: { Self.themePreview().canvasBackgroundHex }
            ),
            ColorBinding(
                field: foregroundHexField, well: foregroundWell, reset: makeResetButton(),
                keyPath: \.customForegroundHex,
                themeColor: { Self.themePreview().canvasForegroundHex }
            ),
            ColorBinding(
                field: cursorHexField, well: cursorWell, reset: makeResetButton(),
                keyPath: \.customCursorHex,
                themeColor: { Self.themePreview().cursorHex }
            ),
            ColorBinding(
                field: cursorTextHexField, well: cursorTextWell, reset: makeResetButton(),
                keyPath: \.cursorTextHex,
                themeColor: { Self.themePreview().cursorTextHex ?? Self.themePreview().canvasBackgroundHex }
            ),
            ColorBinding(
                field: selectionBgHexField, well: selectionBgWell, reset: makeResetButton(),
                keyPath: \.selectionBackgroundHex,
                themeColor: { Self.themePreview().selectionBackgroundHex }
            ),
            ColorBinding(
                field: selectionFgHexField, well: selectionFgWell, reset: makeResetButton(),
                keyPath: \.selectionForegroundHex,
                themeColor: { Self.themePreview().selectionForegroundHex }
            ),
            ColorBinding(
                field: boldHexField, well: boldWell, reset: makeResetButton(),
                keyPath: \.boldColorHex,
                themeColor: { ThemeManager.boldHex(themeName: Self.activeThemeName()) }
            ),
            // Window-chrome accents: the hairline dividers and the status line text.
            // Always honored — not gated by `useCustomColors` — since these are pure
            // chrome and the user explicitly opted in by setting a hex.
            ColorBinding(
                field: dividerHexField, well: dividerWell, reset: makeResetButton(),
                keyPath: \.dividerHex,
                // Match MainSplitViewController.resolvedDividerColor: #1E1E1E on dark themes.
                themeColor: {
                    HarnessChrome.current.isDark
                        ? HarnessChromePalette.defaultDarkDividerHex
                        : Self.themePreview().canvasForegroundHex
                }
            ),
            ColorBinding(
                field: statusLineHexField, well: statusLineWell, reset: makeResetButton(),
                keyPath: \.statusLineHex,
                themeColor: { Self.themePreview().canvasForegroundHex }
            ),
            ColorBinding(
                field: windowBorderHexField, well: windowBorderWell, reset: makeResetButton(),
                keyPath: \.windowBorderHex,
                // Match MainWindowController.applyTransparency: white on dark themes, black on
                // light (opacity makes the hairline read as a faint grey).
                themeColor: { HarnessChrome.current.isDark ? "#FFFFFF" : "#000000" }
            ),
        ]
        for binding in colorBindings {
            // Every color is directly editable; an unset (nil) field falls back to
            // the active theme preset inside the resolver.
            binding.field.stringValue = settings[keyPath: binding.keyPath] ?? ""
            configureLiveAppearanceField(binding.field)
            configureColorWell(binding.well)
            refreshColorBinding(binding)
        }

        paletteHexValues = HarnessSettings.normalizedPalette(settings.paletteHex)
        buildPaletteWells()

        experienceSegment.setSegments(ExperienceMode.allCases.map(Self.experienceTitle))
        experienceSegment.selectedSegment = ExperienceMode.allCases.firstIndex(of: settings.experienceMode) ?? 0
        experienceSegment.target = self
        experienceSegment.action = #selector(experienceModeChanged)
        experienceSummaryLabel.font = .systemFont(ofSize: 11.5)
        experienceSummaryLabel.textColor = .secondaryLabelColor
        experienceSummaryLabel.stringValue = settings.experienceMode.summary(keepSessionsOnQuit: SessionCoordinator.shared.snapshot.keepSessionsOnQuit)

        // Optional Harness controls without switching experience mode, as two independent
        // tri-states. Auto follows the preset; On/Off pin each via `prefixKeyEnabled` /
        // `statusLineEnabled`. The legacy umbrella `harnessControlsEnabled` is preserved on disk and
        // acts as the fallback when a component is Auto, so existing settings keep their behavior.
        prefixControlSegment.setSegments(["Auto", "On", "Off"])
        prefixControlSegment.target = self
        prefixControlSegment.action = #selector(prefixControlChanged)
        statusLineControlSegment.setSegments(["Auto", "On", "Off"])
        statusLineControlSegment.target = self
        statusLineControlSegment.action = #selector(statusLineControlChanged)

        cursorStyleSegment.setSegments(["Block", "Beam", "Underline"])
        textRenderingSegment.setSegments(["Native", "Crisp", "Soft"])
        resizeOverlaySegment.setSegments(["After First", "Always", "Never"])
        resizeOverlayPositionSegment.setSegments(["Center", "Top Right", "Bottom Right"])
        bellSegment.setSegments(["Off", "Sound", "Flash", "Both"])
        optionKeySegment.setSegments(["Characters", "Meta", "Left Meta", "Right Meta"])
        paneDensitySegment.setSegments(["Comfortable", "Compact"])
        for segment in [cursorStyleSegment, textRenderingSegment, resizeOverlaySegment,
                        resizeOverlayPositionSegment, bellSegment, optionKeySegment, paneDensitySegment] {
            segment.target = self
            segment.action = #selector(appearanceTextDidCommit)
        }

        // Toggles that write straight through `applySettingsLive`.
        for toggle in [machineIndicatorToggle, cursorBlinkToggle, copyOnSelectToggle, vividColorsToggle, themeTerminalOutputToggle,
                       ligaturesToggle, promptGutterToggle, transparentTitlebarToggle,
                       liveResizeReflowToggle, paddingBalanceToggle, mouseHideToggle, pasteProtectionToggle,
                       remoteControlToggle, boldIsBrightToggle, themeFitToggle, paneHeadersToggle,
                       inheritCWDToggle, quickTerminalToggle, notificationSoundToggle] + Array(eventToggles.values) {
            toggle.target = self
            toggle.action = #selector(appearanceTextDidCommit)
        }
        // Daemon-owned (not a HarnessSettings field) — reflects snapshot truth and
        // commits via IPC on its own action.
        keepSessionsToggle.target = self
        keepSessionsToggle.action = #selector(toggleKeepSessions)
        secureKeyboardToggle.target = self
        secureKeyboardToggle.action = #selector(secureKeyboardChanged)
        sidebarVisibleToggle.target = self
        sidebarVisibleToggle.action = #selector(sidebarVisibilityChanged)
        restoreWindowSizeToggle.target = self
        restoreWindowSizeToggle.action = #selector(restoreWindowSizeChanged)
        systemNotificationsToggle.target = self
        systemNotificationsToggle.action = #selector(systemNotificationsToggled)

        for button in [defaultTerminalButton, notificationTestButton, notificationPermissionButton] {
            button.bezelStyle = .rounded
            button.controlSize = .regular
            button.target = self
        }
        defaultTerminalButton.action = #selector(setDefaultTerminalClicked)
        notificationPermissionButton.isHidden = true // shown once macOS says it's blocking us
        notificationTestButton.action = #selector(sendTestNotification)
        notificationPermissionButton.action = #selector(openNotificationPermission)

        keyRecorder = KeyRecorderView(initial: settings.prefixKey, emptyTitle: "No prefix")
        keyRecorder.onChange = { value in
            // Empty = disable the prefix entirely (honored via `effectivePrefixKey`); don't
            // silently snap back to Ctrl-A the way the old code did.
            SettingsEditor.applyFromWindow(\.prefixKey, value, on: &SessionCoordinator.shared.settings)
            self.saveSettings()
            PrefixKeymap.shared.rebuildFromSettings()
        }
        quickTerminalHotkeyRecorder = KeyRecorderView(initial: settings.quickTerminalHotkey)
        quickTerminalHotkeyRecorder.onChange = { value in
            SettingsEditor.applyFromWindow(\.quickTerminalHotkey, value, on: &SessionCoordinator.shared.settings)
            self.saveSettings()
            QuickTerminalController.shared.rebuildFromSettings()
        }

        // Every other control's state comes from one place, so open and re-sync can't disagree.
        syncAppearanceControlsFromSettings()
    }

    private func configureSlider(
        _ slider: HarnessSlider, label: NSTextField, range: ClosedRange<Double>, value: Double, action: Selector
    ) {
        slider.minValue = range.lowerBound
        slider.maxValue = range.upperBound
        slider.doubleValue = value
        slider.isContinuous = true
        slider.target = self
        slider.action = action
        slider.onCommit = { [weak self] in self?.flushAndApply() }
        label.font = .monospacedDigitSystemFont(ofSize: 11.5, weight: .regular)
        label.textColor = .secondaryLabelColor
        label.alignment = .right
    }

    // MARK: - Shell layout (sidebar + paged content)

    private func layoutShell() {
        view.wantsLayer = true
        view.layer?.backgroundColor = HarnessChrome.current.terminalBackground.cgColor

        let sidebar = buildSidebar()
        sidebar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sidebar)

        pageContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageContainer)

        NSLayoutConstraint.activate([
            sidebar.topAnchor.constraint(equalTo: view.topAnchor),
            sidebar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sidebar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sidebar.widthAnchor.constraint(equalToConstant: Form.sidebarWidth),

            pageContainer.topAnchor.constraint(equalTo: view.topAnchor),
            pageContainer.leadingAnchor.constraint(equalTo: sidebar.trailingAnchor),
            pageContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        pages[.appearance] = buildAppearancePage()
        pages[.colors] = buildColorsPage()
        pages[.terminal] = buildTerminalPage()
        pages[.keys] = buildKeysPage()
        pages[.notifications] = buildNotificationsPage()
        pages[.agents] = buildAgentsPage()
        pages[.tools] = buildToolsPage()
        pages[.advanced] = buildAdvancedPage()
        updateDependentRows()
    }

    func showPage(_ pane: SettingsPane, refresh: Bool = true) {
        for button in sidebarButtons { button.isSelected = (button.tag == pane.rawValue) }
        for subview in pageContainer.subviews { subview.removeFromSuperview() }
        // Rebuild the Advanced page each time it's shown so it re-checks daemon reachability (and
        // re-fetches live option values): a daemon that was down when Settings opened may be back,
        // and vice-versa. The other pages are static enough to stay cached.
        if pane == .advanced, refresh { pages[.advanced] = buildAdvancedPage() }
        if pane == .notifications { refreshNotificationStatus() }
        guard let page = pages[pane] else { return }
        page.translatesAutoresizingMaskIntoConstraints = false
        pageContainer.addSubview(page)
        NSLayoutConstraint.activate([
            page.topAnchor.constraint(equalTo: pageContainer.topAnchor),
            page.leadingAnchor.constraint(equalTo: pageContainer.leadingAnchor),
            page.trailingAnchor.constraint(equalTo: pageContainer.trailingAnchor),
            page.bottomAnchor.constraint(equalTo: pageContainer.bottomAnchor),
        ])
        currentPane = pane
    }

    // MARK: - Live theme re-skin

    /// Settings paints with `HarnessChrome.current`, so when the user switches theme (or
    /// edits bg/fg/cursor) from inside this window, observe the same chrome broadcast the
    /// main window uses and recolor every control + surface in step. Without this the
    /// Settings window would keep the palette it opened with.
    private func observeChromeChanges() {
        lastChromeSignature = chromeSignature()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(chromeDidChange(_:)),
            name: NotificationBus.shared.snapshotChanged,
            object: nil
        )
    }

    @objc private func chromeDidChange(_ note: Notification) {
        guard note.userInfo?["chromeChanged"] as? Bool == true else { return }
        HarnessDesign.applySidebarChrome(to: sidebarContainer)
        // `flushAndApply` posts `chromeChanged` on every control action (including
        // continuous opacity/blur drags), but the palette only actually changes on a
        // theme or bg/fg/cursor edit. Skip the re-skin walk when the colors are identical
        // so dragging a slider doesn't churn every control on each tick.
        let signature = chromeSignature()
        guard signature != lastChromeSignature else { return }
        lastChromeSignature = signature
        let c = HarnessChrome.current
        view.layer?.backgroundColor = c.terminalBackground.cgColor
        sidebarTitleLabel.textColor = c.textPrimary
        // System-colored text labels track the window's light/dark appearance; updating it
        // re-renders them for free, so only surfaces + custom controls need explicit recolor.
        view.window?.appearance = NSAppearance(named: c.isDark ? .darkAqua : .aqua)
        view.window?.backgroundColor = c.terminalBackground
        for surface in groupSurfaces {
            surface.layer?.backgroundColor = c.surfaceElevated.cgColor
            surface.layer?.borderColor = c.border.cgColor
        }
        for divider in groupDividers { divider.layer?.backgroundColor = c.border.cgColor }
        // Re-skin every themed control. Cached pages are walked directly since only the
        // visible page is in the view tree.
        reskinControls(in: view)
        for page in pages.values { reskinControls(in: page) }
        // Re-tint links (their accent color is baked into the attributed title).
        for link in linkButtons { styleAsLink(link) }
        // Auto light/dark lands here as a chrome change too: the color wells/placeholder hex
        // read from the *theme*, so without a refresh they keep showing the old appearance's
        // palette until the window reopens.
        refreshColorPlaceholders()
    }

    private var lastChromeSignature: String?

    /// A cheap fingerprint of the palette colors that drive the control re-skin. Opacity /
    /// blur changes don't alter these, so they won't trigger a needless walk.
    private func chromeSignature() -> String {
        let c = HarnessChrome.current
        return [c.terminalBackground, c.textPrimary, c.accent]
            .map(hexString)
            .joined(separator: "|") + (c.isDark ? "·D" : "·L")
    }

    /// Recursively re-apply `applyChrome()` to every themed control under `root`.
    private func reskinControls(in root: NSView) {
        for sub in root.subviews {
            switch sub {
            case let v as HarnessTextField: v.applyChrome()
            case let v as HarnessSearchField: v.applyChrome()
            case let v as HarnessToggle: v.applyChrome()
            case let v as HarnessSlider: v.applyChrome()
            case let v as HarnessSwatchWell: v.applyChrome()
            case let v as IconTileView: v.applyChrome()
            case let v as HarnessSegmented: v.applyChrome()
            case let v as HarnessSelect: v.applyChrome()
            case let v as HarnessPillButton: v.applyChrome()
            case let v as KeyRecorderView: v.applyChrome()
            case let v as SettingsSidebarButton: v.applyChrome()
            default: break
            }
            reskinControls(in: sub)
        }
    }

    // MARK: - Sidebar

    private let sidebarContainer = NSView()
    private var sidebarButtons: [SettingsSidebarButton] = []
    private let settingsSearch = HarnessSearchField()
    private let sidebarTitleLabel = NSTextField(labelWithString: "Settings")
    private let noResultsLabel = NSTextField(labelWithString: "No matching settings")

    private func buildSidebar() -> NSView {
        // A plain layer-backed view carrying the same themed sidebar chrome (vibrancy +
        // tint) the main window's sidebar uses — never the system `.sidebar` material,
        // which adds the system tint on top of the theme.
        let container = sidebarContainer
        container.translatesAutoresizingMaskIntoConstraints = false
        HarnessDesign.applySidebarChrome(to: container)

        let title = sidebarTitleLabel
        title.font = .systemFont(ofSize: 20, weight: .bold)
        title.textColor = HarnessChrome.current.textPrimary
        title.translatesAutoresizingMaskIntoConstraints = false

        settingsSearch.placeholderString = "Search"
        settingsSearch.onChange = { [weak self] query in self?.filterSections(query) }
        settingsSearch.onSubmit = { [weak self] in self?.showNextSearchMatch() }
        settingsSearch.setAccessibilityLabel("Search settings")
        settingsSearch.translatesAutoresizingMaskIntoConstraints = false

        let buttons = NSStackView()
        buttons.orientation = .vertical
        buttons.alignment = .width
        buttons.spacing = HarnessDesign.Spacing.xxs
        buttons.translatesAutoresizingMaskIntoConstraints = false

        sidebarButtons.removeAll()
        for pane in SettingsPane.allCases {
            let button = SettingsSidebarButton(title: pane.title, symbol: pane.symbol)
            button.tag = pane.rawValue
            button.target = self
            button.action = #selector(sidebarItemClicked(_:))
            button.onArrow = { [weak self] delta in self?.moveSelection(by: delta) }
            buttons.addArrangedSubview(button)
            sidebarButtons.append(button)
        }

        noResultsLabel.font = .systemFont(ofSize: 12)
        noResultsLabel.textColor = .secondaryLabelColor
        noResultsLabel.isHidden = true
        noResultsLabel.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(title)
        container.addSubview(settingsSearch)
        container.addSubview(buttons)
        container.addSubview(noResultsLabel)
        let buttonsTop = buttons.topAnchor.constraint(equalTo: settingsSearch.bottomAnchor, constant: 16)
        buttonsTopToSearch = buttonsTop
        NSLayoutConstraint.activate([
            buttonsTop,
            title.topAnchor.constraint(equalTo: container.topAnchor, constant: 26),
            title.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 18),
            title.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -18),
            settingsSearch.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 14),
            settingsSearch.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),
            settingsSearch.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -14),
            buttons.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            buttons.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
            noResultsLabel.topAnchor.constraint(equalTo: settingsSearch.bottomAnchor, constant: 18),
            noResultsLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
        ])
        return container
    }

    /// One control that matches the settings search.
    struct SearchMatch {
        let pane: SettingsPane
        fileprivate let row: SettingsFormRow
        var title: String { row.title }
    }

    private var searchMatches: [SearchMatch] = []
    private(set) var searchMatchIndex = 0

    /// Controls whose title and hint contain every word of `query`, title matches first,
    /// each group in sidebar order and then page order. Rows hidden by other settings are skipped.
    func settingsSearchMatches(_ query: String) -> [SearchMatch] {
        let words = query.lowercased().split(whereSeparator: \.isWhitespace).map(String.init)
        guard !words.isEmpty else { return [] }
        var titled: [SearchMatch] = [], hinted: [SearchMatch] = []
        for pane in SettingsPane.allCases {
            guard let page = pages[pane] else { continue }
            for row in Self.formRows(in: page) where !row.isHidden && !(row.superview?.isHidden ?? false) {
                let title = row.title.lowercased()
                let text = title + " " + (row.hint ?? "").lowercased()
                guard words.allSatisfy(text.contains) else { continue }
                let match = SearchMatch(pane: pane, row: row)
                if words.allSatisfy(title.contains) { titled.append(match) } else { hinted.append(match) }
            }
        }
        return titled + hinted
    }

    private static func formRows(in root: NSView) -> [SettingsFormRow] {
        if let row = root as? SettingsFormRow { return [row] }
        return root.subviews.flatMap(formRows)
    }

    /// Filter the sidebar to panes whose title, keywords, or controls match, and land on the
    /// first matching control. Return in the search field steps through the rest.
    private func filterSections(_ raw: String) {
        let query = raw.lowercased().trimmingCharacters(in: .whitespaces)
        searchMatches = settingsSearchMatches(query)
        searchMatchIndex = 0
        let matchedPanes = Set(searchMatches.map(\.pane))
        for button in sidebarButtons {
            guard !query.isEmpty, let pane = SettingsPane(rawValue: button.tag) else {
                button.isHidden = false
                continue
            }
            let hits = matchedPanes.contains(pane) || pane.title.lowercased().contains(query)
                || pane.keywords.contains { $0.contains(query) }
            button.isHidden = !hits
        }
        let visible = sidebarButtons.filter { !$0.isHidden }
        if let first = searchMatches.first {
            reveal(first)
        } else {
            highlightedRow?.setSearchHighlight(false)
            highlightedRow = nil
            if !visible.contains(where: { $0.tag == currentPane.rawValue }),
               let first = visible.first, let pane = SettingsPane(rawValue: first.tag) {
                showPage(pane)
            }
        }
        updateSearchStatus(query: query, anyPane: !visible.isEmpty)
    }

    private weak var highlightedRow: SettingsFormRow?

    func showNextSearchMatch() {
        guard !searchMatches.isEmpty else { return }
        searchMatchIndex = (searchMatchIndex + 1) % searchMatches.count
        reveal(searchMatches[searchMatchIndex])
        updateSearchStatus(query: settingsSearch.stringValue, anyPane: true)
    }

    private func reveal(_ match: SearchMatch) {
        if currentPane != match.pane { showPage(match.pane, refresh: false) }
        highlightedRow?.setSearchHighlight(false)
        highlightedRow = match.row
        match.row.setSearchHighlight(true)
        view.layoutSubtreeIfNeeded()
        let target = match.row.superview ?? match.row
        target.scrollToVisible(target.bounds.insetBy(dx: 0, dy: -48))
        NSAccessibility.post(element: view, notification: .announcementRequested, userInfo: [
            .announcement: "\(match.title), \(match.pane.title)",
            .priority: NSAccessibilityPriorityLevel.medium.rawValue,
        ])
    }

    private func updateSearchStatus(query: String, anyPane: Bool) {
        if query.isEmpty {
            noResultsLabel.isHidden = true
        } else if searchMatches.count > 1 {
            noResultsLabel.stringValue = "\(searchMatchIndex + 1) of \(searchMatches.count) · Return for next"
            noResultsLabel.isHidden = false
        } else {
            noResultsLabel.stringValue = "No matching settings"
            noResultsLabel.isHidden = anyPane
        }
        buttonsTopToSearch?.constant = noResultsLabel.isHidden ? 16 : 36
    }

    private var buttonsTopToSearch: NSLayoutConstraint?

    /// ↑ / ↓ on a focused sidebar row move through the visible panes.
    private func moveSelection(by delta: Int) {
        let visible = sidebarButtons.filter { !$0.isHidden }
        guard let index = visible.firstIndex(where: { $0.tag == currentPane.rawValue }) else { return }
        let next = index + delta
        guard visible.indices.contains(next), let pane = SettingsPane(rawValue: visible[next].tag) else { return }
        showPage(pane)
        view.window?.makeFirstResponder(visible[next])
    }

    @objc private func sidebarItemClicked(_ sender: SettingsSidebarButton) {
        if let pane = SettingsPane(rawValue: sender.tag) { showPage(pane) }
    }

    // MARK: - Form primitives

    /// One scrolling page: a title (with an optional trailing control and subtitle) over its
    /// groups, in a column that fills the pane up to `Form.maxWidth` and centers beyond it.
    func page(_ title: String, subtitle: String? = nil, accessory: NSView? = nil, _ sections: [NSView]) -> NSView {
        let titleLabel = NSTextField(labelWithString: title)
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .labelColor
        titleLabel.setAccessibilityRole(.staticText)
        var headerViews: [NSView] = [titleLabel, spacer()]
        if let accessory { headerViews.append(accessory) }
        let header = hstack(headerViews, spacing: 12)
        var top: [NSView] = [header]
        if let subtitle { top.append(caption(subtitle)) }
        let headerBlock = NSStackView(views: top)
        headerBlock.orientation = .vertical
        headerBlock.alignment = .width
        headerBlock.spacing = HarnessDesign.Spacing.sm
        for part in top {
            part.leadingAnchor.constraint(equalTo: headerBlock.leadingAnchor).isActive = true
            part.trailingAnchor.constraint(equalTo: headerBlock.trailingAnchor).isActive = true
        }

        let stack = NSStackView(views: [headerBlock] + sections)
        stack.orientation = .vertical
        stack.alignment = .width
        stack.spacing = Form.groupSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        for section in stack.arrangedSubviews {
            section.leadingAnchor.constraint(equalTo: stack.leadingAnchor).isActive = true
            section.trailingAnchor.constraint(equalTo: stack.trailingAnchor).isActive = true
        }
        return scrollWrap(stack)
    }

    /// One settings row: title (and an optional hint under it) on the left, the control on the
    /// right. The control is labeled for VoiceOver with the row's title.
    @discardableResult
    func settingsRow(_ title: String, _ control: NSView, hint: String? = nil) -> SettingsFormRow {
        labelForAccessibility(control, title)
        return SettingsFormRow(title: title, hint: hint, control: control)
    }

    /// VoiceOver names the first unlabeled control inside `view` after its row.
    private func labelForAccessibility(_ view: NSView, _ title: String) {
        if view is NSControl || view is KeyRecorderView {
            if (view.accessibilityLabel() ?? "").isEmpty { view.setAccessibilityLabel(title) }
            return
        }
        let first = view.subviews.first { sub in
            guard let control = sub as? NSControl else { return sub is KeyRecorderView }
            return (control as? NSTextField)?.isEditable ?? true
        }
        if let first { labelForAccessibility(first, title) }
    }

    /// `[swatch] [#hex] [↺]` for one editable color; ↺ only shows while the color is overridden.
    func colorRow(_ title: String, _ binding: ColorBinding) -> NSView {
        binding.field.widthAnchor.constraint(equalToConstant: Form.hexFieldWidth).isActive = true
        binding.field.placeholderString = binding.themeColor()?.uppercased() ?? "—"
        binding.field.font = .monospacedSystemFont(ofSize: 11.5, weight: .regular)
        binding.field.setAccessibilityLabel("\(title) hex")
        binding.well.setAccessibilityLabel("\(title) color")
        binding.well.toolTip = title
        binding.reset.setAccessibilityLabel("Use the theme's \(title.lowercased())")
        let resetSlot = NSView()
        resetSlot.translatesAutoresizingMaskIntoConstraints = false
        binding.reset.translatesAutoresizingMaskIntoConstraints = false
        resetSlot.addSubview(binding.reset)
        NSLayoutConstraint.activate([
            resetSlot.widthAnchor.constraint(equalToConstant: 20),
            resetSlot.heightAnchor.constraint(equalToConstant: 20),
            binding.reset.widthAnchor.constraint(equalToConstant: 18),
            binding.reset.heightAnchor.constraint(equalToConstant: 18),
            binding.reset.centerXAnchor.constraint(equalTo: resetSlot.centerXAnchor),
            binding.reset.centerYAnchor.constraint(equalTo: resetSlot.centerYAnchor),
        ])
        return SettingsFormRow(title: title, hint: nil, control: hstack([resetSlot, binding.field, binding.well], spacing: 8))
    }

    /// A rounded card of rows separated by inset hairlines, under an optional heading (with an
    /// optional trailing link) and over an optional footnote.
    func settingsGroup(
        _ title: String?, _ rows: [NSView], accessory: NSView? = nil, footer: String? = nil
    ) -> NSView {
        let group = SettingsGroupView()
        if title != nil || accessory != nil {
            let label = NSTextField(labelWithString: title ?? "")
            label.font = .systemFont(ofSize: 13, weight: .semibold)
            label.textColor = .labelColor
            label.setAccessibilityRole(.staticText)
            let header = hstack(accessory.map { [label, spacer(), $0] } ?? [label], spacing: 8)
            group.addArrangedSubview(header)
            group.setCustomSpacing(HarnessDesign.Spacing.md, after: header)
            header.leadingAnchor.constraint(equalTo: group.leadingAnchor, constant: 2).isActive = true
            header.trailingAnchor.constraint(equalTo: group.trailingAnchor, constant: -2).isActive = true
        }

        let surface = NSView()
        surface.wantsLayer = true
        surface.layer?.backgroundColor = HarnessChrome.current.surfaceElevated.cgColor
        surface.layer?.cornerRadius = HarnessDesign.Radius.card
        surface.layer?.cornerCurve = .continuous
        surface.layer?.borderWidth = 1
        surface.layer?.borderColor = HarnessChrome.current.border.cgColor
        surface.translatesAutoresizingMaskIntoConstraints = false
        groupSurfaces.append(surface)

        let rowStack = NSStackView()
        rowStack.orientation = .vertical
        rowStack.alignment = .width
        rowStack.spacing = 0
        rowStack.translatesAutoresizingMaskIntoConstraints = false
        for (index, content) in rows.enumerated() {
            let divider = index > 0 ? groupDivider() : nil
            if let divider { rowStack.addArrangedSubview(divider) }
            let wrapper = paddedRow(content)
            rowStack.addArrangedSubview(wrapper)
            group.track(row: content, wrapper: wrapper, divider: divider)
        }
        // A vertical stack only matches its children's widths to each other; pin each to the card.
        for view in rowStack.arrangedSubviews {
            view.leadingAnchor.constraint(equalTo: rowStack.leadingAnchor).isActive = true
            view.trailingAnchor.constraint(equalTo: rowStack.trailingAnchor).isActive = true
        }
        surface.addSubview(rowStack)
        group.addArrangedSubview(surface)
        NSLayoutConstraint.activate([
            rowStack.topAnchor.constraint(equalTo: surface.topAnchor, constant: 2),
            rowStack.leadingAnchor.constraint(equalTo: surface.leadingAnchor),
            rowStack.trailingAnchor.constraint(equalTo: surface.trailingAnchor),
            rowStack.bottomAnchor.constraint(equalTo: surface.bottomAnchor, constant: -2),
            surface.leadingAnchor.constraint(equalTo: group.leadingAnchor),
            surface.trailingAnchor.constraint(equalTo: group.trailingAnchor),
        ])

        if let footer {
            let note = caption(footer)
            group.setCustomSpacing(HarnessDesign.Spacing.sm, after: surface)
            group.addArrangedSubview(note)
            note.leadingAnchor.constraint(equalTo: group.leadingAnchor, constant: 2).isActive = true
            note.trailingAnchor.constraint(equalTo: group.trailingAnchor, constant: -2).isActive = true
        }
        return group
    }

    /// A button under the last group with a line saying what it does (Restore Defaults…).
    func settingsFooterAction(_ button: NSButton, caption text: String) -> NSView {
        let note = caption(text)
        note.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        let row = hstack([button, note], spacing: 12)
        row.alignment = .centerY
        return row
    }

    /// Uniform insets around one group row (content provides its own height).
    private func paddedRow(_ content: NSView) -> NSView {
        content.translatesAutoresizingMaskIntoConstraints = false
        let container = NSView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(content)
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: container.topAnchor, constant: Form.rowInsetY),
            content.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -Form.rowInsetY),
            content.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: Form.rowInsetX),
            content.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -Form.rowInsetX),
        ])
        return container
    }

    private func groupDivider() -> NSView {
        let wrap = NSView()
        wrap.translatesAutoresizingMaskIntoConstraints = false
        let line = NSView()
        line.wantsLayer = true
        line.layer?.backgroundColor = HarnessChrome.current.border.cgColor
        line.translatesAutoresizingMaskIntoConstraints = false
        groupDividers.append(line)
        wrap.addSubview(line)
        NSLayoutConstraint.activate([
            wrap.heightAnchor.constraint(equalToConstant: 1),
            line.topAnchor.constraint(equalTo: wrap.topAnchor),
            line.bottomAnchor.constraint(equalTo: wrap.bottomAnchor),
            line.leadingAnchor.constraint(equalTo: wrap.leadingAnchor, constant: Form.rowInsetX),
            line.trailingAnchor.constraint(equalTo: wrap.trailingAnchor, constant: -Form.rowInsetX),
        ])
        return wrap
    }

    /// Show or hide one row of a group, dividers included.
    func setRow(_ row: NSView?, hidden: Bool) {
        guard let row else { return }
        let group = sequence(first: row as NSView, next: { $0.superview }).first { $0 is SettingsGroupView } as? SettingsGroupView
        group?.setRow(row, hidden: hidden)
    }

    /// 16 ANSI swatches in two rows of eight that span the card, each over its index.
    func buildPaletteSection() -> NSView {
        func paletteRow(_ range: Range<Int>) -> NSStackView {
            let row = NSStackView(views: range.map(paletteCell))
            row.orientation = .horizontal
            row.distribution = .fillEqually
            row.spacing = HarnessDesign.Spacing.md
            row.alignment = .top
            return row
        }
        let note = caption("A light canvas uses the light theme's colors, so these follow the theme there.")
        paletteNote = note
        let group = NSStackView(views: [paletteRow(0 ..< 8), paletteRow(8 ..< 16), note])
        group.orientation = .vertical
        group.alignment = .width
        group.spacing = HarnessDesign.Spacing.lg
        for row in group.arrangedSubviews {
            row.leadingAnchor.constraint(equalTo: group.leadingAnchor).isActive = true
            row.trailingAnchor.constraint(equalTo: group.trailingAnchor).isActive = true
        }
        refreshPaletteWells()
        return group
    }

    private func paletteCell(_ index: Int) -> NSView {
        let label = NSTextField(labelWithString: "\(index)")
        label.font = .monospacedDigitSystemFont(ofSize: 10, weight: .regular)
        label.textColor = .secondaryLabelColor
        label.alignment = .center
        let cell = NSStackView(views: [paletteWells[index], label])
        cell.orientation = .vertical
        cell.spacing = HarnessDesign.Spacing.xs
        for part in cell.arrangedSubviews {
            part.leadingAnchor.constraint(equalTo: cell.leadingAnchor).isActive = true
            part.trailingAnchor.constraint(equalTo: cell.trailingAnchor).isActive = true
        }
        return cell
    }

    /// Wraps a page's content stack in a vertical scroll view so it remains reachable on
    /// shorter window heights.
    private func scrollWrap(_ content: NSStackView) -> NSView {
        let documentView = SettingsFlippedView()
        documentView.translatesAutoresizingMaskIntoConstraints = false
        documentView.addSubview(content)

        let scroll = NSScrollView()
        scroll.hasVerticalScroller = true
        scroll.autohidesScrollers = true
        scroll.drawsBackground = false
        scroll.backgroundColor = .clear
        scroll.contentView.drawsBackground = false
        documentView.wantsLayer = true
        documentView.layer?.backgroundColor = NSColor.clear.cgColor
        scroll.documentView = documentView
        scroll.translatesAutoresizingMaskIntoConstraints = false

        let fill = content.widthAnchor.constraint(equalTo: documentView.widthAnchor, constant: -2 * Form.pageInsetX)
        fill.priority = .defaultHigh
        NSLayoutConstraint.activate([
            documentView.topAnchor.constraint(equalTo: scroll.contentView.topAnchor),
            documentView.leadingAnchor.constraint(equalTo: scroll.contentView.leadingAnchor),
            documentView.trailingAnchor.constraint(equalTo: scroll.contentView.trailingAnchor),
            documentView.widthAnchor.constraint(equalTo: scroll.contentView.widthAnchor),

            content.topAnchor.constraint(equalTo: documentView.topAnchor, constant: Form.pageInsetTop),
            content.bottomAnchor.constraint(equalTo: documentView.bottomAnchor, constant: -Form.pageInsetBottom),
            content.centerXAnchor.constraint(equalTo: documentView.centerXAnchor),
            content.leadingAnchor.constraint(greaterThanOrEqualTo: documentView.leadingAnchor, constant: Form.pageInsetX),
            content.widthAnchor.constraint(lessThanOrEqualToConstant: Form.maxWidth),
            fill,
        ])
        return scroll
    }

    func sliderRow(_ slider: HarnessSlider, _ value: NSTextField) -> NSView {
        slider.widthAnchor.constraint(equalToConstant: Form.sliderWidth).isActive = true
        value.widthAnchor.constraint(equalToConstant: Form.sliderValueWidth).isActive = true
        return hstack([slider, value], spacing: 10)
    }

    func hstack(_ views: [NSView], spacing: CGFloat) -> NSStackView {
        let stack = NSStackView(views: views)
        stack.orientation = .horizontal
        stack.alignment = .centerY
        stack.spacing = spacing
        return stack
    }

    func spacer() -> NSView {
        let spacer = NSView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return spacer
    }

    func unitLabel(_ text: String) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabelColor
        return label
    }

    private func caption(_ text: String) -> NSTextField {
        let label = SettingsCaption(wrappingLabelWithString: text)
        label.font = .systemFont(ofSize: 11.5)
        label.textColor = .secondaryLabelColor
        label.isSelectable = false
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }

    private func makeResetButton() -> NSButton {
        let button = NSButton()
        button.bezelStyle = .shadowlessSquare
        button.image = NSImage(systemSymbolName: "arrow.uturn.backward.circle",
                               accessibilityDescription: "Use theme color")
        button.imagePosition = .imageOnly
        button.isBordered = false
        button.contentTintColor = .secondaryLabelColor
        button.target = self
        button.action = #selector(colorResetClicked(_:))
        button.toolTip = "Use the theme's color"
        return button
    }

    private func buildPaletteWells() {
        paletteWells.removeAll()
        for index in 0 ..< 16 {
            let well = HarnessSwatchWell(frame: .zero)
            well.translatesAutoresizingMaskIntoConstraints = false
            well.heightAnchor.constraint(equalToConstant: 28).isActive = true
            well.color = paletteColor(index)
            well.target = self
            well.action = #selector(paletteWellChanged(_:))
            well.toolTip = "\(index) \(Self.ansiNames[index])"
            well.setAccessibilityLabel("ANSI \(index), \(Self.ansiNames[index])")
            paletteWells.append(well)
        }
    }

    /// What the panes paint with no color edits, through the renderer's own resolution, so the
    /// swatches show the light theme in Light mode and the matching half under Auto.
    private static func themePreview() -> TerminalHostResolvedAppearance {
        var base = SessionCoordinator.shared.settings
        base.clearThemeColorOverrides()
        return TerminalHostView.resolvedNativeAppearance(
            themeName: SessionCoordinator.shared.snapshot.themeName,
            settings: base,
            systemAppearance: HarnessChrome.current.isDark ? .dark : .light
        )
    }

    private static func activeThemeName() -> String {
        let settings = SessionCoordinator.shared.settings
        return ThemeManager.activeThemeName(
            themeName: SessionCoordinator.shared.snapshot.themeName,
            appearanceMode: settings.appearanceMode,
            systemAppearance: HarnessChrome.current.isDark ? .dark : .light,
            systemLightThemeName: settings.systemLightThemeName,
            systemDarkThemeName: settings.systemDarkThemeName
        )
    }

    /// A light canvas paints the light theme's ANSI colors and ignores palette edits, so the
    /// swatches show those and stay read-only there.
    private var paletteIsEditable: Bool {
        HarnessChrome.current.isDark || SessionCoordinator.shared.settings.appearanceMode == .theme
    }

    /// The swatch for one ANSI slot: the edit if there is one, else what the panes paint.
    private func paletteColor(_ index: Int) -> NSColor {
        let hex = (paletteIsEditable ? paletteHexValues[index] : nil)
            ?? Self.themePreview().outputPaletteHex[index]
            ?? Self.defaultAnsiPalette[index]
        return NSColor.fromHex(hex) ?? .gray
    }

    func refreshPaletteWells() {
        let editable = paletteIsEditable
        for (index, well) in paletteWells.enumerated() {
            well.color = paletteColor(index)
            well.isEnabled = editable
        }
        paletteNote?.isHidden = editable
    }

    // MARK: - Formatting / utilities

    func formatPercent(_ value: Float) -> String {
        "\(Int((value * 100).rounded()))%"
    }

    func formatBlur(_ value: Int) -> String {
        value == 0 ? "Off" : "\(value) pt"
    }

    func cursorStyleTitle(_ value: String) -> String {
        switch value {
        case "bar": return "Beam"
        case "underline": return "Underline"
        default: return "Block"
        }
    }

    func cursorStyleValue(_ title: String?) -> String {
        switch title {
        case "Beam": return "bar"
        case "Underline": return "underline"
        default: return "block"
        }
    }

    func textRenderingTitle(_ value: TerminalTextRenderingMode) -> String {
        switch value {
        case .crisp: return "Crisp"
        case .soft: return "Soft"
        case .native: return "Native"
        }
    }

    func textRenderingValue(_ title: String?) -> TerminalTextRenderingMode {
        switch title {
        case "Crisp": return .crisp
        case "Soft": return .soft
        default: return .native
        }
    }

    /// Tri-state mapping for the optional Harness-controls override: Auto = `nil`
    /// (follow the experience mode), On/Off force `true`/`false`.
    func harnessControlsTitle(_ value: Bool?) -> String {
        switch value {
        case .some(true): return "On"
        case .some(false): return "Off"
        case .none: return "Auto"
        }
    }

    /// Tri-state segment title → `Bool?` override (Auto = nil). Shared by the prefix and status
    /// line segments since both map Auto/On/Off the same way.
    private func tristateOverride(from segment: HarnessSegmented) -> Bool? {
        switch segment.titleOfSelectedItem {
        case "On": return true
        case "Off": return false
        default: return nil
        }
    }

    var selectedPrefixEnabled: Bool? { tristateOverride(from: prefixControlSegment) }
    var selectedStatusLineEnabled: Bool? { tristateOverride(from: statusLineControlSegment) }

    /// The chosen family, set in itself so the row previews the font.
    func updateFontReadout() {
        let family = SessionCoordinator.shared.settings.fontFamily
        fontReadout.stringValue = family
        fontReadout.font = NSFont(name: family, size: 13) ?? .monospacedSystemFont(ofSize: 13, weight: .regular)
    }

    private static func experienceTitle(_ mode: ExperienceMode) -> String {
        switch mode {
        case .plain: return "Plain"
        case .persistent: return "Persistent"
        case .full: return "Full"
        case .agent: return "Agent"
        }
    }

    // MARK: - Font picker (Terminal page)

    @objc func chooseFont() {
        let current = NSFont(name: SessionCoordinator.shared.settings.fontFamily,
                             size: CGFloat(SessionCoordinator.shared.settings.fontSize))
            ?? .monospacedSystemFont(ofSize: CGFloat(SessionCoordinator.shared.settings.fontSize), weight: .regular)
        let fontManager = NSFontManager.shared
        fontManager.target = self
        fontManager.setSelectedFont(current, isMultiple: false)
        let panel = fontManager.fontPanel(true)
        panel?.makeKeyAndOrderFront(nil)
    }

    func changeFont(_ sender: NSFontManager?) {
        guard let manager = sender else { return }
        let base = NSFont(name: fontFamilyField.stringValue,
                          size: CGFloat(Float(fontSizeField.stringValue) ?? 14))
            ?? .monospacedSystemFont(ofSize: 14, weight: .regular)
        let converted = manager.convert(base)
        fontFamilyField.stringValue = converted.familyName ?? converted.fontName
        fontSizeField.stringValue = String(format: "%.0f", converted.pointSize)
        flushAndApply()
    }

    func validModesForFontPanel(_ fontPanel: NSFontPanel) -> NSFontPanel.ModeMask {
        [.collection, .face, .size]
    }

    func normalizedHexOrNil(_ raw: String) -> String? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let cleaned = trimmed.hasPrefix("#") ? String(trimmed.dropFirst()) : trimmed
        guard cleaned.count == 6,
              cleaned.allSatisfy({ $0.isHexDigit })
        else { return nil }
        return "#\(cleaned)"
    }

    @objc func openAgentsJSON() {
        let url = HarnessPaths.applicationSupport.appendingPathComponent("agents.json")
        if !FileManager.default.fileExists(atPath: url.path) {
            let defaults = AgentTable.default
            if let data = try? JSONEncoder().encode(defaults) {
                try? data.write(to: url, options: .atomic)
            }
        }
        NSWorkspace.shared.open(url)
    }

    /// Daemon-owned `OptionStore` values, fetched on page build. Keyed by option name.
    var advValues: [String: String] = [:]
    var advOptKeys: [ObjectIdentifier: (key: String, kind: AdvKind)] = [:]
    /// Whether the last `loadAdvancedValues` reached the daemon. False = the overlaid values are
    /// builtin defaults, NOT the live daemon state — so the page warns and disables its controls
    /// (a change couldn't be applied) instead of silently presenting defaults as if real.
    var advDaemonReachable = false
    var advLoading = false
    /// The daemon-backed controls (set-option surface), disabled when the daemon is unreachable.
    /// Excludes the performance toggles, which write local settings and stay usable offline.
    var advDaemonControls: [NSControl] = []
}

/// Settings opens as a standard, movable, closable macOS window on top of the main
/// window (not embedded). A fresh controller is built on each open so the window always
/// reflects the current theme/settings; any previously open instance is closed first.
@MainActor
enum SettingsWindowController {
    private static var window: NSWindow?
    /// Retained for the window's lifetime so its `windowWillClose` flush actually fires (NSWindow
    /// holds the delegate weakly). Closing the prior window drops the old proxy.
    private static var closeProxy: SettingsWindowCloseProxy?

    static func reloadIfOpen() {
        (window?.contentViewController as? SettingsViewController)?.adoptExternalSettingsWrite()
    }

    static func show(pane: SettingsPane = .appearance, search: String? = nil) {
        window?.close()
        let controller = SettingsViewController()
        controller.initialPane = pane
        controller.initialSearch = search
        let win = NSWindow(contentViewController: controller)
        win.title = "Settings"
        win.styleMask = [.titled, .closable, .resizable]
        win.titlebarAppearsTransparent = true
        win.titleVisibility = .visible
        win.backgroundColor = HarnessChrome.current.terminalBackground
        win.isMovableByWindowBackground = false
        win.isRestorable = false
        win.isReleasedWhenClosed = false
        win.minSize = NSSize(width: 840, height: 600)
        // Tab walks the controls top to bottom as laid out on the visible page.
        win.autorecalculatesKeyViewLoop = true
        win.setContentSize(NSSize(width: 940, height: 680))
        // Persist on close (incl. via the titlebar button) so a slider drag that never got its
        // mouse-up still saves its live-applied value (#89). Mirrors `viewWillDisappear`; both are
        // safe to fire because `persistPendingState` is idempotent.
        let proxy = SettingsWindowCloseProxy { [weak controller] in controller?.persistPendingState() }
        win.delegate = proxy
        closeProxy = proxy
        window = win
        // Match the active theme's light/dark so the native titlebar + any system-colored
        // text track the themed chrome (mirrors MainWindowController).
        win.appearance = NSAppearance(named: HarnessChrome.current.isDark ? .darkAqua : .aqua)
        win.center()
        win.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

/// Thin `NSWindowDelegate` that flushes the settings controller's pending state when the settings
/// window closes. Kept separate from the view controller so the controller doesn't have to be the
/// window's delegate (it isn't responsible for window lifecycle), and retained by
/// `SettingsWindowController` since NSWindow holds its delegate weakly.
@MainActor
final class SettingsWindowCloseProxy: NSObject, NSWindowDelegate {
    private let onWillClose: () -> Void
    init(onWillClose: @escaping () -> Void) { self.onWillClose = onWillClose }
    func windowWillClose(_ notification: Notification) { onWillClose() }
}

/// The Settings window's sidebar panes, in sidebar order.
enum SettingsPane: Int, CaseIterable {
    case appearance, colors, terminal, keys, notifications, agents, advanced, tools

    var title: String {
        switch self {
        case .appearance: return "Appearance"
        case .colors: return "Colors"
        case .terminal: return "Terminal"
        case .keys: return "Keys"
        case .notifications: return "Notifications"
        case .agents: return "Agents"
        case .advanced: return "Advanced"
        case .tools: return "Tools"
        }
    }

    var symbol: String {
        switch self {
        case .appearance: return "paintbrush"
        case .colors: return "paintpalette"
        case .terminal: return "terminal"
        case .keys: return "keyboard"
        case .notifications: return "bell.badge"
        case .agents: return "sparkles"
        case .advanced: return "slider.horizontal.3"
        case .tools: return "square.grid.2x2"
        }
    }

    /// Extra words the sidebar search matches besides the title.
    var keywords: [String] {
        switch self {
        case .appearance:
            return ["theme", "system", "macos", "opacity", "blur", "padding", "window", "transparent", "titlebar", "sidebar", "restore", "remember", "size"]
        case .colors:
            return ["color", "background", "foreground", "cursor", "selection", "palette", "ansi", "vivid", "ligatures", "divider", "status", "soft", "native", "crisp", "rendering", "gamma"]
        case .terminal:
            return ["font", "shell", "directory", "scrollback", "blink", "copy", "session", "harness", "controls", "experience"]
        case .keys:
            return ["prefix", "binding", "keybinding", "shortcut", "option", "meta", "alt", "compose", "accent", "esc"]
        case .notifications:
            return ["notify", "banner", "alert", "bell", "sound", "blocked", "failed", "error", "done", "finished", "permission"]
        case .agents:
            return ["agent", "icons", "codex", "claude", "cursor", "pi", "hermes", "openclaw", "hook", "detection"]
        case .tools:
            return ["search all sessions", "regex", "output", "overview", "board", "digest", "timeline", "resources", "resume", "ai summaries", "provider", "models", "schedules", "usage profiles", "power", "fan-out", "worktrees", "saved setups", "recently closed", "preview", "recordings", "export", "history", "privacy", "notification policy", "quiet hours", "hook policy", "plugins", "remote", "ssh", "phone", "ipad", "tmux", "import", "ghostty", "keybindings", "iterm2"]
        case .advanced:
            return ["options", "status", "mouse", "mode", "clipboard", "base-index", "renumber", "monitor", "rename", "repeat", "history", "pane", "border", "harness-cli", "set-option", "performance", "pipeline", "render", "identity", "term_program", "xtversion", "shift+enter", "kitty", "ghostty"]
        }
    }
}
