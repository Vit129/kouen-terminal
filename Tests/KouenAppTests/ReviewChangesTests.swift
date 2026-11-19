import Foundation
import KouenCore
import KouenGit
@testable import KouenApp
import XCTest
import AppKit

@MainActor
final class ReviewChangesTests: XCTestCase {
    func testTC6912_FE_BL_DiffIncludesAllChangeKindsWithoutChangingIndex() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        func git(_ arguments: String...) throws -> String {
            let result = GitRunner.shared.execute(arguments, in: root.path)
            XCTAssertTrue(result.isSuccess, result.stderr)
            return result.stdout
        }

        _ = try git("init")
        try "base\n".write(to: root.appendingPathComponent("file"), atomically: true, encoding: .utf8)
        _ = try git("add", "file")
        _ = try git("-c", "user.name=Test", "-c", "user.email=test@example.invalid", "commit", "-m", "base")
        try "staged\n".write(to: root.appendingPathComponent("file"), atomically: true, encoding: .utf8)
        _ = try git("add", "file")
        try "unstaged\n".write(to: root.appendingPathComponent("file"), atomically: true, encoding: .utf8)
        try "new\n".write(to: root.appendingPathComponent("new file"), atomically: true, encoding: .utf8)
        try "another\n".write(to: root.appendingPathComponent("another file"), atomically: true, encoding: .utf8)
        _ = try git("add", "another file")

        let index = try git("ls-files", "--stage")
        let changes = try await ReviewDiff.load(cwd: root.path)
        XCTAssertEqual(Set(changes.files.map(\.kind)), [.staged, .unstaged, .untracked])
        XCTAssertTrue(changes.files.contains { $0.path == "new file" && $0.patch.contains("+new") })
        XCTAssertTrue(changes.files.contains { $0.path == "another file" && $0.patch.contains("+another") })
        let selected = changes.files.filter { $0.path == "file" && $0.kind == .unstaged }
        let restricted = try await ReviewDiff.load(cwd: root.path, restrictingTo: selected)
        XCTAssertEqual(restricted.files.map(\.id), selected.map(\.id))
        XCTAssertEqual(try git("ls-files", "--stage"), index)

        let oversized = String(repeating: String(repeating: "x", count: 255) + "\n", count: 20_000)
        try oversized.write(to: root.appendingPathComponent("file"), atomically: true, encoding: .utf8)
        do {
            _ = try await ReviewDiff.load(cwd: root.path, restrictingTo: selected)
            XCTFail("Expected truncated Git output to be reported")
        } catch let error as ReviewDiff.LoadError {
            XCTAssertTrue(error.localizedDescription.contains("exceeded the review limit"))
        }
    }

    func testTC6913_FE_BL_AnchorsFollowUniqueMovedTextAndRequireReattachmentWhenMissing() {
        let note = ReviewNote(path: "file", kind: .unstaged, line: 3, text: "+old", body: "Fix this")
        let patch = "@@ -7 +7 @@\n-old value\n+old\n"
        let file = ReviewDiff.File(path: "file", kind: .unstaged, patch: patch)
        XCTAssertEqual(note.match(in: [file])?.line, 7)
        XCTAssertNil(note.match(in: []))
        let range = ReviewNote(path: "file", kind: .unstaged, line: 3, text: "-old value\n+old", body: "Review both")
        XCTAssertEqual(range.match(in: [file])?.line, 7)
    }

    func testTC6914_FE_BL_SendTargetsSelectedPaneAndKeepsNotesOnFailure() async {
        let surface = UUID()
        let note = ReviewNote(path: "file", kind: .unstaged, line: 3, text: "+old", body: "Fix this")
        let file = ReviewDiff.File(path: "file", kind: .unstaged, patch: "@@ -3 +3 @@\n-old value\n+old\n")
        let draft = ReviewDraft()
        draft.notes = [note]
        var attempted = false
        let wrong = await draft.send(to: surface, allowed: [], files: [file]) { _, _ in
            attempted = true
            return true
        }
        XCTAssertEqual(wrong, .unavailable)
        XCTAssertFalse(attempted)
        let failed = await draft.send(to: surface, allowed: [surface], files: [file]) { target, text in
            XCTAssertEqual(target, surface)
            XCTAssertTrue(text.contains("file:3"))
            XCTAssertTrue(text.contains("Fix this"))
            return false
        }
        XCTAssertEqual(failed, .deliveryFailed)
        XCTAssertEqual(draft.notes, [note])

        draft.notes.append(ReviewNote(path: "file", kind: .unstaged, line: 3, text: "+old", body: "Already handled", resolved: true))
        let sent = await draft.send(to: surface, allowed: [surface], files: [file]) { target, text in
            XCTAssertEqual(target, surface)
            XCTAssertTrue(text.contains("Fix this"))
            XCTAssertFalse(text.contains("Already handled"))
            return true
        }
        XCTAssertEqual(sent, .sent)
    }

    func testTC6916_FE_BL_SendReportsEveryUnmatchedOpenNoteAndBlocksDelivery() async {
        let surface = UUID()
        let file = ReviewDiff.File(path: "file", kind: .unstaged, patch: "@@ -3 +3 @@\n-old value\n+old\n")
        let matched = ReviewNote(path: "file", kind: .unstaged, line: 3, text: "+old", body: "Fix this")
        let changed = ReviewNote(path: "file", kind: .unstaged, line: 9, text: "+gone", body: "Changed")
        let removed = ReviewNote(path: "removed", kind: .staged, line: 14, text: "+gone", body: "Removed")
        let resolved = ReviewNote(path: "resolved", kind: .staged, line: 1, text: "+gone", body: "Done", resolved: true)
        let draft = ReviewDraft()
        draft.notes = [matched, changed, removed, resolved]

        let result = await draft.send(to: surface, allowed: [surface], files: [file]) { _, _ in
            XCTFail("Delivery must be blocked when any open note needs reattaching")
            return true
        }

        XCTAssertEqual(result, .needsReattachment([changed, removed]))
        XCTAssertEqual(draft.notes, [matched, changed, removed, resolved])
    }

    func testTC6917_FE_BL_PruneKeepsLiveTabDraftAndDropsClosedTabDraft() {
        let container = NSView()
        let terminal = NSView()
        let divider = NSView()
        let coordinator = FilePreviewCoordinator(containerView: container, terminalHost: terminal, tabBarDivider: divider)
        let liveTab = UUID()
        let closedTab = UUID()
        let cwd = "/repo"
        let kept = coordinator.reviewDraft(forTabID: liveTab.uuidString, cwd: cwd)
        let removed = coordinator.reviewDraft(forTabID: closedTab.uuidString, cwd: cwd)

        coordinator.pruneFileTabManagers(keepingTabIDs: Set([liveTab].map(\.uuidString)))

        XCTAssertTrue(coordinator.reviewDraft(forTabID: liveTab.uuidString, cwd: cwd) === kept)
        XCTAssertFalse(coordinator.reviewDraft(forTabID: closedTab.uuidString, cwd: cwd) === removed)
        withExtendedLifetime((container, terminal, divider)) {}
    }

    func testTC6919_FE_BL_BannerShortcutUsesCommandLForReviewChanges() {
        XCTAssertEqual(BannerShortcutRegistry.reviewChanges.id, "reviewChanges")
        XCTAssertEqual(BannerShortcutRegistry.reviewChanges.displayKey, "⌘L")
        XCTAssertTrue(BannerShortcutRegistry.shortcuts.contains {
            $0.key == "⌘L" && $0.description == "review worktree changes"
        })
        XCTAssertFalse(BannerShortcutRegistry.shortcuts.contains { $0.key == "⌘⌥D" })
    }

}
