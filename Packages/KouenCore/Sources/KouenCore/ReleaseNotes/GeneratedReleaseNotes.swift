// Generated from the CHANGELOG.md [4.22.7] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "4.22.7",
        changelogDigest: "aaf1ff3658758f4f",
        sections: [
            Section(title: "Fixed", items: [
                "Refuse a version build that rolls backwards (3679c49)",
                "Keep the live browser pane on cmd+B and fully dispose panes on close (a1a40e1)",
            ]),
        ]
    )
}
