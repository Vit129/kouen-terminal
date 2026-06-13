// Generated from the CHANGELOG.md [1.12.0] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "1.12.0",
        changelogDigest: "7a46b38806e9f7bb",
        sections: [
            Section(title: "Added", items: [
                "Output triggers",
                "Per-host and per-command theme profiles",
                "Hover-reveal pane close",
                "Prompt navigation",
                "#{command_duration} format token",
                "End-to-end typing latency is now measurable",
            ]),
            Section(title: "Changed", items: [
                "The command palette now covers the full command vocabulary",
            ]),
            Section(title: "Fixed", items: [
                "Reopening the app no longer types stray characters at the prompt",
                "Selections survive scrolling",
            ]),
        ]
    )
}
