import AppKit
import KouenCore
import KouenTerminalKit
import KouenTheme

/// Handles theme application, settings propagation, and auto light/dark switching.
@MainActor
final class ThemeService {
    private unowned let coord: SessionCoordinator

    init(coordinator: SessionCoordinator) {
        self.coord = coordinator
    }

    func applySettingsToHosts() {
        KouenChrome.update(
            themeName: coord.snapshot.themeName,
            opacity: CGFloat(coord.settings.backgroundOpacity),
            blur: coord.settings.backgroundBlur,
            backgroundHex: coord.settings.customBackgroundHex,
            foregroundHex: coord.settings.customForegroundHex,
            cursorHex: coord.settings.customCursorHex
        )
        let allowClipboard = KouenOptions.shared.get("set-clipboard")?.boolValue ?? true
        let wordSep = KouenOptions.shared.get("word-separators")?.stringValue ?? " \t"
        let wrapSearch = KouenOptions.shared.get("wrap-search")?.boolValue ?? true
        for host in coord.terminalHosts.allHosts() {
            host.applyTheme(named: coord.snapshot.themeName)
            host.applySettings(coord.settings)
            host.allowProgramClipboardAccess = allowClipboard
            host.wordSeparators = wordSep
            host.wrapSearch = wrapSearch
            applyTerminalIdentity(to: host)
            pushBorderColors(to: host)
        }
        NotificationCenter.default.post(
            name: NotificationBus.shared.snapshotChanged,
            object: nil,
            userInfo: [
                "revision": coord.snapshot.revision,
                "structureChanged": false,
                "chromeChanged": true,
            ]
        )
    }

    func applyThemeToAllHosts() {
        KouenChrome.update(
            themeName: coord.snapshot.themeName,
            opacity: CGFloat(coord.settings.backgroundOpacity),
            blur: coord.settings.backgroundBlur,
            backgroundHex: coord.settings.customBackgroundHex,
            foregroundHex: coord.settings.customForegroundHex,
            cursorHex: coord.settings.customCursorHex
        )
        let allowClipboard = KouenOptions.shared.get("set-clipboard")?.boolValue ?? true
        let wordSep = KouenOptions.shared.get("word-separators")?.stringValue ?? " \t"
        let wrapSearch = KouenOptions.shared.get("wrap-search")?.boolValue ?? true
        for host in coord.terminalHosts.allHosts() {
            host.applyTheme(named: coord.snapshot.themeName)
            host.applySettings(coord.settings)
            host.allowProgramClipboardAccess = allowClipboard
            host.wordSeparators = wordSep
            host.wrapSearch = wrapSearch
            applyTerminalIdentity(to: host)
            pushBorderColors(to: host)
        }
        coord.activePaneService.adoptSynchronizeOptions()
        coord.activePaneService.refreshSyncSiblings()
        coord.activePaneService.reassertMarkedPane()
    }

    func applyTerminalIdentity(to host: TerminalHostView) {
        let spec = TerminalIdentity.spec(forOption: KouenOptions.shared.get(TerminalIdentity.optionKey)?.stringValue)
        host.setTerminalIdentity(name: spec.name, version: spec.version, daVersion: spec.daVersion)
    }

    func pushBorderColors(to host: TerminalHostView) {
        let chrome = KouenChrome.current
        host.applyBorderColors(active: chrome.focusRing, waiting: chrome.waiting)
    }

    func setTheme(_ name: String, seedColors: Bool = true) {
        if seedColors {
            let preset = ThemeManager.presetColors(themeName: name)
            coord.settings.customBackgroundHex = preset.backgroundHex
            coord.settings.customForegroundHex = preset.foregroundHex
            coord.settings.customCursorHex = preset.cursorHex
            coord.settings.cursorTextHex = preset.cursorTextHex
            coord.settings.selectionBackgroundHex = preset.selectionBackgroundHex
            coord.settings.selectionForegroundHex = preset.selectionForegroundHex
            coord.settings.boldColorHex = preset.boldHex
            coord.settings.paletteHex = KouenSettings.normalizedPalette(preset.paletteHex)
            coord.settings.dividerHex = nil
            coord.settings.statusLineHex = nil
            try? coord.settings.save()
        }
        coord.requestDaemon(.setTheme(name: name))
        coord.syncFromDaemon()
    }

    func applyImportedTheme(_ document: ThemeDocument) {
        let colors = document.colors
        coord.settings.customBackgroundHex = colors.background.hexString
        coord.settings.customForegroundHex = colors.foreground.hexString
        coord.settings.customCursorHex = colors.cursor?.hexString
        coord.settings.cursorTextHex = colors.cursorText?.hexString
        coord.settings.selectionBackgroundHex = colors.selectionBackground?.hexString
        coord.settings.selectionForegroundHex = colors.selectionForeground?.hexString
        coord.settings.boldColorHex = colors.bold?.hexString
        coord.settings.paletteHex = KouenSettings.normalizedPalette(colors.palette.map { $0.hexString })
        coord.settings.dividerHex = nil
        coord.settings.statusLineHex = nil
        if let appearance = document.appearance {
            if let opacity = appearance.backgroundOpacity {
                coord.settings.backgroundOpacity = KouenSettings.clampedOpacity(Float(opacity))
            }
            if let blur = appearance.backgroundBlur {
                coord.settings.backgroundBlur = KouenSettings.clampedBlur(blur)
            }
            if let family = appearance.fontFamily, !family.isEmpty {
                coord.settings.fontFamily = family
            }
            if let size = appearance.fontSize {
                coord.settings.fontSize = KouenSettings.clampedFontSize(Float(size))
            }
            if let px = appearance.windowPaddingX {
                coord.settings.windowPaddingX = KouenSettings.clampedPadding(Float(px))
            }
            if let py = appearance.windowPaddingY {
                coord.settings.windowPaddingY = KouenSettings.clampedPadding(Float(py))
            }
            if let applyToOutput = appearance.applyToTerminalOutput {
                coord.settings.applyThemeToTerminalOutput = applyToOutput
            }
        }
        try? coord.settings.save()
        coord.requestDaemon(.setTheme(name: document.name))
        coord.syncFromDaemon()
    }

    func applyAutoThemeForCurrentAppearance() {
        guard let light = coord.settings.lightThemeName,
              let dark = coord.settings.darkThemeName else { return }
        let isDark = SessionCoordinator.isSystemAppearanceDark
        let target = isDark ? dark : light
        let targetOpacity = isDark ? coord.settings.darkThemeOpacity : coord.settings.lightThemeOpacity

        var didChange = false
        if target != coord.snapshot.themeName {
            setTheme(target, seedColors: true)
            didChange = true
        }
        if let targetOpacity {
            let clamped = KouenSettings.clampedOpacity(targetOpacity)
            if coord.settings.backgroundOpacity != clamped {
                coord.settings.backgroundOpacity = clamped
                try? coord.settings.save()
                didChange = true
            }
        }
        if didChange { applySettingsToHosts() }
    }

    func reimportTerminalConfig() {
        if let imported = TerminalConfigImporter.load() {
            coord.settings = KouenSettings.makeDefaults(imported: imported)
            try? coord.settings.save()
            if let theme = imported.themeName {
                setTheme(theme, seedColors: false)
            } else {
                setTheme(ThemeManager.defaultDisplayName, seedColors: false)
            }
            applyAutoThemeForCurrentAppearance()
            applySettingsToHosts()
        }
    }
}
