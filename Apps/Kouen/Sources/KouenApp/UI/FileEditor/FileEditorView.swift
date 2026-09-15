import AppKit
import KouenCore
import QuickLookUI
import KouenLSP

/// File ID for GUI-only file tabs (not daemon-managed).
typealias FileTabID = UUID

/// A read-only file editor panel shown in the content area when a file tab is active.
/// Features: line numbers gutter, syntax highlighting, Quick Look for non-text.
@MainActor
final class FileEditorView: NSView {
    private let syntaxView = SyntaxTextView()
    private let markdownPreviewView = MarkdownPreviewView(frame: .zero)
    private let modeToggleButton = KouenDesign.softIconButton(symbol: "pencil", tooltip: "Edit Markdown (⌘E)", size: 26)
    private let messageLabel = NSTextField(labelWithString: "")
    private let quickLookContainer = NSView()
    private let lspSession = LSPFileSession()

    private static let maxPreviewBytes = 5_000_000
    private(set) var filePath: String = ""
    private var isMarkdownFile = false
    private var isMarkdownEditMode = false
    private var currentMarkdownRaw: String = ""

    var activeDiagnostics: [LSPDiagnostic] { syntaxView.activeDiagnostics }
    /// True once `load(path:)` has routed the current file through the syntax-highlighted
    /// text view (copy/find/vi-mode all work there) rather than Quick Look (a separate,
    /// read-only renderer that doesn't wire into this app's Edit menu).
    var isShowingSyntaxView: Bool { !syntaxView.isHidden }
    var isShowingMarkdownPreview: Bool { !markdownPreviewView.isHidden }
    var isShowingQuickLook: Bool { !quickLookContainer.isHidden }
    private let fileWatcher = FileChangeWatcher()
    private let symbolIndex = WorkspaceSymbolIndex()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    func load(path: String) {
        var cleanPath = path.trimmingCharacters(in: .whitespacesAndNewlines)
        if (cleanPath.hasPrefix("'") && cleanPath.hasSuffix("'")) ||
           (cleanPath.hasPrefix("\"") && cleanPath.hasSuffix("\"")) {
            cleanPath = String(cleanPath.dropFirst().dropLast())
        }
        let isReloadingSamePath = filePath == cleanPath
        filePath = cleanPath
        // Track in MRU for :recent command
        WorkbenchMRU.shared.add(cleanPath)
        // Wire :copy-path callbacks
        syntaxView.onCurrentFile = { [weak self] in self?.filePath }
        syntaxView.onCurrentCWD = {
            let coordinator = SessionCoordinator.shared
            return WorkbenchContextResolver.resolve(
                snapshot: coordinator.snapshot,
                focusedSurfaceID: coordinator.activeSurfaceID,
                currentFilePath: nil
            )?.cwd
        }
        quickLookContainer.isHidden = true
        let expanded = (cleanPath as NSString).expandingTildeInPath
        let url = URL(fileURLWithPath: expanded).resolvingSymlinksInPath()

        fileWatcher.start(path: expanded) { [weak self] in
            guard let self, self.filePath == cleanPath else { return }
            self.load(path: cleanPath)
        }

        // Quick Look for images/PDFs
        let ext = (cleanPath as NSString).pathExtension.lowercased()
        let imageExts = Set(["png", "jpg", "jpeg", "gif", "webp", "svg", "ico", "bmp", "tiff", "heic"])
        let qlExts = imageExts.union(["pdf", "rtf", "rtfd", "doc", "docx", "pages", "key", "keynote", "numbers", "xlsx", "xls", "csv"])
        if qlExts.contains(ext) {
            showQuickLook(url: url)
            return
        }

        guard let attributes = try? FileManager.default.attributesOfItem(atPath: expanded),
              let size = attributes[.size] as? Int else {
            showMessage("Unable to read file.")
            return
        }
        guard size <= Self.maxPreviewBytes else {
            showMessage("File too large to preview (\(ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file))).")
            return
        }
        guard let data = try? Data(contentsOf: url), let contents = String(data: data, encoding: .utf8) else {
            showMessage("Binary file — cannot preview.")
            return
        }

        let isRich = MarkdownPreviewView.isRichPreviewExtension(ext)
        let isCode = MarkdownPreviewView.isSupportedCodeFile(url)
        if isRich || isCode {
            isMarkdownFile = true
            currentMarkdownRaw = contents
            modeToggleButton.isHidden = false
            // Code files default to the syntax editor (keeps LSP/save/diff gutter as the primary
            // view); markdown/mermaid default to the rendered preview. Reset on every new path so
            // a mode left over from a previously viewed file in this same panel doesn't leak into
            // the next one — reloading the same path (file watcher, tab re-select) keeps whatever
            // mode the user is currently in.
            if !isReloadingSamePath {
                isMarkdownEditMode = isCode
            }
            if !isMarkdownEditMode {
                showMarkdownPreview(contents, url: url, resetScroll: !isReloadingSamePath)
            } else {
                showText(contents, fileExtension: ext, resetScroll: !isReloadingSamePath)
                updateModeButtonUI()
            }
            return
        }

        isMarkdownFile = false
        isMarkdownEditMode = false
        modeToggleButton.isHidden = true
        markdownPreviewView.isHidden = true
        showText(contents, fileExtension: ext, resetScroll: !isReloadingSamePath)
    }

    func navigateTo(line: Int, column: Int) {
        syntaxView.navigateTo(line: line, column: column)
    }

    // MARK: - Setup

    private func setup() {
        wantsLayer = true
        layer?.backgroundColor = .clear

        syntaxView.translatesAutoresizingMaskIntoConstraints = false
        syntaxView.onSave = { [weak self] text in
            guard let self, !self.filePath.isEmpty else { return }
            try? text.write(toFile: self.filePath, atomically: true, encoding: .utf8)
            self.currentMarkdownRaw = text
            self.markdownPreviewView.update(markdown: text)
            DisplayMessage.show("Saved \((self.filePath as NSString).lastPathComponent)")
        }
        // LSP hooks
        syntaxView.onHover = { [weak self] position in await self?.lspSession.hover(position: position) }
        syntaxView.onDefinition = { [weak self] position in await self?.lspSession.definition(position: position) }
        syntaxView.onNavigateToDefinition = { [weak self] target in
            self?.load(path: target.url.path)
            self?.syntaxView.navigateTo(line: target.line, column: target.column)
        }
        addSubview(syntaxView)

        markdownPreviewView.translatesAutoresizingMaskIntoConstraints = false
        markdownPreviewView.isHidden = true
        markdownPreviewView.onOpenFile = { [weak self] targetPath in
            self?.load(path: targetPath)
        }
        addSubview(markdownPreviewView)

        modeToggleButton.translatesAutoresizingMaskIntoConstraints = false
        modeToggleButton.isHidden = true
        modeToggleButton.target = self
        modeToggleButton.action = #selector(toggleMarkdownMode)
        addSubview(modeToggleButton)

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = KouenDesign.Typography.sidebarLabel
        messageLabel.textColor = KouenDesign.chrome.textTertiary
        messageLabel.alignment = .center
        messageLabel.isHidden = true
        addSubview(messageLabel)

        quickLookContainer.translatesAutoresizingMaskIntoConstraints = false
        quickLookContainer.isHidden = true
        addSubview(quickLookContainer)

        NSLayoutConstraint.activate([
            syntaxView.topAnchor.constraint(equalTo: topAnchor),
            syntaxView.leadingAnchor.constraint(equalTo: leadingAnchor),
            syntaxView.trailingAnchor.constraint(equalTo: trailingAnchor),
            syntaxView.bottomAnchor.constraint(equalTo: bottomAnchor),

            markdownPreviewView.topAnchor.constraint(equalTo: topAnchor),
            markdownPreviewView.leadingAnchor.constraint(equalTo: leadingAnchor),
            markdownPreviewView.trailingAnchor.constraint(equalTo: trailingAnchor),
            markdownPreviewView.bottomAnchor.constraint(equalTo: bottomAnchor),

            modeToggleButton.topAnchor.constraint(equalTo: topAnchor, constant: KouenDesign.Spacing.xs),
            modeToggleButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -KouenDesign.Spacing.md),

            messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            quickLookContainer.topAnchor.constraint(equalTo: topAnchor),
            quickLookContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            quickLookContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            quickLookContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        lspSession.onDiagnostics = { [weak self] diagnostics in
            self?.syntaxView.setDiagnostics(diagnostics)
        }
    }

    // MARK: - Editing

    func showFindBar() {
        syntaxView.showFindBar()
    }

    func showFindAndReplace() {
        syntaxView.showFindBar()
    }

    override func keyDown(with event: NSEvent) {
        let cmd = event.modifierFlags.contains(.command)
        let shift = event.modifierFlags.contains(.shift)
        let key = event.charactersIgnoringModifiers?.lowercased() ?? ""

        if cmd {
            if (key == "e" || (shift && key == "v")) && isMarkdownFile {
                toggleMarkdownMode()
                return
            }
            switch key {
            case "s": NSSound.beep()
            case "f":
                showFindBar()
            default: super.keyDown(with: event)
            }
            return
        }
        super.keyDown(with: event)
    }

    override var acceptsFirstResponder: Bool { true }

    // FileEditorView (not syntaxView) is first responder here — see keyDown override
    // above. NSView has no copy(_:), so Edit > Copy needs an explicit forward to the
    // inner view, which does the actual selection/clipboard work.
    @objc func copy(_ sender: Any?) {
        if isMarkdownFile && !isMarkdownEditMode {
            markdownPreviewView.copy(sender)
        } else {
            syntaxView.copy(sender)
        }
    }

    // MARK: - Display

    private func showMarkdownPreview(_ text: String, url: URL, resetScroll: Bool) {
        messageLabel.isHidden = true
        syntaxView.isHidden = true
        quickLookContainer.isHidden = true
        markdownPreviewView.isHidden = false
        modeToggleButton.isHidden = false
        updateModeButtonUI()

        if resetScroll {
            markdownPreviewView.load(markdown: text, fileURL: url)
        } else {
            markdownPreviewView.update(markdown: text)
        }
    }

    @objc func toggleMarkdownMode() {
        guard isMarkdownFile else { return }
        isMarkdownEditMode.toggle()
        updateModeButtonUI()

        let ext = (filePath as NSString).pathExtension.lowercased()
        if isMarkdownEditMode {
            markdownPreviewView.isHidden = true
            showText(currentMarkdownRaw, fileExtension: ext, resetScroll: false)
            window?.makeFirstResponder(syntaxView)
        } else {
            let text = syntaxView.string
            currentMarkdownRaw = text
            syntaxView.isHidden = true
            markdownPreviewView.isHidden = false
            markdownPreviewView.update(markdown: text)
            window?.makeFirstResponder(markdownPreviewView)
        }
    }

    private func updateModeButtonUI() {
        let typeName = FileViewerViewController.previewTypeName(forPath: filePath)
        if isMarkdownEditMode {
            modeToggleButton.setSymbol("eye", accessibilityDescription: "Preview \(typeName) (⌘E)", pointSize: 12, weight: .medium)
            modeToggleButton.toolTip = "Preview \(typeName) (⌘E)"
        } else {
            modeToggleButton.setSymbol("pencil", accessibilityDescription: "Edit \(typeName) (⌘E)", pointSize: 12, weight: .medium)
            modeToggleButton.toolTip = "Edit \(typeName) (⌘E)"
        }
    }

    private func showText(_ text: String, fileExtension ext: String, resetScroll: Bool) {
        messageLabel.isHidden = true
        syntaxView.isHidden = false
        quickLookContainer.isHidden = true
        markdownPreviewView.isHidden = true

        syntaxView.load(text: text, fileExtension: ext, resetScroll: resetScroll)
        if ["diff", "patch"].contains(ext) {
            let diffLines = GitDiffGutter.contentLines(text)
            syntaxView.setDiffLines(diffLines)
            if resetScroll, let firstChangedLine = diffLines.keys.min() {
                syntaxView.navigateTo(line: firstChangedLine, column: 1)
            }
        } else {
            let path = filePath
            Task.detached(priority: .utility) {
                let diffLines = await GitDiffGutter.diffLines(for: path)
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    self.syntaxView.setDiffLines(diffLines)
                    if resetScroll, let firstChangedLine = diffLines.keys.min() {
                        self.syntaxView.navigateTo(line: firstChangedLine, column: 1)
                    }
                }
            }
        }

        let fileDir = (filePath as NSString).deletingLastPathComponent
        let coordinator = SessionCoordinator.shared
        let root = WorkbenchContextResolver.resolve(
            snapshot: coordinator.snapshot,
            focusedSurfaceID: coordinator.activeSurfaceID,
            currentFilePath: filePath
        )?.cwd ?? fileDir
        symbolIndex.scan(root: root)
        syntaxView.symbolIndex = symbolIndex
        lspSession.open(url: URL(fileURLWithPath: filePath), text: text, fileExtension: ext)
    }

    private func showMessage(_ message: String) {
        lspSession.close()
        syntaxView.isHidden = true
        markdownPreviewView.isHidden = true
        modeToggleButton.isHidden = true
        quickLookContainer.isHidden = true
        messageLabel.isHidden = false
        messageLabel.stringValue = message
    }

    private func showQuickLook(url: URL) {
        lspSession.close()
        syntaxView.isHidden = true
        markdownPreviewView.isHidden = true
        modeToggleButton.isHidden = true
        messageLabel.isHidden = true
        quickLookContainer.isHidden = false

        if let existing = quickLookContainer.subviews.first as? QLPreviewView {
            // Reuse existing preview view — avoids blink on file switch
            if existing.previewItem?.previewItemURL == url {
                existing.refreshPreviewItem()
            } else {
                existing.previewItem = url as NSURL
            }
            return
        }

        guard let preview = QLPreviewView(frame: .zero, style: .normal) else {
            showMessage("Unable to start Quick Look preview.")
            return
        }
        preview.translatesAutoresizingMaskIntoConstraints = false
        preview.autostarts = true
        preview.previewItem = url as NSURL
        quickLookContainer.addSubview(preview)
        NSLayoutConstraint.activate([
            preview.topAnchor.constraint(equalTo: quickLookContainer.topAnchor),
            preview.leadingAnchor.constraint(equalTo: quickLookContainer.leadingAnchor),
            preview.trailingAnchor.constraint(equalTo: quickLookContainer.trailingAnchor),
            preview.bottomAnchor.constraint(equalTo: quickLookContainer.bottomAnchor),
        ])
    }
}
