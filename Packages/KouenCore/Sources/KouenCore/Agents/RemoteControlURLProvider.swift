import Foundation
import KouenIPC

/// URLs and launcher for agent remote-control web dashboards.
public enum RemoteControlURLProvider: Sendable {
    /// Remote-control web dashboard URL for an agent kind.
    public static func url(for kind: AgentKind) -> URL? {
        switch kind {
        case .claudeCode:
            return URL(string: "https://claude.ai/code")
        case .antigravity:
            return URL(string: "https://antigravity.google.com")
        case .codex:
            return URL(string: "https://chatgpt.com")
        default:
            return nil
        }
    }

    #if os(macOS)
    /// Opens the remote-control web dashboard in Google Chrome if supported.
    @discardableResult
    public static func openInGoogleChrome(for kind: AgentKind) -> Bool {
        guard let url = url(for: kind) else { return false }
        return openInGoogleChrome(url: url)
    }

    /// Launches Google Chrome with the given URL in the background.
    @discardableResult
    public static func openInGoogleChrome(url: URL) -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        process.arguments = ["-a", "Google Chrome", url.absoluteString]
        do {
            try process.run()
            return true
        } catch {
            return false
        }
    }
    #endif
}
