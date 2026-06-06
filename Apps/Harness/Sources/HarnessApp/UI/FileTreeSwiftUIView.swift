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

@MainActor
struct FileTreeSwiftUIView: View {
    let rootPath: String
    let watcher: FileTreeWatcher

    @State private var rootNodes: [FileTreeNode] = []

    var body: some View {
        List(rootNodes, children: \.children) { node in
            row(for: node)
        }
        .listStyle(.sidebar)
        .scrollContentBackground(.hidden)
        .task(id: rootPath) {
            await loadRoot()
        }
    }

    private func row(for node: FileTreeNode) -> some View {
        HStack(spacing: 7) {
            Image(systemName: node.node.isDirectory ? "folder" : "doc")
                .font(.system(size: 13, weight: .regular))
                .frame(width: 16, height: 16)
            Text(node.node.name)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .help(node.node.path)
        .onDrag {
            NSItemProvider(contentsOf: URL(fileURLWithPath: node.node.path)) ?? NSItemProvider()
        }
        .contextMenu {
            Button("Copy Path") {
                copyToPasteboard(node.node.path)
            }
            Button("Copy Relative Path") {
                copyToPasteboard(relativePath(for: node.node.path))
            }
        }
        .onTapGesture(count: 2) {
            guard !node.node.isDirectory else { return }
            openFile(node.node.path)
        }
        .task(id: node.id) {
            await loadChildren(of: node)
        }
    }

    private func loadRoot() async {
        do {
            let nodes = try await watcher.scan(rootPath: rootPath)
            var treeNodes: [FileTreeNode] = []
            for node in nodes {
                let treeNode = FileTreeNode(node: node)
                if node.isDirectory {
                    let children = (try? await watcher.expand(node: node)) ?? []
                    treeNode.children = children.map { FileTreeNode(node: $0) }
                }
                treeNodes.append(treeNode)
            }
            rootNodes = treeNodes
        } catch {
            rootNodes = []
        }
    }

    private func loadChildren(of node: FileTreeNode) async {
        guard node.node.isDirectory, node.children?.isEmpty == true else { return }
        do {
            let childNodes = try await watcher.expand(node: node.node)
            node.children = childNodes.map { child in
                let n = FileTreeNode(node: child)
                return n
            }
        } catch {
            node.children = []
        }
    }

    private func openFile(_ path: String) {
        let coordinator = SessionCoordinator.shared
        coordinator.splitActivePane(direction: .horizontal)
        guard let surfaceID = coordinator.activeSurfaceID else { return }
        let command = "open \(path)\r"
        coordinator.requestDaemon(.sendData(surfaceID: surfaceID.uuidString, data: Data(command.utf8)))
    }

    private func copyToPasteboard(_ string: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(string, forType: .string)
    }

    private func relativePath(for path: String) -> String {
        path.replacingOccurrences(of: rootPath + "/", with: "")
    }
}
