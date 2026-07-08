#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif
import Foundation

/// Installs and manages the per-user LaunchAgent that supervises KouenDaemon.
/// The daemon runs as a launchd-managed process so it survives Kouen.app
/// quitting, system logout, and macOS user-session reboot. Both Kouen.app and
/// `kouen-cli install` use the same installer so behavior is consistent.
public enum LaunchAgentInstaller {
    public struct InstallReport: Sendable {
        public let plistPath: URL
        public let daemonPath: URL
        public let wasAlreadyInstalled: Bool
        public let bootstrapped: Bool
    }

    public enum InstallError: Error, CustomStringConvertible {
        case daemonNotFound(URL)
        case writeFailed(URL, Error)
        case launchctlFailed(Int32, String)

        public var description: String {
            switch self {
            case let .daemonNotFound(url):
                return "KouenDaemon executable not found at \(url.path)"
            case let .writeFailed(url, error):
                return "Failed to write LaunchAgent plist at \(url.path): \(error)"
            case let .launchctlFailed(code, output):
                return "launchctl exited with status \(code): \(output)"
            }
        }
    }

    /// `mobileBridgePort` nil = P25 mobile pairing bridge stays off (default); a value enables
    /// it in the launchd-supervised production daemon by setting the same env var
    /// `Scripts/mobile-web.sh` uses for the isolated dev daemon (`MobileBridgeServer.swift`
    /// only starts when it sees `KOUEN_MOBILE_BRIDGE_PORT` at process launch).
    public static func plist(daemonPath: URL, kouenHome: URL, logPath: URL, mobileBridgePort: UInt16? = nil) -> String {
        let mobileBridgeEnvXML = mobileBridgePort.map {
            """

                <key>KOUEN_MOBILE_BRIDGE_PORT</key>
                <string>\($0)</string>
            """
        } ?? ""
        return """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>Label</key>
            <string>\(KouenPaths.launchAgentLabel)</string>
            <key>ProgramArguments</key>
            <array>
                <string>\(daemonPath.path)</string>
            </array>
            <key>EnvironmentVariables</key>
            <dict>
                <key>KOUEN_HOME</key>
                <string>\(kouenHome.path)</string>\(mobileBridgeEnvXML)
            </dict>
            <key>RunAtLoad</key>
            <true/>
            <key>KeepAlive</key>
            <dict>
                <key>SuccessfulExit</key>
                <false/>
                <key>Crashed</key>
                <true/>
            </dict>
            <key>ProcessType</key>
            <string>Interactive</string>
            <key>StandardOutPath</key>
            <string>\(logPath.path)</string>
            <key>StandardErrorPath</key>
            <string>\(logPath.path)</string>
            <key>ThrottleInterval</key>
            <integer>5</integer>
        </dict>
        </plist>
        """
    }

    /// Write the plist and bootstrap it into launchd. Idempotent: if the plist
    /// already exists with identical content and the service is loaded, this is
    /// a no-op. If content differs, we `bootout` the old service first so the
    /// new configuration takes effect.
    @discardableResult
    public static func install(
        daemonPath: URL,
        kouenHome: URL = KouenPaths.applicationSupport,
        mobileBridgePort: UInt16? = nil
    ) throws -> InstallReport {
        guard FileManager.default.fileExists(atPath: daemonPath.path) else {
            throw InstallError.daemonNotFound(daemonPath)
        }
        try KouenPaths.ensureDirectories()
        let plistURL = KouenPaths.launchAgentURL
        try FileManager.default.createDirectory(at: plistURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        let logURL = KouenPaths.daemonLogURL
        let desired = plist(daemonPath: daemonPath, kouenHome: kouenHome, logPath: logURL, mobileBridgePort: mobileBridgePort)
        let existed = FileManager.default.fileExists(atPath: plistURL.path)
        let existingContent = existed ? (try? String(contentsOf: plistURL, encoding: .utf8)) : nil
        let changed = existingContent != desired

        if changed {
            if existed {
                _ = runLaunchctl(["bootout", "gui/\(getuid())", plistURL.path])
            }
            do {
                try desired.write(to: plistURL, atomically: true, encoding: .utf8)
            } catch {
                throw InstallError.writeFailed(plistURL, error)
            }
        }

        let bootstrapResult = runLaunchctl(["bootstrap", "gui/\(getuid())", plistURL.path])
        // `bootstrap` returns non-zero if the service is already loaded — that's
        // fine when the content matches. Treat status 37 (already-loaded) and 0
        // as success; surface other failures.
        let bootstrapped: Bool
        switch bootstrapResult.status {
        case 0:
            bootstrapped = true
        case 37, 5: // service already bootstrapped / busy
            bootstrapped = false
        default:
            throw InstallError.launchctlFailed(bootstrapResult.status, bootstrapResult.output)
        }
        _ = runLaunchctl(["enable", "gui/\(getuid())/\(KouenPaths.launchAgentLabel)"])
        return InstallReport(
            plistPath: plistURL,
            daemonPath: daemonPath,
            wasAlreadyInstalled: existed && !changed,
            bootstrapped: bootstrapped
        )
    }

    /// Tear down and remove. Used by an uninstaller. Best-effort; failure on a
    /// missing service is not an error.
    public static func uninstall() {
        let plistURL = KouenPaths.launchAgentURL
        _ = runLaunchctl(["bootout", "gui/\(getuid())", plistURL.path])
        try? FileManager.default.removeItem(at: plistURL)
    }

    public static var isInstalled: Bool {
        FileManager.default.fileExists(atPath: KouenPaths.launchAgentURL.path)
    }

    /// Ask launchd to relaunch the daemon (used after the app updates and the
    /// daemon executable on disk changes). Best-effort.
    public static func relaunch() {
        _ = runLaunchctl(["kickstart", "-k", "gui/\(getuid())/\(KouenPaths.launchAgentLabel)"])
    }

    private static func runLaunchctl(_ arguments: [String]) -> (status: Int32, output: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        process.arguments = arguments
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        do {
            try process.run()
        } catch {
            return (-1, "Failed to launch /bin/launchctl: \(error)")
        }
        process.waitUntilExit()
        let data = (try? pipe.fileHandleForReading.readToEnd()) ?? Data()
        return (process.terminationStatus, String(data: data, encoding: .utf8) ?? "")
    }
}
