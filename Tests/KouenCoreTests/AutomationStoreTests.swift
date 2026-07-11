import XCTest
import KouenIPC
@testable import KouenCore

final class AutomationStoreTests: XCTestCase {
    private func tmpURL() -> URL {
        FileManager.default.temporaryDirectory.appendingPathComponent("kouen-automations-\(UUID().uuidString).json")
    }

    func testCreateListGetUpdateDeleteRoundTrip() {
        let url = tmpURL()
        defer { try? FileManager.default.removeItem(at: url) }
        let store = AutomationStore(url: url)

        let created = store.create(repoPath: "/repo", workspaceID: nil, agent: "claude", prompt: "ทำต่อ p40", intervalMinutes: 60)
        XCTAssertEqual(store.get(id: created.id)?.prompt, "ทำต่อ p40")
        XCTAssertEqual(store.list().count, 1)

        let updated = store.update(id: created.id, repoPath: nil, agent: nil, prompt: "ทำต่อ p41", intervalMinutes: nil)
        XCTAssertEqual(updated?.prompt, "ทำต่อ p41")

        XCTAssertTrue(store.delete(id: created.id))
        XCTAssertNil(store.get(id: created.id))
        XCTAssertFalse(store.delete(id: created.id))
    }

    func testZeroIntervalNeverDue() {
        let url = tmpURL()
        defer { try? FileManager.default.removeItem(at: url) }
        let store = AutomationStore(url: url)
        store.create(repoPath: "/repo", workspaceID: nil, agent: "claude", prompt: "manual only", intervalMinutes: 0)

        XCTAssertTrue(store.dueAutomations(asOf: Date().addingTimeInterval(3600)).isEmpty)
    }

    func testPositiveIntervalBecomesDueImmediately() {
        let url = tmpURL()
        defer { try? FileManager.default.removeItem(at: url) }
        let store = AutomationStore(url: url)
        let created = store.create(repoPath: "/repo", workspaceID: nil, agent: "claude", prompt: "recurring", intervalMinutes: 5)

        let due = store.dueAutomations(asOf: Date())
        XCTAssertEqual(due.map(\.id), [created.id])
    }

    func testPausedAutomationNeverDue() {
        let url = tmpURL()
        defer { try? FileManager.default.removeItem(at: url) }
        let store = AutomationStore(url: url)
        let created = store.create(repoPath: "/repo", workspaceID: nil, agent: "claude", prompt: "recurring", intervalMinutes: 5)
        store.setEnabled(id: created.id, enabled: false)

        XCTAssertTrue(store.dueAutomations(asOf: Date()).isEmpty)
    }

    func testRecordRunReschedulesByInterval() {
        let url = tmpURL()
        defer { try? FileManager.default.removeItem(at: url) }
        let store = AutomationStore(url: url)
        let created = store.create(repoPath: "/repo", workspaceID: nil, agent: "claude", prompt: "recurring", intervalMinutes: 5)
        let now = Date()

        let updated = store.recordRun(id: created.id, status: "ok", at: now)
        XCTAssertEqual(updated?.lastRunStatus, "ok")
        XCTAssertEqual(updated?.nextRunAt, now.addingTimeInterval(300))
        XCTAssertTrue(store.dueAutomations(asOf: now).isEmpty, "just-fired automation shouldn't be due again immediately")
    }

    func testRecordRunClearsNextRunAtForRunOnce() {
        let url = tmpURL()
        defer { try? FileManager.default.removeItem(at: url) }
        let store = AutomationStore(url: url)
        let created = store.create(repoPath: "/repo", workspaceID: nil, agent: "claude", prompt: "run once", intervalMinutes: 0)

        let updated = store.recordRun(id: created.id, status: "ok")
        XCTAssertNil(updated?.nextRunAt)
    }

    func testPersistsAcrossReopen() {
        let url = tmpURL()
        defer { try? FileManager.default.removeItem(at: url) }
        let created: KouenAutomation
        do {
            let store = AutomationStore(url: url)
            created = store.create(repoPath: "/repo", workspaceID: nil, agent: "claude", prompt: "persisted", intervalMinutes: 30)
        }
        let reopened = AutomationStore(url: url)
        XCTAssertEqual(reopened.get(id: created.id)?.prompt, "persisted")
    }

    func testUpdateOnMissingIDReturnsNil() {
        let url = tmpURL()
        defer { try? FileManager.default.removeItem(at: url) }
        let store = AutomationStore(url: url)
        XCTAssertNil(store.update(id: UUID(), repoPath: nil, agent: nil, prompt: "nope", intervalMinutes: nil))
    }
}
