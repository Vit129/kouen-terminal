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
    /// field) in `<projectRoot>/graphify-out/graph.json`. The parsed file index is cached per
    /// root and re-parsed only when the file's mtime changes; the first call per root parses a
    /// multi-MB file, so callers on the main thread should hop off it.
    public static func lookupFileInfo(sourceFile: String, projectRoot: URL) -> FileGraphInfo? {
        let graphURL = projectRoot.appendingPathComponent("graphify-out/graph.json")
        guard let mtime = (try? FileManager.default.attributesOfItem(atPath: graphURL.path))?[.modificationDate] as? Date
        else { return nil }
        let key = graphURL.standardizedFileURL.path
        if let cached = graphCache.entry(key: key, mtime: mtime) { return cached[sourceFile] }
        guard let data = try? Data(contentsOf: graphURL),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let nodes = json["nodes"] as? [[String: Any]]
        else { return nil }
        var index: [String: FileGraphInfo] = [:]
        for node in nodes {
            guard let file = node["source_file"] as? String, index[file] == nil,
                  let pagerank = node["pagerank"] as? Double else { continue }
            index[file] = FileGraphInfo(pagerank: pagerank, community: node["community"] as? Int ?? -1)
        }
        graphCache.store(key: key, mtime: mtime, index: index)
        return index[sourceFile]
    }

    private static let graphCache = GraphIndexCache()

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

private final class GraphIndexCache: @unchecked Sendable {
    private let lock = NSLock()
    private var entries: [String: (mtime: Date, index: [String: GraphifyLSPBridge.FileGraphInfo])] = [:]

    func entry(key: String, mtime: Date) -> [String: GraphifyLSPBridge.FileGraphInfo]? {
        lock.lock(); defer { lock.unlock() }
        guard let e = entries[key], e.mtime == mtime else { return nil }
        return e.index
    }

    func store(key: String, mtime: Date, index: [String: GraphifyLSPBridge.FileGraphInfo]) {
        lock.lock(); defer { lock.unlock() }
        if entries.count >= 8 { entries.removeAll() }
        entries[key] = (mtime, index)
    }
}
