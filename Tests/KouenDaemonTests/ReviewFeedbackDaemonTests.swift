import Foundation
import XCTest
@testable import KouenCore
@testable import KouenDaemonCore

final class ReviewFeedbackDaemonTests: XCTestCase {
    func test_TC8304_BE_IT_RejectsChangedTargetsAndWorktreeBeforePTYEnqueue() throws {
        try withAgent { registry, target, worktree, output in
            let wrong = ReviewWorktreeBinding(root: worktree.root + "-other", gitDirectory: worktree.gitDirectory,
                                              branch: worktree.branch, head: worktree.head)
            let old = ReviewFeedbackTarget(surfaceID: target.surfaceID, ptyInstance: target.ptyInstance,
                generation: target.generation &+ 1, agentPID: target.agentPID,
                agentBirth: target.agentBirth, agentKind: target.agentKind)
            XCTAssertEqual(send(registry, request(target, wrong, "WRONG_ROOT")), .worktreeChanged)
            XCTAssertEqual(send(registry, request(old, worktree, "OLD_GENERATION")), .targetChanged)

            let busy = AgentSnapshot(kind: target.agentKind, executable: "/bin/cat", pid: target.agentPID, activity: .working)
            registry.applyAgentChanges([target.surfaceID: .init(primary: busy)])
            XCTAssertEqual(send(registry, request(target, worktree, "BUSY_AGENT")), .notIdle)

            let idle = AgentSnapshot(kind: target.agentKind, executable: "/bin/cat", pid: target.agentPID, activity: .idle)
            registry.applyAgentChanges([target.surfaceID: .init(primary: idle)])
            XCTAssertEqual(send(registry, request(target, worktree, "VALID_MARKER")), .pasted)
            XCTAssertEqual(XCTWaiter.wait(for: [output.marker], timeout: 3), .completed)
            XCTAssertFalse(output.text.contains("WRONG_ROOT"))
            XCTAssertFalse(output.text.contains("OLD_GENERATION"))
            XCTAssertFalse(output.text.contains("BUSY_AGENT"))
        }
    }

    func test_TC8305_BE_IT_DeduplicatesAttemptsAndOnlyQueuesSanitizedPaste() throws {
        try withAgent { registry, target, worktree, output in
            let input = "Once\u{1b}[201~\r\u{7}\u{9b}200~\nSecond line"
            let feedback = request(target, worktree, input)
            XCTAssertEqual(send(registry, feedback), .pasted)
            XCTAssertEqual(send(registry, feedback), .pasted)
            _ = registry.handle(.send(surfaceID: target.surfaceID, text: "VALID_MARKER", origin: .human))
            XCTAssertEqual(XCTWaiter.wait(for: [output.marker], timeout: 3), .completed)
            XCTAssertTrue(output.text.contains("\u{1b}[200~Once\r\nSecond line\u{1b}[201~VALID_MARKER")
                          || output.text.contains("\u{1b}[200~Once\nSecond line\u{1b}[201~VALID_MARKER"))
            XCTAssertEqual(output.text.components(separatedBy: "Once").count - 1, 1)
        }
    }

    private func request(_ target: ReviewFeedbackTarget, _ binding: ReviewWorktreeBinding, _ text: String) -> ReviewFeedbackRequest {
        ReviewFeedbackRequest(target: target, worktree: binding, headSHA: binding.head, attemptID: UUID(), text: text)
    }

    private func send(_ registry: SurfaceRegistry, _ request: ReviewFeedbackRequest) -> ReviewFeedbackDelivery? {
        guard case let .reviewFeedbackDelivery(result) = registry.handle(.sendReviewFeedback(request)) else { return nil }
        return result
    }

    private func withAgent(_ test: (SurfaceRegistry, ReviewFeedbackTarget, ReviewWorktreeBinding, ReviewOutputProbe) throws -> Void) throws {
        try skipUnlessLiveDaemonTests()
        let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent(".tmp/review-daemon-\(UUID())", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let home = getenv("KOUEN_HOME").map { String(cString: $0) }
        setenv("KOUEN_HOME", root.appendingPathComponent(".state").path, 1)
        defer {
            if let home { setenv("KOUEN_HOME", home, 1) } else { unsetenv("KOUEN_HOME") }
            try? FileManager.default.removeItem(at: root)
        }
        try KouenPaths.ensureDirectories()
        func git(_ arguments: String...) {
            let result = ProcessRunner.run(executable: "git", arguments: arguments, in: root.path, timeout: 4)
            XCTAssertTrue(result.isSuccess, result.stderr)
        }
        git("init", "-b", "feature")
        git("-c", "user.name=Test", "-c", "user.email=test@example.invalid", "commit", "--allow-empty", "-m", "review")
        let worktree = try XCTUnwrap(ReviewWorktree.binding(at: root.path))
        let registry = SurfaceRegistry()
        defer { registry.stopMonitoring() }
        guard case let .snapshot(snapshot) = registry.handle(.getSnapshot),
              let workspace = snapshot.activeWorkspace,
              case let .tabID(tabID) = registry.handle(.newTab(workspaceID: workspace.id, cwd: root.path, shell: "/bin/zsh")),
              case let .snapshot(updated) = registry.handle(.getSnapshot),
              let tab = updated.activeWorkspace?.sessions.flatMap(\.tabs).first(where: { $0.id == tabID }),
              let id = tab.rootPane.allSurfaceIDs().first?.uuidString
        else { return XCTFail("Could not spawn PTY fixture") }
        let output = ReviewOutputProbe()
        let subscription = try XCTUnwrap(registry.subscribe(surfaceID: id) { data, _ in output.append(data) })
        defer {
            registry.cancelSubscription(surfaceID: id, token: subscription)
            _ = registry.handle(.closeTab(tabID: tabID))
        }
        // zsh runs the fixture in a separate foreground job so the registry can verify
        // the process identity, starting directory and line discipline independently.
        let child = root.appendingPathComponent("agent")
        try """
        stty -echo -icanon
        printf '\\033[?2004h\\nREADY_PID=%s;\\n' "$$"
        exec /bin/cat
        """.write(to: child, atomically: true, encoding: .utf8)
        _ = registry.handle(.send(surfaceID: id, text: "/bin/sh '\(child.path)'\r", origin: .human))
        XCTAssertEqual(XCTWaiter.wait(for: [output.ready], timeout: 4), .completed, output.text)
        let pid = try XCTUnwrap(output.pid)
        registry.applyAgentChanges([id: .init(primary: AgentSnapshot(kind: .codex, executable: "/bin/cat", pid: pid))])
        guard case let .reviewFeedbackTarget(target) = registry.handle(.inspectReviewFeedbackTarget(surfaceID: id, agentPID: pid))
        else { return XCTFail("Could not inspect foreground agent") }
        try test(registry, target, worktree, output)
    }
}

private final class ReviewOutputProbe: @unchecked Sendable {
    private let lock = NSLock()
    private var bytes = Data()
    private var seenReady = false
    private var seenMarker = false
    let ready = XCTestExpectation(description: "foreground process reports PID")
    let marker = XCTestExpectation(description: "PTY receives accepted write")

    var text: String { lock.withLock { String(decoding: bytes, as: UTF8.self) } }
    var pid: Int32? { Self.parsePID(text) }

    private static func parsePID(_ text: String) -> Int32? {
        text.firstMatch(of: /READY_PID=(\d+);/).flatMap { Int32($0.1) }
    }

    func append(_ data: Data) {
        lock.withLock {
            bytes.append(data)
            let text = String(decoding: bytes, as: UTF8.self)
            if !seenReady, Self.parsePID(text) != nil {
                seenReady = true
                ready.fulfill()
            }
            if !seenMarker, text.contains("VALID_MARKER") {
                seenMarker = true
                marker.fulfill()
            }
        }
    }
}
