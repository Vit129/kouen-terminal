import AppKit
import XCTest
@testable import HarnessTerminalKit

final class HarnessTerminalSurfaceDragDropTests: XCTestCase {
    @MainActor
    func testDroppedFileURLsAcceptFoldersAndImages() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("HarnessTerminalSurfaceDragDropTests-\(UUID().uuidString)", isDirectory: true)
        let folder = root.appendingPathComponent("Folder With Spaces", isDirectory: true)
        let image = root.appendingPathComponent("image file.png")
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        try Data([0x89, 0x50, 0x4e, 0x47]).write(to: image)
        defer { try? FileManager.default.removeItem(at: root) }

        let pasteboard = NSPasteboard(name: NSPasteboard.Name("HarnessDragDrop-\(UUID().uuidString)"))
        pasteboard.clearContents()
        XCTAssertTrue(pasteboard.writeObjects([folder as NSURL, image as NSURL]))

        let urls = HarnessTerminalSurfaceView.droppedFileURLs(from: pasteboard)

        XCTAssertEqual(urls.map(\.path), [folder.path, image.path])
    }

    @MainActor
    func testDroppedFileURLsAcceptLegacyFinderFilenames() {
        let pasteboard = NSPasteboard(name: NSPasteboard.Name("HarnessDragDropLegacy-\(UUID().uuidString)"))
        let filenamesType = NSPasteboard.PasteboardType("NSFilenamesPboardType")
        pasteboard.clearContents()
        pasteboard.declareTypes([filenamesType], owner: nil)
        pasteboard.setPropertyList(["/tmp/Harness Folder", "/tmp/Harness Folder"], forType: filenamesType)

        let urls = HarnessTerminalSurfaceView.droppedFileURLs(from: pasteboard)

        XCTAssertEqual(urls.map(\.path), ["/tmp/Harness Folder"])
    }

    @MainActor
    func testDroppedPathTextQuotesShellUnsafePaths() {
        let urls = [
            URL(fileURLWithPath: "/tmp/plain-file.png"),
            URL(fileURLWithPath: "/tmp/My Folder/it's final.png"),
        ]

        XCTAssertEqual(
            HarnessTerminalSurfaceView.droppedPathText(for: urls),
            "/tmp/plain-file.png '/tmp/My Folder/it'\\''s final.png'"
        )
    }
}
