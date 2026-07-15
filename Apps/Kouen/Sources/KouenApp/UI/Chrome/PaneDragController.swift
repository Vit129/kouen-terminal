import AppKit
import KouenCore

/// Manages pane drag-and-drop: tracks the dragged pane, shows drop zone overlays on
/// potential targets, and commits the move/swap on drop.
@MainActor
final class PaneDragController {
    static let shared = PaneDragController()

    private var sourcePaneID: PaneID?
    private var overlays: [PaneID: PaneDropZoneOverlay] = [:]
    private var dragWindow: NSWindow?
    private var monitor: Any?

    private init() {}

    var isDragging: Bool { sourcePaneID != nil }

    // MARK: - Begin / Update / End

    func beginDrag(paneID: PaneID, from view: NSView) {
        guard sourcePaneID == nil else { return }
        sourcePaneID = paneID
        let paneCount = SessionCoordinator.shared.snapshot.activeWorkspace?.activeTab?.rootPane.allPaneIDs().count ?? -1
        let agentCount = SessionCoordinator.shared.snapshot.activeWorkspace?.sessions
            .flatMap(\.tabs).compactMap(\.agent).count ?? -1
        DragDiagnostics.log("beginDrag paneID=\(paneID) paneCount=\(paneCount) agentCount=\(agentCount)")
        DragDiagnostics.startStallMonitor()
        installOverlays(excluding: paneID)
        installMonitor()
        NSCursor.closedHand.push()
    }

    func cancel() {
        DragDiagnostics.log("cancel (escape or explicit)")
        cleanup()
    }

    // MARK: - Internals

    private func installOverlays(excluding srcID: PaneID) {
        guard let workspace = SessionCoordinator.shared.snapshot.activeWorkspace,
              let tab = workspace.activeTab else { return }
        let allPanes = tab.rootPane.allPaneIDs().filter { $0 != srcID }
        let totalPanes = tab.rootPane.allPaneIDs().count
        guard let contentVC = (NSApp.keyWindow?.contentViewController as? MainSplitViewController
            ?? NSApp.mainWindow?.contentViewController as? MainSplitViewController)?.contentVC
        else { return }

        for paneID in allPanes {
            guard let shell = contentVC.paneShell(for: paneID) else { continue }
            let overlay = PaneDropZoneOverlay(targetPaneID: paneID)
            overlay.disableCenter = totalPanes <= 2
            overlay.frame = shell.bounds
            overlay.autoresizingMask = [.width, .height]
            shell.addSubview(overlay)
            overlays[paneID] = overlay
        }
    }

    private func installMonitor() {
        monitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDragged, .leftMouseUp, .keyDown]) { [weak self] event in
            guard let self, self.sourcePaneID != nil else { return event }
            switch event.type {
            case .leftMouseDragged:
                self.handleDrag(event)
            case .leftMouseUp:
                self.handleDrop(event)
            case .keyDown where event.keyCode == 53: // Escape
                self.cancel()
                return nil
            default: break
            }
            return event
        }
    }

    private func handleDrag(_ event: NSEvent) {
        // Update overlays based on mouse position
        let screenPoint = NSEvent.mouseLocation
        for (_, overlay) in overlays {
            guard let window = overlay.window else { continue }
            let windowPoint = window.convertPoint(fromScreen: screenPoint)
            let localPoint = overlay.convert(windowPoint, from: nil)
            if overlay.bounds.contains(localPoint) {
                overlay.updateZone(for: localPoint)
            } else {
                overlay.clear()
            }
        }
    }

    private func handleDrop(_ event: NSEvent) {
        guard let srcID = sourcePaneID else { cleanup(); return }
        // Find which overlay has an active zone
        var targetPaneID: PaneID?
        var zone: PaneDropZoneOverlay.Zone = .none
        for (paneID, overlay) in overlays {
            if overlay.activeZone != .none {
                targetPaneID = paneID
                zone = overlay.activeZone
                break
            }
        }
        DragDiagnostics.log("handleDrop targetPaneID=\(targetPaneID.map(String.init(describing:)) ?? "nil") zone=\(zone) overlaysWithActiveZone=\(overlays.values.filter { $0.activeZone != .none }.count)")
        cleanup()
        guard let dstID = targetPaneID, zone != .none else {
            DragDiagnostics.log("handleDrop: no target zone active — drop landed nowhere")
            return
        }
        commit(srcID: srcID, dstID: dstID, zone: zone)
    }

    private func commit(srcID: PaneID, dstID: PaneID, zone: PaneDropZoneOverlay.Zone) {
        let start = Date()
        DragDiagnostics.log("commit start srcID=\(srcID) dstID=\(dstID) zone=\(zone)")
        defer { DragDiagnostics.log("commit dispatched in \(Int(Date().timeIntervalSince(start) * 1000))ms (async daemon round-trip continues)") }
        let coordinator = SessionCoordinator.shared.splitPaneCoordinator
        switch zone {
        case .center:
            coordinator.swapPanes(srcPaneID: srcID, dstPaneID: dstID)
        case .left:
            coordinator.movePaneToDirection(sourcePaneID: srcID, destPaneID: dstID, direction: .horizontal, before: true)
        case .right:
            coordinator.movePaneToDirection(sourcePaneID: srcID, destPaneID: dstID, direction: .horizontal, before: false)
        case .top:
            coordinator.movePaneToDirection(sourcePaneID: srcID, destPaneID: dstID, direction: .vertical, before: true)
        case .bottom:
            coordinator.movePaneToDirection(sourcePaneID: srcID, destPaneID: dstID, direction: .vertical, before: false)
        case .none:
            break
        }
    }

    private func cleanup() {
        DragDiagnostics.stopStallMonitor()
        sourcePaneID = nil
        for (_, overlay) in overlays {
            overlay.removeFromSuperview()
        }
        overlays.removeAll()
        if let monitor { NSEvent.removeMonitor(monitor) }
        monitor = nil
        dragWindow?.orderOut(nil)
        dragWindow = nil
        NSCursor.pop()
    }
}
