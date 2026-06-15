import Foundation

/// Intent-only workbench command vocabulary. No AppKit, no shell execution.
/// Consumers (app ex commands, CLI, MCP) execute these through existing IPC paths.
public enum WorkbenchCommand: Codable, Sendable, Equatable {
    // Navigation
    case find(query: String)
    case recent
    case copyPath(relative: Bool)
    case cd(path: String)
    case mark(name: String, path: String)
    // Search / errors
    case grep(query: String)
    case errors
    // Tasks
    case make(target: String?)   // nil = default, "build", "test", "last"
    // State / board
    case board
    case attention
    case ack
}

/// Parses plain-text ex command strings into `WorkbenchCommand` intents.
public enum WorkbenchCommandParser {
    public static func parse(_ input: String) -> WorkbenchCommand? {
        let parts = input.trimmingCharacters(in: .whitespaces)
            .split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
            .map(String.init)
        guard let verb = parts.first else { return nil }
        let arg = parts.count > 1 ? parts[1] : nil

        switch verb {
        case "find": return arg.map { .find(query: $0) } ?? .find(query: "")
        case "recent": return .recent
        case "copy-path":
            return .copyPath(relative: arg == "relative" || arg == nil)
        case "cd": return arg.map { .cd(path: $0) }
        case "mark":
            let mp = arg?.split(separator: " ", maxSplits: 1).map(String.init) ?? []
            guard mp.count == 2 else { return nil }
            return .mark(name: mp[0], path: mp[1])
        case "grep": return arg.map { .grep(query: $0) }
        case "errors": return .errors
        case "make": return .make(target: arg)
        case "board": return .board
        case "attention": return .attention
        case "ack": return .ack
        default: return nil
        }
    }
}
