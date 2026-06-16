// Generated from the CHANGELOG.md [3.1.3] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "3.1.3",
        changelogDigest: "4b62b327edec7abf",
        sections: [
            Section(title: "Fixed", items: [
                "App crash (EXC_BAD_ACCESS) on rapid session close/create",
                "Sidebar session tooltip showed full path",
                "Sessions on same branch hidden in sidebar",
                "Sidebar selection not synced on session switch",
                "File tree branch chip stale after tree refresh",
            ]),
        ]
    )
}
