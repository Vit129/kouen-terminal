import AppKit
import HarnessCore

@MainActor
enum MainMenuBuilder {
    /// Create an NSMenuItem from a registry Keybinding.
    private static func menuItem(_ title: String, action: Selector, binding: Keybinding) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: binding.keyChar)
        item.keyEquivalentModifierMask = binding.modifiers.modifierFlags
        item.target = MenuTarget.shared
        return item
    }

    static func build() -> NSMenu {
        let main = NSMenu()

        let app = NSMenuItem()
        app.submenu = NSMenu(title: "Harness")
        let aboutItem = NSMenuItem(title: "About Harness", action: #selector(MenuTarget.showAbout), keyEquivalent: "")
        aboutItem.target = MenuTarget.shared
        app.submenu?.addItem(aboutItem)
        app.submenu?.addItem(.separator())
        let checkUpdates = NSMenuItem(title: "Check for Updates…", action: SparkleUpdater.checkForUpdatesAction, keyEquivalent: "")
        checkUpdates.target = SparkleUpdater.shared.controller
        app.submenu?.addItem(checkUpdates)
        app.submenu?.addItem(.separator())
        let installItem = NSMenuItem(title: "Install harness-cli…", action: #selector(MenuTarget.installCLI), keyEquivalent: "")
        installItem.target = MenuTarget.shared
        app.submenu?.addItem(installItem)
        app.submenu?.addItem(.separator())
        let prefs = NSMenuItem(title: "Settings…", action: #selector(MenuTarget.openSettings), keyEquivalent: ",")
        prefs.target = MenuTarget.shared
        app.submenu?.addItem(prefs)
        app.submenu?.addItem(.separator())
        let hide = NSMenuItem(title: "Hide Harness", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h")
        app.submenu?.addItem(hide)
        let hideOthers = NSMenuItem(title: "Hide Others", action: #selector(NSApplication.hideOtherApplications(_:)), keyEquivalent: "h")
        hideOthers.keyEquivalentModifierMask = [.command, .option]
        app.submenu?.addItem(hideOthers)
        app.submenu?.addItem(NSMenuItem(title: "Show All", action: #selector(NSApplication.unhideAllApplications(_:)), keyEquivalent: ""))
        app.submenu?.addItem(.separator())
        app.submenu?.addItem(NSMenuItem(title: "Quit Harness", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        main.addItem(app)

        // Edit — standard responder-chain actions so Copy/Paste/Select All work in
        // the focused terminal (and any text field). Target nil routes through the
        // responder chain to whichever view is first responder.
        let edit = NSMenuItem()
        edit.submenu = NSMenu(title: "Edit")
        edit.submenu?.addItem(NSMenuItem(title: "Undo", action: Selector(("undo:")), keyEquivalent: "z"))
        let redo = NSMenuItem(title: "Redo", action: Selector(("redo:")), keyEquivalent: "z")
        redo.keyEquivalentModifierMask = [.command, .shift]
        edit.submenu?.addItem(redo)
        edit.submenu?.addItem(.separator())
        edit.submenu?.addItem(NSMenuItem(title: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x"))
        edit.submenu?.addItem(NSMenuItem(title: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c"))
        edit.submenu?.addItem(NSMenuItem(title: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v"))
        edit.submenu?.addItem(NSMenuItem(title: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a"))
        main.addItem(edit)

        let workspace = NSMenuItem()
        workspace.submenu = NSMenu(title: "Session")
        let newSessionItem = menuItem("New Session", action: #selector(MenuTarget.newSession), binding: BannerShortcutRegistry.newSession)
        workspace.submenu?.addItem(newSessionItem)
        let closeTab = menuItem("Close Tab", action: #selector(MenuTarget.closeTab), binding: BannerShortcutRegistry.closeTab)
        workspace.submenu?.addItem(closeTab)
        let closeSession = NSMenuItem(title: "Close Session", action: #selector(MenuTarget.closeSession), keyEquivalent: "")
        closeSession.target = MenuTarget.shared
        workspace.submenu?.addItem(closeSession)
        workspace.submenu?.addItem(.separator())
        for index in 1...9 {
            let item = NSMenuItem(
                title: "Switch to Session \(index)",
                action: #selector(MenuTarget.selectWorkspaceNumber(_:)),
                keyEquivalent: "\(index)"
            )
            item.tag = index
            item.target = MenuTarget.shared
            workspace.submenu?.addItem(item)
        }
        let prevSession = menuItem("Previous Session", action: #selector(MenuTarget.previousSession), binding: BannerShortcutRegistry.previousSession)
        workspace.submenu?.addItem(prevSession)
        let nextSession = menuItem("Next Session", action: #selector(MenuTarget.nextSession), binding: BannerShortcutRegistry.nextSession)
        workspace.submenu?.addItem(nextSession)
        workspace.submenu?.addItem(.separator())
        let moveSessionLeft = menuItem("Move Session Left", action: #selector(MenuTarget.moveSessionLeft), binding: BannerShortcutRegistry.moveSessionLeft)
        workspace.submenu?.addItem(moveSessionLeft)
        let moveSessionRight = menuItem("Move Session Right", action: #selector(MenuTarget.moveSessionRight), binding: BannerShortcutRegistry.moveSessionRight)
        workspace.submenu?.addItem(moveSessionRight)
        main.addItem(workspace)

        let view = NSMenuItem()
        view.submenu = NSMenu(title: "View")
        let splitHItem = menuItem("Split Right", action: #selector(MenuTarget.splitH), binding: BannerShortcutRegistry.splitRight)
        view.submenu?.addItem(splitHItem)

        let splitVItem = menuItem("Split Down", action: #selector(MenuTarget.splitV), binding: BannerShortcutRegistry.splitDown)
        view.submenu?.addItem(splitVItem)
        view.submenu?.addItem(.separator())

        let prevPane = menuItem("Previous Pane", action: #selector(MenuTarget.previousPane), binding: BannerShortcutRegistry.previousPane)
        view.submenu?.addItem(prevPane)
        let nextPane = menuItem("Next Pane", action: #selector(MenuTarget.nextPane), binding: BannerShortcutRegistry.nextPane)
        view.submenu?.addItem(nextPane)
        view.submenu?.addItem(.separator())

        let focusLeft = NSMenuItem(title: "Focus Pane Left", action: #selector(MenuTarget.focusPaneLeft), keyEquivalent: "\u{F702}")
        focusLeft.keyEquivalentModifierMask = [.command, .shift]
        focusLeft.target = MenuTarget.shared
        view.submenu?.addItem(focusLeft)
        let focusRight = NSMenuItem(title: "Focus Pane Right", action: #selector(MenuTarget.focusPaneRight), keyEquivalent: "\u{F703}")
        focusRight.keyEquivalentModifierMask = [.command, .shift]
        focusRight.target = MenuTarget.shared
        view.submenu?.addItem(focusRight)
        let focusUp = NSMenuItem(title: "Focus Pane Up", action: #selector(MenuTarget.focusPaneUp), keyEquivalent: "\u{F700}")
        focusUp.keyEquivalentModifierMask = [.command, .shift]
        focusUp.target = MenuTarget.shared
        view.submenu?.addItem(focusUp)
        let focusDown = NSMenuItem(title: "Focus Pane Down", action: #selector(MenuTarget.focusPaneDown), keyEquivalent: "\u{F701}")
        focusDown.keyEquivalentModifierMask = [.command, .shift]
        focusDown.target = MenuTarget.shared
        view.submenu?.addItem(focusDown)

        let closePane = menuItem("Close Pane", action: #selector(MenuTarget.closePane), binding: BannerShortcutRegistry.closePane)
        view.submenu?.addItem(closePane)
        view.submenu?.addItem(.separator())

        let detachItem = NSMenuItem(title: "Detach Pane", action: #selector(MenuTarget.detachPane), keyEquivalent: "")
        detachItem.target = MenuTarget.shared
        view.submenu?.addItem(detachItem)
        let reattachItem = NSMenuItem(title: "Reattach Pane", action: #selector(MenuTarget.reattachPane), keyEquivalent: "")
        reattachItem.target = MenuTarget.shared
        view.submenu?.addItem(reattachItem)
        view.submenu?.addItem(.separator())
        let jumpItem = NSMenuItem(title: "Show Notifications", action: #selector(MenuTarget.jumpNotification), keyEquivalent: "i")
        jumpItem.keyEquivalentModifierMask = [.command, .control]
        jumpItem.target = MenuTarget.shared
        view.submenu?.addItem(jumpItem)
        let notchItem = NSMenuItem(title: "Toggle Agent Notch", action: #selector(MenuTarget.toggleAgentNotch), keyEquivalent: "i")
        notchItem.keyEquivalentModifierMask = [.command, .shift]
        notchItem.target = MenuTarget.shared
        view.submenu?.addItem(notchItem)
        let aiChatItem = NSMenuItem(title: "Ask AI…", action: #selector(MenuTarget.openAIChat), keyEquivalent: "i")
        aiChatItem.keyEquivalentModifierMask = [.command]
        aiChatItem.target = MenuTarget.shared
        view.submenu?.addItem(aiChatItem)
        let paletteItem = menuItem("Command Palette", action: #selector(MenuTarget.commandPalette), binding: BannerShortcutRegistry.commandPalette)
        view.submenu?.addItem(paletteItem)
        let promptItem = menuItem("Command Prompt", action: #selector(MenuTarget.commandPrompt), binding: BannerShortcutRegistry.commandPrompt)
        view.submenu?.addItem(promptItem)
        let searchHistoryItem = NSMenuItem(title: "Search Command History...", action: #selector(MenuTarget.searchCommandHistory), keyEquivalent: "r")
        searchHistoryItem.keyEquivalentModifierMask = [.control]
        searchHistoryItem.target = MenuTarget.shared
        view.submenu?.addItem(searchHistoryItem)
        let findItem = menuItem("Find in Files…", action: #selector(MenuTarget.findInFiles), binding: BannerShortcutRegistry.findInFiles)
        view.submenu?.addItem(findItem)
        let sidebarItem = menuItem("Toggle Sidebar", action: #selector(MenuTarget.toggleSidebar), binding: BannerShortcutRegistry.toggleSidebar)
        view.submenu?.addItem(sidebarItem)
        let hintItem = menuItem("Hint Mode (Open Link by Key)", action: #selector(MenuTarget.hintMode), binding: BannerShortcutRegistry.hintMode)
        view.submenu?.addItem(hintItem)
        view.submenu?.addItem(.separator())
        let runItem = menuItem("Run Script", action: #selector(MenuTarget.runScript), binding: BannerShortcutRegistry.runScript)
        view.submenu?.addItem(runItem)
        let stopItem = menuItem("Stop Script", action: #selector(MenuTarget.stopScript), binding: BannerShortcutRegistry.stopScript)
        view.submenu?.addItem(stopItem)
        let sidebarPosItem = NSMenuItem(title: "Move Sidebar to Right", action: #selector(MenuTarget.toggleSidebarPosition), keyEquivalent: "")
        sidebarPosItem.target = MenuTarget.shared
        view.submenu?.addItem(sidebarPosItem)
        view.submenu?.addItem(.separator())
        let zoomIn = NSMenuItem(title: "Increase Font Size", action: #selector(MenuTarget.zoomIn), keyEquivalent: "+")
        zoomIn.keyEquivalentModifierMask = [.command]
        zoomIn.target = MenuTarget.shared
        view.submenu?.addItem(zoomIn)
        // ⌘= alias so zooming in doesn't require Shift to reach "+". Marked as an
        // alternate of the item above with the same modifier mask, so AppKit keeps
        // its key equivalent live without showing a duplicate menu row.
        let zoomInAlias = NSMenuItem(title: "Increase Font Size", action: #selector(MenuTarget.zoomIn), keyEquivalent: "=")
        zoomInAlias.keyEquivalentModifierMask = [.command]
        zoomInAlias.isAlternate = true
        zoomInAlias.target = MenuTarget.shared
        view.submenu?.addItem(zoomInAlias)
        let zoomOut = NSMenuItem(title: "Decrease Font Size", action: #selector(MenuTarget.zoomOut), keyEquivalent: "-")
        zoomOut.keyEquivalentModifierMask = [.command]
        zoomOut.target = MenuTarget.shared
        view.submenu?.addItem(zoomOut)
        let zoomReset = NSMenuItem(title: "Reset Font Size", action: #selector(MenuTarget.zoomReset), keyEquivalent: "0")
        zoomReset.keyEquivalentModifierMask = [.command]
        zoomReset.target = MenuTarget.shared
        view.submenu?.addItem(zoomReset)
        main.addItem(view)

        // Remote — connect the GUI to a HarnessDaemon on another machine over an SSH tunnel.
        // The submenu is rebuilt on open (NSMenuDelegate) so it reflects saved hosts + which one
        // is currently connected.
        let remote = NSMenuItem()
        let remoteMenu = NSMenu(title: "Remote")
        remoteMenu.delegate = MenuTarget.shared
        remote.submenu = remoteMenu
        main.addItem(remote)

        // Window — standard macOS window management. Registered as windowsMenu so
        // AppKit auto-populates the open-windows list and the standard actions work.
        let window = NSMenuItem()
        let windowMenu = NSMenu(title: "Window")
        window.submenu = windowMenu
        windowMenu.addItem(NSMenuItem(title: "Minimize", action: #selector(NSWindow.performMiniaturize(_:)), keyEquivalent: "m"))
        windowMenu.addItem(NSMenuItem(title: "Zoom", action: #selector(MainWindowController.toggleVisibleFrameZoom(_:)), keyEquivalent: ""))
        // Non-native ("fast") full screen: fills the screen without the macOS Space animation.
        let fastFullScreen = NSMenuItem(
            title: "Toggle Fast Full Screen",
            action: #selector(MainWindowController.toggleNonNativeFullscreen(_:)),
            keyEquivalent: "f"
        )
        fastFullScreen.keyEquivalentModifierMask = [.command, .control, .shift]
        windowMenu.addItem(fastFullScreen)
        windowMenu.addItem(.separator())
        let openBrowserItem = menuItem(
            "Open Browser Pane",
            action: #selector(MenuTarget.openBrowserPane),
            binding: BannerShortcutRegistry.browserPane
        )
        windowMenu.addItem(openBrowserItem)
        windowMenu.addItem(.separator())
        windowMenu.addItem(NSMenuItem(title: "Bring All to Front", action: #selector(NSApplication.arrangeInFront(_:)), keyEquivalent: ""))
        main.addItem(window)
        NSApp.windowsMenu = windowMenu

        // Help
        let help = NSMenuItem()
        help.submenu = NSMenu(title: "Help")
        let welcome = NSMenuItem(title: "Welcome to Harness", action: #selector(MenuTarget.showOnboarding), keyEquivalent: "")
        welcome.target = MenuTarget.shared
        help.submenu?.addItem(welcome)
        let shortcuts = NSMenuItem(title: "Keyboard Shortcuts", action: #selector(MenuTarget.showShortcuts), keyEquivalent: "/")
        shortcuts.keyEquivalentModifierMask = [.command]
        shortcuts.target = MenuTarget.shared
        help.submenu?.addItem(shortcuts)
        main.addItem(help)

        return main
    }
}

@MainActor
final class MenuTarget: NSObject, NSMenuItemValidation, NSMenuDelegate {
    static let shared = MenuTarget()

    /// Enable Detach only when the active pane is attached, Reattach only when it's released.
    /// Every other MenuTarget item stays enabled (default true), preserving prior behavior.
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        switch menuItem.action {
        case #selector(detachPane): return !SessionCoordinator.shared.activePaneIsDetached
        case #selector(reattachPane): return SessionCoordinator.shared.activePaneIsDetached
        case #selector(reopenClosedTab): return SessionCoordinator.shared.canReopenClosedTab
        case #selector(toggleSidebarPosition):
            let right = SessionCoordinator.shared.settings.sidebarOnRight
            menuItem.title = right ? "Move Sidebar to Left" : "Move Sidebar to Right"
            return true
        default: return true
        }
    }

    // MARK: - Remote menu (rebuilt on open)

    func menuNeedsUpdate(_ menu: NSMenu) {
        guard menu.title == "Remote" else { return }
        menu.removeAllItems()
        let add = NSMenuItem(title: "Add Remote Host…", action: #selector(addRemoteHost), keyEquivalent: "")
        add.target = self
        menu.addItem(add)
        menu.addItem(.separator())

        let hosts = RemoteHostsService.shared.hosts()
        let active = RemoteHostsService.shared.activeHostName
        if hosts.isEmpty {
            let none = NSMenuItem(title: "No saved hosts", action: nil, keyEquivalent: "")
            none.isEnabled = false
            menu.addItem(none)
        } else {
            for host in hosts {
                let item = NSMenuItem(
                    title: "\(host.name) — \(host.sshTarget)",
                    action: #selector(connectRemoteHost(_:)), keyEquivalent: "")
                item.target = self
                item.representedObject = host.name
                item.state = (host.name == active) ? .on : .off
                menu.addItem(item)
            }
        }
        menu.addItem(.separator())
        let local = NSMenuItem(title: "Use Local Daemon", action: #selector(useLocalDaemon), keyEquivalent: "")
        local.target = self
        local.state = (active == nil) ? .on : .off
        menu.addItem(local)
    }

    @objc func addRemoteHost() {
        let alert = NSAlert()
        alert.messageText = "Add Remote Host"
        alert.informativeText = "Run HarnessDaemon on the remote machine (harness-cli install), "
            + "then connect to it over SSH."
        alert.addButton(withTitle: "Save & Connect")
        alert.addButton(withTitle: "Cancel")
        let stack = NSStackView(frame: NSRect(x: 0, y: 0, width: 320, height: 92))
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 6
        let nameField = NSTextField(frame: NSRect(x: 0, y: 0, width: 320, height: 22))
        nameField.placeholderString = "Name (e.g. devbox)"
        let sshField = NSTextField(frame: NSRect(x: 0, y: 0, width: 320, height: 22))
        sshField.placeholderString = "SSH target (user@host)"
        let sockField = NSTextField(frame: NSRect(x: 0, y: 0, width: 320, height: 22))
        sockField.placeholderString = "Remote socket path"
        stack.addArrangedSubview(nameField)
        stack.addArrangedSubview(sshField)
        stack.addArrangedSubview(sockField)
        alert.accessoryView = stack
        alert.window.initialFirstResponder = nameField
        guard alert.runModal() == .alertFirstButtonReturn else { return }

        let name = nameField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let ssh = sshField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty, !ssh.isEmpty else { return }
        let socketPath = sockField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if socketPath.isEmpty {
            let warn = NSAlert()
            warn.messageText = "Remote socket path required"
            warn.informativeText = "Use the path shown by `harness-cli doctor` on the remote host."
            warn.runModal()
            return
        }
        RemoteHostsService.shared.addHost(
            RemoteHost(name: name, sshTarget: ssh, remoteSocketPath: socketPath))
        SessionCoordinator.shared.connectToRemote(named: name)
    }

    @objc func connectRemoteHost(_ sender: NSMenuItem) {
        guard let name = sender.representedObject as? String else { return }
        SessionCoordinator.shared.connectToRemote(named: name)
    }

    @objc func useLocalDaemon() {
        SessionCoordinator.shared.disconnectRemote()
    }

    @objc func newSession() {
        let coordinator = SessionCoordinator.shared
        // Force a sync to ensure activeSession/activeTab reflect the currently visible tab,
        // not a stale snapshot from before the user's last tab switch.
        coordinator.syncFromDaemon()
        guard let id = coordinator.snapshot.activeWorkspaceID else { return }
        coordinator.addSession(to: id)
    }

    @objc func closeSession() {
        SessionCoordinator.shared.closeActiveSession()
    }

    @objc func closeTab() {
        SessionCoordinator.shared.closeActiveTab()
    }

    @objc func reopenClosedTab() {
        SessionCoordinator.shared.reopenLastClosedTab()
    }

    @objc func find() {
        SessionCoordinator.shared.toggleFindBar()
    }

    @objc func findInFiles() {
        CommandPaletteController.present(relativeTo: NSApp.keyWindow, mode: .grep(query: ""))
    }


    /// ⌘1–9 switch to the session (workspace) at that position in the sidebar.
    @objc func selectWorkspaceNumber(_ sender: NSMenuItem) {
        let index = sender.tag - 1
        let coordinator = SessionCoordinator.shared
        guard let workspace = coordinator.snapshot.activeWorkspace,
              index >= 0, index < workspace.sessions.count else { return }
        coordinator.selectSession(workspaceID: workspace.id, sessionID: workspace.sessions[index].id)
    }

    @objc func previousSession() {
        SessionCoordinator.shared.selectAdjacentSession(offset: -1)
    }

    @objc func nextSession() {
        SessionCoordinator.shared.selectAdjacentSession(offset: 1)
    }

    @objc func moveSessionLeft() {
        SessionCoordinator.shared.moveActiveSession(offset: -1)
    }

    @objc func moveSessionRight() {
        SessionCoordinator.shared.moveActiveSession(offset: 1)
    }

    @objc func splitH() {
        SessionCoordinator.shared.splitActivePane(direction: .horizontal)
    }

    @objc func splitV() {
        SessionCoordinator.shared.splitActivePane(direction: .vertical)
    }

    @objc func runScript() {
        SessionCoordinator.shared.runProjectScript()
    }

    @objc func stopScript() {
        SessionCoordinator.shared.stopProjectScript()
    }

    @objc func focusPaneLeft() { SessionCoordinator.shared.focusPaneDirectional(.left) }
    @objc func focusPaneRight() { SessionCoordinator.shared.focusPaneDirectional(.right) }
    @objc func focusPaneUp() { SessionCoordinator.shared.focusPaneDirectional(.up) }
    @objc func focusPaneDown() { SessionCoordinator.shared.focusPaneDirectional(.down) }
    @objc func closePane() {
        SessionCoordinator.shared.closeActivePane()
    }

    @objc func previousPane() { SessionCoordinator.shared.cycleActivePane(forward: false) }
    @objc func nextPane() { SessionCoordinator.shared.cycleActivePane(forward: true) }

    @objc func detachPane() {
        SessionCoordinator.shared.detachActiveSurface()
    }

    @objc func reattachPane() {
        SessionCoordinator.shared.reattachActiveSurface()
    }

    @objc func jumpNotification() {
        // Iterate all windows so the lookup succeeds even when the key window is a
        // panel or sheet rather than the main content window.
        for window in NSApp.windows {
            if let split = window.contentViewController as? MainSplitViewController {
                split.showNotificationsDropdown()
                return
            }
        }
    }

    @objc func toggleAgentNotch() {
        NotchPanelController.shared.toggleFromMenu()
    }

    @objc func openAIChat() {
        SessionCoordinator.shared.toggleAIChat()
    }

    @objc func showOnboarding() {
        OnboardingController.present()
    }

    @objc func showShortcuts() {
        PrefixCheatsheetWindow.shared.toggle()
    }

    @objc func commandPalette() {
        if let window = NSApp.keyWindow {
            CommandPaletteController.present(relativeTo: window)
        }
    }

    @objc func commandPrompt() {
        CommandPromptController.shared.present()
    }

    @objc func searchCommandHistory() {
        CommandHistorySearchController.shared.present()
    }

    @objc func openSettings() {
        SettingsWindowController.show()
    }

    @objc func hintMode() { SessionCoordinator.shared.showHintMode() }

    @objc func toggleSidebar() {
        let win = NSApp.keyWindow ?? NSApp.mainWindow
            ?? NSApp.windows.first(where: { $0.contentViewController is MainSplitViewController })
        if let split = win?.contentViewController as? MainSplitViewController {
            split.toggleSidebar()
        }
    }

    @objc func toggleSidebarPosition() {
        let window = NSApp.keyWindow ?? NSApp.mainWindow
        if let split = window?.contentViewController as? MainSplitViewController {
            split.toggleSidebarPosition()
        }
    }

    @objc func zoomIn() {
        SessionCoordinator.shared.updateFontSize(delta: 1)
    }

    @objc func zoomOut() {
        SessionCoordinator.shared.updateFontSize(delta: -1)
    }

    @objc func zoomReset() {
        SessionCoordinator.shared.resetFontSize()
    }

    @objc func installCLI() {
        CLIInstaller.install()
    }

    @objc func showAbout() {
        AboutPanelController.show()
    }

    @objc func openBrowserPane() {
        let home = SessionCoordinator.shared.settings.browserHomePage
        SessionCoordinator.shared.splitPaneCoordinator.openBrowserPane(
            url: URL(string: home) ?? URL(string: "https://www.google.com")!,
            direction: .horizontal
        )
    }
}
