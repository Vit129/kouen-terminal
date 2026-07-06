import Foundation
import KouenCore

/// `kouen-cli install-tools` — installs recommended shell tools via Homebrew.
func handleInstallTools() {
    let tools: [(formula: String, description: String)] = [
        ("zoxide", "smart cd — learns your frequent dirs"),
        ("fd", "find files by name"),
        ("fzf", "fuzzy finder for files, history, anything"),
        ("ripgrep", "search file contents (rg)"),
        ("bat", "cat with syntax highlighting"),
        ("eza", "modern ls — colors, icons, git status"),
        ("jq", "parse & query JSON"),
        ("lazygit", "terminal UI for git"),
    ]

    // Check Homebrew
    let brewPath = ["/opt/homebrew/bin/brew", "/usr/local/bin/brew"]
        .first { FileManager.default.fileExists(atPath: $0) }
    guard let brew = brewPath else {
        fputs("install-tools: Homebrew not found. Install from https://brew.sh first.\n", kouenStderr)
        return
    }

    fputs("Installing recommended shell tools via Homebrew...\n\n", kouenStdout)

    var installed: [String] = []
    var skipped: [String] = []
    var failed: [String] = []

    for tool in tools {
        fputs("  \(tool.formula) — \(tool.description)\n", kouenStdout)

        // Check if already installed
        let whichProcess = Process()
        whichProcess.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        whichProcess.arguments = [tool.formula == "ripgrep" ? "rg" : tool.formula]
        whichProcess.standardOutput = FileHandle.nullDevice
        whichProcess.standardError = FileHandle.nullDevice
        try? whichProcess.run()
        whichProcess.waitUntilExit()
        if whichProcess.terminationStatus == 0 {
            fputs("    ✓ already installed\n", kouenStdout)
            skipped.append(tool.formula)
            continue
        }

        // Install
        let process = Process()
        process.executableURL = URL(fileURLWithPath: brew)
        process.arguments = ["install", tool.formula]
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        do {
            try process.run()
            process.waitUntilExit()
            if process.terminationStatus == 0 {
                fputs("    ✓ installed\n", kouenStdout)
                installed.append(tool.formula)
            } else {
                fputs("    ✗ failed\n", kouenStderr)
                failed.append(tool.formula)
            }
        } catch {
            fputs("    ✗ error: \(error.localizedDescription)\n", kouenStderr)
            failed.append(tool.formula)
        }
    }

    // Shell integration hints
    fputs("\n", kouenStdout)
    if !installed.isEmpty || !skipped.isEmpty {
        fputs("Shell integration (add to ~/.zshrc):\n", kouenStdout)
        fputs("  eval \"$(zoxide init zsh)\"\n", kouenStdout)
        fputs("  source <(fzf --zsh)\n", kouenStdout)
        fputs("\n", kouenStdout)
    }

    // Summary
    let total = installed.count + skipped.count
    fputs("Done: \(total)/\(tools.count) ready", kouenStdout)
    if !installed.isEmpty { fputs(" (\(installed.count) new)", kouenStdout) }
    if !failed.isEmpty { fputs(", \(failed.count) failed: \(failed.joined(separator: ", "))", kouenStderr) }
    fputs("\n", kouenStdout)
}
