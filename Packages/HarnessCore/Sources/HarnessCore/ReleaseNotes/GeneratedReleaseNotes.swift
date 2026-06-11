// Generated from the CHANGELOG.md [2.2.4] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "2.2.4",
        changelogDigest: "9fb8fc77e84d5057",
        sections: [
            Section(title: "Added", items: [
                "File preview live reload",
            ]),
            Section(title: "Fixed", items: [
                "Terminal rendering corruption from interleaved status messages",
                "Sidebar disappears after collapse-then-expand with \"Always collapse sidebar on launch\" enabled",
            ]),
        ]
    )
}
