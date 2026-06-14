import XCTest
@testable import HarnessApp
import HarnessCore

/// P16 PBI-BOARD-002: the "Board" sidebar tab renders `BoardModel.classify(...)`
/// as Kanban columns. Structural assertions only (per `HarnessAppTests`
/// convention) — no full UI snapshot testing.
final class BoardViewControllerTests: XCTestCase {
    @MainActor
    func testReloadProducesAllFiveColumnsMatchingBoardModel() {
        let vc = BoardViewController()
        _ = vc.view // force loadView()
        vc.reload()

        let expected = BoardModel.classify(snapshot: SessionCoordinator.shared.snapshot)
        XCTAssertEqual(vc.columns.map(\.kind), expected.map(\.kind))
        XCTAssertEqual(vc.columns.map { $0.cards.count }, expected.map { $0.cards.count })
    }

    @MainActor
    func testReloadRendersOneColumnViewPerBoardColumn() {
        let vc = BoardViewController()
        _ = vc.view
        vc.reload()

        // One arranged column view per BoardColumnKind, in canonical order.
        XCTAssertEqual(vc.columns.count, BoardColumnKind.allCases.count)
    }

    @MainActor
    func testDefaultSnapshotHasOneIdleCard() {
        // SessionCoordinator.shared starts with a default SessionSnapshot() — one
        // session, one tab, idle (no currentCommand, no exitStatus).
        let vc = BoardViewController()
        _ = vc.view
        vc.reload()

        let idle = vc.columns.first { $0.kind == .idle }
        XCTAssertEqual(idle?.cards.count, 1)
        let running = vc.columns.first { $0.kind == .running }
        XCTAssertEqual(running?.cards.count, 0)
    }
}
