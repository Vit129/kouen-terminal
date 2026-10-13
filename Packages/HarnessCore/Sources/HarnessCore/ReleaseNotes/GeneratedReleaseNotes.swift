// Generated from the CHANGELOG.md [2.4.0] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "2.4.0",
        changelogDigest: "0b6a79c63e3b0d96",
        sections: [
            Section(title: "Added", items: [
                "Appearance settings open with a live preview of the selected theme, font, line height, and cell width",
                "Interface text size (Small, Default, Large) scales the sidebar, tab bar, pane headers, status bar, and Settings",
                "Line height and cell width settings adjust terminal spacing while keeping glyphs centered in their cells",
                "Pane headers can be hidden when a tab has a single pane",
                "⌘-click opens path:line:column references from terminal output in your default text editor",
                "A key binding editor covers prefix, no-prefix, and copy-mode keys",
                "Settings search finds individual controls, every daemon option is editable in Settings, and a diagnostics report can be copied from Settings",
                "daemon-stats reports daemon and session-host memory",
            ]),
            Section(title: "Changed", items: [
                "Coding-tool icons sit on the same dark rounded tile as the shell prompt in tabs, sidebar rows, Overview, and Agents settings",
                "Harness follows Reduce Transparency, Increase Contrast, and Differentiate Without Color",
                "Sidebar and pane motion share one display-synchronized animation",
                "The Appearance “Persist scrollback” switch is removed",
                "Release executables are stripped, and each release includes matching debug symbols",
            ]),
            Section(title: "Fixed", items: [
                "Background services exit cleanly when they are stopped, restarted, or replaced",
                "A background service that finds another one already running exits successfully",
                "Reconnecting starts the installed launchd service when it is loaded but idle, so the service stays supervised instead of running as an unsupervised fallback",
                "Session-service startup removes control sockets left behind by crashed daemon workers",
                "Toggling the sidebar with split panes no longer crashes",
                "Wide characters such as emoji and CJK text keep their spacing through resize reflow, copy, and alternate-screen shrink, including sessions saved by earlier versions",
                "Ctrl-C interrupts a foreground job even behind a large paste",
                "Find results stay visible while output streams",
                "The tab location and new-tab directory follow the foreground job, not a background job in another directory",
                "A resize that times out mid-commit no longer rolls back a size the terminal already took, and the session host survives a terminal hangup",
                "New shells start without a long pause when Harness inherits a very high open-file limit",
                "⌘-hover link detection is cheaper, mouse drag reports are deduplicated, and clicks in pane padding stay local",
                "The copy notice and status line no longer leak their monitor and timer",
                "Read-only connections refuse writes with a clear error instead of silently ignoring them, and tunnel status stays accurate",
            ]),
            Section(title: "Security", items: [
                "ssh, telnet, and man links refuse option-shaped operands",
                "Session-host listeners are hardened like the daemon socket",
                "OSC, DCS, and APC payloads beyond their size cap are dropped",
                "Pastes that need confirmation but cannot be confirmed are refused instead of delivered",
                "Hook if-shell and run-shell -b commands are bounded by a deadline and an output cap",
                "Scrollback append files are closed exactly once",
            ]),
        ]
    )
}
