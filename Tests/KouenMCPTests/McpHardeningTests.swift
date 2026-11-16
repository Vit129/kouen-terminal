import XCTest
@testable import KouenMCP
import KouenCore

final class McpHardeningTests: XCTestCase {
    private let initialize = JSONRPCMessage.request(id: .int(1), method: "initialize", params: nil)

    func test_TS_2344_BE_UT_stdioDropsBadFramesAndKeepsReading() throws {
        let buffer = MCPStdioBuffer()
        buffer.append(Data("Content-Length: nope\r\n\r\n".utf8))          // unparsable length
        XCTAssertThrowsError(try buffer.nextMessage())
        buffer.append(Data("Content-Length: 5\r\n\r\n{bad}".utf8))        // valid header, bad JSON
        XCTAssertThrowsError(try buffer.nextMessage())
        buffer.append(Data("Content-Length: 99999999999\r\n\r\n".utf8))   // over the cap
        XCTAssertThrowsError(try buffer.nextMessage())
        let body = try JSONEncoder().encode(initialize)
        var good = Data("Content-Length: \(body.count)\r\n\r\n".utf8)
        good.append(body)
        buffer.append(good)
        XCTAssertEqual(try buffer.nextMessage()?.0, initialize, "a bad frame must not wedge later messages")
    }

    func test_TS_2345_BE_UT_shellTimesOutAndCapsOutput() async {
        let registry = ToolRegistry(policy: { ToolPolicy.load(from: URL(fileURLWithPath: "/nonexistent-policy.json"), environment: [:]) })
        let start = Date()
        let (_, err, _) = await registry.shell("sleep 30", cwd: nil, timeout: 0.5)
        XCTAssertLessThan(Date().timeIntervalSince(start), 10)
        XCTAssertTrue(err.contains("timed out"))

        let (out, _, code) = await registry.shell("head -c 6000000 /dev/zero | tr '\\0' a", cwd: nil)
        XCTAssertEqual(code, 0)
        XCTAssertTrue(out.contains("stdout truncated"))
        XCTAssertLessThan(out.utf8.count, ToolRegistry.maxShellOutputBytes + 200)
    }

    func test_TS_2346_BE_UT_readFileRejectsOversizedFile() async throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: url) }
        FileManager.default.createFile(atPath: url.path, contents: Data(count: ToolRegistry.maxReadFileBytes + 1))
        let registry = ToolRegistry(policy: { ToolPolicy.load(from: URL(fileURLWithPath: "/nonexistent-policy.json"), environment: [:]) })
        let (result, error) = await registry.callTool(params: .object(["name": .string("readFile"), "arguments": .object(["path": .string(url.path)])]))
        XCTAssertNil(result)
        XCTAssertTrue(error?.message.contains("too large") == true)
    }
}
