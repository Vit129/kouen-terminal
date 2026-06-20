// Generated from the CHANGELOG.md [3.4.0] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "3.4.0",
        changelogDigest: "56f804fa35b68c40",
        sections: [
            Section(title: "Added", items: [
                "GitHub PR/CI integration — sidebar badge click opens PR in browser pane, CI status indicators (✓/✗/○)",
                "Browser pane multi-tab support (tab bar, new tab, close tab, target=_blank handling)",
                "Auto-isolate worktrees on branch switch (when harness.json isolateAgents=true)",
                "Auto-archive worktrees on session close when branch merged",
                "Personal project config override (~/.config/harness/projects/)",
                ":recent scoped to current worktree, :make uses harness.json runScript",
                "Hover-to-reveal pane controls with button hover highlight",
                "⌘-click GitHub URLs opens in browser pane (not external browser)",
            ]),
        ]
    )
}
