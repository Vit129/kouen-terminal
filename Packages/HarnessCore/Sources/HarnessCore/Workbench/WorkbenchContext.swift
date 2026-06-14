/// Narrow execution context passed alongside a WorkbenchCommand (PBI-WB-001).
/// Pure value type — no AppKit, no shell.
public struct WorkbenchContext: Sendable, Equatable {
    public let workspaceID: String
    public let sessionID: String
    public let tabID: String
    public let cwd: String
    public let currentFile: String?

    public init(
        workspaceID: String,
        sessionID: String,
        tabID: String,
        cwd: String,
        currentFile: String? = nil
    ) {
        self.workspaceID = workspaceID
        self.sessionID = sessionID
        self.tabID = tabID
        self.cwd = cwd
        self.currentFile = currentFile
    }
}
