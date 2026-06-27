// Generated from the CHANGELOG.md [3.10.1] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "3.10.1",
        changelogDigest: "60988de98ea55fd2",
        sections: [
            Section(title: "Added", items: [
                "Memory pressure monitor — trims inactive pane scrollback to 1 000 lines on warning, 0 on critical (~96 MB freed per idle session) (54f6a0b)",
                "Hint mode ⌘⇧U — Vimium-style keyboard URL picker overlay; home-row-biased labels, 3 s auto-dismiss (cba7cdc)",
                "Send selection → AI chat — right-click selected text → \"Ask AI…\" prefills ⌘I panel (b104eed)",
                "Scrollback search ⌘F — wires existing TerminalFindBar; rebinds Find in Files to ⌘⇧F (5fac8a7)",
                "Click-to-move cursor — single click on same row as cursor sends left/right arrow sequences (ee002b8)",
                "Auto Secure Input — SecureInputMonitor detects password prompts via PTY output and toggles macOS Secure Input API (be60091)",
                "Context-aware Ctrl+C — copies selection when text selected; PTY interrupt otherwise (649cf01)",
                "Composer ⌘⇧E — floating multi-line command editor; ⌘↩ sends to active PTY (f753a14)",
                "Prompt Queue ⌘⇧↩ — queues commands; each fires after previous shell prompt appears; floating status bar shows count (d9e74b9)",
                "Git branch in tab bar — instant update on cd via direct .git/HEAD read, no subprocess (649cf01)",
            ]),
            Section(title: "Fixed", items: [
                "AI chat ⌘I returned no output — pipe double-read anti-pattern in AgentProcessManager (160d064)",
                "NSEvent monitors leaked in KeyRecorderView, SyntaxTextView, ViExCommands, HarnessSidebarPanelVC — removed on deinit (6f9c155)",
                "GitPanelView triggered redundant UI rebuilds on every snapshot update (8841cc7)",
            ]),
        ]
    )
}
