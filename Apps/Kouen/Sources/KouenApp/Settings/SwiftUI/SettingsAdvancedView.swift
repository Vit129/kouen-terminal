import SwiftUI
import KouenCore
import KouenSettings

struct SettingsAdvancedView: View {
    var model: SettingsModel

    @State private var advValues: [String: String] = [:]
    @State private var daemonReachable = true

    var body: some View {
        Form {
            if !daemonReachable {
                Section {
                    Label("Daemon unreachable — showing defaults; changes can't be applied.", systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                }
            }

            Section("Performance") {
                Toggle("Off-main render pipeline", isOn: Binding(
                    get: { model.settings.offMainParserFramePipeline },
                    set: { model.update(\.offMainParserFramePipeline, $0) }
                ))
                .help("Parse and build frames off the main thread. On is recommended.")

                Toggle("Real-time resize", isOn: Binding(
                    get: { model.settings.liveResizeReflow },
                    set: { model.update(\.liveResizeReflow, $0) }
                ))
                .help("Reflow and redraw the running program live while dragging the window edge, instead of on release. On is recommended.")
            }

            Section("Status bar") {
                Text("Format the bottom status bar (FormatString tokens like #{cwd_basename}, #{git_branch}, #{time:%H:%M}). On/off switch is in Appearance ▸ Window.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Picker("Status position", selection: segmentBinding("status-position")) {
                    Text("Bottom").tag("bottom")
                    Text("Top").tag("top")
                }
                .pickerStyle(.segmented)
                .disabled(!daemonReachable)

                LabeledContent("Status left") {
                    TextField("", text: fieldBinding("status-left"))
                        .frame(width: 260)
                }
                .disabled(!daemonReachable)

                LabeledContent("Status right") {
                    TextField("", text: fieldBinding("status-right"))
                        .frame(width: 260)
                }
                .disabled(!daemonReachable)
            }

            Section("Input") {
                Toggle("Mouse reporting", isOn: toggleBinding("mouse"))
                    .disabled(!daemonReachable)

                Picker("Copy-mode keys", selection: segmentBinding("mode-keys")) {
                    Text("vi").tag("vi")
                    Text("emacs").tag("emacs")
                }
                .pickerStyle(.segmented)
                .disabled(!daemonReachable)

                Toggle("OSC 52 clipboard", isOn: toggleBinding("set-clipboard"))
                    .disabled(!daemonReachable)
            }

            Section("Terminal identity") {
                Text("How Kouen identifies itself to programs (TERM_PROGRAM + XTVERSION). Compatible reports a protocol-compatible identity so tools like Claude Code enable Shift+Enter immediately. Applies to newly-opened panes.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Picker("Reported identity", selection: segmentBinding(TerminalIdentity.optionKey)) {
                    ForEach(TerminalIdentity.Mode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .disabled(!daemonReachable)
            }

            Section("Indexing") {
                Picker("Window base index", selection: segmentBinding("base-index")) {
                    Text("0").tag("0")
                    Text("1").tag("1")
                }
                .pickerStyle(.segmented)
                .disabled(!daemonReachable)

                Picker("Pane base index", selection: segmentBinding("pane-base-index")) {
                    Text("0").tag("0")
                    Text("1").tag("1")
                }
                .pickerStyle(.segmented)
                .disabled(!daemonReachable)

                Toggle("Renumber windows", isOn: toggleBinding("renumber-windows"))
                    .disabled(!daemonReachable)
            }

            Section("Titles & monitoring") {
                Toggle("Program tab titles", isOn: toggleBinding("allow-rename"))
                    .disabled(!daemonReachable)
                Toggle("Automatic rename", isOn: toggleBinding("automatic-rename"))
                    .disabled(!daemonReachable)
                Toggle("Monitor activity", isOn: toggleBinding("monitor-activity"))
                    .disabled(!daemonReachable)
                Toggle("Monitor bell", isOn: toggleBinding("monitor-bell"))
                    .disabled(!daemonReachable)

                LabeledContent("Silence alert (s)") {
                    TextField("", text: fieldBinding("monitor-silence"))
                        .frame(width: 80)
                }
                .disabled(!daemonReachable)
            }

            Section("Lifecycle") {
                Toggle("Remain on exit", isOn: toggleBinding("remain-on-exit"))
                    .disabled(!daemonReachable)

                LabeledContent("Prefix repeat (ms)") {
                    TextField("", text: fieldBinding("repeat-time"))
                        .frame(width: 100)
                }
                .disabled(!daemonReachable)

                LabeledContent("History limit") {
                    TextField("", text: fieldBinding("history-limit"))
                        .frame(width: 120)
                }
                .help("Session scrollback; the renderer's own scrollback is in Terminal ▸ Behavior.")
                .disabled(!daemonReachable)
            }

            Section("Pane borders") {
                Picker("Pane border labels", selection: segmentBinding("pane-border-status")) {
                    Text("Off").tag("off")
                    Text("Top").tag("top")
                    Text("Bottom").tag("bottom")
                }
                .pickerStyle(.segmented)
                .disabled(!daemonReachable)

                LabeledContent("Border format") {
                    TextField("", text: fieldBinding("pane-border-format"))
                        .frame(width: 260)
                }
                .disabled(!daemonReachable)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Advanced")
        .task { await loadAdvancedValues() }
    }

    // MARK: - Bindings

    private func toggleBinding(_ key: String) -> SwiftUI.Binding<Bool> {
        SwiftUI.Binding(
            get: { (advValues[key] ?? defaultString(key)) == "on" },
            set: { apply(key: key, rawValue: $0 ? "on" : "off") }
        )
    }

    private func segmentBinding(_ key: String) -> SwiftUI.Binding<String> {
        SwiftUI.Binding(
            get: { advValues[key] ?? defaultString(key) },
            set: { apply(key: key, rawValue: $0) }
        )
    }

    private func fieldBinding(_ key: String) -> SwiftUI.Binding<String> {
        SwiftUI.Binding(
            get: { advValues[key] ?? defaultString(key) },
            set: { apply(key: key, rawValue: $0) }
        )
    }

    private func defaultString(_ key: String) -> String {
        OptionStore.builtinDefaults[key]?.stringValue ?? ""
    }

    // MARK: - Data

    private func loadAdvancedValues() async {
        var values: [String: String] = [:]
        for (key, value) in OptionStore.builtinDefaults {
            values[key] = value.stringValue
        }
        if case let .options(entries)? = await SessionCoordinator.shared.requestDaemon(.showOptions(scope: nil)) {
            for entry in entries where entry.scope == "global" {
                values[entry.key] = entry.value
            }
            daemonReachable = true
        } else {
            daemonReachable = false
        }
        advValues = values
    }

    private func apply(key: String, rawValue: String) {
        advValues[key] = rawValue
        Task {
            await SessionCoordinator.shared.requestDaemon(.setOption(scope: "global", target: nil, key: key, rawValue: rawValue))
            KouenOptions.reloadFromDisk()
            NotificationBus.shared.postSnapshotChanged(SnapshotChangedPayload(
                revision: SessionCoordinator.shared.snapshot.revision,
                structureChanged: false,
                metadataOnly: true,
                chromeChanged: false
            ))
        }
    }
}
