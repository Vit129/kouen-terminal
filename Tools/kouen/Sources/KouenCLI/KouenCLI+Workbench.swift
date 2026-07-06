import Foundation
import KouenCore

// MARK: - P19 Workbench CLI commands
// These mirror the vi ex workbench commands so IDE migrants can use them from any terminal.

/// kouen find <query> — fuzzy file search in cwd
func handleFind(_ args: [String]) -> Int32 {
    let query = args.first(where: { !$0.hasPrefix("-") }) ?? ""
    let cwd = FileManager.default.currentDirectoryPath
    let results = fuzzyFindFiles(query: query, in: cwd, limit: 20)
    if results.isEmpty {
        print("no matches for '\(query)'")
        return 1
    }
    results.enumerated().forEach { i, path in
        let rel = path.hasPrefix(cwd + "/") ? String(path.dropFirst(cwd.count + 1)) : path
        print("\(i + 1)  \(rel)")
    }
    return 0
}

/// kouen make [build|test|run|test] — run project task
func handleMake(_ args: [String]) -> Int32 {
    let target = args.first(where: { !$0.hasPrefix("-") })
    let cwd = FileManager.default.currentDirectoryPath

    // Inline detector (CLI can't depend on KouenApp)
    let cmd: String
    let fm = FileManager.default
    if fm.fileExists(atPath: "\(cwd)/Package.swift") {
        switch target {
        case "test": cmd = "swift test"
        default:     cmd = "swift build"
        }
    } else if fm.fileExists(atPath: "\(cwd)/package.json") {
        cmd = target == "test" ? "npm test" : "npm run build"
    } else if fm.fileExists(atPath: "\(cwd)/Makefile") {
        cmd = target.map { "make \($0)" } ?? "make"
    } else if fm.fileExists(atPath: "\(cwd)/Justfile") || fm.fileExists(atPath: "\(cwd)/justfile") {
        cmd = target.map { "just \($0)" } ?? "just"
    } else {
        cmd = target.map { "task \($0)" } ?? "task"
    }

    fputs("→ \(cmd)\n", kouenStderr)
    return vfork_and_exec(cmd)
}

/// kouen errors <file> — show LSP diagnostics (alias for kouen lsp diagnostics)
func handleErrors(_ args: [String]) -> Int32 {
    guard !args.isEmpty, !args.first!.hasPrefix("-") else {
        fputs("Usage: kouen errors <file>\n", kouenStderr)
        return 1
    }
    var lspArgs = args
    lspArgs.insert("diagnostics", at: 0)
    return Int32(KouenCLI.handleLSP(lspArgs))
}

/// kouen recent — show MRU file list from UserDefaults
func handleRecent(_ args: [String]) -> Int32 {
    let entries = UserDefaults.standard.stringArray(forKey: "KouenWorkbenchRecentFiles") ?? []
    if entries.isEmpty { print("no recent files"); return 0 }
    entries.prefix(20).enumerated().forEach { i, path in print("\(i + 1)  \(path)") }
    return 0
}

/// kouen grep <query> [path] — search files with rg or grep
func handleGrep(_ args: [String]) -> Int32 {
    let positional = args.filter { !$0.hasPrefix("-") }
    guard let query = positional.first else {
        fputs("Usage: kouen grep <query> [path]\n", kouenStderr)
        return 1
    }
    let path = positional.count > 1 ? positional[1] : "."
    let rgAvailable = FileManager.default.fileExists(atPath: "/opt/homebrew/bin/rg") ||
                      FileManager.default.fileExists(atPath: "/usr/local/bin/rg")
    let cmd = rgAvailable
        ? "rg --color=always --line-number '\(query)' \(path)"
        : "grep -rn --color=auto '\(query)' \(path)"
    return vfork_and_exec(cmd)
}

// MARK: - Helpers

private func fuzzyFindFiles(query: String, in dir: String, limit: Int) -> [String] {
    var results: [String] = []
    guard let enumerator = FileManager.default.enumerator(
        at: URL(fileURLWithPath: dir),
        includingPropertiesForKeys: [.isRegularFileKey],
        options: [.skipsHiddenFiles, .skipsPackageDescendants]
    ) else { return [] }
    let q = query.lowercased()
    for case let url as URL in enumerator {
        guard (try? url.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile) == true else { continue }
        // Skip .build, node_modules, .git
        let parts = url.pathComponents
        if parts.contains(".build") || parts.contains("node_modules") || parts.contains(".git") { continue }
        let name = url.lastPathComponent.lowercased()
        let path = url.path.lowercased()
        if q.isEmpty || name.contains(q) || path.contains(q) {
            results.append(url.path)
            if results.count >= limit { break }
        }
    }
    return results
}

/// Exec cmd via /bin/sh, inheriting stdio. Returns exit code.
@discardableResult
private func vfork_and_exec(_ cmd: String) -> Int32 {
    let proc = Process()
    proc.executableURL = URL(fileURLWithPath: "/bin/sh")
    proc.arguments = ["-c", cmd]
    proc.standardInput = FileHandle.standardInput
    proc.standardOutput = FileHandle.standardOutput
    proc.standardError = FileHandle.standardError
    do {
        try proc.run()
        proc.waitUntilExit()
        return proc.terminationStatus
    } catch {
        fputs("error: \(error)\n", kouenStderr)
        return 1
    }
}
