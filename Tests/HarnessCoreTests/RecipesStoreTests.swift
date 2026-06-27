import XCTest
import HarnessCore

final class RecipesStoreTests: XCTestCase {
    
    override func setUp() async throws {
        try await super.setUp()
        // Make sure we run on MainActor
        await MainActor.run {
            // Delete existing test recipes.json to have a clean state
            let url = HarnessPaths.applicationSupport.appendingPathComponent("recipes.json")
            try? FileManager.default.removeItem(at: url)
            RecipesStore.shared.load()
        }
    }
    
    override func tearDown() async throws {
        await MainActor.run {
            let url = HarnessPaths.applicationSupport.appendingPathComponent("recipes.json")
            try? FileManager.default.removeItem(at: url)
        }
        try await super.tearDown()
    }
    
    func testDefaultRecipesLoaded() async {
        await MainActor.run {
            let store = RecipesStore.shared
            XCTAssertFalse(store.recipes.isEmpty)
            XCTAssertEqual(store.recipes.first?.name, "List Files (ls -la)")
        }
    }
    
    func testAddDeleteRecipe() async {
        await MainActor.run {
            let store = RecipesStore.shared
            let countBefore = store.recipes.count
            
            let recipe = Recipe(name: "Test Recipe", command: "echo test", runImmediately: true)
            store.add(recipe)
            
            XCTAssertEqual(store.recipes.count, countBefore + 1)
            XCTAssertTrue(store.recipes.contains { $0.id == recipe.id })
            
            store.delete(recipe)
            XCTAssertEqual(store.recipes.count, countBefore)
            XCTAssertFalse(store.recipes.contains { $0.id == recipe.id })
        }
    }
    
    func testUpdateRecipe() async {
        await MainActor.run {
            let store = RecipesStore.shared
            let recipe = Recipe(name: "Test Recipe", command: "echo test", runImmediately: true)
            store.add(recipe)
            
            let updated = Recipe(id: recipe.id, name: "Updated Test Recipe", command: "echo test updated", runImmediately: false)
            store.update(updated)
            
            guard let found = store.recipes.first(where: { $0.id == recipe.id }) else {
                XCTFail("Recipe not found after update")
                return
            }
            XCTAssertEqual(found.name, "Updated Test Recipe")
            XCTAssertEqual(found.command, "echo test updated")
            XCTAssertFalse(found.runImmediately)
            
            store.delete(updated)
        }
    }
}
