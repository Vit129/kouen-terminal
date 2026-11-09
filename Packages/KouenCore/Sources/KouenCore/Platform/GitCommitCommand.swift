import Foundation

/// Prepares the graph in the target repository, including repositories opened in the Git panel.
/// Arguments stay positional so commit messages and paths never become shell source.
public enum GitCommitCommand {
    public static func run(_ arguments: [String], in directory: String) -> ProcessResult {
        let isCommit = arguments.first == "commit"
        let command = isCommit
            ? ["/bin/bash", "-c", preparation, "kouen-graphify-commit"] + arguments
            : ["/bin/bash", "-c", #"exec /usr/bin/git "$@" </dev/null"#, "kouen-git"] + arguments
        return ProcessRunner.run(
            executable: "/usr/bin/env",
            arguments: ["GIT_TERMINAL_PROMPT=0"] + command,
            in: directory,
            timeout: isCommit ? 660 : 60
        )
    }

    private static let preparation = #"""
    set -euo pipefail
    exec </dev/null
    root=$(git rev-parse --show-toplevel)
    cd "$root"
    # Repositories without a graph commit as before; only Graphify repos are prepared.
    [[ -d graphify-out ]] || exec git "$@"
    graphify_bin=$(command -v graphify || true)
    if [[ -z "$graphify_bin" && -x "$HOME/.local/bin/graphify" ]]; then graphify_bin="$HOME/.local/bin/graphify"; fi
    [[ -n "$graphify_bin" ]] || { echo "Graphify is not installed; stopping before commit." >&2; exit 1; }
    PYTHONHASHSEED=0 "$graphify_bin" update .
    tracked=()
    while IFS= read -r -d '' file; do tracked+=("$file"); done < <(git ls-files -z -- graphify-out/)
    if ((${#tracked[@]})); then git add --update -- "${tracked[@]}"; fi
    exec env GRAPHIFY_SKIP_HOOK=1 git "$@"
    """#
}
