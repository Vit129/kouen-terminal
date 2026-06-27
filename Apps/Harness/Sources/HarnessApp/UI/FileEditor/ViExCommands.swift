import AppKit
import HarnessCore
import HarnessLSP

extension ViEngine {
    // MARK: - Ex command prompt

    func presentExPrompt(_ tv: NSTextView) {
        guard let win = tv.window else { return }
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: win.frame.width, height: 28),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.backgroundColor = NSColor(white: 0.12, alpha: 0.97)
        panel.isOpaque = false

        let field = NSTextField(frame: NSRect(x: 24, y: 4, width: win.frame.width - 32, height: 20))
        field.isBordered = false
        field.drawsBackground = false
        field.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        field.textColor = .white
        field.placeholderString = ""
        let colon = NSTextField(labelWithString: ":")
        colon.frame = NSRect(x: 4, y: 4, width: 18, height: 20)
        colon.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        colon.textColor = .white

        panel.contentView?.addSubview(colon)
        panel.contentView?.addSubview(field)

        let winFrame = win.frame
        panel.setFrame(NSRect(x: winFrame.minX, y: winFrame.minY, width: winFrame.width, height: 28), display: false)
        win.addChildWindow(panel, ordered: .above)
        panel.makeFirstResponder(field)
        exPanel = panel
        exField = field

        // Monitor Enter and Esc
        var monitor: Any?
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self, weak panel, weak field] event in
            guard let panel else {
                if let monitor { NSEvent.removeMonitor(monitor) }
                return event
            }
            switch event.keyCode {
            case 36, 76: // Return / Enter
                let cmd = field?.stringValue ?? ""
                panel.orderOut(nil)
                panel.parent?.removeChildWindow(panel)
                self?.execEx(cmd, tv: tv)
                if let monitor { NSEvent.removeMonitor(monitor) }
                return nil
            case 53: // Esc
                panel.orderOut(nil)
                panel.parent?.removeChildWindow(panel)
                if let monitor { NSEvent.removeMonitor(monitor) }
                return nil
            default:
                return event
            }
        }
    }

    func execEx(_ raw: String, tv: NSTextView) {
        let cmd = raw.trimmingCharacters(in: .whitespaces)
        guard !cmd.isEmpty else { return }

        // :N  go to line number
        if let n = Int(cmd), n > 0 {
            moveToLine(tv, line: n)
            return
        }

        switch cmd {
        case "w":
            onSave?()
        case "q":
            onQuit?()
        case "wq", "x":
            onSave?(); onQuit?()
        case "wq!", "x!":
            onSave?(); onQuit?()
        case "q!":
            onQuit?()
        case "bn", "bnext":
            onNextBuffer?(1)
        case "bp", "bprev", "bprevious":
            onNextBuffer?(-1)
        case "ls", "buffers", "files":
            let list = onListBuffers?() ?? []
            let text = list.isEmpty ? "no open buffers" : list.enumerated().map { "\($0.offset + 1): \($0.element)" }.joined(separator: "\n")
            // Display via NSAlert-style toast or reuse the ex panel label
            displayExMessage(text)
            return
        case "noh", "nohlsearch":
            tv.performFindPanelAction(NSTextFinder.Action.hideFindInterface)
            onSearchHighlight?("")  // clear inline highlights
        default:
            // :set option  — notify host to apply setting
            if cmd.hasPrefix("set ") || cmd == "set" {
                execSet(String(cmd.dropFirst(4)).trimmingCharacters(in: .whitespaces), tv: tv)
                return
            }
            // :e/:edit file  — notify host to open file
            if cmd.hasPrefix("e ") || cmd.hasPrefix("edit ") {
                let dropCount = cmd.hasPrefix("edit ") ? 5 : 2
                let path = String(cmd.dropFirst(dropCount)).trimmingCharacters(in: .whitespaces)
                onOpenFile?(path)
                return
            }
            if cmd.hasPrefix("view ") {
                let path = String(cmd.dropFirst(5)).trimmingCharacters(in: .whitespaces)
                NotificationCenter.default.post(name: .viViewFileCommand, object: self, userInfo: ["path": path])
                return
            }
            if cmd.hasPrefix("find ") {
                let query = String(cmd.dropFirst(5)).trimmingCharacters(in: .whitespaces)
                NotificationCenter.default.post(name: .viFindFileCommand, object: self, userInfo: ["query": query])
                return
            }
            // :recent — show MRU file list
            if cmd == "recent" {
                let list = WorkbenchMRU.shared.entries
                if list.isEmpty {
                    displayExMessage("recent: no recently opened files")
                } else {
                    let text = list.prefix(10).enumerated().map { "\($0.offset + 1): \($0.element)" }.joined(separator: "\n")
                    displayExMessage(text)
                }
                return
            }
            // :copy-path [relative|absolute] — copy current file path
            if cmd == "copy-path" || cmd.hasPrefix("copy-path ") {
                let relative = !cmd.contains("absolute")
                if let file = onCurrentFile?() {
                    let path: String
                    if relative, let cwd = onCurrentCWD?(), file.hasPrefix(cwd + "/") {
                        path = String(file.dropFirst(cwd.count + 1))
                    } else {
                        path = file
                    }
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(path, forType: .string)
                    displayExMessage("copied: \(path)")
                } else {
                    displayExMessage("copy-path: no current file")
                }
                return
            }
            // :board — post notification to show Board tab
            if cmd == "board" {
                NotificationCenter.default.post(name: .viWorkbenchCommand, object: self, userInfo: ["command": "board"])
                return
            }
            // :attention — focus next Needs Attention board card
            if cmd == "attention" {
                let snapshot = SessionCoordinator.shared.snapshot
                let card = BoardModel.classify(snapshot: snapshot)
                    .first { $0.kind == .needsAttention }?.cards.first
                if let card {
                    SessionCoordinator.shared.selectTab(workspaceID: card.workspaceID, tabID: card.tabID)
                } else {
                    displayExMessage("attention: no items need attention")
                }
                return
            }
            // :ack — dismiss current tab's Needs Attention card
            if cmd == "ack" {
                if let tabID = SessionCoordinator.shared.snapshot.activeWorkspace?.activeTab?.id {
                    NotificationCenter.default.post(name: .viBoardAckCommand, object: self, userInfo: ["tabID": tabID.uuidString])
                    displayExMessage("acknowledged")
                }
                return
            }
            // :errors — show LSP diagnostics
            if cmd == "errors" {
                let diags = onDiagnostics?() ?? []
                if diags.isEmpty {
                    displayExMessage("no diagnostics")
                } else {
                    let text = diags.prefix(20).map { d in
                        ":\(d.range.start.line + 1):\(d.range.start.character + 1): \(d.message)"
                    }.joined(separator: "\n")
                    displayExMessage(text)
                }
                return
            }
            // :agent <command> [<file>] [--claude|--codex|--kiro] — send context to agent pane
            if cmd == "agent" || cmd.hasPrefix("agent ") {
                let raw = cmd == "agent" ? "" : String(cmd.dropFirst(6)).trimmingCharacters(in: .whitespaces)
                let bridge = AgentBridge.shared

                // Parse --agent, --model, --effort flags
                let targetKind: AgentKind?
                var targetModel: String? = nil
                var targetEffort: String? = nil
                var cleaned = raw
                // Extract --model <value>
                if let range = cleaned.range(of: #"--model\s+(\S+)"#, options: .regularExpression) {
                    targetModel = String(cleaned[range]).components(separatedBy: .whitespaces).last
                    cleaned = cleaned.replacingCharacters(in: range, with: "").trimmingCharacters(in: .whitespaces)
                }
                // Extract --effort <value>
                if let range = cleaned.range(of: #"--effort\s+(\S+)"#, options: .regularExpression) {
                    targetEffort = String(cleaned[range]).components(separatedBy: .whitespaces).last
                    cleaned = cleaned.replacingCharacters(in: range, with: "").trimmingCharacters(in: .whitespaces)
                }
                // Extract agent kind
                if cleaned.contains("--claude") {
                    targetKind = .claudeCode
                    cleaned = cleaned.replacingOccurrences(of: "--claude", with: "").trimmingCharacters(in: .whitespaces)
                } else if cleaned.contains("--codex") {
                    targetKind = .codex
                    cleaned = cleaned.replacingOccurrences(of: "--codex", with: "").trimmingCharacters(in: .whitespaces)
                } else if cleaned.contains("--kiro") {
                    targetKind = .kiro
                    cleaned = cleaned.replacingOccurrences(of: "--kiro", with: "").trimmingCharacters(in: .whitespaces)
                } else if cleaned.contains("--gemini") {
                    targetKind = .gemini
                    cleaned = cleaned.replacingOccurrences(of: "--gemini", with: "").trimmingCharacters(in: .whitespaces)
                } else {
                    targetKind = nil
                }
                let agents = bridge.allAgents()
                if agents.isEmpty || (targetKind != nil && !agents.contains(where: { $0.kind == targetKind })) {
                    let spawnKind = targetKind ?? .claudeCode
                    let spawnCmd = AgentCatalog.spawnCommand(kind: spawnKind, model: targetModel, effort: targetEffort) ?? spawnKind.rawValue
                    SessionCoordinator.shared.splitActivePaneAndRun(direction: .horizontal, command: spawnCmd)
                    displayExMessage("spawning \(spawnKind.rawValue)... retry :agent in a few seconds")
                    return
                }

                // If multiple and no flag, show list
                if targetKind == nil && agents.count > 1 && cleaned.isEmpty {
                    let list = agents.enumerated().map { "\($0.offset + 1): \($0.element.kind.rawValue) — \($0.element.tabTitle)" }.joined(separator: "\n")
                    displayExMessage("Multiple agents:\n\(list)\nUse :agent <cmd> --claude/--codex/--kiro")
                    return
                }

                // Parse subcommand and optional file path
                let parts = cleaned.split(separator: " ", maxSplits: 1).map(String.init)
                let subcommand = parts.first ?? "help"
                let filePath: String
                if parts.count > 1 {
                    // Resolve file via fuzzy match (same as :find)
                    let query = parts[1]
                    if let resolved = resolveFilePath(query) {
                        filePath = resolved
                    } else {
                        filePath = query // fallback to literal
                    }
                } else {
                    filePath = onCurrentFile?() ?? ""
                }

                switch subcommand {
                case "help":
                    displayExMessage(":agent fix|review|<msg> [<file>] [--claude|--codex|--kiro]")
                case "fix":
                    let errors = onDiagnostics?() ?? []
                    let errorText = errors.isEmpty ? "(no diagnostics)" : errors.map { ":\($0.range.start.line + 1): \($0.message)" }.joined(separator: "\n")
                    _ = bridge.sendFile(path: filePath, command: "fix these errors:\n\(errorText)", kind: targetKind)
                    displayExMessage("sent to agent: fix \(filePath)")
                case "review":
                    _ = bridge.sendFile(path: filePath, command: "review this file", kind: targetKind)
                    displayExMessage("sent to agent: review \(filePath)")
                default:
                    _ = bridge.sendFile(path: filePath, command: subcommand, kind: targetKind)
                    displayExMessage("sent to agent: \(filePath)")
                }
                return
            }
            // :grep <query> — run search in split pane
            if cmd.hasPrefix("grep ") {
                let query = String(cmd.dropFirst(5)).trimmingCharacters(in: .whitespaces)
                CommandPaletteController.present(relativeTo: NSApp.keyWindow, mode: .grep(query: query))
                return
            }
            // :make [build|test|last] — run project task
            if cmd == "make" || cmd.hasPrefix("make ") {
                let target = cmd == "make" ? nil : String(cmd.dropFirst(5)).trimmingCharacters(in: .whitespaces)
                let coordinator = SessionCoordinator.shared
                let cwd = WorkbenchContextResolver.resolve(
                    snapshot: coordinator.snapshot,
                    focusedSurfaceID: coordinator.activeSurfaceID,
                    currentFilePath: onCurrentFile?()
                )?.cwd ?? "."
                let task = ProjectTaskDetector.detect(at: cwd)
                let runCmd: String
                switch target {
                case "build": runCmd = task?.buildCmd ?? "swift build"
                case "test": runCmd = task?.testCmd ?? "swift test"
                case "last": runCmd = lastMakeCommand ?? task?.defaultCmd ?? "swift build"
                default: runCmd = task?.defaultCmd ?? task?.buildCmd ?? "swift build"
                }
                lastMakeCommand = runCmd
                SessionCoordinator.shared.splitActivePaneAndRun(direction: .horizontal, command: runCmd)
                return
            }
            if cmd.hasPrefix("split ") || cmd.hasPrefix("sp ") || cmd.hasPrefix("vsplit ") || cmd.hasPrefix("vsp ") {
                let isVertical = cmd.hasPrefix("vsplit ") || cmd.hasPrefix("vsp ")
                let dropCount = cmd.hasPrefix("vsplit ") ? 7 : (cmd.hasPrefix("split ") ? 6 : 3)
                let path = String(cmd.dropFirst(dropCount)).trimmingCharacters(in: .whitespaces)
                NotificationCenter.default.post(
                    name: .viSplitFileCommand,
                    object: self,
                    userInfo: ["path": path, "direction": isVertical ? "vertical" : "horizontal"]
                )
                return
            }
            // :s/old/new/flags  or  :%s/old/new/flags
            if cmd.hasPrefix("%s/") || cmd.hasPrefix("s/") {
                execSubstitute(cmd, tv: tv)
            } else if cmd.hasPrefix("s") {
                execSubstitute(cmd, tv: tv)
            }
        }
    }

    func displayExMessage(_ text: String) {
        guard let tv = textView, let win = tv.window else { return }
        // Reuse the ex panel style — show briefly then auto-dismiss
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: win.frame.width, height: CGFloat(22 + text.components(separatedBy: "\n").count * 18)),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered, defer: false
        )
        panel.isFloatingPanel = true; panel.level = .floating
        panel.backgroundColor = NSColor(white: 0.12, alpha: 0.95)
        let label = NSTextField(wrappingLabelWithString: text)
        label.frame = NSRect(x: 8, y: 4, width: win.frame.width - 16, height: panel.frame.height - 8)
        label.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        label.textColor = .white
        panel.contentView?.addSubview(label)
        let wf = win.frame
        panel.setFrame(NSRect(x: wf.minX, y: wf.minY, width: wf.width, height: panel.frame.height), display: false)
        win.addChildWindow(panel, ordered: .above)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            panel.orderOut(nil); panel.parent?.removeChildWindow(panel)
        }
    }

    func execSet(_ setting: String, tv: NSTextView) {
        // Handle boolean toggles and key=value pairs
        switch setting {
        case "number", "nu":         onSetOption?("number", "true")
        case "nonumber", "nonu":     onSetOption?("number", "false")
        case "relativenumber", "rnu": onSetOption?("relativenumber", "true")
        case "norelativenumber", "nornu": onSetOption?("relativenumber", "false")
        case "hlsearch", "hls":      onSetOption?("hlsearch", "true")
        case "nohlsearch", "nohls":
            onSetOption?("hlsearch", "false")
            tv.performFindPanelAction(NSTextFinder.Action.hideFindInterface)
        case "ignorecase", "ic":     onSetOption?("ignorecase", "true")
        case "noignorecase", "noic": onSetOption?("ignorecase", "false")
        case "wrap":                 onSetOption?("wrap", "true")
        case "nowrap":               onSetOption?("wrap", "false")
        default:
            if setting.contains("=") {
                let parts = setting.components(separatedBy: "=")
                if parts.count == 2 { onSetOption?(parts[0], parts[1]) }
            }
        }
    }

    func execSubstitute(_ cmd: String, tv: NSTextView) {
        let global = cmd.hasPrefix("%")
        let body = global ? String(cmd.dropFirst()) : cmd          // strip %
        // parse  s/old/new/flags
        guard body.hasPrefix("s") else { return }
        let rest = String(body.dropFirst())                         // /old/new/flags
        guard rest.hasPrefix("/") else { return }
        let parts = rest.dropFirst().components(separatedBy: "/")  // ["old","new","flags"]
        guard parts.count >= 2 else { return }
        let pattern = parts[0], replacement = parts[1]
        let flags = parts.count > 2 ? parts[2] : ""
        let replaceAll = flags.contains("g") || global
        let ns = tv.string as NSString
        tv.isEditable = true
        if global || replaceAll {
            let replaced = ns.replacingOccurrences(of: pattern, with: replacement,
                options: .literal, range: NSRange(location: 0, length: ns.length))
            tv.replaceCharacters(in: NSRange(location: 0, length: ns.length), with: replaced)
        } else {
            // current line only, first occurrence
            let pos = cursorPos(tv)
            let lineR = NSRange(location: lineStart(tv, at: pos), length: lineEnd(tv, at: pos) - lineStart(tv, at: pos))
            let lineText = ns.substring(with: lineR)
            let replaced = (lineText as NSString).replacingOccurrences(of: pattern, with: replacement,
                options: .literal, range: NSRange(location: 0, length: (lineText as NSString).length))
            tv.replaceCharacters(in: lineR, with: replaced)
        }
        tv.isEditable = false
    }

    // MARK: - Search

    func beginSearch(_ tv: NSTextView, forward: Bool) {
        // Use NSTextView's built-in find panel
        tv.performFindPanelAction(NSTextFinder.Action.showFindInterface)
        lastSearch.forward = forward
    }

    func repeatSearch(_ tv: NSTextView, reverse: Bool, count: Int) {
        let fwd = reverse ? !lastSearch.forward : lastSearch.forward
        for _ in 0..<count {
            if fwd {
                tv.performFindPanelAction(NSTextFinder.Action.nextMatch)
            } else {
                tv.performFindPanelAction(NSTextFinder.Action.previousMatch)
            }
        }
    }

    func searchWordUnderCursor(_ tv: NSTextView, forward: Bool) {
        let pos = cursorPos(tv)
        let ns = tv.string as NSString
        var start = pos, end = pos
        while start > 0 && isWordChar(ns.character(at: start - 1), bigWord: false) { start -= 1 }
        while end < ns.length && isWordChar(ns.character(at: end), bigWord: false) { end += 1 }
        let word = ns.substring(with: NSRange(location: start, length: end - start))
        lastSearch = (word, forward)
        onSearchHighlight?(word)
        repeatSearch(tv, reverse: false, count: 1)
    }

    // MARK: - LSP integrations

    func openPathUnderCursor(_ tv: NSTextView) {
        guard let raw = pathTokenUnderCursor(tv) else {
            displayExMessage("gf: no path under cursor")
            return
        }
        onOpenFile?(Self.stripLineColumnSuffix(raw))
    }

    func goToDefinition(_ tv: NSTextView) {
        let position = lspPosition(tv)
        Task { [weak self] in
            guard let self else { return }
            if let target = await self.onDefinition?(position) {
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    self.pushJumpPublic(self.cursorPos(tv))
                    self.onNavigateToDefinition?(target)
                }
                return
            }
            await MainActor.run { [weak self] in
                guard let self else { return }
                if let raw = self.pathTokenUnderCursor(tv) {
                    self.onOpenFile?(Self.stripLineColumnSuffix(raw))
                } else {
                    self.displayExMessage("gd: no definition")
                }
            }
        }
    }

    func showHover(_ tv: NSTextView) {
        let position = lspPosition(tv)
        Task { [weak self] in
            guard let self else { return }
            let text = await self.onHover?(position)
            await MainActor.run { [weak self] in
                guard let self else { return }
                guard let text, !text.isEmpty else {
                    self.displayExMessage("K: no hover")
                    return
                }
                self.displayExMessage(text)
            }
        }
    }

    func jumpDiagnostic(_ tv: NSTextView, forward: Bool) {
        let diagnostics = onDiagnostics?() ?? []
        let currentLine = lspPosition(tv).line
        guard let index = ViDiagnosticNavigator.targetIndex(currentLine: currentLine, diagnostics: diagnostics, forward: forward) else {
            displayExMessage("no diagnostics")
            return
        }
        let diagnostic = diagnostics[index]
        moveToLSPPosition(tv, diagnostic.range.start)
        displayExMessage(diagnostic.message.isEmpty ? "diagnostic" : diagnostic.message)
    }

    func moveToLSPPosition(_ tv: NSTextView, _ position: LSPPosition) {
        let ns = tv.string as NSString
        let lineStart = offset(line: position.line, character: 0, in: ns)
        guard lineStart != NSNotFound else { return }
        let target = min(lineEnd(tv, at: lineStart), lineStart + max(0, position.character))
        tv.setSelectedRange(NSRange(location: target, length: 0))
        tv.scrollRangeToVisible(NSRange(location: target, length: 0))
    }

    func lspPosition(_ tv: NSTextView) -> LSPPosition {
        let ns = tv.string as NSString
        let offset = min(cursorPos(tv), ns.length)
        var line = 0
        var lineStart = 0
        ns.enumerateSubstrings(
            in: NSRange(location: 0, length: offset),
            options: [.byLines, .substringNotRequired]
        ) { _, range, _, _ in
            line += 1
            lineStart = NSMaxRange(range)
        }
        return LSPPosition(line: max(0, line), character: max(0, offset - lineStart))
    }

    func offset(line: Int, character: Int, in text: NSString) -> Int {
        var currentLine = 0
        var result = NSNotFound
        text.enumerateSubstrings(in: NSRange(location: 0, length: text.length), options: [.byLines, .substringNotRequired]) { _, range, _, stop in
            if currentLine == line {
                result = min(range.location + max(0, character), NSMaxRange(range))
                stop.pointee = true
            }
            currentLine += 1
        }
        if result == NSNotFound, line == currentLine {
            result = text.length
        }
        return result
    }

    func pathTokenUnderCursor(_ tv: NSTextView) -> String? {
        let ns = tv.string as NSString
        guard ns.length > 0 else { return nil }
        let pos = min(cursorPos(tv), max(0, ns.length - 1))
        var start = pos
        var end = pos
        while start > 0 && Self.isPathTokenChar(ns.character(at: start - 1)) { start -= 1 }
        while end < ns.length && Self.isPathTokenChar(ns.character(at: end)) { end += 1 }
        let token = ns.substring(with: NSRange(location: start, length: end - start))
            .trimmingCharacters(in: CharacterSet(charactersIn: "'\"`()[]{}<>"))
        return token.contains("/") || token.contains(".") || token.hasPrefix("~") ? token : nil
    }

    static func isPathTokenChar(_ c: unichar) -> Bool {
        guard let scalar = UnicodeScalar(c) else { return false }
        if CharacterSet.alphanumerics.contains(scalar) { return true }
        return "/._-~:@+".unicodeScalars.contains(scalar)
    }

    static func stripLineColumnSuffix(_ token: String) -> String {
        let parts = token.split(separator: ":", omittingEmptySubsequences: false)
        guard parts.count >= 2, let last = parts.last, Int(last) != nil else { return token }
        if parts.count >= 3, Int(parts[parts.count - 2]) != nil {
            return parts.dropLast(2).joined(separator: ":")
        }
        return parts.dropLast().joined(separator: ":")
    }

    /// Resolve a partial file name via fuzzy matching against the current workspace root.
    private func resolveFilePath(_ query: String) -> String? {
        let cwd = onCurrentCWD?() ?? FileManager.default.currentDirectoryPath
        switch FuzzyPathResolver.resolve(query: query, root: cwd, limit: 1) {
        case .unique(let path): return path
        case .ambiguous(let paths): return paths.first
        case .none: return nil
        }
    }
}
