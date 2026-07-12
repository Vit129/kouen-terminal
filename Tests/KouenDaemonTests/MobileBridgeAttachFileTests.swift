import XCTest
@testable import KouenCore
@testable import KouenDaemonCore

/// P37 Phase D2 (file/image attach). Drives `MobileBridgeServer.writeAttachedFile` directly —
/// same "pure static, no live socket needed" shape `readFileInfo`/`listDirectoryEntries` use in
/// `MobileBridgeFilePreviewTests`. Isolates `KOUEN_HOME` (same pattern as `MobileBridgeSpawnTests`)
/// since `writeAttachedFile` writes through `KouenPaths.pastedImagesDirectory`, which reads it.
final class MobileBridgeAttachFileTests: XCTestCase {
    private var root: URL?
    private var previousHome: String?

    override func setUpWithError() throws {
        previousHome = getenv("KOUEN_HOME").map { String(cString: $0) }
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("kouen-mobile-attach-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        root = dir
        setenv("KOUEN_HOME", dir.path, 1)
    }

    override func tearDownWithError() throws {
        if let previousHome { setenv("KOUEN_HOME", previousHome, 1) } else { unsetenv("KOUEN_HOME") }
        if let root { try? FileManager.default.removeItem(at: root) }
    }

    func testWriteAttachedFilePreservesExtensionAndContent() throws {
        let bytes = Data("hello from phone".utf8)
        let path = try XCTUnwrap(MobileBridgeServer.writeAttachedFile(name: "notes.txt", data: bytes))
        XCTAssertTrue(path.hasSuffix(".txt"))
        XCTAssertEqual(try Data(contentsOf: URL(fileURLWithPath: path)), bytes)
    }

    func testWriteAttachedFileOmitsExtensionWhenNameHasNone() throws {
        let path = try XCTUnwrap(MobileBridgeServer.writeAttachedFile(name: "README", data: Data("x".utf8)))
        XCTAssertFalse((path as NSString).lastPathComponent.contains("."))
    }

    /// A malicious `name` can only ever contribute its extension — `pathExtension` on
    /// `"../../etc/passwd"` is empty, so this writes an extension-less file inside the sandbox
    /// directory, never escapes it via `../`.
    func testWriteAttachedFileIgnoresPathComponentsInName() throws {
        let path = try XCTUnwrap(MobileBridgeServer.writeAttachedFile(name: "../../etc/passwd", data: Data("x".utf8)))
        XCTAssertTrue(path.hasPrefix(KouenPaths.pastedImagesDirectory.path))
        XCTAssertFalse(path.contains(".."))
    }

    func testWriteAttachedFileSetsReadablePermissions() throws {
        let path = try XCTUnwrap(MobileBridgeServer.writeAttachedFile(name: "pixel.png", data: Data([0xFF, 0x00])))
        let attrs = try FileManager.default.attributesOfItem(atPath: path)
        XCTAssertEqual((attrs[.posixPermissions] as? NSNumber)?.intValue, 0o644)
    }

    /// Exercises the prune-on-write path indirectly (it's a private implementation detail of
    /// `writeAttachedFile`, same reasoning D1 keeps `handleReadFile`'s internals private) — an
    /// old file present before a write must be gone after it.
    func testWriteAttachedFilePrunesFilesOlderThan24h() throws {
        let dir = KouenPaths.pastedImagesDirectory
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let staleURL = dir.appendingPathComponent("attached-stale-old.txt")
        try Data("stale".utf8).write(to: staleURL)
        let twoDaysAgo = Date().addingTimeInterval(-2 * 24 * 60 * 60)
        try FileManager.default.setAttributes([.modificationDate: twoDaysAgo], ofItemAtPath: staleURL.path)

        _ = try XCTUnwrap(MobileBridgeServer.writeAttachedFile(name: "fresh.txt", data: Data("fresh".utf8)))

        XCTAssertFalse(FileManager.default.fileExists(atPath: staleURL.path), "a 24h+ old attached file must be pruned on the next write")
    }
}
