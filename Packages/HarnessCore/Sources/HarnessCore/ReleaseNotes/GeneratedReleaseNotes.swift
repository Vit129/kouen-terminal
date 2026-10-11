// Generated from the CHANGELOG.md [2.3.0] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "2.3.0",
        changelogDigest: "9d3a1ab5893e0dcf",
        sections: [
            Section(title: "Added", items: [
                "Stable text anchors keep selections, reading positions, and search results attached to their text through resizing and history movement",
                "Precise command regions support copying commands or output, selecting output, searching within a command's output, and navigating failed commands",
                "Checksum-pinned Unicode 18 grapheme segmentation, mode 2027 support, and shared engine text layout for composed input and terminal overlays",
                "Ordered fallback font families and OpenType feature controls in Terminal settings, including matching Overview thumbnails",
            ]),
            Section(title: "Changed", items: [
                "Terminal parsing, row damage, packed history, render snapshots, and GPU encoding reduce repeated work",
                "PTY transport batches reads, bounds write and replay queues, and acknowledges output after consumption",
                "Agent and settings observation uses shared caches and event-driven updates with bounded fallback work",
                "Internal session-host protocol is now 10 and terminal checkpoints use schema 2",
            ]),
            Section(title: "Fixed", items: [
                "Windows apply their saved sidebar state and final geometry before presentation, eliminating the initial half-width sidebar jump",
                "Agent activity records kernel process exits even before the parent reaps the process, retaining the final hook status",
                "Startup no longer invents a temporary terminal or attempts to attach it before the daemon's real snapshot arrives",
                "Sidebar collapse, tab creation, and hidden connection notices avoid conflicting layout constraints during installation and resizing",
                "Malformed output sequence spans are rejected before arithmetic can overflow",
                "Render completion ordering, replay consumption fences, history restoration, and selection invalidation retain their current operation identity through resize, reconnect, and remount",
            ]),
        ]
    )
}
