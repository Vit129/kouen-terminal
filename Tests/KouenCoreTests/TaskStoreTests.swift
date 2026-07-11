import XCTest
import KouenIPC
@testable import KouenCore

final class TaskStoreTests: XCTestCase {
    private func tmpURL() -> URL {
        FileManager.default.temporaryDirectory.appendingPathComponent("kouen-tasks-\(UUID().uuidString).json")
    }

    func testCreateListGetUpdateDeleteRoundTrip() {
        let url = tmpURL()
        defer { try? FileManager.default.removeItem(at: url) }
        let store = TaskStore(url: url)
        let sessionID = SessionID()

        let created = store.create(sessionID: sessionID, title: "write tests")
        XCTAssertEqual(store.get(id: created.id)?.title, "write tests")
        XCTAssertEqual(store.list(sessionID: sessionID).count, 1)

        let updated = store.update(id: created.id, title: "write tests (done)", done: true)
        XCTAssertEqual(updated?.title, "write tests (done)")
        XCTAssertEqual(updated?.done, true)

        XCTAssertTrue(store.delete(id: created.id))
        XCTAssertNil(store.get(id: created.id))
        XCTAssertFalse(store.delete(id: created.id))
    }

    func testListWithNilSessionIDReturnsAllSessions() {
        let url = tmpURL()
        defer { try? FileManager.default.removeItem(at: url) }
        let store = TaskStore(url: url)
        let sessionA = SessionID()
        let sessionB = SessionID()
        store.create(sessionID: sessionA, title: "a")
        store.create(sessionID: sessionB, title: "b")

        XCTAssertEqual(store.list(sessionID: nil).count, 2)
        XCTAssertEqual(store.list(sessionID: sessionA).count, 1)
        XCTAssertEqual(store.list(sessionID: sessionB).count, 1)
    }

    func testTasksSurviveWhenOwningSessionIsGone() {
        // No session-existence check here by design — TaskStore has no notion of which
        // sessions are still open. A "closed session" Task is simply a Task whose
        // sessionID no longer matches any live session; the Dashboard (UI layer) does
        // that grouping, not the store. Verifies the store never deletes on its own.
        let url = tmpURL()
        defer { try? FileManager.default.removeItem(at: url) }
        let store = TaskStore(url: url)
        let closedSessionID = SessionID()
        let created = store.create(sessionID: closedSessionID, title: "leftover")

        XCTAssertEqual(store.list(sessionID: closedSessionID).count, 1)
        XCTAssertNotNil(store.get(id: created.id))
    }

    func testPersistsAcrossReopen() {
        let url = tmpURL()
        defer { try? FileManager.default.removeItem(at: url) }
        let sessionID = SessionID()
        let created: KouenTask
        do {
            let store = TaskStore(url: url)
            created = store.create(sessionID: sessionID, title: "persisted")
        }
        let reopened = TaskStore(url: url)
        XCTAssertEqual(reopened.get(id: created.id)?.title, "persisted")
    }

    func testUpdateOnMissingIDReturnsNil() {
        let url = tmpURL()
        defer { try? FileManager.default.removeItem(at: url) }
        let store = TaskStore(url: url)
        XCTAssertNil(store.update(id: UUID(), title: "nope"))
    }
}
