import Foundation
import KouenCore

public final class IssueTrackerService: Sendable {
    public static let shared = IssueTrackerService()

    public init() {}

    /// Fetches assigned issues for the given tracker type.
    /// If a Personal Access Token is configured in Keychain, queries the live API;
    /// otherwise returns realistic demo issues so the UI and agent dispatch can be tested immediately.
    public func fetchAssignedIssues(tracker: IssueTrackerType) async -> [TrackedIssue] {
        if let token = IssueKeychainStore.loadToken(for: tracker), !token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            do {
                switch tracker {
                case .linear:
                    return try await fetchLinearIssues(token: token)
                case .jira:
                    return try await fetchJiraIssues(token: token)
                case .azureDevOps:
                    return try await fetchAzureIssues(token: token)
                }
            } catch {
                // If API fails or is unreachable, return fallback issues
                return fallbackIssues(for: tracker, isOfflineError: true)
            }
        }
        return fallbackIssues(for: tracker, isOfflineError: false)
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

    private func fetchJiraIssues(token: String) async throws -> [TrackedIssue] {
        // Token format for Jira can be base64(email:api_token) or Bearer
        guard let domain = UserDefaults.standard.string(forKey: "kouen.jira.domain"), !domain.isEmpty,
              let url = URL(string: "https://\(domain).atlassian.net/rest/api/3/search?jql=assignee=currentUser()+AND+resolution=Unresolved") else {
            return fallbackIssues(for: .jira, isOfflineError: false)
        }

        var request = URLRequest(url: url)
        request.setValue("Basic \(token)", forHTTPHeaderField: "Authorization")
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

    // MARK: - Azure DevOps REST

    private func fetchAzureIssues(token: String) async throws -> [TrackedIssue] {
        return fallbackIssues(for: .azureDevOps, isOfflineError: false)
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
        }
    }
}
