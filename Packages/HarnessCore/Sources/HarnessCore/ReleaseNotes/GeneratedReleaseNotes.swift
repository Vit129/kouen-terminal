// Generated from the CHANGELOG.md [3.9.4] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "3.9.4",
        changelogDigest: "33eb4ee89da9d1a9",
        sections: [
            Section(title: "Added", items: [
                "Commit & Push",
                "harness cat displays line numbers in the gutter; line numbers are excluded from copy selection",
            ]),
            Section(title: "Fixed", items: [
                "Long-session memory leak",
                "Long-session memory leak",
                "Unclaimed TerminalHostView held in memory after PaneContainerView rebuild, retaining the entire per-pane terminal graph",
                "Git push could hang indefinitely in the daemon under certain conditions",
                "Git panel double-refreshed (brief blink) immediately after a commit or push",
            ]),
        ]
    )
}
