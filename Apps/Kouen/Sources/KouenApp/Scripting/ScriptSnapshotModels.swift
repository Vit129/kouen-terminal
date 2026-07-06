import Foundation
import KouenCore

extension SessionGroup {
    /// Converts a SessionGroup to a JS-compatible dictionary.
    func toJSDictionary() -> [String: Any] {
        return [
            "id": id.uuidString,
            "name": name,
            "activeTabId": activeTabID?.uuidString ?? "",
            "persistent": persistent,
            "tabs": tabs.map { $0.toJSDictionary() }
        ]
    }
}

extension Tab {
    /// Converts a Tab to a JS-compatible dictionary.
    func toJSDictionary() -> [String: Any] {
        return [
            "id": id.uuidString,
            "title": title,
            "cwd": cwd,
            "gitBranch": gitBranch ?? "",
            "activePaneId": activePaneID?.uuidString ?? "",
            "currentCommand": currentCommand ?? ""
        ]
    }
}

extension PaneLeaf {
    /// Converts a PaneLeaf to a JS-compatible dictionary, associating it with its parent session and tab.
    func toJSDictionary(sessionId: String, tabId: String, tabTitle: String, tabCwd: String, tabGitBranch: String?, tabCurrentCommand: String?) -> [String: Any] {
        return [
            "id": id.uuidString,
            "surfaceId": (activeSurfaceID ?? surfaceID).uuidString,
            "sessionId": sessionId,
            "tabId": tabId,
            "title": tabTitle,
            "cwd": tabCwd,
            "currentCommand": tabCurrentCommand ?? "",
            "gitBranch": tabGitBranch ?? ""
        ]
    }
}
