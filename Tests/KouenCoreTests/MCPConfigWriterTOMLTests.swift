import XCTest
@testable import KouenCore

/// Codex has no JSON MCP config — `MCPConfigWriter` hand-edits the `[mcp_servers.kouen]`
/// table in `config.toml` instead of parsing the whole file. This covers just that block
/// matcher, since it's the only non-trivial logic (add/remove themselves are thin wrappers
/// around it, and untestable without a `homeOverride` MCPConfigWriter doesn't have).
final class MCPConfigWriterTOMLTests: XCTestCase {
    func testFindsBlockAtEndOfFile() {
        let text = "[mcp_servers.other]\ncommand = \"x\"\n\n[mcp_servers.kouen]\ncommand = \"y\"\nargs = []\n"
        let range = MCPConfigWriter.tomlKouenBlock(in: text)
        XCTAssertNotNil(range)
        XCTAssertEqual(String(text[range!]), "[mcp_servers.kouen]\ncommand = \"y\"\nargs = []\n")
    }

    func testFindsBlockFollowedByAnotherTable() {
        let text = "[mcp_servers.kouen]\ncommand = \"y\"\nargs = []\n\n[mcp_servers.other]\ncommand = \"x\"\n"
        let range = MCPConfigWriter.tomlKouenBlock(in: text)
        XCTAssertNotNil(range)
        XCTAssertEqual(String(text[range!]), "[mcp_servers.kouen]\ncommand = \"y\"\nargs = []\n\n")
    }

    func testNilWhenNoBlockPresent() {
        let text = "[mcp_servers.other]\ncommand = \"x\"\n"
        XCTAssertNil(MCPConfigWriter.tomlKouenBlock(in: text))
    }

    func testNilOnEmptyFile() {
        XCTAssertNil(MCPConfigWriter.tomlKouenBlock(in: ""))
    }
}
