import AppKit
import SwiftUI
import HarnessCore

@MainActor
final class WorkspaceFileTreeView: NSView {
    private let watcher = FileTreeWatcher()
    private var rootPath: String
    private let hostingView: NSHostingView<FileTreeSwiftUIView>

    init(rootPath: String? = nil) {
        self.rootPath = rootPath
            ?? SessionCoordinator.shared.snapshot.activeWorkspace?.activeTab?.cwd
            ?? NSHomeDirectory()
        let swiftUIView = FileTreeSwiftUIView(rootPath: self.rootPath, watcher: watcher)
        self.hostingView = NSHostingView(rootView: swiftUIView)
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    func updateRoot(path: String) {
        guard path != rootPath else { return }
        rootPath = path
        hostingView.rootView = FileTreeSwiftUIView(rootPath: path, watcher: watcher)
    }

    private func setup() {
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hostingView)
        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: topAnchor),
            hostingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: trailingAnchor),
            hostingView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
