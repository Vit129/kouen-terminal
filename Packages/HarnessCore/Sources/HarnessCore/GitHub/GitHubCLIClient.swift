import Foundation

/// Lightweight wrapper around the `gh` CLI for PR and CI status queries.
/// Requires `gh` to be installed and authenticated.
public struct GitHubCLIClient: Sendable {
    public init() {}

    // MARK: - Availability

    /// Returns true if `gh` is installed and authenticated.
    public func isAvailable() -> Bool {
        runGH(["auth", "status"]) != nil
    }

    // MARK: - PR

    public struct PRInfo: Sendable, Equatable {
        public let number: Int
        public let title: String
        public let state: PRState
        public let url: String
        public let headRefName: String
        public let isDraft: Bool
        public let checksStatus: ChecksStatus
    }

    public enum PRState: String, Sendable, Equatable {
        case open = "OPEN"
        case closed = "CLOSED"
        case merged = "MERGED"
    }

    public enum ChecksStatus: String, Sendable, Equatable {
        case pass = "pass"
        case fail = "fail"
        case pending = "pending"
        case none = "none"
    }

    /// Get PR info for the current branch in the given repo directory.
    public func prForCurrentBranch(repoPath: String) -> PRInfo? {
        let fields = "number,title,state,url,headRefName,isDraft,statusCheckRollup"
        guard let output = runGH(
            ["pr", "view", "--json", fields],
            in: repoPath
        ) else { return nil }
        return parsePRInfo(output)
    }

    // MARK: - CI Runs

    public struct CIRun: Sendable, Equatable {
        public let id: Int
        public let name: String
        public let status: String       // "completed", "in_progress", "queued"
        public let conclusion: String?  // "success", "failure", "cancelled", nil
        public let url: String
    }

    /// List recent CI runs for the current branch.
    public func ciRuns(repoPath: String, limit: Int = 5) -> [CIRun] {
        guard let output = runGH(
            ["run", "list", "--json", "databaseId,name,status,conclusion,url", "--limit", "\(limit)"],
            in: repoPath
        ) else { return [] }
        return parseCIRuns(output)
    }

    // MARK: - Actions

    /// Re-run failed jobs for a given run ID.
    @discardableResult
    public func rerunFailed(repoPath: String, runID: Int) -> Bool {
        runGH(["run", "rerun", "\(runID)", "--failed"], in: repoPath) != nil
    }

    // MARK: - Private

    private func runGH(_ args: [String], in directory: String? = nil) -> String? {
        let process = Process()
        let pipe = Pipe()
        // Resolve gh path: prefer /opt/homebrew/bin/gh, fall back to /usr/local/bin/gh
        let ghPaths = ["/opt/homebrew/bin/gh", "/usr/local/bin/gh", "/usr/bin/gh"]
        guard let ghPath = ghPaths.first(where: { FileManager.default.fileExists(atPath: $0) }) else {
            return nil
        }
        process.executableURL = URL(fileURLWithPath: ghPath)
        process.arguments = args
        if let directory {
            process.currentDirectoryURL = URL(fileURLWithPath: directory)
        }
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice
        do {
            try process.run()
            process.waitUntilExit()
            guard process.terminationStatus == 0 else { return nil }
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8)
        } catch { return nil }
    }

    private func parsePRInfo(_ json: String) -> PRInfo? {
        guard let data = json.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let number = obj["number"] as? Int,
              let title = obj["title"] as? String,
              let stateStr = obj["state"] as? String,
              let url = obj["url"] as? String,
              let headRef = obj["headRefName"] as? String
        else { return nil }

        let state = PRState(rawValue: stateStr) ?? .open
        let isDraft = obj["isDraft"] as? Bool ?? false
        let checksStatus = parseChecksStatus(obj["statusCheckRollup"])

        return PRInfo(
            number: number, title: title, state: state, url: url,
            headRefName: headRef, isDraft: isDraft, checksStatus: checksStatus
        )
    }

    private func parseChecksStatus(_ rollup: Any?) -> ChecksStatus {
        guard let checks = rollup as? [[String: Any]], !checks.isEmpty else {
            return .none
        }
        let hasFailure = checks.contains { ($0["conclusion"] as? String) == "FAILURE" }
        if hasFailure { return .fail }
        let allDone = checks.allSatisfy { ($0["status"] as? String) == "COMPLETED" }
        if allDone { return .pass }
        return .pending
    }

    private func parseCIRuns(_ json: String) -> [CIRun] {
        guard let data = json.data(using: .utf8),
              let arr = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]]
        else { return [] }
        return arr.compactMap { obj in
            guard let id = obj["databaseId"] as? Int,
                  let name = obj["name"] as? String,
                  let status = obj["status"] as? String,
                  let url = obj["url"] as? String
            else { return nil }
            return CIRun(id: id, name: name, status: status, conclusion: obj["conclusion"] as? String, url: url)
        }
    }
}
