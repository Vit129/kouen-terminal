import AppKit
import HarnessCore

extension SettingsViewController: NSTableViewDataSource, NSTableViewDelegate {
    // MARK: - Page: Remote

    func buildRemotePage() -> NSView {
        reloadRemoteHosts(selecting: selectedRemoteHostName)

        remoteHostsTable.delegate = self
        remoteHostsTable.dataSource = self
        remoteHostsTable.headerView = nil
        remoteHostsTable.rowHeight = 44
        remoteHostsTable.selectionHighlightStyle = .regular
        remoteHostsTable.allowsEmptySelection = true
        remoteHostsTable.allowsMultipleSelection = false
        if remoteHostsTable.tableColumns.isEmpty {
            let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("host"))
            column.title = "Host"
            remoteHostsTable.addTableColumn(column)
        }

        let tableScroll = NSScrollView()
        tableScroll.hasVerticalScroller = true
        tableScroll.drawsBackground = false
        tableScroll.documentView = remoteHostsTable
        tableScroll.translatesAutoresizingMaskIntoConstraints = false
        tableScroll.heightAnchor.constraint(equalToConstant: 300).isActive = true
        tableScroll.widthAnchor.constraint(equalToConstant: 280).isActive = true

        let addButton = NSButton(title: "+", target: self, action: #selector(addRemoteHostClicked))
        let removeButton = NSButton(title: "-", target: self, action: #selector(removeRemoteHostClicked))
        let duplicateButton = NSButton(title: "Duplicate", target: self, action: #selector(duplicateRemoteHostClicked))
        for button in [addButton, removeButton, duplicateButton] {
            button.bezelStyle = .rounded
            button.controlSize = .small
        }
        let hostActions = NSStackView(views: [addButton, removeButton, duplicateButton])
        hostActions.orientation = .horizontal
        hostActions.spacing = 8

        let listStack = NSStackView(views: [tableScroll, hostActions])
        listStack.orientation = .vertical
        listStack.alignment = .leading
        listStack.spacing = 10

        remoteNameField.widthAnchor.constraint(equalToConstant: 280).isActive = true
        remoteSSHTargetField.widthAnchor.constraint(equalToConstant: 280).isActive = true
        remotePortField.widthAnchor.constraint(equalToConstant: 100).isActive = true
        remoteIdentityField.widthAnchor.constraint(equalToConstant: 280).isActive = true
        remoteJumpHostField.widthAnchor.constraint(equalToConstant: 280).isActive = true
        remoteSocketPathField.widthAnchor.constraint(equalToConstant: 280).isActive = true

        remoteNameField.placeholderString = "devbox"
        remoteSSHTargetField.placeholderString = "user@host"
        remotePortField.placeholderString = "22"
        remoteIdentityField.placeholderString = "~/.ssh/id_ed25519"
        remoteJumpHostField.placeholderString = "jump-host"
        remoteSocketPathField.placeholderString = "~/.harness/harness.sock"

        let identityBrowse = NSButton(title: "…", target: self, action: #selector(chooseRemoteIdentityFile))
        identityBrowse.bezelStyle = .rounded
        let identityRow = NSStackView(views: [remoteIdentityField, identityBrowse])
        identityRow.orientation = .horizontal
        identityRow.spacing = 8

        let saveButton = NSButton(title: "Save", target: self, action: #selector(saveRemoteHostClicked))
        saveButton.bezelStyle = .rounded
        let revertButton = NSButton(title: "Revert", target: self, action: #selector(revertRemoteHostClicked))
        revertButton.bezelStyle = .rounded
        remoteConnectButton.target = self
        remoteConnectButton.action = #selector(connectRemoteHostClicked)
        remoteConnectButton.bezelStyle = .rounded
        remoteDisconnectButton.target = self
        remoteDisconnectButton.action = #selector(disconnectRemoteHostClicked)
        remoteDisconnectButton.bezelStyle = .rounded

        let actionRow = NSStackView(views: [saveButton, revertButton, remoteConnectButton, remoteDisconnectButton])
        actionRow.orientation = .horizontal
        actionRow.spacing = 8

        remoteHostsStatusField.font = .systemFont(ofSize: 11.5)
        remoteHostsStatusField.textColor = .secondaryLabelColor
        remoteHostsStatusField.maximumNumberOfLines = 2

        let form = settingsGroup("Host", [
            settingsRow("Name", remoteNameField),
            settingsRow("SSH target", remoteSSHTargetField),
            settingsRow("Port", remotePortField),
            settingsRow("Identity file", identityRow),
            settingsRow("Jump host", remoteJumpHostField),
            settingsRow("Socket path", remoteSocketPathField),
            leadingRow(actionRow),
            remoteHostsStatusField,
        ])

        let columns = NSStackView(views: [listStack, form])
        columns.orientation = .horizontal
        columns.alignment = .top
        columns.spacing = 24

        let stack = NSStackView(views: [
            pageHeader(title: "Remote"),
            settingsCaption("Saved SSH tunnels to remote Harness daemons. TCP remains disabled until it has a TLS layer."),
            columns,
        ])
        stack.orientation = .vertical
        stack.alignment = .width
        stack.spacing = 18
        stack.translatesAutoresizingMaskIntoConstraints = false
        syncRemoteFormFromSelection()
        return scrollWrap(stack)
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        tableView === remoteHostsTable ? remoteHosts.count : 0
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard tableView === remoteHostsTable, remoteHosts.indices.contains(row) else { return nil }
        let id = NSUserInterfaceItemIdentifier("RemoteHostCell")
        let host = remoteHosts[row]
        let active = RemoteHostsService.shared.activeHostName == host.name
        let cell = tableView.makeView(withIdentifier: id, owner: self) as? NSTableCellView ?? NSTableCellView()
        cell.identifier = id
        cell.subviews.forEach { $0.removeFromSuperview() }

        let name = NSTextField(labelWithString: active ? "\(host.name)  •" : host.name)
        name.font = .systemFont(ofSize: 13, weight: .semibold)
        name.textColor = active ? HarnessChrome.current.accent : .labelColor
        let target = NSTextField(labelWithString: host.sshTarget)
        target.font = .systemFont(ofSize: 11)
        target.textColor = .secondaryLabelColor
        target.lineBreakMode = .byTruncatingMiddle
        let stack = NSStackView(views: [name, target])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        cell.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -8),
            stack.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
        ])
        return cell
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        guard notification.object as? NSTableView === remoteHostsTable else { return }
        let row = remoteHostsTable.selectedRow
        selectedRemoteHostName = remoteHosts.indices.contains(row) ? remoteHosts[row].name : nil
        syncRemoteFormFromSelection()
    }

    private func reloadRemoteHosts(selecting name: String?) {
        remoteHosts = RemoteHostsService.shared.hosts().sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        remoteHostsTable.reloadData()
        let selectionName = name ?? remoteHosts.first?.name
        if let selectionName, let index = remoteHosts.firstIndex(where: { $0.name == selectionName }) {
            remoteHostsTable.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
            selectedRemoteHostName = selectionName
        } else {
            selectedRemoteHostName = nil
        }
    }

    private func syncRemoteFormFromSelection() {
        let host = selectedRemoteHostName.flatMap { name in remoteHosts.first { $0.name == name } }
        remoteNameField.stringValue = host?.name ?? ""
        remoteSSHTargetField.stringValue = host?.sshTarget ?? ""
        remotePortField.stringValue = host?.sshArgValue(after: "-p") ?? ""
        remoteIdentityField.stringValue = host?.sshArgValue(after: "-i") ?? ""
        remoteJumpHostField.stringValue = host?.sshArgValue(after: "-J") ?? ""
        remoteSocketPathField.stringValue = host?.remoteSocketPath ?? ""
        refreshRemoteStatus()
    }

    private func refreshRemoteStatus(_ override: String? = nil) {
        let active = RemoteHostsService.shared.activeHostName
        let prefix = active.map { "Connected: \($0)" } ?? "Local daemon"
        remoteHostsStatusField.stringValue = override ?? prefix
        let hasSelection = selectedRemoteHostName != nil
        remoteConnectButton.isEnabled = hasSelection && active != selectedRemoteHostName
        remoteDisconnectButton.isEnabled = active != nil
    }

    private func remoteHostFromForm() -> RemoteHost? {
        let name = remoteNameField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let target = remoteSSHTargetField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let socket = remoteSocketPathField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty, !target.isEmpty, !socket.isEmpty else { return nil }
        var args: [String] = []
        appendSSHArg("-p", remotePortField.stringValue, to: &args)
        appendSSHArg("-i", remoteIdentityField.stringValue, to: &args)
        appendSSHArg("-J", remoteJumpHostField.stringValue, to: &args)
        return RemoteHost(name: name, sshTarget: target, remoteSocketPath: socket, sshArgs: args)
    }

    private func appendSSHArg(_ flag: String, _ value: String, to args: inout [String]) {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        args.append(flag)
        args.append(trimmed)
    }

    @objc private func addRemoteHostClicked() {
        selectedRemoteHostName = nil
        remoteHostsTable.deselectAll(nil)
        remoteNameField.stringValue = ""
        remoteSSHTargetField.stringValue = ""
        remotePortField.stringValue = ""
        remoteIdentityField.stringValue = ""
        remoteJumpHostField.stringValue = ""
        remoteSocketPathField.stringValue = ""
        refreshRemoteStatus("New host")
    }

    @objc private func removeRemoteHostClicked() {
        guard let name = selectedRemoteHostName else { return }
        RemoteHostsService.shared.removeHost(named: name)
        reloadRemoteHosts(selecting: nil)
        syncRemoteFormFromSelection()
    }

    @objc private func duplicateRemoteHostClicked() {
        guard let original = selectedRemoteHostName.flatMap({ name in remoteHosts.first { $0.name == name } }) else { return }
        var copy = original
        copy.name = uniqueRemoteName(base: "\(original.name)-copy")
        RemoteHostsService.shared.addHost(copy)
        reloadRemoteHosts(selecting: copy.name)
        syncRemoteFormFromSelection()
    }

    @objc private func saveRemoteHostClicked() {
        guard let host = remoteHostFromForm() else {
            refreshRemoteStatus("Name, SSH target, and socket path are required.")
            return
        }
        if let oldName = selectedRemoteHostName, oldName != host.name {
            RemoteHostsService.shared.removeHost(named: oldName)
        }
        RemoteHostsService.shared.addHost(host)
        reloadRemoteHosts(selecting: host.name)
        syncRemoteFormFromSelection()
        refreshRemoteStatus("Saved \(host.name)")
    }

    @objc private func revertRemoteHostClicked() {
        reloadRemoteHosts(selecting: selectedRemoteHostName)
        syncRemoteFormFromSelection()
    }

    @objc private func connectRemoteHostClicked() {
        if let host = remoteHostFromForm() {
            RemoteHostsService.shared.addHost(host)
            selectedRemoteHostName = host.name
            reloadRemoteHosts(selecting: host.name)
        }
        guard let name = selectedRemoteHostName else { return }
        refreshRemoteStatus("Connecting to \(name)…")
        SessionCoordinator.shared.connectToRemote(named: name)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.reloadRemoteHosts(selecting: name)
            self?.refreshRemoteStatus()
        }
    }

    @objc private func disconnectRemoteHostClicked() {
        SessionCoordinator.shared.disconnectRemote()
        reloadRemoteHosts(selecting: selectedRemoteHostName)
        refreshRemoteStatus()
    }

    @objc private func chooseRemoteIdentityFile() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.title = "Choose SSH Identity"
        if panel.runModal() == .OK, let url = panel.url {
            remoteIdentityField.stringValue = url.path
        }
    }

    private func uniqueRemoteName(base: String) -> String {
        var candidate = base
        var suffix = 2
        let existing = Set(remoteHosts.map(\.name))
        while existing.contains(candidate) {
            candidate = "\(base)-\(suffix)"
            suffix += 1
        }
        return candidate
    }
}

private extension RemoteHost {
    func sshArgValue(after flag: String) -> String? {
        guard let index = sshArgs.firstIndex(of: flag) else { return nil }
        let valueIndex = sshArgs.index(after: index)
        return sshArgs.indices.contains(valueIndex) ? sshArgs[valueIndex] : nil
    }
}
