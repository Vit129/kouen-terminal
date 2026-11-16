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

    func test_TS_2341_BE_UT_graphifyLookupReparsesOnlyWhenMtimeChanges() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let dir = root.appendingPathComponent("graphify-out")
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let graph = dir.appendingPathComponent("graph.json")
        func write(_ rank: Double, mtime: Date) throws {
            let data = try JSONSerialization.data(withJSONObject: ["nodes": [["source_file": "a.swift", "pagerank": rank, "community": 1]]])
            try data.write(to: graph)
            try FileManager.default.setAttributes([.modificationDate: mtime], ofItemAtPath: graph.path)
        }
        let t0 = Date(timeIntervalSince1970: 1_700_000_000)
        try write(0.1, mtime: t0)
        XCTAssertEqual(GraphifyLSPBridge.lookupFileInfo(sourceFile: "a.swift", projectRoot: root)?.pagerank, 0.1)
        // Same mtime, different content: the cached index must be served (no re-parse).
        try write(0.2, mtime: t0)
        XCTAssertEqual(GraphifyLSPBridge.lookupFileInfo(sourceFile: "a.swift", projectRoot: root)?.pagerank, 0.1)
        try write(0.3, mtime: t0.addingTimeInterval(10))
        XCTAssertEqual(GraphifyLSPBridge.lookupFileInfo(sourceFile: "a.swift", projectRoot: root)?.pagerank, 0.3)
    }
}
