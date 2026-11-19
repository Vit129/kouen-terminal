import Foundation
import XCTest
@testable import KouenCore

final class GitHubPRFeedbackTests: XCTestCase {
    func test_TC8301_BE_IT_FiltersExactHeadAndPaginatesUnresolvedThreads() async throws {
        let fixture = FeedbackFixture()
        let client = GitHubCLIClient { args, _ in await fixture.run(args) }
        let snapshot = try await client.prFeedback(in: "/fixture")
        XCTAssertTrue(snapshot.complete)
        XCTAssertEqual(snapshot.checks.map(\.id), ["check:103", "check:105", "status:8"])
        XCTAssertEqual(snapshot.checks.first?.annotations.first?.path, "file.swift")
        XCTAssertTrue(snapshot.checks.allSatisfy { $0.commit == snapshot.head.headRefOid })
        XCTAssertEqual(snapshot.threads.map(\.id), ["current", "outdated"])
        XCTAssertEqual(snapshot.threads.last?.isOutdated, true)
        let requests = await fixture.requests
        XCTAssertTrue(requests.contains { $0.contains("cursor=second") })
        XCTAssertTrue(requests.last?.contains("github.example/base/project") == true)
        XCTAssertTrue(requests.filter { $0.first == "api" }.allSatisfy { $0.contains("github.example") })
    }

    func test_TC8301_BE_IT_ShowsPartialThreadFetch() async throws {
        let fixture = FeedbackFixture(failSecondThreadPage: true)
        let snapshot = try await GitHubCLIClient { args, _ in await fixture.run(args) }.prFeedback(in: "/fixture")
        XCTAssertFalse(snapshot.complete)
        XCTAssertEqual(snapshot.threads.map(\.id), ["current"])
    }

    func test_TC8303_FE_IT_RejectsHeadChangeDuringFetch() async throws {
        let fixture = FeedbackFixture(changeHead: true)
        do {
            _ = try await GitHubCLIClient { args, _ in await fixture.run(args) }.prFeedback(in: "/fixture")
            XCTFail("Must reject a moving head")
        } catch PRFeedbackError.stale(let old, let new) {
            XCTAssertEqual(old, FeedbackFixture.head)
            XCTAssertEqual(new, FeedbackFixture.newHead)
        }
    }
}

private actor FeedbackFixture {
    static let head = String(repeating: "a", count: 40)
    static let newHead = String(repeating: "b", count: 40)
    var requests: [[String]] = []
    let failSecondThreadPage: Bool
    let changeHead: Bool

    init(failSecondThreadPage: Bool = false, changeHead: Bool = false) {
        self.failSecondThreadPage = failSecondThreadPage
        self.changeHead = changeHead
    }

    func run(_ args: [String]) -> ProcessResult {
        requests.append(args)
        if args.first == "pr" {
            let oid = changeHead && args.contains("--repo") ? Self.newHead : Self.head
            return output("""
            {"number":42,"url":"https://github.example/base/project/pull/42","headRefName":"feature",
            "headRefOid":"\(oid)","baseRefOid":"\(Self.newHead)","headRepository":{"nameWithOwner":"base/project"}}
            """)
        }
        if args.contains("graphql") {
            let second = args.contains("cursor=second")
            if second && failSecondThreadPage { return ProcessResult(exitCode: 1, stdout: "") }
            let threads = second
                ? [thread("current"), thread("outdated", outdated: true), thread("resolved", resolved: true)]
                : [thread("current")]
            return output("""
            {"data":{"repository":{"pullRequest":{"reviewThreads":{"nodes":[\(threads.joined(separator: ","))],
            "pageInfo":{"hasNextPage":\(!second),"endCursor":"second"}}}}}}
            """)
        }
        guard let endpoint = args.last, args.contains("GET") else { return ProcessResult(exitCode: 1, stdout: "") }
        if endpoint.contains("/annotations") {
            return output(#"[{"path":"file.swift","start_line":4,"end_line":4,"message":"Test failure"}]"#)
        }
        guard endpoint.contains("/commits/\(Self.head)/") else { return ProcessResult(exitCode: 1, stdout: "") }
        if endpoint.contains("/statuses") {
            return output(#"[{"id":8,"context":"legacy","state":"error"},{"id":7,"context":"legacy","state":"failure"}]"#)
        }
        let runs: [String]
        if endpoint.hasSuffix("&page=1") {
            runs = (1...100).map { check($0, oid: Self.head) }
        } else {
            runs = [
                check(101, oid: Self.newHead, name: "old-head"),
                check(102, oid: Self.head, conclusion: "success"),
                check(103, oid: Self.head, name: "lint", annotations: 1),
                check(104, oid: Self.head, name: "cancelled", conclusion: "cancelled"),
                check(105, oid: Self.head, name: "lint", source: 2)
            ]
        }
        return output("""
        {"total_count":105,"check_runs":[\(runs.joined(separator: ","))]}
        """)
    }

    private func check(_ id: Int, oid: String, name: String = "test", conclusion: String = "failure",
                       source: Int = 1, annotations: Int = 0) -> String {
        """
        {"id":\(id),"name":"\(name)","head_sha":"\(oid)","status":"completed","conclusion":"\(conclusion)",
        "app":{"id":\(source)},"output":{"annotations_count":\(annotations)}}
        """
    }

    private func thread(_ id: String, outdated: Bool = false, resolved: Bool = false) -> String {
        """
        {"id":"\(id)","isResolved":\(resolved),"isOutdated":\(outdated),"path":"file.swift","diffSide":"RIGHT","line":4,
        "comments":{"nodes":[],"pageInfo":{"hasNextPage":false}}}
        """
    }

    private func output(_ text: String) -> ProcessResult { ProcessResult(exitCode: 0, stdout: text) }
}
