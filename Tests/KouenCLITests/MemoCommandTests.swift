import XCTest
@testable import KouenCLI
import KouenCore

final class MemoCommandTests: XCTestCase {
    private var testDir: URL!

    override func setUpWithError() throws {
        testDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: testDir, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: testDir)
    }

    func testMemoJsonSerialization() throws {
        let memoURL = testDir.appendingPathComponent("memo.json")
        var map: [String: String] = ["agent_status": "waiting_approval", "last_commit": "abc1234"]

        let data = try JSONSerialization.data(withJSONObject: map, options: [.prettyPrinted, .sortedKeys])
        try data.write(to: memoURL)

        let loadedData = try Data(contentsOf: memoURL)
        let loadedMap = try JSONSerialization.jsonObject(with: loadedData) as? [String: String]

        XCTAssertEqual(loadedMap?["agent_status"], "waiting_approval")
        XCTAssertEqual(loadedMap?["last_commit"], "abc1234")

        map.removeValue(forKey: "agent_status")
        let updatedData = try JSONSerialization.data(withJSONObject: map, options: [.prettyPrinted, .sortedKeys])
        try updatedData.write(to: memoURL)

        let reloadedData = try Data(contentsOf: memoURL)
        let reloadedMap = try JSONSerialization.jsonObject(with: reloadedData) as? [String: String]
        XCTAssertNil(reloadedMap?["agent_status"])
        XCTAssertEqual(reloadedMap?["last_commit"], "abc1234")
    }
}
