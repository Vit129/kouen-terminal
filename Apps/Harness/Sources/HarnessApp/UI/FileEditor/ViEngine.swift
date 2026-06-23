import AppKit
import HarnessLSP

// MARK: - Vi Mode State

enum ViMode: Equatable {
    case normal
    case insert
    case visual(line: Bool)    // v = char, V = line
    case replace               // R
    case operatorPending(op: Character)  // d/c/y waiting for motion/text-object
}

enum ViDiagnosticNavigator {
    static func targetIndex(currentLine: Int, diagnostics: [LSPDiagnostic], forward: Bool) -> Int? {
        guard !diagnostics.isEmpty else { return nil }
        let sorted = diagnostics.enumerated().sorted {
            let lhs = $0.element.range.start
            let rhs = $1.element.range.start
            if lhs.line == rhs.line { return lhs.character < rhs.character }
            return lhs.line < rhs.line
        }
        if forward {
            return sorted.first { $0.element.range.start.line > currentLine }?.offset ?? sorted.first?.offset
        }
        return sorted.last { $0.element.range.start.line < currentLine }?.offset ?? sorted.last?.offset
    }
}

// MARK: - Vi Engine

/// Pure vi normal-mode engine operating on NSTextView.
/// Supports: hjkl, w/W/b/B/e/E, 0/^/$/gg/G, {/}, Ctrl+d/u/f/b, %
/// Operators: d, c, y (+ motions + text objects)
/// Doubles: dd, cc, yy
/// Text objects: iw/aw, i"/a", i'/a', i`/a`, i(/a(, i[/a[, i{/a{
/// Visual: v (char), V (line) — d/c/y/>/< in visual
/// Editing: x, X, r, R, ~, J, p, P, u, Ctrl+r, ., o, O, a, A, I
/// Search: /, ?, n, N, *, #
/// Count prefix: 3w, 5j, 2dd …
@MainActor
final class ViEngine {
    weak var textView: NSTextView?
    private(set) var mode: ViMode = .normal
    var onModeChange: ((ViMode) -> Void)?
    /// Called when `:w` or `:wq` is executed — host provides save behaviour.
    var onSave: (() -> Void)?
    /// Called when `:q` or `:wq` is executed — host closes the file/pane.
    var onQuit: (() -> Void)?
    /// Called when `:e <path>` is executed — host opens the file in the editor.
    var onOpenFile: ((String) -> Void)?
    /// Called when `:set` changes a visual setting (key, value pairs like "number"=true).
    var onSetOption: ((String, String) -> Void)?
    /// Called for :bn/:bp buffer navigation — host switches to next/prev tab. delta = +1 or -1.
    var onNextBuffer: ((Int) -> Void)?
    /// Called for :ls/:buffers — host returns list of open tab names for display.
    var onListBuffers: (() -> [String])?
    /// Called when * / # search word — host highlights all matches inline.
    var onSearchHighlight: ((String) -> Void)?
    var onHover: ((LSPPosition) async -> String?)?
    var onDefinition: ((LSPPosition) async -> SyntaxDefinitionTarget?)?
    var onNavigateToDefinition: ((SyntaxDefinitionTarget) -> Void)?
    var onDiagnostics: (() -> [LSPDiagnostic])?
    /// Returns the current file path being edited (for :copy-path).
    var onCurrentFile: (() -> String?)?
    /// Returns the current working directory (for :copy-path relative).
    var onCurrentCWD: (() -> String?)?
    /// Last :make command for :make last.
    var lastMakeCommand: String?

    // Count prefix accumulation
    var countBuf = ""
    // For pending operator (d/c/y) + text-object multi-char (i"/iw etc.)
    var pendingTextObject = false   // waiting for inner/outer char
    var pendingInner = false
    // Yank register (unnamed) + named registers a-z
    var register: String = ""
    var registerIsLine = false
    var namedRegisters: [Character: (text: String, isLine: Bool)] = [:]
    var activeRegister: Character? = nil   // set by "a before operator
    var pendingRegister = false            // waiting for register name char
    // Marks a-z (local), A-Z (global treated same here)
    var marks: [Character: Int] = [:]
    var lastJumpPos: Int = 0       // for '' and `` (jump back)
    // Jump list (Ctrl+o / Ctrl+i)
    var jumpList: [Int] = []
    var jumpIndex: Int = -1        // current position in jumpList
    // Last visual selection for gv
    var lastVisualRange: NSRange = NSRange(location: 0, length: 0)
    var lastVisualIsLine: Bool = false
    // Last edit for . repeat
    var lastEdit: (() -> Void)?
    // Visual anchor
    var visualAnchor: Int = 0
    // Search
    var lastSearch: (pattern: String, forward: Bool) = ("", true)
    // Macro recording: register char → accumulated keys
    var recordingMacro: Character? = nil
    var macroBuffer: String = ""
    var macros: [Character: String] = [:]
    var pendingMacroPlay = false     // waiting for register char after @
    var pendingMacroRecord = false   // waiting for register char after q
    var lastPlayedMacro: Character? = nil

    // Pending state (kept as private vars to avoid complex associated values)
    var pendingG = false
    var pendingDiagnosticJump: Bool?
    var pendingZ = false
    var pendingMark = false
    var pendingMarkJump = false
    var pendingFind: (forward: Bool, till: Bool)? = nil
    var pendingReplace = false
    var pendingOp: Character? = nil

    var lastFindChar: (char: String, forward: Bool, till: Bool) = ("", true, false)

    weak var exPanel: NSPanel?
    weak var exField: NSTextField?

    func enter(mode newMode: ViMode) {
        // Save visual selection before leaving visual mode (for gv)
        if case let .visual(isLine) = mode, let tv = textView {
            let sel = tv.selectedRange()
            if sel.length > 0 {
                lastVisualRange = sel
                lastVisualIsLine = isLine
            }
        }
        mode = newMode
        onModeChange?(newMode)
        if case .insert = newMode {
            textView?.isEditable = true
        } else {
            textView?.isEditable = false
        }
    }

    /// Returns true if the event was consumed.
    func handle(_ event: NSEvent) -> Bool {
        guard let tv = textView else { return false }
        let flags = event.modifierFlags
        let cmd = flags.contains(.command)
        let ctrl = flags.contains(.control)
        let shift = flags.contains(.shift)
        let chars = event.characters ?? ""
        let key = event.charactersIgnoringModifiers ?? ""

        // ⌘ key combinations (⌘C, ⌘A, ⌘V, etc.) are system shortcuts — pass through.
        if cmd { return false }

        // Record keystrokes when macro recording is active (before dispatch)
        if recordingMacro != nil, case .normal = mode, !cmd, !ctrl {
            if event.keyCode != 53 { // not Esc
                macroBuffer += key
            }
        }
        // Esc always returns to normal from any mode
        if event.keyCode == 53 {
            if case .insert = mode { clampCursorOffEOL(tv) }
            enter(mode: .normal)
            countBuf = ""
            pendingTextObject = false
            return true
        }

        switch mode {
        case .insert, .replace:
            return false  // let NSTextView handle
        case .visual:
            return handleVisual(key: key, chars: chars, ctrl: ctrl, shift: shift, cmd: cmd, tv: tv)
        case .normal:
            return handleNormal(key: key, chars: chars, ctrl: ctrl, shift: shift, cmd: cmd, event: event, tv: tv)
        case .operatorPending(let op):
            return handleOperatorPending(op: op, key: key, chars: chars, tv: tv)
        }
    }

    func pushJump(_ pos: Int) {
        // Truncate forward history, append current
        if jumpIndex < jumpList.count - 1 {
            jumpList = Array(jumpList.prefix(jumpIndex + 1))
        }
        jumpList.append(pos)
        if jumpList.count > 100 { jumpList.removeFirst() }
        jumpIndex = jumpList.count - 1
    }

    func pushJumpPublic(_ pos: Int) { pushJump(pos) }  // called after go-to-def

    func jumpListBack(_ tv: NSTextView) {
        guard jumpIndex > 0 else { return }
        if jumpIndex == jumpList.count - 1 { pushJump(cursorPos(tv)); jumpIndex -= 1 }
        jumpIndex -= 1
        let pos = jumpList[jumpIndex]
        tv.setSelectedRange(NSRange(location: pos, length: 0))
        tv.scrollRangeToVisible(NSRange(location: pos, length: 0))
    }

    func jumpListForward(_ tv: NSTextView) {
        guard jumpIndex < jumpList.count - 1 else { return }
        jumpIndex += 1
        let pos = jumpList[jumpIndex]
        tv.setSelectedRange(NSRange(location: pos, length: 0))
        tv.scrollRangeToVisible(NSRange(location: pos, length: 0))
    }

    func playMacro(_ register: Character, tv: NSTextView, count: Int) {
        guard let macro = macros[register] else { return }
        lastPlayedMacro = register
        // Re-execute stored keystroke string by directly calling the action dispatcher.
        // Each char is treated as a plain normal-mode key (no modifiers).
        for _ in 0..<count {
            for ch in macro {
                let k = String(ch)
                _ = dispatchNormalKey(k, tv: tv)
            }
        }
    }

    /// Minimal key dispatch used by macro playback (no NSEvent needed).
    func dispatchNormalKey(_ key: String, tv: NSTextView) -> Bool {
        let count = max(1, Int(countBuf) ?? 1)
        countBuf = ""
        switch key {
        case "h": move(tv, by: -count)
        case "l": move(tv, by:  count)
        case "j": moveLines(tv, by:  count)
        case "k": moveLines(tv, by: -count)
        case "w": moveWords(tv, count: count, forward: true,  bigWord: false, toEnd: false)
        case "b": moveWords(tv, count: count, forward: false, bigWord: false, toEnd: false)
        case "e": moveWords(tv, count: count, forward: true,  bigWord: false, toEnd: true)
        case "0": moveLine(tv, to: .start)
        case "^": moveLine(tv, to: .firstNonBlank)
        case "$": moveLine(tv, to: .end)
        case "x": deleteChar(tv, forward: true, count: count)
        case "X": deleteChar(tv, forward: false, count: count)
        case "p": paste(tv, before: false, count: count)
        case "P": paste(tv, before: true, count: count)
        case "u": tv.undoManager?.undo()
        case "J": joinLines(tv, count: count)
        case "~": toggleCase(tv, count: count)
        case "1", "2", "3", "4", "5", "6", "7", "8", "9":
            countBuf += key; return true
        default: return false
        }
        return true
    }

    // MARK: - Basic movement/cursor helpers

    func cursorPos(_ tv: NSTextView) -> Int {
        tv.selectedRange().location
    }

    func eofPos(_ tv: NSTextView) -> Int {
        tv.string.utf16.count
    }

    func lineHeight(_ tv: NSTextView) -> CGFloat {
        tv.font?.pointSize ?? 14
    }

    func move(_ tv: NSTextView, by delta: Int) {
        let pos = cursorPos(tv)
        let ns = tv.string as NSString
        let len = ns.length
        let new = max(0, min(len, pos + delta))
        tv.setSelectedRange(NSRange(location: new, length: 0))
    }

    func moveLines(_ tv: NSTextView, by delta: Int) {
        let pos = cursorPos(tv)
        let ns = tv.string as NSString
        var line = 0, col = 0
        posToLineCol(ns, pos: pos, line: &line, col: &col)
        let targetLine = max(0, min(lineCount(tv) - 1, line + delta))
        let newPos = lineColToPos(ns, line: targetLine, col: col)
        tv.setSelectedRange(NSRange(location: newPos, length: 0))
    }

    func posToLineCol(_ ns: NSString, pos: Int, line: inout Int, col: inout Int) {
        var p = 0, ln = 0
        let len = ns.length
        while p < pos && p < len {
            if ns.character(at: p) == 10 { ln += 1 }
            p += 1
        }
        line = ln
        // column = distance from last newline
        var c = pos - 1
        while c >= 0 && ns.character(at: c) != 10 { c -= 1 }
        col = pos - (c + 1)
    }

    func lineColToPos(_ ns: NSString, line: Int, col: Int) -> Int {
        var ln = 0, p = 0
        let len = ns.length
        while p < len && ln < line {
            if ns.character(at: p) == 10 { ln += 1 }
            p += 1
        }
        // p is now at start of target line
        let lineStart = p
        var lineEnd = p
        while lineEnd < len && ns.character(at: lineEnd) != 10 { lineEnd += 1 }
        return min(lineStart + col, max(lineStart, lineEnd - 1))
    }

    func lineCount(_ tv: NSTextView) -> Int {
        return (tv.string.components(separatedBy: "\n").count)
    }

    func lineStart(_ tv: NSTextView, at pos: Int) -> Int {
        let ns = tv.string as NSString
        var p = min(pos, ns.length - 1)
        if p < 0 { return 0 }
        while p > 0 && ns.character(at: p - 1) != 10 { p -= 1 }
        return p
    }

    func lineEnd(_ tv: NSTextView, at pos: Int) -> Int {
        let ns = tv.string as NSString
        var p = min(pos, ns.length - 1)
        if p < 0 { return 0 }
        while p < ns.length && ns.character(at: p) != 10 { p += 1 }
        return p > 0 ? p - 1 : 0
    }

    enum LinePos { case start, firstNonBlank, end }

    func moveLine(_ tv: NSTextView, to pos: LinePos) {
        let cur = cursorPos(tv)
        let start = lineStart(tv, at: cur)
        let end = lineEnd(tv, at: cur)
        switch pos {
        case .start:
            tv.setSelectedRange(NSRange(location: start, length: 0))
        case .firstNonBlank:
            let ns = tv.string as NSString
            var p = start
            while p <= end && (ns.character(at: p) == 32 || ns.character(at: p) == 9) { p += 1 }
            tv.setSelectedRange(NSRange(location: min(p, end), length: 0))
        case .end:
            tv.setSelectedRange(NSRange(location: max(start, end), length: 0))
        }
    }

    func moveToLine(_ tv: NSTextView, line: Int) {
        let ns = tv.string as NSString
        let targetLine = max(1, min(line, lineCount(tv))) - 1  // 0-based
        let newPos = lineColToPos(ns, line: targetLine, col: 0)
        tv.setSelectedRange(NSRange(location: newPos, length: 0))
        tv.scrollRangeToVisible(NSRange(location: newPos, length: 0))
    }

    func clampCursorOffEOL(_ tv: NSTextView) {
        let pos = cursorPos(tv)
        let end = lineEnd(tv, at: pos)
        let start = lineStart(tv, at: pos)
        if pos > end && end >= start {
            tv.setSelectedRange(NSRange(location: end, length: 0))
        }
    }

    func scroll(_ tv: NSTextView, lines: CGFloat, down: Bool) {
        let lh = lineHeight(tv)
        let delta = lh * lines * (down ? 1 : -1)
        let origin = NSPoint(x: tv.visibleRect.origin.x, y: tv.visibleRect.origin.y + delta)
        tv.scroll(origin)
    }
}
