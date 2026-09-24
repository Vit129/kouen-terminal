import Foundation
import KouenCore
import KouenIPC

extension KouenCLI {
    /// `kouen history [list] [--limit N] [--json]`
    /// `kouen history search <keyword> [--limit N]`
    /// `kouen history show <id>`
    /// `kouen history resume <id>`
    ///
    /// CLI surface for `AgentHistoryScanner` (Phase 1 backend, already scanning Claude
    /// Code/Antigravity/Codex transcripts for the Session History sidebar tab) — the sidebar
    /// tab requires the GUI; this is the same data from a shell.
    static func handleHistory(_ args: [String], client: DaemonClient) async throws {
        let knownSubs: Set<String> = ["list", "search", "show", "resume"]
        let sub = args.first.flatMap { knownSubs.contains($0) ? $0 : nil }
        let rest = sub != nil ? Array(args.dropFirst()) : args

        switch sub ?? "list" {
        case "search":
            try await handleHistorySearch(rest)
        case "show":
            try await handleHistoryShow(rest)
        case "resume":
            try await handleHistoryResume(rest, client: client)
        default:
            try await handleHistoryList(rest)
        }
    }

    private static func printHistoryUsage() {
        fputs("""
        Usage:
          kouen history [list] [--limit N] [--json]   Recent agent sessions across every workspace
          kouen history search <keyword> [--limit N]  Search prompts/output across all transcripts
          kouen history show <id>                     Show one session's detail (prefix-matched)
          kouen history resume <id>                   Resume a session in a new tab
        \n
        """, kouenStderr)
    }

    private static func findRecord(idPrefix: String) async -> AgentSessionRecord? {
        let lower = idPrefix.lowercased()
        return await AgentHistoryScanner.shared.getOrScan().first { $0.id.lowercased().hasPrefix(lower) }
    }

    private static func handleHistoryList(_ args: [String]) async throws {
        let limit = Int(flagValue(args, flag: "--limit") ?? "20") ?? 20
        let wantJSON = args.contains("--json")
        let shown = Array(await AgentHistoryScanner.shared.getOrScan().prefix(limit))

        if wantJSON {
            struct Entry: Codable {
                let id: String, agent: String, title: String, project: String
                let branch: String?, updatedAt: Date, messageCount: Int
                // "local" unless `claude agents --json` reported this session live elsewhere —
                // see `AgentSessionPlacement`.
                let placement: String
                let liveStatus: String?
            }
            let entries = shown.map {
                Entry(id: $0.id, agent: $0.agentKind.displayName, title: $0.title, project: $0.projectName,
                      branch: $0.gitBranch, updatedAt: $0.updatedAt, messageCount: $0.messageCount,
                      placement: $0.placement.rawValue, liveStatus: $0.liveStatus)
            }
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.sortedKeys]
            if let data = try? encoder.encode(entries), let str = String(data: data, encoding: .utf8) { print(str) }
            return
        }

        guard !shown.isEmpty else {
            print("No agent session history found.")
            return
        }

        let df = RelativeDateTimeFormatter()
        print(String(format: "%-10@ %-12@ %-22@ %-16@ %@",
                     "ID" as NSString, "AGENT" as NSString, "PROJECT" as NSString, "UPDATED" as NSString, "TITLE" as NSString))
        print(String(repeating: "-", count: 90))
        for r in shown {
            let shortID = String(r.id.prefix(8))
            let updated = df.localizedString(for: r.updatedAt, relativeTo: Date())
            print(String(format: "%-10@ %-12@ %-22@ %-16@ %@",
                         shortID as NSString, r.agentKind.displayName as NSString,
                         r.projectName as NSString, updated as NSString, r.title as NSString))
        }
    }

    private static func handleHistorySearch(_ args: [String]) async throws {
        guard let query = args.first(where: { !$0.hasPrefix("--") }) else {
            printHistoryUsage()
            exit(1)
        }
        let limit = Int(flagValue(args, flag: "--limit") ?? "20") ?? 20
        let matcher = SearchMatcher(query: query)
        let records = await AgentHistoryScanner.shared.getOrScan()

        let matched: [(AgentSessionRecord, String?)] = records.compactMap { record in
            let turnsContent = record.latestTurns.map(\.content).joined(separator: "\n")
            let fullContent = "\(record.firstPrompt)\n\(turnsContent)"
            guard let result = matcher.match(
                name: record.title,
                relativePath: "\(record.projectName) \(record.agentKind.displayName)",
                content: fullContent
            ) else { return nil }
            return (record, result.snippet)
        }

        let limited = Array(matched.prefix(limit))
        guard !limited.isEmpty else {
            print("No matches for '\(query)'.")
            return
        }
        for (record, snippet) in limited {
            print("\(String(record.id.prefix(8)))  \(record.agentKind.displayName)  \(record.projectName)  \(record.title)")
            if let snippet, !snippet.isEmpty {
                print("    \(snippet)")
            }
        }
    }

    private static func handleHistoryShow(_ args: [String]) async throws {
        guard let idPrefix = args.first else {
            printHistoryUsage()
            exit(1)
        }
        guard let record = await findRecord(idPrefix: idPrefix) else {
            fputs("history: no record matching '\(idPrefix)'\n", kouenStderr)
            exit(1)
        }
        print("Agent:      \(record.agentKind.displayName)")
        print("Title:      \(record.title)")
        print("Project:    \(record.projectName) (\(record.projectPath))")
        if let branch = record.gitBranch { print("Branch:     \(branch)") }
        if let model = record.modelName { print("Model:      \(model)") }
        print("Messages:   \(record.messageCount)")
        print("Updated:    \(record.updatedAt)")
        if record.placement != .local {
            let status = record.liveStatus.map { " (\($0))" } ?? ""
            print("Live at:    \(record.placement.rawValue)\(status)")
        }
        print("Transcript: \(record.transcriptPath)")
        print("")
        print("First prompt:")
        print(record.firstPrompt)
        if !record.latestTurns.isEmpty {
            print("\nRecent turns:")
            for turn in record.latestTurns {
                print("[\(turn.role)] \(turn.content)")
            }
        }
    }

    private static func handleHistoryResume(_ args: [String], client: DaemonClient) async throws {
        guard let idPrefix = args.first else {
            printHistoryUsage()
            exit(1)
        }
        guard let record = await findRecord(idPrefix: idPrefix) else {
            fputs("history: no record matching '\(idPrefix)'\n", kouenStderr)
            exit(1)
        }

        let snap = try snapshot(client)
        guard let workspaceID = snap.activeWorkspaceID ?? snap.workspaces.first?.id else {
            fputs("history: no workspace to resume into\n", kouenStderr)
            exit(1)
        }

        let response = try checkedRequest(client, .newTab(workspaceID: workspaceID, cwd: record.projectPath, shell: nil))
        guard case let .tabID(tabID) = response else {
            if case let .error(msg) = response { fputs("history: \(msg)\n", kouenStderr) }
            exit(1)
        }

        // Same spawn/poll shape `handleWake` and `kouenSpawnAgent` (MCP) both already use.
        var surfaceID: String?
        for attempt in 0..<6 {
            if attempt > 0 { try? await Task.sleep(nanoseconds: 350_000_000) }
            let polled = try snapshot(client)
            guard let ws = polled.workspaces.first(where: { $0.id == workspaceID }),
                  let tab = ws.sessions.flatMap(\.tabs).first(where: { $0.id == tabID }),
                  let leaf = tab.rootPane.allLeaves().first
            else { continue }
            surfaceID = (leaf.activeSurfaceID ?? leaf.surfaceID).uuidString
            break
        }
        guard let surfaceID else {
            fputs("history: tab created but surface not ready in time (tabID=\(tabID.uuidString))\n", kouenStderr)
            exit(1)
        }

        let cmd = record.effectiveResumeCommand(claudeMode: KouenSettings.load().claudeSessionMode)
        _ = try checkedRequest(client, .send(surfaceID: surfaceID, text: cmd + "\n", origin: .automation))
        print(tabID.uuidString)
    }
}
