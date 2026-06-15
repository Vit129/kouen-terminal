import Foundation
import HarnessCore

/// Unified interface for sending context (files, errors, output) to an agent pane
/// without opening a chat panel. Used by `:agent` ex commands, CLI, and scripting.
@MainActor
final class AgentBridge {
    static let shared = AgentBridge()
    private init() {}

    struct AgentTarget: Equatable {
        let surfaceID: SurfaceID
        let kind: AgentKind
        let tabTitle: String
    }

    /// Find all agent panes in the active workspace.
    func allAgents() -> [AgentTarget] {
        let snapshot = SessionCoordinator.shared.snapshot
        guard let workspace = snapshot.activeWorkspace else { return [] }
        var results: [AgentTarget] = []
        for session in workspace.sessions {
            for tab in session.tabs {
                guard let agent = tab.agent, let sid = tab.rootPane.surfaceID else { continue }
                results.append(AgentTarget(surfaceID: sid, kind: agent.kind, tabTitle: tab.title))
            }
        }
        return results
    }

    /// Find agent by kind filter, or first if nil.
    func agentSurfaceID(kind: AgentKind? = nil) -> SurfaceID? {
        let agents = allAgents()
        if let kind {
            return agents.first { $0.kind == kind }?.surfaceID
        }
        return agents.first?.surfaceID
    }

    /// Send raw text to the agent pane.
    func sendToAgent(_ text: String, kind: AgentKind? = nil) -> Bool {
        guard let surfaceID = agentSurfaceID(kind: kind) else { return false }
        SessionCoordinator.shared.requestDaemon(.send(surfaceID: surfaceID.uuidString, text: text))
        return true
    }

    /// Send file content to agent with a command prefix.
    func sendFile(path: String, command: String, kind: AgentKind? = nil) -> Bool {
        let content: String
        if let data = FileManager.default.contents(atPath: path),
           let text = String(data: data, encoding: .utf8) {
            content = String(text.prefix(8000))
        } else {
            content = "(could not read file)"
        }
        let message = "\(command)\n\nFile: \(path)\n```\n\(content)\n```\n"
        return sendToAgent(message, kind: kind)
    }
}
