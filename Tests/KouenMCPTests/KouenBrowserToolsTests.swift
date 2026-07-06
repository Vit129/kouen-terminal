import XCTest
@testable import KouenMCP
import KouenCore

final class KouenBrowserToolsTests: XCTestCase {
    private var temporaryDirectories: [URL] = []

    override func tearDownWithError() throws {
        for directory in temporaryDirectories {
            try? FileManager.default.removeItem(at: directory)
        }
        temporaryDirectories.removeAll()
        try super.tearDownWithError()
    }

    func testControlGateBlocksMutatingBrowserTools() async {
        let tools = KouenBrowserTools(isToolAllowed: { _ in false }, disabledError: { name in
            JSONRPCError(code: -32000, message: "Disabled: \(name)")
        })

        // Test Open is blocked
        let (openRes, openErr) = await tools.kouenBrowserOpen(urlStr: "https://example.com", directionStr: nil)
        XCTAssertNil(openRes)
        XCTAssertEqual(openErr?.message, "Disabled: kouenBrowserOpen")

        // Test Navigate is blocked
        let (navRes, navErr) = await tools.kouenBrowserNavigate(paneIdStr: UUID().uuidString, urlStr: "https://example.com")
        XCTAssertNil(navRes)
        XCTAssertEqual(navErr?.message, "Disabled: kouenBrowserNavigate")

        // Test Wait is blocked
        let (waitRes, waitErr) = await tools.kouenBrowserWait(paneIdStr: UUID().uuidString, timeoutSeconds: 5.0)
        XCTAssertNil(waitRes)
        XCTAssertEqual(waitErr?.message, "Disabled: kouenBrowserWait")

        // Test Interact is blocked
        let (intRes, intErr) = await tools.kouenBrowserInteract(paneIdStr: UUID().uuidString, action: "click", elementId: "e1", text: nil)
        XCTAssertNil(intRes)
        XCTAssertEqual(intErr?.message, "Disabled: kouenBrowserInteract")

        // Test Close is blocked
        let (closeRes, closeErr) = await tools.kouenBrowserClose(paneIdStr: UUID().uuidString)
        XCTAssertNil(closeRes)
        XCTAssertEqual(closeErr?.message, "Disabled: kouenBrowserClose")
    }

    func testSnapshotIsReadOnlyAndAllowedByDefault() async {
        let missingPolicyURL = temporaryDirectory().appendingPathComponent("missing-policy.json")
        let policy = ToolPolicy.load(from: missingPolicyURL, environment: [:])
        
        // kouenBrowserSnapshot should be allowed since it's read-only
        XCTAssertTrue(policy.isToolAllowed("kouenBrowserSnapshot"))
        
        // Mutating tools should be blocked by default
        XCTAssertFalse(policy.isToolAllowed("kouenBrowserOpen"))
        XCTAssertFalse(policy.isToolAllowed("kouenBrowserNavigate"))
        XCTAssertFalse(policy.isToolAllowed("kouenBrowserWait"))
        XCTAssertFalse(policy.isToolAllowed("kouenBrowserInteract"))
        XCTAssertFalse(policy.isToolAllowed("kouenBrowserClose"))
    }

    private func temporaryDirectory() -> URL {
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        temporaryDirectories.append(url)
        return url
    }
}
