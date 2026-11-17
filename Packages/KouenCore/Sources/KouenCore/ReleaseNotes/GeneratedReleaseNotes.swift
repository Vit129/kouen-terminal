// Generated from the CHANGELOG.md [4.22.16] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "4.22.16",
        changelogDigest: "6ab03f3733c6552f",
        sections: [
            Section(title: "Changed", items: [
                "Arm only for the focused pane, scan off main with carry-over (e3630f0)",
                "Cap network-capture body reads, skip streams and unbounded bodies (b340767)",
                "Feed coalesced output in capped slices (a3436cd)",
                "Skip the 0.5s cwd probe for silent surfaces (c10339d)",
            ]),
            Section(title: "Documentation", items: [
                "Retain verified Kouen query results (9521d67)",
                "Retain wave 1 query result (34a8d4e)",
            ]),
            Section(title: "Fixed", items: [
                "Preserve staged index when restoring checkpoint (8729b55)",
                "Match output triggers split across chunks (fc27787)",
                "Cap console log line length (05f5cee)",
                "Encode typed text as a JSON string literal (2f4f7ea)",
                "Stop busy-spinning on a failed read after POLLERR (b485e3c)",
                "Preserve output triggers and reject stale secure input scans (8cc3b2a)",
                "Avoid recursive locking during feature sweep (90e72de)",
                "Require Bearer authentication and validate HTTP origins (5ed642c)",
                "Sanitize markdown and restrict local image access (498b90a)",
                "Drop async replies whose connection is gone (552ed79)",
                "Reject malformed or oversized Content-Length before auth (488cc7a)",
                "Clamp waitForLoad timeout before UInt64 conversion (d9a74e1)",
                "Ignore stale onEnd after switchEndpoint (7173e56)",
                "Re-attach local browser panes by tab id, not index (d6ef9c6)",
                "Run worktree git and archive script off the registry lock (ab8580d)",
                "Discard setup log creation result on Linux (57aa16e)",
            ]),
        ]
    )
}
