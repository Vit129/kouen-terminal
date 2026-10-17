// Generated from the CHANGELOG.md [4.21.9] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "4.21.9",
        changelogDigest: "5c5f530c1d65e227",
        sections: [
            Section(title: "Added", items: [
                "Black theme and the sidebar's real agent brand icons (136b230)",
                "Remove the \"Isolate into worktree\" banner (7884b58)",
            ]),
            Section(title: "Fixed", items: [
                "Show agy CLI transcript and stop breaking Thai text on the phone (68c4c8b)",
                "Print a loopback pairing URL for opening the page on the Mac itself (2b7f3e4)",
                "Ping the socket so a dead iOS connection reconnects on return (7f894aa)",
            ]),
        ]
    )
}
