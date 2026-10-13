import Foundation
import HarnessCore
import HarnessTerminalEngine

/// Request handlers that `handle(_:)` calls with `lock` held.
extension SurfaceRegistry {
    private static let inputRejected =
        "Input was not accepted: the pane is closed or its input queue is full. Wait for the program to read input, then try again."

    func snoozeAttentionLocked(surfaceID: String, minutes: Int) -> IPCResponse {
        guard let id = UUID(uuidString: surfaceID), [0, 15, 60].contains(minutes) else {
            return .error("Snooze must be 0, 15, or 60 minutes")
        }
        guard editor.snapshot.workspaces.flatMap(\.sessions).flatMap(\.tabs).contains(where: { $0.rootPane.allSurfaceIDs().contains(id) }) else { return .error("Pane not found") }
        if editor.updatePaneActivity(surfaceID: id, {
            $0.snoozedUntil = minutes == 0 ? nil : Date().addingTimeInterval(Double(minutes * 60))
        }) { commit() }
        return .ok
    }

    func notifyLocked(surfaceID: String, title: String, body: String) -> IPCResponse {
        let notification = AgentNotification(
            surfaceID: UUID(uuidString: surfaceID),
            daemonSurfaceID: surfaceID,
            title: title,
            body: body
        )
        let snoozed = editor.listAttention().first { $0.surfaceID.uuidString == surfaceID }?.activity.isSnoozed ?? false
        if !snoozed {
            NotificationBus.shared.post(notification)
            let runID = activity.currentRun(surfaceID: surfaceID)?.id
            notifications.submit(NotificationNotice(surfaceID: surfaceID, runID: runID, event: .agentWaiting, title: title, message: body))
        }
        markWaiting(surfaceKey: surfaceID, text: body)
        noteProgramStatusNotifiedLocked(surfaceID)
        commit()
        fireHookLocked(.notificationPosted, surfaceKey: surfaceID)
        return .ok
    }

    func previewPaneLocked(
        surfaceID: String, specification: PreviewSpecification, updateExisting: Bool, capabilities: [String]
    ) -> IPCResponse {
        guard capabilities.contains(DaemonStats.paneContent) else { return .error(PreviewError.unsupported.localizedDescription) }
        do { _ = try specification.validatedURL() } catch { return .error(error.localizedDescription) }
        guard let source = UUID(uuidString: surfaceID), let location = editor.paneLocation(forSurfaceKey: surfaceID),
              let workspace = editor.snapshot.workspaces.first(where: { workspace in
                  workspace.sessions.contains { $0.tabs.contains { $0.id == location.tabID } }
              }),
              let tab = workspace.sessions.flatMap(\.tabs).first(where: { $0.id == location.tabID }),
              let leaf = tab.rootPane.allLeaves().first(where: { $0.surfaceID == source })
        else { return .error("The selected pane has closed.") }
        if updateExisting {
            guard case .preview = leaf.paneContent, sessions[surfaceID] == nil else {
                return .error("Only an existing preview can change its URL. Create a new preview beside a terminal to preserve its shell.")
            }
            _ = editor.setPaneContent(surfaceID: source, content: .preview(specification)); commit(); return .paneID(leaf.id)
        }
        guard let id = editor.splitPane(in: workspace.id, tabID: tab.id, paneID: leaf.id, direction: .horizontal),
              let newSurface = editor.surfaceID(forPaneID: id)
        else { return .error("Could not create a preview pane.") }
        _ = editor.setPaneContent(surfaceID: newSurface, content: .preview(specification))
        commit(); return .paneID(id)
    }

    func createSurfaceLocked(cwd: String?, shell: String?) -> IPCResponse {
        let surfaceID = UUID().uuidString
        return createOrEnsureSurface(
            surfaceID: surfaceID,
            cwd: cwd,
            shell: shell,
            rows: 24,
            cols: 80,
            scrollbackBytes: nil,
            freshlyCreated: true
        ).map { .surfaceID($0) } ?? .error("Failed to launch shell")
    }

    func ensureSurfaceLocked(
        surfaceID: String, cwd: String?, shell: String?, rows: UInt16, cols: UInt16, scrollbackBytes: Int?, requireInLayout: Bool?
    ) -> IPCResponse {
        guard TerminalGeometry.isValid(cols: Int(cols), rows: Int(rows)) else {
            return .error("Terminal dimensions exceed the supported grid limit.")
        }
        let tabs = editor.snapshot.workspaces.flatMap(\.sessions).flatMap(\.tabs)
        if requireInLayout == true, !tabs.contains(where: { $0.rootPane.allSurfaceIDs().contains { $0.uuidString == surfaceID } }) {
            return .error("This pane has closed.")
        }
        return createOrEnsureSurface(
            surfaceID: surfaceID,
            cwd: cwd,
            shell: shell,
            rows: rows,
            cols: cols,
            scrollbackBytes: scrollbackBytes
        ).map { _ in .ok } ?? .error("Failed to launch shell")
    }

    func getBufferLocked(name: String?) -> IPCResponse {
        let buffer: PasteBufferStore.Buffer?
        if let name { buffer = bufferStore.get(name) }
        else { buffer = bufferStore.mostRecent() }
        guard let buffer else { return .error("Buffer not found") }
        return .buffer(BufferSummary(
            name: buffer.name,
            byteCount: buffer.data.count,
            preview: buffer.preview,
            createdAt: buffer.createdAt,
            data: buffer.data
        ))
    }

    func pasteBufferLocked(surfaceID: String, name: String?, bracketed: Bool) -> IPCResponse {
        guard let session = sessions[surfaceID] else { return .error("Surface not found") }
        let buffer: PasteBufferStore.Buffer?
        if let name { buffer = bufferStore.get(name) }
        else { buffer = bufferStore.mostRecent() }
        guard let buffer else { return .error("Buffer not found") }
        if bracketed {
            // tmux `paste-buffer -p`: wrap in bracketed-paste markers so the
            // program treats it as a single pasted block (DECSET 2004).
            var out = Data("\u{1b}[200~".utf8)
            out.append(buffer.data)
            out.append(Data("\u{1b}[201~".utf8))
            guard session.write(out) else { return .error(Self.inputRejected) }
        } else {
            guard session.write(buffer.data) else { return .error(Self.inputRejected) }
        }
        return .ok
    }

    func surfaceContextLocked(surfaceID: String) -> IPCResponse {
        guard let session = sessions[surfaceID] else {
            return .error("Surface not found")
        }
        let probed = session.probeForegroundProcess()
        let command = session.probeForegroundArguments()
        return .text(ControlPlane.contextJSON(ControlPlane.SurfaceContext(
            pid: Int(probed?.pid ?? -1),
            executable: probed?.executable ?? "",
            cwd: session.currentWorkingDirectory() ?? "",
            arguments: command?.arguments ?? [],
            isShell: command?.isShell ?? false
        )))
    }
}
