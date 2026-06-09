import XCTest
@testable import HarnessCore
@testable import HarnessDaemonCore

/// End-to-end persistence: a real `forkpty` shell writes output, the surface persists its
/// scrollback to disk, and a *fresh* `RealPty` over the same file replays that history — the
/// "daemon restart isn't a blank session" path. Live (spawns a shell), so gated like the other
/// PTY tests behind `HARNESS_LIVE_DAEMON_TESTS=1`.
final class ScrollbackPersistenceTests: XCTestCase {
    private var scrollbackURL: URL!

    override func setUpWithError() throws {
        try skipUnlessLiveDaemonTests()
        scrollbackURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("harness-scroll-\(UUID().uuidString).scroll")
    }

    override func tearDownWithError() throws {
        if let scrollbackURL { try? FileManager.default.removeItem(at: scrollbackURL) }
    }

    private func makePty(id: String) throws -> RealPty {
        let pty = try RealPty(
            id: id,
            cwd: NSTemporaryDirectory(),
            shell: "/bin/sh",
            rows: 24,
            cols: 80,
            scrollbackBytes: 64 * 1024,
            scrollbackURL: scrollbackURL
        )
        pty.start() // reading/exit-watching is now owner-initiated (deferred from init)
        return pty
    }

    func testHistoryReplaysAfterRespawnFromDisk() throws {
        let surfaceID = UUID().uuidString
        let marker = "HARNESS_PERSIST_MARKER"

        // First "daemon run": spawn, produce output containing the marker, persist, tear down.
        let first = try makePty(id: surfaceID)
        let saw = expectation(description: "marker observed in live output")
        saw.assertForOverFulfill = false
        let acc = OutputAccumulator()
        _ = first.subscribe { data, _ in
            if acc.appendAndContains(String(decoding: data, as: UTF8.self), marker: marker) { saw.fulfill() }
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) { first.write("echo \(marker)\n") }
        wait(for: [saw], timeout: 8)
        first.flushScrollback() // graceful-shutdown flush
        first.close()

        // Second "daemon run": a brand-new surface over the same persisted file must replay history.
        let second = try makePty(id: surfaceID)
        defer { second.close() }
        XCTAssertTrue(
            second.replay(fromSequence: nil).contains(marker),
            "reattach after restart should replay persisted scrollback, not start blank"
        )
    }

    /// PR-18 `clear-history`: `clearScrollback()` empties the in-memory ring AND resets the
    /// on-disk file *without* respawning the shell — the gap that previously forced users to
    /// `respawn-pane -k` (which kills the running process) just to clear their scrollback. The
    /// reborn-surface assertion proves the clear reached disk, not just memory (a memory-only
    /// clear would leave the marker to replay on the next daemon run).
    func testClearScrollbackEmptiesRingAndFileWithoutRespawn() throws {
        let surfaceID = UUID().uuidString
        let marker = "HARNESS_CLEAR_MARKER"

        let pty = try makePty(id: surfaceID)
        let saw = expectation(description: "marker observed in live output")
        saw.assertForOverFulfill = false
        let acc = OutputAccumulator()
        _ = pty.subscribe { data, _ in
            if acc.appendAndContains(String(decoding: data, as: UTF8.self), marker: marker) { saw.fulfill() }
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) { pty.write("echo \(marker)\n") }
        wait(for: [saw], timeout: 8)
        // handleOutput appends to the ring before fanning out to subscribers, so seeing the
        // marker means it is already in scrollback — no settle needed.
        XCTAssertTrue(pty.replay(fromSequence: nil).contains(marker), "scrollback should hold the marker before clearing")

        pty.clearScrollback()

        XCTAssertFalse(
            pty.replay(fromSequence: nil).contains(marker),
            "clear-history must empty the in-memory scrollback"
        )

        // The shell is the SAME process (no respawn): it keeps accepting input and streaming.
        let after = "HARNESS_AFTER_CLEAR"
        let alive = expectation(description: "same shell still live after clear")
        alive.assertForOverFulfill = false
        let acc2 = OutputAccumulator()
        _ = pty.subscribe { data, _ in
            if acc2.appendAndContains(String(decoding: data, as: UTF8.self), marker: after) { alive.fulfill() }
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) { pty.write("echo \(after)\n") }
        wait(for: [alive], timeout: 8)
        pty.flushScrollback()
        pty.close()

        // Fresh surface over the same file: the pre-clear marker must be gone from disk too.
        let reborn = try makePty(id: surfaceID)
        defer { reborn.close() }
        XCTAssertFalse(
            reborn.replay(fromSequence: nil).contains(marker),
            "clear-history must reset the on-disk scrollback file, not just memory"
        )
    }
}
