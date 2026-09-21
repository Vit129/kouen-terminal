import Foundation
import KouenCore
import KouenIPC

extension KouenCLI {
    /// Dispatches `kouen agent <command> [args]`
    static func handleAgent(_ args: [String], client: DaemonClient) throws {
        // Strip leading "agent" verb if present
        let cleanArgs = (args.first == "agent") ? Array(args.dropFirst()) : args
        guard let sub = cleanArgs.first else {
            printAgentUsage()
            return
        }

        switch sub {
        case "list", "ls":
            try handleAgentList(Array(cleanArgs.dropFirst()), client: client)

        case "wait":
            try handleAgentWait(Array(cleanArgs.dropFirst()), client: client)

        case "send":
            try handleAgentSend(Array(cleanArgs.dropFirst()), client: client)

        default:
            printAgentUsage()
        }
    }

    private static func printAgentUsage() {
        print("""
        Usage: kouen agent <command> [arguments]

        Commands:
          list [--status <status>] [--json]                        List active agents and their attention state
          wait <tab-or-surface-id> | --feature <slug> [--timeout <sec>]
                                                                     Wait until agent finishes or requests attention
          send <file> [--message <msg>] [--tab/--surface/--feature <id>]
                                                                     Send file context to an agent pane
                                                                     (target required when more than one agent is running)
        """)
    }

    /// The tab bound to `worktreePath` — same match `GitPanelView.agentInfo(forWorktreePath:tabs:)`
    /// uses. Pure (no daemon round trip) so `AgentCommandTests` can exercise it directly; `internal`
    /// (not `private`) for exactly that reason.
    static func matchTab(forWorktreePath worktreePath: String, in snap: SessionSnapshot) -> Tab? {
        let allTabs = snap.workspaces.flatMap { $0.sessions.flatMap(\.tabs) }
        return allTabs.first { $0.cwd == worktreePath || $0.worktreePath == worktreePath }
    }

    /// Resolve `--feature <slug>` to the tab bound to that feature's worktree. `nil` when the
    /// feature doesn't exist, has no bound worktree, or nothing is currently running there.
    static func resolveTabForFeature(slug: String, in snap: SessionSnapshot, client: DaemonClient) throws -> Tab? {
        guard case let .featureInfo(summary) = try checkedRequest(client, .featureGet(slug: slug)),
              let feat = summary, let worktreePath = feat.worktreePath
        else { return nil }
        return matchTab(forWorktreePath: worktreePath, in: snap)
    }

    /// A tab's surface, tolerating a split root pane (no single `surfaceID`) by falling back to
    /// its first leaf — same fallback `FleetViewModel.refresh` uses.
    private static func firstSurfaceID(of tab: Tab) -> String? {
        tab.rootPane.surfaceID?.uuidString ?? tab.rootPane.allSurfaceIDs().first?.uuidString
    }

    /// Resolve a `--tab <id>`/`--surface <id>` prefix against every tab currently running an
    /// agent. P46 Pillar 6 gap 4: `handleAgentSend` used to silently pick "the first agent tab
    /// found" — wrong when more than one is running. `nil` target only auto-resolves when
    /// exactly one agent tab exists; more than one without an explicit target is an error, not
    /// a guess. `internal` (not `private`) so `AgentCommandTests` can exercise this pure
    /// resolution logic directly without a live daemon.
    static func resolveAgentTab(in snap: SessionSnapshot, target: String?) -> Tab? {
        let agentTabs = snap.workspaces.flatMap { $0.sessions.flatMap(\.tabs) }.filter { $0.agent != nil }
        guard let target else {
            return agentTabs.count == 1 ? agentTabs.first : nil
        }
        let targetLower = target.lowercased()
        return agentTabs.first {
            $0.id.uuidString.lowercased().hasPrefix(targetLower)
                || ($0.rootPane.surfaceID?.uuidString.lowercased().hasPrefix(targetLower) ?? false)
        }
    }

    private static func handleAgentList(_ args: [String], client: DaemonClient) throws {
        let snap = try snapshot(client)
        let statusFilter = flagValue(args, flag: "--status")?.lowercased()
        let wantJSON = args.contains("--json")

        struct AgentEntry: Codable {
            let tabID: String
            let surfaceID: String
            let agent: String
            let status: String
            let activity: String
            let prompt: String?
            let cwd: String
        }

        var entries: [AgentEntry] = []

        for ws in snap.workspaces {
            for session in ws.sessions {
                for tab in session.tabs {
                    let agentName = tab.agent?.kind.displayName ?? (tab.status != .idle ? "Unknown" : nil)
                    guard let resolvedAgent = agentName else { continue }
                    let tabStatus = tab.status.rawValue
                    let activity = tab.agent?.activity.rawValue ?? "idle"

                    if let filter = statusFilter {
                        if tabStatus != filter && activity != filter {
                            continue
                        }
                    }

                    let surfaceID = tab.rootPane.surfaceID?.uuidString ?? ""
                    entries.append(AgentEntry(
                        tabID: tab.id.uuidString,
                        surfaceID: surfaceID,
                        agent: resolvedAgent,
                        status: tabStatus,
                        activity: activity,
                        prompt: tab.notificationText,
                        cwd: tab.cwd
                    ))
                }
            }
        }

        if wantJSON {
            let data = (try? JSONEncoder().encode(entries)) ?? Data()
            print(String(data: data, encoding: .utf8) ?? "[]")
            return
        }

        if entries.isEmpty {
            print("No active agents found.")
            return
        }

        print(String(format: "%-8@ %-16@ %-10@ %-28@ %@",
                     "TAB" as NSString,
                     "AGENT" as NSString,
                     "STATUS" as NSString,
                     "ATTENTION / PROMPT" as NSString,
                     "CWD" as NSString))
        print(String(repeating: "-", count: 80))

        for entry in entries {
            let promptStr = entry.prompt ?? (entry.status == "waiting" ? "Waiting for approval" : "-")
            let shortPrompt = String(promptStr.prefix(27))
            let shortTab = String(entry.tabID.prefix(8))
            print(String(format: "%-8@ %-16@ %-10@ %-28@ %@",
                         shortTab as NSString,
                         entry.agent as NSString,
                         entry.status as NSString,
                         shortPrompt as NSString,
                         entry.cwd as NSString))
        }
    }

    private static func handleAgentWait(_ args: [String], client: DaemonClient) throws {
        // A leading flag (e.g. `--feature`) means no positional target — the flag's own value
        // token isn't itself `--`-prefixed, so this only inspects `args.first`, never the value.
        let positionalTarget = args.first?.hasPrefix("--") == false ? args.first : nil
        let featureSlug = flagValue(args, flag: "--feature")
        guard positionalTarget != nil || featureSlug != nil else {
            fputs("Usage: kouen agent wait <tab-or-surface-id> [--timeout <sec>]\n       kouen agent wait --feature <slug> [--timeout <sec>]\n", kouenStderr)
            return
        }
        let describeTarget = featureSlug.map { "feature '\($0)'" } ?? "'\(positionalTarget!)'"

        let timeoutSec = Double(flagValue(args, flag: "--timeout") ?? "600") ?? 600
        let deadline = Date().addingTimeInterval(timeoutSec)
        let targetLower = positionalTarget?.lowercased()

        // `resolveAgentTab` filters to agent-only tabs, which `wait` doesn't want (the target may
        // not have a detected agent yet) — match against every tab instead.
        func resolveTargetTab() throws -> Tab {
            let snap = try snapshot(client)
            if let featureSlug {
                guard let tab = try resolveTabForFeature(slug: featureSlug, in: snap, client: client) else {
                    fputs("agent: no tab bound to feature '\(featureSlug)' (no worktree, or nothing running there)\n", kouenStderr)
                    exit(1)
                }
                return tab
            }
            let allTabs = snap.workspaces.flatMap { $0.sessions.flatMap(\.tabs) }
            guard let tab = allTabs.first(where: {
                $0.id.uuidString.lowercased().hasPrefix(targetLower!)
                    || ($0.rootPane.surfaceID?.uuidString.lowercased().hasPrefix(targetLower!) ?? false)
            }) else {
                fputs("agent: tab/surface '\(positionalTarget!)' not found\n", kouenStderr)
                exit(1)
            }
            return tab
        }

        // Returns true once a terminal status was reported (caller should stop).
        func reportIfTerminal(_ tab: Tab) -> Bool {
            switch tab.status {
            case .waiting:
                print("Agent transitioned to waiting: \(tab.notificationText ?? "Needs approval")")
                return true
            case .done:
                print("Agent completed task.")
                return true
            case .error:
                fputs("Agent encountered error.\n", kouenStderr)
                exit(1)
            default:
                return false
            }
        }

        print("Waiting for agent \(describeTarget)...")

        var tab = try resolveTargetTab()
        guard let surfaceID = firstSurfaceID(of: tab) else {
            fputs("agent: target has no surface\n", kouenStderr)
            exit(1)
        }
        // P46 Pillar 6 gap 4: block on the daemon's `.waitFor` channel instead of busy-polling —
        // `DaemonServer` signals it the instant `markWaiting`/`markDone` fires. ponytail: a status
        // transition landing in the narrow window between this check and the wait registering
        // below is missed (`WaitForRegistry` doesn't latch a signal with no waiters — same
        // semantics tmux's own `wait-for` documents) and only surfaces once the full timeout
        // elapses; upgrade path would be a small "already pending" flag on the channel itself.
        let channel = agentWaitChannel(surfaceKey: surfaceID)

        while Date() < deadline {
            if reportIfTerminal(tab) { return }
            let remaining = deadline.timeIntervalSinceNow
            guard remaining > 0 else { break }
            _ = try? checkedRequest(client, .waitFor(channel: channel, mode: "wait"), timeout: remaining)
            tab = try resolveTargetTab()
        }

        fputs("agent: wait timed out after \(Int(timeoutSec))s\n", kouenStderr)
        exit(1)
    }

    private static func handleAgentSend(_ args: [String], client: DaemonClient) throws {
        guard let file = args.first else {
            fputs("Usage: kouen agent send <file> [--message <msg>] [--tab/--surface/--feature <id>]\n", kouenStderr)
            return
        }
        let message = flagValue(args, flag: "--message") ?? "review this file"
        let target = flagValue(args, flag: "--tab") ?? flagValue(args, flag: "--surface")
        let featureSlug = flagValue(args, flag: "--feature")

        guard let data = FileManager.default.contents(atPath: file),
              let content = String(data: data, encoding: .utf8) else {
            fputs("agent: cannot read '\(file)'\n", kouenStderr)
            return
        }

        let snap = try snapshot(client)
        let matched: Tab
        if let featureSlug {
            guard let tab = try resolveTabForFeature(slug: featureSlug, in: snap, client: client) else {
                fputs("agent: no tab bound to feature '\(featureSlug)' (no worktree, or nothing running there)\n", kouenStderr)
                exit(1)
            }
            matched = tab
        } else {
            let agentTabCount = snap.workspaces.flatMap { $0.sessions.flatMap(\.tabs) }.filter { $0.agent != nil }.count
            guard let tab = resolveAgentTab(in: snap, target: target) else {
                if target == nil, agentTabCount > 1 {
                    fputs("agent: \(agentTabCount) agent panes running — pass --tab/--surface/--feature to pick one (see `kouen agent list`)\n", kouenStderr)
                } else if let target {
                    fputs("agent: no agent tab matching '\(target)'\n", kouenStderr)
                } else {
                    fputs("agent: no agent pane found\n", kouenStderr)
                }
                exit(1)
            }
            matched = tab
        }
        guard let surfaceID = firstSurfaceID(of: matched) else {
            fputs("agent: no agent pane found\n", kouenStderr)
            return
        }

        let capped = String(content.prefix(8000))
        let payload = "\(message)\n\nFile: \(file)\n```\n\(capped)\n```\n"
        _ = try checkedRequest(client, .send(surfaceID: surfaceID, text: payload, origin: .automation))
        print("sent to agent: \(file)")
    }
}
