#if canImport(Network)
import XCTest
@testable import KouenDaemonCore

final class MobileBridgeAgentCommandTests: XCTestCase {
    private func text(_ chunks: [Data]?) -> [String]? { chunks?.map { String(decoding: $0, as: UTF8.self) } }

    func testModelAndEffortTypeSlashCommandThenEnter() {
        XCTAssertEqual(text(MobileBridgeServer.agentCommandInput(kind: "model", value: "sonnet", currentMode: nil)), ["/model sonnet", "\r"])
        XCTAssertEqual(text(MobileBridgeServer.agentCommandInput(kind: "effort", value: "xhigh", currentMode: nil)), ["/effort xhigh", "\r"])
    }

    func testRejectsAnythingNotAllowlisted() {
        XCTAssertNil(MobileBridgeServer.agentCommandInput(kind: "model", value: "x\r!rm -rf", currentMode: nil))
        XCTAssertNil(MobileBridgeServer.agentCommandInput(kind: "effort", value: "ultra", currentMode: nil))
        XCTAssertNil(MobileBridgeServer.agentCommandInput(kind: "shell", value: "ls", currentMode: nil))
    }

    func testModeCountsShiftTabPressesAlongTheVerifiedCycle() {
        // manual -> acceptEdits -> plan -> auto -> manual
        XCTAssertEqual(MobileBridgeServer.agentCommandInput(kind: "mode", value: "plan", currentMode: "manual")?.count, 2)
        XCTAssertEqual(MobileBridgeServer.agentCommandInput(kind: "mode", value: "manual", currentMode: "auto")?.count, 1)
        XCTAssertEqual(MobileBridgeServer.agentCommandInput(kind: "mode", value: "auto", currentMode: "auto")?.count, 0)
        XCTAssertNil(MobileBridgeServer.agentCommandInput(kind: "mode", value: "plan", currentMode: "bypassPermissions"))
        XCTAssertNil(MobileBridgeServer.agentCommandInput(kind: "mode", value: "plan", currentMode: nil))
    }
}
#endif
