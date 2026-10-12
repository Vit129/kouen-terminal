// Generated from the CHANGELOG.md [4.21.2] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "4.21.2",
        changelogDigest: "ca2947e77698cbea",
        sections: [
            Section(title: "Added", items: [
                "P51 Kouen Companion PWA (plain text chat, diff/preview cards, draft PR, no terminal emulator) (66ecde7)",
                "Replace mockup preview with real browser mirror (6c2096a)",
                "Setup tailscale serve HTTPS pairing and clean up assets and fonts (9a859e6)",
                "P51 Kouen Companion PWA (waiting for claude review and testing) (ac6d1c3)",
                "Add kouen rc command to launch companion in Chrome (waiting for claude review and testing) (ecda596)",
                "Auto-open kouen rc when launching claude, agy, or codex (waiting for claude review and testing) (72f663a)",
                "Open the Kouen Companion when copilot starts in remote mode (64ceb73)",
            ]),
            Section(title: "Changed", items: [
                "Split history model, extract graphify cache, and deduplicate jsonl reader (a6d87d0)",
                "P52 history model separation and JSONL reader deduplication (waiting for claude review and testing) (7891523)",
            ]),
            Section(title: "Documentation", items: [
                "Update agent-memory location to central agent-memory-private (69116c1)",
            ]),
            Section(title: "Fixed", items: [
                "Align client ack key handling with draftPRCreated and fileAttached responses (fe24d77)",
                "Prevent XSS in PR cards and enforce session-scoped cwd (8054a4c)",
                "Prevent subprocess deadlocks and enforce timeouts on gh and git (85b5b99)",
                "Send attached file path to agent and submit with carriage return (28fa1e0)",
                "Make draft PR creation one-tap without confirmation sheet (e917cfd)",
                "Isolate release bump staging and guard dirty main in full-cycle (waiting for claude review and testing) (c68c7a7)",
                "Parse space-separated microsecond timestamps for Antigravity (dc4012a)",
                "Stop kouen rc from enabling the mobile bridge and hardcoding port 7777 (f413d48)",
                "Review fixes for the P56 companion and history follow-ups (ee243be)",
                "Find tailscale on Apple Silicon, block symlink cwd escape, drop guessed preview port (a00a6c4)",
                "Guard os.Logger so the Linux headless build compiles again (7706a53)",
                "Write kouen rc errors via FileHandle so Linux strict concurrency compiles (585d45a)",
            ]),
        ]
    )
}
