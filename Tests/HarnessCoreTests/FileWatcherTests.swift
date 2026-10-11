import Foundation
import XCTest
@testable import HarnessCore

final class FileWatcherTests: XCTestCase {
    private final class Observations: @unchecked Sendable {
        // Accessed only on the callback queue, including the final assertion read.
        var values: Set<String> = []
        var errors: [String] = []
        var finished = false
    }

    func testCreationInPlaceWritesAtomicReplacementAndDeletion() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("harness-watch-" + UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appendingPathComponent("settings.json")
        let changes = expectation(description: "observe all mutations through deletion")
        let observations = Observations()
        let queue = DispatchQueue(label: "com.harness.filewatcher.test")
        let watcher = FileWatcher(url: url, debounce: .milliseconds(0), callbackQueue: queue) {
            guard !observations.finished else { return }
            do {
                guard let bytes = try PrivateFile.read(url) else {
                    guard observations.values.contains("fourth") else { return }
                    observations.values.insert("deleted")
                    observations.finished = true
                    changes.fulfill()
                    return
                }
                let value = String(decoding: bytes, as: UTF8.self)
                // Vnode events may be coalesced or delivered more than once.
                guard observations.values.insert(value).inserted else { return }
                switch value {
                case "first", "third":
                    let file = try FileHandle(forWritingTo: url)
                    defer { try? file.close() }
                    try file.truncate(atOffset: 0)
                    try file.write(contentsOf: Data(bytes == Data("first".utf8) ? "second".utf8 : "fourth".utf8))
                case "second": try Data("third".utf8).write(to: url, options: .atomic)
                case "fourth": try FileManager.default.removeItem(at: url)
                default: throw NSError(domain: "FileWatcherTests", code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Unexpected file contents: \(value)"])
                }
            } catch {
                observations.errors.append(error.localizedDescription)
                observations.finished = true
                changes.fulfill()
            }
        }
        try Data("first".utf8).write(to: url, options: .atomic)
        wait(for: [changes], timeout: 12)
        // Fulfillment and the filesystem mutation must finish before fixture cleanup;
        // queued callbacks after completion cannot mutate files or call XCTest.
        let result = queue.sync {
            observations.finished = true
            return (observations.errors, observations.values)
        }
        XCTAssertTrue(result.0.isEmpty, result.0.joined(separator: ", "))
        XCTAssertEqual(result.1, ["first", "second", "third", "fourth", "deleted"])
        withExtendedLifetime(watcher) {}
    }
}
