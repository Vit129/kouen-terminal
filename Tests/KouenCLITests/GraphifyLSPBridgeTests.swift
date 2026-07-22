import XCTest
import KouenLSP

final class GraphifyLSPBridgeTests: XCTestCase {
    private func makeProjectWithGraph(nodes: [[String: Any]]) -> URL {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let graphDir = root.appendingPathComponent("graphify-out")
        try? FileManager.default.createDirectory(at: graphDir, withIntermediateDirectories: true)
        let json = ["nodes": nodes]
        let data = try! JSONSerialization.data(withJSONObject: json)
        try! data.write(to: graphDir.appendingPathComponent("graph.json"))
        return root
    }

    func testLookupFileInfoFindsMatchingNode() {
        let root = makeProjectWithGraph(nodes: [
            ["source_file": "Sources/Foo.swift", "pagerank": 0.001234, "community": 5],
            ["source_file": "Sources/Bar.swift", "pagerank": 0.005, "community": 2],
        ])
        defer { try? FileManager.default.removeItem(at: root) }

        let info = GraphifyLSPBridge.lookupFileInfo(sourceFile: "Sources/Foo.swift", projectRoot: root)
        XCTAssertEqual(info?.pagerank, 0.001234)
        XCTAssertEqual(info?.community, 5)
    }

    func testLookupFileInfoReturnsNilForUnknownFile() {
        let root = makeProjectWithGraph(nodes: [
            ["source_file": "Sources/Foo.swift", "pagerank": 0.001, "community": 1],
        ])
        defer { try? FileManager.default.removeItem(at: root) }

        XCTAssertNil(GraphifyLSPBridge.lookupFileInfo(sourceFile: "Sources/Missing.swift", projectRoot: root))
    }

    func testLookupFileInfoReturnsNilWhenGraphMissing() {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        XCTAssertNil(GraphifyLSPBridge.lookupFileInfo(sourceFile: "Sources/Foo.swift", projectRoot: root))
    }

    func testRunReturnsNilWhenBinaryMissing() {
        let cwd = FileManager.default.temporaryDirectory
        let output = GraphifyLSPBridge.run(
            "explain", arguments: ["Foo"], cwd: cwd,
            binaryPath: "/definitely/not/a/real/binary-\(UUID().uuidString)"
        )
        XCTAssertNil(output)
    }
}
