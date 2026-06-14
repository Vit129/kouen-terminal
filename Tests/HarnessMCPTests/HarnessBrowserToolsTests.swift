import XCTest
@testable import HarnessMCP
import HarnessCore

final class HarnessBrowserToolsTests: XCTestCase {
    private var temporaryDirectories: [URL] = []

    override func tearDownWithError() throws {
        for directory in temporaryDirectories {
            try? FileManager.default.removeItem(at: directory)
        }
        temporaryDirectories.removeAll()
        try super.tearDownWithError()
    }

    func testControlGateBlocksMutatingBrowserTools() async {
        let tools = HarnessBrowserTools(isToolAllowed: { _ in false }, disabledError: { name in
            JSONRPCError(code: -32000, message: "Disabled: \(name)")
        })

        // Test Open is blocked
        let (openRes, openErr) = await tools.harnessBrowserOpen(urlStr: "https://example.com", directionStr: nil)
        XCTAssertNil(openRes)
        XCTAssertEqual(openErr?.message, "Disabled: harnessBrowserOpen")

        // Test Navigate is blocked
        let (navRes, navErr) = await tools.harnessBrowserNavigate(paneIdStr: UUID().uuidString, urlStr: "https://example.com")
        XCTAssertNil(navRes)
        XCTAssertEqual(navErr?.message, "Disabled: harnessBrowserNavigate")

        // Test Wait is blocked
        let (waitRes, waitErr) = await tools.harnessBrowserWait(paneIdStr: UUID().uuidString, timeoutSeconds: 5.0)
        XCTAssertNil(waitRes)
        XCTAssertEqual(waitErr?.message, "Disabled: harnessBrowserWait")

        // Test Interact is blocked
        let (intRes, intErr) = await tools.harnessBrowserInteract(paneIdStr: UUID().uuidString, action: "click", elementId: "e1", text: nil)
        XCTAssertNil(intRes)
        XCTAssertEqual(intErr?.message, "Disabled: harnessBrowserInteract")

        // Test Close is blocked
        let (closeRes, closeErr) = await tools.harnessBrowserClose(paneIdStr: UUID().uuidString)
        XCTAssertNil(closeRes)
        XCTAssertEqual(closeErr?.message, "Disabled: harnessBrowserClose")
    }

    func testSnapshotIsReadOnlyAndAllowedByDefault() async {
        let missingPolicyURL = temporaryDirectory().appendingPathComponent("missing-policy.json")
        let policy = ToolPolicy.load(from: missingPolicyURL, environment: [:])
        
        // harnessBrowserSnapshot should be allowed since it's read-only
        XCTAssertTrue(policy.isToolAllowed("harnessBrowserSnapshot"))
        
        // Mutating tools should be blocked by default
        XCTAssertFalse(policy.isToolAllowed("harnessBrowserOpen"))
        XCTAssertFalse(policy.isToolAllowed("harnessBrowserNavigate"))
        XCTAssertFalse(policy.isToolAllowed("harnessBrowserWait"))
        XCTAssertFalse(policy.isToolAllowed("harnessBrowserInteract"))
        XCTAssertFalse(policy.isToolAllowed("harnessBrowserClose"))
    }

    private func temporaryDirectory() -> URL {
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        temporaryDirectories.append(url)
        return url
    }
}
