/// Shared workbench command intents (PBI-WB-001).
/// Pure value types — no shell execution, no AppKit.
public enum WorkbenchCommand: Sendable, Equatable {
    // Navigation
    case find(query: String)
    case recent
    case copyPath(relative: Bool)
    case cd(path: String)
    case mark(name: String, path: String)

    // Search / errors
    case grep(query: String)
    case errors

    // State
    case board
    case attention
    case ack

    // Tasks
    case make(target: String?)
}
