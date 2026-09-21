import Foundation
import KouenCore
import KouenIPC

extension KouenCLI {
    public static func handleContext(_ args: [String], client: DaemonClient?) async throws {
        let sub = args.first ?? "help"
        let engine = ContextResolutionEngine()
        let cwd = FileManager.default.currentDirectoryPath

        switch sub {
        case "diff":
            let staged = args.contains("--staged")
            let full = args.contains("--all")
            let output = engine.resolveDiff(cwd: cwd, staged: staged, full: full)
            print(output)

        case "file":
            guard args.count >= 2 else {
                fputs("Usage: kouen context file <path>\n", kouenStderr)
                exit(1)
            }
            let path = args[1]
            let output = engine.resolveFile(path: path, cwd: cwd)
            print(output)

        case "pane":
            guard args.count >= 2 else {
                fputs("Usage: kouen context pane <surfaceID> [--tail <lines>]\n", kouenStderr)
                exit(1)
            }
            let surfaceID = args[1]
            let tailCount = flagValue(args, flag: "--tail").flatMap { Int($0) } ?? 50
            let output = await engine.resolvePane(surfaceID: surfaceID, tail: tailCount, daemonClient: client)
            print(output)

        case "last":
            var activeSurface: String?
            if let client = client,
               let snapshot = try? client.request(.getSnapshot),
               case let .snapshot(snap) = snapshot {
                // Bug fix: was `activeTab?.id` (the TAB's uuid) — @last/@error/@pane/@builderror
                // all need a real SURFACE uuid, which only coincidentally matches a tab's id for
                // a single-pane tab. Falls back to the first leaf for a split tab (same fallback
                // FleetViewModel/KouenCLI+Agent's firstSurfaceID(of:) already use).
                let activeTab = snap.activeWorkspace?.activeTab
                activeSurface = activeTab?.rootPane.surfaceID?.uuidString
                    ?? activeTab?.rootPane.allSurfaceIDs().first?.uuidString
            }
            let output = await engine.resolveLast(daemonClient: client, activeSurfaceID: activeSurface)
            print(output)

        case "error":
            var activeSurface: String?
            if let client = client,
               let snapshot = try? client.request(.getSnapshot),
               case let .snapshot(snap) = snapshot {
                // Bug fix: was `activeTab?.id` (the TAB's uuid) — @last/@error/@pane/@builderror
                // all need a real SURFACE uuid, which only coincidentally matches a tab's id for
                // a single-pane tab. Falls back to the first leaf for a split tab (same fallback
                // FleetViewModel/KouenCLI+Agent's firstSurfaceID(of:) already use).
                let activeTab = snap.activeWorkspace?.activeTab
                activeSurface = activeTab?.rootPane.surfaceID?.uuidString
                    ?? activeTab?.rootPane.allSurfaceIDs().first?.uuidString
            }
            let output = await engine.resolveError(cwd: cwd, daemonClient: client, activeSurfaceID: activeSurface)
            print(output)

        case "graph":
            guard args.count >= 2 else {
                fputs("Usage: kouen context graph <query>\n", kouenStderr)
                exit(1)
            }
            let query = args.dropFirst().joined(separator: " ")
            let output = engine.resolveGraph(query: query, cwd: cwd)
            print(output)

        case "issue":
            let output = engine.resolveIssue(cwd: cwd)
            print(output)

        case "inject":
            let prompt = args.dropFirst().joined(separator: " ")
            guard !prompt.isEmpty else {
                fputs("Usage: kouen context inject \"<prompt with @-mentions>\"\n", kouenStderr)
                exit(1)
            }
            var activeSurface: String?
            if let client = client,
               let snapshot = try? client.request(.getSnapshot),
               case let .snapshot(snap) = snapshot {
                // Bug fix: was `activeTab?.id` (the TAB's uuid) — @last/@error/@pane/@builderror
                // all need a real SURFACE uuid, which only coincidentally matches a tab's id for
                // a single-pane tab. Falls back to the first leaf for a split tab (same fallback
                // FleetViewModel/KouenCLI+Agent's firstSurfaceID(of:) already use).
                let activeTab = snap.activeWorkspace?.activeTab
                activeSurface = activeTab?.rootPane.surfaceID?.uuidString
                    ?? activeTab?.rootPane.allSurfaceIDs().first?.uuidString
            }
            let resolved = await engine.resolveTemplate(
                prompt,
                cwd: cwd,
                daemonClient: client,
                activeSurfaceID: activeSurface
            )
            print(resolved)

        default:
            printContextHelp()
        }
    }

    private static func printContextHelp() {
        print("""
        Usage: kouen context <subcommand> [options]

        Subcommands:
          diff [--staged] [--all]     Output git diff (token-guarded and filtered)
          file <path>                 Output bounded file contents
          pane <surfaceID> [--tail N] Capture tail output of a specific pane
          last                        Capture recent output from active pane
          error                       Extract latest compiler or runtime error stacktrace
          graph <query>               Query Graphify AST summary for a symbol or feature
          issue                       Output current SDLC feature and checklist
          inject "<template>"         Resolve all @-mentions (@diff, @file:x, @last, @error)

        Examples:
          kouen context diff | claude
          kouen context pane 2 --tail 40 | claude
          kouen context error | claude
          kouen context inject "Fix this error: @error in @file:Sources/App.swift" | claude
        """)
    }
}
