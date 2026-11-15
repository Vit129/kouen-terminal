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
}
#endif
