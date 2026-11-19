import Foundation
import KouenIPC

public enum ReviewWorktree {
    public static func binding(at directory: String) -> ReviewWorktreeBinding? {
        guard let root = git(["rev-parse", "--show-toplevel"], at: directory),
              let gitDirectory = git(["rev-parse", "--absolute-git-dir"], at: directory),
              let head = git(["rev-parse", "--verify", "HEAD"], at: directory),
              GitHubCLIClient.isFeedbackOID(head),
              let branch = git(["symbolic-ref", "--quiet", "--short", "HEAD"], at: directory)
        else { return nil }
        return ReviewWorktreeBinding(root: canonical(root), gitDirectory: canonical(gitDirectory),
                                     branch: branch, head: head)
    }

    public static func matchesRepository(_ head: PRFeedbackHead, at directory: String) -> Bool {
        guard let repository = head.headRepository?.nameWithOwner,
              let remotes = git(["remote"], at: directory) else { return false }
        return remotes.split(separator: "\n").contains { remote in
            guard let location = git(["remote", "get-url", "--", String(remote)], at: directory) else { return false }
            let url = URL(string: location)
            let parts = location.split(separator: ":", maxSplits: 1)
            let host: String?
            let path: String
            if let url, let urlHost = url.host {
                host = urlHost
                path = String(url.path.drop(while: { $0 == "/" }))
            } else if parts.count == 2, !location.contains("://") {
                host = parts[0].split(separator: "@").last.map(String.init)
                path = String(parts[1])
            } else { return false }
            let name = path.hasSuffix(".git") ? String(path.dropLast(4)) : path
            return host?.lowercased() == head.host.lowercased() && name.lowercased() == repository.lowercased()
        }
    }

    private static func git(_ args: [String], at directory: String) -> String? {
        let result = ProcessRunner.run(executable: "git", arguments: args, in: directory, timeout: 4)
        guard result.isSuccess, !result.isTimedOut, !result.stdoutWasTruncated else { return nil }
        let value = result.stdout.trimmingCharacters(in: .newlines)
        return value.isEmpty ? nil : value
    }

    private static func canonical(_ path: String) -> String {
        URL(fileURLWithPath: path).resolvingSymlinksInPath().standardizedFileURL.path
    }
}

public enum ReviewFeedbackText {
    public static func sanitize(_ text: String) -> String {
        var clean = text
        for prefix in ["\u{1b}[", "\u{9b}"] {
            for suffix in ["200~", "201~"] {
                clean = clean.replacingOccurrences(of: prefix + suffix, with: "")
            }
        }
        return String(clean.unicodeScalars.filter {
            $0 == "\n" || $0 == "\t" || !CharacterSet.controlCharacters.contains($0)
        })
    }

    public static func paste(_ text: String) -> Data? {
        guard !text.isEmpty, text.utf8.count <= ReviewFeedbackRequest.maxTextBytes else { return nil }
        let clean = sanitize(text)
        guard !clean.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        return AgentHandoffBuilder.bracketedPasteData(for: clean, submit: "")
    }
}
