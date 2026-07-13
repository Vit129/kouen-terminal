import SwiftUI
import KouenSettings

struct SettingsAppearanceView: View {
    var model: SettingsModel

    private var autoTheme: Bool {
        model.settings.lightThemeName != nil && model.settings.darkThemeName != nil
    }

    var body: some View {
        Form {
            themeSection
            windowSection
        }
        .formStyle(.grouped)
        .navigationTitle("Appearance")
    }

    // MARK: - Theme

    private var themeSection: some View {
        Section("Theme") {
            Picker("Theme", selection: Binding(
                get: { model.currentThemeName },
                set: { model.setTheme($0) }
            )) {
                ForEach(model.themeNames, id: \.self) { Text($0).tag($0) }
            }
            .disabled(autoTheme)

            Toggle("Auto light/dark", isOn: Binding(
                get: { autoTheme },
                set: { toggleAutoTheme($0) }
            ))
            .help("Switch theme with the macOS system appearance.")

            if autoTheme {
                Picker("Light theme", selection: Binding(
                    get: { model.settings.lightThemeName ?? model.currentThemeName },
                    set: { model.update(\.lightThemeName, $0) }
                )) {
                    ForEach(model.themeNames, id: \.self) { Text($0).tag($0) }
                }

                Picker("Dark theme", selection: Binding(
                    get: { model.settings.darkThemeName ?? model.currentThemeName },
                    set: { model.update(\.darkThemeName, $0) }
                )) {
                    ForEach(model.themeNames, id: \.self) { Text($0).tag($0) }
                }

                SliderRow(
                    label: "Light opacity",
                    value: Binding(
                        get: { Double(model.settings.lightThemeOpacity ?? model.settings.backgroundOpacity) },
                        set: { model.update(\.lightThemeOpacity, Float($0)) }
                    ),
                    range: 0...1,
                    format: "%"
                )
                .help("Window opacity while the light theme is active.")

                SliderRow(
                    label: "Dark opacity",
                    value: Binding(
                        get: { Double(model.settings.darkThemeOpacity ?? model.settings.backgroundOpacity) },
                        set: { model.update(\.darkThemeOpacity, Float($0)) }
                    ),
                    range: 0...1,
                    format: "%"
                )
                .help("Window opacity while the dark theme is active.")
            }

            HStack(spacing: 16) {
                Button("Use theme colors") { model.useThemeColors() }
                    .buttonStyle(.link)
                Button("Reset to defaults") { confirmReset() }
                    .buttonStyle(.link)
            }
        }
    }

    // MARK: - Window

    private var windowSection: some View {
        Section("Window") {
            SliderRow(
                label: "Opacity",
                value: Binding(
                    get: { Double(model.settings.backgroundOpacity) },
                    set: { model.update(\.backgroundOpacity, KouenSettings.clampedOpacity(Float($0))) }
                ),
                range: 0...1,
                format: "%"
            )

            SliderRow(
                label: "Blur",
                value: Binding(
                    get: { Double(model.settings.backgroundBlur) },
                    set: { model.update(\.backgroundBlur, Int($0.rounded())) }
                ),
                range: 0...40,
                format: ""
            )

            SliderRow(
                label: "Edge border",
                value: Binding(
                    get: { Double(model.settings.windowBorderOpacity) },
                    set: { model.update(\.windowBorderOpacity, Float($0)) }
                ),
                range: 0...1,
                format: "%"
            )
            .help("Faint hairline around the window edge — 0% hides it.")

            HStack {
                Text("Padding")
                Spacer()
                TextField("X", value: Binding(
                    get: { model.settings.windowPaddingX },
                    set: { model.update(\.windowPaddingX, KouenSettings.clampedPadding($0)) }
                ), format: .number)
                .frame(width: 55)
                .multilineTextAlignment(.trailing)
                Text("×")
                    .foregroundStyle(.secondary)
                TextField("Y", value: Binding(
                    get: { model.settings.windowPaddingY },
                    set: { model.update(\.windowPaddingY, KouenSettings.clampedPadding($0)) }
                ), format: .number)
                .frame(width: 55)
                .multilineTextAlignment(.trailing)
                Text("pt")
                    .foregroundStyle(.secondary)
            }

            Toggle("Center grid", isOn: Binding(
                get: { model.settings.windowPaddingBalance },
                set: { model.update(\.windowPaddingBalance, $0) }
            ))
            .help("Distribute leftover padding evenly so the grid is centered.")

            Picker("Resize overlay", selection: Binding(
                get: { model.settings.resizeOverlay },
                set: { model.update(\.resizeOverlay, $0) }
            )) {
                Text("After first").tag(ResizeOverlayMode.afterFirst)
                Text("Always").tag(ResizeOverlayMode.always)
                Text("Never").tag(ResizeOverlayMode.never)
            }
            .pickerStyle(.segmented)
            .help("Show the grid size while resizing the window.")

            Picker("Overlay position", selection: Binding(
                get: { model.settings.resizeOverlayPosition },
                set: { model.update(\.resizeOverlayPosition, $0) }
            )) {
                Text("Center").tag(ResizeOverlayPosition.center)
                Text("Top right").tag(ResizeOverlayPosition.topRight)
                Text("Bottom right").tag(ResizeOverlayPosition.bottomRight)
            }
            .pickerStyle(.segmented)

            Toggle("Transparent title bar", isOn: Binding(
                get: { model.settings.transparentTitlebar },
                set: { model.update(\.transparentTitlebar, $0) }
            ))
            Toggle("Status line", isOn: Binding(
                get: { model.settings.effectiveStatusLineEnabled },
                set: { model.update(\.statusLineEnabled, $0) }
            ))
            Toggle("Sidebar", isOn: Binding(
                get: { model.settings.sidebarVisible },
                set: { model.update(\.sidebarVisible, $0) }
            ))
            Toggle("Sidebar on right", isOn: Binding(
                get: { model.settings.sidebarOnRight },
                set: {
                    model.update(\.sidebarOnRight, $0)
                    // model.update only persists the flag — it doesn't touch the live
                    // NSSplitView subview order, which `toggleSidebarPosition()`/the
                    // menu command otherwise keeps in sync. Without this, the divider
                    // math (setSidebarWidth/sidebarContainerView) reads the new flag
                    // while the physical layout is still built for the old one, so the
                    // next sidebar toggle animates the wrong view (real terminal pane
                    // squeezed to sidebar width, real sidebar left showing blank).
                    NotificationCenter.default.post(
                        name: Notification.Name("KouenSidebarPlacementChanged"), object: nil)
                }
            ))
            Toggle("Always collapse sidebar on launch", isOn: Binding(
                get: { model.settings.sidebarCollapsedOnLaunch },
                set: { model.update(\.sidebarCollapsedOnLaunch, $0) }
            ))
            Toggle("Remember window size", isOn: Binding(
                get: { model.settings.restoreWindowSize },
                set: { model.update(\.restoreWindowSize, $0) }
            ))
            .help("Reopen at the last size and position.")
        }
    }

    // MARK: - Helpers

    private func toggleAutoTheme(_ enabled: Bool) {
        if enabled {
            let current = model.currentThemeName
            if model.settings.lightThemeName == nil { model.update(\.lightThemeName, current) }
            if model.settings.darkThemeName == nil { model.update(\.darkThemeName, current) }
        } else {
            model.update(\.lightThemeName, nil)
            model.update(\.darkThemeName, nil)
        }
    }

    private func confirmReset() {
        let alert = NSAlert()
        alert.messageText = "Reset appearance to defaults?"
        alert.informativeText = "Colors, palette, font, padding, and other visual settings will be restored to their defaults. This can't be undone."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Reset")
        alert.addButton(withTitle: "Cancel")
        alert.buttons[0].keyEquivalent = ""
        alert.buttons[1].keyEquivalent = "\r"
        guard alert.runModal() == .alertFirstButtonReturn else { return }
        model.resetToDefaults()
    }
}

// MARK: - Slider helper

private struct SliderRow: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let format: String

    var body: some View {
        LabeledContent(label) {
            HStack(spacing: 8) {
                Slider(value: $value, in: range)
                    .frame(width: 200)
                Text(displayValue)
                    .monospacedDigit()
                    .frame(width: 48, alignment: .trailing)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var displayValue: String {
        if format == "%" {
            return String(format: "%.0f%%", value * 100)
        }
        return String(format: "%.0f", value)
    }
}
