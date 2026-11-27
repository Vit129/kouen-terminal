// Generated from the CHANGELOG.md [4.24.3] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "4.24.3",
        changelogDigest: "fe8204a7536077df",
        sections: [
            Section(title: "Documentation", items: [
                "Allow headless packages in the CLI thin-client rule (2d8d199)",
                "Move older changelog entries to archive (#165) (3323bda)",
            ]),
            Section(title: "Fixed", items: [
                "Regenerate release notes for v4.24.2 (3a2141d)",
                "Restore Kouen subprocess and daemon checks (380acd7)",
                "Guard FileManager.trashItem to Darwin (df75a23)",
            ]),
        ]
    )
}
