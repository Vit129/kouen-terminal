#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif
import Foundation
import KouenCore

extension KouenCLI {
    static func handleNewTab(_ args: [String], client: DaemonClient) throws {
        if let name = flagValue(args, flag: "--workspace") {
            let cwd = flagValue(args, flag: "--cwd")
            let response = try checkedRequest(client, .newTabInWorkspace(named: name, cwd: cwd))
            if case let .tabID(id) = response { print(id.uuidString) }
            return
        }
        guard let workspaceID = UUID(uuidString: flagValue(args, flag: "--workspace-id") ?? "") else {
            fputs("Usage: kouen-cli new-tab --workspace <name|uuid> [--cwd path]\n", kouenStderr)
            exit(1)
        }
        let cwd = flagValue(args, flag: "--cwd")
        let response = try checkedRequest(client, .newTab(workspaceID: workspaceID, cwd: cwd))
        if case let .tabID(id) = response { print(id.uuidString) }
    }

    static func handleNewSession(_ args: [String], client: DaemonClient) throws {
        let name = flagValue(args, flag: "--name")
        // tmux `new-session -t <session>`: a session GROUPED with the target,
        // sharing its window list. Loud lookup — never group with the wrong session.
        if let groupWith = flagValue(args, flag: "--group-with") {
            guard case let .snapshot(snapshot)? = try? client.request(.getSnapshot, timeout: 2),
                  let target = snapshot.workspaces.flatMap(\.sessions)
                      .first(where: { $0.name == groupWith || $0.id.uuidString == groupWith })
            else {
                fputs("new-session: --group-with: no session named '\(groupWith)'\n", kouenStderr)
                exit(1)
            }
            let response = try checkedRequest(client, .newSessionInGroup(targetSessionID: target.id, name: name))
            if case let .sessionID(id) = response { print(id.uuidString) }
            return
        }
        guard let workspaceID = try resolveWorkspaceID(args, client: client) else {
            fputs("Usage: kouen-cli new-session --workspace <name|uuid> [--cwd path] [--name name] [--isolate [--branch <branch>]] [--worktree <branch>] [--repo <path>] [--group-with <session>]\n", kouenStderr)
            exit(1)
        }
        // --isolate [--branch <branch>] [--base-ref <ref>]: create session in its own worktree
        if args.contains("--isolate") {
            let repo = flagValue(args, flag: "--repo") ?? flagValue(args, flag: "--cwd") ?? FileManager.default.currentDirectoryPath
            let branch = flagValue(args, flag: "--branch")
            let baseRef = flagValue(args, flag: "--base-ref")
            let sessionShort = UUID().uuidString.prefix(8).lowercased()
            let mgr = WorktreeManager()
            guard let wtPath = mgr.create(repoPath: repo, sessionID: String(sessionShort), branch: branch, baseRef: baseRef) else {
                fputs("new-session: failed to create worktree in '\(repo)'\n", kouenStderr)
                exit(1)
            }
            let sessionName = name ?? branch ?? "wt-\(sessionShort)"
            let response = try checkedRequest(client, .newSession(workspaceID: workspaceID, cwd: wtPath, name: sessionName, worktreePath: wtPath, parentRepoPath: repo))
            if case let .sessionID(id) = response { print(id.uuidString) }
            return
        }
        // --worktree <branch>: create a git worktree then session with cwd pointing to it
        if let worktreeBranch = flagValue(args, flag: "--worktree") {
            let repo = flagValue(args, flag: "--repo") ?? FileManager.default.currentDirectoryPath
            let worktreeDir = (repo as NSString).deletingLastPathComponent
                .appending("/\((repo as NSString).lastPathComponent)-worktrees/\(worktreeBranch)")
            let gitProcess = Process()
            gitProcess.executableURL = URL(fileURLWithPath: "/usr/bin/git")
            gitProcess.arguments = ["-C", repo, "worktree", "add", worktreeDir, "-b", worktreeBranch]
            gitProcess.standardError = Pipe()
            try? gitProcess.run()
            gitProcess.waitUntilExit()
            // If worktree already exists (exit 128), still use the path
            let finalCwd = FileManager.default.fileExists(atPath: worktreeDir) ? worktreeDir : repo
            let response = try checkedRequest(client, .newSession(workspaceID: workspaceID, cwd: finalCwd, name: name ?? worktreeBranch))
            if case let .sessionID(id) = response { print(id.uuidString) }
            return
        }
        let cwd = flagValue(args, flag: "--cwd")
        let response = try checkedRequest(client, .newSession(workspaceID: workspaceID, cwd: cwd, name: name))
        if case let .sessionID(id) = response { print(id.uuidString) }
    }

    static func handleNewSplit(_ args: [String], client: DaemonClient) throws {
        guard let tabID = UUID(uuidString: flagValue(args, flag: "--tab") ?? ""),
              let directionRaw = flagValue(args, flag: "--direction"),
              let direction = SplitDirection(rawValue: directionRaw)
        else {
            fputs("Usage: kouen-cli new-split --tab <uuid> --direction horizontal|vertical\n", kouenStderr)
            exit(1)
        }
        let paneID: UUID?
        switch optionalUUIDFlag(args, flag: "--pane") {
        case .absent: paneID = nil
        case .valid(let id): paneID = id
        case .invalid(let raw):
            fputs("new-split: --pane must be a pane UUID (got '\(raw)')\n", kouenStderr)
            exit(1)
        case .dangling:
            fputs("new-split: --pane requires a value\n", kouenStderr)
            exit(1)
        }
        let response = try checkedRequest(client, .newSplit(tabID: tabID, paneID: paneID, direction: direction))
        if case let .paneID(id) = response { print(id.uuidString) }
    }

    static func handleSelectWorkspace(_ args: [String], client: DaemonClient) throws {
        guard let target = flagValue(args, flag: "--workspace") ?? flagValue(args, flag: "--id") else {
            fputs("Usage: kouen-cli select-workspace --workspace <name|uuid>\n", kouenStderr)
            exit(1)
        }
        if let uuid = UUID(uuidString: target) {
            _ = try checkedRequest(client, .selectWorkspace(id: uuid))
        } else {
            _ = try checkedRequest(client, .selectWorkspaceByName(name: target))
        }
    }

    static func handleSelectTab(_ args: [String], client: DaemonClient) throws {
        guard let workspaceID = UUID(uuidString: flagValue(args, flag: "--workspace") ?? ""),
              let tabID = UUID(uuidString: flagValue(args, flag: "--tab") ?? "")
        else {
            fputs("Usage: kouen-cli select-tab --workspace <uuid> --tab <uuid>\n", kouenStderr)
            exit(1)
        }
        _ = try checkedRequest(client, .selectTab(workspaceID: workspaceID, tabID: tabID))
    }

    static func handleSelectSession(_ args: [String], client: DaemonClient) throws {
        guard let workspaceID = try resolveWorkspaceID(args, client: client),
              let sessionID = UUID(uuidString: flagValue(args, flag: "--session") ?? "")
        else {
            fputs("Usage: kouen-cli select-session --workspace <name|uuid> --session <uuid>\n", kouenStderr)
            exit(1)
        }
        _ = try checkedRequest(client, .selectSession(workspaceID: workspaceID, sessionID: sessionID))
    }

    static func printWorkspaces(_ args: [String], client: DaemonClient) throws {
        let response = try checkedRequest(client, .listWorkspaces)
        guard case let .workspaces(items) = response else { throw DaemonClientError.unexpectedResponse }
        try emit(items, args) {
            for item in items {
                print("\(item.id)\t\(item.name)\t\(item.tabCount) sessions")
            }
        }
    }

    static func printSurfaces(_ args: [String], client: DaemonClient) throws {
        let response = try checkedRequest(client, .listSurfaces)
        guard case let .surfaces(items) = response else { throw DaemonClientError.unexpectedResponse }
        try emit(items, args) {
            for item in items {
                print("\(item.surfaceID)\t\(item.workspaceName)\t\(item.tabTitle)\t\(item.cwd)")
            }
        }
    }

    static func resolveWorkspaceID(_ args: [String], client: DaemonClient) throws -> UUID? {
        guard let target = flagValue(args, flag: "--workspace") ?? flagValue(args, flag: "--workspace-id") else {
            return nil
        }
        if let uuid = UUID(uuidString: target) {
            return uuid
        }
        let response = try checkedRequest(client, .listWorkspaces)
        guard case let .workspaces(items) = response else { return nil }
        return items.first { $0.name == target }?.id
    }

    static func snapshot(_ client: DaemonClient) throws -> SessionSnapshot {
        guard case let .snapshot(snapshot) = try checkedRequest(client, .getSnapshot) else {
            throw DaemonClientError.unexpectedResponse
        }
        return snapshot
    }

    static func printSessions(_ args: [String], client: DaemonClient) throws {
        let snap = try snapshot(client)
        if let fmt = flagValue(args, flag: "-F") {
            // -F format string: render each session with FormatString
            for (si, ws) in snap.workspaces.enumerated() {
                for session in ws.sessions {
                    var ctx = FormatContext()
                    ctx.sessionName = session.name.isEmpty ? ws.name : session.name
                    ctx.sessionID = session.id.uuidString
                    ctx.sessionWindows = session.tabs.count
                    ctx.tabIndex = si
                    ctx.sessionAttached = 1
                    print(FormatString.evaluate(fmt, context: ctx))
                }
            }
            return
        }
        try emit(SnapshotQueryFormatter.sessionRows(snap), args) {
            SnapshotQueryFormatter.sessions(snap).forEach { print($0) }
        }
    }

    /// `list-agents [--waiting] [--json] [--pretty]` — every running agent with its
    /// workspace/session/tab/pane, surface id, name, state, and last-activity age.
    /// `--waiting` filters to agents blocking on you; `--json` emits the machine-readable shape.
    static func printAgents(_ args: [String], client: DaemonClient) throws {
        let response = try checkedRequest(client, .listAgents)
        guard case let .agents(items) = response else { throw DaemonClientError.unexpectedResponse }
        let filtered = args.contains("--waiting") ? items.filter(\.waiting) : items
        try emit(filtered, args) {
            AgentListFormatter.text(filtered).forEach { print($0) }
        }
    }

    static func printWindows(_ args: [String], client: DaemonClient) throws {
        let snap = try snapshot(client)
        let fmt = flagValue(args, flag: "-F")
        let sessions: [SessionGroup]
        if let target = flagValue(args, flag: "--session") {
            guard let session = resolveSession(snap, nameOrID: target) else {
                fputs("list-windows: no session matches '\(target)'\n", kouenStderr)
                exit(1)
            }
            sessions = [session]
        } else {
            sessions = snap.workspaces.flatMap(\.sessions)
        }
        if let fmt {
            for session in sessions {
                for (ti, tab) in session.tabs.enumerated() {
                    var ctx = FormatContext()
                    ctx.tabName = tab.title; ctx.tabIndex = ti
                    ctx.windowID = tab.id.uuidString
                    ctx.windowPanes = tab.rootPane.allSurfaceIDs().count
                    ctx.windowActive = tab.id == session.activeTabID
                    ctx.windowFlags = tab.id == session.activeTabID ? "*" : ""
                    print(FormatString.evaluate(fmt, context: ctx))
                }
            }
            return
        }
        if flagValue(args, flag: "--session") != nil {
            let session = sessions.first!
            try emit(SnapshotQueryFormatter.windowRows(in: session), args) {
                SnapshotQueryFormatter.windows(in: session).forEach { print($0) }
            }
        } else {
            try emit(SnapshotQueryFormatter.windowRows(snap), args) {
                SnapshotQueryFormatter.windows(snap).forEach { print($0) }
            }
        }
    }

    static func printPanes(_ args: [String], client: DaemonClient) throws {
        let snap = try snapshot(client)
        let tab: Tab?
        if let raw = flagValue(args, flag: "--tab") {
            guard let tabID = UUID(uuidString: raw) else {
                fputs("list-panes: --tab must be a tab UUID (got '\(raw)')\n", kouenStderr)
                exit(1)
            }
            tab = snap.workspaces.flatMap(\.sessions).flatMap(\.tabs).first { $0.id == tabID }
        } else {
            tab = snap.activeWorkspace?.activeTab
        }
        guard let tab else {
            fputs("list-panes: no matching tab\n", kouenStderr)
            exit(1)
        }
        if let fmt = flagValue(args, flag: "-F") {
            for (pi, pid) in tab.rootPane.allPaneIDs().enumerated() {
                var ctx = FormatContext()
                ctx.paneIndex = pi
                ctx.paneID = pid.uuidString
                ctx.paneActive = pid == tab.activePaneID
                print(FormatString.evaluate(fmt, context: ctx))
            }
            return
        }
        try emit(SnapshotQueryFormatter.paneRows(in: tab), args) {
            SnapshotQueryFormatter.panes(in: tab).forEach { print($0) }
        }
    }

    static func handleHasSession(_ args: [String], client: DaemonClient) throws {
        guard let target = flagValue(args, flag: "--session") else {
            fputs("Usage: kouen-cli has-session --session <name|uuid>\n", kouenStderr)
            exit(2)
        }
        let exists = SnapshotQueryFormatter.sessionExists(try snapshot(client), nameOrID: target)
        exit(exists ? 0 : 1)
    }

    static func resolveSession(_ snapshot: SessionSnapshot, nameOrID: String) -> SessionGroup? {
        let lowered = nameOrID.lowercased()
        return snapshot.workspaces.flatMap(\.sessions).first {
            $0.id.uuidString.lowercased() == lowered || $0.name == nameOrID
        }
    }

    static func printSnapshot(_ client: DaemonClient) throws {
        let response = try checkedRequest(client, .getSnapshot)
        guard case let .snapshot(snapshot) = response else { throw DaemonClientError.unexpectedResponse }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(snapshot)
        if let text = String(data: data, encoding: .utf8) { print(text) }
    }
}
