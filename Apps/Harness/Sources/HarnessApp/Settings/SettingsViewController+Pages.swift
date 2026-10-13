import AppKit
import HarnessCore
import HarnessTerminalKit
import HarnessTheme
import UniformTypeIdentifiers
import UserNotifications

extension SettingsViewController {
    // MARK: - Page: Appearance

    func buildAppearancePage() -> NSView {
        for popup in [themePopup, systemLightThemePopup, systemDarkThemePopup] {
            popup.widthAnchor.constraint(equalToConstant: Form.wideControlWidth).isActive = true
        }
        let modeRow = settingsRow("Appearance", appearanceModeSegment)
        let themeRow = settingsRow("Theme", themePopup)
        let lightRow = settingsRow("Light theme", systemLightThemePopup)
        let darkRow = settingsRow("Dark theme", systemDarkThemePopup)
        appearanceModeRow = modeRow
        self.themeRow = themeRow
        lightThemeRow = lightRow
        darkThemeRow = darkRow
        let previewRow = settingsRow("Live preview", specimenPreview,
                                     hint: "Prompt, operators, CJK, and the 16 ANSI colors.")
        let themeGroup = settingsGroup("Theme", [modeRow, themeRow, lightRow, darkRow, previewRow],
                                       accessory: revertAppearanceButton)

        let windowGroup = settingsGroup("Window", [
            settingsRow("Opacity", sliderRow(opacitySlider, opacityLabel)),
            settingsRow("Blur", sliderRow(blurSlider, blurLabel), hint: "Frosts the desktop behind the window."),
            settingsRow("Border", sliderRow(windowBorderOpacitySlider, windowBorderOpacityLabel),
                        hint: "A hairline around the window edge. 0% hides it."),
            settingsRow("Interface text size", chromeTextSizeSegment,
                        hint: "Larger labels in the sidebar, tab bar, status line, and Settings."),
            settingsRow("Transparent title bar", transparentTitlebarToggle),
            settingsRow("Show sidebar", sidebarVisibleToggle,
                        hint: "Sessions in a sidebar instead of tabs in the title bar. ⌘\\ switches."),
            settingsRow("Show machine indicator", machineIndicatorToggle,
                        hint: "Show this Mac or the remote host in the window controls."),
            settingsRow("Remember size and position", restoreWindowSizeToggle,
                        hint: "Reopen at your last size. When off, start at 100 columns × 30 rows."),
        ])

        paddingXField.widthAnchor.constraint(equalToConstant: Form.numberFieldWidth).isActive = true
        paddingYField.widthAnchor.constraint(equalToConstant: Form.numberFieldWidth).isActive = true
        paddingXField.setAccessibilityLabel("Horizontal padding")
        paddingYField.setAccessibilityLabel("Vertical padding")
        let paddingRow = hstack([paddingXField, unitLabel("×"), paddingYField, unitLabel("pt")], spacing: 6)
        paneSpacingField.widthAnchor.constraint(equalToConstant: Form.numberFieldWidth).isActive = true
        paneSpacingField.setAccessibilityLabel("Pane spacing")
        let panesGroup = settingsGroup("Panes", [
            settingsRow("Density", paneDensitySegment,
                        hint: "Comfortable sets panes apart as cards. Compact keeps them flush."),
            settingsRow("Pane spacing", hstack([paneSpacingField, unitLabel("pt")], spacing: 6),
                        hint: "Gap around and between panes. 0–24 pt; default \(Int(HarnessSettings.defaultPaneSpacing)). Comfortable only."),
            settingsRow("Pane headers", paneHeadersToggle,
                        hint: "Program, directory, and split buttons atop each pane. Comfortable only."),
            settingsRow("Single-pane header", singlePaneHeaderToggle,
                        hint: "Keep the pane header visible before a tab is split."),
            settingsRow("Padding", paddingRow, hint: "Space between the text and the pane edge."),
            settingsRow("Center the grid", paddingBalanceToggle,
                        hint: "Share leftover space evenly on every side."),
        ])

        let positionRow = settingsRow("Position", resizeOverlayPositionSegment)
        resizeOverlayPositionRow = positionRow
        let resizeGroup = settingsGroup("Resize", [
            settingsRow("Show size while resizing", resizeOverlaySegment,
                        hint: "After First skips the window opening."),
            positionRow,
        ])

        let restore = makeRoundedButton("Restore Defaults…", action: #selector(resetToDefaults))
        let footer = settingsFooterAction(restore, caption: "Resets appearance, colors, and font. Shell, keys, and agent settings stay.")

        return page("Appearance", [themeGroup, windowGroup, panesGroup, resizeGroup, footer])
    }

    // MARK: - Page: Colors

    func buildColorsPage() -> NSView {
        // colorBindings 0–6 are the terminal colors; 7–9 are the chrome accents. The
        // selected theme seeds every one; the user can then edit any swatch.
        let names = ["Background", "Foreground", "Cursor", "Text under cursor", "Selection", "Selected text", "Bold text"]
        let terminalGroup = settingsGroup(
            "Terminal",
            zip(names, colorBindings.prefix(7)).map { colorRow($0, $1) },
            footer: "An empty field uses the theme's color. ↺ puts one color back."
        )

        let resetPalette = makeLinkButton("Reset", action: #selector(SettingsViewController.resetPalette))
        resetPalette.setAccessibilityLabel("Reset ANSI palette")
        let paletteGroup = settingsGroup("ANSI palette", [buildPaletteSection()], accessory: resetPalette)

        let chromeGroup = settingsGroup("Window chrome", [
            colorRow("Dividers", colorBindings[7]),
            colorRow("Status line text", colorBindings[8]),
            colorRow("Window border", colorBindings[9]),
        ])

        let legibilityGroup = settingsGroup("Legibility", [
            settingsRow("Minimum contrast", sliderRow(minContrastSlider, minContrastLabel),
                        hint: "Lifts dim text to this contrast ratio."),
            settingsRow("Bold is bright", boldIsBrightToggle, hint: "Bold text in colors 0–7 uses 8–15."),
            settingsRow("Fit program colors to theme", themeFitToggle,
                        hint: "Nudges unreadable program colors toward the theme. On in light mode by default."),
            settingsRow("Recolor program output", themeTerminalOutputToggle,
                        hint: "Programs' ANSI colors take the theme's palette. Off keeps them as written."),
            settingsRow("Wide color (Display P3)", vividColorsToggle, hint: "Richer color on P3 displays."),
        ])

        return page("Colors", accessory: themeFileMenu(),
                    [terminalGroup, paletteGroup, chromeGroup, legibilityGroup])
    }

    /// Colors ▸ Theme ▾: keep the colors on screen as a named theme in the theme menu, write
    /// them to a `.harnesstheme` file to share, or drop every edit back to the theme's colors.
    private func themeFileMenu() -> NSPopUpButton {
        let menu = NSPopUpButton(frame: .zero, pullsDown: true)
        menu.bezelStyle = .rounded
        menu.addItem(withTitle: "Theme")
        for (title, action) in [("Save as Theme…", #selector(saveAsTheme)), ("Export Theme…", #selector(exportTheme))] {
            menu.addItem(withTitle: title)
            menu.lastItem?.target = self
            menu.lastItem?.action = action
        }
        menu.menu?.addItem(.separator())
        menu.addItem(withTitle: "Revert to Theme Colors")
        menu.lastItem?.target = self
        menu.lastItem?.action = #selector(useThemeColors)
        menu.setAccessibilityLabel("Theme actions")
        return menu
    }

    @objc private func saveAsTheme() {
        let alert = NSAlert()
        alert.messageText = "Save these colors as a theme"
        alert.informativeText = "It joins the theme menu and is saved in your themes folder."
        let field = NSTextField(frame: NSRect(x: 0, y: 0, width: 260, height: 24))
        field.placeholderString = "Theme name"
        alert.accessoryView = field
        alert.addButton(withTitle: "Save")
        alert.addButton(withTitle: "Cancel")
        alert.window.initialFirstResponder = field
        guard alert.runModal() == .alertFirstButtonReturn else { return }
        let name = field.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        do {
            try ThemeLibrary.saveCurrent(as: name)
            populateThemePopup(themePopup, selectedThemeName: name)
            Toast.show("Saved theme “\(name)”", in: view)
        } catch is ThemeLibrary.NameTaken {
            Toast.show("“\(name)” is a built-in theme; choose another name", in: view)
        } catch {
            Toast.show("Couldn't save the theme", in: view)
        }
    }

    @objc private func exportTheme() {
        let name = SessionCoordinator.shared.snapshot.themeName
        let panel = NSSavePanel()
        panel.nameFieldStringValue = ThemeFileService.fileName(for: name)
        panel.allowedContentTypes = [UTType(filenameExtension: ThemeDocument.fileExtension) ?? .json]
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            try ThemeLibrary.exportCurrent(to: url, named: url.deletingPathExtension().lastPathComponent)
            Toast.show("Exported \(url.lastPathComponent)", in: view)
        } catch {
            Toast.show("Couldn't export the theme", in: view)
        }
    }

    private func makeLinkButton(_ title: String, action: Selector) -> NSButton {
        let button = NSButton(title: title, target: self, action: action)
        styleAsLink(button)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        return button
    }

    private func makeRoundedButton(_ title: String, action: Selector) -> NSButton {
        let button = NSButton(title: title, target: self, action: action)
        button.bezelStyle = .rounded
        button.controlSize = .regular
        return button
    }

    func styleAsLink(_ button: NSButton) {
        button.bezelStyle = .accessoryBarAction
        button.isBordered = false
        // Use the shared neutral interface accent.
        let link = HarnessChrome.current.accent
        let attr = NSAttributedString(string: button.title, attributes: [
            .foregroundColor: link,
            .font: NSFont.systemFont(ofSize: 12, weight: .medium),
        ])
        button.attributedTitle = attr
        button.contentTintColor = link
        if !linkButtons.contains(where: { $0 === button }) { linkButtons.append(button) }
    }

    // MARK: - Page: Terminal

    func buildTerminalPage() -> NSView {
        // Experience mode: how much of Harness is exposed (controls + default session
        // persistence). It governs terminal behavior, so it lives here rather than under
        // Appearance. The summary updates live so the choice is self-explanatory.
        experienceSegment.setAccessibilityLabel("Experience")
        let experienceContent = NSView()
        for part in [experienceSegment, experienceSummaryLabel] as [NSView] {
            part.translatesAutoresizingMaskIntoConstraints = false
            experienceContent.addSubview(part)
            part.leadingAnchor.constraint(equalTo: experienceContent.leadingAnchor).isActive = true
            part.trailingAnchor.constraint(equalTo: experienceContent.trailingAnchor).isActive = true
        }
        NSLayoutConstraint.activate([
            experienceSegment.topAnchor.constraint(equalTo: experienceContent.topAnchor),
            experienceSummaryLabel.topAnchor.constraint(equalTo: experienceSegment.bottomAnchor, constant: HarnessDesign.Spacing.md),
            experienceSummaryLabel.bottomAnchor.constraint(equalTo: experienceContent.bottomAnchor),
        ])
        let experienceGroup = settingsGroup("Experience", [
            experienceContent,
            settingsRow("Command prefix", prefixControlSegment, hint: "Auto follows the experience."),
            settingsRow("Status line", statusLineControlSegment, hint: "Auto follows the experience."),
        ])

        let chooseFontButton = makeRoundedButton("Choose…", action: #selector(chooseFont))
        chooseFontButton.setAccessibilityLabel("Choose font")
        fontReadout.textColor = .labelColor
        fontReadout.lineBreakMode = .byTruncatingTail
        fontReadout.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        fontSizeField.widthAnchor.constraint(equalToConstant: Form.numberFieldWidth).isActive = true
        lineHeightField.widthAnchor.constraint(equalToConstant: Form.numberFieldWidth).isActive = true
        cellWidthField.widthAnchor.constraint(equalToConstant: Form.numberFieldWidth).isActive = true
        fontFallbackField.widthAnchor.constraint(equalToConstant: Form.wideControlWidth).isActive = true
        fontFeaturesField.widthAnchor.constraint(equalToConstant: Form.wideControlWidth).isActive = true
        fontFallbackField.placeholderString = "System defaults"
        fontFeaturesField.placeholderString = "Font defaults"
        let fontGroup = settingsGroup("Font", [
            settingsRow("Font", hstack([fontReadout, chooseFontButton], spacing: 10)),
            settingsRow("Size", hstack([fontSizeField, unitLabel("pt")], spacing: 6), hint: "8–32 pt. ⌘+ and ⌘− change it too."),
            settingsRow("Line height", hstack([lineHeightField, unitLabel("×")], spacing: 6),
                        hint: "0.80–1.60× natural cell height. Default 1.00."),
            settingsRow("Cell width", hstack([cellWidthField, unitLabel("×")], spacing: 6),
                        hint: "0.80–1.40× natural glyph advance. Default 1.00."),
            settingsRow("Text rendering", textRenderingSegment, hint: "Crisp draws glyphs lighter, Soft heavier."),
            settingsRow("Ligatures", ligaturesToggle, hint: "Joins => != -> in fonts that have them."),
            settingsRow("Fallback fonts", fontFallbackField, hint: "Comma-separated font families, in preferred order."),
            settingsRow("Font features", fontFeaturesField, hint: "OpenType settings, such as calt=0, ss01=1. "
                + "Blank uses font defaults."),
        ])

        let cursorGroup = settingsGroup("Cursor", [
            settingsRow("Style", cursorStyleSegment),
            settingsRow("Blink", cursorBlinkToggle),
        ])

        shellField.widthAnchor.constraint(equalToConstant: Form.wideControlWidth).isActive = true
        cwdField.widthAnchor.constraint(equalToConstant: Form.wideControlWidth).isActive = true
        let shellGroup = settingsGroup("Shell", [
            settingsRow("Shell", shellField),
            settingsRow("Start in", cwdField, hint: "The directory a new session opens in."),
            settingsRow("New tabs use the current directory", inheritCWDToggle,
                        hint: "Off opens every tab in the directory above."),
        ])

        scrollbackField.widthAnchor.constraint(equalToConstant: Form.wideNumberFieldWidth).isActive = true
        let scrollGroup = settingsGroup("Scrolling", [
            settingsRow("Scrollback", hstack([scrollbackField, unitLabel("lines")], spacing: 6),
                        hint: "0 removes the line cap. Decoded history and raw output each retain up to 512 MiB "
                            + "per pane."),
            settingsRow("Captured history", makeRoundedButton("History and Privacy…", action: #selector(openHistoryPrivacy)),
                        hint: "Host or pane capture, encryption status, and recovery. Layout is separate from captured text."),
            settingsRow("Scroll speed", sliderRow(scrollMultiplierSlider, scrollMultiplierLabel)),
        ])

        let inputGroup = settingsGroup("Input and output", [
            settingsRow("Copy on select", copyOnSelectToggle),
            settingsRow("Hide pointer while typing", mouseHideToggle),
            settingsRow("Bell", bellSegment, hint: "When a program rings the bell in the pane you're in."),
            settingsRow("Prompt marks", promptGutterToggle,
                        hint: "A green or red stripe beside each prompt for the last command. Needs shell "
                            + "integration."),
        ])

        let securityGroup = settingsGroup("Security", [
            settingsRow("Paste protection", pasteProtectionToggle,
                        hint: "Ask before pasting several lines or control characters."),
            settingsRow("Secure keyboard entry", secureKeyboardToggle,
                        hint: "Other apps can't read what you type while Harness is in front."),
            settingsRow("Remote control", remoteControlToggle,
                        hint: "Lets a client over an SSH tunnel run app actions. This Mac always can."),
        ])

        let defaultRow = settingsRow("Default terminal", defaultTerminalButton)
        defaultTerminalRow = defaultRow
        refreshDefaultTerminalStatus()
        let sessionsGroup = settingsGroup("Sessions", [
            settingsRow("Keep sessions running", keepSessionsToggle,
                        hint: "Sessions keep running after you quit, ready to reattach."),
            defaultRow,
        ])

        return page("Terminal", [experienceGroup, fontGroup, cursorGroup, shellGroup, scrollGroup,
                                 inputGroup, securityGroup, sessionsGroup])
    }

    // MARK: - Page: Keys

    func buildKeysPage() -> NSView {
        let keyboardGroup = settingsGroup("Keyboard", [
            settingsRow("Prefix key", keyRecorder, hint: "Click, then press a shortcut. Clear it to turn the prefix off."),
            settingsRow("Option key", optionKeySegment,
                        hint: "Characters types what your layout gives (@, é). Meta sends Esc+key for Emacs and readline."),
        ], footer: "The prefix is armed when Terminal ▸ Experience ▸ Command prefix allows it.")

        let quickTerminalGroup = settingsGroup("Quick terminal", [
            settingsRow("Quick terminal", quickTerminalToggle,
                        hint: "A terminal that drops from the top of the screen, over any app."),
            settingsRow("Hotkey", quickTerminalHotkeyRecorder),
        ])

        let editor = makeRoundedButton("Edit Key Bindings…", action: #selector(showKeyBindingsEditor))
        let editorFooter = settingsFooterAction(editor, caption: "Change, add, or reset prefix, no-prefix, and copy mode keys.")
        let shortcuts = makeRoundedButton("Keyboard Shortcuts…", action: #selector(showKeyboardShortcuts))
        let footer = settingsFooterAction(shortcuts, caption: "Every shortcut, menu key, and binding in one list (⌘/).")

        return page("Keys", [keyboardGroup, quickTerminalGroup, editorFooter, footer])
    }

    @objc private func showKeyBindingsEditor() {
        KeyBindingsEditorWindow.shared.show()
    }

    @objc private func showKeyboardShortcuts() {
        KeyboardShortcutsWindow.shared.toggle()
    }

    // MARK: - Page: Notifications

    func buildNotificationsPage() -> NSView {
        commandFinishedThresholdField.widthAnchor.constraint(equalToConstant: Form.numberFieldWidth).isActive = true
        // "Which events notify me" — one row per NotificationEvent, in enum order. The
        // command-finished row carries its runtime threshold as a sub-row. State/target are
        // wired in `configureControls` (the authoritative seed, so a flush can never clobber
        // settings with unseeded toggles); here we only lay out the rows.
        var eventRows: [NSView] = []
        for event in NotificationEvent.allCases {
            guard let toggle = eventToggles[event] else { continue }
            eventRows.append(settingsRow(event.title, toggle, hint: event.detail))
            if event == .commandFinished {
                eventRows.append(settingsRow("Threshold", hstack([commandFinishedThresholdField, unitLabel("seconds")], spacing: 6)))
            }
        }
        let notifyFooter = "Only for panes you aren't looking at. Several at once arrive as one notification."
        let notifyGroup = settingsGroup("Notify me when", eventRows, footer: notifyFooter)

        let statusRow = settingsRow("macOS permission", hstack([notificationTestButton, notificationPermissionButton], spacing: 8))
        notificationStatusRow = statusRow
        let deliveryGroup = settingsGroup("Delivery", [
            settingsRow("Show banners", systemNotificationsToggle),
            settingsRow("Play sound", notificationSoundToggle, hint: "Chimes even with banners off."),
            statusRow,
            settingsRow("Quiet hours and destinations",
                        makeRoundedButton("Configure Policy…", action: #selector(openNotificationPolicy)),
                        hint: "Opt-in external sinks, speech, content categories, quiet hours and delivery "
                            + "diagnostics."),
        ])
        refreshNotificationStatus()

        return page("Notifications", [notifyGroup, deliveryGroup])
    }

    @objc func sendTestNotification() {
        notificationStatusRow?.hint = "Requesting a test notification…"
        DesktopNotifier.sendTest { [weak self] message in
            self?.notificationStatusRow?.hint = message
        }
    }

    @objc private func openHistoryPrivacy() { SessionCoordinator.shared.presentHistoryPrivacy() }

    /// Toggling banners on is only meaningful if macOS is also allowing them. So when the user
    /// enables the setting, trigger the system permission prompt (or route to System Settings if
    /// already denied) — otherwise the toggle would silently produce nothing on a fresh install.
    @objc func systemNotificationsToggled() {
        flushAndApply()
        if systemNotificationsToggle.state == .on {
            DesktopNotifier.requestOrOpenSettings()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in self?.refreshNotificationStatus() }
    }

    @objc func openNotificationPermission() {
        DesktopNotifier.requestOrOpenSettings()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in self?.refreshNotificationStatus() }
    }

    /// Pull the live macOS permission state into the row so the user can tell whether the
    /// system is allowing alerts at all (the common reason agent notifications never appear).
    func refreshNotificationStatus() {
        DesktopNotifier.authorizationStatus { [weak self] status in
            guard let self else { return }
            let text: String
            let needsAllow: Bool
            switch status {
            case .authorized, .provisional:
                text = "Allowed."
                needsAllow = false
            case .denied:
                text = "macOS is blocking Harness notifications. Allow them in System Settings ▸ Notifications."
                needsAllow = true
            case .notDetermined:
                text = "Not asked yet. Send a test to grant it."
                needsAllow = false
            @unknown default:
                text = ""
                needsAllow = true
            }
            self.notificationStatusRow?.hint = text
            self.notificationPermissionButton.isHidden = !needsAllow
        }
    }

    // MARK: - Page: Tools

    func buildToolsPage() -> NSView {
        func group(_ title: String, _ items: [(String, String, Selector)]) -> NSView {
            settingsGroup(title, items.map { name, hint, action in
                let button = HarnessToolPage.button("Open…", target: self, action: action)
                button.setAccessibilityLabel("Open " + name)
                return settingsRow(name, button, hint: hint)
            })
        }
        return page("Tools", subtitle: "Open every workspace tool and configuration screen from here. Pane tools "
            + "use the selected terminal "
            + "and host.", [
            group("Activity and agents", [
                ("Overview and Board",
                 "Digest, tool timeline, resources, attention, and resume controls.",
                 #selector(openToolOverview)),
                ("Search all sessions", "Search retained terminal output with host, agent, time, and regex "
                    + "filters.", #selector(openToolSearch)),
                ("AI summaries", "Providers, model discovery, consent, and summary history.", #selector(openToolSummaries)),
                ("Schedules", "Agent schedules, definitions, and occurrence history.", #selector(openToolSchedules)),
                ("Usage profiles", "Provider profiles and approved transcript directories.", #selector(openActivityProfiles)),
                ("Power", "Working-agent sleep policy and temporary overrides.", #selector(openPowerSettings)),
            ]),
            group("Workspace", [
                ("Fan-out", "Launch a task across agents and compare their work.", #selector(openToolFanout)),
                ("Managed worktrees", "Create, inspect, compare, and clean up managed checkouts.", #selector(openToolWorktrees)),
                ("Saved setups", "Saved layouts and their startup suggestions.", #selector(openToolSetups)),
                ("Recently closed", "Review closed sessions and restore their layout.", #selector(openToolRecentlyClosed)),
                ("Preview panes", "Open a local development page beside the selected pane.", #selector(openToolPreview)),
                ("Recordings and export",
                 "Record output, review redactions, and export an asciicast.",
                 #selector(openToolRecordings)),
            ]),
            group("Privacy and connections", [
                ("History and privacy", "Capture choices, encryption status, and recovery.", #selector(openHistoryPrivacy)),
                ("Notification policy", "Quiet hours, speech, external destinations, and delivery "
                    + "status.", #selector(openNotificationPolicy)),
                ("Hook policy", "Trusted guardrails, hook installation, and redacted audit.", #selector(openToolHookPolicy)),
                ("Local plugins", "Review a local plugin before trusting its palette actions.", #selector(openToolPlugins)),
                ("Remote host", "Add an SSH host using existing credentials.", #selector(openToolRemote)),
                ("Phone or iPad", "Connection code for the private iOS companion.", #selector(openToolMobile)),
            ]),
            diagnosticsGroup(),
            group("Import", [
                ("tmux layouts", "Preview a layout and save it without acquiring existing PTYs.", #selector(openToolTmux)),
                ("Settings and keybindings",
                 "Review supported Ghostty settings and binding conflicts.",
                 #selector(openToolSettingsImport)),
                ("iTerm2 colors", "Preview and import a color preset.", #selector(openToolColorsImport)),
            ]),
        ])
    }

    @objc private func openToolSearch() { OutputSearchController.shared.present() }
    @objc private func openToolOverview() {
        // End the button's tracking loop before transferring focus to a borderless panel.
        let parent = view.window
        DispatchQueue.main.async { WorkspaceOverviewController.present(relativeTo: parent) }
    }
    @objc private func openToolSummaries() { SessionCoordinator.shared.presentAISummaries() }
    @objc private func openToolSchedules() { SessionCoordinator.shared.presentSchedules() }
    @objc private func openToolFanout() { SessionCoordinator.shared.presentFanout() }
    @objc private func openToolWorktrees() { SessionCoordinator.shared.presentManagedWorktrees() }
    @objc private func openToolSetups() { SessionLibraryController.shared.present() }
    @objc private func openToolRecentlyClosed() { SessionLibraryController.shared.present(recentlyClosed: true) }
    @objc private func openToolPreview() { SessionCoordinator.shared.presentPreview() }
    @objc private func openToolRecordings() { SessionCoordinator.shared.presentRecordings() }
    @objc private func openToolHookPolicy() { SessionCoordinator.shared.presentHookPolicy() }
    @objc private func openToolPlugins() { PluginTrustController.review(relativeTo: view.window) }
    @objc private func openToolRemote() { RemoteHostSheet.present() }
    private func diagnosticsGroup() -> NSView {
        let button = HarnessToolPage.button("Copy", target: self, action: #selector(copyDiagnosticsReport))
        button.setAccessibilityLabel("Copy diagnostics report")
        return settingsGroup("Support", [
            settingsRow("Diagnostics report", button,
                        hint: "Copies versions, counts, and appearance settings with your home folder and secrets masked. No terminal output."),
        ])
    }
    @objc private func copyDiagnosticsReport() { SessionCoordinator.shared.copyDiagnosticsReport() }
    @objc private func openToolMobile() { MobilePairingController.shared.present() }
    @objc private func openToolTmux() { SessionCoordinator.shared.presentTmuxImport() }
    @objc private func openToolSettingsImport() { SettingsImportController.present() }
    @objc private func openToolColorsImport() { ThemeImportController.presentITermImport() }

    // MARK: - Page: Agents

    func buildAgentsPage() -> NSView {
        let agentsGroup = settingsGroup(
            "Agents", Self.agentKinds.map(agentRow),
            footer: "Harness identifies these tools when you run them in a pane. Install each CLI separately. Where available, optional "
                + "hooks report when the agent stops or needs input; Harness backs up existing hook configuration before changing it."
        )

        let detectionGroup = settingsGroup("Setup", [
            settingsRow("Power", makeRoundedButton("Configure Power…", action: #selector(openPowerSettings)),
                        hint: "Keep working agents awake on AC power; battery use is off by default."),
            settingsRow("Usage profiles", makeRoundedButton("Configure Profiles…", action: #selector(openActivityProfiles)),
                        hint: "Name provider profiles and approve custom transcript roots without reading "
                            + "credentials."),
            settingsRow("Detection rules", makeRoundedButton("Edit agents.json…", action: #selector(openAgentsJSON)),
                        hint: "Which executables count as each agent."),
            settingsRow("Setup prompt", makeRoundedButton("Copy Prompt", action: #selector(copySetupPrompt)),
                        hint: "For a tool without one-click hooks: paste it into the agent and it wires up its "
                            + "own."),
        ])

        return page("Agents", [agentsGroup, detectionGroup])
    }

    @objc private func openNotificationPolicy() {
        if notificationPolicy == nil {
            let controller = NotificationPolicyWindowController()
            controller.onClose = { [weak self] in self?.notificationPolicy = nil; self?.syncAppearanceControlsFromSettings() }
            notificationPolicy = controller
        }
        notificationPolicy?.showWindow(nil)
    }

    @objc private func openPowerSettings() {
        if powerSettings == nil {
            let controller = PowerSettingsWindowController()
            controller.onClose = { [weak self] in self?.powerSettings = nil }
            powerSettings = controller
        }
        powerSettings?.showWindow(nil)
    }

    @objc private func openActivityProfiles() {
        if activityProfiles == nil {
            let controller = ActivityProfileWindowController()
            controller.onClose = { [weak self] in self?.activityProfiles = nil }
            activityProfiles = controller
        }
        activityProfiles?.showWindow(nil)
    }

    /// The same designed badge used by tabs, plus detection details and hook setup.
    private func agentRow(_ kind: AgentKind) -> NSView {
        let icon = IconTileView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.apply(.agent(kind))

        let name = NSTextField(labelWithString: kind.displayName)
        name.font = .systemFont(ofSize: 13)
        name.textColor = .labelColor
        let execs = NSTextField(labelWithString: executablesString(for: kind))
        execs.font = .monospacedSystemFont(ofSize: 10.5, weight: .regular)
        execs.textColor = .secondaryLabelColor
        execs.lineBreakMode = .byTruncatingTail
        execs.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        let textCol = NSStackView(views: [name, execs])
        textCol.orientation = .vertical
        textCol.alignment = .leading
        textCol.spacing = 1
        textCol.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let trailing = NSStackView()
        trailing.orientation = .horizontal
        trailing.alignment = .centerY
        trailing.spacing = 10
        trailing.setHuggingPriority(.required, for: .vertical)
        if AgentHookInstaller.canInstall(kind) {
            let health = AgentHookInstaller.health(agent: kind)
            let installed = health == .current || health == .outdated
            let title = health == .outdated ? "Update Hooks" : installed ? "Reinstall Hooks" : "Install Hooks"
            let button = NSButton(title: title, target: self, action: #selector(installHooksClicked(_:)))
            button.bezelStyle = .rounded
            button.controlSize = .small
            button.setAccessibilityLabel("\(installed ? "Reinstall" : "Install") \(kind.displayName) hooks")
            button.toolTip = health.rawValue
            hookButtons[kind] = button
            trailing.addArrangedSubview(button)
        }

        let row = NSStackView(views: [icon, textCol, spacer(), trailing])
        row.orientation = .horizontal
        row.alignment = .centerY
        row.spacing = 10
        return row
    }

    private func executablesString(for kind: AgentKind) -> String {
        let execs = AgentTable.default.entries.first { $0.kind == kind }?.executables ?? []
        return execs.isEmpty ? "—" : execs.joined(separator: ", ")
    }

    @objc private func copySetupPrompt() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(AgentHookInstaller.setupPrompt, forType: .string)
        Toast.show("Setup prompt copied — paste it into your agent", in: view)
    }

    @objc private func installHooksClicked(_ sender: NSButton) {
        guard let kind = hookButtons.first(where: { $0.value === sender })?.key else { return }
        sender.isEnabled = false
        Task { @MainActor [weak self, weak sender] in
            defer { sender?.isEnabled = true }
            let preparation = await Task.detached(priority: .userInitiated) { Result { try AgentHookInstaller.prepare(agent: kind) } }.value
            guard let self, let sender else { return }
            do {
                let proposal = try preparation.get()
                guard HookInstallationReview.approve(proposal) else { return }
                let installed = await Task.detached(priority: .userInitiated) { Result { try AgentHookInstaller.apply(proposal) } }.value
                let result = try installed.get()
                sender.title = "Reinstall Hooks"
                sender.toolTip = result.backedUp.map { "Backed up previous configuration to \($0.path)" } ?? result.path.path
                Toast.show(kind == .codex ? "Hooks configured — review approvals in Codex "
                    + "/hooks" : "Hooks configured — review the "
                    + "provider's trust prompts", in: self.view)
            } catch {
                let alert = NSAlert(); alert.messageText = "Hook configuration could not be installed"
                alert.informativeText = error.localizedDescription; alert.runModal()
            }
        }
    }

    // MARK: - Page: Advanced (harness-cli set-option surface)

    enum AdvKind { case toggle, segment, field }

    func buildAdvancedPage(refresh: Bool = true) -> NSView {
        advDaemonControls.removeAll() // repopulated by the adv* factories below
        // The adv* controls are rebuilt on every Advanced-page show, so the prior batch's identifiers
        // are stale (keyed by ObjectIdentifier of freed controls). Clear the map alongside the control
        // list, otherwise it grows unbounded across reopens.
        advOptKeys.removeAll()
        if refresh { loadAdvancedValues() }
        // The performance toggles are member controls (not rebuilt by the adv* factories), so unlike
        // the daemon-backed controls they don't get refreshed by `loadAdvancedValues`. Re-read their
        // state from settings here so a rebuilt page reflects changes made since the last build.
        let perfSettings = SessionCoordinator.shared.settings
        liveResizeReflowToggle.state = perfSettings.liveResizeReflow ? .on : .off

        let performanceGroup = settingsGroup("Performance", [
            settingsRow("Real-time resize", liveResizeReflowToggle,
                        hint: "Reflow the running program while you drag the window edge."),
        ], footer: "Disable this to defer reflow until the resize ends.")

        let statusGroup = settingsGroup("Status line", [
            settingsRow("Position", advSegment("status-position", ["bottom", "top"])),
            settingsRow("Left", advField("status-left", width: Form.wideControlWidth)),
            settingsRow("Right", advField("status-right", width: Form.wideControlWidth)),
        ], footer: "Format strings like #{cwd_basename}, #{git_branch}, #{time:%H:%M}. Show or hide it in Terminal ▸ Experience.")

        let inputGroup = settingsGroup("Input", [
            settingsRow("Mouse reporting", advToggle("mouse")),
            settingsRow("Copy-mode keys", advSegment("mode-keys", ["vi", "emacs"])),
            settingsRow("Word separators", advField("word-separators", width: Form.wideNumberFieldWidth),
                        hint: "Characters copy mode's w, b, and e stop at."),
            settingsRow("Programs can copy", advToggle("set-clipboard"), hint: "OSC 52 clipboard writes."),
            settingsRow("Programs can read the clipboard", advToggle("allow-clipboard-read"),
                        hint: "OSC 52 clipboard reads. Off by default."),
        ])

        let identityGroup = settingsGroup("Terminal identity", [
            settingsRow("Report as", advSegment(TerminalIdentity.optionKey, TerminalIdentity.Mode.allCases.map(\.rawValue))),
        ], footer: "What TERM_PROGRAM and XTVERSION say. Compatible lets tools like Claude Code turn on "
            + "Shift+Enter right away; Harness "
            + "reports its own name and version. Applies to new panes.")

        let indexGroup = settingsGroup("Numbering", [
            settingsRow("First window", advSegment("base-index", ["0", "1"])),
            settingsRow("First pane", advSegment("pane-base-index", ["0", "1"])),
            settingsRow("Renumber windows", advToggle("renumber-windows"), hint: "Close the gap when a window closes."),
        ])

        let titleGroup = settingsGroup("Titles and monitoring", [
            settingsRow("Programs set tab titles", advToggle("allow-rename")),
            settingsRow("Automatic rename", advToggle("automatic-rename"), hint: "Name tabs after the running program."),
            settingsRow("Monitor activity", advToggle("monitor-activity")),
            settingsRow("Monitor bell", advToggle("monitor-bell")),
            settingsRow("Silence alert",
                        hstack([advField("monitor-silence", width: Form.numberFieldWidth), unitLabel("seconds")], spacing: 6),
                        hint: "0 turns it off."),
        ])

        let lifecycleGroup = settingsGroup("Lifecycle", [
            settingsRow("Remain on exit", advToggle("remain-on-exit"), hint: "Keep a pane on screen after its program exits."),
            settingsRow("Shell integration", advToggle("shell-integration"),
                        hint: "Prompt, directory, and command tracking for shells in new panes."),
            settingsRow("Prefix repeat", hstack([advField("repeat-time", width: Form.numberFieldWidth), unitLabel("ms")], spacing: 6)),
            settingsRow("Hook shell timeout",
                        hstack([advField("hook-shell-timeout", width: Form.numberFieldWidth), unitLabel("seconds")], spacing: 6),
                        hint: "Maximum runtime for hook if-shell and background run-shell commands. 0 = no limit."),
            settingsRow("History limit",
                        hstack([advField("history-limit", width: Form.wideNumberFieldWidth), unitLabel("lines")], spacing: 6),
                        hint: "The session's scrollback. The window's own is in Terminal ▸ Scrolling."),
        ])

        let borderGroup = settingsGroup("Pane borders", [
            settingsRow("Labels", advSegment("pane-border-status", ["off", "top", "bottom"])),
            settingsRow("Format", advField("pane-border-format", width: Form.wideControlWidth)),
        ])

        // When the daemon is unreachable these groups show builtin defaults, NOT the live state, and
        // a change can't be applied — so disable the daemon-backed controls and warn inline at the
        // top. The performance toggles (local settings) stay usable. Re-checked each time the page is
        // shown (see `showPage`). The set-option surface depends on the daemon, so it's gated here.
        if !advDaemonReachable {
            for control in advDaemonControls { control.isEnabled = false }
        }
        var sections: [NSView] = advDaemonReachable ? [] : [advUnreachableBanner()]
        sections += [performanceGroup, statusGroup, inputGroup, identityGroup, indexGroup,
                     titleGroup, lifecycleGroup, borderGroup]
        return page("Advanced", subtitle: "Options shared with harness-cli set-option. Changes apply everywhere at once.", sections)
    }

    /// Inline warning shown atop the Advanced page when the daemon is unreachable: the controls
    /// below show builtin defaults, not live state, and edits can't be applied. Uses the chrome's
    /// danger color so it reads as a real warning, consistent with the rest of Settings.
    private func advUnreachableBanner() -> NSView {
        let c = HarnessChrome.current
        // The danger hue is tuned for dark canvases; on paper it needs more ink to read.
        let ink = c.isDark ? c.danger : (c.danger.blended(withFraction: 0.4, of: .black) ?? c.danger)
        let banner = NSView()
        banner.wantsLayer = true
        banner.layer?.cornerRadius = HarnessDesign.Radius.card
        banner.layer?.cornerCurve = .continuous
        banner.layer?.backgroundColor = c.danger.withAlphaComponent(0.12).cgColor
        banner.layer?.borderWidth = 1
        banner.layer?.borderColor = c.danger.withAlphaComponent(0.35).cgColor
        let label = NSTextField(wrappingLabelWithString:
            "The daemon isn't reachable. These are the defaults, and changes can't be applied until it's back.")
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = ink
        label.translatesAutoresizingMaskIntoConstraints = false
        banner.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: banner.leadingAnchor, constant: Form.rowInsetX),
            label.trailingAnchor.constraint(equalTo: banner.trailingAnchor, constant: -Form.rowInsetX),
            label.topAnchor.constraint(equalTo: banner.topAnchor, constant: 10),
            label.bottomAnchor.constraint(equalTo: banner.bottomAnchor, constant: -10),
        ])
        return banner
    }

    private func loadAdvancedValues() {
        guard !advLoading else { return }
        if advValues.isEmpty {
            for (key, value) in OptionStore.builtinDefaults { advValues[key] = value.stringValue }
        }
        advLoading = true
        SessionCoordinator.shared.requestDaemonAsync(.showOptions(scope: nil), refresh: false) { [weak self] response in
            guard let self else { return }
            self.advLoading = false
            if case let .options(entries)? = response {
                for entry in entries where entry.scope == "global" { self.advValues[entry.key] = entry.value }
                self.advDaemonReachable = true
            } else { self.advDaemonReachable = false }
            self.pages[.advanced] = self.buildAdvancedPage(refresh: false)
            if self.currentPane == .advanced { self.showPage(.advanced, refresh: false) }
        }
    }

    private func advToggle(_ key: String) -> HarnessToggle {
        let toggle = HarnessToggle(frame: .zero)
        let raw = (advValues[key] ?? "off").lowercased()
        toggle.state = (raw == "on" || raw == "true" || raw == "1") ? .on : .off
        toggle.target = self
        toggle.action = #selector(advChanged(_:))
        advOptKeys[ObjectIdentifier(toggle)] = (key, .toggle)
        advDaemonControls.append(toggle)
        return toggle
    }

    private func advSegment(_ key: String, _ values: [String]) -> HarnessSegmented {
        let segment = HarnessSegmented(frame: .zero)
        segment.setSegments(values.map { $0.capitalized })
        if let current = advValues[key] { segment.selectItem(withTitle: current.capitalized) }
        segment.target = self
        segment.action = #selector(advChanged(_:))
        advOptKeys[ObjectIdentifier(segment)] = (key, .segment)
        advDaemonControls.append(segment)
        return segment
    }

    private func advField(_ key: String, width: CGFloat) -> HarnessTextField {
        let field = HarnessTextField()
        field.stringValue = advValues[key] ?? ""
        field.font = .monospacedSystemFont(ofSize: 11.5, weight: .regular)
        field.widthAnchor.constraint(equalToConstant: width).isActive = true
        field.target = self
        field.action = #selector(advChanged(_:))
        advOptKeys[ObjectIdentifier(field)] = (key, .field)
        advDaemonControls.append(field)
        return field
    }

    @objc private func advChanged(_ sender: NSObject) {
        guard let entry = advOptKeys[ObjectIdentifier(sender)] else { return }
        let raw: String
        switch entry.kind {
        case .toggle: raw = (sender as? HarnessToggle)?.state == .on ? "on" : "off"
        case .segment: raw = (sender as? HarnessSegmented)?.titleOfSelectedItem?.lowercased() ?? ""
        case .field: raw = (sender as? NSTextField)?.stringValue ?? ""
        }
        setDaemonOption(key: entry.key, rawValue: raw)
    }

    private func setDaemonOption(key: String, rawValue: String) {
        SessionCoordinator.shared.requestDaemonAsync(DaemonSettingsControls.request(key: key, rawValue: rawValue))
        advValues[key] = rawValue
        HarnessOptions.reloadFromDisk()
        // Nudge the status line + chrome to re-read the new option value.
        NotificationCenter.default.post(
            name: NotificationBus.shared.snapshotChanged,
            object: nil,
            userInfo: ["revision": SessionCoordinator.shared.snapshot.revision,
                       "structureChanged": false,
                       "chromeChanged": false,
                       "metadataOnly": true]
        )
    }
}
