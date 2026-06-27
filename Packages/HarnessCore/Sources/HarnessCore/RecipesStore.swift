import Foundation

public struct Recipe: Codable, Identifiable, Sendable {
    public let id: UUID
    public let name: String
    public let command: String
    public let runImmediately: Bool
    
    public init(id: UUID = UUID(), name: String, command: String, runImmediately: Bool) {
        self.id = id
        self.name = name
        self.command = command
        self.runImmediately = runImmediately
    }
}

@MainActor
public final class RecipesStore: @unchecked Sendable {
    public static let shared = RecipesStore()
    
    public private(set) var recipes: [Recipe] = []
    
    private let fileURL: URL
    
    private init() {
        self.fileURL = HarnessPaths.applicationSupport.appendingPathComponent("recipes.json")
        load()
    }
    
    public func load() {
        do {
            let data = try Data(contentsOf: fileURL)
            self.recipes = try JSONDecoder().decode([Recipe].self, from: data)
        } catch {
            // Seed defaults if load fails
            self.recipes = Self.defaultRecipes
            save()
        }
    }
    
    public func save() {
        do {
            try FileManager.default.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(recipes)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            // Ignore error or log it
        }
    }
    
    public func add(_ recipe: Recipe) {
        recipes.append(recipe)
        save()
    }
    
    public func delete(_ recipe: Recipe) {
        recipes.removeAll { $0.id == recipe.id }
        save()
    }
    
    public func update(_ recipe: Recipe) {
        if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
            recipes[index] = recipe
            save()
        }
    }
    
    private static let defaultRecipes = [
        Recipe(name: "List Files (ls -la)", command: "ls -la", runImmediately: true),
        Recipe(name: "Git Status", command: "git status", runImmediately: true),
        Recipe(name: "Check Listening Ports", command: "lsof -iTCP -sTCP:LISTEN", runImmediately: true),
        Recipe(name: "Show System Log", command: "tail -n 50 /var/log/system.log", runImmediately: false)
    ]
}
