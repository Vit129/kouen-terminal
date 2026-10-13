import XCTest
@testable import HarnessCore

final class KeyBindingEditorTests: XCTestCase {
    private let x = KeySpec(key: "x")
    private let bigX = KeySpec(key: "X")
    private let metaLeft = KeySpec(key: "Left", modifiers: .option)

    func testFreshTablesShowEveryDefaultAsStandard() {
        let rows = KeyTableSet.defaults.editorRows(in: .prefix)
        XCTAssertFalse(rows.isEmpty)
        XCTAssertTrue(rows.allSatisfy { $0.status == .standard && !$0.isResettable })
        XCTAssertEqual(rows.first { $0.spec == x }?.command, .killPane)
    }

    func testEveryDefaultCommandTextParsesBackToTheSameCommand() throws {
        for id in KeyTableSet.editableTables {
            for row in KeyTableSet.defaults.editorRows(in: id) {
                XCTAssertEqual(try CommandParser.parse(row.commandText), row.command,
                               "\(id.rawValue) \(row.spec): \(row.commandText)")
            }
        }
        let targets: [Command.PaneTarget] = [.left, .right, .up, .down, .next, .previous, .last]
        for target in targets {
            for command in [Command.selectPane(target: target), .swapPane(target: target, source: nil)] {
                XCTAssertEqual(try CommandParser.parse(command.shortDescription), command, command.shortDescription)
            }
        }
    }

    func testChangingADefaultMarksItChangedAndResetRestoresIt() {
        var tables = KeyTableSet.defaults
        tables.editorSet(.prefix, spec: x, command: .detachClient)
        XCTAssertEqual(row(x, in: tables)?.status, .changed)
        XCTAssertEqual(row(x, in: tables)?.defaultCommand, .killPane)

        tables.editorReset(.prefix, spec: x)
        XCTAssertEqual(tables, KeyTableSet.defaults)
    }

    func testRebindingADefaultLeavesTheOldKeyUnboundAcrossReload() throws {
        var tables = KeyTableSet.defaults
        tables.editorRebind(.prefix, from: x, to: bigX)
        XCTAssertNil(tables.table(.prefix)?.lookup(x))
        XCTAssertEqual(tables.table(.prefix)?.lookup(bigX)?.command, .killPane)
        XCTAssertEqual(row(x, in: tables)?.status, .removed)
        XCTAssertEqual(row(bigX, in: tables)?.status, .added)

        let reloaded = try roundTrip(tables)
        XCTAssertNil(reloaded.table(.prefix)?.lookup(x), "the moved default must not come back")
        XCTAssertEqual(reloaded.table(.prefix)?.lookup(bigX)?.command, .killPane)
    }

    func testRemovingAnAddedKeyLeavesNoTombstone() {
        var tables = KeyTableSet.defaults
        tables.editorSet(.root, spec: metaLeft, command: .selectPane(target: .left))
        XCTAssertEqual(row(metaLeft, in: tables, table: .root)?.status, .added)
        tables.editorRemove(.root, spec: metaLeft)
        XCTAssertEqual(tables, KeyTableSet.defaults)
    }

    func testResettingARemovedDefaultBringsItBack() {
        var tables = KeyTableSet.defaults
        tables.editorRemove(.prefix, spec: x)
        XCTAssertEqual(row(x, in: tables)?.status, .removed)
        tables.editorReset(.prefix, spec: x)
        XCTAssertEqual(tables.table(.prefix)?.lookup(x)?.command, .killPane)
        XCTAssertFalse(tables.table(.prefix)?.isDisabled(x) ?? true)
    }

    func testResetTableUndoesEveryEditInThatTableOnly() {
        var tables = KeyTableSet.defaults
        tables.editorRebind(.prefix, from: x, to: bigX)
        tables.editorSet(.root, spec: metaLeft, command: .selectPane(target: .left))
        tables.editorResetTable(.prefix)
        XCTAssertEqual(tables.table(.prefix), KeyTableSet.defaults.table(.prefix))
        XCTAssertNotNil(tables.table(.root)?.lookup(metaLeft))
    }

    func testConflictFindsTheOtherBindingButNotItself() {
        let tables = KeyTableSet.defaults
        XCTAssertEqual(tables.conflict(in: .prefix, spec: x)?.command, .killPane)
        XCTAssertNil(tables.conflict(in: .prefix, spec: x, excluding: x))
        XCTAssertNil(tables.conflict(in: .prefix, spec: KeySpec(key: "F9")))
    }

    func testANewCommandDropsTheOldNote() {
        var tables = KeyTableSet.defaults
        let noted = tables.table(.prefix)?.bindings.first { $0.note != nil }
        guard let noted else { return XCTFail("expected a default with a note") }
        tables.editorSet(.prefix, spec: noted.spec, command: noted.command)
        XCTAssertEqual(tables.table(.prefix)?.lookup(noted.spec)?.note, noted.note)
        tables.editorSet(.prefix, spec: noted.spec, command: .detachClient)
        XCTAssertNil(tables.table(.prefix)?.lookup(noted.spec)?.note)
    }

    func testColonAfterThePrefixIsReserved() {
        let issues = check(.prefix, KeySpec(key: ":"), editing: nil, prefix: false, shadows: nil)
        XCTAssertEqual(issues, [.reservedPromptKey])
    }

    func testRootKeyRefusesThePrefixAndOrdersBlockingIssuesFirst() {
        let ctrlA = KeySpec(key: "a", modifiers: .control)
        let issues = check(.root, ctrlA, editing: nil, prefix: true, shadows: "the menu item “Select All”")
        XCTAssertEqual(issues, [.prefixKey, .shadows("the menu item “Select All”")])
        XCTAssertTrue(issues[0].isBlocking)
    }

    func testRootKeyWithoutACommandModifierWarnsThatTypingStops() {
        let issues = check(.root, KeySpec(key: "F5"), editing: nil, prefix: false, shadows: nil)
        XCTAssertEqual(issues, [.swallowsTyping])
        XCTAssertTrue(check(.root, metaLeft, editing: nil, prefix: false, shadows: nil).isEmpty)
    }

    func testSameTableConflictOffersReplacementButNotForTheKeyBeingEdited() {
        let issues = check(.prefix, x, editing: KeySpec(key: "c"), prefix: false, shadows: "ignored outside root")
        XCTAssertEqual(issues, [.replaces(Binding(spec: x, command: .killPane, note: noteForX()))])
        XCTAssertFalse(issues[0].isBlocking)
        XCTAssertTrue(check(.prefix, x, editing: x, prefix: false, shadows: nil).isEmpty)
    }

    func testCopyModeTablesOnlyAcceptCopyModeActions() {
        XCTAssertEqual(KeyBindingCheck.issues(table: .copyMode, command: .killPane), [.notCopyModeAction])
        XCTAssertTrue(KeyBindingCheck.issues(table: .copyModeEmacs, command: .copyModeCommand(.cancel)).isEmpty)
        XCTAssertTrue(KeyBindingCheck.issues(table: .prefix, command: .killPane).isEmpty)
    }

    private func check(
        _ table: KeyTableID, _ spec: KeySpec, editing: KeySpec?, prefix: Bool, shadows: String?
    ) -> [KeyBindingIssue] {
        KeyBindingCheck.issues(table: table, spec: spec, editing: editing, in: .defaults,
                               isPrefixKey: prefix, shadows: shadows)
    }

    private func noteForX() -> String? {
        KeyTableSet.defaults.table(.prefix)?.lookup(x)?.note
    }

    private func row(_ spec: KeySpec, in tables: KeyTableSet, table: KeyTableID = .prefix) -> KeyBindingRow? {
        tables.editorRows(in: table).first { $0.spec == spec }
    }

    private func roundTrip(_ tables: KeyTableSet) throws -> KeyTableSet {
        let data = try JSONEncoder().encode(tables)
        return KeybindingsStore.merge(stored: try JSONDecoder().decode(KeyTableSet.self, from: data))
    }
}
