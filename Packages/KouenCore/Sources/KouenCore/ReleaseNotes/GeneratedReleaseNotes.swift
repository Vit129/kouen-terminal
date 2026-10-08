// Generated from the CHANGELOG.md [4.20.16] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "4.20.16",
        changelogDigest: "d2a83a84de7111c1",
        sections: [
            Section(title: "Added", items: [
                "Update scopes, date grouping and compact two-line rows (f39f223)",
                "Add ranked loose search matching for sessions (e747aaf)",
                "Add full transcript SQLite FTS5 index and incremental reindexing (598c894)",
                "Share one ranker between the sidebar and kouen history search (9753581)",
                "Redesign ui and ux in ai session history tab and add kouen-preview when use make preview (release v4.20.16) (e6a835e)",
            ]),
            Section(title: "Fixed", items: [
                "Address P52 review findings for repo root freeze, typing lag, FTS limit and tab disambiguation (e6a59f5)",
                "Weight query words by rarity so common words can't carry a match (4b9f016)",
                "Resume and hand-off open a new session, like Cmd+T (837afaf)",
                "Label preview builds \"Kouen Preview\" in the title bar (5f9b624)",
                "Expand sidebar width and floor for Kouen Preview header label (0b521f3)",
            ]),
        ]
    )
}
