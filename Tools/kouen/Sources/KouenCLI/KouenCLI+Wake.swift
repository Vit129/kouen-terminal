import Foundation
import KouenCore

extension KouenCLI {
    /// `kouen-cli wake <org/repo|path> --workspace <name|uuid> [--issue N] [--agent claude]
    ///   [--branch name] [--prompt text]`
    ///
    /// ghq-style one-shot: resolve/clone the repo, create an isolated worktree, spawn a session,
    /// launch the agent, and (if `--issue`/`--prompt` is given) type the initial prompt — composes
    /// `RepoResolver` + `WorktreeManager` (already used by `new-session --isolate`) with the same
    /// spawn/poll/type steps `kouenSpawnAgent` (MCP) and `fireAutomationLocked` (automations) each
    /// already do on their own; this is the only place that chains all of them into one command.
    static func handleWake(_ args: [String], client: DaemonClient) throws {
        guard let target = positionalArgs(args, skippingValuesFor: [
            "--workspace", "--issue", "--agent", "--branch", "--prompt",
        ]).first else {
            fputs(
                "Usage: kouen-cli wake <org/repo|path> --workspace <name|uuid> "
                    + "[--issue N] [--agent claude] [--branch name] [--prompt text]\n",
                kouenStderr
            )
            exit(1)
        }
        guard let workspaceID = try resolveWorkspaceID(args, client: client) else {
            fputs("wake: --workspace <name|uuid> is required\n", kouenStderr)
            exit(1)
        }
        guard let repoPath = RepoResolver().resolve(target) else {
            fputs("wake: could not resolve or clone '\(target)'\n", kouenStderr)
            exit(1)
        }

        let issueNumber = flagValue(args, flag: "--issue").flatMap(Int.init)
        var prompt = flagValue(args, flag: "--prompt")
        if prompt == nil, let issueNumber {
            if let issue = GitHubCLIClient().issue(repoSpec: target, number: issueNumber) {
                prompt = "Issue #\(issueNumber): \(issue.title)\n\n\(issue.body)"
            } else {
                fputs("wake: warning: could not fetch issue #\(issueNumber), continuing without a prompt\n", kouenStderr)
            }
        }

        let branch = flagValue(args, flag: "--branch") ?? issueNumber.map { "issue-\($0)" }
        let sessionShort = UUID().uuidString.prefix(8).lowercased()
        guard let worktreePath = WorktreeManager().create(repoPath: repoPath, sessionID: String(sessionShort), branch: branch)
        else {
            fputs("wake: failed to create worktree in '\(repoPath)'\n", kouenStderr)
            exit(1)
        }

        let agent = flagValue(args, flag: "--agent") ?? "claude"
        let name = branch ?? "wake-\(sessionShort)"
        let response = try checkedRequest(client, .newSession(
            workspaceID: workspaceID, cwd: worktreePath, name: name,
            worktreePath: worktreePath, parentRepoPath: repoPath
        ))
        guard case let .sessionID(sessionID) = response else {
            if case let .error(msg) = response { fputs("wake: \(msg)\n", kouenStderr) }
            exit(1)
        }

        // Poll for the session's pane to come up — same shape as `kouenSpawnAgent`'s readiness loop.
        var surfaceID: String?
        for attempt in 0..<6 {
            if attempt > 0 { Thread.sleep(forTimeInterval: 0.35) }
            let snap = try snapshot(client)
            guard let ws = snap.workspaces.first(where: { $0.id == workspaceID }),
                  let session = ws.sessions.first(where: { $0.id == sessionID }),
                  let leaf = session.tabs.first?.rootPane.allLeaves().first
            else { continue }
            surfaceID = (leaf.activeSurfaceID ?? leaf.surfaceID).uuidString
            break
        }
        guard let surfaceID else {
            fputs("wake: session spawned but surface not ready in time (sessionID=\(sessionID.uuidString))\n", kouenStderr)
            exit(1)
        }

        _ = try checkedRequest(client, .send(surfaceID: surfaceID, text: agentLaunchCommand(for: agent)))
        if let prompt {
            // ponytail: fixed 3s cold-start delay, same heuristic `fireAutomationLocked` uses for
            // its own prompt-typing step — not a readiness check. Ceiling: a slow/cold CLI start
            // could still lose the prompt to the shell.
            Thread.sleep(forTimeInterval: 3)
            _ = try checkedRequest(client, .send(surfaceID: surfaceID, text: prompt + "\n"))
        }
        print(sessionID.uuidString)
    }

    private static func agentLaunchCommand(for agent: String) -> String {
        switch agent.lowercased() {
        case "codex": return "codex\n"
        case "kiro": return "kiro\n"
        case "gemini": return "gemini\n"
        default: return "claude\n"
        }
    }
}
