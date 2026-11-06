// Generated from the CHANGELOG.md [4.22.12] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "4.22.12",
        changelogDigest: "e0ed8548e07797d5",
        sections: [
            Section(title: "Documentation", items: [
                "Record that the fleet/tab-bar memory guards have landed (29e70e0)",
            ]),
            Section(title: "Fixed", items: [
                "Stop fleet/tab-bar republishing on unchanged snapshots (8901aa8)",
                "Drain autoreleased JSON per transcript during history scans (9ea7cf1)",
            ]),
        ]
    )
}
