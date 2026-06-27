import AppKit
import Foundation
import HarnessCore
import UniformTypeIdentifiers

/// Portable layout template — split geometry + CWDs, no runtime UUIDs.
struct LayoutTemplate: Codable {
    var name: String
    var exportedAt: Date
    var root: LayoutNode
}

indirect enum LayoutNode: Codable {
    case leaf(cwd: String)
    case branch(direction: SplitDirection, ratio: Double, first: LayoutNode, second: LayoutNode)
}

/// Export active tab's pane tree to a .harness-layout file; import recreates splits via cd.
/// Import is best-effort: CWDs are exact, split tree is flattened to horizontal splits.
@MainActor
enum LayoutFileStore {
    static let fileExtension = "harness-layout"

    // MARK: - Export

    static func exportCurrentLayout() {
        guard let tab = SessionCoordinator.shared.snapshot.activeWorkspace?.activeTab else { return }
        let savePanel = NSSavePanel()
        if let type = UTType(filenameExtension: fileExtension) { savePanel.allowedContentTypes = [type] }
        savePanel.nameFieldStringValue = "layout"
        savePanel.begin { response in
            guard response == .OK, let url = savePanel.url else { return }
            let template = LayoutTemplate(
                name: url.deletingPathExtension().lastPathComponent,
                exportedAt: .now,
                root: layoutNode(from: tab.rootPane)
            )
            do {
                let enc = JSONEncoder(); enc.outputFormatting = .prettyPrinted
                try enc.encode(template).write(to: url)
            } catch {
                NSAlert(error: error).runModal()
            }
        }
    }

    // MARK: - Import

    static func importLayout() {
        let openPanel = NSOpenPanel()
        if let type = UTType(filenameExtension: fileExtension) { openPanel.allowedContentTypes = [type] }
        openPanel.begin { response in
            guard response == .OK, let url = openPanel.url else { return }
            do {
                let template = try JSONDecoder().decode(LayoutTemplate.self, from: Data(contentsOf: url))
                applyLayout(template.root)
            } catch {
                NSAlert(error: error).runModal()
            }
        }
    }

    // MARK: - Private

    private static func layoutNode(from pane: PaneNode) -> LayoutNode {
        switch pane {
        case let .leaf(leaf):
            return .leaf(cwd: leaf.surfaces.compactMap(\.cwd).first ?? "")
        case let .branch(direction, ratio, first, second):
            return .branch(direction: direction, ratio: ratio,
                           first: layoutNode(from: first), second: layoutNode(from: second))
        case .browser:
            return .leaf(cwd: "")
        }
    }

    private static func applyLayout(_ root: LayoutNode) {
        var cwds: [String] = []
        collectLeaves(root, into: &cwds)
        guard !cwds.isEmpty else { return }
        let coord = SessionCoordinator.shared
        if let cwd = cwds.first, !cwd.isEmpty, let sid = coord.activeSurfaceID {
            Task { await coord.requestDaemon(.sendData(surfaceID: sid.uuidString, data: Data(("cd \(cwd.shellQuoted)\r").utf8))) }
        }
        for cwd in cwds.dropFirst() where !cwd.isEmpty {
            coord.splitActivePaneAndRun(direction: .horizontal, command: "cd \(cwd.shellQuoted)")
        }
    }

    private static func collectLeaves(_ node: LayoutNode, into out: inout [String]) {
        switch node {
        case let .leaf(cwd): out.append(cwd)
        case let .branch(_, _, first, second):
            collectLeaves(first, into: &out)
            collectLeaves(second, into: &out)
        }
    }
}

private extension String {
    var shellQuoted: String { "'\(replacingOccurrences(of: "'", with: "'\"'\"'"))'" }
}
