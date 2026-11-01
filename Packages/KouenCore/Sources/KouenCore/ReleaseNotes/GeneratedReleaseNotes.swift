// Generated from the CHANGELOG.md [4.22.9] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "4.22.9",
        changelogDigest: "2c838d9bec73533d",
        sections: [
            Section(title: "Documentation", items: [
                "State the real reason the build number must not roll back (e3caa30)",
            ]),
            Section(title: "Fixed", items: [
                "Label generated release notes with the release tag (7ea98c3)",
                "Opt web views out of Extensible SSO so navigation cannot hang on AppSSO (780b5b8)",
            ]),
        ]
    )
}
