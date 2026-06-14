#if HARNESS_ACP
import Foundation

/// Represents a single message in the agent chat conversation.
public struct ACPChatMessage: Identifiable, Sendable {
    public enum Role: Sendable { case user, assistant, thought, toolCall }

    public let id: UUID
    public let role: Role
    public var text: String
    public let timestamp: Date
    public var toolCallId: String?
    public var toolKind: String?
    public var toolStatus: String?

    public init(role: Role, text: String, toolCallId: String? = nil, toolKind: String? = nil) {
        self.id = UUID()
        self.role = role
        self.text = text
        self.timestamp = Date()
        self.toolCallId = toolCallId
        self.toolKind = toolKind
    }
}

/// Observable session state for the agent chat panel.
@MainActor
public final class ACPSession: @unchecked Sendable {
    public enum Status: Sendable {
        case disconnected
        case connecting
        case ready
        case streaming
        case waitingForApproval(ACPPermissionRequest)
        case error(String)
    }

    public private(set) var messages: [ACPChatMessage] = []
    public private(set) var status: Status = .disconnected
    public var onUpdate: (() -> Void)?

    private let client: ACPClient
    private var agentConfig: AgentConfig?
    private var streamingBuffer = ""
    private var thoughtBuffer = ""

    public init(client: ACPClient) {
        self.client = client
    }

    public var isStreaming: Bool {
        if case .streaming = status { return true }
        return false
    }

    // MARK: - Lifecycle

    public func connect(config: AgentConfig, cwd: String) async {
        agentConfig = config
        status = .connecting
        onUpdate?()
        do {
            await client.setDelegate(self)
            try await client.start(config: config, cwd: cwd)
            status = .ready
        } catch {
            status = .error(error.localizedDescription)
        }
        onUpdate?()
    }

    public func disconnect() async {
        await client.stop()
        status = .disconnected
        onUpdate?()
    }

    // MARK: - User Actions

    public func sendMessage(_ text: String) async {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        messages.append(ACPChatMessage(role: .user, text: trimmed))
        streamingBuffer = ""
        thoughtBuffer = ""
        status = .streaming
        onUpdate?()

        do {
            try await client.sendPrompt(text: trimmed)
        } catch {
            status = .error(error.localizedDescription)
            onUpdate?()
        }
    }

    public func cancelPrompt() async {
        try? await client.cancel()
    }

    public func respondToPermission(optionId: String) async {
        guard case let .waitingForApproval(req) = status else { return }
        await client.respondToPermission(requestId: req.id, optionId: optionId)
        status = .streaming
        onUpdate?()
    }

    public func rejectPermission() async {
        guard case let .waitingForApproval(req) = status else { return }
        // Find reject_once option, or just cancel
        if let rejectOpt = req.options.first(where: { $0.kind == "reject_once" }) {
            await client.respondToPermission(requestId: req.id, optionId: rejectOpt.id)
        } else {
            await client.cancelPermission(requestId: req.id)
        }
        status = .streaming
        onUpdate?()
    }

    // MARK: - Helpers

    private func flushStreamingBuffer() {
        if !streamingBuffer.isEmpty {
            messages.append(ACPChatMessage(role: .assistant, text: streamingBuffer))
            streamingBuffer = ""
        }
    }

    private func flushThoughtBuffer() {
        if !thoughtBuffer.isEmpty {
            messages.append(ACPChatMessage(role: .thought, text: thoughtBuffer))
            thoughtBuffer = ""
        }
    }
}

// MARK: - ACPClientDelegate

extension ACPSession: ACPClientDelegate {
    nonisolated public func acpClient(_ client: ACPClient, didReceiveTextChunk text: String) {
        Task { @MainActor in
            self.streamingBuffer += text
            // Update last assistant message in-place for streaming display
            if let lastIdx = self.messages.indices.last, self.messages[lastIdx].role == .assistant {
                self.messages[lastIdx].text = self.streamingBuffer
            } else {
                self.messages.append(ACPChatMessage(role: .assistant, text: self.streamingBuffer))
            }
            self.onUpdate?()
        }
    }

    nonisolated public func acpClient(_ client: ACPClient, didReceiveThoughtChunk text: String) {
        Task { @MainActor in
            self.thoughtBuffer += text
            self.onUpdate?()
        }
    }

    nonisolated public func acpClient(_ client: ACPClient, didReceiveToolCall toolCall: ACPToolCall) {
        Task { @MainActor in
            self.flushStreamingBuffer()
            self.messages.append(ACPChatMessage(
                role: .toolCall,
                text: toolCall.title,
                toolCallId: toolCall.toolCallId,
                toolKind: toolCall.kind
            ))
            self.onUpdate?()
        }
    }

    nonisolated public func acpClient(_ client: ACPClient, didReceiveToolCallUpdate update: ACPToolCallUpdate) {
        Task { @MainActor in
            if let idx = self.messages.lastIndex(where: { $0.toolCallId == update.toolCallId }) {
                if let title = update.title { self.messages[idx].text = title }
                if let status = update.status { self.messages[idx].toolStatus = status }
            }
            self.onUpdate?()
        }
    }

    nonisolated public func acpClient(_ client: ACPClient, didRequestPermission request: ACPPermissionRequest) {
        Task { @MainActor in
            self.status = .waitingForApproval(request)
            self.onUpdate?()
        }
    }

    nonisolated public func acpClient(_ client: ACPClient, didRequestTerminal command: String, args: [String], terminalId: String) {
        Task { @MainActor in
            self.messages.append(ACPChatMessage(
                role: .toolCall,
                text: "$ \(command) \(args.joined(separator: " "))",
                toolKind: "execute"
            ))
            self.onUpdate?()
        }
    }

    nonisolated public func acpClient(_ client: ACPClient, didFinishPrompt stopReason: String) {
        Task { @MainActor in
            self.flushThoughtBuffer()
            // streamingBuffer is already displayed in messages via in-place update
            self.streamingBuffer = ""
            self.status = .ready
            self.onUpdate?()
        }
    }
}

// MARK: - Helper to set delegate on actor

extension ACPClient {
    public func setDelegate(_ delegate: (any ACPClientDelegate)?) async {
        self.delegate = delegate
    }
}
#endif
