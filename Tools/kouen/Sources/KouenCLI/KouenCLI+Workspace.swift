import Foundation
import KouenCore
import KouenGit

private struct WorkspaceCatalogCategory: Decodable {
    let id: String
    let name: String
    let sourceFolder: String?
    let excludedPaths: Set<String>?
}

private struct WorkspaceCatalogEntry: Codable {
    let path: String
    let categoryID: String?
    let stableID: String?
}

private struct WorkspaceReconcileReport: Encodable {
    let candidates: [WorkspaceReconciliation.Candidate]
    let unavailableRoots: [String]
    let groupsWithoutSource: [String]
}

private struct WorkspaceCLIError: Error, CustomStringConvertible {
    let description: String
}

extension KouenCLI {
    static func normalizeWorkspaceArguments(_ input: [String]) -> [String] {
        guard input.count >= 2 else { return input }
        let commands = ["project:scan": "workspace-scan", "project:reconcile": "workspace-reconcile",
                        "project:list": "workspace-project-list", "workspace:open": "workspace-open"]
        guard let command = commands[input[0] + ":" + input[1]] else { return input }
        var rest = Array(input.dropFirst(2))
        if let first = rest.first, !first.hasPrefix("-") {
            rest.removeFirst()
            let flag = command == "workspace-scan" ? "--path" : command == "workspace-reconcile" ? "--group" : "--project"
            rest.insert(contentsOf: [flag, first], at: 0)
        }
        return [command] + rest
    }

    private static func workspaceCatalog(_ args: [String]) throws -> (UserDefaults, [WorkspaceCatalogEntry]) {
        let domain = flagValue(args, flag: "--catalog-domain") ?? "com.vit129.kouen"
        guard let defaults = UserDefaults(suiteName: domain) else { throw WorkspaceCLIError(description: "Cannot open project catalog") }
        let entries = try defaults.data(forKey: "ProjectEntries").map { try JSONDecoder().decode([WorkspaceCatalogEntry].self, from: $0) } ?? []
        return (defaults, entries)
    }

    static func workspaceProjectList(_ args: [String]) throws {
        let (_, entries) = try workspaceCatalog(args)
        if args.contains("--json") { print(String(decoding: try JSONEncoder().encode(entries), as: UTF8.self)) }
        else { entries.forEach { print("\($0.stableID ?? "legacy")\t\($0.path)") } }
    }

    static func resolveWorkspaceProject(_ args: [String]) throws -> String {
        let (defaults, entries) = try workspaceCatalog(args)
        if let target = flagValue(args, flag: "--project") {
            let parts = target.split(separator: "/", omittingEmptySubsequences: false)
            if parts.count == 2, !parts[0].isEmpty, !parts[1].isEmpty {
                let categories = try defaults.data(forKey: "ProjectCategories").map { try JSONDecoder().decode([WorkspaceCatalogCategory].self, from: $0) } ?? []
                let groupIDs = Set(categories.filter { $0.name == String(parts[0]) || $0.id == String(parts[0]) }.map(\.id))
                let grouped = entries.filter { entry in
                    entry.categoryID.map(groupIDs.contains) == true && (entry.path as NSString).lastPathComponent == String(parts[1])
                }
                if grouped.count == 1 { return grouped[0].path }
                if grouped.count > 1 || groupIDs.count > 1 { throw WorkspaceCLIError(description: "Project selector is ambiguous; use its stable ID or path") }
                if !groupIDs.isEmpty { throw WorkspaceCLIError(description: "Project not found in group") }
            }
            let matches = entries.filter { $0.stableID == target || $0.path == target || ($0.path as NSString).lastPathComponent == target }
            if matches.count == 1 { return matches[0].path }
            if matches.count > 1 { throw WorkspaceCLIError(description: "Project selector is ambiguous; use its stable ID or path") }
            if target.contains("/") || target.hasPrefix(".") || target.hasPrefix("~") {
                return (target as NSString).expandingTildeInPath
            }
            throw WorkspaceCLIError(description: "Project not found; use project list or an explicit path")
        }
        let cwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).resolvingSymlinksInPath().path
        let gitRoot = GitService.shared.resolveRepoRoot(for: cwd).map {
            URL(fileURLWithPath: $0).resolvingSymlinksInPath().path
        }
        let matches = entries.filter {
            let root = URL(fileURLWithPath: $0.path).resolvingSymlinksInPath().path
            if let gitRoot { return root == gitRoot }
            return cwd == root || cwd.hasPrefix(root + "/")
        }.sorted { $0.path.count > $1.path.count }
        guard let first = matches.first, matches.count == 1 || first.path.count > matches[1].path.count else {
            throw WorkspaceCLIError(description: "Cannot infer a unique project from cwd; pass --project")
        }
        return first.path
    }

    static func workspaceReconcile(_ args: [String]) throws {
        guard args.contains("--dry-run") else {
            fputs("Usage: kouen-cli workspace-reconcile --dry-run [--json] [--catalog-domain domain]\n", kouenStderr)
            exit(1)
        }
        let (defaults, projects) = try workspaceCatalog(args)
        let decoder = JSONDecoder()
        let categories = try defaults.data(forKey: "ProjectCategories").map { try decoder.decode([WorkspaceCatalogCategory].self, from: $0) } ?? []
        var candidates: [WorkspaceReconciliation.Candidate] = []
        var unavailable: [String] = []
        var groupsWithoutSource: [String] = []
        let tracked = Set(projects.map(\.path))
        let group = flagValue(args, flag: "--group")
        let overrideRoot = flagValue(args, flag: "--root").map { ($0 as NSString).expandingTildeInPath }
        if overrideRoot != nil && group == nil {
            throw WorkspaceCLIError(description: "Specify a group when using --root")
        }
        if let group, categories.filter({ $0.id == group || $0.name == group }).count != 1 {
            throw WorkspaceCLIError(description: "Group not found or ambiguous")
        }
        for category in categories {
            if let group, category.id != group && category.name != group { continue }
            guard let root = overrideRoot ?? category.sourceFolder else {
                groupsWithoutSource.append(category.name)
                continue
            }
            guard let found = try? WorkspaceRepositoryScanner.scan(root: root) else { unavailable.append(root); continue }
            let missing = projects.filter { $0.categoryID == category.id && !FileManager.default.fileExists(atPath: $0.path) }.map(\.path)
            let available = found.filter { !tracked.contains($0) && !(category.excludedPaths ?? []).contains($0) }
            candidates += WorkspaceReconciliation.candidates(missing: missing, discovered: available)
        }
        let report = WorkspaceReconcileReport(candidates: candidates, unavailableRoots: unavailable, groupsWithoutSource: groupsWithoutSource)
        if args.contains("--json") {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys]
            print(String(decoding: try encoder.encode(report), as: UTF8.self))
        } else {
            for candidate in candidates { print("\(candidate.confidence)\t\(candidate.oldPath)\t\(candidate.newPath)") }
            for name in groupsWithoutSource {
                fputs("Group \(name) has no source folder; pass --root.\n", kouenStderr)
            }
            for root in unavailable { fputs("Unavailable source folder: \(root)\n", kouenStderr) }
        }
    }
}
