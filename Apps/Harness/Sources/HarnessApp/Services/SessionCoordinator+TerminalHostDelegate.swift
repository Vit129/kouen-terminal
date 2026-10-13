import AVFoundation
import AppKit
import Foundation
import HarnessCore
import HarnessTerminalEngine
import HarnessTerminalKit
import HarnessTheme
import Network
import UserNotifications

extension SessionCoordinator: TerminalHostDelegate {
    func terminalHostDidChangeTitle(_ title: String, surfaceID: SurfaceID) {
        logIfFailed(.updateTabTitle(surfaceID: surfaceID.uuidString, title: title), surface: surfaceID)
        refreshSnapshot()
    }

    /// OSC 9;4 progress — ephemeral GUI state, deliberately NOT mirrored
    /// to the daemon: keep-alives arrive ~1/s per working agent and must not churn
    /// layout.json commits. The tracker nudges a metadata-only tab refresh on transitions.
    func terminalHostDidUpdateProgress(_ report: TerminalProgressReport, surfaceID: SurfaceID) {
        SurfaceProgressTracker.shared.update(report, forSurface: surfaceID)
    }

    func terminalHostDidChangeWorkingDirectory(_ path: String, surfaceID: SurfaceID) {
        logIfFailed(.updateTabCwd(surfaceID: surfaceID.uuidString, path: path), surface: surfaceID)
        refreshSnapshot()
    }

    /// OSC 1337 `SetUserVar=` → a pane-scoped `@name` user option, so `#{@name}` format
    /// tokens (status line, pane borders, hooks) read it like any other user option. The
    /// engine already validated and bounded the name/value; `@`-options always pass the
    /// daemon's key validation. Pushes are coalesced (see `pendingUserVariables`) — the
    /// engine dedupes same-value rewrites, this bounds genuinely-changing floods.
    func terminalHostDidSetUserVariable(_ name: String, value: String, surfaceID: SurfaceID) {
        var names = pushedUserVariableNames[surfaceID, default: []]
        if !names.contains(name) {
            // Per-surface name cap, mirroring the engine's: defense in depth so a hostile
            // stream can't grow options.json even if the engine's own bound regresses.
            guard names.count < Self.maxUserVariablesPerSurface else { return }
            names.insert(name)
            pushedUserVariableNames[surfaceID] = names
        }
        pendingUserVariables[surfaceID, default: [:]][name] = value
        scheduleUserVariableFlush()
    }

    /// RIS dropped the engine's user variables — reset the daemon mirror so `#{@name}`
    /// stops serving pre-reset values. There is no unset IPC, so each pushed name is set
    /// to "" (renders as empty in formats) via the same coalesced path; the bookkeeping
    /// is forgotten so the name cap re-arms for the post-reset epoch.
    func terminalHostDidClearUserVariables(surfaceID: SurfaceID) {
        guard let names = pushedUserVariableNames.removeValue(forKey: surfaceID), !names.isEmpty else { return }
        for name in names { pendingUserVariables[surfaceID, default: [:]][name] = "" }
        scheduleUserVariableFlush()
    }

    /// One short debounce window shared by all surfaces: `SetUserVar` can arrive in bursts
    /// (a status updater in a shell loop) and each daemon round trip is synchronous on main.
    private func scheduleUserVariableFlush() {
        guard !userVariableFlushScheduled else { return }
        userVariableFlushScheduled = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self else { return }
            self.userVariableFlushScheduled = false
            let pending = self.pendingUserVariables
            self.pendingUserVariables = [:]
            for (surfaceID, variables) in pending {
                for (name, value) in variables {
                    self.logIfFailed(.setOption(
                        scope: "pane", target: surfaceID.uuidString, key: "@\(name)", rawValue: value), surface: surfaceID)
                }
            }
        }
    }

    func terminalHostDidChangeFocus(_ focused: Bool, surfaceID: SurfaceID) {
        guard focused else { return }
        setActiveSurface(surfaceID)
        // Focus-in now fires on every click-into / ⌘-Tab-back (not only tab switches), so
        // gate the clear on the local `.waiting` state: `clearNotification` does a main-thread
        // `requestDaemon` + full `syncFromDaemon`, and there's nothing to clear on a pane with
        // no badge. The snapshot lookup is cheap and keeps the hot path off the daemon.
        guard tabIsWaiting(forSurface: surfaceID) else { return }
        clearNotification(for: surfaceID)
    }

    /// Whether the tab owning `surfaceID` currently shows a `.waiting` notification, read from
    /// the local snapshot (no daemon round-trip).
    private func tabIsWaiting(forSurface surfaceID: SurfaceID) -> Bool {
        snapshot.workspaces
            .flatMap { workspace in workspace.sessions.flatMap { $0.tabs } }
            .first { $0.rootPane.allSurfaceIDs().contains(surfaceID) }?
            .status == .waiting
    }

    func terminalHostDidRingBell(surfaceID: SurfaceID) {
        // In-app feedback for the ringing surface, honored on every BEL regardless of focus
        // (a focused bell was previously silent). The GUI `bellMode` setting decides, with the
        // tmux `visual-bell`/`bell-action` options bridging in via the shared resolver.
        let visualBell = HarnessOptions.shared.get("visual-bell", scope: .global)?.stringValue
        let bellAction = HarnessOptions.shared.get("bell-action", scope: .global)?.stringValue
        let effect = BellFeedback.resolve(mode: settings.bellMode, visualBell: visualBell, bellAction: bellAction)
        if effect.audible { NSSound.beep() }
        if effect.visual { terminalHosts.host(for: surfaceID)?.flashBell() }
        // tmux `bell-action off`/`none` silences the alert path too; otherwise keep the existing
        // tab bell-flag + (unfocused) OS-banner notification.
        if bellAction == "off" || bellAction == "none" { return }
        if notificationOwners[notificationOwner(for: surfaceID)] == true { return }
        handleNotification(for: surfaceID, event: .bell, title: "Terminal", body: "Bell")
    }

    func terminalHostDidFinishCommand(duration: TimeInterval, exitCode: Int?, surfaceID: SurfaceID) {
        // Every finished command updates `#{command_duration}` — the notification below stays
        // gated on the event toggle + threshold.
        lastCommandDurations[surfaceID] = duration
        guard notificationOwners[notificationOwner(for: surfaceID)] != true, settings.isEventEnabled(.commandFinished),
              duration >= Double(max(0, settings.commandFinishedThresholdSeconds)) else { return }
        // Only notify when this pane isn't the one being actively watched.
        if NSApp.isActive, surfaceID == activeSurfaceID { return }
        let code = exitCode ?? 0
        let status = code == 0 ? "succeeded" : "failed (exit \(code))"
        deliverAgentAlert(event: .commandFinished, title: "Command \(status)", body: "Ran for \(Self.formatDuration(duration)).")
    }

    private static func formatDuration(_ seconds: TimeInterval) -> String {
        let total = Int(seconds.rounded())
        if total < 60 { return "\(total)s" }
        let minutes = total / 60, secs = total % 60
        if minutes < 60 { return secs == 0 ? "\(minutes)m" : "\(minutes)m \(secs)s" }
        let hours = minutes / 60, mins = minutes % 60
        return mins == 0 ? "\(hours)h" : "\(hours)h \(mins)m"
    }

    func terminalHostDidRequestDesktopNotification(title: String, body: String, surfaceID: SurfaceID) {
        guard notificationOwners[notificationOwner(for: surfaceID)] != true else { return }
        handleNotification(for: surfaceID, event: .agentWaiting, title: title, body: body)
    }

    /// A `notify`-action output trigger matched (the surface already applied the per-rule
    /// cooldown). Routes through the same notification path as a program's OSC 9 — the rule
    /// itself is the opt-in, so there is no separate per-event toggle to trip over.
    func terminalHostDidMatchTrigger(_ rule: TriggerRule, lineText: String, surfaceID: SurfaceID) {
        handleNotification(
            for: surfaceID, event: .agentWaiting,
            title: "Trigger: \(rule.pattern)", body: lineText
        )
    }

    func terminalHostScriptActionFinished(_ result: ScriptActionResult, surfaceID: SurfaceID) {
        Self.applyScriptResult(result)
    }

    func terminalHostShowMessage(_ message: String, surfaceID: SurfaceID) {
        DisplayMessage.show(message)
    }

    func terminalHostSizeOwnershipChanged(_ ownership: SizeOwnership, surfaceID: SurfaceID) {
        NotificationCenter.default.post(name: .harnessSizeOwnershipDidChange, object: nil)
    }

    /// Copy a command that watches `surfaceID` read-only from any terminal: no typing, no
    /// resizing. A pane on a saved remote host gets `--host`.
    func copyWatchCommand(for surfaceID: SurfaceID) {
        var words = ["harness-cli"]
        if let host = RemoteHostsService.shared.activeHostName { words += ["--host", ShellQuoting.quote(host)] }
        words += ["attach", "--read-only", "--surface", surfaceID.uuidString]
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(words.joined(separator: " "), forType: .string)
        DisplayMessage.show("Copied a read-only attach command")
    }

    /// Make this window's size the active pane's size, when another client owns it.
    func takeActivePaneSize() {
        guard let surfaceID = activeSurfaceID else { return }
        terminalHostIfExists(for: surfaceID)?.takeSize()
    }

    /// Show a Lua action's failure and run the commands it queued with `harness.queue`,
    /// through the same executor as the `:` prompt and key bindings.
    static func applyScriptResult(_ result: ScriptActionResult) {
        if let failure = result.failure { DisplayMessage.show(failure) }
        for command in result.queued {
            do {
                try MainExecutor.shared.executeSource(command)
            } catch {
                DisplayMessage.show("queued command failed: \(command): \(error)")
                return
            }
        }
    }

    func terminalHostDidClose(surfaceID: SurfaceID) {
        terminalHosts.removeHost(for: surfaceID)
        SurfaceProgressTracker.shared.forget(surfaceID)
    }
}
