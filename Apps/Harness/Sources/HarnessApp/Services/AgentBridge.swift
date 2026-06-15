import Foundation
import HarnessCore

/// Unified interface for sending context (files, errors, output) to an agent pane
/// without opening a chat panel. Used by `:agent` ex commands, CLI, and scripting.
@MainActor
final class AgentBridge {
    static let shared = AgentBridge()
    private init() {}

    /// Find the first agent pane surface ID in the active workspace.
    func agentSurfaceID() -> SurfaceID? {
        let snapshot = SessionCoordinator.shared.snapshot
        guard let workspace = snapshot.activeWorkspace else { return nil }
        for session in workspace.sessions {
            for tab in session.tabs {
                guard tab.agent != nil else { continue }
                // Return the active surface of this tab's root pane
                if let sid = tab.rootPane.surfaceID { return sid }
            }
        }
        return nil
    }

    /// Send raw text to the agent pane.
    func sendToAgent(_ text: String) {
        guard let surfaceID = agentSurfaceID() else { return }
        SessionCoordinator.shared.requestDaemon(.send(surfaceID: surfaceID.uuidString, text: text))
    }

    /// Send file content to agent with a command prefix.
    func sendFile(path: String, command: String) {
        let content: String
        if let data = FileManager.default.contents(atPath: path),
           let text = String(data: data, encoding: .utf8) {
            content = text.prefix(8000).description // cap to avoid flooding
        } else {
            content = "(could not read file)"
        }
        let message = "\(command)\n\nFile: \(path)\n```\n\(content)\n```\n"
        sendToAgent(message)
    }

    /// Send last build/test output to agent.
    func sendLastOutput(command: String) {
        // Capture from the last split pane (where :make ran)
        let message = "\(command)\n"
        sendToAgent(message)
    }
}
