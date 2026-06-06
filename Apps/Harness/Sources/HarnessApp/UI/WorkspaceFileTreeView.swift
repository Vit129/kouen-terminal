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
    /// Last session identity used to hydrate the tree. Different sessions at the
    /// same CWD can be on different branches, so we always reload on session change.
    private var lastSessionID: SessionID?
    private let hostingView: NSHostingView<FileTreeSwiftUIView>

    init(rootPath: String? = nil) {
        self.rootPath = rootPath
            ?? SessionCoordinator.shared.snapshot.activeWorkspace?.activeTab?.cwd
            ?? NSHomeDirectory()
        self.lastSessionID = SessionCoordinator.shared.snapshot.activeWorkspace?.activeSessionID
        let swiftUIView = FileTreeSwiftUIView(
            rootPath: self.rootPath,
            sessionID: self.lastSessionID,
            watcher: watcher
        )
        self.hostingView = NSHostingView(rootView: swiftUIView)
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    /// Update the file tree root, forcing a refresh when the session changes even
    /// if the path is the same (different branches, same repo root).
    func updateRoot(path: String, sessionID: SessionID?) {
        guard path != rootPath || sessionID != lastSessionID else { return }
        rootPath = path
        lastSessionID = sessionID
        hostingView.rootView = FileTreeSwiftUIView(rootPath: path, sessionID: sessionID, watcher: watcher)
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
