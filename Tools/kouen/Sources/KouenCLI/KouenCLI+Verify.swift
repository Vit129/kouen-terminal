import Foundation
import KouenCore
import KouenIPC

extension KouenCLI {
    /// `kouen verify [tier1 | tier2] [--tab/--surface/--feature <id>]`
    ///
    /// On-demand Two-Tier Verification (P46 Phase 4) — `tier1` (fast syntax/build check) runs
    /// automatically after every turn when `verify-on-turn` is enabled (`set-option -g
    /// verify-on-turn on`); `tier2` (the project's own full test command) is deliberately
    /// manual-only — running a full suite automatically after every single agent turn is too
    /// expensive a default, so it's here for the human/agent to invoke when they actually want it.
    static func handleVerify(_ args: [String], client: DaemonClient) throws {
        let knownSubs: Set<String> = ["tier1", "tier2"]
        let sub = args.first.flatMap { knownSubs.contains($0) ? $0 : nil } ?? "tier1"
        let rest = sub == args.first ? Array(args.dropFirst()) : args
        let target = flagValue(rest, flag: "--tab") ?? flagValue(rest, flag: "--surface")
        let featureSlug = flagValue(rest, flag: "--feature")

        let snap = try snapshot(client)
        let tab: Tab?
        if let featureSlug {
            tab = try resolveTabForFeature(slug: featureSlug, in: snap, client: client)
        } else if let target {
            let lower = target.lowercased()
            let allTabs = snap.workspaces.flatMap { $0.sessions.flatMap(\.tabs) }
            tab = allTabs.first {
                $0.id.uuidString.lowercased().hasPrefix(lower)
                    || ($0.rootPane.surfaceID?.uuidString.lowercased().hasPrefix(lower) ?? false)
            }
        } else {
            tab = snap.activeWorkspace?.activeTab
        }
        guard let tab else {
            if let featureSlug {
                fputs("verify: no tab bound to feature '\(featureSlug)' (no worktree, or nothing running there)\n", kouenStderr)
            } else {
                fputs("verify: no active tab (pass --tab/--surface/--feature <id>)\n", kouenStderr)
            }
            exit(1)
        }

        let runner = VerificationRunner()
        let result = sub == "tier2" ? runner.tier2TestRun(cwd: tab.cwd) : runner.tier1SyntaxCheck(cwd: tab.cwd)
        guard let result else {
            fputs("verify: no recognized project toolchain in '\(tab.cwd)'\n", kouenStderr)
            exit(1)
        }

        print("$ \(result.command)")
        print(result.output)
        print(result.passed ? "\n✓ passed" : "\n✗ failed")
        exit(result.passed ? 0 : 1)
    }
}
