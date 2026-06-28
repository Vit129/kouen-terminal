import SwiftUI
import HarnessCore
import HarnessSettings
import HarnessTerminalKit
import UserNotifications

struct SettingsAgentsView: View {
    var model: SettingsModel

    @State private var notifStatus: String = ""
    @State private var notifNeedsAllow: Bool = false
    @State private var hookStates: [AgentKind: HookState] = [:]

    enum HookState { case idle, installing, installed, failed }

    private static let agentKinds: [AgentKind] = [
        .codex, .claudeCode, .cursor, .grok, .pi, .hermes,
        .openClaw, .openCode, .aider, .gemini, .goose, .antigravity, .kiro,
    ]

    var body: some View {
        Form {
            notifySection
            deliverySection
            notchSection
            detectionSection
            agentsSection
        }
        .formStyle(.grouped)
        .navigationTitle("Agents")
        .task { refreshNotifStatus() }
    }

    // MARK: - Notify me about

    private var notifySection: some View {
        Section("Notify me about") {
            ForEach(NotificationEvent.allCases, id: \.self) { event in
                Toggle(event.title, isOn: Binding(
                    get: { model.settings.isEventEnabled(event) },
                    set: { enabled in
                        var s = model.settings
                        s.setEventEnabled(event, enabled)
                        model.update(\.notificationEvents, s.notificationEvents)
                    }
                ))
                .help(event.detail)

                if event == .commandFinished {
                    HStack {
                        Text("Threshold (seconds)")
                        Spacer()
                        TextField("sec", value: Binding(
                            get: { model.settings.commandFinishedThresholdSeconds },
                            set: { model.update(\.commandFinishedThresholdSeconds, max(1, $0)) }
                        ), format: .number)
                        .frame(width: 60)
                        .multilineTextAlignment(.trailing)
                    }
                    .help("Only commands that ran at least this long trigger the notification.")
                }
            }
        }
    }

    // MARK: - Delivery

    private var deliverySection: some View {
        Section("Delivery") {
            Toggle("macOS banner", isOn: Binding(
                get: { model.settings.systemNotificationsEnabled },
                set: { enabled in
                    model.update(\.systemNotificationsEnabled, enabled)
                    if enabled { DesktopNotifier.requestOrOpenSettings() }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { refreshNotifStatus() }
                }
            ))
            Toggle("Sound", isOn: Binding(
                get: { model.settings.notificationSoundEnabled },
                set: { model.update(\.notificationSoundEnabled, $0) }
            ))
            if !notifStatus.isEmpty {
                Text(notifStatus)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            HStack(spacing: 10) {
                Button("Send Test Notification") {
                    DesktopNotifier.sendTest()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { refreshNotifStatus() }
                }
                .buttonStyle(.bordered)
                if notifNeedsAllow {
                    Button("Open System Settings…") {
                        DesktopNotifier.requestOrOpenSettings()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { refreshNotifStatus() }
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }

    // MARK: - Notch HUD

    private var notchSection: some View {
        Section("Notch HUD") {
            Picker("Visibility", selection: Binding(
                get: { model.settings.notchVisibilityMode },
                set: { model.update(\.notchVisibilityMode, $0) }
            )) {
                Text("Automatic").tag(NotchVisibilityMode.automatic)
                Text("On").tag(NotchVisibilityMode.on)
                Text("Off").tag(NotchVisibilityMode.off)
            }
            .pickerStyle(.segmented)
            .help("Automatic shows the notch in Agent Workspace only.")

            Toggle("Hover", isOn: Binding(
                get: { model.settings.notchOpenOnHover },
                set: { model.update(\.notchOpenOnHover, $0) }
            ))
        }
    }

    // MARK: - Detection & hooks

    private var detectionSection: some View {
        Section("Detection & hooks") {
            Text("Harness identifies agents by walking each pane's process tree and matching the executables shown below — it works for any shell, no setup. Install hooks so an agent can ping you the moment it stops or needs input.")
                .font(.caption)
                .foregroundStyle(.secondary)
            Button("Edit agents.json…") {
                let url = HarnessPaths.applicationSupport.appendingPathComponent("agents.json")
                NSWorkspace.shared.open(url)
            }
            .buttonStyle(.bordered)

            Divider()

            Text("Trouble with one-click install? Copy this prompt and paste it into any coding agent/IDE running on this Mac.")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(AgentHookInstaller.setupPrompt)
                .font(.system(size: 10.5, design: .monospaced))
                .foregroundStyle(.secondary)
                .textSelection(.enabled)
            Button("Copy Setup Prompt") {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(AgentHookInstaller.setupPrompt, forType: .string)
            }
            .buttonStyle(.bordered)
        }
    }

    // MARK: - Agent rows

    private var agentsSection: some View {
        Section("Agents") {
            ForEach(Self.agentKinds, id: \.self) { kind in
                AgentRow(kind: kind, model: model, hookState: hookStates[kind] ?? .idle) { state in
                    hookStates[kind] = state
                }
            }
            Button("Reset Agent Colors") {
                model.update(\.agentColorOverrides, [:])
            }
            .buttonStyle(.bordered)
        }
    }

    // MARK: - Helpers

    private func refreshNotifStatus() {
        DesktopNotifier.authorizationStatus { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .provisional:
                    notifStatus = "macOS is allowing notifications."
                    notifNeedsAllow = false
                case .denied:
                    notifStatus = "macOS is blocking notifications for Harness. Click below to allow them in System Settings ▸ Notifications."
                    notifNeedsAllow = true
                case .notDetermined:
                    notifStatus = "Notifications haven't been authorized yet. Send a test to grant them."
                    notifNeedsAllow = true
                @unknown default:
                    notifStatus = ""
                    notifNeedsAllow = true
                }
            }
        }
    }
}

// MARK: - AgentRow

private struct AgentRow: View {
    let kind: AgentKind
    var model: SettingsModel
    let hookState: SettingsAgentsView.HookState
    let onHookState: (SettingsAgentsView.HookState) -> Void
    @State private var mcpIsConfigured = false

    private var executables: String {
        let execs = AgentTable.default.entries.first { $0.kind == kind }?.executables ?? []
        return execs.isEmpty ? "—" : execs.joined(separator: ", ")
    }

    private var agentColorBinding: SwiftUI.Binding<SwiftUI.Color> {
        Binding(
            get: {
                let hex = SessionCoordinator.shared.settings.agentColorHex(for: kind)
                return Color(nsColor: NSColor.fromHex(hex) ?? .white)
            },
            set: { newColor in
                guard let ns = NSColor(newColor).usingColorSpace(.sRGB) else { return }
                var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
                ns.getRed(&r, green: &g, blue: &b, alpha: &a)
                let hex = String(format: "#%02X%02X%02X", Int(r*255), Int(g*255), Int(b*255))
                var colors = SessionCoordinator.shared.settings.agentColorOverrides
                colors[kind.rawValue] = hex
                model.update(\.agentColorOverrides, colors)
            }
        )
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(nsImage: AgentIconRenderer.templateOrMonogramImage(for: kind, size: 18))
                .resizable()
                .frame(width: 18, height: 18)
                .foregroundStyle(agentColor)

            VStack(alignment: .leading, spacing: 1) {
                Text(kind.displayName)
                    .font(.system(size: 13, weight: .medium))
                Text(executables)
                    .font(.system(size: 10.5, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            ColorPicker("", selection: agentColorBinding, supportsOpacity: false)
                .labelsHidden()
                .frame(width: 28)

            if AgentHookInstaller.canInstall(kind) {
                hookButton
            }

            if MCPConfigWriter.canConfigure(kind) {
                mcpButton
            }
        }
        .task { mcpIsConfigured = MCPConfigWriter.isConfigured(kind) }
    }

    private var agentColor: Color {
        let hex = SessionCoordinator.shared.settings.agentColorHex(for: kind)
        return Color(nsColor: NSColor.fromHex(hex) ?? .white)
    }

    private var hookButton: some View {
        Button(hookButtonTitle) {
            onHookState(.installing)
            Task.detached(priority: .userInitiated) {
                let outcome = Result { try AgentHookInstaller.install(agent: kind) }
                await MainActor.run {
                    switch outcome {
                    case .success: onHookState(.installed)
                    case .failure: onHookState(.failed)
                    }
                }
            }
        }
        .buttonStyle(.bordered)
        .disabled(hookState == .installing)
    }

    private var hookButtonTitle: String {
        switch hookState {
        case .idle: return AgentHookInstaller.isInstalled(agent: kind) ? "Reinstall Hooks" : "Install Hooks"
        case .installing: return "Installing…"
        case .installed: return "Reinstall Hooks"
        case .failed: return "Install Hooks"
        }
    }

    private var mcpButton: some View {
        let mcpPath = resolveMCPPath()
        return Button(mcpIsConfigured ? "✓ MCP" : "Add MCP") {
            let removing = mcpIsConfigured
            Task.detached(priority: .userInitiated) {
                if removing {
                    try? MCPConfigWriter.remove(kind)
                } else {
                    try? MCPConfigWriter.add(kind, mcpBinaryPath: mcpPath)
                }
                await MainActor.run { mcpIsConfigured = !removing }
            }
        }
        .buttonStyle(.bordered)
        .foregroundStyle(mcpIsConfigured ? Color.green : Color.primary)
    }

    private func resolveMCPPath() -> String {
        if let dir = Bundle.main.executableURL?.deletingLastPathComponent() {
            let bundled = dir.appendingPathComponent("harness-mcp")
            if FileManager.default.isExecutableFile(atPath: bundled.path) { return bundled.path }
        }
        return "harness-mcp"
    }
}
