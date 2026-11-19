import Foundation

/// Runs git for repositories opened in the Git panel.
/// Arguments stay positional so commit messages and paths never become shell source.
public enum GitCommitCommand {
    public static func run(_ arguments: [String], in directory: String) -> ProcessResult {
        let isCommit = arguments.first == "commit"
        let command = ["/bin/bash", "-c", #"exec /usr/bin/git "$@" </dev/null"#, "kouen-git"] + arguments
        return ProcessRunner.run(
            executable: "/usr/bin/env",
            arguments: ["GIT_TERMINAL_PROMPT=0"] + command,
            in: directory,
            timeout: isCommit ? 660 : 60
        )
    }
}
