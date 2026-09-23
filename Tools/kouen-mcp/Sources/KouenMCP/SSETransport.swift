import Foundation
import Network
import CryptoKit
import KouenCore

/// HTTP and Server-Sent Events (SSE) Transport for Kouen MCP Server.
/// Complies with the Model Context Protocol (MCP) HTTP with SSE transport specification.
final class SSETransport: @unchecked Sendable {
    private let server: MCPServer
    private let host: String
    private let port: UInt16
    private let authToken: String?
    private let queue = DispatchQueue(label: "kouen.mcp.sse", qos: .userInitiated)

    private let stateLock = NSLock()
    private var _listener: NWListener?
    private var listener: NWListener? {
        get {
            stateLock.lock()
            defer { stateLock.unlock() }
            return _listener
        }
        set {
            stateLock.lock()
            defer { stateLock.unlock() }
            _listener = newValue
        }
    }
    private var sessions: [String: NWConnection] = [:]
    private var _isRunning = false
    private var isRunning: Bool {
        get {
            stateLock.lock()
            defer { stateLock.unlock() }
            return _isRunning
        }
        set {
            stateLock.lock()
            defer { stateLock.unlock() }
            _isRunning = newValue
        }
    }

    init(server: MCPServer, host: String = "0.0.0.0", port: UInt16 = 8765, authToken: String? = nil) {
        self.server = server
        self.host = host
        self.port = port
        self.authToken = authToken
    }

    func start() async {
        do {
            let nwPort = NWEndpoint.Port(rawValue: port) ?? 8765
            let params = NWParameters.tcp
            params.allowLocalEndpointReuse = true
            params.requiredLocalEndpoint = NWEndpoint.hostPort(host: NWEndpoint.Host(host), port: nwPort)

            let l = try NWListener(using: params)
            self.listener = l

            l.stateUpdateHandler = { [weak self] state in
                guard let self else { return }
                switch state {
                case .ready:
                    let tokenHint = self.authToken != nil ? " (auth token enabled)" : ""
                    fputs("kouen-mcp: Remote HTTP/SSE server listening on http://\(self.host):\(self.port)\(tokenHint)\n", stderr)
                    fputs("  SSE Endpoint:    http://\(self.host):\(self.port)/sse\n", stderr)
                    fputs("  Direct MCP:      http://\(self.host):\(self.port)/mcp\n", stderr)
                    fputs("  Health / Info:   http://\(self.host):\(self.port)/health\n", stderr)
                    fflush(stderr)
                case .failed(let error):
                    fputs("kouen-mcp: Listener failed with error: \(error)\n", stderr)
                    fflush(stderr)
                case .cancelled:
                    fputs("kouen-mcp: Listener stopped\n", stderr)
                    fflush(stderr)
                default:
                    break
                }
            }

            l.newConnectionHandler = { [weak self] conn in
                self?.handleIncomingConnection(conn)
            }

            self.isRunning = true
            l.start(queue: queue)

            // Keep the async task running until cancelled or stopped
            while self.isRunning && !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 100_000_000)
            }
        } catch {
            fputs("kouen-mcp: Failed to bind HTTP server on \(host):\(port): \(error)\n", stderr)
            fflush(stderr)
        }
    }

    public func stop() {
        self.isRunning = false
        queue.async {
            for (_, conn) in self.sessions {
                conn.cancel()
            }
            self.sessions.removeAll()
            let l = self.listener
            self.listener = nil
            l?.cancel()
        }
    }

    // MARK: - Connection & HTTP Handling

    private func handleIncomingConnection(_ conn: NWConnection) {
        conn.start(queue: queue)
        readHTTPRequest(conn: conn, accumulated: Data())
    }

    private func readHTTPRequest(conn: NWConnection, accumulated: Data) {
        conn.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] content, _, isComplete, error in
            guard let self else { return }

            if error != nil {
                conn.cancel()
                return
            }

            var buffer = accumulated
            if let content {
                buffer.append(content)
            }

            // Look for end of HTTP headers (\r\n\r\n)
            if let headerRange = buffer.range(of: Data("\r\n\r\n".utf8)) {
                let headerData = buffer[..<headerRange.lowerBound]
                let bodyData = buffer[headerRange.upperBound...]

                guard let headerString = String(data: headerData, encoding: .utf8) else {
                    self.sendHTTPResponse(conn: conn, status: "400 Bad Request", body: "Invalid HTTP Request")
                    return
                }

                let lines = headerString.components(separatedBy: "\r\n")
                guard let requestLine = lines.first else {
                    self.sendHTTPResponse(conn: conn, status: "400 Bad Request", body: "Empty Request Line")
                    return
                }

                let reqParts = requestLine.split(separator: " ")
                guard reqParts.count >= 2 else {
                    self.sendHTTPResponse(conn: conn, status: "400 Bad Request", body: "Malformed Request Line")
                    return
                }

                let method = String(reqParts[0]).uppercased()
                let fullPath = String(reqParts[1])

                var headers: [String: String] = [:]
                for line in lines.dropFirst() {
                    guard let colonIdx = line.firstIndex(of: ":") else { continue }
                    let key = line[..<colonIdx].trimmingCharacters(in: .whitespaces).lowercased()
                    let value = line[line.index(after: colonIdx)...].trimmingCharacters(in: .whitespaces)
                    headers[key] = value
                }

                let contentLength = Int(headers["content-length"] ?? "0") ?? 0

                // Check if we have received the full body
                if bodyData.count < contentLength {
                    // Need more body bytes
                    self.readRemainingBody(conn: conn, method: method, fullPath: fullPath, headers: headers, accumulatedBody: Data(bodyData), expectedLength: contentLength)
                    return
                }

                let completeBody = Data(bodyData.prefix(contentLength))
                self.dispatchRequest(conn: conn, method: method, fullPath: fullPath, headers: headers, body: completeBody)
            } else if buffer.count > 16384 {
                // Header too large
                self.sendHTTPResponse(conn: conn, status: "431 Request Header Fields Too Large", body: "Headers too large")
            } else if isComplete {
                conn.cancel()
            } else {
                // Continue reading headers
                self.readHTTPRequest(conn: conn, accumulated: buffer)
            }
        }
    }

    private func readRemainingBody(conn: NWConnection, method: String, fullPath: String, headers: [String: String], accumulatedBody: Data, expectedLength: Int) {
        conn.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] content, _, isComplete, error in
            guard let self else { return }

            if error != nil {
                conn.cancel()
                return
            }

            var body = accumulatedBody
            if let content {
                body.append(content)
            }

            if body.count >= expectedLength {
                let completeBody = Data(body.prefix(expectedLength))
                self.dispatchRequest(conn: conn, method: method, fullPath: fullPath, headers: headers, body: completeBody)
            } else if isComplete {
                conn.cancel()
            } else {
                self.readRemainingBody(conn: conn, method: method, fullPath: fullPath, headers: headers, accumulatedBody: body, expectedLength: expectedLength)
            }
        }
    }

    // MARK: - Routing & Dispatch

    private func dispatchRequest(conn: NWConnection, method: String, fullPath: String, headers: [String: String], body: Data) {
        // Handle CORS Preflight
        if method == "OPTIONS" {
            sendCORSPreflightResponse(conn: conn)
            return
        }

        // Validate Token if configured
        if let token = authToken {
            let authHeader = headers["authorization"] ?? ""
            let urlParams = parseQueryParams(url: fullPath)
            let tokenParam = urlParams["token"]

            let bearerValid = Self.constantTimeEquals(authHeader, "Bearer \(token)")
            let paramValid = tokenParam.map { Self.constantTimeEquals($0, token) } ?? false
            let valid = bearerValid || paramValid
            if !valid {
                sendHTTPResponse(conn: conn, status: "401 Unauthorized", body: "Unauthorized: Invalid or missing authentication token")
                return
            }
        }

        let pathOnly = fullPath.split(separator: "?").first.map(String.init) ?? fullPath
        let queryParams = parseQueryParams(url: fullPath)

        switch (method, pathOnly) {
        case ("GET", "/sse"):
            handleSSEConnect(conn: conn)

        case ("POST", "/message"):
            handlePostMessage(conn: conn, queryParams: queryParams, body: body)

        case ("POST", "/mcp"), ("POST", "/"):
            handleDirectJSONRPC(conn: conn, body: body)

        case ("GET", "/health"), ("GET", "/"):
            handleHealthCheck(conn: conn)

        default:
            sendHTTPResponse(conn: conn, status: "404 Not Found", body: "Endpoint not found: \(pathOnly)")
        }
    }

    // MARK: - SSE Handler

    private func handleSSEConnect(conn: NWConnection) {
        let sessionId = UUID().uuidString

        // Register session
        sessions[sessionId] = conn

        conn.stateUpdateHandler = { [weak self] state in
            guard let self else { return }
            switch state {
            case .cancelled, .failed:
                self.queue.async { [weak self] in
                    self?.sessions.removeValue(forKey: sessionId)
                }
            default:
                break
            }
        }

        // Send HTTP 200 OK with SSE headers
        let headers = [
            "HTTP/1.1 200 OK",
            "Content-Type: text/event-stream",
            "Cache-Control: no-cache, no-transform",
            "Connection: keep-alive",
            "Access-Control-Allow-Origin: *",
            "Access-Control-Allow-Headers: *",
            "\r\n"
        ].joined(separator: "\r\n")

        conn.send(content: Data(headers.utf8), completion: .contentProcessed { error in
            guard error == nil else { return }

            // Immediately send the 'endpoint' event per MCP specification
            let endpointEvent = "event: endpoint\r\ndata: /message?sessionId=\(sessionId)\r\n\r\n"
            conn.send(content: Data(endpointEvent.utf8), completion: .contentProcessed { _ in })
        })
    }

    private func handlePostMessage(conn: NWConnection, queryParams: [String: String], body: Data) {
        guard let sessionId = queryParams["sessionId"] else {
            sendHTTPResponse(conn: conn, status: "400 Bad Request", body: "Missing sessionId query parameter")
            return
        }

        guard let sseConn = sessions[sessionId] else {
            sendHTTPResponse(conn: conn, status: "404 Not Found", body: "Active SSE session not found for sessionId: \(sessionId)")
            return
        }

        // Acknowledge the POST with 202 Accepted immediately
        sendHTTPResponse(conn: conn, status: "202 Accepted", body: "Accepted")

        // Asynchronously process the JSON-RPC request and send response over the SSE stream
        Task {
            guard let message = try? JSONDecoder().decode(JSONRPCMessage.self, from: body) else {
                let errData = Data("event: message\r\ndata: {\"jsonrpc\":\"2.0\",\"error\":{\"code\":-32700,\"message\":\"Parse error\"}}\r\n\r\n".utf8)
                sseConn.send(content: errData, completion: .contentProcessed { _ in })
                return
            }

            if let response = await self.server.handle(message) {
                if let encoded = try? JSONEncoder().encode(response),
                   let jsonStr = String(data: encoded, encoding: .utf8) {
                    let ssePayload = "event: message\r\ndata: \(jsonStr)\r\n\r\n"
                    sseConn.send(content: Data(ssePayload.utf8), completion: .contentProcessed { _ in })
                }
            }
        }
    }

    // MARK: - Direct JSON-RPC (Streamable HTTP / POST /mcp)

    private func handleDirectJSONRPC(conn: NWConnection, body: Data) {
        Task {
            guard let message = try? JSONDecoder().decode(JSONRPCMessage.self, from: body) else {
                let errBody = "{\"jsonrpc\":\"2.0\",\"error\":{\"code\":-32700,\"message\":\"Parse error\"}}"
                self.sendJSONResponse(conn: conn, status: "400 Bad Request", json: errBody)
                return
            }

            if let response = await self.server.handle(message),
               let encoded = try? JSONEncoder().encode(response),
               let jsonStr = String(data: encoded, encoding: .utf8) {
                self.sendJSONResponse(conn: conn, status: "200 OK", json: jsonStr)
            } else {
                // Notifications have no response
                self.sendHTTPResponse(conn: conn, status: "204 No Content", body: "")
            }
        }
    }

    // MARK: - Health Check / Discovery

    private func handleHealthCheck(conn: NWConnection) {
        let info = """
        {
          "server": "kouen-mcp",
          "version": "\(KouenVersion.short)",
          "status": "ok",
          "transport": "sse",
          "endpoints": {
            "sse": "/sse",
            "message": "/message?sessionId=<sessionId>",
            "direct": "/mcp",
            "health": "/health"
          }
        }
        """
        sendJSONResponse(conn: conn, status: "200 OK", json: info)
    }

    // MARK: - Helpers

    private func sendHTTPResponse(conn: NWConnection, status: String, body: String) {
        let bodyData = Data(body.utf8)
        let resp = [
            "HTTP/1.1 \(status)",
            "Content-Type: text/plain; charset=utf-8",
            "Content-Length: \(bodyData.count)",
            "Connection: close",
            "Access-Control-Allow-Origin: *",
            "\r\n"
        ].joined(separator: "\r\n") + body

        conn.send(content: Data(resp.utf8), completion: .contentProcessed { _ in
            conn.cancel()
        })
    }

    private func sendJSONResponse(conn: NWConnection, status: String, json: String) {
        let bodyData = Data(json.utf8)
        let resp = [
            "HTTP/1.1 \(status)",
            "Content-Type: application/json; charset=utf-8",
            "Content-Length: \(bodyData.count)",
            "Connection: close",
            "Access-Control-Allow-Origin: *",
            "\r\n"
        ].joined(separator: "\r\n") + json

        conn.send(content: Data(resp.utf8), completion: .contentProcessed { _ in
            conn.cancel()
        })
    }

    private func sendCORSPreflightResponse(conn: NWConnection) {
        let resp = [
            "HTTP/1.1 204 No Content",
            "Access-Control-Allow-Origin: *",
            "Access-Control-Allow-Methods: GET, POST, OPTIONS",
            "Access-Control-Allow-Headers: Content-Type, Authorization",
            "Access-Control-Max-Age: 86400",
            "Content-Length: 0",
            "Connection: close",
            "\r\n\r\n"
        ].joined(separator: "\r\n")

        conn.send(content: Data(resp.utf8), completion: .contentProcessed { _ in
            conn.cancel()
        })
    }

    private func parseQueryParams(url: String) -> [String: String] {
        guard let queryIdx = url.firstIndex(of: "?") else { return [:] }
        let queryString = url[url.index(after: queryIdx)...]
        var params: [String: String] = [:]
        for pair in queryString.split(separator: "&") {
            let kv = pair.split(separator: "=", maxSplits: 1)
            if kv.count == 2 {
                let k = String(kv[0]).removingPercentEncoding ?? String(kv[0])
                let v = String(kv[1]).removingPercentEncoding ?? String(kv[1])
                params[k] = v
            } else if kv.count == 1 {
                let k = String(kv[0]).removingPercentEncoding ?? String(kv[0])
                params[k] = ""
            }
        }
        return params
    }

    private static func constantTimeEquals(_ a: String, _ b: String) -> Bool {
        let hashA = SHA256.hash(data: Data(a.utf8))
        let hashB = SHA256.hash(data: Data(b.utf8))
        var diff: UInt8 = 0
        for (byteA, byteB) in zip(hashA, hashB) {
            diff |= byteA ^ byteB
        }
        return diff == 0
    }
}
