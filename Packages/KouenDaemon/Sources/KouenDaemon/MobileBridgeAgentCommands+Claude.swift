import Foundation

/// Claude Code: fixed family aliases (each always resolves to that family's newest model, so this
/// list only changes when a whole new family ships), plus a Shift+Tab permission-mode cycle.
enum ClaudeMobileCommands {
    /// Claude Code's `Shift+Tab` cycle order, verified in a live TTY (claude 2.1.296): manual,
    /// acceptEdits, plan, auto, then back to manual. `bypassPermissions` is not in the cycle.
    static let modeCycle = ["manual", "acceptEdits", "plan", "auto"]
    static let models: Set<String> = ["opus", "sonnet", "haiku", "fable"]
    static let efforts: Set<String> = ["low", "medium", "high", "xhigh", "max"]

    static func input(kind: String, value: String, currentMode: String?) -> [Data]? {
        switch kind {
        case "model" where models.contains(value):
            return slashCommandChunks("model", value)
        case "effort" where efforts.contains(value):
            return slashCommandChunks("effort", value)
        case "mode":
            guard let from = currentMode.flatMap(modeCycle.firstIndex(of:)),
                  let to = modeCycle.firstIndex(of: value) else { return nil }
            let presses = (to - from + modeCycle.count) % modeCycle.count
            return Array(repeating: Data([0x1b, 0x5b, 0x5a]), count: presses)
        default:
            return nil
        }
    }
}
