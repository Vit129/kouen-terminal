import AppKit
import XCTest
import KouenTerminalEngine
@testable import KouenTerminalKit

final class KouenTerminalSurfaceDragDropTests: XCTestCase {
    @MainActor
    func testDroppedFileURLsAcceptFoldersAndImages() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("KouenTerminalSurfaceDragDropTests-\(UUID().uuidString)", isDirectory: true)
        let folder = root.appendingPathComponent("Folder With Spaces", isDirectory: true)
        let image = root.appendingPathComponent("image file.png")
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        try Data([0x89, 0x50, 0x4e, 0x47]).write(to: image)
        defer { try? FileManager.default.removeItem(at: root) }

        let pasteboard = NSPasteboard(name: NSPasteboard.Name("KouenDragDrop-\(UUID().uuidString)"))
        pasteboard.clearContents()
        XCTAssertTrue(pasteboard.writeObjects([folder as NSURL, image as NSURL]))

        let urls = KouenTerminalSurfaceView.droppedFileURLs(from: pasteboard)

        XCTAssertEqual(urls.map(\.path), [folder.path, image.path])
    }

    @MainActor
    func testDroppedFileURLsAcceptLegacyFinderFilenames() {
        let pasteboard = NSPasteboard(name: NSPasteboard.Name("KouenDragDropLegacy-\(UUID().uuidString)"))
        let filenamesType = NSPasteboard.PasteboardType("NSFilenamesPboardType")
        pasteboard.clearContents()
        pasteboard.declareTypes([filenamesType], owner: nil)
        pasteboard.setPropertyList(["/tmp/Kouen Folder", "/tmp/Kouen Folder"], forType: filenamesType)

        let urls = KouenTerminalSurfaceView.droppedFileURLs(from: pasteboard)

        XCTAssertEqual(urls.map(\.path), ["/tmp/Kouen Folder"])
    }

    @MainActor
    func testDroppedPathTextQuotesShellUnsafePaths() {
        let urls = [
            URL(fileURLWithPath: "/tmp/plain-file.png"),
            URL(fileURLWithPath: "/tmp/My Folder/it's final.png"),
        ]

        XCTAssertEqual(
            KouenTerminalSurfaceView.droppedPathText(for: urls),
            "/tmp/plain-file.png '/tmp/My Folder/it'\\''s final.png'"
        )
    }

    // MARK: - Image paste (screenshot on the clipboard)

    @MainActor
    func testPasteImageWritesDecodablePNGAndReturnsPath() throws {
        // A real, decodable PNG on the clipboard — exactly what a screenshot (⌘⇧4) produces.
        let rep = NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: 4, pixelsHigh: 4,
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
        )!
        let png = try XCTUnwrap(rep.representation(using: .png, properties: [:]))

        let pasteboard = NSPasteboard(name: NSPasteboard.Name("KouenPasteImage-\(UUID().uuidString)"))
        pasteboard.clearContents()
        pasteboard.setData(png, forType: .png)

        let path = try XCTUnwrap(KouenTerminalSurfaceView.writePastedImage(from: pasteboard))
        defer { try? FileManager.default.removeItem(atPath: path) }

        XCTAssertTrue(path.hasSuffix(".png"))
        XCTAssertTrue(path.contains("/pasted-images/"))
        let written = try Data(contentsOf: URL(fileURLWithPath: path))
        XCTAssertNotNil(ImageDecoder.decode(written), "the written file should be a decodable image")
    }

    @MainActor
    func testPasteImageWritesReadableHandoffPath() throws {
        let rep = NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: 2, pixelsHigh: 2,
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
        )!
        let png = try XCTUnwrap(rep.representation(using: .png, properties: [:]))

        let pasteboard = NSPasteboard(name: NSPasteboard.Name("KouenPasteReadableImage-\(UUID().uuidString)"))
        pasteboard.clearContents()
        pasteboard.setData(png, forType: .png)

        let path = try XCTUnwrap(KouenTerminalSurfaceView.writePastedImage(from: pasteboard))
        defer { try? FileManager.default.removeItem(atPath: path) }

        let dirPath = URL(fileURLWithPath: path).deletingLastPathComponent().path
        let fileAttributes = try FileManager.default.attributesOfItem(atPath: path)
        let dirAttributes = try FileManager.default.attributesOfItem(atPath: dirPath)
        let fileMode = try XCTUnwrap(fileAttributes[.posixPermissions] as? NSNumber)
        let dirMode = try XCTUnwrap(dirAttributes[.posixPermissions] as? NSNumber)
        XCTAssertEqual(fileMode.intValue & 0o777, 0o644)
        XCTAssertEqual(dirMode.intValue & 0o777, 0o755)
    }

    @MainActor
    func testPasteImageReturnsNilForNonImageClipboard() {
        let pasteboard = NSPasteboard(name: NSPasteboard.Name("KouenPasteNoImage-\(UUID().uuidString)"))
        pasteboard.clearContents()
        pasteboard.setString("just text", forType: .string)
        XCTAssertNil(KouenTerminalSurfaceView.writePastedImage(from: pasteboard))
    }
}
