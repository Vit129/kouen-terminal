// Generated from the CHANGELOG.md [4.22.8] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "4.22.8",
        changelogDigest: "f37180299d8695ed",
        sections: [
            Section(title: "Fixed", items: [
                "Generate GitHub release notes from HEAD, not the not-yet-created tag (4f48ebd)",
                "Keep CFBundleVersion above every build ever shipped (35c0fc2)",
            ]),
        ]
    )
}
