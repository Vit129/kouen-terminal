import AppKit
import SwiftUI
import KouenCore

struct SettingsRemoteView: View {
    @State private var hosts: [RemoteHost] = []
    @State private var selectedID: String? = nil
    @State private var editName = ""
    @State private var editTarget = ""
    @State private var editPort = ""
    @State private var editIdentity = ""
    @State private var editJump = ""
    @State private var editSocket = ""
    @State private var statusMessage = ""
    @State private var isDetectingSocket = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
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
