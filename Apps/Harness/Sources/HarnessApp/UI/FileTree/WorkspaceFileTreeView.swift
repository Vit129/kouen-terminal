import AppKit
import Observation
import SwiftUI
import HarnessCore

/// Mutable context observed by `FileTreeSwiftUIView`.
/// Mutating this is safe during a layout pass because SwiftUI will re-render
/// on the next cycle rather than replacing the hosting view's root struct.
@Observable
@MainActor
final class FileTreeContext {
    var rootPath: String
    var sessionID: SessionID?
    /// Set to scroll-and-highlight a file path in the tree; cleared after the scroll fires.
    var revealPath: String?

    init(rootPath: String, sessionID: SessionID?) {
        self.rootPath = rootPath
        self.sessionID = sessionID
    }
}

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
    private let context: FileTreeContext
    private var hostingView: NSHostingView<FileTreeSwiftUIView>!
    let keyboard = FileTreeKeyboardNavigator()

    var onFilePreview: ((FileNode) -> Void)?

    init(rootPath: String? = nil) {
        let initialPath = rootPath
            ?? SessionCoordinator.shared.snapshot.activeWorkspace?.activeTab?.cwd
            ?? NSHomeDirectory()
        let initialSessionID = SessionCoordinator.shared.snapshot.activeWorkspace?.activeSessionID
        self.context = FileTreeContext(rootPath: initialPath, sessionID: initialSessionID)
        super.init(frame: .zero)
        self.hostingView = NSHostingView(rootView: FileTreeSwiftUIView(
            context: context,
            watcher: watcher,
            keyboard: keyboard.state,
            onPreview: { [weak self] node in self?.onFilePreview?(node) }
        ))
        keyboard.onOpenFile = { [weak self] path in
            guard let self else { return }
            let url = URL(fileURLWithPath: path)
            let node = FileNode(id: path, name: url.lastPathComponent, path: path,
                                isDirectory: url.hasDirectoryPath)
            
            let coordinator = SessionCoordinator.shared
            let action = coordinator.settings.fileClickAction
            if action == "terminalOnly" {
                coordinator.splitActivePane(direction: .horizontal)
                guard let surfaceID = coordinator.activeSurfaceID else { return }
                let command = "open \(path)\r"
                coordinator.requestDaemon(.sendData(surfaceID: surfaceID.uuidString, data: Data(command.utf8)))
            } else if action == "vi" || action == "cat" {
                guard let surfaceID = coordinator.activeSurfaceID else { return }
                let cmd = action == "vi" ? "vi \(path)\r" : "cat \(path)\r"
                coordinator.requestDaemon(.sendData(surfaceID: surfaceID.uuidString, data: Data(cmd.utf8)))
            } else {
                self.onFilePreview?(node)
            }
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

    /// Expands all ancestor directories of `path`, highlights it in the keyboard navigator,
    /// then signals the SwiftUI list to scroll to it after a short delay for child loading.
    func revealFileInTree(path: String) {
        let rootPrefix = context.rootPath.hasSuffix("/") ? context.rootPath : context.rootPath + "/"
        if path.hasPrefix(rootPrefix) {
            let relative = String(path.dropFirst(rootPrefix.count))
            let parentRelative = (relative as NSString).deletingLastPathComponent
            let components = parentRelative.components(separatedBy: "/").filter { !$0.isEmpty }
            var accumulated = context.rootPath
            for component in components {
                accumulated = (accumulated as NSString).appendingPathComponent(component)
                NotificationCenter.default.post(
                    name: .fileTreeToggleExpand,
                    object: nil,
                    userInfo: ["path": accumulated, "action": "expand"]
                )
            }
        }
        keyboard.state.focusedPath = path
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            guard let self else { return }
            self.context.revealPath = path
        }
    }

    func updateRoot(path: String, sessionID: SessionID?) {
        guard path != context.rootPath || sessionID != context.sessionID else { return }
        // Mutate the shared context instead of replacing hostingView.rootView.
        // Replacing rootView mid-layout-pass can leave AttributeGraph holding
        // stale @Observable references, causing a UAF crash in swift_getObjectType.
        context.rootPath = path
        context.sessionID = sessionID
    }

    private func setup() {
        attachHostingView()
    }

    /// Adds the hosting view and pins it to the edges. Idempotent: safe to call
    /// again after `viewWillMove(toWindow: nil)` detached it (see `didMoveToWindow`).
    private func attachHostingView() {
        guard hostingView.superview == nil else { return }
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hostingView)
        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: topAnchor),
            hostingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: trailingAnchor),
            hostingView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    override func viewWillMove(toWindow newWindow: NSWindow?) {
        super.viewWillMove(toWindow: newWindow)
        if newWindow == nil {
            // Detach the hosting view so SwiftUI stops re-evaluating the body
            // after the backing context is freed (zombie @Observable access → crash).
            // Also cancel pending layout to prevent a queued re-render race.
            hostingView?.needsLayout = false
            hostingView?.needsDisplay = false
            hostingView?.removeFromSuperview()
        }
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        // Re-attach after returning to a window: `viewWillMove(toWindow: nil)`
        // removes the hosting view on detach, but the view can come back alive
        // (e.g. sidebar position swap removes/re-adds the container). Without this
        // the file tree stays permanently blank.
        if window != nil { attachHostingView() }
    }
}
