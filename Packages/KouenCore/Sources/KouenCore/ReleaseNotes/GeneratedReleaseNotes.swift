// Generated from the CHANGELOG.md [4.21.1] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "4.21.1",
        changelogDigest: "fee67836de34d5fc",
        sections: [
            Section(title: "Added", items: [
                "Full session coverage and surface tagging across Antigravity, Codex and Copilot (P55) (9ed39f5)",
                "Cross-repo task grouping, selected row detail expansion, and search highlighting (P52 Phase 2) (7dd5763)",
                "Advanced search (position indicators, topic segments, semantic fallback, graphify enrichment) (#85) (52337e1)",
            ]),
            Section(title: "Fixed", items: [
                "Keep sessions visible after schema bumps and cross-repo grouping (P52-P55 review) (5c62a87)",
            ]),
        ]
    )
}
