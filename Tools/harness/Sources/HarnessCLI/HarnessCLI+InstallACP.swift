#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif
import Foundation
import HarnessCore

extension HarnessCLI {
    /// `harness-cli install-acp [--claude] [--codex] [--all]`
    ///
    /// Installs ACP adapter packages that let Harness launch Claude Code and Codex as
    /// ACP agents (JSON-RPC 2.0 over stdio with Content-Length framing). Requires npm.
    ///
    /// The adapters are official Zed-sponsored packages:
    ///   @zed-industries/claude-code-acp  → binary: claude-code-acp
    ///   @zed-industries/codex-acp        → binary: codex-acp
    ///
    /// After install, open Harness > Settings > Agents and toggle "Chat" on for each agent.
    static func handleInstallACP(_ args: [String]) throws {
        let wantsClaude = args.contains("--claude")
        let wantsCodex = args.contains("--codex")
        let all = (!wantsClaude && !wantsCodex) || args.contains("--all")

        guard let npm = findNPM() else {
            fputs(
                "install-acp: npm not found.\n"
                    + "  Install Node.js/npm first: https://nodejs.org\n"
                    + "  Or via Homebrew: brew install node\n",
                harnessStderr
            )
            exit(1)
        }

        var packages: [(package: String, binary: String)] = []
        if all || wantsClaude {
            packages.append((package: "@zed-industries/claude-code-acp", binary: "claude-code-acp"))
        }
        if all || wantsCodex {
            packages.append((package: "@zed-industries/codex-acp", binary: "codex-acp"))
        }

        var allOK = true
        for (package, binary) in packages {
            print("Installing \(package)…")
            let ok = runNPMInstall(npm: npm, package: package)
            if ok {
                if let path = which(binary) {
                    print("  ✓ \(binary) → \(path)")
                } else {
                    print("  ✓ installed (binary location: run 'which \(binary)' to verify)")
                }
            } else {
                fputs("  ✗ failed to install \(package)\n", harnessStderr)
                allOK = false
            }
        }

        if allOK {
            print(
                "\nDone. Open Harness > Settings > Agents and toggle \"Chat\" on for each agent."
            )
        } else {
            fputs("\nOne or more packages failed. Check npm output above.\n", harnessStderr)
            exit(1)
        }
    }

    // MARK: - Private helpers

    private static func runNPMInstall(npm: String, package: String) -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: npm)
        process.arguments = ["install", "-g", package]
        process.standardOutput = FileHandle.standardOutput
        process.standardError = FileHandle.standardError
        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0
        } catch {
            fputs("install-acp: failed to run npm: \(error.localizedDescription)\n", harnessStderr)
            return false
        }
    }

    private static func findNPM() -> String? {
        let candidates = [
            "/usr/local/bin/npm",
            "/opt/homebrew/bin/npm",
        ]
        if let found = candidates.first(where: { FileManager.default.isExecutableFile(atPath: $0) }) {
            return found
        }
        return which("npm")
    }

    private static func which(_ binary: String) -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        process.arguments = [binary]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice
        try? process.run()
        process.waitUntilExit()
        guard process.terminationStatus == 0 else { return nil }
        let raw = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        let path = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return path.isEmpty ? nil : path
    }
}
