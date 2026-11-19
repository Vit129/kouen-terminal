import Foundation
import XCTest
@testable import KouenCore

final class AgentHistoryStorageLimitsTests: XCTestCase {
    func test_TS_8900_BE_UT_SpoolRefusesOverBudgetAndReleasesCapacity() throws {
        let temp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: temp, withIntermediateDirectories: false)
        defer { try? FileManager.default.removeItem(at: temp) }
        let directory = try AgentHistoryTranscriptSpool.prepareDirectory(in: temp)
        let budget = AgentHistoryTranscriptSpool.Budget(perSpool: 5, total: 8)
        var first: AgentHistoryTranscriptSpool? = try AgentHistoryTranscriptSpool(budget: budget, directory: directory)
        let second = try AgentHistoryTranscriptSpool(budget: budget, directory: directory)
        try first?.append("éabc")
        XCTAssertThrowsError(try first?.append("x"))
        try second.append("abc")
        XCTAssertThrowsError(try second.append("d"))

        first = nil
        try second.append("d")
        var chunks: [String] = []
        try second.forEachChunk { chunks.append($0) }
        XCTAssertEqual(chunks, ["abcd"])
    }

    func test_TS_8901_BE_IT_SweepStaysInsideDedicatedDirectory() throws {
        let temp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: temp, withIntermediateDirectories: false)
        defer { try? FileManager.default.removeItem(at: temp) }
        let directory = try AgentHistoryTranscriptSpool.prepareDirectory(in: temp)
        let old = Date(timeIntervalSince1970: 100)
        let name = "kouen-history-\(UUID().uuidString).spool"
        let stale = directory.appendingPathComponent(name)
        let outside = temp.appendingPathComponent(name)
        let symlink = directory.appendingPathComponent("kouen-history-\(UUID().uuidString).spool")
        let fresh = directory.appendingPathComponent("kouen-history-\(UUID().uuidString).spool")
        let live = try AgentHistoryTranscriptSpool(
            budget: .init(perSpool: 5, total: 5), directory: directory
        )
        let liveName = try XCTUnwrap(FileManager.default.contentsOfDirectory(atPath: directory.path).first)
        let livePath = directory.appendingPathComponent(liveName)
        for url in [stale, outside, fresh] { try Data([1]).write(to: url) }
        for url in [stale, outside, livePath] {
            try FileManager.default.setAttributes([.modificationDate: old], ofItemAtPath: url.path)
        }
        try FileManager.default.createSymbolicLink(at: symlink, withDestinationURL: outside)

        AgentHistoryTranscriptSpool.sweepStale(in: temp, directory: temp, olderThan: Date())
        XCTAssertEqual(try Data(contentsOf: outside), Data([1]))
        AgentHistoryTranscriptSpool.sweepStale(in: temp, directory: directory, olderThan: old.addingTimeInterval(1))
        XCTAssertFalse(FileManager.default.fileExists(atPath: stale.path))
        for url in [outside, symlink, fresh, livePath] {
            XCTAssertTrue(FileManager.default.fileExists(atPath: url.path), url.path)
        }
        withExtendedLifetime(live) {}
    }

    #if canImport(SQLite3)
    func test_TS_8902_BE_IT_FTSPrunesOldestBeforeNewerEntries() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: false)
        defer { try? FileManager.default.removeItem(at: directory) }
        let path = directory.appendingPathComponent("history.sqlite").path
        func index(_ id: String, time: Double, using index: AgentHistoryFTSIndex) {
            let payload = String(repeating: "\(id) ", count: 10_000)
            index.indexSession(
                sessionID: id, title: id, firstPrompt: "", fullTranscript: payload,
                gitBranch: nil, repoName: "", agentName: "", filesEdited: "", toolsCalled: "",
                transcriptPath: "/fixture/\(id)", mtime: Date(timeIntervalSince1970: time), fileSize: payload.utf8.count
            )
        }
        do {
            let seed = AgentHistoryFTSIndex(dbPath: path)
            index("newest", time: 30, using: seed)
            index("oldest", time: 10, using: seed)
            index("middle", time: 20, using: seed)
            XCTAssertEqual(Set(seed.search(query: "newest middle oldest").keys), ["oldest", "middle", "newest"])
        }
        let databaseURL = URL(fileURLWithPath: path)
        let seededSize = try Data(contentsOf: databaseURL).count
        // Force eviction with this SQLite build's actual page and schema overhead.
        let limit = seededSize - 1
        let bounded = AgentHistoryFTSIndex(dbPath: path, maximumIndexBytes: limit)
        XCTAssertEqual(Set(bounded.search(query: "newest middle oldest").keys), ["middle", "newest"])
        index("staler", time: 5, using: bounded)
        XCTAssertEqual(Set(bounded.search(query: "newest middle staler").keys), ["middle", "newest"])
        XCTAssertTrue(bounded.needsReindex(sessionID: "oldest", mtime: Date(timeIntervalSince1970: 10), fileSize: 70_000))
        XCTAssertLessThanOrEqual(try Data(contentsOf: databaseURL).count, limit)
    }
    #endif
}
