// Generated from the CHANGELOG.md [3.5.3] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "3.5.3",
        changelogDigest: "2f1518188ffa4ddf",
        sections: [
            Section(title: "Added", items: [
                "File click action setting — choose preview, editor, vi, cat, or terminal-only",
                "Tab pill: branch name as primary title, repo name as context subtitle",
                "Sidebar worktree grouping fix — uses parentRepoPath for correct repo grouping",
                "harness-cli install-tools — one command to install zoxide, fd, fzf, rg, bat, eza, jq, lazygit",
                "⌘⇧I toggles the Agent Notch panel so you can select the notifying agent directly",
                "⌘⇧U opens the Notifications inbox/dropdown",
                "Agent Notch rows show both agent and source tab/session so notifications are easier to trace",
                "Persistent notch peek — notification stays until user clicks",
                "macOS native toast notifications for agent done/waiting (osascript fallback)",
                "Always auto-isolate worktrees on branch switch (not config-gated)",
            ]),
        ]
    )
}
