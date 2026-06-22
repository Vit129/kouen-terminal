import XCTest
@testable import HarnessMCP
import HarnessCore

final class StdioTransportTests: XCTestCase {
    private let initialize = ACPMessage.request(
        id: .int(1),
        method: "initialize",
        params: .object(["protocolVersion": .string("2024-11-05")])
    )

    func testParsesNewlineDelimitedMessage() throws {
        var data = try JSONEncoder().encode(initialize)
        data.append(Data("\n".utf8))
        let buffer = MCPStdioBuffer()
        buffer.append(data)

        let result = try XCTUnwrap(buffer.nextMessage())
        XCTAssertEqual(result.0, initialize)
        XCTAssertEqual(result.1, .newline)
    }

    func testParsesContentLengthMessage() throws {
        let buffer = MCPStdioBuffer()
        buffer.append(try ACPTransport.encode(initialize))

        let result = try XCTUnwrap(buffer.nextMessage())
        XCTAssertEqual(result.0, initialize)
        XCTAssertEqual(result.1, .contentLength)
    }

    func testNewlineMessageWaitsForTerminator() throws {
        let body = try JSONEncoder().encode(initialize)
        let buffer = MCPStdioBuffer()
        buffer.append(body)
        XCTAssertNil(try buffer.nextMessage())

        buffer.append(Data("\n".utf8))
        XCTAssertEqual(try buffer.nextMessage()?.0, initialize)
    }

    func testContentLengthMessageWaitsForCompleteBody() throws {
        let frame = try ACPTransport.encode(initialize)
        let splitIndex = frame.index(frame.startIndex, offsetBy: frame.count - 1)
        let buffer = MCPStdioBuffer()
        buffer.append(frame[..<splitIndex])
        XCTAssertNil(try buffer.nextMessage())

        buffer.append(frame[splitIndex...])
        XCTAssertEqual(try buffer.nextMessage()?.0, initialize)
    }
}
