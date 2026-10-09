import XCTest
@testable import KouenCore
import KouenIPC

final class RemoteControlURLProviderTests: XCTestCase {
    func testRemoteControlURLs() {
        XCTAssertEqual(RemoteControlURLProvider.url(for: .claudeCode)?.absoluteString, "https://claude.ai/code")
        XCTAssertEqual(RemoteControlURLProvider.url(for: .antigravity)?.absoluteString, "https://antigravity.google.com")
        XCTAssertEqual(RemoteControlURLProvider.url(for: .codex)?.absoluteString, "https://chatgpt.com")
        XCTAssertNil(RemoteControlURLProvider.url(for: .copilot))
    }
}
