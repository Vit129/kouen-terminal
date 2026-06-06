import AppKit
import Observation
import SwiftUI
import HarnessCore

@Observable
@MainActor
final class FileTreeNode: Identifiable {
    let id: String
    let node: FileNode
    var children: [FileTreeNode]?

    init(node: FileNode) {
        self.id = node.id
        self.node = node
        self.children = node.isDirectory ? [] : nil
    }
}

/// SwiftUI view for the file-explorer sidebar panel.
///
/// **Git status integration (F1-B/E/F):**
/// - `.task(id:)` uses a combined `sessionID + rootPath` key so it re-runs
///   whenever *either* the directory or the active session changes.
/// - `loadRoot()` runs filesystem scan and `git status` concurrently, then
///   merges the status map into each `FileNode.gitStatus`.
/// - `NodeRow` renders a coloured dot and optional strikethrough per status.
@MainActor
struct FileTreeSwiftUIView: View {
    let rootPath: String
    /// Session identity included in the `.task` id so switching sessions in the
    /// same repo (e.g. main vs feat/A) re-runs `loadRoot()`.
    let sessionID: SessionID?
    let watcher: FileTreeWatcher
    @State private var rootNodes: [FileTreeNode] = []
    /// Kept alive across expands so child nodes inherit the same status map.
    @State private var currentGitStatus: [String: GitStatusType] = [:]

    var body: some View {
        List {
            ForEach(rootNodes) { node in
                NodeRow(node: node, rootPath: rootPath, watcher: watcher, gitStatus: currentGitStatus)
            }
        }
        .listStyle(.sidebar)
        .scrollContentBackground(.hidden)
        // React to both path and session changes — different sessions may be on
        // different branches sharing the same rootPath.
        .task(id: "\(sessionID?.uuidString ?? "nil")|\(rootPath)") { await loadRoot() }
    }

    private func loadRoot() async {
        let statusProvider = GitStatusProvider()
        // Fetch git status and scan the filesystem concurrently.
        async let gitStatusTask  = statusProvider.status(rootPath: rootPath)
        async let rawNodesTask   = (try? watcher.scan(rootPath: rootPath)) ?? []
        let (status, rawNodes)   = await (gitStatusTask, rawNodesTask)

        currentGitStatus = status
        // Merge status into nodes (watcher also accepts the map, but we already
        // have the raw nodes — apply inline to avoid a second scan).
        let prefix = rootPath.hasSuffix("/") ? rootPath : rootPath + "/"
        rootNodes = rawNodes.map { node in
            let rel = node.path.hasPrefix(prefix)
                ? String(node.path.dropFirst(prefix.count))
                : node.path
            var updated = node
            updated.gitStatus = status[rel] ?? .unmodified
            return FileTreeNode(node: updated)
        }
    }
}

// MARK: - NodeRow

@MainActor
private struct NodeRow: View {
    let node: FileTreeNode
    let rootPath: String
    let watcher: FileTreeWatcher
    let gitStatus: [String: GitStatusType]
    @State private var isExpanded = false

    var body: some View {
        if node.node.isDirectory {
            DisclosureGroup(isExpanded: $isExpanded) {
                ForEach(node.children ?? []) { child in
                    NodeRow(node: child, rootPath: rootPath, watcher: watcher, gitStatus: gitStatus)
                }
            } label: {
                rowLabel(systemImage: "folder")
                    .contentShape(Rectangle())
                    .onTapGesture { isExpanded.toggle() }
            }
            .onChange(of: isExpanded) { _, expanded in
                if expanded { Task { await loadChildren() } }
            }
        } else {
            rowLabel(systemImage: "doc")
                .onTapGesture(count: 2) { openFile() }
        }
    }

    private func rowLabel(systemImage: String) -> some View {
        HStack(spacing: 4) {
            Label {
                Text(node.node.name)
                    .strikethrough(node.node.gitStatus == .deleted, color: gitStatusColor(node.node.gitStatus))
            } icon: {
                Image(systemName: systemImage)
            }
            .help(node.node.path)
            Spacer()
            gitStatusDot(node.node.gitStatus)
        }
        .onDrag {
            NSItemProvider(contentsOf: URL(fileURLWithPath: node.node.path)) ?? NSItemProvider()
        }
        .contextMenu {
            Button("Copy Path") { copyToPasteboard(node.node.path) }
            Button("Copy Relative Path") {
                let rel = node.node.path.replacingOccurrences(of: rootPath + "/", with: "")
                copyToPasteboard(rel)
            }
        }
    }

    // MARK: Git status indicators

    /// A small filled circle indicating the working-tree git status.
    /// Hidden (clear / zero-size) for unmodified files so it takes no space.
    @ViewBuilder
    private func gitStatusDot(_ status: GitStatusType) -> some View {
        let color = gitStatusColor(status)
        if status != .unmodified {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
        }
    }

    private func gitStatusColor(_ status: GitStatusType) -> Color {
        switch status {
        case .modified:   return .yellow
        case .added:      return .green
        case .deleted:    return .red
        case .untracked:  return .secondary
        case .unmodified: return .clear
        }
    }

    // MARK: Actions

    private func copyToPasteboard(_ string: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(string, forType: .string)
    }

    private func loadChildren() async {
        guard node.children?.isEmpty == true else { return }
        do {
            let childNodes = try await watcher.expand(node: node.node, gitStatus: gitStatus)
            node.children = childNodes.map { FileTreeNode(node: $0) }
        } catch {
            node.children = []
        }
    }

    private func openFile() {
        let coordinator = SessionCoordinator.shared
        coordinator.splitActivePane(direction: .horizontal)
        guard let surfaceID = coordinator.activeSurfaceID else { return }
        let command = "open \(node.node.path)\r"
        coordinator.requestDaemon(.sendData(surfaceID: surfaceID.uuidString, data: Data(command.utf8)))
    }
}
