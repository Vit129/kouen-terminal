import Foundation

/// Self-contained path helpers for the onboarding installer.
/// Mirrors the relevant pieces of HarnessCore.HarnessPaths so the wizard can
/// install to exactly the same locations the real harness-cli expects — without
/// any build or runtime dependency on the main monorepo.
enum HarnessCLIPaths {
    static var applicationSupport: URL {
        // Allow HARNESS_HOME override exactly like the real daemon/CLI (useful for preview).
        if let raw = ProcessInfo.processInfo.environment["HARNESS_HOME"], !raw.isEmpty {
            return URL(fileURLWithPath: (raw as NSString).expandingTildeInPath, isDirectory: true)
        }
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support", isDirectory: true)
        return base.appendingPathComponent("Harness", isDirectory: true)
    }

    static var binDirectory: URL {
        applicationSupport.appendingPathComponent("bin", isDirectory: true)
    }

    static var installedCLIPath: URL {
        binDirectory.appendingPathComponent("harness-cli")
    }

    static var installedDaemonPath: URL {
        binDirectory.appendingPathComponent("HarnessDaemon")
    }

    static var launchAgentURL: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/LaunchAgents/com.vit129.harness.daemon.plist")
    }

    static let launchAgentLabel = "com.vit129.harness.daemon"

    static func ensureDirectories() throws {
        let ownerOnly: [FileAttributeKey: Any] = [.posixPermissions: 0o700]
        try FileManager.default.createDirectory(at: applicationSupport, withIntermediateDirectories: true, attributes: ownerOnly)
        try FileManager.default.createDirectory(at: binDirectory, withIntermediateDirectories: true, attributes: ownerOnly)
        try? FileManager.default.setAttributes(ownerOnly, ofItemAtPath: applicationSupport.path)
    }
}