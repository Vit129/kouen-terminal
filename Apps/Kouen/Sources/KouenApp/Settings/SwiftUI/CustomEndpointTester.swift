import Foundation

/// "Test Connection" for a `CustomModelEndpoint`: one tiny Chat Completions request
/// (`max_tokens: 1`) so a wrong URL, key, or model ID shows up before anything depends on it.
/// The key is only ever placed in the Authorization header — never in a returned message.
enum CustomEndpointTester {
    struct Result: Equatable {
        let ok: Bool
        let message: String
    }

    /// Accepts a base URL (`https://host/v1`) or a full endpoint (`https://host/v1/chat/completions`).
    /// Returns nil for anything that would send the key unsafely: non-http(s), or plain http to a
    /// host other than localhost.
    static func chatCompletionsURL(baseURL: String) -> URL? {
        let trimmed = baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard var components = URLComponents(string: trimmed),
              let scheme = components.scheme?.lowercased(),
              let host = components.host, !host.isEmpty
        else { return nil }
        let isLocal = host == "localhost" || host == "127.0.0.1" || host == "::1"
        guard scheme == "https" || (scheme == "http" && isLocal) else { return nil }
        var path = components.path
        while path.hasSuffix("/") { path.removeLast() }
        if !path.hasSuffix("/chat/completions") { path += "/chat/completions" }
        components.path = path
        components.query = nil
        components.fragment = nil
        return components.url
    }

    static func makeRequest(baseURL: String, modelID: String, apiKey: String) -> URLRequest? {
        guard let url = chatCompletionsURL(baseURL: baseURL) else { return nil }
        var request = URLRequest(url: url, timeoutInterval: 15)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "model": modelID,
            "messages": [["role": "user", "content": "ping"]],
            "max_tokens": 1,
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        return request
    }

    static func classify(statusCode: Int, body: Data) -> Result {
        switch statusCode {
        case 200 ..< 300:
            return Result(ok: true, message: "Connected — the model replied (HTTP \(statusCode)).")
        case 401, 403:
            return Result(ok: false, message: "Rejected (HTTP \(statusCode)) — check the API key.")
        case 404:
            return Result(ok: false, message: "Not found (HTTP 404) — check the Base URL.")
        default:
            let detail = String(data: body.prefix(200), encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let suffix = detail.isEmpty ? "" : ": \(detail)"
            return Result(ok: false, message: "HTTP \(statusCode)\(suffix)")
        }
    }

    static func test(
        baseURL: String, modelID: String, apiKey: String, session: URLSession = .shared
    ) async -> Result {
        guard !modelID.trimmingCharacters(in: .whitespaces).isEmpty else {
            return Result(ok: false, message: "Enter a Model ID first.")
        }
        guard let request = makeRequest(baseURL: baseURL, modelID: modelID, apiKey: apiKey) else {
            return Result(ok: false, message: "Base URL must be https:// (http:// only for localhost).")
        }
        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                return Result(ok: false, message: "No HTTP response.")
            }
            return classify(statusCode: http.statusCode, body: data)
        } catch {
            return Result(ok: false, message: "Request failed: \(error.localizedDescription)")
        }
    }
}
