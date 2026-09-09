// ponytail: intentionally AppKit — syntax highlight uses custom NSTextStorage + layout manager; SwiftUI TextEditor has no equivalent hook.
import AppKit
import KouenCore
import QuickLookUI
import KouenLSP

/// Read-only preview of a file's contents, hosted in the sidebar in place of
/// the file tree.
@MainActor
final class FileViewerViewController: NSViewController {
    /// Files larger than this are not loaded into the text view.
    private static let maxPreviewBytes = 1_000_000

    private let header = NSView()
    private let backButton = KouenDesign.softIconButton(symbol: "chevron.left", tooltip: "Back to file tree")
    private let pathLabel = NSTextField(labelWithString: "")
    private let modeButton = KouenDesign.softIconButton(symbol: "pencil", tooltip: "Edit / View Source (⌘E)", size: 24)
    private let syntaxView = SyntaxTextView()
    private let markdownPreviewView = MarkdownPreviewView(frame: .zero)
    private let quickLookView = QLPreviewView(frame: .zero, style: .normal)
    private let messageLabel = NSTextField(labelWithString: "")
    private let fileWatcher = FileChangeWatcher()
    // LSP integration (hover, go-to-definition, diagnostics) enabled.
    private let lspSession = LSPFileSession()

    private var isMarkdownFile = false
    private var isMarkdownEditMode = false
    private var currentMarkdownRaw = ""

    /// Invoked when the user taps the back button.
    var onBack: (() -> Void)?

    override func loadView() {
        view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeader()
        setupPreviewViews()
        setupMessageLabel()
    }

    /// Reads `path` from disk and displays it. Shows a placeholder message for
    /// binary/oversized files or read failures.
    func load(path: String) {
        var cleanPath = path.trimmingCharacters(in: .whitespacesAndNewlines)
        if (cleanPath.hasPrefix("'") && cleanPath.hasSuffix("'")) ||
           (cleanPath.hasPrefix("\"") && cleanPath.hasSuffix("\"")) {
            cleanPath = String(cleanPath.dropFirst().dropLast())
        }
        let isReloadingSamePath = pathLabel.toolTip == cleanPath
        pathLabel.stringValue = (cleanPath as NSString).lastPathComponent
        pathLabel.toolTip = cleanPath

        let expanded = (cleanPath as NSString).expandingTildeInPath
        let url = URL(fileURLWithPath: expanded).resolvingSymlinksInPath()
        let ext = url.pathExtension.lowercased()

        fileWatcher.start(path: expanded) { [weak self] in
            guard let self, self.pathLabel.toolTip == cleanPath else { return }
            self.load(path: cleanPath)
        }

        if Self.quickLookExtensions.contains(ext) {
            showQuickLook(url)
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
            showMessage("Unable to preview this file (binary or unsupported encoding).")
            return
        }

        let isMD = ["md", "markdown"].contains(ext)
        if isMD {
            isMarkdownFile = true
            currentMarkdownRaw = contents
            if !isMarkdownEditMode {
                showMarkdownPreview(contents, url: url, resetScroll: !isReloadingSamePath)
            } else {
                showText(contents, url: url, fileExtension: ext, resetScroll: !isReloadingSamePath)
                updateModeButtonUI()
            }
            return
        }

        isMarkdownFile = false
        isMarkdownEditMode = false
        modeButton.isHidden = true
        markdownPreviewView.isHidden = true
        showText(contents, url: url, fileExtension: ext, resetScroll: !isReloadingSamePath)
    }

    // MARK: - Setup

    private func setupHeader() {
        header.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(header)

        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.target = self
        backButton.action = #selector(backTapped)
        header.addSubview(backButton)

        pathLabel.translatesAutoresizingMaskIntoConstraints = false
        pathLabel.font = KouenDesign.Typography.sidebarLabel
        pathLabel.textColor = KouenDesign.chrome.textPrimary
        pathLabel.lineBreakMode = .byTruncatingMiddle
        header.addSubview(pathLabel)

        modeButton.translatesAutoresizingMaskIntoConstraints = false
        modeButton.target = self
        modeButton.action = #selector(toggleMarkdownMode)
        modeButton.isHidden = true
        header.addSubview(modeButton)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: 36),

            backButton.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: KouenDesign.Spacing.sm),
            backButton.centerYAnchor.constraint(equalTo: header.centerYAnchor),

            modeButton.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -KouenDesign.Spacing.sm),
            modeButton.centerYAnchor.constraint(equalTo: header.centerYAnchor),

            pathLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: KouenDesign.Spacing.xs),
            pathLabel.trailingAnchor.constraint(equalTo: modeButton.leadingAnchor, constant: -KouenDesign.Spacing.xs),
            pathLabel.centerYAnchor.constraint(equalTo: header.centerYAnchor),
        ])
    }

    private func setupPreviewViews() {
        syntaxView.translatesAutoresizingMaskIntoConstraints = false
        syntaxView.onSave = { [weak self] text in
            guard let path = self?.pathLabel.toolTip, !path.isEmpty else { return }
            let expanded = (path as NSString).expandingTildeInPath
            try? text.write(toFile: expanded, atomically: true, encoding: .utf8)
            self?.currentMarkdownRaw = text
            self?.markdownPreviewView.update(markdown: text)
            DisplayMessage.show("Saved \((path as NSString).lastPathComponent)")
        }
        // LSP hooks
        syntaxView.onHover = { [weak self] position in await self?.lspSession.hover(position: position) }
        syntaxView.onDefinition = { [weak self] position in await self?.lspSession.definition(position: position) }
        syntaxView.onNavigateToDefinition = { [weak self] target in
            self?.load(path: target.url.path)
        }
        view.addSubview(syntaxView)

        markdownPreviewView.translatesAutoresizingMaskIntoConstraints = false
        markdownPreviewView.isHidden = true
        markdownPreviewView.onOpenFile = { [weak self] path in
            self?.load(path: path)
        }
        view.addSubview(markdownPreviewView)

        if let quickLookView {
            quickLookView.translatesAutoresizingMaskIntoConstraints = false
            quickLookView.autostarts = true
            quickLookView.isHidden = true
            view.addSubview(quickLookView)
        }

        // LSP diagnostics
        lspSession.onDiagnostics = { [weak self] diagnostics in
            self?.syntaxView.setDiagnostics(diagnostics)
        }

        var constraints = [
            syntaxView.topAnchor.constraint(equalTo: header.bottomAnchor),
            syntaxView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            syntaxView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            syntaxView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            markdownPreviewView.topAnchor.constraint(equalTo: header.bottomAnchor),
            markdownPreviewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            markdownPreviewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            markdownPreviewView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ]
        if let quickLookView {
            constraints.append(contentsOf: [
                quickLookView.topAnchor.constraint(equalTo: header.bottomAnchor),
                quickLookView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                quickLookView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                quickLookView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
        }
        NSLayoutConstraint.activate(constraints)
    }

    private func setupMessageLabel() {
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = KouenDesign.Typography.sidebarLabel
        messageLabel.textColor = KouenDesign.chrome.textTertiary
        messageLabel.alignment = .center
        messageLabel.isHidden = true
        view.addSubview(messageLabel)

        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            messageLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: KouenDesign.Spacing.lg),
            messageLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -KouenDesign.Spacing.lg),
        ])
    }

    // MARK: - Display state

    private func showMarkdownPreview(_ text: String, url: URL, resetScroll: Bool) {
        lspSession.close()
        messageLabel.isHidden = true
        syntaxView.isHidden = true
        quickLookView?.isHidden = true
        markdownPreviewView.isHidden = false
        modeButton.isHidden = false
        updateModeButtonUI()

        if resetScroll {
            markdownPreviewView.load(markdown: text, fileURL: url)
        } else {
            markdownPreviewView.update(markdown: text)
        }
        view.window?.makeFirstResponder(markdownPreviewView)
    }

    @objc func toggleMarkdownMode() {
        guard isMarkdownFile else { return }
        isMarkdownEditMode.toggle()
        updateModeButtonUI()

        guard let path = pathLabel.toolTip, !path.isEmpty else { return }
        let expanded = (path as NSString).expandingTildeInPath
        let url = URL(fileURLWithPath: expanded).resolvingSymlinksInPath()

        if isMarkdownEditMode {
            markdownPreviewView.isHidden = true
            showText(currentMarkdownRaw, url: url, fileExtension: "md", resetScroll: false)
            view.window?.makeFirstResponder(syntaxView)
        } else {
            let text = syntaxView.string
            currentMarkdownRaw = text
            syntaxView.isHidden = true
            markdownPreviewView.isHidden = false
            markdownPreviewView.update(markdown: text)
            view.window?.makeFirstResponder(markdownPreviewView)
        }
    }

    private func updateModeButtonUI() {
        if isMarkdownEditMode {
            modeButton.setSymbol("eye", accessibilityDescription: "Preview Markdown (⌘E)", pointSize: 11, weight: .medium)
            modeButton.toolTip = "Preview Markdown (⌘E)"
        } else {
            modeButton.setSymbol("pencil", accessibilityDescription: "Edit / View Source (⌘E)", pointSize: 11, weight: .medium)
            modeButton.toolTip = "Edit / View Source (⌘E)"
        }
    }

    private func showText(_ text: String, url: URL, fileExtension ext: String, resetScroll: Bool) {
        messageLabel.isHidden = true
        quickLookView?.isHidden = true
        markdownPreviewView.isHidden = true
        syntaxView.isHidden = false
        syntaxView.load(text: text, fileExtension: ext, resetScroll: resetScroll)
        if ["diff", "patch"].contains(ext) {
            let diffLines = GitDiffGutter.contentLines(text)
            syntaxView.setDiffLines(diffLines)
            if resetScroll, let firstChangedLine = diffLines.keys.min() {
                syntaxView.navigateTo(line: firstChangedLine, column: 1)
            }
        } else {
            let path = url.path
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
        lspSession.open(url: url, text: text, fileExtension: ext)
        view.window?.makeFirstResponder(syntaxView)
    }

    private func showQuickLook(_ url: URL) {
        lspSession.close()
        guard let quickLookView else {
            showMessage("Unable to start Quick Look preview.")
            return
        }
        modeButton.isHidden = true
        markdownPreviewView.isHidden = true
        messageLabel.isHidden = true
        syntaxView.isHidden = true
        if quickLookView.previewItem?.previewItemURL == url {
            quickLookView.refreshPreviewItem()
        } else {
            quickLookView.previewItem = url as NSURL
        }
        quickLookView.isHidden = false
    }

    private func showMessage(_ message: String) {
        lspSession.close()
        modeButton.isHidden = true
        markdownPreviewView.isHidden = true
        syntaxView.isHidden = true
        quickLookView?.isHidden = true
        messageLabel.isHidden = false
        messageLabel.stringValue = message
    }

    @objc private func backTapped() {
        onBack?()
    }

    @objc func copy(_ sender: Any?) {
        if isMarkdownFile && !isMarkdownEditMode {
            markdownPreviewView.copy(sender)
        } else {
            syntaxView.copy(sender)
        }
    }

    override func keyDown(with event: NSEvent) {
        let cmd = event.modifierFlags.contains(.command)
        let shift = event.modifierFlags.contains(.shift)
        let key = event.charactersIgnoringModifiers?.lowercased() ?? ""

        if cmd && (key == "e" || (shift && key == "v")) && isMarkdownFile {
            toggleMarkdownMode()
            return
        }

        if event.keyCode == 53 {
            onBack?()
            return
        }
        super.keyDown(with: event)
    }

    override var acceptsFirstResponder: Bool { true }

    private static let quickLookExtensions: Set<String> = loadQuickLookExtensions()

    private static func loadQuickLookExtensions() -> Set<String> {
        let file = KouenPaths.applicationSupport.appendingPathComponent("quicklook-extensions.json")
        if let data = try? Data(contentsOf: file),
           let list = try? JSONDecoder().decode([String].self, from: data),
           !list.isEmpty { return Set(list) }
        return [
            "png", "jpg", "jpeg", "gif", "webp", "svg", "ico", "bmp", "tiff", "heic",
            "pdf", "rtf", "rtfd", "doc", "docx", "pages", "key", "keynote", "numbers",
            "csv", "xls", "xlsx",
        ]
    }
}
