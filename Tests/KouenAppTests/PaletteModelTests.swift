import XCTest
@testable import KouenApp

@MainActor
final class PaletteModelTests: XCTestCase {

    private func makeAction(id: String, title: String, section: PaletteAction.Section) -> PaletteAction {
        PaletteAction(id: id, title: title, subtitle: "", symbol: "star", shortcut: "", section: section) {}
    }

    private func makeModel(
        actions: [PaletteAction] = [],
        recentIDs: [String] = [],
        mode: CommandPaletteController.PaletteMode = .normal
    ) -> PaletteModel {
        PaletteModel(actions: actions, recentIDs: recentIDs, parentWindow: nil, mode: mode)
    }

    // MARK: - Initial state

    func testEmptyActions_emptyQuery_producesNoRows() {
        let model = makeModel()
        XCTAssertTrue(model.rows.isEmpty)
    }

    func testGrepMode_preseedsQueryFromMode() {
        let model = makeModel(mode: .grep(query: "TODO"))
        XCTAssertEqual(model.query, "TODO")
    }

    func testGrepMode_emptyQuery_producesNoRows() {
        let model = makeModel(mode: .grep(query: ""))
        XCTAssertTrue(model.rows.isEmpty)
    }

    // MARK: - Normal mode filtering

    func testNormalMode_withMatchingQuery_producesItemRow() {
        let action = makeAction(id: "theme-1", title: "Switch Theme", section: .themes)
        let model = makeModel(actions: [action])
        model.updateQuery("theme")
        let hasItem = model.rows.contains {
            if case .item(let a) = $0 { return a.id == "theme-1" }
            return false
        }
        XCTAssertTrue(hasItem, "rows should contain the matching action")
    }

    func testNormalMode_withNonMatchingQuery_producesNoRows() {
        let action = makeAction(id: "theme-1", title: "Switch Theme", section: .themes)
        let model = makeModel(actions: [action])
        model.updateQuery("zzzzzz")
        XCTAssertTrue(model.rows.isEmpty)
    }

    func testNormalMode_withEmptyQuery_includesAllActions() {
        let actions = (0..<3).map { makeAction(id: "a\($0)", title: "Action \($0)", section: .actions) }
        let model = makeModel(actions: actions)
        // empty query shows all actions; each action produces one .item row
        let itemCount = model.rows.filter { if case .item = $0 { return true }; return false }.count
        XCTAssertEqual(itemCount, 3)
    }

    // MARK: - Selection movement

    func testMoveSelection_wrapsForwardAtEnd() {
        let actions = (0..<3).map { makeAction(id: "a\($0)", title: "Action \($0)", section: .actions) }
        let model = makeModel(actions: actions)
        model.updateQuery("Action")
        guard let first = model.selectableIndexes.first, let last = model.selectableIndexes.last else {
            return XCTFail("expected selectable rows")
        }
        model.selectedIndex = last
        model.moveSelection(by: 1)
        XCTAssertEqual(model.selectedIndex, first)
    }

    func testMoveSelection_wrapsBackwardAtStart() {
        let actions = (0..<3).map { makeAction(id: "a\($0)", title: "Action \($0)", section: .actions) }
        let model = makeModel(actions: actions)
        model.updateQuery("Action")
        guard let first = model.selectableIndexes.first, let last = model.selectableIndexes.last else {
            return XCTFail("expected selectable rows")
        }
        model.selectedIndex = first
        model.moveSelection(by: -1)
        XCTAssertEqual(model.selectedIndex, last)
    }

    func testMoveSelection_noOpsWhenNoSelectableRows() {
        let model = makeModel()
        let before = model.selectedIndex
        model.moveSelection(by: 1)
        XCTAssertEqual(model.selectedIndex, before)
    }
}
