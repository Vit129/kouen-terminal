import AppKit
import CoreImage
import SwiftUI
import KouenCore

struct SettingsRemoteView: View {
    var model: SettingsModel

    @State private var hosts: [RemoteHost] = []
    @State private var selectedID: String? = nil
    @State private var editName = ""
    @State private var editTarget = ""
    @State private var editPort = ""
    @State private var editIdentity = ""
    @State private var editJump = ""
    @State private var editAgentForwarding = false
    @State private var editSocket = ""
    @State private var statusMessage = ""
    @State private var isDetectingSocket = false

    // P37 B2: in-app pairing QR state, refreshed by the poll loop in `mobilePairingSection`.
    @State private var pairingURL: String? = nil
    @State private var pairingQR: NSImage? = nil
    @State private var pairingSecondsRemaining = 0
    @State private var pairingDaemonReportsEnabled = false
    @State private var pairedDevices: [PairedDeviceSummary] = []
    // A paired device reconnects via its stored secret (P37 A2) — it never needs the QR
    // again, so once at least one device is paired the rotating QR is pointless noise by
    // default. This only gates the QR's visibility, not pairing itself: the daemon keeps
    // rotating tokens underneath regardless, so toggling this back on always shows a live one.
    @State private var showQRManually = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                mobilePairingSection

                Divider()

                Text("Saved SSH tunnels to remote Kouen daemons. TCP remains disabled until it has a TLS layer.")
                    .font(.callout)
                    .foregroundStyle(.secondary)

                HStack(alignment: .top, spacing: 24) {
                    hostListPanel
                    hostFormPanel
                }
            }
            .padding(20)
        }
        .navigationTitle("Remote")
        .onAppear { reloadHosts() }
        .onChange(of: selectedID) { _, newID in syncFormFromSelection(id: newID) }
        .onReceive(NotificationCenter.default.publisher(for: RemoteHostsService.activeHostDidChange)) { _ in
            reloadHosts()
            refreshStatus()
        }
        .onReceive(NotificationCenter.default.publisher(for: RemoteHostsService.connectionDidFail)) { note in
            let msg = (note.userInfo?["error"] as? String) ?? "Connection failed"
            statusMessage = "⚠️ \(msg)"
        }
    }

    // MARK: - Mobile pairing

    private var mobilePairingSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Toggle("Enable mobile pairing", isOn: Binding(
                get: { model.settings.mobileBridgeEnabled },
                set: { enabled in
                    model.update(\.mobileBridgeEnabled, enabled)
                    SessionCoordinator.shared.requestDaemon(.setMobileBridgeEnabled(enabled))
                }
            ))
            Text("Lets a phone pair via QR (`kouen-cli mobile-list-clients`/`mobile-revoke-client` manage paired devices). Binds loopback + Tailscale only, never plain LAN. Takes effect immediately — no restart, running PTYs/agents are unaffected.")
                .font(.caption)
                .foregroundStyle(.secondary)

            if model.settings.mobileBridgeEnabled {
                if pairedDevices.isEmpty || showQRManually {
                    pairingQRPanel
                } else {
                    pairedAlreadyBanner
                }
                pairedDevicesList
            }
        }
        // P37 B2: poll the live pairing URL/countdown ~1s while this pane is visible — the
        // token rotates every 45s, so the QR must refresh itself. `.task(id:)` restarts the
        // loop when the toggle flips and cancels it when the pane disappears, so a closed
        // Settings window costs zero IPC traffic.
        .task(id: model.settings.mobileBridgeEnabled) {
            guard model.settings.mobileBridgeEnabled else {
                pairingURL = nil
                pairingQR = nil
                return
            }
            while !Task.isCancelled {
                await refreshPairingInfo()
                try? await Task.sleep(for: .seconds(1))
            }
        }
    }

    /// Shown instead of the live QR once ≥1 device is already paired — re-showing a
    /// rotating token nobody needs anymore was the whole ask (paired devices reconnect via
    /// their stored secret, never the QR).
    private var pairedAlreadyBanner: some View {
        HStack(spacing: 8) {
            Label("\(pairedDevices.count) device\(pairedDevices.count == 1 ? "" : "s") paired", systemImage: "checkmark.circle.fill")
                .font(.caption)
                .foregroundStyle(Color.green)
            Spacer()
            Button("Pair another device") { showQRManually = true }
                .controlSize(.small)
        }
        .padding(.top, 4)
    }

    @ViewBuilder
    private var pairingQRPanel: some View {
        if let qr = pairingQR, let url = pairingURL {
            VStack(alignment: .leading, spacing: 8) {
                if showQRManually && !pairedDevices.isEmpty {
                    Button("Done — hide QR") { showQRManually = false }
                        .controlSize(.small)
                }
                // `.interpolation(.none)` keeps the upscaled QR modules hard-edged —
                // the default (bilinear) smoothing blurs them enough to slow camera scans.
                Image(nsImage: qr)
                    .interpolation(.none)
                    .resizable()
                    .frame(width: 200, height: 200)
                ProgressView(value: Double(min(max(pairingSecondsRemaining, 0), 45)), total: 45)
                    .frame(width: 200)
                HStack(spacing: 6) {
                    Text(url)
                        .font(.system(size: 11, design: .monospaced))
                        .textSelection(.enabled)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Button {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(url, forType: .string)
                    } label: {
                        Image(systemName: "doc.on.doc")
                    }
                    .buttonStyle(.borderless)
                    .help("Copy pairing URL")
                }
                Text("Scan with your phone's camera — the code rotates every 45 seconds.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 4)
        } else {
            // Enabled but no URL: either the daemon is still (re)starting, or no WS listener
            // is up (port squatted — R4). Both self-heal into the QR on a later poll tick.
            Label(
                pairingDaemonReportsEnabled
                    ? "Bridge is on, but not listening — the port may be in use. Check logs/daemon.log."
                    : "Waiting for the daemon's pairing bridge…",
                systemImage: pairingDaemonReportsEnabled ? "exclamationmark.triangle" : "hourglass"
            )
            .font(.caption)
            .foregroundStyle(pairingDaemonReportsEnabled ? Color.orange : Color.secondary)
            .padding(.top, 4)
        }
    }

    @ViewBuilder
    private var pairedDevicesList: some View {
        if !pairedDevices.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                Text("Paired devices")
                    .font(.system(size: 12, weight: .semibold))
                    .padding(.top, 6)
                ForEach(pairedDevices, id: \.id) { device in
                    HStack(spacing: 8) {
                        Text(device.label)
                            .font(.system(size: 12))
                        Text(device.pairedAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button("Revoke") {
                            Task {
                                _ = await SessionCoordinator.shared.requestDaemon(.mobileRevokeClient(id: device.id))
                                await refreshPairingInfo()
                            }
                        }
                        .controlSize(.small)
                    }
                }
            }
        }
    }

    private func refreshPairingInfo() async {
        if case let .mobilePairingInfo(url, seconds, enabled)? =
            await SessionCoordinator.shared.requestDaemon(.mobilePairingInfo) {
            pairingDaemonReportsEnabled = enabled
            pairingSecondsRemaining = seconds
            if url != pairingURL {
                pairingURL = url
                // Regenerate only when the token actually rotated — a CIFilter render per
                // poll tick for an unchanged URL is pure waste.
                pairingQR = url.flatMap(Self.qrImage(for:))
            }
        } else {
            pairingDaemonReportsEnabled = false
            pairingURL = nil
            pairingQR = nil
        }
        if case let .mobileClients(devices)? =
            await SessionCoordinator.shared.requestDaemon(.mobileListClients) {
            pairedDevices = devices
        }
    }

    /// CIQRCodeGenerator emits 1pt/module; integer-upscale via CoreImage (crisp by
    /// construction), and the view's `.interpolation(.none)` handles the final fit.
    private static func qrImage(for string: String) -> NSImage? {
        guard let data = string.data(using: .utf8),
              let filter = CIFilter(name: "CIQRCodeGenerator")
        else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")
        guard let output = filter.outputImage else { return nil }
        let scaled = output.transformed(by: CGAffineTransform(scaleX: 8, y: 8))
        let rep = NSCIImageRep(ciImage: scaled)
        let image = NSImage(size: rep.size)
        image.addRepresentation(rep)
        return image
    }

    // MARK: - Host list panel

    private var hostListPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            List(hosts, selection: $selectedID) { host in
                let active = RemoteHostsService.shared.activeHostName == host.name
                VStack(alignment: .leading, spacing: 2) {
                    Text(active ? "\(host.name)  •" : host.name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(active ? Color.accentColor : Color.primary)
                    Text(host.sshTarget)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                .tag(host.name)
            }
            .frame(width: 280, height: 300)
            .border(Color(nsColor: .separatorColor))

            HStack(spacing: 8) {
                Button("+") { addHost() }
                Button("-") { removeSelectedHost() }
                    .disabled(selectedID == nil)
                Button("Duplicate") { duplicateSelectedHost() }
                    .disabled(selectedID == nil)
            }
            .controlSize(.small)
        }
    }

    // MARK: - Host form panel

    private var hostFormPanel: some View {
        Form {
            Section("Host") {
                LabeledContent("Name") {
                    TextField("devbox", text: $editName)
                        .frame(width: 280)
                }
                LabeledContent("SSH target") {
                    TextField("user@host", text: $editTarget)
                        .frame(width: 280)
                }
                LabeledContent("Port") {
                    TextField("22", text: $editPort)
                        .frame(width: 100)
                }
                LabeledContent("Identity file") {
                    HStack(spacing: 8) {
                        TextField("~/.ssh/id_ed25519", text: $editIdentity)
                            .frame(width: 230)
                        Button("…") { chooseIdentityFile() }
                    }
                }
                LabeledContent("Jump host") {
                    TextField("jump-host", text: $editJump)
                        .frame(width: 280)
                }
                LabeledContent("Agent forwarding") {
                    Toggle("", isOn: $editAgentForwarding)
                        .labelsHidden()
                        .help("Forward SSH_AUTH_SOCK (-A) so git/gh on the remote can use your local keys")
                }
                LabeledContent("Socket path") {
                    HStack(spacing: 8) {
                        TextField("/home/user/.config/kouen/kouen.sock", text: $editSocket)
                            .frame(width: 230)
                        Button(isDetectingSocket ? "Detecting…" : "Detect") { detectSocketPath() }
                            .disabled(isDetectingSocket
                                || editTarget.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }

                HStack(spacing: 8) {
                    Button("Save") { saveHost() }
                    Button("Revert") { syncFormFromSelection(id: selectedID) }
                    Button("Connect") { connectToSelected() }
                        .disabled(!canConnect)
                    Button("Disconnect") { disconnectHost() }
                        .disabled(RemoteHostsService.shared.activeHostName == nil)
                }

                if !statusMessage.isEmpty {
                    Text(statusMessage)
                        .font(.system(size: 11.5))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .formStyle(.grouped)
    }

    // MARK: - Helpers

    private var selectedHost: RemoteHost? {
        hosts.first { $0.name == selectedID }
    }

    private var canConnect: Bool {
        let active = RemoteHostsService.shared.activeHostName
        let hasSelection = selectedID != nil
        let trimmedName = editName.trimmingCharacters(in: .whitespacesAndNewlines)
        let formFilled = !trimmedName.isEmpty
            && !editTarget.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !editSocket.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let targetName = selectedID ?? (trimmedName.isEmpty ? nil : trimmedName)
        return (hasSelection || formFilled) && active != targetName
    }

    private func reloadHosts(selecting name: String? = nil) {
        hosts = RemoteHostsService.shared.hosts().sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
        let target = name ?? selectedID ?? hosts.first?.name
        selectedID = hosts.first(where: { $0.name == target })?.name
    }

    private func syncFormFromSelection(id: String?) {
        let host = id.flatMap { n in hosts.first { $0.name == n } }
        editName = host?.name ?? ""
        editTarget = host?.sshTarget ?? ""
        editPort = host?.sshArgValue(after: "-p") ?? ""
        editIdentity = host?.sshArgValue(after: "-i") ?? ""
        editJump = host?.sshArgValue(after: "-J") ?? ""
        editAgentForwarding = host?.sshArgs.contains("-A") ?? false
        editSocket = host?.remoteSocketPath ?? ""
        refreshStatus()
    }

    private func refreshStatus(_ override: String? = nil) {
        let active = RemoteHostsService.shared.activeHostName
        statusMessage = override ?? (active.map { "Connected: \($0)" } ?? "Local daemon")
    }

    private func addHost() {
        selectedID = nil
        editName = ""; editTarget = ""; editPort = ""
        editIdentity = ""; editJump = ""; editSocket = ""
        editAgentForwarding = false
        refreshStatus("New host")
    }

    private func removeSelectedHost() {
        guard let name = selectedID else { return }
        RemoteHostsService.shared.removeHost(named: name)
        reloadHosts(selecting: nil)
        syncFormFromSelection(id: selectedID)
    }

    private func duplicateSelectedHost() {
        guard let original = selectedHost else { return }
        var copy = original
        copy.name = uniqueName(base: "\(original.name)-copy")
        RemoteHostsService.shared.addHost(copy)
        reloadHosts(selecting: copy.name)
        syncFormFromSelection(id: selectedID)
    }

    private func saveHost() {
        let name = editName.trimmingCharacters(in: .whitespacesAndNewlines)
        let target = editTarget.trimmingCharacters(in: .whitespacesAndNewlines)
        let socket = editSocket.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty, !target.isEmpty, !socket.isEmpty else {
            refreshStatus("Name, SSH target, and socket path are required.")
            return
        }
        var args: [String] = []
        appendSSHArg("-p", editPort, to: &args)
        appendSSHArg("-i", editIdentity, to: &args)
        appendSSHArg("-J", editJump, to: &args)
        if editAgentForwarding { args.append("-A") }
        let host = RemoteHost(name: name, sshTarget: target, remoteSocketPath: socket, sshArgs: args)
        let oldName = selectedID
        let isRename = oldName != nil && oldName != name
        if isRename, hosts.contains(where: { $0.name == name }) {
            refreshStatus("A host named '\(name)' already exists.")
            return
        }
        let wasActive = isRename && RemoteHostsService.shared.activeHostName == oldName
        if isRename { RemoteHostsService.shared.removeHost(named: oldName!) }
        RemoteHostsService.shared.addHost(host)
        if wasActive { SessionCoordinator.shared.connectToRemote(named: name) }
        reloadHosts(selecting: name)
        syncFormFromSelection(id: selectedID)
        refreshStatus("Saved \(name)")
    }

    private func connectToSelected() {
        let name: String
        if let selected = selectedID {
            name = selected
        } else {
            let n = editName.trimmingCharacters(in: .whitespacesAndNewlines)
            let target = editTarget.trimmingCharacters(in: .whitespacesAndNewlines)
            let socket = editSocket.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !n.isEmpty, !target.isEmpty, !socket.isEmpty else {
                refreshStatus("Name, SSH target, and socket path are required.")
                return
            }
            var args: [String] = []
            appendSSHArg("-p", editPort, to: &args)
            appendSSHArg("-i", editIdentity, to: &args)
            appendSSHArg("-J", editJump, to: &args)
            let host = RemoteHost(name: n, sshTarget: target, remoteSocketPath: socket, sshArgs: args)
            RemoteHostsService.shared.addHost(host)
            reloadHosts(selecting: n)
            name = n
        }
        refreshStatus("Connecting to \(name)…")
        SessionCoordinator.shared.connectToRemote(named: name)
    }

    private func disconnectHost() {
        SessionCoordinator.shared.disconnectRemote()
        reloadHosts(selecting: selectedID)
        refreshStatus()
    }

    private func chooseIdentityFile() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.title = "Choose SSH Identity"
        if panel.runModal() == .OK, let url = panel.url {
            editIdentity = url.path
        }
    }

    private func detectSocketPath() {
        let target = editTarget.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !target.isEmpty else { return }
        var args: [String] = []
        appendSSHArg("-p", editPort, to: &args)
        appendSSHArg("-i", editIdentity, to: &args)
        appendSSHArg("-J", editJump, to: &args)
        isDetectingSocket = true
        refreshStatus("Detecting socket path on \(target)…")
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let path = try RemoteHostsService.shared.detectSocketPath(sshTarget: target, sshArgs: args)
                DispatchQueue.main.async {
                    editSocket = path
                    isDetectingSocket = false
                    refreshStatus("Detected socket path.")
                }
            } catch {
                DispatchQueue.main.async {
                    isDetectingSocket = false
                    refreshStatus("⚠️ Detect failed: \(error)")
                }
            }
        }
    }

    private func appendSSHArg(_ flag: String, _ value: String, to args: inout [String]) {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        args.append(flag)
        args.append(trimmed)
    }

    private func uniqueName(base: String) -> String {
        var candidate = base
        var suffix = 2
        let existing = Set(RemoteHostsService.shared.hosts().map(\.name))
        while existing.contains(candidate) {
            candidate = "\(base)-\(suffix)"
            suffix += 1
        }
        return candidate
    }
}

private extension RemoteHost {
    func sshArgValue(after flag: String) -> String? {
        if let index = sshArgs.firstIndex(of: flag) {
            let valueIndex = sshArgs.index(after: index)
            if sshArgs.indices.contains(valueIndex) { return sshArgs[valueIndex] }
        }
        if let glued = sshArgs.first(where: { $0.hasPrefix(flag) && $0 != flag }) {
            return String(glued.dropFirst(flag.count))
        }
        return nil
    }
}
