import Foundation
import HarnessCore

/// Daemon-backed MCP tools for the browser pane (P14 PBI-BROWSER-004).
struct HarnessBrowserTools: Sendable {
    static let controlGateVariable = "HARNESS_MCP_ALLOW_CONTROL"

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

    // MARK: - harnessBrowserOpen

    func harnessBrowserOpen(urlStr: String, directionStr: String?) async -> (AnyCodable?, JSONRPCError?) {
        let toolName = "harnessBrowserOpen"
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

    // MARK: - harnessBrowserNavigate

    func harnessBrowserNavigate(paneIdStr: String, urlStr: String) async -> (AnyCodable?, JSONRPCError?) {
        let toolName = "harnessBrowserNavigate"
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

    // MARK: - harnessBrowserWait

    func harnessBrowserWait(paneIdStr: String, timeoutSeconds: Double?) async -> (AnyCodable?, JSONRPCError?) {
        let toolName = "harnessBrowserWait"
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

    // MARK: - harnessBrowserSnapshot

    func harnessBrowserSnapshot(paneIdStr: String, interactive: Bool?) async -> (AnyCodable?, JSONRPCError?) {
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

    // MARK: - harnessBrowserInteract

    func harnessBrowserInteract(paneIdStr: String, action: String, elementId: String, text: String?) async -> (AnyCodable?, JSONRPCError?) {
        let toolName = "harnessBrowserInteract"
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

    // MARK: - harnessBrowserClose

    func harnessBrowserClose(paneIdStr: String) async -> (AnyCodable?, JSONRPCError?) {
        let toolName = "harnessBrowserClose"
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
