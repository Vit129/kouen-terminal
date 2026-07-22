import Foundation

/// Bridges the editor to a project's `graphify-out/graph.json`, so a human reading code in
/// Kouen's built-in editor sees the same dependency-graph signal an agent gets from
/// `mcp__graphify__*` — without needing an agent in the loop. `graph.json`'s nodes are
/// file/module-level (one node per source file, plus imported module names), not per-symbol —
/// confirmed by inspecting a real export — so this only ever annotates "this file", never a
/// specific class/function under the cursor.
public enum GraphifyLSPBridge {
    public struct FileGraphInfo: Sendable, Equatable {
        public let pagerank: Double
        public let community: Int
    }

    /// Looks up `sourceFile` (repo-root-relative, matching `graph.json`'s own `source_file`
    /// field) in `<projectRoot>/graphify-out/graph.json`. Re-reads the file each call — call
    /// sites are hover-rate (human-paced), not hot-path; add caching if that stops being true.
    public static func lookupFileInfo(sourceFile: String, projectRoot: URL) -> FileGraphInfo? {
        let graphURL = projectRoot.appendingPathComponent("graphify-out/graph.json")
        guard let data = try? Data(contentsOf: graphURL),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let nodes = json["nodes"] as? [[String: Any]]
        else { return nil }
        guard let node = nodes.first(where: { ($0["source_file"] as? String) == sourceFile }) else { return nil }
        guard let pagerank = node["pagerank"] as? Double else { return nil }
        return FileGraphInfo(pagerank: pagerank, community: node["community"] as? Int ?? -1)
    }

    /// Shells out to the `graphify` CLI for anything beyond a flat file-level lookup — `explain`
    /// (plain-language node + neighbors) and `path` (shortest path between two nodes) are its
    /// real subcommands (confirmed via `graphify --help`; there is no CLI `query` — that's
    /// MCP-only via `graphify-mcp`). `cwd` must be the project root so `graphify` finds its own
    /// `graphify-out/`.
    public static func run(_ subcommand: String, arguments: [String], cwd: URL, binaryPath: String? = nil) -> String? {
        let resolvedBinary = binaryPath ?? ("~/.local/bin/graphify" as NSString).expandingTildeInPath
        guard FileManager.default.fileExists(atPath: resolvedBinary) else { return nil }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: resolvedBinary)
        process.arguments = [subcommand] + arguments
        process.currentDirectoryURL = cwd
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice
        do {
            try process.run()
            process.waitUntilExit()
            guard process.terminationStatus == 0 else { return nil }
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch { return nil }
    }
}
