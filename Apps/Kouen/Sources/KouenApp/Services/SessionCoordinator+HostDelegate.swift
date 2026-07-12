import AppKit
import KouenCore
import KouenTerminalEngine
import KouenTerminalKit

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
        FrecencyDirectoryStore.shared.recordVisit(path: path)
        kickBranchRefresh(for: surfaceID, cwd: path)
        Task {
            await daemonSyncService.logIfFailed(.updateTabCwd(surfaceID: surfaceID.uuidString, path: path))
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
        notificationCoordinator.deliverAgentAlert(event: .commandFinished, title: "Command \(status)", body: "Ran for \(formatDuration(duration)).", surfaceID: surfaceID)
    }

    func terminalHostDidRequestDesktopNotification(title: String, body: String, surfaceID: SurfaceID) {
        handleNotification(for: surfaceID, event: .agentWaiting, title: title, body: body)
    }

    func terminalHostDidClose(surfaceID: SurfaceID) {
        terminalHosts.removeHost(for: surfaceID)
        SurfaceProgressTracker.shared.forget(surfaceID)
        PromptQueue.shared.forget(surfaceID)
    }

    func terminalHostDidRequestOpenFile(_ path: String, surfaceID: SurfaceID) {
        MainExecutor.shared.executeSurfacingErrors(.workbench(.view(path: path)))
        terminalHostDidRequestRevealFile(path, surfaceID: surfaceID)
    }

    func terminalHostDidRequestRevealFile(_ path: String, surfaceID: SurfaceID) {
        NotificationCenter.default.post(
            name: Notification.Name("KouenRevealFileInTree"), object: nil, userInfo: ["path": path])
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

    /// On every CWD change, read `.git/HEAD` directly (no subprocess) and push an
    /// `updateTabGitBranch` immediately if the branch differs from the snapshot.
    /// The 5-second polling loop in `DaemonSyncService` still handles the steady-state;
    /// this just eliminates the lag right after a `cd`.
    func kickBranchRefresh(for surfaceID: SurfaceID, cwd: String) {
        var matchedWorkspace: WorkspaceID?
        var matchedTab: TabID?
        var matchedBranch: String?
        search: for ws in snapshot.workspaces {
            for session in ws.sessions {
                for tab in session.tabs where tab.rootPane.allSurfaceIDs().contains(surfaceID) {
                    matchedWorkspace = ws.id
                    matchedTab = tab.id
                    matchedBranch = tab.gitBranch
                    break search
                }
            }
        }
        guard let workspaceID = matchedWorkspace, let tabID = matchedTab else { return }
        let knownBranch = matchedBranch

        Task.detached(priority: .utility) { [weak self] in
            guard let branch = Self.readGitHead(at: cwd), branch != knownBranch else { return }
            await MainActor.run { [weak self] in
                guard let self else { return }
                Task {
                    await self.daemonSyncService.logIfFailed(
                        .updateTabGitBranch(workspaceID: workspaceID, tabID: tabID, branch: branch))
                    await self.syncFromDaemon(metadataOnly: true)
                }
            }
        }
    }

    /// Walk up from `path` to find `.git` and return the current branch name from its `HEAD`.
    /// Returns nil for detached HEAD, worktrees with non-standard HEAD, or paths outside a repo.
    /// ponytail: direct file read — no subprocess, no blocking git invocation.
    private nonisolated static func readGitHead(at path: String) -> String? {
        var url = URL(fileURLWithPath: path, isDirectory: true)
        for _ in 0 ..< 16 {
            let dotGit = url.appendingPathComponent(".git")
            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: dotGit.path, isDirectory: &isDirectory) {
                let headURL: URL
                if isDirectory.boolValue {
                    headURL = dotGit.appendingPathComponent("HEAD")
                } else {
                    // Linked worktree: `.git` is a file containing "gitdir: <path/to/worktrees/name>".
                    // Follow the redirect instead of walking past it to the main repo's HEAD.
                    guard let redirect = try? String(contentsOf: dotGit, encoding: .utf8),
                          let gitdirLine = redirect.split(separator: "\n").first(where: { $0.hasPrefix("gitdir:") })
                    else { return nil }
                    let gitdirPath = gitdirLine.dropFirst("gitdir:".count).trimmingCharacters(in: .whitespaces)
                    headURL = URL(fileURLWithPath: gitdirPath).appendingPathComponent("HEAD")
                }
                guard let content = try? String(contentsOf: headURL, encoding: .utf8) else { return nil }
                let s = content.trimmingCharacters(in: .whitespacesAndNewlines)
                // "ref: refs/heads/main" → "main"; a detached HEAD is a bare hash → nil
                guard s.hasPrefix("ref: refs/heads/") else { return nil }
                let branch = String(s.dropFirst("ref: refs/heads/".count))
                return branch.isEmpty ? nil : branch
            }
            let parent = url.deletingLastPathComponent()
            if parent.path == url.path { break }
            url = parent
        }
        return nil
    }
}
