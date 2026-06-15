// Generated from the CHANGELOG.md [2.7.1] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "2.7.1",
        changelogDigest: "98c7ed48b42a6406",
        sections: [
            Section(title: "Fixed", items: [
                "Browser Pane close button now works",
                "Browser Pane toolbar buttons no longer blocked by a hidden error banner",
            ]),
            Section(title: "Added", items: [
                "⌘B opens a new Browser Pane",
                "Clicking a localhost or LAN dev-server link in terminal output opens it in the in-app Browser Pane",
            ]),
        ]
    )
}
