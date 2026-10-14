// Generated from the CHANGELOG.md [4.21.7] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "4.21.7",
        changelogDigest: "cbfcf0683f5f7ebb",
        sections: [
            Section(title: "Added", items: [
                "Ask before isolating a tab instead of moving the shared folder (47a7bf6)",
            ]),
            Section(title: "Changed", items: [
                "Split MobileBridgeServer so connection, text wrap and per-agent model/effort are findable on their own (6d6e45b)",
            ]),
            Section(title: "Fixed", items: [
                "Re-enable IPC worktreeCreate and run setupScript in each new worktree (7161134)",
                "Recompute isolation notices on snapshot apply, not only on the branch ping (114e856)",
                "Separate connecting logic and dynamically discover tailscale (b4e5c80)",
            ]),
        ]
    )
}
