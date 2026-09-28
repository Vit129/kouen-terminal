import XCTest
@testable import KouenApp

final class HandoffDirectoryTests: XCTestCase {
    func testKeepsExistingPathAndFallsBackToAncestorWhenRemoved() throws {
        let base = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: base) }

        XCTAssertEqual(KouenSidebarPanelViewController.handoffDirectory(for: base.path), base.path)
        let gone = base.appendingPathComponent("removed-worktree/sub").path
        XCTAssertEqual(KouenSidebarPanelViewController.handoffDirectory(for: gone), base.path)
    }
}
