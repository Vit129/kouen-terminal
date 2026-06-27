// Generated from the CHANGELOG.md [3.9.5] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "3.9.5",
        changelogDigest: "1b14d8f201157c87",
        sections: [
            Section(title: "Added", items: [
                "Vimium-style hint mode (Cmd+Shift+U) for keyboard link opening (cba7cdc)",
                "Harness view opens sidebar file viewer via OSC 7735 (8913672)",
                "Harness cat shows line numbers that are excluded from copy (22f4dd5)",
                "Add Commit & Push to Sync menu (e902d2e)",
            ]),
            Section(title: "Documentation", items: [
                "Update agent-memory with RL-056/057/058 and CASE-039/040/041 (4b9eb22)",
                "Strip global-duplicate sections from CLAUDE.md (7bb5578)",
                "Record memory-leak audit findings + onRetire fix pattern (8af2790)",
                "Add memory-leak-audit case study + update graphify for v3.9.4 (120acf3)",
                "Bump version to v3.9.4 + note Commit & Push shortcut in README (5720d01)",
                "Note long-session memory stability in README (53aefa9)",
            ]),
            Section(title: "Fixed", items: [
                "Fix button hit-testing, sidebar toggle, and browser log freeze (aeadae9)",
                "Remove adjustSubviews() calls that caused terminal blink regression (b55cc62)",
                "Browser cannot show in cmd+b and browser button (e530205)",
                "Browser pane reuse guidance and skill routing paths (9bd07a4)",
                "Replace graphify CLI trigger with graph-report skill (528c166)",
                "Cmd+W closes browser pane (intercept before WKWebView consumes it) (02e49cd)",
                "Disarm prefix key on mouse click to prevent swallowing Cmd+\\ (fd7a5f0)",
                "Prevent git panel double-refresh blink after commit/push (c9dc884)",
                "Prevent git push from hanging in daemon (1ddc27d)",
                "Release unclaimed TerminalHostViews after PaneContainerView build (0430ed8)",
                "Stop per-pane AI controllers and browser network log from leaking (e642997)",
                "Memory leak audit — pane lifecycle + AI controller cleanup (38fa427)",
                "Don't fail make install when open has no window server (9d7de27)",
                "Pin session worktree to shell cwd, not deepest foreground descendant (8ad328d)",
            ]),
        ]
    )
}
