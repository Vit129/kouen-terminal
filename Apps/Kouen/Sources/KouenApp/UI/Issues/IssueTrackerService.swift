import Foundation
import KouenCore

/// Whether the last `fetchAssignedIssues` call returned real data or a demo fallback, and why —
/// lets the UI tell "not configured yet" apart from "configured but the API call failed"
/// instead of showing indistinguishable demo issues either way.
public enum IssueFetchStatus: Sendable, Equatable {
    case live
    case notConfigured
    case apiError(String)
}

public final class IssueTrackerService: Sendable {
    public static let shared = IssueTrackerService()

    public init() {}

    /// Fetches assigned issues for the given tracker type, along with whether the result is
    /// live data or a demo fallback (and why). GitHub authenticates via the local `gh` CLI and
    /// needs no Keychain token; the other three need a PAT configured first.
    public func fetchAssignedIssues(tracker: IssueTrackerType) async -> (issues: [TrackedIssue], status: IssueFetchStatus) {
        if tracker == .github {
            do {
                return (try await fetchGitHubIssues(), .live)
            } catch {
                return (fallbackIssues(for: tracker, isOfflineError: true), .apiError(error.localizedDescription))
            }
        }
        if let token = IssueKeychainStore.loadToken(for: tracker), !token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            do {
                switch tracker {
                case .linear:
                    return (try await fetchLinearIssues(token: token), .live)
                case .jira:
                    return (try await fetchJiraIssues(token: token), .live)
                case .azureDevOps:
                    return (try await fetchAzureIssues(token: token), .live)
                case .github:
                    fatalError("unreachable — handled above")
                }
            } catch {
                // If API fails or is unreachable, return fallback issues
                return (fallbackIssues(for: tracker, isOfflineError: true), .apiError(error.localizedDescription))
            }
        }
        return (fallbackIssues(for: tracker, isOfflineError: false), .notConfigured)
    }

    // MARK: - Linear GraphQL

    private func fetchLinearIssues(token: String) async throws -> [TrackedIssue] {
        guard let url = URL(string: "https://api.linear.app/graphql") else { return [] }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let query = """
        query {
          viewer {
            assignedIssues(first: 25, filter: { state: { type: { nin: ["completed", "canceled"] } } }) {
              nodes {
                id
                identifier
                title
                description
                priority
                url
                state {
                  name
                }
              }
            }
          }
        }
        """

        let payload = ["query": query]
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "LinearAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid Linear API response"])
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let dataObj = json["data"] as? [String: Any],
              let viewer = dataObj["viewer"] as? [String: Any],
              let assigned = viewer["assignedIssues"] as? [String: Any],
              let nodes = assigned["nodes"] as? [[String: Any]] else {
            return []
        }

        return nodes.compactMap { dict -> TrackedIssue? in
            guard let id = dict["id"] as? String,
                  let identifier = dict["identifier"] as? String,
                  let title = dict["title"] as? String else { return nil }
            let desc = dict["description"] as? String
            let urlStr = dict["url"] as? String
            let priorityNum = dict["priority"] as? Int ?? 3
            let priority: IssuePriority = {
                switch priorityNum {
                case 1: return .urgent
                case 2: return .high
                case 3: return .medium
                case 4: return .low
                default: return .none
                }
            }()
            let stateObj = dict["state"] as? [String: Any]
            let status = stateObj?["name"] as? String ?? "In Progress"

            return TrackedIssue(
                id: id,
                key: identifier,
                title: title,
                description: desc,
                priority: priority,
                status: status,
                url: urlStr,
                trackerType: .linear
            )
        }
    }

    // MARK: - Jira REST

    /// Jira Cloud REST API v3 (`*.atlassian.net`) — the only Jira flavor this hits, since the
    /// URL is hardcoded to that domain. Cloud always authenticates via Basic auth with
    /// base64(email:api_token); there's no separate Bearer path for this endpoint, so we build
    /// the Basic header ourselves from the stored email + PAT rather than asking the user to
    /// pre-encode it (the PAT field alone was never a complete credential for this API).
    private func fetchJiraIssues(token: String) async throws -> [TrackedIssue] {
        guard let domain = UserDefaults.standard.string(forKey: "kouen.jira.domain"), !domain.isEmpty,
              let email = UserDefaults.standard.string(forKey: "kouen.jira.email"), !email.isEmpty,
              let url = URL(string: "https://\(domain).atlassian.net/rest/api/3/search?jql=assignee=currentUser()+AND+resolution=Unresolved") else {
            return fallbackIssues(for: .jira, isOfflineError: false)
        }
        guard let basicAuth = "\(email):\(token)".data(using: .utf8)?.base64EncodedString() else {
            return fallbackIssues(for: .jira, isOfflineError: false)
        }

        var request = URLRequest(url: url)
        request.setValue("Basic \(basicAuth)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "JiraAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid Jira API response"])
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let issues = json["issues"] as? [[String: Any]] else {
            return []
        }

        return issues.compactMap { dict -> TrackedIssue? in
            guard let id = dict["id"] as? String,
                  let key = dict["key"] as? String,
                  let fields = dict["fields"] as? [String: Any],
                  let summary = fields["summary"] as? String else { return nil }
            let statusObj = fields["status"] as? [String: Any]
            let statusName = statusObj?["name"] as? String ?? "Open"
            let priorityObj = fields["priority"] as? [String: Any]
            let prioName = (priorityObj?["name"] as? String ?? "").lowercased()
            let priority: IssuePriority = {
                if prioName.contains("highest") || prioName.contains("urgent") { return .urgent }
                if prioName.contains("high") { return .high }
                if prioName.contains("low") { return .low }
                return .medium
            }()

            return TrackedIssue(
                id: id,
                key: key,
                title: summary,
                description: nil,
                priority: priority,
                status: statusName,
                url: "https://\(domain).atlassian.net/browse/\(key)",
                trackerType: .jira
            )
        }
    }

    // MARK: - GitHub (via local `gh` CLI)

    private struct GitHubSearchResult: Decodable {
        let number: Int
        let title: String
        let url: String
        let state: String
        let repository: Repository
        let labels: [Label]?

        struct Repository: Decodable { let nameWithOwner: String }
        struct Label: Decodable { let name: String }
    }

    /// Uses the local `gh` CLI (already authenticated via `gh auth login`, same convention as
    /// `docs/agents/issue-tracker.md`) instead of a token/REST call — never touches Keychain.
    private func fetchGitHubIssues() async throws -> [TrackedIssue] {
        // `/usr/bin/env gh` resolves via PATH — `gh` installs to `/opt/homebrew/bin` on Apple
        // Silicon Homebrew but `/usr/local/bin` on Intel, so a hardcoded path isn't portable.
        let (stdout, _, code) = try await runProcess(
            "/usr/bin/env",
            args: ["gh", "search", "issues", "--assignee=@me", "--state=open",
                   "--json", "number,title,url,state,repository,labels", "--limit", "25"]
        )
        guard code == 0 else {
            throw NSError(domain: "GitHubCLI", code: Int(code), userInfo: [NSLocalizedDescriptionKey: "gh search issues exited \(code) — is `gh auth login` still valid?"])
        }
        guard let data = stdout.data(using: .utf8) else { return [] }
        let results = try JSONDecoder().decode([GitHubSearchResult].self, from: data)

        return results.map { item in
            let labelNames = (item.labels ?? []).map { $0.name.lowercased() }
            let priority: IssuePriority = {
                if labelNames.contains(where: { $0.contains("critical") || $0.contains("urgent") }) { return .urgent }
                if labelNames.contains(where: { $0.contains("high") }) { return .high }
                if labelNames.contains(where: { $0.contains("low") }) { return .low }
                return .medium
            }()
            return TrackedIssue(
                id: "\(item.repository.nameWithOwner)#\(item.number)",
                key: "#\(item.number)",
                title: item.title,
                description: nil,
                priority: priority,
                status: item.state.capitalized,
                url: item.url,
                trackerType: .github
            )
        }
    }

    /// Runs a local executable and returns its output. Drains both pipes CONCURRENTLY, before
    /// `waitUntilExit()` — reading sequentially or after exit deadlocks deterministically once
    /// output on either stream exceeds the pipe buffer. See
    /// agent-memory/knowledge/patterns/process-pipe-deadlock.md.
    private func runProcess(_ executablePath: String, args: [String]) async throws -> (stdout: String, stderr: String, exitCode: Int32) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executablePath)
        process.arguments = args
        let outPipe = Pipe()
        let errPipe = Pipe()
        process.standardOutput = outPipe
        process.standardError = errPipe
        try process.run()

        async let outDataTask = withCheckedContinuation { (continuation: CheckedContinuation<Data, Never>) in
            DispatchQueue.global(qos: .userInitiated).async {
                continuation.resume(returning: outPipe.fileHandleForReading.readDataToEndOfFile())
            }
        }
        async let errDataTask = withCheckedContinuation { (continuation: CheckedContinuation<Data, Never>) in
            DispatchQueue.global(qos: .userInitiated).async {
                continuation.resume(returning: errPipe.fileHandleForReading.readDataToEndOfFile())
            }
        }
        let (outData, errData) = await (outDataTask, errDataTask)
        process.waitUntilExit()

        let stdout = String(data: outData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let stderr = String(data: errData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return (stdout, stderr, process.terminationStatus)
    }

    // MARK: - Azure DevOps REST

    /// Two-step Azure DevOps REST flow: a WIQL query returns matching work item ids only
    /// (no fields), then a batch GET fetches the fields we actually render. Auth is Basic
    /// with an empty username — Azure's own convention for PAT auth (`Basic base64(":<PAT>")`).
    private func fetchAzureIssues(token: String) async throws -> [TrackedIssue] {
        guard let organization = UserDefaults.standard.string(forKey: "kouen.azure.organization"), !organization.isEmpty,
              let basicAuth = ":\(token)".data(using: .utf8)?.base64EncodedString() else {
            return fallbackIssues(for: .azureDevOps, isOfflineError: false)
        }

        guard let wiqlURL = URL(string: "https://dev.azure.com/\(organization)/_apis/wit/wiql?api-version=7.0") else {
            return fallbackIssues(for: .azureDevOps, isOfflineError: false)
        }
        var wiqlRequest = URLRequest(url: wiqlURL)
        wiqlRequest.httpMethod = "POST"
        wiqlRequest.setValue("Basic \(basicAuth)", forHTTPHeaderField: "Authorization")
        wiqlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let wiql = """
        SELECT [System.Id] FROM WorkItems \
        WHERE [System.AssignedTo] = @Me \
        AND [System.State] NOT IN ('Closed', 'Done', 'Removed') \
        ORDER BY [System.ChangedDate] DESC
        """
        wiqlRequest.httpBody = try JSONSerialization.data(withJSONObject: ["query": wiql])

        let (wiqlData, wiqlResponse) = try await URLSession.shared.data(for: wiqlRequest)
        guard let wiqlHTTP = wiqlResponse as? HTTPURLResponse, (200...299).contains(wiqlHTTP.statusCode) else {
            throw NSError(domain: "AzureDevOpsAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid Azure DevOps WIQL response"])
        }
        guard let wiqlJSON = try JSONSerialization.jsonObject(with: wiqlData) as? [String: Any],
              let workItems = wiqlJSON["workItems"] as? [[String: Any]], !workItems.isEmpty else {
            return []
        }
        let ids = workItems.compactMap { $0["id"] as? Int }
        guard !ids.isEmpty else { return [] }

        let idList = ids.map(String.init).joined(separator: ",")
        guard let fieldsURL = URL(string: "https://dev.azure.com/\(organization)/_apis/wit/workitems?ids=\(idList)&fields=System.Title,System.State,System.WorkItemType,System.TeamProject,Microsoft.VSTS.Common.Priority&api-version=7.0") else {
            return []
        }
        var fieldsRequest = URLRequest(url: fieldsURL)
        fieldsRequest.setValue("Basic \(basicAuth)", forHTTPHeaderField: "Authorization")

        let (fieldsData, fieldsResponse) = try await URLSession.shared.data(for: fieldsRequest)
        guard let fieldsHTTP = fieldsResponse as? HTTPURLResponse, (200...299).contains(fieldsHTTP.statusCode) else {
            throw NSError(domain: "AzureDevOpsAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid Azure DevOps work item response"])
        }
        guard let fieldsJSON = try JSONSerialization.jsonObject(with: fieldsData) as? [String: Any],
              let items = fieldsJSON["value"] as? [[String: Any]] else {
            return []
        }

        return items.compactMap { item -> TrackedIssue? in
            guard let id = item["id"] as? Int,
                  let fields = item["fields"] as? [String: Any],
                  let title = fields["System.Title"] as? String else { return nil }
            let state = fields["System.State"] as? String ?? "Active"
            let rawProject = fields["System.TeamProject"] as? String ?? organization
            let project = rawProject.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? rawProject
            let priorityNum = fields["Microsoft.VSTS.Common.Priority"] as? Int ?? 3
            let priority: IssuePriority = {
                switch priorityNum {
                case 1: return .urgent
                case 2: return .high
                case 3: return .medium
                case 4: return .low
                default: return .medium
                }
            }()
            return TrackedIssue(
                id: String(id),
                key: "AB#\(id)",
                title: title,
                description: nil,
                priority: priority,
                status: state,
                url: "https://dev.azure.com/\(organization)/\(project)/_workitems/edit/\(id)",
                trackerType: .azureDevOps
            )
        }
    }

    // MARK: - Helper Prompts & Branch Naming

    public static func sanitizeBranchName(key: String, title: String) -> String {
        let cleanKey = key.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let slug = title.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .prefix(5)
            .joined(separator: "-")
        return "issue/\(cleanKey)-\(slug)"
    }

    public static func generateAgentTaskPrompt(for issue: TrackedIssue) -> String {
        var text = """
        You are assigned to implement ticket [\(issue.key)]: \(issue.title)
        Priority: \(issue.priority.rawValue)
        Status: \(issue.status)
        """
        if let url = issue.url {
            text += "\nTicket URL: \(url)"
        }
        if let desc = issue.description, !desc.isEmpty {
            text += "\n\nDescription:\n\(desc)"
        }
        text += """
        

        Please inspect the codebase, design the solution, write clean Swift/code, add comprehensive tests, and ensure compilation passes with zero warnings.
        
        """
        return text
    }

    // MARK: - Demo / Fallback Issues

    private func fallbackIssues(for tracker: IssueTrackerType, isOfflineError: Bool) -> [TrackedIssue] {
        switch tracker {
        case .linear:
            return [
                TrackedIssue(
                    id: "lin-1",
                    key: "ENG-101",
                    title: "Implement Worktree Lineage & Drift Badges",
                    description: "Add lineage tracking via branch.<name>.base and calculate ahead/behind divergence against base branch.",
                    priority: .urgent,
                    status: "In Progress",
                    url: "https://linear.app",
                    trackerType: .linear
                ),
                TrackedIssue(
                    id: "lin-2",
                    key: "ENG-102",
                    title: "Add Dedicated Split-Pane Diff Viewer",
                    description: "Provide multi-file diff view with file list, diffstat, and Annotate AI Diff prompt bridge.",
                    priority: .high,
                    status: "Todo",
                    url: "https://linear.app",
                    trackerType: .linear
                ),
                TrackedIssue(
                    id: "lin-3",
                    key: "ENG-103",
                    title: "Browser Design Mode Live CSS Agent Bridge",
                    description: "Connect WebKit element styling inspection directly to active AI agent session.",
                    priority: .medium,
                    status: "Todo",
                    url: "https://linear.app",
                    trackerType: .linear
                )
            ]
        case .jira:
            return [
                TrackedIssue(
                    id: "jira-1",
                    key: "PROJ-204",
                    title: "Migrate PTY stream to Swift 6 strict concurrency",
                    description: "Ensure all actors and Sendable boundaries adhere to compiler strictness.",
                    priority: .high,
                    status: "In Progress",
                    url: nil,
                    trackerType: .jira
                ),
                TrackedIssue(
                    id: "jira-2",
                    key: "PROJ-205",
                    title: "Audit SQLite schema indices for transcript scans",
                    description: "Benchmark query latency across 10,000 transcript turns.",
                    priority: .medium,
                    status: "Backlog",
                    url: nil,
                    trackerType: .jira
                )
            ]
        case .azureDevOps:
            return [
                TrackedIssue(
                    id: "az-1",
                    key: "AB#341",
                    title: "Automate notarization and Sparkle appcast generation",
                    description: "Configure GitHub Actions runner with Xcode 16.2.",
                    priority: .medium,
                    status: "Active",
                    url: nil,
                    trackerType: .azureDevOps
                )
            ]
        case .github:
            return [
                TrackedIssue(
                    id: "gh-1",
                    key: "#42",
                    title: "gh CLI not authenticated — showing demo issues",
                    description: "Run `gh auth login` in a terminal, then refresh this tab.",
                    priority: .medium,
                    status: "Open",
                    url: nil,
                    trackerType: .github
                )
            ]
        }
    }
}
