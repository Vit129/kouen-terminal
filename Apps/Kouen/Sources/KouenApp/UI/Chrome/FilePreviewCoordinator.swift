import AppKit
import KouenCore
import KouenLSP

/// Manages the file editor split panel — tab bar, editor view, show/hide, vi commands,
/// and persistence. Owned by ContentAreaViewController.
@MainActor
final class FilePreviewCoordinator {
    private unowned let containerView: NSView
    private unowned let terminalHost: NSView
    private unowned let tabBarDivider: NSView

    // One FileTabManager per terminal tab (mirrors PaneLifecycleManager.containerCache),
    // so file previews opened in one tab never appear in another. `fileTabManager` always
    // points at the entry for the currently-active tab; switchToTab(tabID:) swaps it.
    private var fileTabManager = FileTabManager()
    private var fileTabManagers: [String: FileTabManager] = [:] // tabID → its own FileTabManager
    private var currentTabID: String?
    private var fileEditorPanel: NSView?
    private var fileEditorTabBar: FileEditorTabBarView?
    private var fileEditorView: FileEditorView?
    private var editorWidthConstraint: NSLayoutConstraint?
    private var editorDivider: EditorDividerView?

    // Owned here; ContentAreaVC calls setupInitialLeadingConstraint() in viewDidLoad.
    var terminalHostLeading: NSLayoutConstraint?

    var isFileEditorVisible: Bool { fileEditorPanel != nil }
    var activeDiagnostics: [LSPDiagnostic] { fileEditorView?.activeDiagnostics ?? [] }
    var currentFilePath: String? { fileEditorView?.filePath }

    init(containerView: NSView, terminalHost: NSView, tabBarDivider: NSView) {
        self.containerView = containerView
        self.terminalHost = terminalHost
        self.tabBarDivider = tabBarDivider
    }

    // MARK: - Setup

    func setupInitialLeadingConstraint() {
        let leading = terminalHost.leadingAnchor.constraint(equalTo: containerView.leadingAnchor)
        leading.isActive = true
        terminalHostLeading = leading
    }

    // MARK: - File Tab API

    func openFileTab(path: String) {
        fileTabManager.open(path: path)
        showFileEditorSplit()
        loadActiveFileTab()
        persistEditorState()
    }

    func navigateCurrentFile(line: Int, column: Int) {
        fileEditorView?.navigateTo(line: line, column: column)
    }

    func closeFileTab(id: FileTabID) {
        fileTabManager.close(id: id)
        if fileTabManager.hasOpenTabs {
            loadActiveFileTab()
        } else {
            hideFileEditorSplit()
        }
        persistEditorState()
    }

    func selectFileTab(id: FileTabID) {
        fileTabManager.activate(id: id)
        loadActiveFileTab()
        persistEditorState()
    }

    func activateTerminalTab() {
        // no-op — terminal is always visible in split mode
    }

    // MARK: - Per-Tab Scoping

    /// Called whenever the active terminal tab changes. Swaps in that tab's own
    /// FileTabManager and shows/hides the split to match — a tab with no open
    /// previews of its own never shows another tab's file.
    func switchToTab(tabID: String?) {
        guard tabID != currentTabID else { return }
        currentTabID = tabID
        guard let tabID else {
            fileTabManager = FileTabManager()
            hideFileEditorSplit()
            return
        }
        let manager = fileTabManagers[tabID] ?? {
            let created = FileTabManager()
            fileTabManagers[tabID] = created
            return created
        }()
        fileTabManager = manager
        if manager.hasOpenTabs {
            showFileEditorSplit()
            loadActiveFileTab()
        } else {
            hideFileEditorSplit()
        }
    }

    /// Drop FileTabManagers for tabs that no longer exist, mirroring
    /// PaneLifecycleManager.pruneCache — otherwise every tab ever visited leaks forever.
    func pruneFileTabManagers(keepingTabIDs liveTabIDs: Set<String>) {
        let staleKeys = fileTabManagers.keys.filter { !liveTabIDs.contains($0) }
        for key in staleKeys { fileTabManagers.removeValue(forKey: key) }
    }

    private func loadActiveFileTab() {
        guard let tab = fileTabManager.activeTab() else { return }
        fileEditorView?.load(path: tab.path)
        fileEditorTabBar?.reload(tabs: fileTabManager.openTabs, activeID: fileTabManager.activeFileTabID)
    }

    // MARK: - Split Show/Hide

    func showFileEditorSplit() {
        if fileEditorPanel != nil {
            loadActiveFileTab()
            return
        }
        let panel = NSView()
        panel.wantsLayer = true
        let c = KouenDesign.chrome
        panel.layer?.borderColor = c.border.cgColor
        panel.layer?.borderWidth = 1
        panel.translatesAutoresizingMaskIntoConstraints = false

        let tabBarView = FileEditorTabBarView()
        tabBarView.translatesAutoresizingMaskIntoConstraints = false
        tabBarView.onSelect = { [weak self] id in self?.selectFileTab(id: id) }
        tabBarView.onClose = { [weak self] id in self?.closeFileTab(id: id) }
        panel.addSubview(tabBarView)
        fileEditorTabBar = tabBarView

        let editor = FileEditorView(frame: .zero)
        editor.translatesAutoresizingMaskIntoConstraints = false
        panel.addSubview(editor)
        fileEditorView = editor

        NSLayoutConstraint.activate([
            tabBarView.topAnchor.constraint(equalTo: panel.topAnchor),
            tabBarView.leadingAnchor.constraint(equalTo: panel.leadingAnchor),
            tabBarView.trailingAnchor.constraint(equalTo: panel.trailingAnchor),
            tabBarView.heightAnchor.constraint(equalToConstant: 34),
            editor.topAnchor.constraint(equalTo: tabBarView.bottomAnchor),
            editor.leadingAnchor.constraint(equalTo: panel.leadingAnchor),
            editor.trailingAnchor.constraint(equalTo: panel.trailingAnchor),
            editor.bottomAnchor.constraint(equalTo: panel.bottomAnchor),
        ])

        containerView.addSubview(panel)
        let initialWidth = containerView.bounds.width > 0 ? containerView.bounds.width * 0.4 : 400
        let widthC = panel.widthAnchor.constraint(equalToConstant: initialWidth)
        widthC.priority = .defaultHigh
        NSLayoutConstraint.activate([
            panel.topAnchor.constraint(equalTo: tabBarDivider.bottomAnchor, constant: 2),
            panel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            panel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            widthC,
            panel.widthAnchor.constraint(greaterThanOrEqualToConstant: 200),
        ])
        editorWidthConstraint = widthC

        let divider = EditorDividerView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.widthConstraint = widthC
        divider.containerView = containerView
        containerView.addSubview(divider)
        NSLayoutConstraint.activate([
            divider.topAnchor.constraint(equalTo: panel.topAnchor),
            divider.bottomAnchor.constraint(equalTo: panel.bottomAnchor),
            divider.leadingAnchor.constraint(equalTo: panel.trailingAnchor, constant: -2),
            divider.widthAnchor.constraint(equalToConstant: 5),
        ])
        editorDivider = divider

        if let existing = terminalHostLeading {
            existing.isActive = false
        }
        let leading = terminalHost.leadingAnchor.constraint(equalTo: panel.trailingAnchor)
        leading.isActive = true
        terminalHostLeading = leading

        fileEditorPanel = panel
        refreshEditorPanelFill()
        layoutFileEditorSplitSynchronously()
        persistEditorState()
    }

    func hideFileEditorSplit() {
        guard let panel = fileEditorPanel else { return }
        panel.removeFromSuperview()
        editorDivider?.removeFromSuperview()
        fileEditorPanel = nil
        fileEditorView = nil
        fileEditorTabBar = nil
        editorWidthConstraint = nil
        editorDivider = nil
        if let lc = terminalHostLeading {
            lc.isActive = false
            terminalHostLeading = nil
        }
        let restored = terminalHost.leadingAnchor.constraint(equalTo: containerView.leadingAnchor)
        restored.isActive = true
        terminalHostLeading = restored
        layoutFileEditorSplitSynchronously()
        persistEditorState()
    }

    // MARK: - Chrome

    func refreshEditorPanelFill() {
        guard let panel = fileEditorPanel else { return }
        let opacity = CGFloat(KouenSettings.clampedOpacity(SessionCoordinator.shared.settings.backgroundOpacity))
        panel.layer?.backgroundColor = KouenChrome.current.terminalBackground
            .withAlphaComponent(opacity).cgColor
    }

    // MARK: - Persistence

    func persistEditorState() {
        let visible = isFileEditorVisible
        let paths = fileTabManager.openTabs.map { $0.path }
        let activePath = fileTabManager.activeTab()?.path
        UserDefaults.standard.set(visible, forKey: "kouen.fileEditorVisible")
        UserDefaults.standard.set(paths, forKey: "kouen.fileEditorPaths")
        if let activePath {
            UserDefaults.standard.set(activePath, forKey: "kouen.fileEditorActivePath")
        } else {
            UserDefaults.standard.removeObject(forKey: "kouen.fileEditorActivePath")
        }
    }

    func restoreEditorState() {
        let visible = UserDefaults.standard.bool(forKey: "kouen.fileEditorVisible")
        let paths = UserDefaults.standard.stringArray(forKey: "kouen.fileEditorPaths") ?? []
        let activePath = UserDefaults.standard.string(forKey: "kouen.fileEditorActivePath")
        for path in paths { fileTabManager.open(path: path) }
        if let activePath { fileTabManager.open(path: activePath) }
        if visible && fileTabManager.hasOpenTabs {
            showFileEditorSplit()
            loadActiveFileTab()
        }
    }

    // MARK: - Vi Command Forwarding

    func handleViQuit() {
        if let activeID = fileTabManager.activeTab()?.id {
            closeFileTab(id: activeID)
        }
    }

    func handleViOpen(path: String) {
        guard let resolved = resolveViPath(path, command: "edit") else { return }
        openFileTab(path: resolved)
    }

    func handleViSplit(path: String, direction: SplitDirection) {
        guard let expanded = resolveViPath(path, command: "split") else { return }
        SessionCoordinator.shared.splitActivePaneAndRun(
            direction: direction,
            command: "${EDITOR:-vi} \(Self.shellQuote(expanded))"
        )
    }

    func handleViFind(query: String) {
        let root = currentWorkbenchCWD()
        switch FuzzyPathResolver.resolve(query: query, root: root, limit: 5) {
        case .none:
            DisplayMessage.show("find: no match")
        case .unique(let path):
            openFileTab(path: path)
        case .ambiguous(let matches):
            DisplayMessage.show(matches.enumerated().map { "\($0.offset + 1): \($0.element)" }.joined(separator: "\n"))
        }
    }

    func handleViNextBuffer(delta: Int) {
        let tabs = fileTabManager.openTabs
        guard !tabs.isEmpty, let active = fileTabManager.activeTab() else { return }
        let idx = tabs.firstIndex(where: { $0.id == active.id }) ?? 0
        let newIdx = (idx + delta + tabs.count) % tabs.count
        selectFileTab(id: tabs[newIdx].id)
    }

    // MARK: - Helpers

    private func layoutFileEditorSplitSynchronously() {
        let hosts = SessionCoordinator.shared.terminalHosts.allHosts()
        hosts.forEach { $0.setPresentsWithTransaction(true) }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        containerView.layout()
        CATransaction.commit()
        hosts.forEach { $0.setPresentsWithTransaction(false) }
    }

    /// Resolves a file path referenced in terminal output (e.g. a ⌘-clicked link) against the
    /// authoritative workbench cwd, with a fuzzy-path fallback — used when the terminal
    /// surface's own OSC-7 cwd was nil/stale and the raw candidate doesn't exist as-is.
    /// Silent (no `DisplayMessage`): unlike vi `:e`, this fires from a passive click, not a
    /// typed command, so an unresolvable link should just no-op rather than show an overlay.
    func resolveTerminalLinkPath(_ path: String) -> String? {
        var expanded = (path as NSString).expandingTildeInPath
        let cwd = currentWorkbenchCWD()
        if !expanded.hasPrefix("/") {
            expanded = (cwd as NSString).appendingPathComponent(expanded)
        }
        if FileManager.default.fileExists(atPath: expanded) { return expanded }
        if case .unique(let match) = FuzzyPathResolver.resolve(query: path, root: cwd, limit: 5) {
            return match
        }
        return nil
    }

    private func resolveViPath(_ path: String, command: String) -> String? {
        var expanded = (path as NSString).expandingTildeInPath
        let cwd = currentWorkbenchCWD()
        if !expanded.hasPrefix("/") {
            expanded = (cwd as NSString).appendingPathComponent(expanded)
        }
        if !FileManager.default.fileExists(atPath: expanded) {
            switch FuzzyPathResolver.resolve(query: path, root: cwd, limit: 5) {
            case .none:
                DisplayMessage.show("\(command): no match")
                return nil
            case .unique(let match):
                return match
            case .ambiguous(let matches):
                DisplayMessage.show(matches.enumerated().map { "\($0.offset + 1): \($0.element)" }.joined(separator: "\n"))
                return nil
            }
        }
        return expanded
    }

    private func currentWorkbenchCWD() -> String {
        let coordinator = SessionCoordinator.shared
        return WorkbenchContextResolver.resolve(
            snapshot: coordinator.snapshot,
            focusedSurfaceID: coordinator.activeSurfaceID,
            currentFilePath: currentFilePath
        )?.cwd ?? FileManager.default.currentDirectoryPath
    }

    private static func shellQuote(_ value: String) -> String {
        ShellQuoting.quote(value)
    }
}
