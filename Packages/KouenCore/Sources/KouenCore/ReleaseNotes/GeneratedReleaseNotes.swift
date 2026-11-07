// Generated from the CHANGELOG.md [4.22.13] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "4.22.13",
        changelogDigest: "6da87c4cdd59db55",
        sections: [
            Section(title: "Fixed", items: [
                "Stop ProcessRunner.run from blocking forever on an open pipe (a530bcb)",
            ]),
        ]
    )
}
