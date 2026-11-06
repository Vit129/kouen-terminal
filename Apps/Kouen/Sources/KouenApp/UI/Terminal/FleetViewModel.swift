import Foundation
import KouenCore

/// Thin `@Observable` facade over the headless `FleetSessionList` (KouenCore) — the UI owns
/// only the cached list plus the live filter text, and the actual flatten/sort/filter runs in
/// the pure core so it can be unit-tested without a window.
///
/// Pattern mirrors `AutomationsFleetModel` (`@Observable @MainActor`, list + text filter) — not
/// the file itself, since that one lists scheduled jobs and their run history, not live sessions.
@Observable @MainActor
public final class FleetViewModel {
    public var items: [FleetSessionItem] = []
    public var filterText: String = ""

    public init() {}

    public var filteredItems: [FleetSessionItem] {
        FleetSessionList.filter(items, text: filterText)
    }

    public var waitingCount: Int { items.count { $0.isWaiting } }

    public func itemsFor(filter: ProjectTabFilter) -> [FleetSessionItem] {
        FleetSessionList.filtered(filteredItems, by: filter)
    }

    /// Rebuild the flat list from the current cross-workspace snapshot. Cheap enough (plain
    /// array walk + sort, no I/O) to call on every `snapshotChanged` notification, the same
    /// cadence `AgentSessionHistoryModel.refresh` and the Attention Beacon already run at.
    /// `activeSurfaceID` marks whichever row is the one currently being viewed (see
    /// `FleetSessionItem.isActive`) — pass `SessionCoordinator.shared.activeSurfaceID`.
    ///
    /// Memory investigation (Nov 2026): this is `@Observable`, so assigning `items`
    /// unconditionally republished on every tick even when the rows were identical — which
    /// rebuilt `FleetView`'s `List` and fed the RenderBox display-list churn seen in the heap
    /// snapshot. Only publish an actual change.
    public func refresh(from snapshot: SessionSnapshot, activeSurfaceID: UUID? = nil) {
        let newItems = FleetSessionList.flatten(snapshot, activeSurfaceID: activeSurfaceID)
        if items != newItems { items = newItems }
    }
}
