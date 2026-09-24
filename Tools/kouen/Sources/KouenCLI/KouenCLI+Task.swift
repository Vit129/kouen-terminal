#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif
import Foundation
import KouenCore
import KouenIPC

extension KouenCLI {
    /// `kouen task new <slug> [--repo <path>] [--branch <name>] [--base <name>] [--worktree <path>] [--phase <phase>]`
    /// `kouen task status [<slug>] [--json]`
    /// `kouen task list [--repo <path>] [--json]`
    /// `kouen task gate approve <slug> <1|2|3|4> [--approver <name>] [--notes <text>]`
    /// `kouen task phase <slug> <phase>`
    /// `kouen task supersede <slug> <new-slug>`
    /// `kouen task delete <slug>`
    /// `kouen task merge <slug>` — Gate 4 (Merge Review): shows the diff stat, blocks until
    /// Gate 4 is approved, then merges `branch` into `baseBranch`
    /// `kouen task sweep [--repo <path>]`
    static func handleTask(_ args: [String], client: DaemonClient) async throws {
        guard let sub = args.first else {
            printTaskUsage()
            exit(1)
        }

        switch sub {
        case "new":
            try handleTaskNew(Array(args.dropFirst()), client: client)
        case "status":
            try handleTaskStatus(Array(args.dropFirst()), client: client)
        case "list":
            try handleTaskList(Array(args.dropFirst()), client: client)
        case "gate":
            try handleTaskGate(Array(args.dropFirst()), client: client)
        case "phase":
            try handleTaskPhase(Array(args.dropFirst()), client: client)
        case "supersede":
            try handleTaskSupersede(Array(args.dropFirst()), client: client)
        case "delete":
            try handleTaskDelete(Array(args.dropFirst()), client: client)
        case "merge":
            try handleTaskMerge(Array(args.dropFirst()), client: client)
        case "sweep":
            try handleTaskSweep(Array(args.dropFirst()), client: client)
        case "preview":
            try handleTaskPreview(Array(args.dropFirst()), client: client)
        case "pack-pr":
            try await handleTaskPackPr(Array(args.dropFirst()), client: client)
        default:
            printTaskUsage()
            exit(1)
        }
    }

    private static func printTaskUsage() {
        fputs("""
        Usage:
          kouen task new <slug> [--repo <path>] [--branch <name>] [--base <name>] [--worktree <path>] [--phase <phase>] [--preview]
          kouen task status [<slug>] [--json]
          kouen task list [--repo <path>] [--json]
          kouen task gate approve <slug> <1|2|3|4> [--approver <name>] [--notes <text>] [--preview]
          kouen task phase <slug> <interview|architect|qa-design|dev|qa-verify|completed>
          kouen task supersede <slug> <new-slug>
          kouen task delete <slug>
          kouen task merge <slug>            Gate 4 (Merge Review) — shows the diff, blocks
                                              until approved, then merges into the base branch
          kouen task pack-pr [<slug>] [--out <file>]
                                              Compiles a diff summary, gate approvals, task
                                              checklist, and session summary into PR markdown
          kouen task sweep [--repo <path>]
          kouen task preview [<slug>] [--file architecture|progress]
        \n
        """, kouenStderr)
    }

    private static func handleTaskNew(_ args: [String], client: DaemonClient) throws {
        guard let slug = args.first, !slug.hasPrefix("--") else {
            printTaskUsage()
            exit(1)
        }
        let repo = flagValue(args, flag: "--repo") ?? FileManager.default.currentDirectoryPath
        let branch = flagValue(args, flag: "--branch")
        let base = flagValue(args, flag: "--base") ?? "main"
        let worktree = flagValue(args, flag: "--worktree")
        let phase = flagValue(args, flag: "--phase") ?? "interview"

        let resp = try checkedRequest(client, .featureCreate(
            slug: slug,
            repoPath: repo,
            branch: branch,
            baseBranch: base,
            worktreePath: worktree,
            phase: phase
        ))

        if case let .featureInfo(summary) = resp, let summary {
            print("Feature created: \(summary.slug) [\(summary.phase)]")
            if let b = summary.branch { print("  Branch: \(b) (base: \(summary.baseBranch ?? "main"))") }
            if let wt = summary.worktreePath { print("  Worktree: \(wt)") }
            let progressFile = KouenFeatureMarkdownSync.progressFileURL(for: summary.slug, repoPath: summary.repoPath)
            print("  Plan Markdown: \(progressFile.path)")
            if args.contains("--preview") {
                openMarkdownPreview(path: progressFile.path)
                print("  Preview GUI: Opened in Kouen sidebar")
            }
        } else {
            print("Feature created: \(slug)")
        }
    }

    private static func handleTaskStatus(_ args: [String], client: DaemonClient) throws {
        let isJson = args.contains("--json")
        let slugArg = args.first(where: { !$0.hasPrefix("--") })

        let targetSlug: String
        if let slugArg {
            targetSlug = slugArg
        } else {
            // Try to infer from current git branch or directory
            let cwd = FileManager.default.currentDirectoryPath
            let resp = try checkedRequest(client, .featureList(repoPath: cwd))
            if case let .features(list) = resp, let first = list.first {
                targetSlug = first.slug
            } else {
                fputs("Usage: kouen task status <slug> [--json]\n", kouenStderr)
                exit(1)
            }
        }

        let resp = try checkedRequest(client, .featureGet(slug: targetSlug))
        guard case let .featureInfo(summary) = resp, let feat = summary else {
            fputs("Task/Feature not found: '\(targetSlug)'\n", kouenStderr)
            exit(1)
        }

        if isJson {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = .iso8601
            if let data = try? encoder.encode(feat), let str = String(data: data, encoding: .utf8) {
                print(str)
            }
            return
        }

        print("Feature: \(feat.slug)")
        print("Phase:   \(feat.phase)")
        print("Repo:    \(feat.repoPath)")
        if let b = feat.branch { print("Branch:  \(b) (base: \(feat.baseBranch ?? "main"))") }
        if let wt = feat.worktreePath { print("Worktree: \(wt)") }
        if let sup = feat.supersededBy { print("Superseded By: \(sup)") }

        print("Gates:")
        for g in 1...4 {
            let approved = feat.gates.first { $0.gate == g && $0.approved }
            let check = approved != nil ? "✓" : " "
            let gateName: String
            switch g {
            case 1: gateName = "Gate 1 (Architect design)"
            case 2: gateName = "Gate 2 (Scenario list)"
            case 3: gateName = "Gate 3 (Seam agreement)"
            case 4: gateName = "Gate 4 (Merge Review)"
            default: gateName = "Gate \(g)"
            }
            if let app = approved {
                print("  [\(check)] \(gateName) — approved by \(app.approver)")
            } else {
                print("  [\(check)] \(gateName) — pending")
            }
        }
    }

    private static func handleTaskList(_ args: [String], client: DaemonClient) throws {
        let isJson = args.contains("--json")
        let repo = flagValue(args, flag: "--repo")

        let resp = try checkedRequest(client, .featureList(repoPath: repo))
        guard case let .features(features) = resp else {
            fputs("Failed to fetch features\n", kouenStderr)
            exit(1)
        }

        if isJson {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = .iso8601
            if let data = try? encoder.encode(features), let str = String(data: data, encoding: .utf8) {
                print(str)
            }
            return
        }

        if features.isEmpty {
            print("No features tracked.")
            return
        }

        print(String(format: "%-24@ %-12@ %-16@ %-20@", "SLUG", "PHASE", "BRANCH", "WORKTREE"))
        print(String(repeating: "-", count: 76))
        for f in features {
            let slug = f.slug
            let phase = f.phase
            let branch = f.branch ?? "-"
            let wt = f.worktreePath.map { URL(fileURLWithPath: $0).lastPathComponent } ?? "-"
            print(String(format: "%-24@ %-12@ %-16@ %-20@", slug, phase, branch, wt))
        }
    }

    private static func handleTaskGate(_ args: [String], client: DaemonClient) throws {
        guard let action = args.first, action == "approve", args.count >= 3 else {
            fputs("Usage: kouen task gate approve <slug> <1|2|3|4> [--approver <name>] [--notes <text>]\n", kouenStderr)
            exit(1)
        }
        let slug = args[1]
        guard let gateNum = Int(args[2]), (1...4).contains(gateNum) else {
            fputs("Gate number must be 1, 2, 3, or 4\n", kouenStderr)
            exit(1)
        }
        let approver = flagValue(args, flag: "--approver") ?? NSUserName()
        let notes = flagValue(args, flag: "--notes")

        let resp = try checkedRequest(client, .featureApproveGate(slug: slug, gate: gateNum, approver: approver, notes: notes))
        if case let .featureInfo(summary) = resp, let feat = summary {
            print("Approved Gate \(gateNum) for '\(feat.slug)' by \(approver)")
            let progressFile = KouenFeatureMarkdownSync.progressFileURL(for: feat.slug, repoPath: feat.repoPath)
            print("  Updated: \(progressFile.path)")
            if args.contains("--preview") {
                openMarkdownPreview(path: progressFile.path)
                print("  Preview GUI: Opened in Kouen sidebar")
            }
        } else {
            print("Approved Gate \(gateNum) for '\(slug)'")
        }
    }

    private static func handleTaskPhase(_ args: [String], client: DaemonClient) throws {
        guard args.count >= 2 else {
            fputs("Usage: kouen task phase <slug> <interview|architect|qa-design|dev|qa-verify|completed>\n", kouenStderr)
            exit(1)
        }
        let slug = args[0]
        let phase = args[1]

        let resp = try checkedRequest(client, .featureUpdatePhase(slug: slug, phase: phase))
        if case let .featureInfo(summary) = resp, let feat = summary {
            print("Updated '\(feat.slug)' phase -> \(feat.phase)")
        } else {
            print("Updated '\(slug)' phase -> \(phase)")
        }
    }

    private static func handleTaskSupersede(_ args: [String], client: DaemonClient) throws {
        guard args.count >= 2 else {
            fputs("Usage: kouen task supersede <slug> <new-slug>\n", kouenStderr)
            exit(1)
        }
        let slug = args[0]
        let newSlug = args[1]

        let resp = try checkedRequest(client, .featureSupersede(slug: slug, supersededBy: newSlug))
        if case let .featureInfo(summary) = resp, let feat = summary {
            print("Feature '\(feat.slug)' marked superseded by '\(newSlug)'")
        } else {
            print("Feature '\(slug)' marked superseded by '\(newSlug)'")
        }
    }

    private static func handleTaskDelete(_ args: [String], client: DaemonClient) throws {
        guard let slug = args.first else {
            fputs("Usage: kouen task delete <slug>\n", kouenStderr)
            exit(1)
        }
        _ = try checkedRequest(client, .featureDelete(slug: slug))
        print("Deleted feature: \(slug)")
    }

    /// P46 Pillar 6 gap 5 (Gate 4, Merge Review): a feature could previously go green on tests
    /// and merge straight to base with nobody having looked at the diff — gates 1-3 only cover
    /// design/scenario/seam agreement, not "did a human actually see what's about to land."
    /// Always shows the diff stat; merges only once Gate 4 is approved, and only if `repoPath`
    /// is actually sitting on `baseBranch` already (never force-switches it out from under
    /// whatever the human has checked out there).
    private static func handleTaskMerge(_ args: [String], client: DaemonClient) throws {
        guard let slug = args.first, !slug.hasPrefix("--") else {
            fputs("Usage: kouen task merge <slug>\n", kouenStderr)
            exit(1)
        }

        let resp = try checkedRequest(client, .featureGet(slug: slug))
        guard case let .featureInfo(summary) = resp, let feat = summary else {
            fputs("Task/Feature not found: '\(slug)'\n", kouenStderr)
            exit(1)
        }
        guard let branch = feat.branch else {
            fputs("Feature '\(slug)' has no bound branch — nothing to merge.\n", kouenStderr)
            exit(1)
        }
        let base = feat.baseBranch ?? "main"

        let worktrees = WorktreeManager()
        print("Diff \(base)...\(branch):")
        if let stat = worktrees.diffStat(repoPath: feat.repoPath, branch: branch, base: base), !stat.isEmpty {
            print(stat)
        } else {
            print("  (no diff — branch is even with \(base), or one of the refs doesn't exist)")
        }

        guard feat.isGateApproved(4) else {
            print("""

            Gate 4 (Merge Review) not yet approved — review the diff above, then:
              kouen task gate approve \(slug) 4 [--approver <name>] [--notes <text>]
              kouen task merge \(slug)   # re-run once approved
            """)
            exit(1)
        }

        let current = worktrees.currentBranch(at: feat.repoPath)
        guard current == base else {
            fputs("""

            '\(feat.repoPath)' is on '\(current ?? "unknown")', not '\(base)' — checkout \
            '\(base)' there first, then re-run this command. Kouen won't switch it for you.

            """, kouenStderr)
            exit(1)
        }

        let approver = feat.gates.first { $0.gate == 4 }?.approver ?? NSUserName()
        guard worktrees.merge(repoPath: feat.repoPath, branch: branch, message: "Merge '\(branch)' (Gate 4 approved by \(approver))") else {
            fputs("\nmerge failed — check for conflicts in '\(feat.repoPath)'\n", kouenStderr)
            exit(1)
        }
        print("\nMerged '\(branch)' into '\(base)'. Run `kouen task sweep` to clean up the worktree.")
    }

    private static func handleTaskSweep(_ args: [String], client: DaemonClient) throws {
        let repo = flagValue(args, flag: "--repo")
        _ = try checkedRequest(client, .featureSweepMerged(repoPath: repo))
        print("Merged-branch sweep completed.")
    }

    private static func handleTaskPreview(_ args: [String], client: DaemonClient) throws {
        let slugArg = args.first(where: { !$0.hasPrefix("--") })
        let fileType = flagValue(args, flag: "--file") ?? "progress" // "progress" or "architecture"

        let targetSlug: String
        let repoPath: String
        if let slugArg {
            targetSlug = slugArg
            let resp = try checkedRequest(client, .featureGet(slug: targetSlug))
            if case let .featureInfo(summary) = resp, let feat = summary {
                repoPath = feat.repoPath
            } else {
                repoPath = FileManager.default.currentDirectoryPath
            }
        } else {
            let cwd = FileManager.default.currentDirectoryPath
            let resp = try checkedRequest(client, .featureList(repoPath: cwd))
            if case let .features(list) = resp, let first = list.first {
                targetSlug = first.slug
                repoPath = first.repoPath
            } else {
                fputs("Usage: kouen task preview [<slug>] [--file architecture|progress]\n", kouenStderr)
                exit(1)
            }
        }

        let targetURL: URL
        if fileType == "architecture" {
            targetURL = KouenFeatureMarkdownSync.architectureFileURL(for: targetSlug, repoPath: repoPath)
        } else {
            targetURL = KouenFeatureMarkdownSync.progressFileURL(for: targetSlug, repoPath: repoPath)
        }

        guard FileManager.default.fileExists(atPath: targetURL.path) else {
            fputs("Markdown file not found at: \(targetURL.path)\n", kouenStderr)
            exit(1)
        }

        openMarkdownPreview(path: targetURL.path)
        print("Opened Preview GUI for \(targetSlug) (\(targetURL.lastPathComponent))")
    }

    /// P46 Phase 4: compiles what a PR description needs — the diff, which gates cleared, the
    /// task checklist, and (best-effort) the agent session that did the work — so `gh pr create
    /// --body "$(kouen task pack-pr <slug>)"` doesn't need it hand-assembled.
    private static func handleTaskPackPr(_ args: [String], client: DaemonClient) async throws {
        let slugArg = args.first(where: { !$0.hasPrefix("--") })
        let outPath = flagValue(args, flag: "--out")

        let targetSlug: String
        if let slugArg {
            targetSlug = slugArg
        } else {
            let cwd = FileManager.default.currentDirectoryPath
            guard case let .features(list) = try checkedRequest(client, .featureList(repoPath: cwd)), let first = list.first else {
                fputs("Usage: kouen task pack-pr [<slug>] [--out <file>]\n", kouenStderr)
                exit(1)
            }
            targetSlug = first.slug
        }

        guard case let .featureInfo(summary) = try checkedRequest(client, .featureGet(slug: targetSlug)), let feat = summary else {
            fputs("Task/Feature not found: '\(targetSlug)'\n", kouenStderr)
            exit(1)
        }

        var md = "# \(feat.slug)\n\n"

        if let branch = feat.branch, let base = feat.baseBranch {
            let stat = WorktreeManager().diffStat(repoPath: feat.repoPath, branch: branch, base: base) ?? "(no diff)"
            md += "## Changes (`\(base)...\(branch)`)\n\n```\n\(stat)\n```\n\n"
        }

        md += "## Gate Approvals\n\n"
        let gateNames = [1: "Architect design", 2: "Scenario list", 3: "Seam agreement", 4: "Merge Review"]
        for g in 1...4 {
            let name = gateNames[g] ?? "Gate \(g)"
            if let approval = feat.gates.first(where: { $0.gate == g && $0.approved }) {
                md += "- [x] Gate \(g) (\(name)) — approved by \(approval.approver)\n"
            } else {
                md += "- [ ] Gate \(g) (\(name)) — pending\n"
            }
        }

        if !feat.tasks.isEmpty {
            md += "\n## Task Checklist\n\n"
            for task in feat.tasks {
                md += "- [\(task.done ? "x" : " ")] \(task.label)\n"
            }
        }

        // Best-effort: the agent session whose transcript matches this feature's worktree.
        if let worktreePath = feat.worktreePath {
            let records = await AgentHistoryScanner.shared.getOrScan()
            if let record = records.first(where: { $0.projectPath == worktreePath || $0.projectPath == feat.repoPath }) {
                md += "\n## Session Summary\n\n"
                md += "**Agent:** \(record.agentKind.displayName)\n\n"
                md += "**First prompt:**\n> \(record.firstPrompt.replacingOccurrences(of: "\n", with: "\n> "))\n"
            }
        }

        if let outPath {
            try md.write(toFile: outPath, atomically: true, encoding: .utf8)
            print("Wrote PR pack to \(outPath)")
        } else {
            print(md)
        }
    }

    static func openMarkdownPreview(path: String) {
        if ProcessInfo.processInfo.environment["KOUEN_SURFACE_ID"] != nil {
            print("\u{1B}]7735;\(path)\u{07}", terminator: "")
            fflush(nil)   // all streams; `stdout` itself is a non-Sendable global on Linux
        } else {
            #if canImport(Darwin)
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
            process.arguments = [path]
            try? process.run()
            #endif
        }
    }
}
