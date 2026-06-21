// Generated from the CHANGELOG.md [3.5.4] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "3.5.4",
        changelogDigest: "a0b1c2d3e4f5g6h7",
        sections: [
            Section(title: "Fixed", items: [
                ":z, :view, :edit, :e, :split, :vsplit, :agent — wired missing command prompt verbs",
                ":fzf, :zi, :rg, :fd, :bat, :eza, :jq — shell tool passthrough from command prompt",
                ":z uses zoxide query fallback when path doesn't exist on disk",
            ]),
        ]
    )
}
