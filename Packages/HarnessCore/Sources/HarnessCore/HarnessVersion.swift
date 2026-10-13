import Foundation

/// Single source of truth for the Harness version, readable from every process.
///
/// The app can read `Bundle.main` (e.g. `AboutPanelController`), but the daemon is a
/// separate launchd process where `Bundle.main` does not resolve to the app bundle —
/// so anything shared across the daemon/app boundary (the spawned shell's
/// `TERM_PROGRAM_VERSION`, the XTVERSION reply) reads these constants instead.
///
/// Bump these alongside `Info.plist` (`CFBundleShortVersionString` / `CFBundleVersion`)
/// in the release runbook. `Scripts/package-app.sh` and the release workflow fail the
/// build when the two disagree (v1.3.0/v1.3.1 shipped daemons that reported 1.2.0).
public enum HarnessVersion {
    /// Marketing version, matches `CFBundleShortVersionString`.
    public static let short = "2.3.2"
    /// Build number, matches `CFBundleVersion`. Used as the secondary-DA firmware field
    /// and for displaying available updates. Protocol/capabilities govern compatibility;
    /// a build difference does not authorize restarting programs.
    public static let build = 136
    public static let protocolLevel = 2
}

/// Redacted local diagnostics snapshot for support and bug reports.
/// Never includes terminal buffer contents, command arguments, or environment variables.
public struct HarnessDiagnosticsReport: Equatable, Sendable {
    public let version: String
    public let build: Int
    public let protocolLevel: Int
    public let osVersion: String
    public let daemonSocketRedactedPath: String
    public let daemonConnected: Bool
    public let sessionCount: Int
    public let windowCount: Int
    public let paneCount: Int
    public let themeName: String
    public let appearanceMode: String
    public let fontSummary: String
    public let chromeTextSize: String

    public init(
        version: String = HarnessVersion.short,
        build: Int = HarnessVersion.build,
        protocolLevel: Int = HarnessVersion.protocolLevel,
        osVersion: String = ProcessInfo.processInfo.operatingSystemVersionString,
        daemonSocketPath: String = HarnessPaths.socketURL.path,
        daemonConnected: Bool,
        sessionCount: Int,
        windowCount: Int,
        paneCount: Int,
        themeName: String = "Harness Default",
        settings: HarnessSettings,
        homeDirectory: String = NSHomeDirectory()
    ) {
        self.version = version
        self.build = build
        self.protocolLevel = protocolLevel
        self.osVersion = Self.redact(osVersion, homeDirectory: homeDirectory)
        self.daemonSocketRedactedPath = Self.redact(daemonSocketPath, homeDirectory: homeDirectory)
        self.daemonConnected = daemonConnected
        self.sessionCount = max(0, sessionCount)
        self.windowCount = max(0, windowCount)
        self.paneCount = max(0, paneCount)
        self.themeName = Self.redact(themeName, homeDirectory: homeDirectory)
        self.appearanceMode = settings.appearanceMode.rawValue
        let lh = String(format: "%.2f", HarnessSettings.clampedLineHeight(settings.lineHeight))
        let cw = String(format: "%.2f", HarnessSettings.clampedCellWidth(settings.cellWidth))
        let family = Self.redact(settings.fontFamily, homeDirectory: homeDirectory)
        self.fontSummary = "\(family) \(Int(settings.fontSize.rounded()))pt (line \(lh)x, width \(cw)x)"
        self.chromeTextSize = settings.chromeTextSize.rawValue
    }

    public static func redact(_ input: String, homeDirectory: String = NSHomeDirectory()) -> String {
        var result = input
        let home = homeDirectory.hasSuffix("/") ? String(homeDirectory.dropLast()) : homeDirectory
        // Whole path components only: a home of `/Users/al` must not turn `/Users/alice` into `~ice`.
        if !home.isEmpty {
            result = result.replacingOccurrences(
                of: NSRegularExpression.escapedPattern(for: home) + #"(?=/|$|\s)"#,
                with: "~",
                options: .regularExpression
            )
        }
        result = result.replacingOccurrences(of: #"/(?:Users|home)/[^/\s]+"#, with: "~", options: .regularExpression)
        for (_, pattern) in SecretPatterns.all {
            result = result.replacingOccurrences(of: pattern, with: "[REDACTED]", options: .regularExpression)
        }
        return result
    }

    public func formatted() -> String {
        [
            "Harness Diagnostics Report",
            "version: \(version) (\(build))",
            "protocol: \(protocolLevel)",
            "os: \(osVersion)",
            "daemon.socket: \(daemonSocketRedactedPath)",
            "daemon.connected: \(daemonConnected ? "true" : "false")",
            "workspace.sessions: \(sessionCount)",
            "workspace.windows: \(windowCount)",
            "workspace.panes: \(paneCount)",
            "appearance.mode: \(appearanceMode)",
            "appearance.theme: \(themeName)",
            "appearance.chromeTextSize: \(chromeTextSize)",
            "terminal.font: \(fontSummary)",
        ].joined(separator: "\n")
    }
}
