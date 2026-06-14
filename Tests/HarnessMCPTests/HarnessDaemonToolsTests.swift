import XCTest
@testable import HarnessMCP
import HarnessCore

final class HarnessDaemonToolsTests: XCTestCase {
    private var temporaryDirectories: [URL] = []

    override func tearDownWithError() throws {
        for directory in temporaryDirectories {
            try? FileManager.default.removeItem(at: directory)
        }
        temporaryDirectories.removeAll()
        try super.tearDownWithError()
    }

    func testControlGateRequiresExactOne() {
        XCTAssertFalse(HarnessDaemonTools.isControlEnabled(environment: [:]))
        XCTAssertFalse(HarnessDaemonTools.isControlEnabled(environment: ["HARNESS_MCP_ALLOW_CONTROL": "true"]))
        XCTAssertFalse(HarnessDaemonTools.isControlEnabled(environment: ["HARNESS_MCP_ALLOW_CONTROL": "0"]))
        XCTAssertTrue(HarnessDaemonTools.isControlEnabled(environment: ["HARNESS_MCP_ALLOW_CONTROL": "1"]))
    }

    func testMutatingToolReturnsDeterministicErrorWhenGateClosed() async {
        let tools = HarnessDaemonTools(controlEnabled: { false })
        let (result, error) = await tools.sendPaneText(surfaceId: "surface", text: "echo nope\n", bracketed: false)
        XCTAssertNil(result)
        XCTAssertEqual(error, HarnessDaemonTools.controlDisabledError)
    }

    func testPolicyAbsentUsesSafeDefaults() async {
        let missingPolicyURL = temporaryDirectory().appendingPathComponent("missing-policy.json")
        let policy = ToolPolicy.load(from: missingPolicyURL, environment: [:])
        XCTAssertTrue(policy.isToolAllowed("readFile"))
        XCTAssertTrue(policy.isToolAllowed("harnessList"))
        XCTAssertFalse(policy.isToolAllowed("writeFile"))
        XCTAssertFalse(policy.isToolAllowed("runCommand"))
        XCTAssertFalse(policy.isToolAllowed("sendPaneText"))
    }

    /// P16 PBI-BOARD-005: `harnessBoard` is a read-only tool, so it must be
    /// allowed by the default policy and registered in `ToolRegistry` like
    /// `harnessList`.
    func testHarnessBoardIsReadOnlyAndRegistered() async {
        let missingPolicyURL = temporaryDirectory().appendingPathComponent("missing-policy.json")
        let policy = ToolPolicy.load(from: missingPolicyURL, environment: [:])
        XCTAssertTrue(policy.isToolAllowed("harnessBoard"))

        let registry = ToolRegistry(policy: policy)
        guard case let .object(root) = registry.listTools(),
              case let .array(tools) = root["tools"]
        else {
            XCTFail("Expected listTools() to return { tools: [...] }")
            return
        }
        let names: [String] = tools.compactMap {
            guard case let .object(tool) = $0, case let .string(name) = tool["name"] else { return nil }
            return name
        }
        XCTAssertTrue(names.contains("harnessBoard"))
    }

    func testPolicyExplicitDenyBlocksControlTools() async throws {
        let policyURL = try writePolicy(#"{ "version": 1, "allowControl": false, "allowedTools": [] }"#)
        let policy = ToolPolicy.load(from: policyURL, environment: [:])
        let registry = ToolRegistry(policy: policy)

        let params: AnyCodable = .object([
            "name": .string("sendPaneText"),
            "arguments": .object([
                "surfaceId": .string("surface"),
                "text": .string("echo denied\n"),
            ]),
        ])
        let (result, error) = await registry.callTool(params: params)
        XCTAssertNil(result)
        XCTAssertEqual(error?.code, -32000)
        XCTAssertTrue(error?.message.contains("sendPaneText") == true)
        XCTAssertFalse(policy.isToolAllowed("writeFile"))
    }

    func testPolicyAllowsNamedToolOnly() async throws {
        let policyURL = try writePolicy(#"{ "version": 1, "allowControl": false, "allowedTools": ["writeFile"] }"#)
        let policy = ToolPolicy.load(from: policyURL, environment: [:])
        let registry = ToolRegistry(policy: policy)
        let outputURL = temporaryDirectory().appendingPathComponent("policy-write.txt")

        let writeParams: AnyCodable = .object([
            "name": .string("writeFile"),
            "arguments": .object([
                "path": .string(outputURL.path),
                "content": .string("allowed"),
            ]),
        ])
        let (writeResult, writeError) = await registry.callTool(params: writeParams)
        XCTAssertNotNil(writeResult)
        XCTAssertNil(writeError)
        XCTAssertEqual(try String(contentsOf: outputURL, encoding: .utf8), "allowed")

        let commandParams: AnyCodable = .object([
            "name": .string("runCommand"),
            "arguments": .object(["command": .string("echo denied")]),
        ])
        let (commandResult, commandError) = await registry.callTool(params: commandParams)
        XCTAssertNil(commandResult)
        XCTAssertEqual(commandError?.code, -32000)
        XCTAssertTrue(commandError?.message.contains("runCommand") == true)
    }

    func testUUIDParsingRunsAfterControlGate() async {
        let tools = HarnessDaemonTools(controlEnabled: { true })

        let (_, spawnError) = await tools.spawnSession(workspaceId: "not-a-uuid", cwd: nil, name: nil, shell: nil)
        XCTAssertEqual(spawnError?.code, -32602)
        XCTAssertEqual(spawnError?.message, "Invalid 'workspaceId' UUID")

        let valid = UUID().uuidString
        let (_, splitTabError) = await tools.splitPane(tabId: "not-a-uuid", paneId: valid, direction: "right", shell: nil)
        XCTAssertEqual(splitTabError?.code, -32602)
        XCTAssertEqual(splitTabError?.message, "Invalid 'tabId' UUID")

        let (_, splitPaneError) = await tools.splitPane(tabId: valid, paneId: "not-a-uuid", direction: "right", shell: nil)
        XCTAssertEqual(splitPaneError?.code, -32602)
        XCTAssertEqual(splitPaneError?.message, "Invalid 'paneId' UUID")

        let (_, closeError) = await tools.closePane(paneId: "not-a-uuid")
        XCTAssertEqual(closeError?.code, -32602)
        XCTAssertEqual(closeError?.message, "Invalid 'paneId' UUID")
    }

    func testSplitPaneDirectionMappingUsesLayoutSemantics() {
        // P15 step 4: the direction-string mapping moved to `CommandIPCTranslator` so
        // `harness.panes.split` (P11 PBI-SCRIPT-005) and this MCP tool agree on what
        // "right"/"left"/"up"/"down" mean.
        XCTAssertEqual(CommandIPCTranslator.layoutDirection(forPaneDirection: "right"), .horizontal)
        XCTAssertEqual(CommandIPCTranslator.layoutDirection(forPaneDirection: "left"), .horizontal)
        XCTAssertEqual(CommandIPCTranslator.layoutDirection(forPaneDirection: "up"), .vertical)
        XCTAssertEqual(CommandIPCTranslator.layoutDirection(forPaneDirection: "down"), .vertical)
        XCTAssertEqual(CommandIPCTranslator.layoutDirection(forPaneDirection: "RIGHT"), .horizontal)
        XCTAssertNil(CommandIPCTranslator.layoutDirection(forPaneDirection: "diagonal"))
    }

    func testToolRegistryRejectsNonStringKeys() async {
        let registry = ToolRegistry()
        let params: AnyCodable = .object([
            "name": .string("sendPaneKeys"),
            "arguments": .object([
                "surfaceId": .string("surface"),
                "keys": .array([.string("Enter"), .int(1)]),
            ]),
        ])
        let (result, error) = await registry.callTool(params: params)
        XCTAssertNil(result)
        XCTAssertEqual(error?.code, -32602)
        XCTAssertEqual(error?.message, "'keys' must be an array of strings")
    }

    private func temporaryDirectory() -> URL {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("HarnessMCPTests-\(UUID().uuidString)", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        temporaryDirectories.append(directory)
        return directory
    }

    private func writePolicy(_ json: String) throws -> URL {
        let url = temporaryDirectory().appendingPathComponent("mcp-policy.json")
        try json.write(to: url, atomically: true, encoding: .utf8)
        return url
    }
}
