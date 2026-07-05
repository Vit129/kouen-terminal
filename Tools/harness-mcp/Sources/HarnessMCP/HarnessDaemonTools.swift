import Foundation
import HarnessCore

/// Read-only daemon-backed MCP tools (P12 PBI-ORCH-001): list workspaces/sessions/tabs/panes
/// and read a pane's output. Wraps `DaemonClientActor` so `ToolRegistry` stays a thin dispatcher.
struct HarnessDaemonTools: Sendable {
    /// `readPaneOutput` line count when `lines` is omitted.
    static let defaultLines = 200
    /// Hard cap on `readPaneOutput` lines to keep MCP payloads bounded.
    static let maxLines = 2000
    /// Hard cap on `waitForPaneOutput` returned tail text.
    static let maxWaitTailCharacters = 8192
    static let controlGateVariable = "HARNESS_MCP_ALLOW_CONTROL"

    private let client: DaemonClientActor
    private let subscriptionClient: DaemonClient
    private let isToolAllowed: @Sendable (String) -> Bool
    private let disabledError: @Sendable (String) -> JSONRPCError

    init(
        client: DaemonClientActor = DaemonClientActor(),
        subscriptionClient: DaemonClient = DaemonClient(),
        isToolAllowed: @escaping @Sendable (String) -> Bool = { ToolPolicy.load().isToolAllowed($0) },
        disabledError: @escaping @Sendable (String) -> JSONRPCError = { ToolPolicy.load().disabledError(for: $0) }
    ) {
        self.client = client
        self.subscriptionClient = subscriptionClient
        self.isToolAllowed = isToolAllowed
        self.disabledError = disabledError
    }

    init(
        client: DaemonClientActor = DaemonClientActor(),
        subscriptionClient: DaemonClient = DaemonClient(),
        controlEnabled: @escaping @Sendable () -> Bool
    ) {
        self.init(
            client: client,
            subscriptionClient: subscriptionClient,
            isToolAllowed: { _ in controlEnabled() },
            disabledError: { _ in Self.controlDisabledError }
        )
    }

    // MARK: - harnessList

    func harnessList(includePanes: Bool, includeAgents: Bool) async -> (AnyCodable?, JSONRPCError?) {
        guard let response = await send(.getSnapshot) else {
            return (nil, Self.daemonUnavailableError)
        }
        guard case let .snapshot(snapshot) = response else {
            return (nil, JSONRPCError(code: -32000, message: "Unexpected response to getSnapshot"))
        }
        let workspaces: [AnyCodable] = snapshot.workspaces.map { workspace in
            .object([
                "id": .string(workspace.id.uuidString),
                "name": .string(workspace.name),
                "sessions": .array(workspace.sessions.map { session in
                    .object([
                        "id": .string(session.id.uuidString),
                        "name": .string(session.name),
                        "tabs": .array(session.tabs.map { tab in
                            tabJSON(tab, includePanes: includePanes, includeAgents: includeAgents)
                        }),
                    ])
                }),
            ])
        }
        return (toolResult(json: .object(["workspaces": .array(workspaces)])), nil)
    }

    private func tabJSON(_ tab: Tab, includePanes: Bool, includeAgents: Bool) -> AnyCodable {
        var obj: [String: AnyCodable] = [
            "id": .string(tab.id.uuidString),
            "title": .string(tab.title),
        ]
        if includePanes {
            obj["panes"] = .array(tab.rootPane.allLeaves().map { leaf in
                paneJSON(leaf, tab: tab, includeAgents: includeAgents)
            })
        }
        return .object(obj)
    }

    private func paneJSON(_ leaf: PaneLeaf, tab: Tab, includeAgents: Bool) -> AnyCodable {
        let activeSurfaceID = leaf.activeSurfaceID ?? leaf.surfaceID
        let activeSurface = leaf.surfaces.first { $0.id == activeSurfaceID }
        var obj: [String: AnyCodable] = [
            "paneId": .string(leaf.id.uuidString),
            "surfaceId": .string(activeSurfaceID.uuidString),
            "title": .string(activeSurface?.title ?? tab.title),
            "cwd": .string(activeSurface?.cwd ?? tab.cwd),
            "active": .bool(tab.activePaneID == leaf.id),
            "label": activeSurface?.label.map(AnyCodable.string) ?? .null,
        ]
        if includeAgents {
            obj["agent"] = tab.agent.map(agentJSON) ?? .null
        }
        return .object(obj)
    }

    private func agentJSON(_ agent: AgentSnapshot) -> AnyCodable {
        .object([
            "kind": .string(agent.kind.rawValue),
            "executable": .string(agent.executable),
            "pid": .int(Int(agent.pid)),
            "activity": .string(agent.activity.rawValue),
        ])
    }

    // MARK: - harnessBoard

    /// P16 PBI-BOARD-005: read-only Kanban view over `BoardModel.classify(...)`, the
    /// same shared classification used by the GUI board tab, `harness board` CLI,
    /// and `harness.board.list()` scripting — so an orchestrator agent sees the
    /// same columns/cards as a human looking at the board.
    func harnessBoard() async -> (AnyCodable?, JSONRPCError?) {
        guard let response = await send(.getSnapshot) else {
            return (nil, Self.daemonUnavailableError)
        }
        guard case let .snapshot(snapshot) = response else {
            return (nil, JSONRPCError(code: -32000, message: "Unexpected response to getSnapshot"))
        }
        let columns = BoardModel.classify(snapshot: snapshot)
        guard let data = try? JSONEncoder().encode(columns),
              let json = try? JSONDecoder().decode(AnyCodable.self, from: data)
        else {
            return (nil, JSONRPCError(code: -32000, message: "Failed to encode board"))
        }
        return (toolResult(json: .object(["columns": json])), nil)
    }

    // MARK: - openDiffReview

    func openDiffReview(_ args: [String: AnyCodable]) async -> (AnyCodable?, JSONRPCError?) {
        let repoPath: String?
        if case let .string(p) = args["repoPath"] { repoPath = p } else { repoPath = nil }
        return await okResponse(for: .openGitPanel(repoPath: repoPath), expected: "openGitPanel")
    }

    // MARK: - readPaneOutput

    func readPaneOutput(
        surfaceId: String,
        lines: Int?,
        escapeSequences: Bool,
        joinWrapped: Bool
    ) async -> (AnyCodable?, JSONRPCError?) {
        let lineCount = min(max(lines ?? Self.defaultLines, 1), Self.maxLines)
        guard let response = await send(.capturePaneRange(
            surfaceID: surfaceId,
            start: -lineCount,
            end: nil,
            escapeSequences: escapeSequences,
            joinWrapped: joinWrapped
        )) else {
            return (nil, Self.daemonUnavailableError)
        }
        switch response {
        case let .text(text):
            return (toolResult(json: .object(["text": .string(text)])), nil)
        case let .error(message):
            return (nil, JSONRPCError(code: -32000, message: message))
        default:
            return (nil, JSONRPCError(code: -32000, message: "Unexpected response to capturePaneRange"))
        }
    }

    // MARK: - getBlock (P34 F3)

    /// `harnessGetLastBlock`/`harnessGetBlock`: a command's exact text, output, and exit code —
    /// reconstructed from the pane's retained scrollback (works even if no GUI window has that
    /// pane open). Nil `blockId` = the most recently finished command. Requires the pane's shell
    /// to emit OSC 133 `C` (zsh/fish, not bash yet — see `ShellIntegration.swift`).
    func getBlock(surfaceId: String, blockId: Int?) async -> (AnyCodable?, JSONRPCError?) {
        guard let response = await send(.getBlock(surfaceID: surfaceId, blockID: blockId)) else {
            return (nil, Self.daemonUnavailableError)
        }
        switch response {
        case let .blockInfo(.some(block)):
            let formatter = ISO8601DateFormatter()
            var fields: [String: AnyCodable] = [
                "id": .int(block.id),
                "command": .string(block.command),
                "output": .string(block.output),
                "startedAt": .string(formatter.string(from: block.startedAt)),
            ]
            fields["exitCode"] = block.exitCode.map { .int($0) } ?? .null
            fields["finishedAt"] = block.finishedAt.map { .string(formatter.string(from: $0)) } ?? .null
            return (toolResult(json: .object(fields)), nil)
        case .blockInfo(.none):
            return (nil, JSONRPCError(code: -32000, message: blockId == nil
                ? "No finished command block yet on this pane (shell must emit OSC 133 C — zsh/fish)"
                : "Block \(blockId ?? -1) not found"))
        case let .error(message):
            return (nil, JSONRPCError(code: -32000, message: message))
        default:
            return (nil, JSONRPCError(code: -32000, message: "Unexpected response to getBlock"))
        }
    }

    // MARK: - Mutating daemon tools

    func sendPaneText(surfaceId: String, text: String, bracketed _: Bool) async -> (AnyCodable?, JSONRPCError?) {
        guard isToolAllowed("sendPaneText") else { return (nil, disabledError("sendPaneText")) }
        let result = await okResponse(for: .send(surfaceID: surfaceId, text: text), expected: "send")
        if result.1 == nil { await notifyMCPActivity(surfaceId: surfaceId, tool: "sendPaneText") }
        return result
    }

    func sendPaneKeys(surfaceId: String, keys: [String]) async -> (AnyCodable?, JSONRPCError?) {
        guard isToolAllowed("sendPaneKeys") else { return (nil, disabledError("sendPaneKeys")) }
        let result = await okResponse(for: .sendKeys(surfaceID: surfaceId, keys: keys), expected: "sendKeys")
        if result.1 == nil { await notifyMCPActivity(surfaceId: surfaceId, tool: "sendPaneKeys") }
        return result
    }

    /// Sets/clears a pane's durable purpose label — see `IPCRequest.setPaneLabel`.
    /// `label: nil` (or empty string) clears it.
    func setPaneLabel(surfaceId: String, label: String?) async -> (AnyCodable?, JSONRPCError?) {
        guard isToolAllowed("setPaneLabel") else { return (nil, disabledError("setPaneLabel")) }
        let cleaned = label?.isEmpty == true ? nil : label
        let result = await okResponse(for: .setPaneLabel(surfaceID: surfaceId, label: cleaned), expected: "setPaneLabel")
        if result.1 == nil { await notifyMCPActivity(surfaceId: surfaceId, tool: "setPaneLabel") }
        return result
    }

    private func notifyMCPActivity(surfaceId: String, tool: String) async {
        _ = await send(.notifyMCPActivity(surfaceID: surfaceId, toolName: tool))
    }

    func spawnSession(
        workspaceId: String,
        cwd: String?,
        name: String?,
        shell: String?,
        label: String? = nil
    ) async -> (AnyCodable?, JSONRPCError?) {
        guard isToolAllowed("spawnSession") else { return (nil, disabledError("spawnSession")) }
        guard let workspaceID = UUID(uuidString: workspaceId) else {
            return (nil, JSONRPCError(code: -32602, message: "Invalid 'workspaceId' UUID"))
        }
        guard let response = await send(.newSession(workspaceID: workspaceID, cwd: cwd, name: name, shell: shell)) else {
            return (nil, Self.daemonUnavailableError)
        }
        switch response {
        case let .sessionID(sessionID):
            await labelPrimarySurface(ofSessionID: sessionID, label: label)
            return (toolResult(json: .object(["sessionId": .string(sessionID.uuidString)])), nil)
        case let .error(message):
            return (nil, JSONRPCError(code: -32000, message: message))
        default:
            return (nil, JSONRPCError(code: -32000, message: "Unexpected response to newSession"))
        }
    }

    func splitPane(
        tabId: String,
        paneId: String,
        direction: String,
        shell: String?,
        label: String? = nil
    ) async -> (AnyCodable?, JSONRPCError?) {
        guard isToolAllowed("splitPane") else { return (nil, disabledError("splitPane")) }
        guard let tabID = UUID(uuidString: tabId) else {
            return (nil, JSONRPCError(code: -32602, message: "Invalid 'tabId' UUID"))
        }
        guard let paneID = UUID(uuidString: paneId) else {
            return (nil, JSONRPCError(code: -32602, message: "Invalid 'paneId' UUID"))
        }
        guard let splitDirection = CommandIPCTranslator.layoutDirection(forPaneDirection: direction) else {
            return (nil, JSONRPCError(code: -32602, message: "Invalid 'direction' parameter"))
        }
        guard let response = await send(.newSplit(tabID: tabID, paneID: paneID, direction: splitDirection, shell: shell)) else {
            return (nil, Self.daemonUnavailableError)
        }
        switch response {
        case let .paneID(newPaneID):
            await labelPaneSurface(tabID: tabID, paneID: newPaneID, label: label)
            return (toolResult(json: .object(["paneId": .string(newPaneID.uuidString)])), nil)
        case let .error(message):
            return (nil, JSONRPCError(code: -32000, message: message))
        default:
            return (nil, JSONRPCError(code: -32000, message: "Unexpected response to newSplit"))
        }
    }

    /// Labels a newly created pane in the same tool call that created it, so the calling agent
    /// doesn't need a follow-up harnessList round-trip to resolve a surfaceId first. No-op when
    /// `label` is nil/empty, or when the surface can't be resolved (best-effort — the pane was
    /// already created successfully either way).
    private func labelPrimarySurface(ofSessionID sessionID: UUID, label: String?) async {
        guard let label, !label.isEmpty,
              case let .snapshot(snap)? = await send(.getSnapshot),
              let surfaceID = snap.workspaces.flatMap(\.sessions).first(where: { $0.id == sessionID })?
                  .tabs.first?.rootPane.surfaceID
        else { return }
        _ = await send(.setPaneLabel(surfaceID: surfaceID.uuidString, label: label))
    }

    private func labelPaneSurface(tabID: UUID, paneID: UUID, label: String?) async {
        guard let label, !label.isEmpty,
              case let .snapshot(snap)? = await send(.getSnapshot),
              let tab = snap.workspaces.flatMap(\.sessions).flatMap(\.tabs).first(where: { $0.id == tabID }),
              let surfaceID = tab.rootPane.allLeaves().first(where: { $0.id == paneID })?.surfaceID
        else { return }
        _ = await send(.setPaneLabel(surfaceID: surfaceID.uuidString, label: label))
    }

    func closePane(paneId: String) async -> (AnyCodable?, JSONRPCError?) {
        guard isToolAllowed("closePane") else { return (nil, disabledError("closePane")) }
        guard let paneID = UUID(uuidString: paneId) else {
            return (nil, JSONRPCError(code: -32602, message: "Invalid 'paneId' UUID"))
        }
        return await okResponse(for: .killPane(paneID: paneID), expected: "killPane")
    }

    /// Spawn a new session and immediately launch an AI agent CLI (claude, codex, kiro, gemini, cursor).
    func harnessSpawnAgent(
        agent: String,
        workspaceId: String?,
        cwd: String?
    ) async -> (AnyCodable?, JSONRPCError?) {
        guard isToolAllowed("harnessSpawnAgent") else { return (nil, disabledError("harnessSpawnAgent")) }

        // Resolve workspace
        let resolvedWorkspaceId: UUID
        if let wid = workspaceId, let uuid = UUID(uuidString: wid) {
            resolvedWorkspaceId = uuid
        } else {
            guard let snapResp = await send(.getSnapshot),
                  case let .snapshot(snap) = snapResp,
                  let first = snap.workspaces.first
            else { return (nil, Self.daemonUnavailableError) }
            resolvedWorkspaceId = first.id
        }

        // Map agent name → CLI launch command
        let agentLabel: String
        let agentCommand: String
        switch agent.lowercased() {
        case "claude", "claude-code":
            agentLabel = "Claude"; agentCommand = "claude\n"
        case "codex":
            agentLabel = "Codex"; agentCommand = "codex\n"
        case "kiro":
            agentLabel = "Kiro"; agentCommand = "kiro\n"
        case "gemini":
            agentLabel = "Gemini"; agentCommand = "gemini\n"
        case "cursor":
            agentLabel = "Cursor"
            agentCommand = cwd.map { "cursor \($0)\n" } ?? "cursor .\n"
        default:
            return (nil, JSONRPCError(code: -32602,
                message: "Unknown agent '\(agent)'. Valid values: claude, codex, kiro, gemini, cursor"))
        }

        // Spawn the session
        guard let spawnResp = await send(.newSession(
            workspaceID: resolvedWorkspaceId, cwd: cwd, name: "\(agentLabel)", shell: nil
        )) else { return (nil, Self.daemonUnavailableError) }

        guard case let .sessionID(sessionID) = spawnResp else {
            if case let .error(msg) = spawnResp {
                return (nil, JSONRPCError(code: -32000, message: msg))
            }
            return (nil, JSONRPCError(code: -32000, message: "Unexpected response to newSession"))
        }

        // Poll snapshot until the shell is ready (up to ~2 s)
        var surfaceIDString: String?
        for attempt in 0..<6 {
            if attempt > 0 {
                try? await Task.sleep(nanoseconds: 350_000_000)
            }
            guard let snapResp2 = await send(.getSnapshot),
                  case let .snapshot(snap2) = snapResp2,
                  let ws = snap2.workspaces.first(where: { $0.id == resolvedWorkspaceId }),
                  let session = ws.sessions.first(where: { $0.id == sessionID }),
                  let leaf = session.tabs.first?.rootPane.allLeaves().first
            else { continue }
            surfaceIDString = (leaf.activeSurfaceID ?? leaf.surfaceID).uuidString
            break
        }

        guard let sid = surfaceIDString else {
            return (nil, JSONRPCError(code: -32000, message: "Session spawned but surface not ready in time"))
        }

        // Send the agent launch command
        _ = await send(.send(surfaceID: sid, text: agentCommand))
        await notifyMCPActivity(surfaceId: sid, tool: "harnessSpawnAgent")

        return (toolResult(json: .object([
            "sessionId": .string(sessionID.uuidString),
            "surfaceId": .string(sid),
            "agent": .string(agent),
            "launched": .string(agentCommand.trimmingCharacters(in: .whitespacesAndNewlines)),
        ])), nil)
    }

    // MARK: - waitForPaneOutput

    func waitForPaneOutput(
        surfaceId: String,
        pattern: String,
        timeoutMs: Int?,
        fromNow: Bool
    ) async -> (AnyCodable?, JSONRPCError?) {
        let timeout = max(timeoutMs ?? 30_000, 1)
        let waiter = PaneOutputWaiter(pattern: pattern, maxTailCharacters: Self.maxWaitTailCharacters)
        let subscription: DaemonSubscription
        do {
            // Gap-free attach: subscribe first (buffering live frames), then replay scrollback and
            // flush the buffer deduped against the replay boundary. This avoids the race where a
            // separate subscribe-then-replay sequence can miss or duplicate output written between
            // the two calls.
            subscription = try subscriptionClient.attachReplayingSurfaceOutput(
                surfaceID: surfaceId,
                label: "kouen-mcp waitForPaneOutput",
                onReplay: { text in
                    guard !fromNow else { return }
                    waiter.append(text, sequence: nil)
                },
                onData: { data, sequence in
                    let text = String(data: data, encoding: .utf8) ?? String(decoding: data, as: UTF8.self)
                    waiter.append(text, sequence: sequence)
                },
                onEnd: {
                    waiter.finish(timedOut: true)
                }
            )
        } catch {
            return (nil, Self.daemonUnavailableError)
        }
        defer { subscription.cancel() }

        let result = await withTaskGroup(of: PaneOutputWaitResult.self, returning: PaneOutputWaitResult.self) { group in
            group.addTask { await waiter.result() }
            group.addTask {
                try? await Task.sleep(nanoseconds: UInt64(timeout) * 1_000_000)
                return waiter.finish(timedOut: true)
            }
            let first = await group.next() ?? waiter.finish(timedOut: true)
            group.cancelAll()
            return first
        }
        return (toolResult(json: .object([
            "timedOut": .bool(result.timedOut),
            "matched": .bool(result.matched),
            "tail": .string(result.tail),
            "sequence": result.sequence.map { .int(Int($0)) } ?? .null,
        ])), nil)
    }

    // MARK: - Helpers

    private func send(_ request: IPCRequest) async -> IPCResponse? {
        try? await client.request(request)
    }

    private func okResponse(for request: IPCRequest, expected: String) async -> (AnyCodable?, JSONRPCError?) {
        guard let response = await send(request) else {
            return (nil, Self.daemonUnavailableError)
        }
        switch response {
        case .ok:
            return (toolResult(json: .object(["ok": .bool(true)])), nil)
        case let .error(message):
            return (nil, JSONRPCError(code: -32000, message: message))
        default:
            return (nil, JSONRPCError(code: -32000, message: "Unexpected response to \(expected)"))
        }
    }

    private static let daemonUnavailableError = JSONRPCError(
        code: -32000,
        message: "Harness daemon is not running"
    )

    static let controlDisabledError = JSONRPCError(
        code: -32000,
        message: "Harness MCP control tools are disabled; set HARNESS_MCP_ALLOW_CONTROL=1 to enable"
    )

    static func isControlEnabled(
        environment: [String: String] = ProcessInfo.processInfo.environment
    ) -> Bool {
        environment[controlGateVariable] == "1"
    }

    func getActiveCWD() async -> String? {
        guard let response = await send(.getSnapshot),
              case let .snapshot(snapshot) = response
        else {
            return nil
        }
        return WorkbenchContextResolver.resolve(snapshot: snapshot)?.cwd
    }

    private func toolResult(json value: AnyCodable) -> AnyCodable {
        let data = try? JSONEncoder().encode(value)
        let text = data.flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
        return .object([
            "content": .array([.object([
                "type": .string("text"),
                "text": .string(text),
            ])]),
        ])
    }
}

private struct PaneOutputWaitResult: Sendable {
    var timedOut: Bool
    var matched: Bool
    var tail: String
    var sequence: UInt64?
}

private final class PaneOutputWaiter: @unchecked Sendable {
    private let lock = NSLock()
    private let pattern: String
    private let maxTailCharacters: Int
    private var continuation: CheckedContinuation<PaneOutputWaitResult, Never>?
    private var completed = false
    private var matched = false
    private var tail = ""
    private var sequence: UInt64?

    init(pattern: String, maxTailCharacters: Int) {
        self.pattern = pattern
        self.maxTailCharacters = maxTailCharacters
    }

    func append(_ text: String, sequence: UInt64?) {
        lock.lock()
        guard !completed else {
            lock.unlock()
            return
        }
        tail += text
        if tail.count > maxTailCharacters {
            tail = String(tail.suffix(maxTailCharacters))
        }
        if let sequence {
            self.sequence = sequence
        }
        if tail.contains(pattern) {
            matched = true
            completed = true
            let result = currentResult(timedOut: false)
            let continuation = self.continuation
            self.continuation = nil
            lock.unlock()
            continuation?.resume(returning: result)
            return
        }
        lock.unlock()
    }

    func result() async -> PaneOutputWaitResult {
        await withCheckedContinuation { continuation in
            lock.lock()
            if completed {
                let result = currentResult(timedOut: !matched)
                lock.unlock()
                continuation.resume(returning: result)
            } else {
                self.continuation = continuation
                lock.unlock()
            }
        }
    }

    @discardableResult
    func finish(timedOut: Bool) -> PaneOutputWaitResult {
        lock.lock()
        if completed {
            let result = currentResult(timedOut: timedOut && !matched)
            lock.unlock()
            return result
        }
        completed = true
        let result = currentResult(timedOut: timedOut)
        let continuation = self.continuation
        self.continuation = nil
        lock.unlock()
        continuation?.resume(returning: result)
        return result
    }

    private func currentResult(timedOut: Bool) -> PaneOutputWaitResult {
        PaneOutputWaitResult(
            timedOut: timedOut && !matched,
            matched: matched,
            tail: tail,
            sequence: sequence
        )
    }
}
