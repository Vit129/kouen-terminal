// SSETransport only exists where Network.framework does.
#if canImport(Network)
import XCTest
@testable import KouenMCP
import KouenCore

final class SSETransportTests: XCTestCase {
    private var transport: SSETransport?
    private var serverTask: Task<Void, Never>?
    private let testPort: UInt16 = 19876

    override func tearDown() async throws {
        transport?.stop()
        serverTask?.cancel()
        await serverTask?.value
        transport = nil
        serverTask = nil
    }

    private func start(token: String? = "secret-token") async throws {
        let sse = SSETransport(server: MCPServer(), host: "127.0.0.1", port: testPort, authToken: token)
        transport = sse
        serverTask = Task { await sse.start() }
        let deadline = Date().addingTimeInterval(5)
        repeat {
            do {
                _ = try await request()
                return
            } catch {
                if Date() >= deadline { throw error }
                await Task.yield()
            }
        } while true
    }

    private func request(path: String = "/health", method: String = "GET",
                         token: String? = "secret-token", origin: String? = nil,
                         host: String? = nil, body: String? = nil) async throws -> (Data, HTTPURLResponse) {
        var request = URLRequest(url: URL(string: "http://127.0.0.1:\(testPort)\(path)")!)
        request.timeoutInterval = 2
        request.httpMethod = method
        if let token { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        if let origin { request.setValue(origin, forHTTPHeaderField: "Origin") }
        if let host { request.setValue(host, forHTTPHeaderField: "Host") }
        if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = Data(body.utf8)
        }
        let (data, response) = try await URLSession.shared.data(for: request)
        return (data, try XCTUnwrap(response as? HTTPURLResponse))
    }

    func testHealthEndpoint() async throws {
        try await start()
        let (data, http) = try await request()
        XCTAssertEqual(http.statusCode, 200)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(json["server"] as? String, "kouen-mcp")
        XCTAssertEqual(json["status"] as? String, "ok")
    }

    func test_TC0201_BE_UT_ForeignOriginIsForbidden() async throws {
        try await start()
        for origin in ["https://evil.example", "null", "http://localhost.evil.example", "file://", "http://user@localhost"] {
            let (_, http) = try await request(origin: origin)
            XCTAssertEqual(http.statusCode, 403, origin)
            XCTAssertNil(http.value(forHTTPHeaderField: "Access-Control-Allow-Origin"))
        }
        let (_, preflight) = try await request(method: "OPTIONS", token: nil, origin: "https://evil.example")
        XCTAssertEqual(preflight.statusCode, 403)
    }

    func test_TC0202_BE_UT_RebindingHostIsForbidden() async throws {
        try await start()
        for host in ["evil.example:\(testPort)", "127.0.0.1.evil.example:\(testPort)", "localhost:1"] {
            let (_, http) = try await request(host: host)
            XCTAssertEqual(http.statusCode, 403, host)
        }
    }

    func test_TC0203_BE_UT_GeneratedTokenRequiredAndQueryTokenRejected() async throws {
        try await start(token: nil)
        let (_, noToken) = try await request(token: nil)
        XCTAssertEqual(noToken.statusCode, 401)
        let (_, invalid) = try await request(token: "wrong")
        XCTAssertEqual(invalid.statusCode, 401)
        let (_, query) = try await request(path: "/health?token=secret-token", token: nil)
        XCTAssertEqual(query.statusCode, 401)
    }

    func test_TC0204_BE_UT_ValidBearerWithoutOriginSucceeds() async throws {
        try await start()
        let (_, http) = try await request()
        XCTAssertEqual(http.statusCode, 200)
        XCTAssertNil(http.value(forHTTPHeaderField: "Access-Control-Allow-Origin"))
        let (_, queryOnly) = try await request(path: "/health?token=secret-token", token: nil)
        XCTAssertEqual(queryOnly.statusCode, 401)
        let (_, localOrigin) = try await request(origin: "http://localhost:3000")
        XCTAssertEqual(localOrigin.statusCode, 200)
        let (_, preflight) = try await request(method: "OPTIONS")
        XCTAssertEqual(preflight.statusCode, 204)
        XCTAssertNil(preflight.value(forHTTPHeaderField: "Access-Control-Allow-Origin"))
    }

    func test_TC0205_BE_UT_HostPolicyPreservesExplicitRemoteBindings() {
        XCTAssertTrue(HTTPRequestPolicy.permits(headers: ["host": "100.64.0.1:8765"], bindHost: "100.64.0.1", port: 8765))
        XCTAssertTrue(HTTPRequestPolicy.permits(headers: ["host": "100.64.0.1:8765"], bindHost: "0.0.0.0", port: 8765))
        XCTAssertFalse(HTTPRequestPolicy.permits(headers: ["host": "evil.example:8765"], bindHost: "0.0.0.0", port: 8765))
        XCTAssertFalse(HTTPRequestPolicy.permits(headers: [:], bindHost: "127.0.0.1", port: 8765))
        XCTAssertFalse(HTTPRequestPolicy.permits(headers: ["host": "user@localhost:8765"], bindHost: "127.0.0.1", port: 8765))
        XCTAssertTrue(HTTPRequestPolicy.permits(headers: ["host": "[::1]:8765", "origin": "http://[::1]:3000"], bindHost: "::1", port: 8765))
    }

    func testDirectJSONRPCMethodList() async throws {
        try await start()
        let (data, http) = try await request(path: "/mcp", method: "POST",
            body: "{\"jsonrpc\":\"2.0\",\"id\":10,\"method\":\"tools/list\"}")
        XCTAssertEqual(http.statusCode, 200)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(json["id"] as? Int, 10)
        let result = try XCTUnwrap(json["result"] as? [String: Any])
        XCTAssertGreaterThan(try XCTUnwrap(result["tools"] as? [[String: Any]]).count, 20)
    }

    // MARK: - [TC-0702] Content-Length is untrusted input

    /// Sends a hand-written request (URLSession refuses a malformed Content-Length) and returns the
    /// status line the transport answered with.
    private func rawStatusLine(contentLength: String, token: String? = nil) throws -> String {
        let fd = socket(AF_INET, SOCK_STREAM, 0)
        defer { close(fd) }
        var addr = sockaddr_in()
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = testPort.bigEndian
        addr.sin_addr.s_addr = inet_addr("127.0.0.1")
        let rc = withUnsafePointer(to: &addr) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { connect(fd, $0, socklen_t(MemoryLayout<sockaddr_in>.size)) }
        }
        XCTAssertEqual(rc, 0)
        var tv = timeval(tv_sec: 3, tv_usec: 0)
        setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &tv, socklen_t(MemoryLayout<timeval>.size))
        var head = "POST /message HTTP/1.1\r\nHost: 127.0.0.1:\(testPort)\r\nContent-Length: \(contentLength)\r\n"
        if let token { head += "Authorization: Bearer \(token)\r\n" }
        head += "\r\n"
        _ = head.withCString { write(fd, $0, strlen($0)) }
        var buf = [UInt8](repeating: 0, count: 256)
        let n = read(fd, &buf, buf.count)
        guard n > 0 else { return "" }
        return String(decoding: buf.prefix(n), as: UTF8.self).components(separatedBy: "\r\n").first ?? ""
    }

    func test_TC0702_BE_UT_NegativeContentLengthIsRejectedBeforeAuth() async throws {
        try await start()
        XCTAssertTrue(try rawStatusLine(contentLength: "-1").contains("400"))
        XCTAssertTrue(try rawStatusLine(contentLength: "abc").contains("400"))
    }

    func test_TC0702_BE_UT_OversizedContentLengthIsRejectedBeforeAuth() async throws {
        try await start()
        XCTAssertTrue(try rawStatusLine(contentLength: "\(4 * 1024 * 1024 + 1)").contains("413"))
        let overflow = try rawStatusLine(contentLength: "99999999999999999999")
        XCTAssertTrue(overflow.contains("413") || overflow.contains("400"), overflow)
    }
}
#endif
