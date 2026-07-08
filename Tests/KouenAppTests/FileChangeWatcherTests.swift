import XCTest
@testable import KouenApp

/// Regression test for the QuickLook self-triggered flicker loop: QuickLook writes a
/// `com.apple.lastuseddate#PS` xattr on every render, which is an attrib-only change.
/// If the watcher reacted to `.attrib` it would reload -> re-render -> re-write the
/// xattr -> reload again, forever. Only real content changes should fire `onChange`.
final class FileChangeWatcherTests: XCTestCase {
    @MainActor
    func testAttribOnlyChangeDoesNotTriggerReloadButWriteDoes() async throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("file-change-watcher-\(UUID().uuidString).txt")
        try Data("hello".utf8).write(to: url)
        defer { try? FileManager.default.removeItem(at: url) }

        var changeCount = 0
        let watcher = FileChangeWatcher(debounceInterval: 0.05)
        watcher.start(path: url.path) { changeCount += 1 }

        let xattrResult = url.path.withCString { path in
            setxattr(path, "com.apple.test.attribonly", "x", 1, 0, 0)
        }
        XCTAssertEqual(xattrResult, 0, "setxattr failed: \(String(cString: strerror(errno)))")
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertEqual(changeCount, 0, "attrib-only xattr write must not trigger reload")

        try Data("hello world".utf8).write(to: url)
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertEqual(changeCount, 1, "actual content write must trigger reload")

        watcher.stop()
    }
}
