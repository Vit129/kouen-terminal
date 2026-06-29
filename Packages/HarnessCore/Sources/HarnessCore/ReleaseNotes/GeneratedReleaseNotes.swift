// Generated from the CHANGELOG.md [3.11.7] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "3.11.7",
        changelogDigest: "402d387f38091a08",
        sections: [
            Section(title: "Added", items: [
                "AI chat input bar: model picker pill and effort picker pill — select model override (e.g",
                "AIAgentConfig gains activeModel and activeEffort fields, persisted per agent kind",
            ]),
            Section(title: "Fixed", items: [
                "CPU peaks on every daemon snapshot change: all 5 UI snapshot observers now skip Phase-1 revision pings (no typed payload) and act only on Phase-2 (real flags)",
                "SessionCoordinator coalesces burst Phase-1 pings via SnapshotCoalescer so rapid cwdTimer / agent-scanner commits collapse to one scheduleSnapshotRefresh() per runloop turn",
                "FrecencyDirectoryStore directory entries now capped at 500; lowest-scored entries evicted on overflow",
            ]),
            Section(title: "Internal", items: [
                "Retire guard (check_retire_coverage.py) extended with --mode filter for snapshot-sweep cleanup pattern; Leak D robot test enforces this for NotificationCoordinator",
            ]),
        ]
    )
}
