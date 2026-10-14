// Generated from the CHANGELOG.md [2.4.1] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "2.4.1",
        changelogDigest: "0134c9979311756d",
        sections: [
            Section(title: "Fixed", items: [
                "Moving and quickly resizing terminal windows stays responsive while rendering catches up",
                "The host selector uses a native macOS menu control",
            ]),
        ]
    )
}
