import Foundation
import KouenCore
import KouenTerminalKit

@MainActor
enum TerminalPaneRegistryAccess {
    static func host(for surfaceID: SurfaceID) -> TerminalHostView? {
        SessionCoordinator.shared.terminalHostIfExists(for: surfaceID)
    }
}
