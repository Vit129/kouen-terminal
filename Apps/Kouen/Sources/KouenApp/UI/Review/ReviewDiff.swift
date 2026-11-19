import Foundation
import KouenGit
import KouenCore

struct ReviewDiff: Sendable {
    enum Kind: String, Hashable, Sendable {
        case staged = "Staged"
        case unstaged = "Unstaged"
        case untracked = "New"
    }

    struct Line: Hashable, Sendable, Identifiable {
        let id: Int
        let hunk: Int
        let line: Int
        let text: String
        let oldLine: Int?
    }

    struct File: Sendable, Identifiable {
        let path: String
        let kind: Kind
        let patch: String
        var id: String { kind.rawValue + ":" + path }

        let lines: [Line]

        init(path: String, kind: Kind, patch: String) {
            self.path = path
            self.kind = kind
            self.patch = patch
            self.lines = Self.parseLines(patch)
        }

        private static func parseLines(_ patch: String) -> [Line] {
            var old = 0
            var new = 0
            return GitParsers.parseDiffHunks(patch).hunks.enumerated().flatMap { hunkIndex, hunk -> [(Int, Int, String, Int?)] in
                guard let header = hunk.first else { return [] }
                let ranges = header.split(separator: " ")
                guard ranges.count >= 3,
                      let oldRange = ranges[1].dropFirst().split(separator: ",").first,
                      let newRange = ranges[2].dropFirst().split(separator: ",").first,
                      let oldStart = Int(oldRange), let newStart = Int(newRange) else { return [] }
                old = oldStart
                new = newStart
                return hunk.dropFirst().compactMap { text in
                    switch text.first {
                    case "-": defer { old += 1 }; return (hunkIndex, old, text, old)
                    case "+": defer { new += 1 }; return (hunkIndex, new, text, nil)
                    case " ": defer { new += 1; old += 1 }; return (hunkIndex, new, text, old)
                    default: return nil
                    }
                }
            }.enumerated().map { Line(id: $0.offset, hunk: $0.element.0, line: $0.element.1, text: $0.element.2, oldLine: $0.element.3) }
        }
    }

    let root: String
    let files: [File]

    struct LoadError: LocalizedError {
        let errorDescription: String?
    }

    private static func run(_ arguments: [String], at directory: String, allowDifference: Bool = false) async throws -> String {
        try Task.checkCancellation()
        let result = await ProcessRunner.runAsync(
            executable: GitRunner.shared.gitExecutableURL.path,
            arguments: ["-C", directory] + arguments,
            timeout: 10
        )
        try Task.checkCancellation()
        guard !result.stdoutWasTruncated else {
            throw LoadError(errorDescription: "Git output exceeded the review limit. Narrow the changes and refresh.")
        }
        guard !result.isTimedOut, result.exitCode == 0 || (allowDifference && result.exitCode == 1) else {
            throw LoadError(errorDescription: result.stderr.isEmpty ? "Git could not load changes." : result.stderr)
        }
        return result.stdout
    }

    static func worktreeRoot(cwd: String) async throws -> String {
        try await run(["rev-parse", "--show-toplevel"], at: cwd).trimmingCharacters(in: .newlines)
    }

    static func load(cwd: String, restrictingTo selection: [File]? = nil) async throws -> Self {
        let root = try await worktreeRoot(cwd: cwd)
        let flags = ["--literal-pathspecs", "diff", "--no-ext-diff", "--no-textconv", "--no-renames", "--no-color"]
        var files: [File] = []
        for kind in [Kind.staged, .unstaged] {
            let selectedPaths = selection?.filter { $0.kind == kind }.map(\.path)
            if selectedPaths?.isEmpty == true { continue }
            let mode = kind == .staged ? ["--cached"] : []
            let result = try await run(
                flags + mode + ["--raw", "-z", "--patch", "--"] + (selectedPaths ?? []), at: root
            )
            files += try parseFiles(result, kind: kind)
        }
        let selectedNewPaths = selection?.filter { $0.kind == .untracked }.map(\.path)
        if selectedNewPaths?.isEmpty == true { return Self(root: root, files: files) }
        let newPaths = try await run(
            ["--literal-pathspecs", "ls-files", "--others", "--exclude-standard", "-z", "--"] + (selectedNewPaths ?? []),
            at: root
        )
        for path in newPaths.split(separator: "\0").map(String.init) {
            let patch = try await run(flags + ["--no-index", "--", "/dev/null", "./" + path],
                at: root, allowDifference: true)
            files.append(File(path: path, kind: .untracked, patch: patch))
        }
        return Self(root: root, files: files)
    }

    static func loadPRPatch(root: String, head: PRFeedbackHead) async throws -> [File] {
        let mergeBase = try await run(["merge-base", head.baseRefOid, head.headRefOid], at: root)
            .trimmingCharacters(in: .newlines)
        let patch = try await run([
            "--literal-pathspecs", "diff", "--no-ext-diff", "--no-textconv", "--find-renames", "--no-color",
            "--raw", "-z", "--patch", mergeBase, head.headRefOid, "--"
        ], at: root)
        return try parseFiles(patch, kind: .unstaged)
    }

    private static func parseFiles(_ result: String, kind: Kind) throws -> [File] {
        guard !result.isEmpty else { return [] }
        guard let boundary = result.range(of: "\0\0") else {
            throw LoadError(errorDescription: "Git returned an incomplete patch.")
        }
        var fields = result[..<boundary.lowerBound].split(separator: "\0").makeIterator()
        var paths: [String] = []
        while let header = fields.next() {
            guard header.hasPrefix(":"), let source = fields.next() else {
                throw LoadError(errorDescription: "Git returned an incomplete file record.")
            }
            let status = header.split(separator: " ").last?.first
            if status == "R" || status == "C" {
                guard let destination = fields.next() else {
                    throw LoadError(errorDescription: "Git returned an incomplete rename record.")
                }
                paths.append(String(destination))
            } else {
                paths.append(String(source))
            }
        }
        let payload = result[boundary.upperBound...]
        let patches = payload.components(separatedBy: "\ndiff --git ")
        guard paths.count == patches.count,
              payload.hasPrefix("diff --git ") else {
            throw LoadError(errorDescription: "Git returned inconsistent file and patch lists.")
        }
        return zip(paths, patches).enumerated().map { index, pair in
            let (path, patch) = pair
            return File(path: path, kind: kind, patch: index == 0 ? patch : "diff --git " + patch)
        }
    }
}
