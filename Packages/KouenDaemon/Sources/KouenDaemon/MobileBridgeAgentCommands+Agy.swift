import Foundation

/// agy (Antigravity): models and efforts come from `agy models` (`AgyModelCatalog`), never a
/// hand-copied list. No mode control — agy has no verified permission-mode cycle.
enum AgyMobileCommands {
    /// nil catalog (agy missing) allows nothing rather than a stale guess.
    static func input(kind: String, value: String, catalog: AgyModelCatalog.Catalog?) -> [Data]? {
        guard let catalog else { return nil }
        switch kind {
        case "model" where catalog.models.contains(where: { $0[0] == value }):
            return slashCommandChunks("model", value)
        case "effort" where catalog.efforts.contains(value):
            return slashCommandChunks("effort", value)
        default:
            return nil
        }
    }
}
