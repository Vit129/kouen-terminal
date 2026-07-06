import Foundation
import KouenCore

/// Daemon-backed MCP tools for the browser pane (P14 PBI-BROWSER-004).
struct KouenBrowserTools: Sendable {
    static let controlGateVariable = "KOUEN_MCP_ALLOW_CONTROL"

    private let client: DaemonClientActor
    private let isToolAllowed: @Sendable (String) -> Bool
    private let disabledError: @Sendable (String) -> JSONRPCError

    init(
        client: DaemonClientActor = DaemonClientActor(),
        isToolAllowed: @escaping @Sendable (String) -> Bool = { ToolPolicy.load().isToolAllowed($0) },
        disabledError: @escaping @Sendable (String) -> JSONRPCError = { ToolPolicy.load().disabledError(for: $0) }
    ) {
        self.client = client
        self.isToolAllowed = isToolAllowed
        self.disabledError = disabledError
    }

    private func send(_ request: IPCRequest, timeout: TimeInterval = 35) async -> IPCResponse? {
        try? await client.request(request, timeout: timeout)
    }

    // MARK: - kouenBrowserOpen

    func kouenBrowserOpen(urlStr: String, directionStr: String?) async -> (AnyCodable?, JSONRPCError?) {
        let toolName = "kouenBrowserOpen"
        guard isToolAllowed(toolName) else { return (nil, disabledError(toolName)) }
        guard let url = URL(string: urlStr) else {
            return (nil, JSONRPCError(code: -32602, message: "Invalid URL string: \(urlStr)"))
        }
        var direction: SplitDirection?
        if let dirStr = directionStr {
            guard let dir = CommandIPCTranslator.layoutDirection(forPaneDirection: dirStr) else {
                return (nil, JSONRPCError(code: -32602, message: "Invalid direction: \(dirStr)"))
            }
            direction = dir
        }

        guard let response = await send(.browserOpen(url: url, direction: direction)) else {
            return (nil, JSONRPCError(code: -32000, message: "Daemon unavailable"))
        }

        switch response {
        case let .browserSuccess(payload):
            if case let .open(paneID) = payload {
                return (toolResult(json: .object(["paneId": .string(paneID.uuidString)])), nil)
            }
            return (nil, JSONRPCError(code: -32000, message: "Unexpected browser open payload response"))
        case let .error(msg):
            return (nil, JSONRPCError(code: -32000, message: msg))
        default:
            return (nil, JSONRPCError(code: -32000, message: "Unexpected response from daemon"))
        }
    }

    // MARK: - kouenBrowserNavigate

    func kouenBrowserNavigate(paneIdStr: String, urlStr: String) async -> (AnyCodable?, JSONRPCError?) {
        let toolName = "kouenBrowserNavigate"
        guard isToolAllowed(toolName) else { return (nil, disabledError(toolName)) }
        guard let paneID = UUID(uuidString: paneIdStr) else {
            return (nil, JSONRPCError(code: -32602, message: "Invalid paneId UUID: \(paneIdStr)"))
        }
        guard let url = URL(string: urlStr) else {
            return (nil, JSONRPCError(code: -32602, message: "Invalid URL string: \(urlStr)"))
        }

        guard let response = await send(.browserNavigate(paneID: paneID, url: url)) else {
            return (nil, JSONRPCError(code: -32000, message: "Daemon unavailable"))
        }

        switch response {
        case let .browserSuccess(payload):
            if case .ok = payload {
                return (toolResult(json: .object(["ok": .bool(true)])), nil)
            }
            if case let .error(msg) = payload {
                return (nil, JSONRPCError(code: -32000, message: msg))
            }
            return (nil, JSONRPCError(code: -32000, message: "Unexpected payload response"))
        case let .error(msg):
            return (nil, JSONRPCError(code: -32000, message: msg))
        default:
            return (nil, JSONRPCError(code: -32000, message: "Unexpected response from daemon"))
        }
    }

    // MARK: - kouenBrowserWait

    func kouenBrowserWait(paneIdStr: String, timeoutSeconds: Double?) async -> (AnyCodable?, JSONRPCError?) {
        let toolName = "kouenBrowserWait"
        guard isToolAllowed(toolName) else { return (nil, disabledError(toolName)) }
        guard let paneID = UUID(uuidString: paneIdStr) else {
            return (nil, JSONRPCError(code: -32602, message: "Invalid paneId UUID: \(paneIdStr)"))
        }

        guard let response = await send(.browserWait(paneID: paneID, timeoutSeconds: timeoutSeconds)) else {
            return (nil, JSONRPCError(code: -32000, message: "Daemon unavailable"))
        }

        switch response {
        case let .browserSuccess(payload):
            if case .ok = payload {
                return (toolResult(json: .object(["ok": .bool(true)])), nil)
            }
            if case let .error(msg) = payload {
                return (nil, JSONRPCError(code: -32000, message: msg))
            }
            return (nil, JSONRPCError(code: -32000, message: "Unexpected payload response"))
        case let .error(msg):
            return (nil, JSONRPCError(code: -32000, message: msg))
        default:
            return (nil, JSONRPCError(code: -32000, message: "Unexpected response from daemon"))
        }
    }

    // MARK: - kouenBrowserSnapshot

    func kouenBrowserSnapshot(paneIdStr: String, interactive: Bool?) async -> (AnyCodable?, JSONRPCError?) {
        guard let paneID = UUID(uuidString: paneIdStr) else {
            return (nil, JSONRPCError(code: -32602, message: "Invalid paneId UUID: \(paneIdStr)"))
        }

        guard let response = await send(.browserSnapshot(paneID: paneID, interactive: interactive)) else {
            return (nil, JSONRPCError(code: -32000, message: "Daemon unavailable"))
        }

        switch response {
        case let .browserSuccess(payload):
            if case let .snapshot(snap) = payload {
                let elements: [AnyCodable] = snap.elements.map { el in
                    var elObj: [String: AnyCodable] = [
                        "id": .string(el.id),
                        "tag": .string(el.tag),
                        "text": .string(el.text),
                        "value": .string(el.value),
                        "placeholder": .string(el.placeholder)
                    ]
                    if let href = el.href {
                        elObj["href"] = .string(href)
                    }
                    return .object(elObj)
                }
                let resObj: [String: AnyCodable] = [
                    "url": .string(snap.url),
                    "title": .string(snap.title),
                    "text": .string(snap.text),
                    "elements": .array(elements)
                ]
                return (toolResult(json: .object(resObj)), nil)
            }
            if case let .error(msg) = payload {
                return (nil, JSONRPCError(code: -32000, message: msg))
            }
            return (nil, JSONRPCError(code: -32000, message: "Unexpected payload response"))
        case let .error(msg):
            return (nil, JSONRPCError(code: -32000, message: msg))
        default:
            return (nil, JSONRPCError(code: -32000, message: "Unexpected response from daemon"))
        }
    }

    // MARK: - kouenBrowserInteract

    func kouenBrowserInteract(paneIdStr: String, action: String, elementId: String, text: String?) async -> (AnyCodable?, JSONRPCError?) {
        let toolName = "kouenBrowserInteract"
        guard isToolAllowed(toolName) else { return (nil, disabledError(toolName)) }
        guard let paneID = UUID(uuidString: paneIdStr) else {
            return (nil, JSONRPCError(code: -32602, message: "Invalid paneId UUID: \(paneIdStr)"))
        }

        guard let response = await send(.browserInteract(paneID: paneID, action: action, elementID: elementId, text: text)) else {
            return (nil, JSONRPCError(code: -32000, message: "Daemon unavailable"))
        }

        switch response {
        case let .browserSuccess(payload):
            if case .ok = payload {
                return (toolResult(json: .object(["ok": .bool(true)])), nil)
            }
            if case let .error(msg) = payload {
                return (nil, JSONRPCError(code: -32000, message: msg))
            }
            return (nil, JSONRPCError(code: -32000, message: "Unexpected payload response"))
        case let .error(msg):
            return (nil, JSONRPCError(code: -32000, message: msg))
        default:
            return (nil, JSONRPCError(code: -32000, message: "Unexpected response from daemon"))
        }
    }

    // MARK: - kouenBrowserClose

    func kouenBrowserClose(paneIdStr: String) async -> (AnyCodable?, JSONRPCError?) {
        let toolName = "kouenBrowserClose"
        guard isToolAllowed(toolName) else { return (nil, disabledError(toolName)) }
        guard let paneID = UUID(uuidString: paneIdStr) else {
            return (nil, JSONRPCError(code: -32602, message: "Invalid paneId UUID: \(paneIdStr)"))
        }

        guard let response = await send(.browserClose(paneID: paneID)) else {
            return (nil, JSONRPCError(code: -32000, message: "Daemon unavailable"))
        }

        switch response {
        case let .browserSuccess(payload):
            if case .ok = payload {
                return (toolResult(json: .object(["ok": .bool(true)])), nil)
            }
            if case let .error(msg) = payload {
                return (nil, JSONRPCError(code: -32000, message: msg))
            }
            return (nil, JSONRPCError(code: -32000, message: "Unexpected payload response"))
        case let .error(msg):
            return (nil, JSONRPCError(code: -32000, message: msg))
        default:
            return (nil, JSONRPCError(code: -32000, message: "Unexpected response from daemon"))
        }
    }

    // MARK: - kouenBrowserScreenshot

    func kouenBrowserScreenshot(paneIdStr: String) async -> (AnyCodable?, JSONRPCError?) {
        guard let paneID = UUID(uuidString: paneIdStr) else {
            return (nil, JSONRPCError(code: -32602, message: "Invalid paneId UUID: \(paneIdStr)"))
        }
        guard let response = await send(.browserScreenshot(paneID: paneID)) else {
            return (nil, JSONRPCError(code: -32000, message: "Daemon unavailable"))
        }
        switch response {
        case let .browserSuccess(payload):
            if case let .screenshot(base64) = payload {
                return (toolResult(json: .object(["image": .string(base64)])), nil)
            }
            if case let .error(msg) = payload { return (nil, JSONRPCError(code: -32000, message: msg)) }
            return (nil, JSONRPCError(code: -32000, message: "Unexpected payload response"))
        case let .error(msg): return (nil, JSONRPCError(code: -32000, message: msg))
        default: return (nil, JSONRPCError(code: -32000, message: "Unexpected response from daemon"))
        }
    }

    // MARK: - kouenBrowserNetwork

    func kouenBrowserNetwork(paneIdStr: String) async -> (AnyCodable?, JSONRPCError?) {
        guard let paneID = UUID(uuidString: paneIdStr) else {
            return (nil, JSONRPCError(code: -32602, message: "Invalid paneId UUID: \(paneIdStr)"))
        }
        guard let response = await send(.browserNetwork(paneID: paneID)) else {
            return (nil, JSONRPCError(code: -32000, message: "Daemon unavailable"))
        }
        switch response {
        case let .browserSuccess(payload):
            if case let .network(entries) = payload {
                let items: [AnyCodable] = entries.map { e in
                    var obj: [String: AnyCodable] = [
                        "id": .string(e.id), "url": .string(e.url), "method": .string(e.method),
                    ]
                    if let s = e.status { obj["status"] = .int(s) }
                    if let d = e.duration { obj["duration"] = .double(d) }
                    if let b = e.requestBody { obj["requestBody"] = .string(b) }
                    if let b = e.responseBody { obj["responseBody"] = .string(b) }
                    return .object(obj)
                }
                return (toolResult(json: .object(["requests": .array(items)])), nil)
            }
            if case let .error(msg) = payload { return (nil, JSONRPCError(code: -32000, message: msg)) }
            return (nil, JSONRPCError(code: -32000, message: "Unexpected payload response"))
        case let .error(msg): return (nil, JSONRPCError(code: -32000, message: msg))
        default: return (nil, JSONRPCError(code: -32000, message: "Unexpected response from daemon"))
        }
    }

    // MARK: - kouenBrowserCookies

    func kouenBrowserCookies(paneIdStr: String) async -> (AnyCodable?, JSONRPCError?) {
        guard let paneID = UUID(uuidString: paneIdStr) else {
            return (nil, JSONRPCError(code: -32602, message: "Invalid paneId UUID: \(paneIdStr)"))
        }
        guard let response = await send(.browserCookies(paneID: paneID)) else {
            return (nil, JSONRPCError(code: -32000, message: "Daemon unavailable"))
        }
        switch response {
        case let .browserSuccess(payload):
            if case let .cookies(cookies) = payload {
                let items: [AnyCodable] = cookies.map { c in
                    .object([
                        "name": .string(c.name), "value": .string(c.value),
                        "domain": .string(c.domain), "path": .string(c.path),
                        "isSecure": .bool(c.isSecure), "isHTTPOnly": .bool(c.isHTTPOnly),
                    ])
                }
                return (toolResult(json: .object(["cookies": .array(items)])), nil)
            }
            if case let .error(msg) = payload { return (nil, JSONRPCError(code: -32000, message: msg)) }
            return (nil, JSONRPCError(code: -32000, message: "Unexpected payload response"))
        case let .error(msg): return (nil, JSONRPCError(code: -32000, message: msg))
        default: return (nil, JSONRPCError(code: -32000, message: "Unexpected response from daemon"))
        }
    }

    // MARK: - kouenBrowserStorage

    func kouenBrowserStorage(paneIdStr: String, storageType: String) async -> (AnyCodable?, JSONRPCError?) {
        guard let paneID = UUID(uuidString: paneIdStr) else {
            return (nil, JSONRPCError(code: -32602, message: "Invalid paneId UUID: \(paneIdStr)"))
        }
        guard let response = await send(.browserStorage(paneID: paneID, storageType: storageType)) else {
            return (nil, JSONRPCError(code: -32000, message: "Daemon unavailable"))
        }
        switch response {
        case let .browserSuccess(payload):
            if case let .storage(kv) = payload {
                let items: [String: AnyCodable] = kv.mapValues { .string($0) }
                return (toolResult(json: .object(["entries": .object(items)])), nil)
            }
            if case let .error(msg) = payload { return (nil, JSONRPCError(code: -32000, message: msg)) }
            return (nil, JSONRPCError(code: -32000, message: "Unexpected payload response"))
        case let .error(msg): return (nil, JSONRPCError(code: -32000, message: msg))
        default: return (nil, JSONRPCError(code: -32000, message: "Unexpected response from daemon"))
        }
    }

    // MARK: - kouenBrowserEvaluate

    func kouenBrowserEvaluate(paneIdStr: String, script: String) async -> (AnyCodable?, JSONRPCError?) {
        let toolName = "kouenBrowserEvaluate"
        guard isToolAllowed(toolName) else { return (nil, disabledError(toolName)) }
        guard let paneID = UUID(uuidString: paneIdStr) else {
            return (nil, JSONRPCError(code: -32602, message: "Invalid paneId UUID: \(paneIdStr)"))
        }
        guard let response = await send(.browserEvaluate(paneID: paneID, script: script)) else {
            return (nil, JSONRPCError(code: -32000, message: "Daemon unavailable"))
        }
        switch response {
        case let .browserSuccess(payload):
            if case let .text(result) = payload {
                return (toolResult(json: .object(["result": .string(result)])), nil)
            }
            if case let .error(msg) = payload { return (nil, JSONRPCError(code: -32000, message: msg)) }
            return (nil, JSONRPCError(code: -32000, message: "Unexpected payload response"))
        case let .error(msg): return (nil, JSONRPCError(code: -32000, message: msg))
        default: return (nil, JSONRPCError(code: -32000, message: "Unexpected response from daemon"))
        }
    }

    // MARK: - kouenBrowserGoBack / GoForward / Reload

    func kouenBrowserGoBack(paneIdStr: String) async -> (AnyCodable?, JSONRPCError?) {
        let toolName = "kouenBrowserGoBack"
        guard isToolAllowed(toolName) else { return (nil, disabledError(toolName)) }
        guard let paneID = UUID(uuidString: paneIdStr) else {
            return (nil, JSONRPCError(code: -32602, message: "Invalid paneId UUID: \(paneIdStr)"))
        }
        guard let response = await send(.browserGoBack(paneID: paneID)) else {
            return (nil, JSONRPCError(code: -32000, message: "Daemon unavailable"))
        }
        if case let .browserSuccess(.ok) = response { return (toolResult(json: .object(["ok": .bool(true)])), nil) }
        if case let .browserSuccess(.error(msg)) = response { return (nil, JSONRPCError(code: -32000, message: msg)) }
        return (nil, JSONRPCError(code: -32000, message: "Unexpected response"))
    }

    func kouenBrowserGoForward(paneIdStr: String) async -> (AnyCodable?, JSONRPCError?) {
        let toolName = "kouenBrowserGoForward"
        guard isToolAllowed(toolName) else { return (nil, disabledError(toolName)) }
        guard let paneID = UUID(uuidString: paneIdStr) else {
            return (nil, JSONRPCError(code: -32602, message: "Invalid paneId UUID: \(paneIdStr)"))
        }
        guard let response = await send(.browserGoForward(paneID: paneID)) else {
            return (nil, JSONRPCError(code: -32000, message: "Daemon unavailable"))
        }
        if case let .browserSuccess(.ok) = response { return (toolResult(json: .object(["ok": .bool(true)])), nil) }
        if case let .browserSuccess(.error(msg)) = response { return (nil, JSONRPCError(code: -32000, message: msg)) }
        return (nil, JSONRPCError(code: -32000, message: "Unexpected response"))
    }

    func kouenBrowserReload(paneIdStr: String) async -> (AnyCodable?, JSONRPCError?) {
        let toolName = "kouenBrowserReload"
        guard isToolAllowed(toolName) else { return (nil, disabledError(toolName)) }
        guard let paneID = UUID(uuidString: paneIdStr) else {
            return (nil, JSONRPCError(code: -32602, message: "Invalid paneId UUID: \(paneIdStr)"))
        }
        guard let response = await send(.browserReload(paneID: paneID)) else {
            return (nil, JSONRPCError(code: -32000, message: "Daemon unavailable"))
        }
        if case let .browserSuccess(.ok) = response { return (toolResult(json: .object(["ok": .bool(true)])), nil) }
        if case let .browserSuccess(.error(msg)) = response { return (nil, JSONRPCError(code: -32000, message: msg)) }
        return (nil, JSONRPCError(code: -32000, message: "Unexpected response"))
    }

    private func toolResult(json value: AnyCodable) -> AnyCodable {
        let data = try? JSONEncoder().encode(value)
        let text = data.flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
        return .object([
            "content": .array([
                .object([
                    "type": .string("text"),
                    "text": .string(text),
                ])
            ])
        ])
    }
}
