import AppKit
import HarnessCore

@MainActor
final class GitPanelView: NSView {
    private let scrollView = NSScrollView()
    private let stackView = NSStackView()
    private var currentPath: String?

    // Header
    private let branchLabel = NSTextField(labelWithString: "")
    private let pullButton = NSButton(title: "Pull", target: nil, action: nil)
    private let pushButton = NSButton(title: "Push", target: nil, action: nil)

    // Commit
    private let commitField = NSTextField()
    private let commitButton = NSButton(title: "Commit", target: nil, action: nil)
    private let commitPushButton = NSButton(title: "Commit+Push", target: nil, action: nil)
    private let commitAmendButton = NSButton(title: "Amend", target: nil, action: nil)
    private let stageAllButton = NSButton(title: "Stage All", target: nil, action: nil)

    // Sections
    private let changesHeader = NSTextField(labelWithString: "CHANGES")
    private let historyHeader = NSTextField(labelWithString: "HISTORY")
    private let changesStack = NSStackView()
    private let historyStack = NSStackView()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    func updateRoot(path: String) {
        guard path != currentPath else { return }
        currentPath = path
        Task { [weak self] in await self?.refresh() }
    }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false

        // Branch bar
        branchLabel.font = .monospacedSystemFont(ofSize: 11, weight: .medium)
        branchLabel.textColor = HarnessDesign.chrome.textPrimary
        branchLabel.lineBreakMode = .byTruncatingTail

        for btn in [pullButton, pushButton, stageAllButton, commitButton, commitPushButton, commitAmendButton] {
            btn.bezelStyle = .recessed; btn.controlSize = .small
            btn.font = .systemFont(ofSize: 11, weight: .medium)
        }
        pullButton.target = self; pullButton.action = #selector(pullAction)
        pushButton.target = self; pushButton.action = #selector(pushAction)
        stageAllButton.target = self; stageAllButton.action = #selector(stageAllAction)
        commitButton.target = self; commitButton.action = #selector(commitAction)
        commitPushButton.target = self; commitPushButton.action = #selector(commitPushAction)
        commitAmendButton.target = self; commitAmendButton.action = #selector(commitAmendAction)

        let branchBar = NSStackView(views: [branchLabel, pullButton, pushButton])
        branchBar.orientation = .horizontal; branchBar.spacing = 6

        // Commit area
        commitField.placeholderString = "Commit message…"
        commitField.font = .systemFont(ofSize: 12)
        commitField.isBezeled = true; commitField.bezelStyle = .roundedBezel
        commitField.focusRingType = .none
        commitField.usesSingleLineMode = false
        commitField.lineBreakMode = .byWordWrapping
        commitField.maximumNumberOfLines = 5
        commitField.translatesAutoresizingMaskIntoConstraints = false
        commitField.heightAnchor.constraint(greaterThanOrEqualToConstant: 52).isActive = true

        let btnRow = NSStackView(views: [stageAllButton, commitButton, commitPushButton, commitAmendButton])
        btnRow.orientation = .horizontal; btnRow.spacing = 4

        // Section headers
        for h in [changesHeader, historyHeader] {
            h.font = .systemFont(ofSize: 10, weight: .semibold)
            h.textColor = HarnessDesign.chrome.textTertiary
        }

        changesStack.orientation = .vertical; changesStack.alignment = .width; changesStack.spacing = 1
        historyStack.orientation = .vertical; historyStack.alignment = .width; historyStack.spacing = 0

        // Main stack
        stackView.orientation = .vertical
        stackView.alignment = .width
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(branchBar)
        stackView.addArrangedSubview(changesHeader)
        stackView.addArrangedSubview(changesStack)
        stackView.addArrangedSubview(commitField)
        stackView.addArrangedSubview(btnRow)
        stackView.addArrangedSubview(historyHeader)
        stackView.addArrangedSubview(historyStack)

        let doc = FlippedView()
        doc.translatesAutoresizingMaskIntoConstraints = false
        doc.addSubview(stackView)

        scrollView.documentView = doc
        scrollView.hasVerticalScroller = true
        scrollView.drawsBackground = false
        scrollView.scrollerStyle = .overlay
        scrollView.autohidesScrollers = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            doc.topAnchor.constraint(equalTo: scrollView.contentView.topAnchor),
            doc.leadingAnchor.constraint(equalTo: scrollView.contentView.leadingAnchor),
            doc.trailingAnchor.constraint(equalTo: scrollView.contentView.trailingAnchor),
            doc.widthAnchor.constraint(equalTo: scrollView.contentView.widthAnchor),
            stackView.topAnchor.constraint(equalTo: doc.topAnchor, constant: 6),
            stackView.leadingAnchor.constraint(equalTo: doc.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: doc.trailingAnchor, constant: -10),
            stackView.bottomAnchor.constraint(equalTo: doc.bottomAnchor, constant: -8),
        ])
    }

    // MARK: - Actions

    @objc private func pullAction() { runAndRefresh(["pull"]) }
    @objc private func pushAction() { runAndRefresh(["push"]) }
    @objc private func stageAllAction() { runAndRefresh(["add", "-A"]) }

    @objc private func commitAction() {
        guard let msg = commitMessage() else { return }
        runAndRefresh(["commit", "-m", msg], clearField: true)
    }

    @objc private func commitPushAction() {
        guard let msg = commitMessage() else { return }
        guard let path = currentPath else { return }
        Task {
            _ = await runGit(["commit", "-m", msg], in: path)
            _ = await runGit(["push"], in: path)
            commitField.stringValue = ""
            await refresh()
        }
    }

    @objc private func commitAmendAction() {
        let msg = commitField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if msg.isEmpty {
            runAndRefresh(["commit", "--amend", "--no-edit"])
        } else {
            runAndRefresh(["commit", "--amend", "-m", msg], clearField: true)
        }
    }

    @objc private func toggleStage(_ sender: NSButton) {
        guard let path = currentPath, let file = sender.toolTip else { return }
        let isStaged = sender.state == .on
        Task {
            _ = await runGit(isStaged ? ["restore", "--staged", file] : ["add", file], in: path)
            await refresh()
        }
    }

    private func commitMessage() -> String? {
        let msg = commitField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        return msg.isEmpty ? nil : msg
    }

    private func runAndRefresh(_ args: [String], clearField: Bool = false) {
        guard let path = currentPath else { return }
        Task {
            _ = await runGit(args, in: path)
            if clearField { commitField.stringValue = "" }
            await refresh()
        }
    }

    // MARK: - Refresh

    private func refresh() async {
        guard let path = currentPath else { return }
        let branch = await runGit(["branch", "--show-current"], in: path)
        let status = await runGit(["status", "--porcelain"], in: path)
        let log = await runGit(["log", "--format=%H|%an|%ar|%s", "-20"], in: path)

        branchLabel.stringValue = "⎇ " + (branch.isEmpty ? "detached" : branch)

        changesStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        historyStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Changes
        if status.isEmpty {
            changesStack.addArrangedSubview(makeLabel("Working tree clean"))
        } else {
            for line in status.components(separatedBy: "\n").prefix(30) where !line.isEmpty {
                changesStack.addArrangedSubview(makeStatusRow(line))
            }
        }

        // History (SourceTree-style)
        for line in log.components(separatedBy: "\n").prefix(20) where !line.isEmpty {
            historyStack.addArrangedSubview(makeHistoryRow(line))
        }
    }

    // MARK: - Row builders

    private func makeStatusRow(_ line: String) -> NSView {
        let xy = line.prefix(2)
        let indexStatus = String(xy.first ?? Character(" "))
        let file = String(line.dropFirst(3))
        let isStaged = indexStatus != " " && indexStatus != "?"
        let workTree = String(xy.last ?? Character(" "))

        let color: NSColor
        switch isStaged ? indexStatus : workTree {
        case "M": color = .systemOrange
        case "A": color = .systemGreen
        case "D": color = .systemRed
        case "R": color = .systemBlue
        case "?": color = .systemGreen
        default: color = HarnessDesign.chrome.textSecondary
        }

        let row = NSStackView()
        row.orientation = .horizontal; row.spacing = 4

        let check = NSButton(checkboxWithTitle: "", target: self, action: #selector(toggleStage(_:)))
        check.state = isStaged ? .on : .off
        check.toolTip = file; check.controlSize = .small

        let badge = NSTextField(labelWithString: String(xy).trimmingCharacters(in: .whitespaces))
        badge.font = .monospacedSystemFont(ofSize: 10, weight: .medium)
        badge.textColor = color
        badge.setContentHuggingPriority(.required, for: .horizontal)

        let name = NSTextField(labelWithString: (file as NSString).lastPathComponent)
        name.font = .systemFont(ofSize: 11.5)
        name.textColor = HarnessDesign.chrome.textSecondary
        name.lineBreakMode = .byTruncatingMiddle
        name.toolTip = file

        row.addArrangedSubview(check)
        row.addArrangedSubview(badge)
        row.addArrangedSubview(name)
        return row
    }

    private func makeHistoryRow(_ line: String) -> NSView {
        // format: hash|author|relative_time|subject
        let parts = line.split(separator: "|", maxSplits: 3).map(String.init)
        guard parts.count >= 4 else { return makeLabel(line) }
        let hash = String(parts[0].prefix(7))
        let author = parts[1]
        let time = parts[2]
        let subject = parts[3]

        let card = NSView()
        card.wantsLayer = true
        card.translatesAutoresizingMaskIntoConstraints = false

        let subjectLabel = NSTextField(labelWithString: subject)
        subjectLabel.font = .systemFont(ofSize: 12, weight: .regular)
        subjectLabel.textColor = HarnessDesign.chrome.textPrimary
        subjectLabel.lineBreakMode = .byTruncatingTail
        subjectLabel.translatesAutoresizingMaskIntoConstraints = false

        let metaLabel = NSTextField(labelWithString: "\(author) · \(time) · \(hash)")
        metaLabel.font = .systemFont(ofSize: 10)
        metaLabel.textColor = HarnessDesign.chrome.textTertiary
        metaLabel.lineBreakMode = .byTruncatingTail
        metaLabel.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(subjectLabel)
        card.addSubview(metaLabel)
        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 38),
            subjectLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 4),
            subjectLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 4),
            subjectLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -4),
            metaLabel.topAnchor.constraint(equalTo: subjectLabel.bottomAnchor, constant: 1),
            metaLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 4),
            metaLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -4),
        ])
        return card
    }

    private func makeLabel(_ text: String) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.font = .systemFont(ofSize: 11.5)
        label.textColor = HarnessDesign.chrome.textTertiary
        return label
    }

    // MARK: - Git runner

    private func runGit(_ args: [String], in directory: String) async -> String {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let process = Process()
                process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
                process.arguments = args
                process.currentDirectoryURL = URL(fileURLWithPath: directory)
                let pipe = Pipe()
                process.standardOutput = pipe
                process.standardError = Pipe()
                do {
                    try process.run()
                    process.waitUntilExit()
                    let data = pipe.fileHandleForReading.readDataToEndOfFile()
                    continuation.resume(returning: String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
                } catch {
                    continuation.resume(returning: "")
                }
            }
        }
    }
}

private final class FlippedView: NSView {
    override var isFlipped: Bool { true }
}
