import XCTest
@testable import KouenDaemonCore

/// P37 Phase D1 (file preview). Drives `MobileBridgeServer.readFileInfo`/`.listDirectoryEntries`
/// directly — the pure path→response logic split out of the connection-bound WS handlers,
/// same "static, no live socket needed" shape `resolveSpawnedSurfaceID` uses in
/// `MobileBridgeSpawnTests`. Pure filesystem I/O against a temp dir, so unlike the spawn/focus
/// tests this needs no `SurfaceRegistry`/`KOUEN_LIVE_DAEMON_TESTS` gate.
final class MobileBridgeFilePreviewTests: XCTestCase {
    private var root: URL!

    override func setUpWithError() throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("kouen-mobile-file-preview-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        root = dir
    }

    override func tearDownWithError() throws {
        if let root { try? FileManager.default.removeItem(at: root) }
    }

    func testReadFileReturnsUTF8TextContent() throws {
        let path = root.appendingPathComponent("notes.txt")
        try "hello from kouen".write(to: path, atomically: true, encoding: .utf8)

        let info = try XCTUnwrap(MobileBridgeServer.readFileInfo(path: path.path))
        XCTAssertEqual(info.encoding, "utf8")
        XCTAssertEqual(info.content, "hello from kouen")
        XCTAssertEqual(info.mimeType, "text/plain")
        XCTAssertFalse(info.truncated)
    }

    func testReadFileReturnsBase64WithImageMimeForBinaryContent() throws {
        let path = root.appendingPathComponent("pixel.png")
        // Not a real PNG — just non-UTF8 bytes, which is all `readFileInfo`'s text/binary split
        // actually checks. A raw 0xFF byte is an invalid UTF-8 lead byte on its own.
        let bytes = Data([0xFF, 0xD8, 0xFF, 0x00, 0x01, 0x02])
        try bytes.write(to: path)

        let info = try XCTUnwrap(MobileBridgeServer.readFileInfo(path: path.path))
        XCTAssertEqual(info.encoding, "base64")
        XCTAssertEqual(info.mimeType, "image/png")
        XCTAssertEqual(Data(base64Encoded: info.content), bytes)
    }

    func testReadFileReturnsOctetStreamMimeForUnknownBinaryExtension() throws {
        let path = root.appendingPathComponent("blob.bin")
        try Data([0xFF, 0x00, 0xFE]).write(to: path)

        let info = try XCTUnwrap(MobileBridgeServer.readFileInfo(path: path.path))
        XCTAssertEqual(info.encoding, "base64")
        XCTAssertEqual(info.mimeType, "application/octet-stream")
    }

    func testReadFileReturnsNilForMissingPath() {
        XCTAssertNil(MobileBridgeServer.readFileInfo(path: root.appendingPathComponent("nope.txt").path))
    }

    func testReadFileReturnsNilForDirectory() {
        XCTAssertNil(MobileBridgeServer.readFileInfo(path: root.path))
    }

    func testListDirectoryReturnsSortedEntriesWithIsDirectoryFlag() throws {
        try "x".write(to: root.appendingPathComponent("b.txt"), atomically: true, encoding: .utf8)
        try "x".write(to: root.appendingPathComponent("a.txt"), atomically: true, encoding: .utf8)
        try FileManager.default.createDirectory(at: root.appendingPathComponent("sub"), withIntermediateDirectories: true)

        let entries = try XCTUnwrap(MobileBridgeServer.listDirectoryEntries(path: root.path))
        XCTAssertEqual(entries.map(\.name), ["a.txt", "b.txt", "sub"])
        XCTAssertEqual(entries.map(\.isDirectory), [false, false, true])
    }

    func testListDirectoryReturnsNilForMissingPath() {
        XCTAssertNil(MobileBridgeServer.listDirectoryEntries(path: root.appendingPathComponent("nope").path))
    }
}
