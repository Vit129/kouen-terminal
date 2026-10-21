// Generated from the CHANGELOG.md [4.21.11] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "4.21.11",
        changelogDigest: "9e192ccde37243c4",
        sections: [
            Section(title: "Added", items: [
                "Reuse existing browser pane with new tab instead of splitting (2587335)",
            ]),
            Section(title: "Documentation", items: [
                "Relicense to Apache-2.0, keep the Harness MIT notice (6120233)",
                "Credit Claude as co-developer and contributor (5feea86)",
                "Add Installation section in README (395fe02)",
                "Slim README and move reference material to docs/ (b4f5e4a)",
            ]),
        ]
    )
}
