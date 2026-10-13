import AppKit
import HarnessCore
import HarnessTerminalKit
import HarnessTheme
import UniformTypeIdentifiers
import UserNotifications

extension SettingsViewController {
    // MARK: - Live apply

    // The four continuous sliders apply live on every drag tick but persist only once on commit
    // (`onCommit`, wired in setup), so scrubbing never spams a JSON encode + atomic write per frame.

    @objc func opacityDidChange() {
        opacityLabel.stringValue = formatPercent(Float(opacitySlider.doubleValue))
        applySettingsLive()
    }

    @objc func blurDidChange() {
        let rounded = Int(blurSlider.doubleValue.rounded())
        blurLabel.stringValue = formatBlur(rounded)
        applySettingsLive()
    }

    @objc func windowBorderOpacityDidChange() {
        windowBorderOpacityLabel.stringValue = formatPercent(Float(windowBorderOpacitySlider.doubleValue))
        applySettingsLive()
    }

    @objc func themeDidChange() {
        guard let theme = themePopup.titleOfSelectedItem else { return }
        // A theme is a starting preset: seed the full editable color set, then
        // mirror it into the controls so the user edits from the theme's values.
        SessionCoordinator.shared.setTheme(theme)
        syncAppearanceControlsFromSettings()
        refreshColorPlaceholders()
    }

    private func resizeOverlayTitle(_ mode: ResizeOverlayMode) -> String {
        switch mode {
        case .afterFirst: return "After First"
        case .always: return "Always"
        case .never: return "Never"
        }
    }

    private func resizeOverlayValue(_ title: String?) -> ResizeOverlayMode {
        switch title {
        case "Always": return .always
        case "Never": return .never
        default: return .afterFirst
        }
    }

    private func resizeOverlayPositionTitle(_ position: ResizeOverlayPosition) -> String {
        switch position {
        case .center: return "Center"
        case .topRight: return "Top Right"
        case .bottomRight: return "Bottom Right"
        }
    }

    private func resizeOverlayPositionValue(_ title: String?) -> ResizeOverlayPosition {
        switch title {
        case "Top Right": return .topRight
        case "Bottom Right": return .bottomRight
        default: return .center
        }
    }

    private func bellModeTitle(_ mode: BellMode) -> String {
        switch mode {
        case .off: return "Off"
        case .audible: return "Sound"
        case .visual: return "Flash"
        case .both: return "Both"
        }
    }

    private func bellModeValue(_ title: String?) -> BellMode {
        switch title {
        case "Off": return .off
        case "Sound": return .audible
        case "Both": return .both
        default: return .visual
        }
    }

    private func optionKeyTitle(_ mode: OptionAsMetaMode) -> String {
        switch mode {
        case .composed: return "Characters"
        case .meta: return "Meta"
        case .leftMetaOnly: return "Left Meta"
        case .rightMetaOnly: return "Right Meta"
        }
    }

    private func optionKeyValue(_ title: String?) -> OptionAsMetaMode {
        switch title {
        case "Meta": return .meta
        case "Left Meta": return .leftMetaOnly
        case "Right Meta": return .rightMetaOnly
        default: return .composed
        }
    }

    func updateMinContrastLabel() {
        let value = minContrastSlider.doubleValue
        minContrastLabel.stringValue = value <= 1.01 ? "Off" : String(format: "%.1f:1", value)
    }

    @objc func minContrastChanged() {
        updateMinContrastLabel()
        applySettingsLive()
    }

    func updateScrollMultiplierLabel() {
        let value = scrollMultiplierSlider.doubleValue
        scrollMultiplierLabel.stringValue = String(format: "%.1f×", value)
    }

    @objc func scrollMultiplierChanged() {
        updateScrollMultiplierLabel()
        applySettingsLive()
    }

    @objc func systemLightThemeDidChange() {
        guard let theme = systemLightThemePopup.titleOfSelectedItem else { return }
        let coordinator = SessionCoordinator.shared
        coordinator.settings.systemLightThemeName = theme
        coordinator.settings.clearThemeColorOverrides()
        saveSettings()
        coordinator.applySettingsToHosts()
        syncAppearanceControlsFromSettings()
        refreshColorPlaceholders()
    }

    @objc func systemDarkThemeDidChange() {
        guard let theme = systemDarkThemePopup.titleOfSelectedItem else { return }
        let coordinator = SessionCoordinator.shared
        coordinator.settings.systemDarkThemeName = theme
        coordinator.settings.clearThemeColorOverrides()
        saveSettings()
        coordinator.applySettingsToHosts()
        syncAppearanceControlsFromSettings()
        refreshColorPlaceholders()
    }

    /// Re-seed all colors from the currently selected theme, discarding manual
    /// edits ("Reset to theme").
    @objc func useThemeColors() {
        SessionCoordinator.shared.setTheme(SessionCoordinator.shared.snapshot.themeName)
        syncAppearanceControlsFromSettings()
        refreshColorPlaceholders()
    }

    @objc func toggleKeepSessions() {
        let keep = keepSessionsToggle.state == .on
        keepSessionsToggle.isEnabled = false
        SessionCoordinator.shared.requestDaemonAsync(.setKeepSessionsOnQuit(keep)) { [weak self] response in
            guard let self else { return }
            let effective = response == nil ? SessionCoordinator.shared.snapshot.keepSessionsOnQuit : keep
            self.keepSessionsToggle.isEnabled = true
            self.keepSessionsToggle.state = effective ? .on : .off
            let mode = SessionCoordinator.shared.settings.experienceMode
            self.experienceSummaryLabel.stringValue = mode.summary(keepSessionsOnQuit: effective)
        }
    }

    @objc func setDefaultTerminalClicked() {
        defaultTerminalButton.isEnabled = false
        defaultTerminalButton.title = "Setting…"
        Task { @MainActor in
            do {
                try await DefaultTerminalManager.setAsDefault()
                Toast.show("Harness is now the default terminal", in: view)
            } catch {
                Toast.show("Couldn't set default terminal", in: view)
            }
            refreshDefaultTerminalStatus()
        }
    }

    func refreshDefaultTerminalStatus() {
        let status = DefaultTerminalManager.status()
        defaultTerminalRow?.hint = status.summary
        defaultTerminalButton.title = status.isDefault ? "Default" : "Make Default"
        defaultTerminalButton.isEnabled = !status.isDefault
    }

    private var selectedAppearanceMode: HarnessAppearanceMode {
        let title = appearanceModeSegment.titleOfSelectedItem ?? ""
        return HarnessAppearanceMode.allCases.first { Self.appearanceModeTitle($0) == title } ?? .theme
    }

    /// Resolve the default and renamed presets to their current catalog names.
    private static func themeMenuName(_ name: String) -> String {
        name == ThemeManager.defaultDisplayName ? ThemeManager.defaultThemeName
            : HarnessThemeCatalog.theme(named: name)?.name ?? name
    }

    func populateThemePopup(_ popup: HarnessSelect, selectedThemeName: String) {
        popup.removeAllItems()
        popup.addItems(withTitles: ThemeManager.allThemeNames().filter { $0 != ThemeManager.defaultDisplayName })
        popup.featuredCount = ThemeManager.featuredThemes.count
        popup.searchPlaceholder = "Search themes"
        popup.selectItem(withTitle: Self.themeMenuName(selectedThemeName))
    }

    /// Show only the theme pickers the appearance mode uses: one theme for Theme, the light
    /// theme for Light, both halves for Auto.
    private func updateSystemThemePickerAvailability() {
        let mode = selectedAppearanceMode
        let followsSystem = mode == .macOSSystem
        setRow(themeRow, hidden: mode != .theme)
        setRow(lightThemeRow, hidden: mode == .theme)
        setRow(darkThemeRow, hidden: !followsSystem)
        systemLightThemePopup.isEnabled = mode != .theme
        systemDarkThemePopup.isEnabled = followsSystem
        switch mode {
        case .theme: appearanceModeRow?.hint = "One theme, light or dark, whatever macOS is set to."
        case .light: appearanceModeRow?.hint = "Always the light theme."
        case .macOSSystem: appearanceModeRow?.hint = "Switches between the light and dark theme with macOS."
        }
    }

    /// Rows whose control only means something given another setting dim or hide with it.
    func updateDependentRows() {
        updateSystemThemePickerAvailability()
        setRow(resizeOverlayPositionRow, hidden: resizeOverlaySegment.titleOfSelectedItem == "Never")
        let comfortable = paneDensitySegment.titleOfSelectedItem != "Compact"
        paneSpacingField.isEnabled = comfortable
        paneHeadersToggle.isEnabled = comfortable
        singlePaneHeaderToggle.isEnabled = comfortable && paneHeadersToggle.state == .on
        commandFinishedThresholdField.isEnabled = eventToggles[.commandFinished]?.state == .on
        quickTerminalHotkeyRecorder?.alphaValue = quickTerminalToggle.state == .on ? 1 : 0.45
    }

    private func syncSystemThemePickersFromSettings() {
        let settings = SessionCoordinator.shared.settings
        systemLightThemePopup.selectItem(withTitle: Self.themeMenuName(settings.systemLightThemeName))
        systemDarkThemePopup.selectItem(withTitle: Self.themeMenuName(settings.systemDarkThemeName))
    }

    /// Static (not instance) so tests can exercise the real seeding rule without
    /// instantiating the view controller.
    static func seedUnsetSystemThemeNames(settings: inout HarnessSettings, selectedThemeName: String) {
        if settings.systemLightThemeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            settings.systemLightThemeName = ThemeManager.defaultSystemLightThemeName
        }
        if settings.systemDarkThemeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           ThemeManager.allThemeNames().contains(selectedThemeName) {
            settings.systemDarkThemeName = selectedThemeName
        }
    }

    static func appearanceModeTitle(_ mode: HarnessAppearanceMode) -> String {
        switch mode {
        case .theme: return "Theme"
        case .light: return "Light"
        case .macOSSystem: return "Auto"
        }
    }

    /// The selected experience mode, derived from the segment position.
    private var selectedExperienceMode: ExperienceMode {
        let cases = ExperienceMode.allCases
        let i = experienceSegment.selectedSegment
        return cases.indices.contains(i) ? cases[i] : .plain
    }

    /// Switching mode re-gates the chrome (prefix + status line), sets the default
    /// session-persistence policy on the daemon, and refreshes the live surfaces — all on the
    /// one session core. `flushAndApply` persists the setting and posts the chrome-changed
    /// notification the status line + prefix react to.
    @objc func experienceModeChanged() {
        let mode = selectedExperienceMode
        experienceSummaryLabel.stringValue = mode.summary(keepSessionsOnQuit: mode.persistsSessionsByDefault)
        flushAndApply()
        PrefixKeymap.shared.rebuildFromSettings()
        // Mode sets the default persistence: Plain is ephemeral (a clean quit closes its
        // sessions), the others keep sessions running. The user can still override via the
        // "Keep sessions running" toggle. Mirror the snapshot truth into that toggle so the
        // two controls stay consistent while the window is open.
        let keep = mode.persistsSessionsByDefault
        keepSessionsToggle.isEnabled = false
        SessionCoordinator.shared.requestDaemonAsync(.setKeepSessionsOnQuit(keep)) { [weak self] response in
            guard let self else { return }
            let effective: Bool
            if case .ok? = response {
                AppDelegate.recordModePersistenceApplied(mode)
                effective = keep
            } else {
                effective = SessionCoordinator.shared.snapshot.keepSessionsOnQuit
            }
            self.keepSessionsToggle.isEnabled = true
            self.keepSessionsToggle.state = effective ? .on : .off
            self.experienceSummaryLabel.stringValue = self.selectedExperienceMode.summary(keepSessionsOnQuit: effective)
        }
    }

    /// The per-component prefix override re-gates the prefix key independently of the status line
    /// (and of the experience mode). Mirrors the chrome-refresh path of `experienceModeChanged`.
    @objc func prefixControlChanged() {
        SettingsEditor.applyFromWindow(\.prefixKeyEnabled, selectedPrefixEnabled, on: &SessionCoordinator.shared.settings)
        flushAndApply()
        PrefixKeymap.shared.rebuildFromSettings()
    }

    /// The per-component status-line override re-gates the bottom status band independently of the
    /// prefix. `flushAndApply` posts the chrome-changed notification `StatusLineView` reacts to.
    /// This one control owns the status line: Auto and On also clear the older `showStatusLine`
    /// switch, which used to sit on the Appearance page and hid the band on its own.
    @objc func statusLineControlChanged() {
        let choice = selectedStatusLineEnabled
        SettingsEditor.applyFromWindow(\.statusLineEnabled, choice, on: &SessionCoordinator.shared.settings)
        if choice != false {
            SettingsEditor.applyFromWindow(\.showStatusLine, true, on: &SessionCoordinator.shared.settings)
        }
        flushAndApply()
    }

    @objc func secureKeyboardChanged() {
        SessionCoordinator.shared.setSecureKeyboardEntry(secureKeyboardToggle.state == .on)
    }

    /// "Remember window size" applies to the live main window immediately, not just on the
    /// next launch: enabling it arms frame autosave (and snapshots the current frame so the
    /// very next quit/relaunch restores it); disabling it stops autosaving. Without this the
    /// toggle would appear to do nothing until two launches later. `MainWindowController.init`
    /// performs the launch-time restore using the same autosave name.
    @objc func restoreWindowSizeChanged() {
        flushAndApply()
        let enabled = restoreWindowSizeToggle.state == .on
        for window in NSApp.windows where window.contentViewController is MainSplitViewController {
            if enabled {
                window.setFrameAutosaveName(MainWindowController.frameAutosaveName)
                window.saveFrame(usingName: MainWindowController.frameAutosaveName)
            } else {
                // Empty name disables autosaving; the stored frame is ignored next launch
                // because `restoreWindowSize` is now false.
                window.setFrameAutosaveName("")
            }
        }
    }

    /// "Show sidebar" applies live to the main window's split (which also persists the
    /// setting), so the sidebar slides immediately rather than only on the next launch.
    @objc func sidebarVisibilityChanged() {
        let visible = sidebarVisibleToggle.state == .on
        for window in NSApp.windows {
            if let split = window.contentViewController as? MainSplitViewController {
                split.setSidebarVisible(visible, animated: true)
            }
        }
    }

    @objc func appearanceTextDidCommit() {
        flushAndApply()
        // A hex field that committed non-empty-but-invalid text wrote `nil` (drop to theme) into
        // settings, yet the field still shows the rejected red text. Re-sync every hex field to the
        // resolved on-disk state so the UI never silently disagrees with what was actually saved.
        resyncColorFieldsFromSettings()
        updateDependentRows()
    }

    /// Write each color field back from the resolved setting it produced, then refresh its swatch.
    /// Invalid input resolved to `nil` → the field clears (the override dropped to the theme); valid
    /// input round-trips to its normalized form. Keeps the form honest after a commit.
    private func resyncColorFieldsFromSettings() {
        let settings = SessionCoordinator.shared.settings
        for binding in colorBindings {
            let resolved = settings[keyPath: binding.keyPath] ?? ""
            if binding.field.stringValue != resolved {
                binding.field.stringValue = resolved
            }
            refreshColorBinding(binding)
        }
    }

    @objc private func appearanceTextDidChange(_ note: Notification) {
        guard let field = note.object as? NSTextField,
              let binding = colorBindings.first(where: { $0.field === field })
        else { return }
        refreshColorBinding(binding)
        let raw = field.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if raw.isEmpty || normalizedHexOrNil(raw) != nil {
            flushAndApply()
        }
    }

    func configureColorWell(_ well: HarnessSwatchWell) {
        well.target = self
        well.action = #selector(colorWellChanged(_:))
        well.translatesAutoresizingMaskIntoConstraints = false
        well.widthAnchor.constraint(equalToConstant: Form.swatchWidth).isActive = true
        well.heightAnchor.constraint(equalToConstant: Form.swatchHeight).isActive = true
    }

    @objc private func colorWellChanged(_ sender: HarnessSwatchWell) {
        guard let binding = colorBindings.first(where: { $0.well === sender }) else { return }
        binding.field.stringValue = hexString(sender.color)
        refreshColorBinding(binding)
        flushAndApply()
    }

    @objc func colorResetClicked(_ sender: NSButton) {
        guard let binding = colorBindings.first(where: { $0.reset === sender }) else { return }
        binding.field.stringValue = ""
        refreshColorBinding(binding)
        flushAndApply()
    }

    func refreshColorBinding(_ binding: ColorBinding) {
        validateHexField(binding.field)
        let hasOverride = normalizedHexOrNil(binding.field.stringValue) != nil
        let effective = normalizedHexOrNil(binding.field.stringValue) ?? binding.themeColor()
        binding.well.color = effective.flatMap(NSColor.fromHex) ?? HarnessChrome.current.terminalBackground
        binding.reset.isHidden = !hasOverride
    }

    func refreshColorPlaceholders() {
        for binding in colorBindings {
            binding.field.placeholderString = binding.themeColor()?.uppercased() ?? "—"
            refreshColorBinding(binding)
        }
        refreshPaletteWells()
    }

    @objc func paletteWellChanged(_ sender: HarnessSwatchWell) {
        guard let index = paletteWells.firstIndex(where: { $0 === sender }) else { return }
        paletteHexValues[index] = hexString(sender.color)
        flushAndApply()
    }

    /// Modal confirm for a destructive, instantly-applied reset. Mirrors the sidebar's delete/close
    /// alerts. Returns true only when the user explicitly confirms.
    private func confirmDestructive(message: String, info: String, confirmTitle: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = message
        alert.informativeText = info
        alert.alertStyle = .warning
        alert.addButton(withTitle: confirmTitle)
        alert.addButton(withTitle: "Cancel")
        return alert.runModal() == .alertFirstButtonReturn
    }

    @objc func resetPalette() {
        paletteHexValues = Array(repeating: nil, count: 16)
        refreshPaletteWells()
        flushAndApply()
    }

    /// Every control's state from the store: on open, after a theme change or reset, and when
    /// the command palette writes while this window is open.
    func syncAppearanceControlsFromSettings() {
        let settings = SessionCoordinator.shared.settings
        func on(_ value: Bool) -> NSControl.StateValue { value ? .on : .off }
        opacitySlider.doubleValue = Double(settings.backgroundOpacity)
        opacityLabel.stringValue = formatPercent(settings.backgroundOpacity)
        blurSlider.doubleValue = Double(settings.backgroundBlur)
        blurLabel.stringValue = formatBlur(settings.backgroundBlur)
        windowBorderOpacitySlider.doubleValue = Double(settings.windowBorderOpacity)
        windowBorderOpacityLabel.stringValue = formatPercent(settings.windowBorderOpacity)
        paneSpacingField.stringValue = String(format: "%.0f", settings.paneSpacing)
        paddingXField.stringValue = String(Int(settings.windowPaddingX.rounded()))
        paddingYField.stringValue = String(Int(settings.windowPaddingY.rounded()))
        fontFamilyField.stringValue = settings.fontFamily
        fontSizeField.stringValue = String(Int(settings.fontSize.rounded()))
        lineHeightField.stringValue = formatMultiplier(settings.lineHeight)
        cellWidthField.stringValue = formatMultiplier(settings.cellWidth)
        fontFallbackField.stringValue = settings.fontFallbackFamilies.joined(separator: ", ")
        fontFeaturesField.stringValue = settings.fontFeatures.sorted { $0.key < $1.key }
            .map { "\($0.key)=\($0.value)" }.joined(separator: ", ")
        fontFeaturesField.textColor = .labelColor
        fontFeaturesField.toolTip = nil
        updateFontReadout()
        shellField.stringValue = settings.defaultShell
        cwdField.stringValue = settings.defaultCWD
        scrollbackField.stringValue = String(settings.scrollbackLines)
        appearanceModeSegment.selectItem(withTitle: Self.appearanceModeTitle(settings.appearanceMode))
        syncSystemThemePickersFromSettings()
        experienceSegment.selectedSegment = ExperienceMode.allCases.firstIndex(of: settings.experienceMode) ?? 0
        let keepSessions = SessionCoordinator.shared.snapshot.keepSessionsOnQuit
        experienceSummaryLabel.stringValue = settings.experienceMode.summary(keepSessionsOnQuit: keepSessions)
        prefixControlSegment.selectItem(withTitle: harnessControlsTitle(settings.prefixKeyEnabled))
        // The older `showStatusLine` switch hides the band on its own; show that as Off here.
        statusLineControlSegment.selectItem(withTitle: settings.showStatusLine ? harnessControlsTitle(settings.statusLineEnabled) : "Off")
        cursorStyleSegment.selectItem(withTitle: cursorStyleTitle(settings.cursorStyle))
        cursorBlinkToggle.state = on(settings.cursorBlink)
        copyOnSelectToggle.state = on(settings.copyOnSelect)
        keepSessionsToggle.state = on(SessionCoordinator.shared.snapshot.keepSessionsOnQuit)
        vividColorsToggle.state = on(settings.colorRendering == .vivid)
        textRenderingSegment.selectItem(withTitle: textRenderingTitle(settings.textRendering))
        themeTerminalOutputToggle.state = on(settings.applyThemeToTerminalOutput)
        ligaturesToggle.state = on(settings.ligatures)
        promptGutterToggle.state = on(settings.showPromptGutter)
        liveResizeReflowToggle.state = on(settings.liveResizeReflow)
        resizeOverlaySegment.selectItem(withTitle: resizeOverlayTitle(settings.resizeOverlay))
        resizeOverlayPositionSegment.selectItem(withTitle: resizeOverlayPositionTitle(settings.resizeOverlayPosition))
        bellSegment.selectItem(withTitle: bellModeTitle(settings.bellMode))
        optionKeySegment.selectItem(withTitle: optionKeyTitle(settings.optionAsMeta))
        paddingBalanceToggle.state = on(settings.windowPaddingBalance)
        minContrastSlider.doubleValue = settings.minimumContrast
        updateMinContrastLabel()
        scrollMultiplierSlider.doubleValue = settings.scrollMultiplier
        updateScrollMultiplierLabel()
        mouseHideToggle.state = on(settings.mouseHideWhileTyping)
        quickTerminalToggle.state = on(settings.quickTerminalEnabled)
        pasteProtectionToggle.state = on(settings.pasteProtection)
        secureKeyboardToggle.state = on(settings.secureKeyboardEntry)
        remoteControlToggle.state = on(settings.remoteControl)
        inheritCWDToggle.state = on(settings.windowInheritCWD)
        boldIsBrightToggle.state = on(settings.boldIsBright)
        themeFitToggle.state = on(settings.effectiveThemeFit(appearanceIsLight: !HarnessChrome.current.isDark))
        paneDensitySegment.selectItem(withTitle: settings.paneDensity == .compact ? "Compact" : "Comfortable")
        paneHeadersToggle.state = on(settings.paneHeaders)
        singlePaneHeaderToggle.state = on(settings.singlePaneHeader)
        chromeTextSizeSegment.selectItem(withTitle: settings.chromeTextSize == .large ? "Large" : "Default")
        for (event, toggle) in eventToggles {
            toggle.state = on(settings.isEventEnabled(event))
        }
        commandFinishedThresholdField.stringValue = String(settings.commandFinishedThresholdSeconds)
        transparentTitlebarToggle.state = on(settings.transparentTitlebar)
        sidebarVisibleToggle.state = on(settings.sidebarVisible)
        machineIndicatorToggle.state = on(settings.showMachineIndicator)
        restoreWindowSizeToggle.state = on(settings.restoreWindowSize)
        systemNotificationsToggle.state = on(settings.systemNotificationsEnabled)
        notificationSoundToggle.state = on(settings.notificationSoundEnabled)
        for binding in colorBindings {
            binding.field.stringValue = settings[keyPath: binding.keyPath] ?? ""
            refreshColorBinding(binding)
        }
        paletteHexValues = HarnessSettings.normalizedPalette(settings.paletteHex)
        refreshPaletteWells()
        updateDependentRows()
        refreshSpecimenPreview()
    }

    func hexString(_ color: NSColor) -> String {
        guard let rgb = color.usingColorSpace(.sRGB) else { return "" }
        let r = Int((rgb.redComponent * 255).rounded())
        let g = Int((rgb.greenComponent * 255).rounded())
        let b = Int((rgb.blueComponent * 255).rounded())
        return String(format: "#%02X%02X%02X", r, g, b)
    }

    private func validateHexField(_ field: NSTextField) {
        let raw = field.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let valid = raw.isEmpty || normalizedHexOrNil(raw) != nil
        field.textColor = valid ? HarnessChrome.current.textPrimary : HarnessChrome.current.danger
    }

    @objc func resetToDefaults() {
        guard confirmDestructive(
            message: "Reset appearance to defaults?",
            info: "Colors, palette, font, padding, and other visual settings will be restored to their defaults. This can't be undone.",
            confirmTitle: "Reset"
        ) else { return }
        SessionCoordinator.shared.settings.resetToImportedConfig(imported: TerminalConfigImporter.load())
        syncAppearanceControlsFromSettings()
        flushAndApply()
    }

    func configureLiveAppearanceField(_ field: NSTextField) {
        field.target = self
        field.action = #selector(appearanceTextDidCommit)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appearanceTextDidChange(_:)),
            name: NSControl.textDidChangeNotification,
            object: field
        )
    }

    /// Single flush — push every field into HarnessSettings, save, and apply
    /// to the live terminal/window. Called from every control's action so the
    /// settings window behaves entirely live.
    func saveSettings() {
        do { try SessionCoordinator.shared.settings.save() }
        catch { DisplayMessage.show("Could not save settings.json: \(error.localizedDescription). Check disk space and permissions.") }
    }

    func flushAndApply() {
        applySettingsLive()
        saveSettings()
    }

    /// Settings window path into the shared writer. The palette calls `applyFromPalette`.
    private func write<T>(_ keyPath: WritableKeyPath<HarnessSettings, T>, _ value: T) {
        SettingsEditor.applyFromWindow(keyPath, value, on: &SessionCoordinator.shared.settings)
    }

    /// A palette write landed while this window is open. Pull the store back into the controls
    /// so the close-flush does not overwrite it with the old control values.
    func adoptExternalSettingsWrite() {
        syncAppearanceControlsFromSettings()
    }

    /// Push every field into HarnessSettings and apply it to the live surfaces, but DO NOT persist.
    /// Used on continuous slider drag ticks (60–120 Hz) so scrubbing never triggers a JSON encode +
    /// atomic write per tick; persistence happens once on the gesture's commit (`onCommit`). Every
    /// other control still goes through `flushAndApply`, which saves.
    private func applySettingsLive() {
        let coordinator = SessionCoordinator.shared
        write(\.backgroundOpacity, HarnessSettings.clampedOpacity(Float(opacitySlider.doubleValue)))
        write(\.backgroundBlur, HarnessSettings.clampedBlur(Int(blurSlider.doubleValue.rounded())))
        write(\.windowBorderOpacity, max(0, min(1, Float(windowBorderOpacitySlider.doubleValue))))
        // Read every editable color from its control (bg/fg/cursor/cursor-text/
        // selection/bold + divider/status accents). nil = fall back to theme preset.
        for binding in colorBindings {
            write(binding.keyPath, normalizedHexOrNil(binding.field.stringValue))
        }
        write(\.paletteHex, HarnessSettings.normalizedPalette(paletteHexValues))
        write(\.transparentTitlebar, transparentTitlebarToggle.state == .on)
        write(\.sidebarVisible, sidebarVisibleToggle.state == .on)
        write(\.showMachineIndicator, machineIndicatorToggle.state == .on)
        write(\.restoreWindowSize, restoreWindowSizeToggle.state == .on)
        write(\.paneSpacing, HarnessSettings.clampedPaneSpacing(Double(paneSpacingField.stringValue) ?? 4))
        write(\.windowPaddingX, HarnessSettings.clampedPadding(Float(paddingXField.stringValue) ?? 12))
        write(\.windowPaddingY, HarnessSettings.clampedPadding(Float(paddingYField.stringValue) ?? 12))
        let previousAppearanceMode = coordinator.settings.appearanceMode
        let nextAppearanceMode = selectedAppearanceMode
        write(\.appearanceMode, nextAppearanceMode)
        if previousAppearanceMode != nextAppearanceMode {
            coordinator.settings.clearThemeColorOverrides()
            paletteHexValues = HarnessSettings.normalizedPalette(coordinator.settings.paletteHex)
            for binding in colorBindings {
                binding.field.stringValue = ""
                refreshColorBinding(binding)
            }
        }
        if previousAppearanceMode != .macOSSystem && nextAppearanceMode == .macOSSystem {
            Self.seedUnsetSystemThemeNames(settings: &coordinator.settings, selectedThemeName: coordinator.snapshot.themeName)
            syncSystemThemePickersFromSettings()
        }
        if previousAppearanceMode != .light && nextAppearanceMode == .light {
            Self.seedUnsetSystemThemeNames(settings: &coordinator.settings, selectedThemeName: coordinator.snapshot.themeName)
            syncSystemThemePickersFromSettings()
        }
        write(\.fontSize, HarnessSettings.clampedFontSize(Float(fontSizeField.stringValue) ?? 14))
        write(\.lineHeight, HarnessSettings.clampedLineHeight(Float(lineHeightField.stringValue) ?? 1))
        write(\.cellWidth, HarnessSettings.clampedCellWidth(Float(cellWidthField.stringValue) ?? 1))
        write(\.fontFamily, fontFamilyField.stringValue)
        write(\.fontFallbackFamilies, fontFallbackField.stringValue.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty })
        if let features = HarnessSettings.parseFontFeatures(fontFeaturesField.stringValue) {
            write(\.fontFeatures, features)
            fontFeaturesField.textColor = .labelColor
            fontFeaturesField.toolTip = nil
        } else {
            fontFeaturesField.textColor = .systemRed
            fontFeaturesField.toolTip = "Use four-character tags and nonnegative numbers, for example calt=0, ss01=1."
        }
        write(\.defaultShell, shellField.stringValue)
        write(\.defaultCWD, cwdField.stringValue)
        write(\.windowInheritCWD, inheritCWDToggle.state == .on)
        // `0` is the unlimited sentinel (kept verbatim); any other value is floored at 100 lines.
        let enteredScrollback = Int(scrollbackField.stringValue) ?? 10_000
        write(\.scrollbackLines, enteredScrollback == 0 ? 0 : max(100, enteredScrollback))
        write(\.cursorStyle, cursorStyleValue(cursorStyleSegment.titleOfSelectedItem))
        write(\.cursorBlink, cursorBlinkToggle.state == .on)
        write(\.copyOnSelect, copyOnSelectToggle.state == .on)
        write(\.systemNotificationsEnabled, systemNotificationsToggle.state == .on)
        write(\.notificationSoundEnabled, notificationSoundToggle.state == .on)
        write(\.colorRendering, vividColorsToggle.state == .on ? .vivid : .accurate)
        write(\.textRendering, textRenderingValue(textRenderingSegment.titleOfSelectedItem))
        write(\.applyThemeToTerminalOutput, themeTerminalOutputToggle.state == .on)
        write(\.ligatures, ligaturesToggle.state == .on)
        write(\.showPromptGutter, promptGutterToggle.state == .on)
        write(\.liveResizeReflow, liveResizeReflowToggle.state == .on)
        write(\.resizeOverlay, resizeOverlayValue(resizeOverlaySegment.titleOfSelectedItem))
        write(\.resizeOverlayPosition, resizeOverlayPositionValue(resizeOverlayPositionSegment.titleOfSelectedItem))
        write(\.bellMode, bellModeValue(bellSegment.titleOfSelectedItem))
        write(\.scrollMultiplier, HarnessSettings.clampedScrollMultiplier(scrollMultiplierSlider.doubleValue))
        write(\.mouseHideWhileTyping, mouseHideToggle.state == .on)
        write(\.optionAsMeta, optionKeyValue(optionKeySegment.titleOfSelectedItem))
        write(\.quickTerminalEnabled, quickTerminalToggle.state == .on)
        write(\.windowPaddingBalance, paddingBalanceToggle.state == .on)
        write(\.minimumContrast, HarnessSettings.clampedContrast(minContrastSlider.doubleValue))
        write(\.pasteProtection, pasteProtectionToggle.state == .on)
        write(\.remoteControl, remoteControlToggle.state == .on)
        write(\.boldIsBright, boldIsBrightToggle.state == .on)
        write(\.themeFit, ThemeFitPolicy.stored(
            toggleOn: themeFitToggle.state == .on,
            appearanceIsLight: !HarnessChrome.current.isDark
        ))
        write(\.paneDensity, paneDensitySegment.titleOfSelectedItem == "Compact" ? .compact : .comfortable)
        write(\.paneHeaders, paneHeadersToggle.state == .on)
        write(\.singlePaneHeader, singlePaneHeaderToggle.state == .on)
        write(\.chromeTextSize, chromeTextSizeSegment.titleOfSelectedItem == "Large" ? .large : .regular)
        for (event, toggle) in eventToggles {
            SettingsEditor.setEvent(event, toggle.state == .on, on: &coordinator.settings)
        }
        write(\.commandFinishedThresholdSeconds, max(1, Int(commandFinishedThresholdField.stringValue) ?? 10))
        // Reflect every clamped numeric field back into the UI so typing an out-of-range value
        // (fontSize "2", threshold "0", …) doesn't leave the field showing one number while the
        // setting — and the live terminals — silently use the clamped one. Non-numeric entries
        // reset to the persisted value the same way.
        reflectClamped(commandFinishedThresholdField, String(coordinator.settings.commandFinishedThresholdSeconds))
        reflectClamped(fontSizeField, String(format: "%.0f", coordinator.settings.fontSize))
        reflectClamped(lineHeightField, formatMultiplier(coordinator.settings.lineHeight))
        reflectClamped(cellWidthField, formatMultiplier(coordinator.settings.cellWidth))
        reflectClamped(paneSpacingField, String(format: "%.0f", coordinator.settings.paneSpacing))
        reflectClamped(paddingXField, String(format: "%.0f", coordinator.settings.windowPaddingX))
        reflectClamped(paddingYField, String(format: "%.0f", coordinator.settings.windowPaddingY))
        reflectClamped(scrollbackField, String(coordinator.settings.scrollbackLines))
        write(\.experienceMode, selectedExperienceMode)

        // Theme switching (and its color seeding) is handled by themeDidChange, so this only ever
        // pushes the current settings to the live surfaces — scrubbing a slider never fires a
        // setTheme IPC. Persistence is the caller's job (`flushAndApply` saves; drag ticks don't).
        coordinator.applySettingsToHosts()
        QuickTerminalController.shared.rebuildFromSettings()
        updateFontReadout()
        refreshSpecimenPreview()
        // An appearance flip changes which theme the panes paint; re-preview it.
        if previousAppearanceMode != nextAppearanceMode {
            refreshColorPlaceholders()
            refreshPaletteWells()
        }
    }

    func refreshSpecimenPreview() {
        let coordinator = SessionCoordinator.shared
        let systemAppearance: HarnessSystemAppearance = HarnessChrome.current.isDark ? .dark : .light
        specimenPreview.update(
            themeName: coordinator.snapshot.themeName,
            settings: coordinator.settings,
            systemAppearance: systemAppearance
        )
        revertAppearanceButton.isEnabled =
            coordinator.settings != initialSettingsSnapshot
            || coordinator.snapshot.themeName != initialThemeSnapshot
    }

    /// Restore the theme and appearance settings captured when the Settings window opened.
    @objc func revertAppearanceChanges() {
        let coordinator = SessionCoordinator.shared
        if !initialThemeSnapshot.isEmpty, coordinator.snapshot.themeName != initialThemeSnapshot {
            coordinator.setTheme(initialThemeSnapshot)
        }
        coordinator.settings = initialSettingsSnapshot
        saveSettings()
        coordinator.applySettingsToHosts()
        QuickTerminalController.shared.rebuildFromSettings()
        PrefixKeymap.shared.rebuildFromSettings()
        populateThemePopup(themePopup, selectedThemeName: coordinator.snapshot.themeName)
        syncAppearanceControlsFromSettings()
        refreshColorPlaceholders()
    }

    /// Rewrite a numeric field only when its committed text differs from the clamped setting —
    /// the UI must never show a value the terminals aren't actually using.
    private func reflectClamped(_ field: NSTextField, _ clamped: String) {
        if field.stringValue != clamped { field.stringValue = clamped }
    }

    /// Safety net for the apply-only/persist-on-commit split (#89): continuous sliders apply live on
    /// every drag tick but only persist in `HarnessSlider.mouseUp → onCommit`. If a drag never gets
    /// its mouse-up (window closed programmatically mid-drag, a modal steals the gesture, the app
    /// deactivates mid-track), the live-applied value would never be saved. Flushing on teardown
    /// guarantees the visible state is the persisted state. `flushAndApply` is idempotent (read
    /// controls → settings → save), so a redundant call after a normal commit is harmless.
    func persistPendingState() {
        flushAndApply()
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()
        persistPendingState()
    }
}
