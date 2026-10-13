import Foundation

extension IPCRequest {
    /// The refusal a read-only connection gets for anything outside `permittedOnReadOnlyConnection`.
    public static let readOnlyRefusal =
        "This connection is attached read-only, so the request was not run. Attach without --read-only to change the terminal."

    /// Whether a connection that attached or subscribed read-only may make this request. Read-only
    /// is a property of the connection, set once and never cleared, and both front doors (the
    /// session host and the daemon socket) apply this one rule. A viewer may read state, keep its
    /// own stream alive, and report a size that never votes. It may not type, paste, take size
    /// ownership, upgrade itself to a writable stream, or change workspaces or settings.
    public var permittedOnReadOnlyConnection: Bool {
        switch self {
        case let .attachStream(attach): attach.readOnly
        case .ping, .daemonStats, .identifyClient, .presentClient, .listClients,
             .subscribeSurfaceOutputReadOnly, .cancelSubscription, .detachSurface, .acknowledgeOutput,
             .resizeSurface, .subscribeSnapshot, .subscribeEvents,
             .getSnapshot, .getSnapshotForClient, .listWorkspaces, .listSurfaces, .listAgents, .listAttention,
             .capturePane, .capturePaneRange, .captureFormatted, .replayScrollback, .replayScrollbackSequenced,
             .mobileHistory, .mobileHistoryMatch, .searchOutput, .searchOutputFiltered, .validateOutputMatch,
             .cancelSearch, .listBuffers, .getBuffer, .showOptions, .showEnvironment, .listHooks, .showMessages,
             .foregroundProcess, .surfaceContext, .processTree, .paneQuery:
            true
        default:
            false
        }
    }
}
