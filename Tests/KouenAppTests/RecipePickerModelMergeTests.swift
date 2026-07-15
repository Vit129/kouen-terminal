import XCTest
import KouenCore
import KouenTerminalEngine
@testable import KouenApp

/// P38 Phase C — the pivot merged saved `Recipe`s and captured `TerminalBlock` history into one
/// flat, searchable `PickerItem` list (`RecipePickerController.swift`). The deleted overlay's
/// test file was never replaced when the pivot happened; this covers the actual merge/filter
/// logic that replaced it, plus the later addition of per-pane "thread" grouping (Zed's
/// turn-by-turn framing, folded into this same picker instead of a dedicated UI).
@MainActor
final class RecipePickerModelMergeTests: XCTestCase {
    private func osc133(_ body: String) -> String { "\u{1b}]133;\(body)\u{07}" }
    private func b64(_ s: String) -> String { Data(s.utf8).base64EncodedString() }

    /// Builds real `TerminalBlock`s the same way `TerminalBlockStoreTests` does — the struct's
    /// memberwise init is internal to `KouenTerminalEngine`, so a cross-module test target can
    /// only get instances by feeding real OSC 133 output through a live emulator.
    private func makeBlocks() -> [TerminalBlock] {
        let term = TerminalEmulator(cols: 40, rows: 20)
        term.feed(osc133("A") + "$ ")
        term.feed(osc133("C;\(b64("git status"))") + "\r\nclean\r\n")
        term.feed(osc133("D;0"))
        term.feed(osc133("A") + "$ ")
        term.feed(osc133("C;\(b64("cat missing-file"))") + "\r\n")
        term.feed(osc133("D;1"))
        return term.blocks // oldest first: git status, cat missing-file
    }

    private func makeHistoryItems(paneLabel: String = "Pane 1", surfaceID: SurfaceID = SurfaceID()) -> [PickerItem] {
        makeBlocks().map { .historyBlock($0, surfaceID: surfaceID, paneLabel: paneLabel) }
    }

    private func makeRecipe(name: String = "Build", command: String = "swift build", runImmediately: Bool = true) -> Recipe {
        Recipe(name: name, command: command, runImmediately: runImmediately)
    }

    // MARK: - PickerItem identity/search text/grouping

    func testPickerItemIDsAreDistinctAcrossKinds() {
        let block = makeBlocks()[0]
        let recipe = makeRecipe()
        XCTAssertNotEqual(PickerItem.recipe(recipe).id, PickerItem.historyBlock(block, surfaceID: SurfaceID(), paneLabel: "Pane 1").id)
    }

    func testRecipeSearchableTextIncludesNameAndCommand() {
        let recipe = makeRecipe(name: "Deploy", command: "make deploy")
        XCTAssertEqual(PickerItem.recipe(recipe).searchableText, "Deploy make deploy")
    }

    func testHistoryBlockSearchableTextIsJustTheCommand() {
        let block = makeBlocks()[0]
        XCTAssertEqual(PickerItem.historyBlock(block, surfaceID: SurfaceID(), paneLabel: "Pane 1").searchableText, "git status")
    }

    func testRecipeHasNoGroupLabel() {
        XCTAssertNil(PickerItem.recipe(makeRecipe()).groupLabel)
    }

    func testHistoryBlockGroupLabelIsItsPaneLabel() {
        let block = makeBlocks()[0]
        XCTAssertEqual(PickerItem.historyBlock(block, surfaceID: SurfaceID(), paneLabel: "Pane 2").groupLabel, "Pane 2")
    }

    // MARK: - Merge ordering

    func testAllItemsPreservesCallerOrderHistoryThenRecipes() {
        let items = makeHistoryItems()
        let recipe = makeRecipe()
        let model = RecipePickerModel(recipes: [recipe], historyItems: items, parentWindow: nil)

        XCTAssertEqual(model.allItems.count, 3)
        // Caller is documented to pass history already most-recent-first; the model must not
        // silently re-sort or interleave — recipes always trail all history items.
        XCTAssertEqual(model.allItems[0].searchableText, items[0].searchableText)
        XCTAssertEqual(model.allItems[1].searchableText, items[1].searchableText)
        if case .recipe = model.allItems[2] {} else { XCTFail("expected recipe last") }
    }

    /// Two panes' history must keep each pane's items grouped together, not interleaved by
    /// time — the caller (`RecipePickerController.present`) builds `historyItems` one pane at a
    /// time for exactly this reason; the model must preserve whatever order it's given.
    func testHistoryFromDifferentPanesStaysGroupedNotInterleaved() {
        let paneA = makeHistoryItems(paneLabel: "Pane A", surfaceID: SurfaceID())
        let paneB = makeHistoryItems(paneLabel: "Pane B", surfaceID: SurfaceID())
        let model = RecipePickerModel(recipes: [], historyItems: paneA + paneB, parentWindow: nil)

        XCTAssertEqual(model.allItems.prefix(2).map(\.groupLabel), ["Pane A", "Pane A"])
        XCTAssertEqual(model.allItems.suffix(2).map(\.groupLabel), ["Pane B", "Pane B"])
    }

    // MARK: - Filtering across both kinds

    func testQueryFiltersAcrossBothItemKinds() {
        let items = makeHistoryItems() // "git status", "cat missing-file"
        let recipe = makeRecipe(name: "Git Log", command: "git log --oneline")
        let model = RecipePickerModel(recipes: [recipe], historyItems: items, parentWindow: nil)

        model.updateQuery("git")

        XCTAssertEqual(model.filteredItems.count, 2, "matches the 'git status' history block AND the 'Git Log' recipe")
        XCTAssertTrue(model.filteredItems.contains { $0.searchableText.lowercased().contains("git status") })
        if case .recipe = model.filteredItems.last! {} else { XCTFail("expected the matching recipe to survive filtering") }
    }

    func testQueryIsCaseInsensitive() {
        let items = makeHistoryItems()
        let model = RecipePickerModel(recipes: [], historyItems: items, parentWindow: nil)
        model.updateQuery("GIT STATUS")
        XCTAssertEqual(model.filteredItems.count, 1)
    }

    func testEmptyQueryRestoresFullList() {
        let items = makeHistoryItems()
        let recipe = makeRecipe()
        let model = RecipePickerModel(recipes: [recipe], historyItems: items, parentWindow: nil)
        model.updateQuery("git")
        model.updateQuery("")
        XCTAssertEqual(model.filteredItems.count, model.allItems.count)
    }

    func testNoMatchesClearsFilteredList() {
        let model = RecipePickerModel(recipes: [makeRecipe()], historyItems: makeHistoryItems(), parentWindow: nil)
        model.updateQuery("nonexistent-xyz")
        XCTAssertTrue(model.filteredItems.isEmpty)
    }

    // MARK: - Selection clamping/wrap

    func testSelectedIndexClampsWhenFilterShrinksList() {
        let model = RecipePickerModel(recipes: [makeRecipe()], historyItems: makeHistoryItems(), parentWindow: nil)
        model.selectedIndex = 2 // last item (a recipe) before filtering
        model.updateQuery("git status") // only one history block matches
        XCTAssertEqual(model.filteredItems.count, 1)
        XCTAssertEqual(model.selectedIndex, 0, "selection must clamp into the shrunk list, not point past its end")
    }

    func testMoveSelectionWrapsAroundBothDirections() {
        let model = RecipePickerModel(recipes: [makeRecipe()], historyItems: makeHistoryItems(), parentWindow: nil)
        XCTAssertEqual(model.filteredItems.count, 3)
        model.selectedIndex = 0
        model.moveSelection(by: -1)
        XCTAssertEqual(model.selectedIndex, 2, "moving up from the first item wraps to the last")
        model.moveSelection(by: 1)
        XCTAssertEqual(model.selectedIndex, 0, "moving down from the last item wraps to the first")
    }

    func testMoveSelectionNoOpsOnEmptyList() {
        let model = RecipePickerModel(recipes: [], historyItems: [], parentWindow: nil)
        model.moveSelection(by: 1) // must not crash on an empty list
        XCTAssertEqual(model.selectedIndex, 0)
    }
}
