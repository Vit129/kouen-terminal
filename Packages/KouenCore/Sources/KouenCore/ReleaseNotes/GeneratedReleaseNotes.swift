// Generated from the CHANGELOG.md [4.21.10] block by Scripts/generate-release-notes.swift.
// DO NOT EDIT BY HAND — regenerate in release prep after updating CHANGELOG.md:
//   swift Scripts/generate-release-notes.swift
// Drift guards: ReleaseNotesGuardTests (version + changelog digest), package-app.sh.

extension ReleaseNotes {
    public static let current = ReleaseNotes(
        version: "4.21.10",
        changelogDigest: "55a5a29b695c8160",
        sections: [
            Section(title: "Added", items: [
                "Open files and folders from other projects (9ab8529)",
                "Open bare file names from agent output across projects (fcc9d2b)",
                "Pin the file tree on another folder; root picker in its header (0fbde41)",
            ]),
            Section(title: "Changed", items: [
                "Route indexSession through indexSessionsBatch (561b1ea)",
                "Write the FTS index in batches of 50 during a scan (a6037f2)",
                "Spawn git only when a worktree or HEAD actually changed (7fe5a48)",
                "Watch the transcript file instead of polling it every 1s (cb11ff2)",
            ]),
            Section(title: "Documentation", items: [
                "Kouen-file-open covers folders, wrapped paths and other projects (2dd2ee9)",
                "Document FileTree programmatic reveal race prevention (4f9bc4c)",
                "Kouen-file-open: how to see click logs in KouenPreview (9488351)",
                "Kouen-file-open: stale HTML after reload is usually page state (51ccef4)",
            ]),
            Section(title: "Fixed", items: [
                "Restart the daemon for real at the end of make start (88e1b6a)",
                "Fix header scroll overlap and cross-project reveal ancestor expansion (9c66415)",
                "Cancel overlapping reveal tasks and remove cascading revealEpoch bumps (3fc33da)",
                "Protect child nodes from parallel loadChildren races during reveal (9cf8d07)",
                "Loop over itemsToIndex in session_index_meta insert and add mixed batch test (2f052cb)",
                "Address P59 review findings (transcript meta, KeyTable precedence, semantic sort, locator head-tail) (a519846)",
                "Cmd+R reloads the browser pane, Cmd+Shift+R ignores the cache (7119f16)",
            ]),
        ]
    )
}
