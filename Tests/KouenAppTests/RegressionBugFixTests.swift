import XCTest
import KouenCore
@testable import KouenApp

/// Regression tests for bugs fixed in the Jun 2026 audit:
///   - structureFingerprint covering non-active tabs (memory/CPU leak)
///   - shellQuoted correctness for cd navigation
@MainActor
final class RegressionBugFixTests: XCTestCase {

    // MARK: - Helpers

    private func snap(tabs: [Tab], workspaces extra: [Workspace] = []) -> SessionSnapshot {
        let session = SessionGroup(tabs: tabs)
        let ws = Workspace(sessions: [session])
        return SessionSnapshot(workspaces: [ws] + extra, activeWorkspaceID: ws.id)
    }

    // MARK: - structureFingerprint: non-active tab regression

    /// The original bug: only the active tab was hashed, so killing a pane in a
    /// background tab never incremented structureRevision → TerminalHostView leaked.
    func testStructureFingerprintDetectsNonActiveTabPaneKill() {
        let leafActive = PaneLeaf()
        let leafBackground = PaneLeaf()
        let leafReplacement = PaneLeaf() // new leaf after kill

        let snapBefore = snap(tabs: [
            Tab(rootPane: .leaf(leafActive), sortOrder: 0),
            Tab(rootPane: .leaf(leafBackground), sortOrder: 1),
        ])
        let snapAfter = snap(tabs: [
            Tab(rootPane: .leaf(leafActive), sortOrder: 0),
            Tab(rootPane: .leaf(leafReplacement), sortOrder: 1),
        ])

        XCTAssertNotEqual(
            DaemonSyncService.structureFingerprint(snapBefore),
            DaemonSyncService.structureFingerprint(snapAfter),
            "Pane kill in a background tab must change the fingerprint"
        )
    }

    func testStructureFingerprintDetectsActiveTabPaneKill() {
        let leafA = PaneLeaf()
        let leafB = PaneLeaf()

        let before = snap(tabs: [Tab(rootPane: .leaf(leafA))])
        let after  = snap(tabs: [Tab(rootPane: .leaf(leafB))])

        XCTAssertNotEqual(
            DaemonSyncService.structureFingerprint(before),
            DaemonSyncService.structureFingerprint(after)
        )
    }

    // MARK: - structureFingerprint: stability

    func testStructureFingerprintStableWhenUnchanged() {
        let snap = self.snap(tabs: [Tab(rootPane: .leaf(PaneLeaf()))])

        XCTAssertEqual(
            DaemonSyncService.structureFingerprint(snap),
            DaemonSyncService.structureFingerprint(snap),
            "Fingerprint must be deterministic for an unchanged snapshot"
        )
    }

    // MARK: - structureFingerprint: browser pane exclusion

    /// Different browser-pane IDs in the same tab must not change the fingerprint —
    /// the original blink-loop guard relied on active-tab-only hashing; with all-tabs
    /// hashing, excluding browser panes keeps that invariant intact.
    func testStructureFingerprintExcludesBrowserPanes() {
        let termLeaf = PaneLeaf()
        let browser1 = BrowserLeaf(id: UUID(), url: URL(string: "https://a.com")!)
        let browser2 = BrowserLeaf(id: UUID(), url: URL(string: "https://b.com")!)

        let snap1 = snap(tabs: [Tab(rootPane: .branch(
            direction: .horizontal, ratio: 0.5,
            first: .leaf(termLeaf), second: .browser(browser1)
        ))])
        let snap2 = snap(tabs: [Tab(rootPane: .branch(
            direction: .horizontal, ratio: 0.5,
            first: .leaf(termLeaf), second: .browser(browser2)
        ))])

        XCTAssertEqual(
            DaemonSyncService.structureFingerprint(snap1),
            DaemonSyncService.structureFingerprint(snap2),
            "Browser-pane ID changes must not affect the fingerprint"
        )
    }

    func testStructureFingerprintBrowserOnlyTabIgnoresBrowserID() {
        let browser1 = BrowserLeaf(id: UUID(), url: URL(string: "https://x.com")!)
        let browser2 = BrowserLeaf(id: UUID(), url: URL(string: "https://y.com")!)

        let snap1 = snap(tabs: [Tab(rootPane: .browser(browser1))])
        let snap2 = snap(tabs: [Tab(rootPane: .browser(browser2))])

        // Neither has terminal surfaces — swapping browser IDs must not change the fingerprint.
        XCTAssertEqual(
            DaemonSyncService.structureFingerprint(snap1),
            DaemonSyncService.structureFingerprint(snap2),
            "Browser-only tabs must not affect fingerprint regardless of browser ID"
        )
    }

    // MARK: - structureFingerprint: multiple workspaces

    func testStructureFingerprintCoversNonActiveWorkspace() {
        let leafW1 = PaneLeaf()
        let leafW2a = PaneLeaf()
        let leafW2b = PaneLeaf()

        func makeSnap(w2Leaf: PaneLeaf) -> SessionSnapshot {
            let s1 = SessionGroup(tabs: [Tab(rootPane: .leaf(leafW1))])
            let w1 = Workspace(sessions: [s1])
            let s2 = SessionGroup(tabs: [Tab(rootPane: .leaf(w2Leaf))])
            let w2 = Workspace(sessions: [s2])
            return SessionSnapshot(workspaces: [w1, w2], activeWorkspaceID: w1.id)
        }

        XCTAssertNotEqual(
            DaemonSyncService.structureFingerprint(makeSnap(w2Leaf: leafW2a)),
            DaemonSyncService.structureFingerprint(makeSnap(w2Leaf: leafW2b)),
            "Fingerprint must include all workspaces, not just the active one"
        )
    }

    // MARK: - shellQuoted

    func testShellQuotedSimplePath() {
        XCTAssertEqual("/usr/local/bin".shellQuoted, "'/usr/local/bin'")
    }

    func testShellQuotedPathWithSpaces() {
        XCTAssertEqual("/Users/me/My Documents".shellQuoted, "'/Users/me/My Documents'")
    }

    func testShellQuotedPathWithSingleQuote() {
        // /foo'bar  →  '/foo'"'"'bar'
        XCTAssertEqual("/foo'bar".shellQuoted, "'/foo'\"'\"'bar'")
    }

    func testShellQuotedPathWithMultipleSingleQuotes() {
        // it's a 'path'  →  'it'"'"'s a '"'"'path'"'"''
        XCTAssertEqual("it's a 'path'".shellQuoted, "'it'\"'\"'s a '\"'\"'path'\"'\"''")
    }

    func testShellQuotedShellMetacharactersAreSuppressed() {
        // Dollar signs and semicolons inside single quotes are inert.
        XCTAssertEqual("/foo/$bar;rm *".shellQuoted, "'/foo/$bar;rm *'")
    }

    func testShellQuotedEmptyString() {
        XCTAssertEqual("".shellQuoted, "''")
    }

    func testShellQuotedHomeTildeIsLiteral() {
        // A tilde inside single quotes is never expanded.
        XCTAssertEqual("~/projects".shellQuoted, "'~/projects'")
    }

    /// Round-trip sanity: unquoting the output should reproduce the original path.
    /// We simulate this by verifying the quoting + embedding in an echo command
    /// produces only single-quote regions with proper escaping.
    func testShellQuotedRoundTrip() {
        let inputs = [
            "/simple/path",
            "/path with spaces",
            "/path'with'quotes",
            "/path$with${meta}",
            "",
            "/a'b'c'd",
        ]
        for input in inputs {
            let quoted = input.shellQuoted
            // Quoted form must always start and end with single-quote.
            XCTAssertTrue(quoted.hasPrefix("'"), "Expected leading ' for: \(input)")
            XCTAssertTrue(quoted.hasSuffix("'"), "Expected trailing ' for: \(input)")
            // No unescaped single quote inside — every ' inside input becomes '"'"'
            // which means the original quote is never left bare inside single-quote region.
            let embedded = input.replacingOccurrences(of: "'", with: "'\"'\"'")
            XCTAssertEqual(quoted, "'\(embedded)'")
        }
    }
}
