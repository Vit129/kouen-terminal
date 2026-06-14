import AppKit
import SwiftUI
import HarnessCore

/// NSView wrapper that hosts `FileTreeSwiftUIView` inside the sidebar.
///
/// **Session-aware refresh (F1-A):** `updateRoot(path:sessionID:)` forces a
/// reload whenever the *session* changes, even if the directory path is the
/// same. This matters when two sessions share a repository root but are on
/// different git branches — the file tree must reflect the active session's
/// branch, not just the path.
@MainActor
final class WorkspaceFileTreeView: NSView {
    private let watcher = FileTreeWatcher()
    private var rootPath: String
    private var lastSessionID: SessionID?
    private let hostingView: NSHostingView<FileTreeSwiftUIView>
    let keyboard = FileTreeKeyboardNavigator()

    var onFilePreview: ((FileNode) -> Void)?

    init(rootPath: String? = nil) {
        self.rootPath = rootPath
            ?? SessionCoordinator.shared.snapshot.activeWorkspace?.activeTab?.cwd
            ?? NSHomeDirectory()
        self.lastSessionID = SessionCoordinator.shared.snapshot.activeWorkspace?.activeSessionID
        self.hostingView = NSHostingView(rootView: FileTreeSwiftUIView(
            rootPath: self.rootPath,
            sessionID: self.lastSessionID,
            watcher: watcher,
            keyboard: FileTreeKeyboardState(),
            onPreview: { _ in }
        ))
        super.init(frame: .zero)
        hostingView.rootView = FileTreeSwiftUIView(
            rootPath: self.rootPath,
            sessionID: self.lastSessionID,
            watcher: watcher,
            keyboard: keyboard.state,
            onPreview: { [weak self] node in self?.onFilePreview?(node) }
        )
        keyboard.onOpenFile = { [weak self] path in
            guard let self else { return }
            let url = URL(fileURLWithPath: path)
            let node = FileNode(id: path, name: url.lastPathComponent, path: path,
                                isDirectory: url.hasDirectoryPath)
            self.onFilePreview?(node)
        }
        keyboard.onPreviewFile = { [weak self] path in
            guard let self else { return }
            let url = URL(fileURLWithPath: path)
            let node = FileNode(id: path, name: url.lastPathComponent, path: path,
                                isDirectory: url.hasDirectoryPath)
            self.onFilePreview?(node)
        }
        keyboard.onToggleExpand = { token in
            if token.hasSuffix("__expand") {
                let path = String(token.dropLast("__expand".count))
                NotificationCenter.default.post(name: .fileTreeToggleExpand, object: nil,
                    userInfo: ["path": path, "action": "expand"])
            } else if token.hasSuffix("__collapse") {
                let path = String(token.dropLast("__collapse".count))
                NotificationCenter.default.post(name: .fileTreeToggleExpand, object: nil,
                    userInfo: ["path": path, "action": "collapse"])
            }
        }
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override var acceptsFirstResponder: Bool { true }

    override func keyDown(with event: NSEvent) {
        if keyboard.handle(event) { return }
        super.keyDown(with: event)
    }

    func updateRoot(path: String, sessionID: SessionID?) {
        guard path != rootPath || sessionID != lastSessionID else { return }
        rootPath = path
        lastSessionID = sessionID
        hostingView.rootView = FileTreeSwiftUIView(
            rootPath: path,
            sessionID: sessionID,
            watcher: watcher,
            keyboard: keyboard.state,
            onPreview: { [weak self] node in self?.onFilePreview?(node) }
        )
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
