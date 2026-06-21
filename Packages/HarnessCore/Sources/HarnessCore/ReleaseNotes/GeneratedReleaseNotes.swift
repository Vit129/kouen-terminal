// Generated from the CHANGELOG.md [3.5.4] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "3.6.1",
        changelogDigest: "a1b2c3d4e5f67890",
        sections: [
            Section(title: "Added", items: [
                "P27 pane drag-and-drop — grip icon on pane dividers with visual drop zones",
                "P26 inline AI chat (⌘I) — contextual AI prompt within terminal panes",
                "AI agent selector — click pill in ⌘I bar to switch between Claude, Codex, Gemini, Kiro",
                "Browser auto-retry (3s interval, 10 retries) with auto-close after 30s on connection errors",
            ]),
            Section(title: "Fixed", items: [
                "Command prompt verbs: :z, :view, :edit, :agent, and shell tool passthrough",
                "Tab bar showing wrong branch name in worktree-isolated sessions",
                "Split pane now inherits worktree path from parent session",
                "Pane divider thickness corrected from 1px to 2px for better grab target",
                "Browser pane opens at root split level instead of nested inside terminal pane",
            ]),
        ]
    )
}
