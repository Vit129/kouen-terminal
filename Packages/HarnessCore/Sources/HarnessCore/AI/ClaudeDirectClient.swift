import Foundation

/// Lightweight client for the Anthropic Messages API with Server-Sent Events streaming.
/// Used by the Chat sidebar and inline AI completion. Requires `claudeAPIKey` in
/// `HarnessSettings` or the `ANTHROPIC_API_KEY` environment variable.
public actor ClaudeDirectClient {
    private static let endpoint = URL(string: "https://api.anthropic.com/v1/messages")!
    private static let anthropicVersion = "2023-06-01"
    public static let defaultModel = "claude-sonnet-4-6"

    public struct Message: Sendable {
        public let role: String
        public let content: String
        public init(role: String, content: String) {
            self.role = role
            self.content = content
        }
    }

    public enum StreamEvent: Sendable {
        case text(String)
        case done
        case error(String)
    }

    private let apiKey: String
    private let model: String

    public init?(settings: HarnessSettings, model: String = ClaudeDirectClient.defaultModel) {
        let key = settings.claudeAPIKey?.trimmingCharacters(in: .whitespacesAndNewlines)
            ?? ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"]?.trimmingCharacters(in: .whitespacesAndNewlines)
            ?? ""
        guard !key.isEmpty else { return nil }
        self.apiKey = key
        self.model = model
    }

    /// Stream a response to `messages`, calling `onEvent` for each SSE chunk.
    /// Returns when the stream is complete or errors.
    public func stream(
        messages: [Message],
        systemPrompt: String? = nil,
        maxTokens: Int = 4096,
        onEvent: @Sendable @escaping (StreamEvent) -> Void
    ) async {
        var body: [String: Any] = [
            "model": model,
            "max_tokens": maxTokens,
            "stream": true,
            "messages": messages.map { ["role": $0.role, "content": $0.content] },
        ]
        if let systemPrompt { body["system"] = systemPrompt }

        guard let bodyData = try? JSONSerialization.data(withJSONObject: body) else {
            onEvent(.error("Failed to encode request"))
            return
        }

        var request = URLRequest(url: Self.endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue(Self.anthropicVersion, forHTTPHeaderField: "anthropic-version")
        request.httpBody = bodyData

        do {
            let (asyncBytes, response) = try await URLSession.shared.bytes(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                onEvent(.error("Invalid response")); return
            }
            guard httpResponse.statusCode == 200 else {
                var errBody = ""
                for try await byte in asyncBytes { errBody.append(Character(UnicodeScalar(byte))) }
                onEvent(.error("API error \(httpResponse.statusCode): \(errBody.prefix(200))")); return
            }
            for try await line in asyncBytes.lines {
                guard line.hasPrefix("data: ") else { continue }
                let data = String(line.dropFirst(6))
                if data == "[DONE]" { onEvent(.done); return }
                guard let json = try? JSONSerialization.jsonObject(with: Data(data.utf8)) as? [String: Any] else { continue }
                // content_block_delta type carries the text chunk
                if let type = json["type"] as? String, type == "content_block_delta",
                   let delta = json["delta"] as? [String: Any],
                   let text = delta["text"] as? String {
                    onEvent(.text(text))
                }
            }
            onEvent(.done)
        } catch {
            onEvent(.error(error.localizedDescription))
        }
    }

    /// One-shot completion (non-streaming). Convenience for short prompts.
    public func complete(
        messages: [Message],
        systemPrompt: String? = nil,
        maxTokens: Int = 512
    ) async -> Result<String, String> {
        var result = ""
        var lastError: String? = nil
        await stream(messages: messages, systemPrompt: systemPrompt, maxTokens: maxTokens) { event in
            switch event {
            case .text(let chunk): result += chunk
            case .error(let msg): lastError = msg
            case .done: break
            }
        }
        if let err = lastError { return .failure(err) }
        return .success(result)
    }
}
