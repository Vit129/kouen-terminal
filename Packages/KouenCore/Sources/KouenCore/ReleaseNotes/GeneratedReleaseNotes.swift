// Generated from the CHANGELOG.md [4.4.0] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "4.4.0",
        changelogDigest: "bf023bec7e901f4a",
        sections: [
            Section(title: "Added", items: [
                "P39 competitive-gap closes — SSH agent forwarding, sidebar port badge, git hunk staging, in-app PR merge, fleet visibility badge (4e6549e)",
                "Add Tasks/Worktree/Hosts MCP tools and Automations scheduler (release v5.0.0) (97180fd)",
            ]),
            Section(title: "Fixed", items: [
                "Reload MCP tool policy on every check, not once at construction (7678351)",
                "Move Cmd+F find bar below pane's browser/split/close icon row (1d796a5)",
                "Mobile pairing rejected every real device because the token rotated out before connect (c8bd2bc)",
                "Browser pane sends a real Safari UA so Google/Apple OAuth doesn't reject it (e955924)",
                "Correct release to v4.4.0 (was mistakenly major-bumped) and scope kouenBrowserOpen to the calling agent's own session (eed2a9f)",
            ]),
        ]
    )
}
