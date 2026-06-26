import SwiftUI
import HarnessCore
import HarnessSettings

struct SettingsTerminalView: View {
    var model: SettingsModel

    var body: some View {
        Form {
            experienceSection
            fontSection
            shellSection
            behaviorSection
        }
        .formStyle(.grouped)
        .navigationTitle("Terminal")
    }

    // MARK: - Experience

    private var experienceSection: some View {
        Section("Experience") {
            Picker("Mode", selection: Binding(
                get: { model.settings.experienceMode },
                set: { model.update(\.experienceMode, $0) }
            )) {
                Text("Plain").tag(ExperienceMode.plain)
                Text("Full").tag(ExperienceMode.full)
            }
            .pickerStyle(.segmented)

            Picker("Command prefix", selection: Binding(
                get: { TriState(model.settings.prefixKeyEnabled) },
                set: { model.update(\.prefixKeyEnabled, $0.boolValue) }
            )) {
                ForEach(TriState.allCases, id: \.self) { Text($0.label).tag($0) }
            }
            .pickerStyle(.segmented)
            .help("Auto follows the mode above.")

            Toggle("Show status line", isOn: Binding(
                get: { model.settings.showStatusLine },
                set: { model.update(\.showStatusLine, $0) }
            ))
        }
    }

    // MARK: - Font

    private var fontSection: some View {
        Section("Font") {
            HStack {
                Text(fontReadout)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Choose Font…") { openFontPanel() }
            }
            HStack {
                Text("Size")
                Spacer()
                TextField("Size", value: Binding(
                    get: { model.settings.fontSize },
                    set: { model.update(\.fontSize, HarnessSettings.clampedFontSize($0)) }
                ), format: .number)
                .multilineTextAlignment(.trailing)
                .frame(width: 60)
            }
        }
    }

    // MARK: - Shell

    private var shellSection: some View {
        Section("Shell") {
            LabeledContent("Shell") {
                TextField("e.g. /bin/zsh", text: Binding(
                    get: { model.settings.defaultShell },
                    set: { model.update(\.defaultShell, $0) }
                ))
            }
            LabeledContent("Default directory") {
                TextField("e.g. ~/Projects", text: Binding(
                    get: { model.settings.defaultCWD },
                    set: { model.update(\.defaultCWD, $0) }
                ))
            }
        }
    }

    // MARK: - Behavior

    private var behaviorSection: some View {
        Section("Behavior") {
            Picker("Cursor style", selection: Binding(
                get: { model.settings.cursorStyle },
                set: { model.update(\.cursorStyle, $0) }
            )) {
                Text("Bar").tag("bar")
                Text("Block").tag("block")
                Text("Underline").tag("underline")
            }
            .pickerStyle(.segmented)

            HStack {
                Text("Scrollback lines")
                Spacer()
                TextField("Lines", value: Binding(
                    get: { model.settings.scrollbackLines },
                    set: { model.update(\.scrollbackLines, max(100, $0)) }
                ), format: .number)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
            }

            Toggle("Blinking cursor", isOn: Binding(
                get: { model.settings.cursorBlink },
                set: { model.update(\.cursorBlink, $0) }
            ))
            Toggle("Copy text on selection", isOn: Binding(
                get: { model.settings.copyOnSelect },
                set: { model.update(\.copyOnSelect, $0) }
            ))
            Toggle("Confirm risky pastes", isOn: Binding(
                get: { model.settings.pasteProtection },
                set: { model.update(\.pasteProtection, $0) }
            ))
            Toggle("Prompt gutter", isOn: Binding(
                get: { model.settings.showPromptGutter },
                set: { model.update(\.showPromptGutter, $0) }
            ))
            .help("Green/red stripe marking command success — needs shell integration.")
            Toggle("Real-time resize reflow", isOn: Binding(
                get: { model.settings.liveResizeReflow },
                set: { model.update(\.liveResizeReflow, $0) }
            ))
            Toggle("Keep sessions running after window closes", isOn: Binding(
                get: { model.keepSessions },
                set: { model.setKeepSessions($0) }
            ))
        }
    }

    // MARK: - Helpers

    private var fontReadout: String {
        "\(model.settings.fontFamily) \(Int(model.settings.fontSize))pt"
    }

    private func openFontPanel() {
        let size = CGFloat(model.settings.fontSize)
        let font = NSFont(name: model.settings.fontFamily, size: size)
            ?? .monospacedSystemFont(ofSize: size, weight: .regular)
        let mgr = NSFontManager.shared
        mgr.setSelectedFont(font, isMultiple: false)
        mgr.orderFrontFontPanel(nil)
    }
}

// MARK: - Tri-state helper for Bool?

private enum TriState: CaseIterable {
    case auto, on, off

    init(_ value: Bool?) {
        switch value {
        case .none: self = .auto
        case .some(true): self = .on
        case .some(false): self = .off
        }
    }

    var boolValue: Bool? {
        switch self {
        case .auto: nil
        case .on: true
        case .off: false
        }
    }

    var label: String {
        switch self {
        case .auto: "Auto"
        case .on: "On"
        case .off: "Off"
        }
    }
}
