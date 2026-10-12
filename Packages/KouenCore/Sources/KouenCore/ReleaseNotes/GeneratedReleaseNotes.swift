// Generated from the CHANGELOG.md [4.21.5] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "4.21.5",
        changelogDigest: "1ba4880f17ccccac",
        sections: [
            Section(title: "Added", items: [
                "Parse Claude transcript lines into typed items and tail them by offset (6cf8620)",
                "Push the attached agent's transcript to the Companion (d7df0d6)",
                "Render the Companion session as user/agent bubbles and tool rows (c058903)",
            ]),
        ]
    )
}
