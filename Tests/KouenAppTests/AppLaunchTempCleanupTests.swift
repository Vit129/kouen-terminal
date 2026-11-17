import Foundation
import XCTest
@testable import KouenApp

@MainActor
final class AppLaunchTempCleanupTests: XCTestCase {
    func test_TS_2310_BE_UT_removesOnlyStaleKouenTemporaryFiles() throws {
        let repo = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        let directory = repo.appendingPathComponent(".tmp/temp-cleanup-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        let old = directory.appendingPathComponent("kouen-output-old.spool")
        let otherOld = ["kouen-attach-old.spool", "kouen-history-old.spool", "kouen-browser-old.log"].map { directory.appendingPathComponent($0) }
        let fresh = directory.appendingPathComponent("kouen-browser-live.log")
        let unrelated = directory.appendingPathComponent("other-old.spool")
        let matchingDirectory = directory.appendingPathComponent("kouen-history-dir.spool", isDirectory: true)
        let target = directory.appendingPathComponent("preserve-target")
        let link = directory.appendingPathComponent("kouen-attach-link.spool")
        for url in [old, fresh, unrelated] + otherOld { XCTAssertTrue(FileManager.default.createFile(atPath: url.path, contents: Data())) }
        try FileManager.default.createDirectory(at: matchingDirectory, withIntermediateDirectories: false)
        XCTAssertTrue(FileManager.default.createFile(atPath: target.path, contents: Data()))
        try FileManager.default.createSymbolicLink(at: link, withDestinationURL: target)
        let oldDate = Date(timeIntervalSince1970: 1)
        let processStart = Date(timeIntervalSince1970: 2)
        try FileManager.default.setAttributes([.modificationDate: oldDate], ofItemAtPath: old.path)
        for url in otherOld { try FileManager.default.setAttributes([.modificationDate: oldDate], ofItemAtPath: url.path) }
        try FileManager.default.setAttributes([.modificationDate: processStart.addingTimeInterval(1)], ofItemAtPath: fresh.path)
        try FileManager.default.setAttributes([.modificationDate: oldDate], ofItemAtPath: unrelated.path)

        StaleTemporaryFileSweeper.sweep(in: directory, processStart: processStart, hasOtherProducer: { true }, log: { _ in })
        XCTAssertTrue(FileManager.default.fileExists(atPath: old.path), "a possible live producer must prevent deletion")
        StaleTemporaryFileSweeper.sweep(in: directory, processStart: processStart, hasOtherProducer: { false }, log: { message in XCTFail(message) })

        XCTAssertFalse(FileManager.default.fileExists(atPath: old.path))
        for url in otherOld { XCTAssertFalse(FileManager.default.fileExists(atPath: url.path)) }
        XCTAssertTrue(FileManager.default.fileExists(atPath: fresh.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: unrelated.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: link.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: target.path))
        var isDirectory: ObjCBool = false
        XCTAssertTrue(FileManager.default.fileExists(atPath: matchingDirectory.path, isDirectory: &isDirectory))
        XCTAssertTrue(isDirectory.boolValue)
    }

    func test_TS_2310_BE_UT_usesTheCurrentProcessStartTime() {
        let processStart = StaleTemporaryFileSweeper.processStartDate()
        XCTAssertNotNil(processStart)
        XCTAssertLessThanOrEqual(processStart ?? .distantFuture, Date())
    }
}
