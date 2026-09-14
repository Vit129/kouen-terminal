import XCTest
@testable import KouenMCP
import KouenCore

final class SSETransportTests: XCTestCase {
    private var transport: SSETransport?
    private let testPort: UInt16 = 9876

    override func tearDown() async throws {
        transport?.stop()
        transport = nil
        try await Task.sleep(nanoseconds: 100_000_000)
    }

    func testHealthEndpoint() async throws {
        let server = MCPServer()
        let sse = SSETransport(server: server, host: "127.0.0.1", port: testPort)
        transport = sse

        Task { await sse.start() }
        try await Task.sleep(nanoseconds: 200_000_000)

        let url = URL(string: "http://127.0.0.1:\(testPort)/health")!
        let (data, response) = try await URLSession.shared.data(from: url)

        let http = try XCTUnwrap(response as? HTTPURLResponse)
        XCTAssertEqual(http.statusCode, 200)

        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(json["server"] as? String, "kouen-mcp")
        XCTAssertEqual(json["status"] as? String, "ok")
        XCTAssertEqual(json["transport"] as? String, "sse")
    }

    func testCORSPreflight() async throws {
        let server = MCPServer()
        let sse = SSETransport(server: server, host: "127.0.0.1", port: testPort)
        transport = sse

        Task { await sse.start() }
        try await Task.sleep(nanoseconds: 200_000_000)

        var request = URLRequest(url: URL(string: "http://127.0.0.1:\(testPort)/sse")!)
        request.httpMethod = "OPTIONS"

        let (_, response) = try await URLSession.shared.data(for: request)
        let http = try XCTUnwrap(response as? HTTPURLResponse)
        XCTAssertEqual(http.statusCode, 204)
        XCTAssertEqual(http.value(forHTTPHeaderField: "Access-Control-Allow-Origin"), "*")
    }

    func testDirectJSONRPCMethodList() async throws {
        let server = MCPServer()
        let sse = SSETransport(server: server, host: "127.0.0.1", port: testPort)
        transport = sse

        Task { await sse.start() }
        try await Task.sleep(nanoseconds: 200_000_000)

        var request = URLRequest(url: URL(string: "http://127.0.0.1:\(testPort)/mcp")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = Data("{\"jsonrpc\":\"2.0\",\"id\":10,\"method\":\"tools/list\"}".utf8)

        let (data, response) = try await URLSession.shared.data(for: request)
        let http = try XCTUnwrap(response as? HTTPURLResponse)
        XCTAssertEqual(http.statusCode, 200)

        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(json["id"] as? Int, 10)
        let result = try XCTUnwrap(json["result"] as? [String: Any])
        let tools = try XCTUnwrap(result["tools"] as? [[String: Any]])
        XCTAssertGreaterThan(tools.count, 20)
    }

    func testAuthTokenProtection() async throws {
        let server = MCPServer()
        let sse = SSETransport(server: server, host: "127.0.0.1", port: testPort, authToken: "secret-token")
        transport = sse

        Task { await sse.start() }
        try await Task.sleep(nanoseconds: 200_000_000)

        let url = URL(string: "http://127.0.0.1:\(testPort)/health")!

        // 1. Unauthenticated request should be 401
        let (_, unauthResp) = try await URLSession.shared.data(from: url)
        let unauthHttp = try XCTUnwrap(unauthResp as? HTTPURLResponse)
        XCTAssertEqual(unauthHttp.statusCode, 401)

        // 2. Authenticated request via Bearer header should be 200
        var authedReq = URLRequest(url: url)
        authedReq.setValue("Bearer secret-token", forHTTPHeaderField: "Authorization")
        let (_, authResp) = try await URLSession.shared.data(for: authedReq)
        let authHttp = try XCTUnwrap(authResp as? HTTPURLResponse)
        XCTAssertEqual(authHttp.statusCode, 200)

        // 3. Authenticated request via URL parameter should be 200
        let paramUrl = URL(string: "http://127.0.0.1:\(testPort)/health?token=secret-token")!
        let (_, paramResp) = try await URLSession.shared.data(from: paramUrl)
        let paramHttp = try XCTUnwrap(paramResp as? HTTPURLResponse)
        XCTAssertEqual(paramHttp.statusCode, 200)
    }
}
