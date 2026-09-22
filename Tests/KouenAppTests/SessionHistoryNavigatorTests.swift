import XCTest
import KouenCore
@testable import KouenApp

/// Pure stack-mechanics tests for `SessionHistoryNavigator` — the browser-style back/forward
/// history through tab/session switches (P48). Exercises `recordIfNeeded`/`popForBack`/
/// `popForForward` directly rather than `goBack()`/`goForward()`, which require a live
/// `SessionCoordinator`/daemon; those are thin wrappers around the same stack mechanics tested
/// here (see `SessionHistoryNavigator.swift`'s doc comment on `popForBack(current:)`).
@MainActor
final class SessionHistoryNavigatorTests: XCTestCase {
    private func entry(_ n: Int) -> SessionHistoryNavigator.HistoryEntry {
        .init(workspaceID: WorkspaceID(), sessionID: SessionID(), tabID: nil)
    }

    func testRecordThenBackReturnsThePreviousEntry() {
        let nav = SessionHistoryNavigator()
        let a = entry(1)
        let b = entry(2)

        nav.recordIfNeeded(previous: a)
        XCTAssertTrue(nav.canGoBack)

        let target = nav.popForBack(current: b)
        XCTAssertEqual(target, a)
        XCTAssertFalse(nav.canGoBack)
        XCTAssertTrue(nav.canGoForward, "the entry navigated away FROM must land on the forward stack")
    }

    func testNewNavigationAfterBackClearsForwardStack() {
        let nav = SessionHistoryNavigator()
        let a = entry(1)
        let b = entry(2)

        nav.recordIfNeeded(previous: a)
        _ = nav.popForBack(current: b) // now on a, b sits on forward stack
        XCTAssertTrue(nav.canGoForward)

        // A brand-new navigation (not a back/forward step) must discard the forward history —
        // standard browser semantics: going back then navigating somewhere new kills "redo".
        nav.recordIfNeeded(previous: a)
        XCTAssertFalse(nav.canGoForward, "a fresh navigation must clear the forward stack")
        XCTAssertTrue(nav.canGoBack)
    }

    func testBackAndForwardOnEmptyStackIsNoOp() {
        let nav = SessionHistoryNavigator()
        XCTAssertNil(nav.popForBack(current: entry(1)))
        XCTAssertNil(nav.popForForward(current: entry(1)))
        XCTAssertFalse(nav.canGoBack)
        XCTAssertFalse(nav.canGoForward)
    }

    func testBackThenForwardRoundTrips() {
        let nav = SessionHistoryNavigator()
        let a = entry(1)
        let b = entry(2)

        nav.recordIfNeeded(previous: a) // active is conceptually b now; back stack = [a]
        let backTarget = nav.popForBack(current: b) // -> a, forward stack = [b]
        XCTAssertEqual(backTarget, a)

        let forwardTarget = nav.popForForward(current: a) // -> b, back stack = [a] again
        XCTAssertEqual(forwardTarget, b)
        XCTAssertTrue(nav.canGoBack)
        XCTAssertFalse(nav.canGoForward)
    }
}
