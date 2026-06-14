#if HARNESS_ACP
import Foundation

/// ACP protocol v1 client — manages agent subprocess lifecycle and JSON-RPC 2.0 communication.
public actor ACPClient {
    public enum State: Sendable {
        case idle
        case initializing
        case ready(sessionId: String)
        case prompting
        case error(String)
    }

    public enum ClientError: Error, Sendable {
        case notReady
        case noSession
        case protocolError(String)
        case timeout
    }

    /// Delegate receives session update notifications on the main actor.
    public weak var delegate: (any ACPClientDelegate)?

    private var process: ACPProcess?
    private var config: AgentConfig?
    private var state: State = .idle
    private var nextRequestId: Int = 1
    private var pendingRequests: [Int: CheckedContinuation<AnyCodable?, Error>] = [:]
    private var messageTask: Task<Void, Never>?
    private var sessionId: String?

    public init() {}

    // MARK: - Lifecycle

    public func start(config: AgentConfig, cwd: String) async throws {
        self.config = config
        state = .initializing

        let proc = ACPProcess()
        process = proc
        try await proc.launch(config: config)

        startMessageLoop(proc)

        // Initialize handshake
        let initParams: AnyCodable = .object([
            "protocolVersion": .int(1),
            "clientInfo": .object([
                "name": .string("harness-terminal"),
                "version": .string("1.0.0"),
            ]),
            "clientCapabilities": .object([
                "fs": .object([
                    "readTextFile": .bool(true),
                    "writeTextFile": .bool(true),
                ]),
                "terminal": .bool(true),
            ]),
        ])
        _ = try await sendRequest(method: "initialize", params: initParams)

        // Create session
        let sessionParams: AnyCodable = .object([
            "cwd": .string(cwd),
            "mcpServers": .array([]),
        ])
        let sessionResult = try await sendRequest(method: "session/new", params: sessionParams)
        if case let .object(dict) = sessionResult, case let .string(sid) = dict["sessionId"] {
            sessionId = sid
            state = .ready(sessionId: sid)
        } else {
            throw ClientError.protocolError("session/new did not return sessionId")
        }
    }

    public func stop() async {
        messageTask?.cancel()
        messageTask = nil
        await process?.terminate()
        process = nil
        state = .idle
        sessionId = nil
        // Fail all pending requests
        for (_, cont) in pendingRequests {
            cont.resume(throwing: ClientError.notReady)
        }
        pendingRequests.removeAll()
    }

    public var currentState: State { state }

    // MARK: - Prompt

    public func sendPrompt(text: String) async throws {
        guard let sid = sessionId else { throw ClientError.noSession }
        state = .prompting
        let params: AnyCodable = .object([
            "sessionId": .string(sid),
            "prompt": .array([
                .object([
                    "type": .string("text"),
                    "text": .string(text),
                ]),
            ]),
        ])
        let result = try await sendRequest(method: "session/prompt", params: params)
        // PromptResponse has stopReason
        if case let .object(dict) = result, case let .string(reason) = dict["stopReason"] {
            await delegate?.acpClient(self, didFinishPrompt: reason)
        }
        state = .ready(sessionId: sid)
    }

    public func cancel() async throws {
        guard let sid = sessionId else { return }
        let params: AnyCodable = .object([
            "sessionId": .string(sid),
        ])
        let msg = ACPMessage.notification(method: "session/cancel", params: params)
        try await process?.send(msg)
    }

    // MARK: - JSON-RPC

    private func sendRequest(method: String, params: AnyCodable?) async throws -> AnyCodable? {
        guard let process else { throw ClientError.notReady }
        let id = nextRequestId
        nextRequestId += 1
        let msg = ACPMessage.request(id: .int(id), method: method, params: params)
        try await process.send(msg)

        return try await withCheckedThrowingContinuation { continuation in
            pendingRequests[id] = continuation
        }
    }

    private func startMessageLoop(_ proc: ACPProcess) {
        messageTask = Task { [weak self] in
            for await message in proc.incomingMessages {
                guard let self else { break }
                await self.handleMessage(message)
            }
        }
    }

    private func handleMessage(_ message: ACPMessage) async {
        switch message {
        case let .response(id, result, error):
            if case let .int(intId) = id, let cont = pendingRequests.removeValue(forKey: intId) {
                if let error {
                    cont.resume(throwing: ClientError.protocolError("\(error.code): \(error.message)"))
                } else {
                    cont.resume(returning: result)
                }
            }

        case let .notification(method, params):
            guard method == "session/update" else { return }
            guard case let .object(dict) = params else { return }
            // SessionNotification: { sessionId, update: { sessionUpdate: "...", ... } }
            let updateType: String
            if case let .object(updateDict) = dict["update"],
               case let .string(ut) = updateDict["sessionUpdate"] {
                updateType = ut
            } else if case let .string(ut) = dict["sessionUpdate"] {
                updateType = ut
            } else {
                return
            }
            await handleSessionUpdate(updateType: updateType, params: params)

        case let .request(id, method, params):
            // Agent requesting something from client
            await handleAgentRequest(id: id, method: method, params: params)
        }
    }

    private func handleSessionUpdate(updateType: String, params: AnyCodable?) async {
        guard case let .object(dict) = params else { return }
        let update = dict["update"] ?? params!

        switch updateType {
        case "agent_message_chunk":
            if case let .object(chunk) = update,
               case let .object(content) = chunk["content"],
               case let .string(text) = content["text"] {
                await delegate?.acpClient(self, didReceiveTextChunk: text)
            }
        case "agent_thought_chunk":
            if case let .object(chunk) = update,
               case let .object(content) = chunk["content"],
               case let .string(text) = content["text"] {
                await delegate?.acpClient(self, didReceiveThoughtChunk: text)
            }
        case "tool_call":
            if case let .object(tc) = update {
                let toolCallId = tc["toolCallId"].flatMap { if case let .string(s) = $0 { return s } else { return nil } } ?? ""
                let title = tc["title"].flatMap { if case let .string(s) = $0 { return s } else { return nil } } ?? ""
                let kind = tc["kind"].flatMap { if case let .string(s) = $0 { return s } else { return nil } } ?? "other"
                let status = tc["status"].flatMap { if case let .string(s) = $0 { return s } else { return nil } } ?? "pending"
                await delegate?.acpClient(self, didReceiveToolCall: ACPToolCall(
                    toolCallId: toolCallId, title: title, kind: kind, status: status, content: tc["content"]
                ))
            }
        case "tool_call_update":
            if case let .object(tc) = update {
                let toolCallId = tc["toolCallId"].flatMap { if case let .string(s) = $0 { return s } else { return nil } } ?? ""
                let status = tc["status"].flatMap { if case let .string(s) = $0 { return s } else { return nil } }
                let title = tc["title"].flatMap { if case let .string(s) = $0 { return s } else { return nil } }
                await delegate?.acpClient(self, didReceiveToolCallUpdate: ACPToolCallUpdate(
                    toolCallId: toolCallId, title: title, status: status, content: tc["content"]
                ))
            }
        default:
            break
        }
    }

    private func handleAgentRequest(id: JSONRPCId, method: String, params: AnyCodable?) async {
        switch method {
        case "fs/read_text_file":
            guard case let .object(dict) = params,
                  case let .string(path) = dict["path"] else {
                await sendErrorResponse(id: id, code: -32602, message: "Invalid params")
                return
            }
            do {
                let content = try String(contentsOfFile: path, encoding: .utf8)
                let result: AnyCodable = .object(["content": .string(content)])
                try await process?.send(.response(id: id, result: result, error: nil))
            } catch {
                await sendErrorResponse(id: id, code: -32002, message: "File not found: \(path)")
            }

        case "fs/write_text_file":
            guard case let .object(dict) = params,
                  case let .string(path) = dict["path"],
                  case let .string(content) = dict["content"] else {
                await sendErrorResponse(id: id, code: -32602, message: "Invalid params")
                return
            }
            do {
                try content.write(toFile: path, atomically: true, encoding: .utf8)
                try await process?.send(.response(id: id, result: .object([:]), error: nil))
            } catch {
                await sendErrorResponse(id: id, code: -32603, message: "Write failed: \(error.localizedDescription)")
            }

        case "session/request_permission":
            guard case let .object(dict) = params else {
                await sendErrorResponse(id: id, code: -32602, message: "Invalid params")
                return
            }
            let permRequest = ACPPermissionRequest(id: id, params: dict)
            await delegate?.acpClient(self, didRequestPermission: permRequest)

        case "terminal/create":
            guard case let .object(dict) = params,
                  case let .string(command) = dict["command"] else {
                await sendErrorResponse(id: id, code: -32602, message: "Invalid params")
                return
            }
            let args: [String] = {
                if case let .array(arr) = dict["args"] {
                    return arr.compactMap { if case let .string(s) = $0 { return s } else { return nil } }
                }
                return []
            }()
            let terminalId = UUID().uuidString
            await delegate?.acpClient(self, didRequestTerminal: command, args: args, terminalId: terminalId)
            let result: AnyCodable = .object(["terminalId": .string(terminalId)])
            try? await process?.send(.response(id: id, result: result, error: nil))

        default:
            await sendErrorResponse(id: id, code: -32601, message: "Method not found: \(method)")
        }
    }

    // MARK: - Permission Response

    public func respondToPermission(requestId: JSONRPCId, optionId: String) async {
        let result: AnyCodable = .object([
            "outcome": .object([
                "outcome": .string("selected"),
                "optionId": .string(optionId),
            ]),
        ])
        try? await process?.send(.response(id: requestId, result: result, error: nil))
    }

    public func cancelPermission(requestId: JSONRPCId) async {
        let result: AnyCodable = .object([
            "outcome": .object([
                "outcome": .string("cancelled"),
            ]),
        ])
        try? await process?.send(.response(id: requestId, result: result, error: nil))
    }

    private func sendErrorResponse(id: JSONRPCId, code: Int, message: String) async {
        try? await process?.send(.response(id: id, result: nil, error: JSONRPCError(code: code, message: message)))
    }
}

// MARK: - Protocol Types

public struct ACPToolCall: Sendable {
    public let toolCallId: String
    public let title: String
    public let kind: String
    public let status: String
    public let content: AnyCodable?
}

public struct ACPToolCallUpdate: Sendable {
    public let toolCallId: String
    public let title: String?
    public let status: String?
    public let content: AnyCodable?
}

public struct ACPPermissionRequest: Sendable {
    public let id: JSONRPCId
    public let params: [String: AnyCodable]

    public var toolCallTitle: String {
        if case let .object(tc) = params["toolCall"],
           case let .string(t) = tc["title"] { return t }
        return "Unknown"
    }

    public var toolCallKind: String {
        if case let .object(tc) = params["toolCall"],
           case let .string(k) = tc["kind"] { return k }
        return "other"
    }

    public var options: [(id: String, name: String, kind: String)] {
        guard case let .array(opts) = params["options"] else { return [] }
        return opts.compactMap { opt in
            guard case let .object(o) = opt,
                  case let .string(oid) = o["optionId"],
                  case let .string(name) = o["name"],
                  case let .string(kind) = o["kind"] else { return nil }
            return (id: oid, name: name, kind: kind)
        }
    }

    /// Diff content from the tool call (for file edits)
    public var diff: (path: String, oldText: String?, newText: String)? {
        guard case let .object(tc) = params["toolCall"],
              case let .array(contents) = tc["content"] else { return nil }
        for item in contents {
            guard case let .object(c) = item,
                  case let .string(type) = c["type"], type == "diff",
                  case let .string(path) = c["path"],
                  case let .string(newText) = c["newText"] else { continue }
            let oldText: String? = {
                if case let .string(s) = c["oldText"] { return s }
                return nil
            }()
            return (path: path, oldText: oldText, newText: newText)
        }
        return nil
    }
}

// MARK: - Delegate

@MainActor
public protocol ACPClientDelegate: AnyObject, Sendable {
    func acpClient(_ client: ACPClient, didReceiveTextChunk text: String)
    func acpClient(_ client: ACPClient, didReceiveThoughtChunk text: String)
    func acpClient(_ client: ACPClient, didReceiveToolCall toolCall: ACPToolCall)
    func acpClient(_ client: ACPClient, didReceiveToolCallUpdate update: ACPToolCallUpdate)
    func acpClient(_ client: ACPClient, didRequestPermission request: ACPPermissionRequest)
    func acpClient(_ client: ACPClient, didRequestTerminal command: String, args: [String], terminalId: String)
    func acpClient(_ client: ACPClient, didFinishPrompt stopReason: String)
}
#endif
