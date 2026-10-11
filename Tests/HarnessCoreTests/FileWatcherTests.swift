import Foundation
import XCTest
@testable import HarnessCore

final class FileWatcherTests: XCTestCase {
    func testCreationInPlaceWritesAtomicReplacementAndDeletion() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("harness-watch-" + UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appendingPathComponent("settings.json")
        let changes = expectation(description: "create, write in place, replace, write in place and delete")
        changes.expectedFulfillmentCount = 5
        let queue = DispatchQueue(label: "com.harness.filewatcher.test")
        let watcher = FileWatcher(url: url, debounce: .milliseconds(0), callbackQueue: queue) {
            changes.fulfill()
            do {
                guard let bytes = try PrivateFile.read(url) else { return }
                switch String(decoding: bytes, as: UTF8.self) {
                case "first", "third":
                    let file = try FileHandle(forWritingTo: url)
                    defer { try? file.close() }
                    try file.truncate(atOffset: 0)
                    try file.write(contentsOf: Data(bytes == Data("first".utf8) ? "second".utf8 : "fourth".utf8))
                case "second": try Data("third".utf8).write(to: url, options: .atomic)
                default: try FileManager.default.removeItem(at: url)
                }
            } catch { XCTFail(error.localizedDescription) }
        }
        try Data("first".utf8).write(to: url, options: .atomic)
        wait(for: [changes], timeout: 12)
        withExtendedLifetime(watcher) {}
    }
}
