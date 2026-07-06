import Foundation

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
        fputs("install-tools: Homebrew not found. Install from https://brew.sh first.\n", stderr)
        return
    }

    fputs("Installing recommended shell tools via Homebrew...\n\n", stdout)

    var installed: [String] = []
    var skipped: [String] = []
    var failed: [String] = []

    for tool in tools {
        fputs("  \(tool.formula) — \(tool.description)\n", stdout)

        // Check if already installed
        let whichProcess = Process()
        whichProcess.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        whichProcess.arguments = [tool.formula == "ripgrep" ? "rg" : tool.formula]
        whichProcess.standardOutput = FileHandle.nullDevice
        whichProcess.standardError = FileHandle.nullDevice
        try? whichProcess.run()
        whichProcess.waitUntilExit()
        if whichProcess.terminationStatus == 0 {
            fputs("    ✓ already installed\n", stdout)
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
                fputs("    ✓ installed\n", stdout)
                installed.append(tool.formula)
            } else {
                fputs("    ✗ failed\n", stderr)
                failed.append(tool.formula)
            }
        } catch {
            fputs("    ✗ error: \(error.localizedDescription)\n", stderr)
            failed.append(tool.formula)
        }
    }

    // Shell integration hints
    fputs("\n", stdout)
    if !installed.isEmpty || !skipped.isEmpty {
        fputs("Shell integration (add to ~/.zshrc):\n", stdout)
        fputs("  eval \"$(zoxide init zsh)\"\n", stdout)
        fputs("  source <(fzf --zsh)\n", stdout)
        fputs("\n", stdout)
    }

    // Summary
    let total = installed.count + skipped.count
    fputs("Done: \(total)/\(tools.count) ready", stdout)
    if !installed.isEmpty { fputs(" (\(installed.count) new)", stdout) }
    if !failed.isEmpty { fputs(", \(failed.count) failed: \(failed.joined(separator: ", "))", stderr) }
    fputs("\n", stdout)
}
