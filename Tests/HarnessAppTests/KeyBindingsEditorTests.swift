import AppKit
import HarnessCore
import XCTest
@testable import HarnessApp

@MainActor
final class KeyBindingsEditorTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        // The editor saves through the shared keybindings file. Keep every save in a scratch home.
        setenv("HARNESS_HOME", "/tmp/hkb-\(UUID().uuidString.prefix(6))", 1)
        MainActor.assumeIsolated { _ = NSApplication.shared }
    }

    override func setUp() {
        super.setUp()
        MainActor.assumeIsolated {
            try? FileManager.default.removeItem(at: KeybindingsStore.fileURL)
            KeybindingsService.shared.reload()
        }
    }

    func testRebindRootAndPrefixKeysResolveAConflictRunLiveAndReset() throws {
        let editor = KeyBindingsEditorWindow(isPrefixKey: { _ in false }, shadowedByRoot: { _ in nil })
        let service = KeybindingsService.shared
        let x = KeySpec(key: "x")
        let z = KeySpec(key: "z")

        // Prefix: move kill-pane from x onto z, which zoom-pane already uses.
        editor.startChangingKey(table: .prefix, spec: x)
        XCTAssertTrue(editor.handleRecordingKey(key("z", code: 6)))
        XCTAssertEqual(service.lookup(table: .prefix, spec: z)?.command, .zoomPane, "a conflict waits for Return")
        XCTAssertTrue(editor.handleRecordingKey(key("\r", code: 36)))
        XCTAssertEqual(live(.prefix, key("z", code: 6)), .killPane)
        XCTAssertNil(service.lookup(table: .prefix, spec: x))

        // No prefix: add ⌥← for select-pane -L.
        editor.startAdding(to: .root)
        XCTAssertTrue(editor.handleRecordingKey(key("\u{F702}", code: 123, modifiers: [.option, .function])))
        let pending = try XCTUnwrap(editor.shown.first)
        XCTAssertEqual(pending.table, .root)
        XCTAssertTrue(editor.commitAction("select-pane -L", for: pending))
        XCTAssertEqual(live(.root, key("\u{F702}", code: 123, modifiers: [.option, .function])), .selectPane(target: .left))

        XCTAssertEqual(KeybindingsStore.load(), service.tables, "the file holds what runs")

        editor.reset(table: .prefix, spec: z)
        XCTAssertEqual(service.lookup(table: .prefix, spec: z)?.command, .zoomPane)
        editor.resetTable(.prefix)
        editor.resetTable(.root)
        XCTAssertEqual(service.tables, .defaults)
        XCTAssertEqual(KeybindingsStore.load(), .defaults)
    }

    func testReservedKeysAreRefusedAndRecordingContinues() {
        let tables = InMemoryTables()
        let editor = tables.editor(isPrefixKey: { $0 == KeySpec(key: "a", modifiers: .control) })

        editor.startAdding(to: .prefix)
        XCTAssertTrue(editor.handleRecordingKey(key(":", code: 41, modifiers: .shift)))
        XCTAssertNil(editor.pendingAdd)

        editor.startAdding(to: .root)
        XCTAssertTrue(editor.handleRecordingKey(key("a", code: 0, modifiers: .control)))
        XCTAssertNil(editor.pendingAdd)
        XCTAssertTrue(editor.handleRecordingKey(key("\u{1B}", code: 53)))
        XCTAssertEqual(tables.value, .defaults)
    }

    func testShadowingAMenuKeyNeedsConfirmation() {
        let tables = InMemoryTables()
        let cmdT = KeySpec(key: "t", modifiers: .command)
        let editor = tables.editor(shadowedByRoot: { $0 == cmdT ? "the menu item “New Tab”" : nil })

        editor.startAdding(to: .root)
        editor.handleRecordingKey(key("t", code: 17, modifiers: .command))
        XCTAssertNil(editor.pendingAdd, "the menu conflict is shown before the key is taken")
        editor.handleRecordingKey(key("\r", code: 36))
        XCTAssertEqual(editor.pendingAdd?.spec, cmdT)
    }

    func testInvalidAndWrongTableActionsAreNotSaved() throws {
        let tables = InMemoryTables()
        let editor = tables.editor()
        editor.setScope(.copyMode)
        let row = try XCTUnwrap(editor.shown.first)

        XCTAssertFalse(editor.commitAction("kill-pane", for: row))
        XCTAssertFalse(editor.commitAction("no-such-verb", for: row))
        XCTAssertEqual(tables.value, .defaults)
        XCTAssertTrue(editor.commitAction("copy-mode -X cancel", for: row))
        XCTAssertEqual(tables.value.table(.copyMode)?.lookup(row.spec)?.command, .copyModeCommand(.cancel))
    }

    func testSearchMatchesKeysActionsAndTables() {
        let editor = InMemoryTables().editor()
        editor.setScope(.all)
        editor.setSearch("kill-pane")
        XCTAssertTrue(editor.shown.contains { $0.table == .prefix && $0.spec == KeySpec(key: "x") })
        editor.setSearch("copy mode (emacs)")
        XCTAssertFalse(editor.shown.isEmpty)
        XCTAssertTrue(editor.shown.allSatisfy { $0.table == .copyModeEmacs })
    }

    func testKeyTextShowsShiftForUppercaseTableKeys() {
        XCTAssertEqual(KeyBindingsEditorWindow.keyText(KeySpec(key: "M")), "⇧M")
        XCTAssertEqual(KeyBindingsEditorWindow.keyText(KeySpec(key: "m")), "M")
        XCTAssertEqual(KeyBindingsEditorWindow.keyText(KeySpec(key: "Left", modifiers: .shift)), "⇧←")
        XCTAssertEqual(KeyBindingsEditorWindow.keyText(KeySpec(key: "%")), "%")
    }

    private func live(_ table: KeyTableID, _ event: NSEvent) -> Command? {
        PrefixKeymap.makeSpec(from: event).flatMap { KeybindingsService.shared.lookup(table: table, spec: $0)?.command }
    }

    private func key(_ raw: String, code: UInt16, modifiers: NSEvent.ModifierFlags = []) -> NSEvent {
        NSEvent.keyEvent(
            with: .keyDown, location: .zero, modifierFlags: modifiers, timestamp: 0, windowNumber: 0,
            context: nil, characters: raw, charactersIgnoringModifiers: raw, isARepeat: false, keyCode: code
        )!
    }
}

@MainActor
private final class InMemoryTables {
    var value = KeyTableSet.defaults

    func editor(
        isPrefixKey: @escaping (KeySpec) -> Bool = { _ in false },
        shadowedByRoot: @escaping (KeySpec) -> String? = { _ in nil }
    ) -> KeyBindingsEditorWindow {
        KeyBindingsEditorWindow(
            readTables: { self.value },
            applyEdit: { change in change(&self.value) },
            isPrefixKey: isPrefixKey,
            shadowedByRoot: shadowedByRoot
        )
    }
}
