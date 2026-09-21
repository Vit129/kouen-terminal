// Generated from the CHANGELOG.md [4.18.0] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "4.18.0",
        changelogDigest: "667b49150b83a332",
        sections: [
            Section(title: "Added", items: [
                "Auto-show job result on run-now + scheduled runs (ce56d8d)",
                "Harden multi-agent attention & write safety (P46 Pillar 6) (28585cf)",
                "Complete P46 CLI-First Agent Harness (phases 1-4) (9a7eda8)",
                "Plan-46-agent-dev-env-completely (release v4.18.0) (b951db9)",
            ]),
            Section(title: "Documentation", items: [
                "Add document for kouen agent dev env terminal (68edb71)",
            ]),
            Section(title: "Fixed", items: [
                "Close P46 follow-up gaps — verification timeout, dirty-tree guard, feed-to-agent (6014b78)",
                "Row click did nothing — .onTapGesture inside List is a no-op on macOS (06153c2)",
                "Make PR and no-PR release paths behave identically (61ff7d7)",
            ]),
        ]
    )
}
