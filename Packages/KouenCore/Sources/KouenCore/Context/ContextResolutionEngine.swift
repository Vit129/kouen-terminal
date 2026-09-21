import Foundation
import KouenIPC

/// Engine that resolves semantic `@`-mentions (`@diff`, `@file`, `@pane`, `@error`, `@graph`, `@issue`)
/// into clean, token-guarded context blocks suitable for AI agent CLI prompts.
public struct ContextResolutionEngine: Sendable {
    public init() {}

    /// Resolves all `@`-mention tokens in a user prompt string.
    public func resolveTemplate(
        _ template: String,
        cwd: String,
        daemonClient: DaemonClient? = nil,
        activeSurfaceID: String? = nil
    ) async -> String {
        var resolved = template

        // 1. @diff or @diff:staged
        if resolved.contains("@diff") {
            let staged = resolved.contains("@diff:staged")
            let diffContent = resolveDiff(cwd: cwd, staged: staged)
            resolved = resolved.replacingOccurrences(of: "@diff:staged", with: diffContent)
            resolved = resolved.replacingOccurrences(of: "@diff", with: diffContent)
        }

        // 2. @file:<path>
        let fileRegex = try? NSRegularExpression(pattern: #"@file:([^\s]+)"#)
        if let matches = fileRegex?.matches(in: resolved, range: NSRange(resolved.startIndex..., in: resolved)) {
            for match in matches.reversed() {
                guard let range = Range(match.range, in: resolved),
                      let pathRange = Range(match.range(at: 1), in: resolved) else { continue }
                let relPath = String(resolved[pathRange])
                let content = resolveFile(path: relPath, cwd: cwd)
                resolved.replaceSubrange(range, with: content)
            }
        }

        // 3. @pane:<id>
        let paneRegex = try? NSRegularExpression(pattern: #"@pane:([a-zA-Z0-9\-]+)"#)
        if let matches = paneRegex?.matches(in: resolved, range: NSRange(resolved.startIndex..., in: resolved)) {
            for match in matches.reversed() {
                guard let range = Range(match.range, in: resolved),
                      let idRange = Range(match.range(at: 1), in: resolved) else { continue }
                let targetID = String(resolved[idRange])
                let content = await resolvePane(surfaceID: targetID, daemonClient: daemonClient)
                resolved.replaceSubrange(range, with: content)
            }
        }

        // 4. @error
        if resolved.contains("@error") {
            let errContent = await resolveError(cwd: cwd, daemonClient: daemonClient, activeSurfaceID: activeSurfaceID)
            resolved = resolved.replacingOccurrences(of: "@error", with: errContent)
        }

        // 5. @last
        if resolved.contains("@last") {
            let lastContent = await resolveLast(daemonClient: daemonClient, activeSurfaceID: activeSurfaceID)
            resolved = resolved.replacingOccurrences(of: "@last", with: lastContent)
        }

        // 6. @graph:<symbol>
        let graphRegex = try? NSRegularExpression(pattern: #"@graph:([^\s]+)"#)
        if let matches = graphRegex?.matches(in: resolved, range: NSRange(resolved.startIndex..., in: resolved)) {
            for match in matches.reversed() {
                guard let range = Range(match.range, in: resolved),
                      let symRange = Range(match.range(at: 1), in: resolved) else { continue }
                let query = String(resolved[symRange])
                let content = resolveGraph(query: query, cwd: cwd)
                resolved.replaceSubrange(range, with: content)
            }
        }

        // 7. @issue
        if resolved.contains("@issue") {
            let issueContent = resolveIssue(cwd: cwd)
            resolved = resolved.replacingOccurrences(of: "@issue", with: issueContent)
        }

        // 8. @builderror — Tier 1 verification's full failure output (P46 Phase 4 follow-up),
        // distinct from @error's terminal-scrollback heuristic scrape: this is the exact
        // captured `swift build`/`tsc`/etc. output, not a guess from what's visible on screen.
        if resolved.contains("@builderror") {
            let content = await resolveBuildError(daemonClient: daemonClient, activeSurfaceID: activeSurfaceID)
            resolved = resolved.replacingOccurrences(of: "@builderror", with: content)
        }

        return resolved
    }

    // MARK: - Token Resolvers

    /// Resolves git diff from the working directory.
    public func resolveDiff(cwd: String, staged: Bool = false, full: Bool = false) -> String {
        let pipe = Pipe()
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.currentDirectoryURL = URL(fileURLWithPath: cwd)
        process.arguments = staged ? ["diff", "--cached"] : ["diff"]
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice   // never read — an undrained Pipe() is its own deadlock risk

        do {
            try process.run()
            // Read to EOF BEFORE waitUntilExit(): a real diff (this function's whole purpose)
            // can easily exceed the pipe buffer, so waiting for exit first deadlocks
            // deterministically — same failure mode documented in
            // agent-memory/knowledge/patterns/process-pipe-deadlock.md.
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            process.waitUntilExit()
            let raw = String(data: data, encoding: .utf8) ?? ""
            if raw.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return "[No uncommitted changes in \(cwd)]"
            }
            if full {
                return "```diff\n" + raw + "\n```"
            }
            let sanitized = TokenGuard.sanitizeDiff(raw)
            return "```diff\n" + sanitized + "\n```"
        } catch {
            return "[Error running git diff: \(error.localizedDescription)]"
        }
    }

    /// Resolves file contents relative to cwd.
    public func resolveFile(path: String, cwd: String) -> String {
        let fullPath = path.hasPrefix("/") ? path : (cwd as NSString).appendingPathComponent(path)
        guard FileManager.default.fileExists(atPath: fullPath) else {
            return "[File not found: \(path)]"
        }

        guard let data = try? Data(contentsOf: URL(fileURLWithPath: fullPath)),
              let content = String(data: data, encoding: .utf8) else {
            return "[Unable to read file: \(path)]"
        }

        let bounded = TokenGuard.truncateTail(content, maxLines: 300)
        let ext = (path as NSString).pathExtension
        return "### File: \(path)\n```\(ext)\n\(bounded)\n```"
    }

    /// Resolves tail output of a specific surface/pane via daemon IPC.
    public func resolvePane(surfaceID: String, tail: Int? = 50, daemonClient: DaemonClient?) async -> String {
        guard let client = daemonClient else {
            return "[Daemon client unavailable to capture pane \(surfaceID)]"
        }

        guard let response = try? await client.request(.capturePane(surfaceID: surfaceID, includeScrollback: true)),
              case let .text(output) = response else {
            return "[No output captured from pane \(surfaceID)]"
        }

        let truncated = TokenGuard.truncateTail(output, maxLines: tail ?? 50)
        return "### Pane (\(surfaceID)) Output:\n```text\n\(truncated)\n```"
    }

    /// Resolves the last terminal output in the active surface.
    public func resolveLast(daemonClient: DaemonClient?, activeSurfaceID: String?) async -> String {
        guard let surfaceID = activeSurfaceID else {
            return "[No active surface for @last output]"
        }
        return await resolvePane(surfaceID: surfaceID, tail: 30, daemonClient: daemonClient)
    }

    /// Resolves error stacktrace from the scrollback of the active or nearby pane.
    public func resolveError(cwd: String, daemonClient: DaemonClient?, activeSurfaceID: String?) async -> String {
        guard let surfaceID = activeSurfaceID, let client = daemonClient else {
            return "[No active terminal surface to extract error]"
        }

        guard let response = try? await client.request(.capturePane(surfaceID: surfaceID, includeScrollback: true)),
              case let .text(output) = response else {
            return "[No error stacktrace captured]"
        }

        let lines = output.components(separatedBy: .newlines)
        var errorLines: [String] = []
        var capturing = false

        // Heuristic: capture lines around error/fatal/panic/exception/FAIL
        for line in lines {
            let lower = line.lowercased()
            if lower.contains("error:") || lower.contains("fatal:") || lower.contains("panic:") ||
               lower.contains("exception") || lower.contains("traceback") || lower.contains("fail") {
                capturing = true
            }
            if capturing {
                errorLines.append(line)
                if errorLines.count >= 60 { break }
            }
        }

        if errorLines.isEmpty {
            // Fallback to last 25 lines of the pane
            let fallback = lines.suffix(25).joined(separator: "\n")
            return "### Recent Terminal Output:\n```text\n\(fallback)\n```"
        }

        return "### Captured Error / Stacktrace:\n```text\n\(errorLines.joined(separator: "\n"))\n```"
    }

    /// Resolves Graphify AST knowledge for a symbol or query.
    public func resolveGraph(query: String, cwd: String) -> String {
        let graphSummaryPath = (cwd as NSString).appendingPathComponent("graphify-out/GRAPH_SUMMARY.md")
        if FileManager.default.fileExists(atPath: graphSummaryPath),
           let content = try? String(contentsOfFile: graphSummaryPath, encoding: .utf8) {
            let matchingLines = content.components(separatedBy: .newlines).filter { $0.localizedCaseInsensitiveContains(query) }
            if !matchingLines.isEmpty {
                return "### Knowledge Graph for '\(query)':\n" + matchingLines.prefix(15).joined(separator: "\n")
            }
        }
        return "[Knowledge graph query for '\(query)': no direct match found in graphify-out]"
    }

    /// Resolves active issue/feature task from FeatureStore.
    public func resolveIssue(cwd: String) -> String {
        let store = FeatureStore.shared
        let features = store.list(repoPath: cwd)
        if let feature = features.first(where: { $0.supersededBy == nil }) ?? features.first {
            var desc = "### Active Feature: \(feature.slug) [Phase: \(feature.phase.rawValue)]\n"
            desc += "Branch: \(feature.branch ?? "unknown") | Base: \(feature.baseBranch ?? "main")\n"
            if !feature.tasks.isEmpty {
                desc += "Tasks:\n"
                for task in feature.tasks {
                    desc += "- [\(task.done ? "x" : " ")] \(task.label)\n"
                }
            }
            return desc
        }
        return "[No active feature tracked for \(cwd)]"
    }

    /// Resolves the active surface's last Tier 1 verification failure — the full captured output
    /// `CheckpointManager`/`VerificationRunner`'s daemon-side hook stored, not a scrollback guess.
    public func resolveBuildError(daemonClient: DaemonClient?, activeSurfaceID: String?) async -> String {
        guard let surfaceID = activeSurfaceID, let client = daemonClient else {
            return "[No active terminal surface to fetch a build error for]"
        }
        guard let response = try? client.request(.getVerificationOutput(surfaceID: surfaceID)),
              case let .text(output) = response, !output.isEmpty
        else {
            return "[No verification failure recorded for this surface]"
        }
        return "### Build/Verification Failure:\n```text\n\(output)\n```"
    }
}
