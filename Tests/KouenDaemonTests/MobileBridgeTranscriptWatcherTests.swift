import Foundation
import XCTest
@testable import KouenDaemonCore

/// The transcript tail reads only when the file changes (no 1s poll). These prove the watcher
/// fires on an append straight away and leaves no fd behind once cancelled.
final class MobileBridgeTranscriptWatcherTests: XCTestCase {
    func testAppendFiresEventAndCancelClosesFD() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("watcher-\(UUID().uuidString).jsonl")
        try Data("{}\n".utf8).write(to: url)
        defer { try? FileManager.default.removeItem(at: url) }

        let queue = DispatchQueue(label: "test.transcript-watcher")
        let fired = expectation(description: "append produced an event")
        fired.assertForOverFulfill = false
        let watcher = try XCTUnwrap(TranscriptFileWatcher(url: url, queue: queue) { event in
            if !event.isDisjoint(with: [.write, .extend]) { fired.fulfill() }
        })
        let fd = watcher.fd
        XCTAssertNotEqual(fcntl(fd, F_GETFD), -1, "fd is open while watching")

        let handle = try FileHandle(forWritingTo: url)
        try handle.seekToEnd()
        try handle.write(contentsOf: Data("{\"a\":1}\n".utf8))
        try handle.close()
        wait(for: [fired], timeout: 1.0) // well under the 5s slow timer

        watcher.cancel()
        queue.sync {} // cancel handler runs on `queue`; drain it
        XCTAssertEqual(fcntl(fd, F_GETFD), -1, "fd closed after cancel")
    }

    func testMissingFileReturnsNil() {
        let url = URL(fileURLWithPath: "/nonexistent/\(UUID().uuidString).jsonl")
        XCTAssertNil(TranscriptFileWatcher(url: url, queue: .main) { _ in })
    }
}
