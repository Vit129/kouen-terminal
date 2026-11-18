import XCTest
import KouenLSP

final class LSPLifecycleTests: XCTestCase {
    /// `/bin/cat` echoes frames back and never answers `shutdown` with a response, so this
    /// proves shutdown gives up after its timeout and still reaps the process.
    func test_TS_2340_BE_UT_lspShutdownTimesOutOnUnresponsiveServer() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let client = LSPClient()
        try await client.launch(configuration: LSPServerConfiguration(
            language: "test", executablePath: "/bin/cat", arguments: [], rootURL: root))
        let start = Date()
        await client.shutdown(timeout: .milliseconds(300))
        XCTAssertLessThan(Date().timeIntervalSince(start), 3)
        do {
            _ = try await client.request(method: "x", params: nil)
            XCTFail("request after shutdown must fail")
        } catch {
            XCTAssertEqual(error as? LSPClientError, .processNotRunning)
        }
    }
}
