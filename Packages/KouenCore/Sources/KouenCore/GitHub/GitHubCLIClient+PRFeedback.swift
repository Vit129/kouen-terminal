import Foundation

public struct PRFeedbackHead: Decodable, Sendable, Equatable {
    public let number: Int
    public let url: String
    public let headRefName: String
    public let headRefOid: String
    public let baseRefOid: String
    public let headRepository: Repository?

    public struct Repository: Decodable, Sendable, Equatable {
        public let nameWithOwner: String
    }

    public var host: String { URL(string: url)?.host ?? "" }
    public var repository: String {
        URL(string: url)?.pathComponents.dropFirst().prefix(2).joined(separator: "/") ?? ""
    }
    var repositorySpec: String { "\(host)/\(repository)" }
}

public struct FailedPRCheck: Sendable, Equatable, Identifiable {
    public let id: String
    public let name: String
    public let conclusion: String
    public let url: String?
    public let summary: String?
    public let commit: String
    public let annotations: [Annotation]

    public struct Annotation: Decodable, Sendable, Equatable {
        public let path: String
        public let start_line: Int
        public let end_line: Int
        public let message: String
    }
}

public struct PRReviewThread: Decodable, Sendable, Equatable, Identifiable {
    public let id: String
    public let isResolved: Bool
    public let isOutdated: Bool
    public let path: String
    public let diffSide: String
    public let line: Int?
    public let startLine: Int?
    public let startDiffSide: String?
    public let originalLine: Int?
    public let originalStartLine: Int?
    public let comments: Comments

    public struct Comments: Decodable, Sendable, Equatable {
        public let nodes: [Comment]
        public let pageInfo: PageInfo
    }
    public struct Comment: Decodable, Sendable, Equatable {
        public let author: Author?
        public let body: String
        public let diffHunk: String?
        public let originalCommit: Commit?
    }
    public struct Author: Decodable, Sendable, Equatable { public let login: String }
    public struct Commit: Decodable, Sendable, Equatable { public let oid: String }
}

public struct PageInfo: Decodable, Sendable, Equatable {
    public let hasNextPage: Bool
    public let endCursor: String?
}

public struct PRFeedbackSnapshot: Sendable, Equatable {
    public let head: PRFeedbackHead
    public let checks: [FailedPRCheck]
    public let threads: [PRReviewThread]
    public let fetchedAt: Date
    public let complete: Bool
}

public enum PRFeedbackError: LocalizedError {
    case unavailable
    case stale(String, String)
    case binding(String)
    case selectionChanged

    public var errorDescription: String? {
        switch self {
        case .unavailable: "Could not verify PR feedback. Check GitHub CLI authentication and connectivity."
        case let .stale(old, new): "PR head changed (\(old.prefix(8)) → \(new.prefix(8))). Refresh and select again."
        case let .binding(message): message
        case .selectionChanged: "Selected PR feedback changed. Refresh and select again."
        }
    }
}

extension GitHubCLIClient {
    public func feedbackHead(in directory: String, pinned: PRFeedbackHead? = nil) async throws -> PRFeedbackHead {
        let spec = pinned.map { [String($0.number), "--repo", $0.repositorySpec] } ?? []
        let head: PRFeedbackHead = try await feedbackJSON(
            ["pr", "view"] + spec + ["--json", "number,url,headRefName,headRefOid,baseRefOid,headRepository"],
            in: directory
        )
        guard head.number > 0, !head.host.isEmpty, Self.isRepositoryName(head.repository),
              head.headRepository.map({ Self.isRepositoryName($0.nameWithOwner) }) != false,
              Self.isFeedbackOID(head.headRefOid), Self.isFeedbackOID(head.baseRefOid),
              pinned == nil || (head.number == pinned?.number && head.repositorySpec == pinned?.repositorySpec)
        else { throw PRFeedbackError.unavailable }
        return head
    }

    public func prFeedback(in directory: String, pinned: PRFeedbackHead? = nil) async throws -> PRFeedbackSnapshot {
        let head = try await feedbackHead(in: directory, pinned: pinned)
        if let pinned { try Self.verifyFeedbackHead(pinned, against: head) }
        return try await collectFeedback(head, in: directory)
    }

    public func refreshPRFeedback(in directory: String, pinned: PRFeedbackHead) async throws -> PRFeedbackSnapshot {
        let head = try await feedbackHead(in: directory, pinned: pinned)
        return try await collectFeedback(head, in: directory)
    }

    private func collectFeedback(_ head: PRFeedbackHead, in directory: String) async throws -> PRFeedbackSnapshot {
        async let checks = feedbackChecks(head, in: directory)
        async let threads = feedbackThreads(head, in: directory)
        let (checkPage, threadPage) = await (checks, threads)
        let final = try await feedbackHead(in: directory, pinned: head)
        try Self.verifyFeedbackHead(head, against: final)
        return PRFeedbackSnapshot(head: head, checks: checkPage.items, threads: threadPage.items,
            fetchedAt: Date(), complete: checkPage.complete && threadPage.complete)
    }

    public static func verifyFeedbackHead(_ expected: PRFeedbackHead, against current: PRFeedbackHead) throws {
        guard expected.headRefOid == current.headRefOid else {
            throw PRFeedbackError.stale(expected.headRefOid, current.headRefOid)
        }
        guard expected == current else { throw PRFeedbackError.selectionChanged }
    }

    private static func isRepositoryName(_ name: String) -> Bool {
        let parts = name.split(separator: "/", omittingEmptySubsequences: false)
        return parts.count == 2 && parts.allSatisfy { part in
            !part.isEmpty && part != "." && part != ".." && part.utf8.allSatisfy {
                (48...57).contains($0) || (65...90).contains($0) || (97...122).contains($0)
                    || $0 == 45 || $0 == 46 || $0 == 95
            }
        }
    }

    static func isFeedbackOID(_ oid: String) -> Bool {
        oid.utf8.count == 40 && oid.utf8.allSatisfy { (48...57).contains($0) || (97...102).contains($0) }
    }

    private func feedbackJSON<T: Decodable>(_ args: [String], in directory: String) async throws -> T {
        let result = await feedbackRunner(args, directory)
        guard result.isSuccess, !result.isTimedOut, !result.stdoutWasTruncated else {
            throw PRFeedbackError.unavailable
        }
        return try JSONDecoder().decode(T.self, from: Data(result.stdout.utf8))
    }

    private struct CheckPage: Decodable {
        let total_count: Int
        let check_runs: [Run]
    }
    private struct Run: Decodable {
        let id: Int
        let name: String
        let head_sha: String
        let status: String
        let conclusion: String?
        let html_url: String?
        let app: App?
        let check_suite: Suite?
        let output: Output?
        struct App: Decodable { let id: Int }
        struct Suite: Decodable { let id: Int }
        struct Output: Decodable { let summary: String?; let annotations_count: Int? }
    }
    private struct Status: Decodable {
        let id: Int
        let context: String
        let state: String
        let target_url: String?
        let description: String?
    }

    private func feedbackChecks(_ head: PRFeedbackHead, in directory: String) async -> (items: [FailedPRCheck], complete: Bool) {
        let headRepository = head.headRepository?.nameWithOwner ?? head.repository
        guard headRepository.caseInsensitiveCompare(head.repository) != .orderedSame else {
            return await feedbackChecks(head, repository: head.repository, in: directory)
        }
        async let base = feedbackChecks(head, repository: head.repository, in: directory)
        async let fork = feedbackChecks(head, repository: headRepository, in: directory)
        let (baseChecks, forkChecks) = await (base, fork)
        var byID = Dictionary(uniqueKeysWithValues: baseChecks.items.map { ($0.id, $0) })
        for check in forkChecks.items { byID[check.id] = check }
        return (byID.values.sorted { $0.id < $1.id }, baseChecks.complete && forkChecks.complete)
    }

    private func feedbackChecks(_ head: PRFeedbackHead, repository: String,
                                in directory: String) async -> (items: [FailedPRCheck], complete: Bool) {
        let endpoint = "repos/\(repository)/commits/\(head.headRefOid)"
        let args = ["api", "--method", "GET", "--hostname", head.host]
        var runs: [String: Run] = [:]
        var statuses: [String: Status] = [:]
        var complete = true
        do {
            for page in 1...10 {
                let result: CheckPage = try await feedbackJSON(
                    args + ["\(endpoint)/check-runs?filter=all&per_page=100&page=\(page)"], in: directory)
                for run in result.check_runs where run.head_sha == head.headRefOid {
                    let source = run.app.map { String($0.id) } ?? "run-\(run.id)"
                    let suite = run.check_suite.map { String($0.id) } ?? ""
                    let key = "\(source)/\(suite)/\(run.name)"
                    if run.id > (runs[key]?.id ?? 0) { runs[key] = run }
                }
                if page * 100 >= result.total_count { break }
                if result.check_runs.count < 100 {
                    complete = false
                    break
                }
                if page == 10 { complete = false }
            }
        } catch { complete = false }
        do {
            for page in 1...10 {
                let result: [Status] = try await feedbackJSON(
                    args + ["\(endpoint)/statuses?per_page=100&page=\(page)"], in: directory)
                for status in result where status.id > (statuses[status.context]?.id ?? 0) {
                    statuses[status.context] = status
                }
                if result.count < 100 { break }
                if page == 10 { complete = false }
            }
        } catch { complete = false }
        let failures: Set<String> = ["failure", "timed_out", "action_required", "startup_failure", "stale"]
        var checkItems: [FailedPRCheck] = []
        var remainingAnnotationQueries = 16
        for run in runs.values.sorted(by: { $0.id < $1.id }) {
            guard run.status == "completed", let conclusion = run.conclusion, failures.contains(conclusion) else { continue }
            var annotations: [FailedPRCheck.Annotation] = []
            let count = run.output?.annotations_count ?? 0
            if count > 0 {
                for page in 1...min(3, (count - 1) / 30 + 1) {
                    guard remainingAnnotationQueries > 0 else { break }
                    remainingAnnotationQueries -= 1
                    do {
                        let next: [FailedPRCheck.Annotation] = try await feedbackJSON(
                            args + ["repos/\(repository)/check-runs/\(run.id)/annotations?per_page=30&page=\(page)"],
                            in: directory)
                        annotations += next
                    } catch { break }
                }
                if annotations.count < count { complete = false }
            }
            checkItems.append(FailedPRCheck(id: "check:\(run.id)", name: run.name, conclusion: conclusion,
                url: run.html_url, summary: run.output?.summary.map { String($0.prefix(1500)) },
                commit: run.head_sha, annotations: annotations))
        }
        let statusItems = statuses.values.filter { ["failure", "error"].contains($0.state) }.map {
            FailedPRCheck(id: "status:\($0.id)", name: $0.context, conclusion: $0.state, url: $0.target_url,
                summary: $0.description.map { String($0.prefix(1500)) }, commit: head.headRefOid, annotations: [])
        }
        return ((checkItems + statusItems).sorted { $0.id < $1.id }, complete)
    }

    private struct ThreadResponse: Decodable {
        let data: Payload
        let errors: [GraphQLError]?
        struct GraphQLError: Decodable { let message: String }
        struct Payload: Decodable { let repository: Repository }
        struct Repository: Decodable { let pullRequest: PullRequest }
        struct PullRequest: Decodable { let reviewThreads: Connection }
        struct Connection: Decodable { let nodes: [PRReviewThread]; let pageInfo: PageInfo }
    }

    private func feedbackThreads(_ head: PRFeedbackHead, in directory: String) async -> (items: [PRReviewThread], complete: Bool) {
        let repository = head.repository.split(separator: "/")
        let query = """
        query($owner:String!, $name:String!, $number:Int!, $cursor:String) {
          repository(owner:$owner, name:$name) {
            pullRequest(number:$number) {
              reviewThreads(first:30, after:$cursor) {
                pageInfo { hasNextPage endCursor }
                nodes {
                  id isResolved isOutdated path diffSide line startLine startDiffSide originalLine originalStartLine
                  comments(first:8) {
                    pageInfo { hasNextPage endCursor }
                    nodes { author { login } body diffHunk originalCommit { oid } }
                  }
                }
              }
            }
          }
        }
        """
        var cursor: String?
        var threads: [String: PRReviewThread] = [:]
        var complete = true
        for _ in 0..<12 {
            let args = ["api", "graphql", "--hostname", head.host, "-f", "query=\(query)",
                        "-f", "owner=\(repository[0])", "-f", "name=\(repository[1])",
                        "-F", "number=\(head.number)"] + (cursor.map { ["-f", "cursor=\($0)"] } ?? [])
            do {
                let response: ThreadResponse = try await feedbackJSON(args, in: directory)
                let page = response.data.repository.pullRequest.reviewThreads
                for thread in page.nodes where !thread.isResolved {
                    threads[thread.id] = thread
                    if thread.comments.pageInfo.hasNextPage { complete = false }
                }
                if response.errors?.isEmpty == false { complete = false }
                if !page.pageInfo.hasNextPage { return (threads.values.sorted { $0.id < $1.id }, complete) }
                guard let next = page.pageInfo.endCursor, next != cursor else { break }
                cursor = next
            } catch { break }
        }
        return (threads.values.sorted { $0.id < $1.id }, false)
    }
}
