import AppKit
import HarnessCore
import HarnessTerminalEngine
import HarnessTerminalKit

extension SessionCoordinator: TerminalHostDelegate {
    func terminalHostDidChangeTitle(_ title: String, surfaceID: SurfaceID) {
        Task {
            await daemonSyncService.logIfFailed(.updateTabTitle(surfaceID: surfaceID.uuidString, title: title))
            await syncFromDaemon(metadataOnly: true)
        }
    }

    func terminalHostDidUpdateProgress(_ report: TerminalProgressReport, surfaceID: SurfaceID) {
        SurfaceProgressTracker.shared.update(report, forSurface: surfaceID)
    }

    func terminalHostDidChangeWorkingDirectory(_ path: String, surfaceID: SurfaceID) {
        Task {
            await daemonSyncService.logIfFailed(.updateTabCwd(surfaceID: surfaceID.uuidString, path: path))
            await syncFromDaemon(metadataOnly: true)
        }
    }

    func surfaceShellTrackerDidUpdateCwd(_ surfaceID: SurfaceID, cwd: String) {
        let current = snapshot.workspaces.flatMap { $0.sessions.flatMap { $0.tabs } }
            .first { $0.rootPane.allSurfaceIDs().contains(surfaceID) }?.cwd
        if current == cwd { return }
        Task {
            await daemonSyncService.logIfFailed(.updateTabCwd(surfaceID: surfaceID.uuidString, path: cwd))
            await syncFromDaemon(metadataOnly: true)
        }
    }

    func terminalHostDidChangeFocus(_ focused: Bool, surfaceID: SurfaceID) {
        guard focused else { return }
        setActiveSurface(surfaceID)
        guard tabIsWaiting(forSurface: surfaceID) else { return }
        clearNotification(for: surfaceID)
    }

    func terminalHostDidRingBell(surfaceID: SurfaceID) {
        handleNotification(for: surfaceID, event: .bell, title: "Terminal", body: "Bell")
    }

    func terminalHostDidFinishCommand(duration: TimeInterval, exitCode: Int?, surfaceID: SurfaceID) {
        guard settings.isEventEnabled(.commandFinished),
              duration >= Double(max(0, settings.commandFinishedThresholdSeconds)) else { return }
        if NSApp.isActive, surfaceID == activeSurfaceID { return }
        let code = exitCode ?? 0
        let status = code == 0 ? "succeeded" : "failed (exit \(code))"
        notificationCoordinator.deliverAgentAlert(event: .commandFinished, title: "Command \(status)", body: "Ran for \(formatDuration(duration)).")
    }

    func terminalHostDidRequestDesktopNotification(title: String, body: String, surfaceID: SurfaceID) {
        handleNotification(for: surfaceID, event: .agentWaiting, title: title, body: body)
    }

    func terminalHostDidClose(surfaceID: SurfaceID) {
        terminalHosts.removeHost(for: surfaceID)
        SurfaceProgressTracker.shared.forget(surfaceID)
    }
}

// MARK: - Helpers used by HostDelegate

extension SessionCoordinator {
    func tabIsWaiting(forSurface surfaceID: SurfaceID) -> Bool {
        snapshot.workspaces.flatMap { $0.sessions.flatMap { $0.tabs } }
            .first { $0.rootPane.allSurfaceIDs().contains(surfaceID) }?.status == .waiting
    }

    func formatDuration(_ seconds: TimeInterval) -> String {
        let total = Int(seconds.rounded())
        if total < 60 { return "\(total)s" }
        let minutes = total / 60, secs = total % 60
        if minutes < 60 { return secs == 0 ? "\(minutes)m" : "\(minutes)m \(secs)s" }
        let hours = minutes / 60, mins = minutes % 60
        return mins == 0 ? "\(hours)h" : "\(hours)h \(mins)m"
    }

    func clearNotification(for surfaceID: SurfaceID) {
        requestDaemon(.clearNotification(surfaceID: surfaceID.uuidString))
        syncFromDaemon()
    }
}
