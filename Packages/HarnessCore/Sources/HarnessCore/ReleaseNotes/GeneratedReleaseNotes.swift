// Generated from the CHANGELOG.md [3.1.4] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "3.2.0",
        changelogDigest: "1829ac274cec80db",
        sections: [
            Section(title: "Fixed", items: [
                "File tree crash (EXC_BAD_ACCESS in swift_getObjectType)",
                "Duplicate .task(id: taskID) in FileTreeSwiftUIView",
            ]),
        ]
    )
}
