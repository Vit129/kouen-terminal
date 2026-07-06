import AppKit
import KouenLSP

extension ViEngine {
    // MARK: - Operator pending

    func handleOperatorPending(op: Character, key: String, chars: String, tv: NSTextView) -> Bool {
        let count = max(1, Int(countBuf) ?? 1)
        countBuf = ""

        // Double operator: dd / cc / yy / >> / <<
        if String(op) == key {
            switch op {
            case "d": let e: () -> Void = { [weak self] in self?.deleteLine(tv, count: count) }; e(); lastEdit = e
            case "c": deleteLine(tv, count: count); enter(mode: .insert)
            case "y": yankLines(tv, count: count)
            case ">": indentLines(tv, count: count, indent: true)
            case "<": indentLines(tv, count: count, indent: false)
            default: break
            }
            enter(mode: .normal)
            return true
        }

        // Text object prefix: i / a
        if key == "i" || key == "a" {
            pendingTextObject = true
            pendingInner = key == "i"
            pendingOp = op
            enter(mode: .normal)   // stay normal, wait for next char
            return true
        }

        // Motion
        var range: NSRange? = nil
        switch key {
        case "w": range = wordRange(tv, count: count, bigWord: false)
        case "W": range = wordRange(tv, count: count, bigWord: true)
        case "b": range = wordRangeBack(tv, count: count, bigWord: false)
        case "B": range = wordRangeBack(tv, count: count, bigWord: true)
        case "e": range = wordEndRange(tv, count: count, bigWord: false)
        case "E": range = wordEndRange(tv, count: count, bigWord: true)
        case "0": range = rangeToLineStart(tv, firstNonBlank: false)
        case "^": range = rangeToLineStart(tv, firstNonBlank: true)
        case "$":
            range = rangeToLineEnd(tv)
        case "D" where op == "d":
            range = rangeToLineEnd(tv)
        case "h": range = NSRange(location: max(0, cursorPos(tv) - count), length: count)
        case "l": range = NSRange(location: cursorPos(tv), length: count)
        case "j": range = rangeLines(tv, count: count + 1, includeCurrent: true)
        case "k": range = rangeLines(tv, count: -(count + 1), includeCurrent: true)
        case "g":
            pendingG = true
            return true
        case "G":
            let start = min(cursorPos(tv), eofPos(tv))
            let end = eofPos(tv)
            range = NSRange(location: start, length: end - start)
        case "{": range = rangeOverParagraph(tv, forward: false, count: count)
        case "}": range = rangeOverParagraph(tv, forward: true, count: count)
        default: break
        }

        if pendingG {
            pendingG = false
            // gg motion in operator context = from cursor to file start
            if key == "g" {
                let pos = cursorPos(tv)
                range = NSRange(location: 0, length: pos)
            }
        }

        if let r = range {
            applyOperator(op: op, range: r, tv: tv)
        }
        enter(mode: op == "c" ? .insert : .normal)
        return true
    }

    func applyOperatorTextObject(op: Character, char: String, inner: Bool, tv: NSTextView) {
        guard let range = textObjectRange(tv, char: char, inner: inner) else {
            enter(mode: .normal)
            return
        }
        applyOperator(op: op, range: range, tv: tv)
        enter(mode: op == "c" ? .insert : .normal)
    }

    func applyOperator(op: Character, range: NSRange, tv: NSTextView) {
        let text = (tv.string as NSString).substring(with: range)
        switch op {
        case "d":
            registerIsLine = false; register = text
            let e: () -> Void = { [weak self] in self?.deleteRange(tv, range: range) }
            e(); lastEdit = e
        case "c":
            registerIsLine = false; register = text
            deleteRange(tv, range: range)
        case "y":
            registerIsLine = false; register = text
            // Move cursor to start of yanked region
            tv.setSelectedRange(NSRange(location: range.location, length: 0))
        case ">":
            indentRange(tv, range: range, indent: true)
        case "<":
            indentRange(tv, range: range, indent: false)
        default: break
        }
    }

    // MARK: - Visual mode

    func handleVisual(key: String, chars: String, ctrl: Bool, shift: Bool, cmd: Bool, tv: NSTextView) -> Bool {
        let count = max(1, Int(countBuf) ?? 1)
        countBuf = ""

        guard case let .visual(isLine) = mode else { return false }

        // Motions (move head, anchor stays)
        switch key {
        case "h": move(tv, by: -count); updateVisualSelection(tv); return true
        case "l": move(tv, by:  count); updateVisualSelection(tv); return true
        case "j": moveLines(tv, by:  count); updateVisualSelection(tv); return true
        case "k": moveLines(tv, by: -count); updateVisualSelection(tv); return true
        case "w": moveWords(tv, count: count, forward: true,  bigWord: false, toEnd: false); updateVisualSelection(tv); return true
        case "W": moveWords(tv, count: count, forward: true,  bigWord: true,  toEnd: false); updateVisualSelection(tv); return true
        case "b": moveWords(tv, count: count, forward: false, bigWord: false, toEnd: false); updateVisualSelection(tv); return true
        case "B": moveWords(tv, count: count, forward: false, bigWord: true,  toEnd: false); updateVisualSelection(tv); return true
        case "e": moveWords(tv, count: count, forward: true,  bigWord: false, toEnd: true);  updateVisualSelection(tv); return true
        case "0": moveLine(tv, to: .start);         updateVisualSelection(tv); return true
        case "^": moveLine(tv, to: .firstNonBlank); updateVisualSelection(tv); return true
        case "$": moveLine(tv, to: .end);            updateVisualSelection(tv); return true
        case "g":
            if pendingG { pendingG = false; moveToLine(tv, line: 1); updateVisualSelection(tv); return true }
            pendingG = true; return true
        case "G": moveToLine(tv, line: lineCount(tv)); updateVisualSelection(tv); return true
        case "{": moveParagraph(tv, forward: false, count: count); updateVisualSelection(tv); return true
        case "}": moveParagraph(tv, forward: true, count: count);  updateVisualSelection(tv); return true

        // Operators on selection
        case "d", "x":
            let sel = tv.selectedRange()
            if sel.length > 0 {
                register = (tv.string as NSString).substring(with: sel)
                registerIsLine = isLine
                deleteRange(tv, range: sel)
            }
            enter(mode: .normal)
            return true
        case "y":
            let sel = tv.selectedRange()
            register = sel.length > 0 ? (tv.string as NSString).substring(with: sel) : ""
            registerIsLine = isLine
            tv.setSelectedRange(NSRange(location: visualAnchor, length: 0))
            enter(mode: .normal)
            return true
        case "c":
            let sel = tv.selectedRange()
            if sel.length > 0 {
                register = (tv.string as NSString).substring(with: sel)
                registerIsLine = isLine
                deleteRange(tv, range: sel)
            }
            enter(mode: .insert)
            return true
        case ">":
            indentRange(tv, range: tv.selectedRange(), indent: true)
            enter(mode: .normal)
            return true
        case "<":
            indentRange(tv, range: tv.selectedRange(), indent: false)
            enter(mode: .normal)
            return true
        case "=":
            // auto-indent: re-indent selected lines (same as >, simplified to remove+re-add leading whitespace to match shiftwidth 4)
            indentRange(tv, range: tv.selectedRange(), indent: false)  // strip existing
            enter(mode: .normal)
            return true
        case "u":
            lowercaseRange(tv, range: tv.selectedRange())
            enter(mode: .normal)
            return true
        case "U":
            uppercaseRange(tv, range: tv.selectedRange())
            enter(mode: .normal)
            return true
        case "~":
            toggleCaseRange(tv, range: tv.selectedRange())
            enter(mode: .normal)
            return true
        case "v":
            // toggle between char/line visual
            if isLine {
                visualAnchor = cursorPos(tv)
                enter(mode: .visual(line: false))
            } else {
                enter(mode: .normal)
            }
            return true
        case "V":
            if !isLine {
                visualAnchor = lineStart(tv, at: cursorPos(tv))
                enter(mode: .visual(line: true))
                updateVisualSelection(tv)
            } else {
                enter(mode: .normal)
            }
            return true
        case "o":   // swap anchor and head
            let sel = tv.selectedRange()
            let otherEnd = sel.location == visualAnchor ? sel.location + sel.length : sel.location
            visualAnchor = cursorPos(tv)
            tv.setSelectedRange(NSRange(location: otherEnd, length: 0))
            updateVisualSelection(tv)
            return true
        default: break
        }
        return false
    }

    func updateVisualSelection(_ tv: NSTextView) {
        guard case let .visual(isLine) = mode else { return }
        let cur = cursorPos(tv)
        let lo = min(visualAnchor, cur)
        let hi = max(visualAnchor, cur)
        if isLine {
            let start = lineStart(tv, at: lo)
            let end   = lineEnd(tv, at: hi) + 1 // include newline
            let clamped = min(end, tv.string.utf16.count)
            tv.setSelectedRange(NSRange(location: start, length: max(0, clamped - start)))
        } else {
            tv.setSelectedRange(NSRange(location: lo, length: hi - lo + 1))
        }
    }

    // MARK: - Edit operations

    func deleteRange(_ tv: NSTextView, range: NSRange) {
        let clamped = NSRange(location: range.location,
                              length: min(range.length, tv.string.utf16.count - range.location))
        guard clamped.length > 0 else { return }
        tv.isEditable = true
        tv.replaceCharacters(in: clamped, with: "")
        tv.isEditable = (mode == .insert)
        tv.setSelectedRange(NSRange(location: min(clamped.location, tv.string.utf16.count), length: 0))
    }

    func deleteChar(_ tv: NSTextView, forward: Bool, count: Int) {
        let pos = cursorPos(tv)
        let len = tv.string.utf16.count
        if forward {
            let end = min(pos + count, len)
            register = (tv.string as NSString).substring(with: NSRange(location: pos, length: end - pos))
            deleteRange(tv, range: NSRange(location: pos, length: end - pos))
        } else {
            let start = max(0, pos - count)
            register = (tv.string as NSString).substring(with: NSRange(location: start, length: pos - start))
            deleteRange(tv, range: NSRange(location: start, length: pos - start))
        }
    }

    func deleteLine(_ tv: NSTextView, count: Int) {
        let pos = cursorPos(tv)
        let start = lineStart(tv, at: pos)
        var end = lineEnd(tv, at: pos)
        for _ in 1..<count {
            if end + 1 < tv.string.utf16.count { end = lineEnd(tv, at: end + 1) }
        }
        // include trailing newline
        let includeNewline = end + 1 <= tv.string.utf16.count
        let len = includeNewline ? end - start + 2 : end - start + 1
        let range = NSRange(location: start, length: min(len, tv.string.utf16.count - start))
        register = (tv.string as NSString).substring(with: range)
        registerIsLine = true
        deleteRange(tv, range: range)
    }

    func yankLines(_ tv: NSTextView, count: Int) {
        let pos = cursorPos(tv)
        let start = lineStart(tv, at: pos)
        var end = lineEnd(tv, at: pos)
        for _ in 1..<count {
            if end + 1 < tv.string.utf16.count { end = lineEnd(tv, at: end + 1) }
        }
        let len = min(end - start + 2, tv.string.utf16.count - start)
        register = (tv.string as NSString).substring(with: NSRange(location: start, length: len))
        registerIsLine = true
    }

    func deleteToEndOfLine(_ tv: NSTextView) {
        let pos = cursorPos(tv)
        let end = lineEnd(tv, at: pos)
        register = (tv.string as NSString).substring(with: NSRange(location: pos, length: max(0, end - pos + 1)))
        deleteRange(tv, range: NSRange(location: pos, length: max(0, end - pos + 1)))
    }

    func changeToEndOfLine(_ tv: NSTextView) {
        deleteToEndOfLine(tv)
        enter(mode: .insert)
    }

    func paste(_ tv: NSTextView, before: Bool, count: Int) {
        guard !register.isEmpty else { return }
        let pos = cursorPos(tv)
        let text = String(repeating: register, count: count)
        tv.isEditable = true
        if registerIsLine {
            let insertPos = before ? lineStart(tv, at: pos) : (lineEnd(tv, at: pos) + 1)
            let clamped = min(insertPos, tv.string.utf16.count)
            let insertText = text.hasSuffix("\n") ? text : text + "\n"
            tv.replaceCharacters(in: NSRange(location: clamped, length: 0), with: insertText)
            tv.setSelectedRange(NSRange(location: clamped, length: 0))
        } else {
            let insertPos = before ? pos : min(pos + 1, tv.string.utf16.count)
            tv.replaceCharacters(in: NSRange(location: insertPos, length: 0), with: text)
            tv.setSelectedRange(NSRange(location: insertPos + text.utf16.count - 1, length: 0))
        }
        tv.isEditable = false
    }

    func replaceChar(_ tv: NSTextView, with char: String, count: Int) {
        let pos = cursorPos(tv)
        let len = tv.string.utf16.count
        let replaceLen = min(count, len - pos)
        guard replaceLen > 0 else { return }
        tv.isEditable = true
        tv.replaceCharacters(in: NSRange(location: pos, length: replaceLen), with: String(repeating: char, count: replaceLen))
        tv.isEditable = false
        tv.setSelectedRange(NSRange(location: pos + replaceLen - 1, length: 0))
        let cap = char; let c = replaceLen
        lastEdit = { [weak self] in self?.replaceChar(tv, with: cap, count: c) }
    }

    func toggleCase(_ tv: NSTextView, count: Int) {
        let pos = cursorPos(tv)
        let len = tv.string.utf16.count
        let end = min(pos + count, len)
        let range = NSRange(location: pos, length: end - pos)
        let text = (tv.string as NSString).substring(with: range)
        let toggled = String(text.map { c in c.isUppercase ? Character(c.lowercased()) : Character(c.uppercased()) })
        tv.isEditable = true
        tv.replaceCharacters(in: range, with: toggled)
        tv.isEditable = false
        tv.setSelectedRange(NSRange(location: end, length: 0))
    }

    func toggleCaseLine(_ tv: NSTextView) {
        let pos = cursorPos(tv)
        let range = NSRange(location: lineStart(tv, at: pos), length: lineEnd(tv, at: pos) - lineStart(tv, at: pos))
        toggleCaseRange(tv, range: range)
    }

    func toggleCaseRange(_ tv: NSTextView, range: NSRange) {
        let text = (tv.string as NSString).substring(with: range)
        let toggled = String(text.map { c in c.isUppercase ? Character(c.lowercased()) : Character(c.uppercased()) })
        tv.isEditable = true
        tv.replaceCharacters(in: range, with: toggled)
        tv.isEditable = false
    }

    func lowercaseLine(_ tv: NSTextView) {
        let pos = cursorPos(tv)
        let start = lineStart(tv, at: pos); let end = lineEnd(tv, at: pos)
        lowercaseRange(tv, range: NSRange(location: start, length: end - start))
    }

    func uppercaseLine(_ tv: NSTextView) {
        let pos = cursorPos(tv)
        let start = lineStart(tv, at: pos); let end = lineEnd(tv, at: pos)
        uppercaseRange(tv, range: NSRange(location: start, length: end - start))
    }

    func lowercaseRange(_ tv: NSTextView, range: NSRange) {
        let text = (tv.string as NSString).substring(with: range).lowercased()
        tv.isEditable = true; tv.replaceCharacters(in: range, with: text); tv.isEditable = false
    }

    func uppercaseRange(_ tv: NSTextView, range: NSRange) {
        let text = (tv.string as NSString).substring(with: range).uppercased()
        tv.isEditable = true; tv.replaceCharacters(in: range, with: text); tv.isEditable = false
    }

    func joinLines(_ tv: NSTextView, count: Int) {
        let pos = cursorPos(tv)
        var end = pos
        for _ in 0..<count {
            let lineE = lineEnd(tv, at: end)
            if lineE + 1 < tv.string.utf16.count { end = lineE + 1 }
        }
        let range = NSRange(location: lineStart(tv, at: pos), length: lineEnd(tv, at: end) - lineStart(tv, at: pos))
        let text = (tv.string as NSString).substring(with: range)
        let joined = text.components(separatedBy: "\n").map { $0.trimmingCharacters(in: .whitespaces) }.joined(separator: " ")
        tv.isEditable = true
        tv.replaceCharacters(in: range, with: joined)
        tv.isEditable = false
    }

    func openLineBelow(_ tv: NSTextView) {
        let pos = cursorPos(tv)
        let end = lineEnd(tv, at: pos)
        let insertPos = min(end + 1, tv.string.utf16.count)
        tv.isEditable = true
        tv.replaceCharacters(in: NSRange(location: insertPos, length: 0), with: "\n")
        tv.setSelectedRange(NSRange(location: insertPos + 1, length: 0))
    }

    func openLineAbove(_ tv: NSTextView) {
        let pos = cursorPos(tv)
        let start = lineStart(tv, at: pos)
        tv.isEditable = true
        tv.replaceCharacters(in: NSRange(location: start, length: 0), with: "\n")
        tv.setSelectedRange(NSRange(location: start, length: 0))
    }

    func indentLines(_ tv: NSTextView, count: Int, indent: Bool) {
        let pos = cursorPos(tv)
        let range = rangeLines(tv, count: count, includeCurrent: true)
        indentRange(tv, range: range, indent: indent)
        tv.setSelectedRange(NSRange(location: pos, length: 0))
    }

    func indentRange(_ tv: NSTextView, range: NSRange, indent: Bool) {
        let ns = tv.string as NSString
        let text = ns.substring(with: range)
        let indented = text.components(separatedBy: "\n").map { line in
            indent ? "    " + line : String(line.drop(while: { $0 == " " || $0 == "\t" }).prefix(999999))
        }.joined(separator: "\n")
        tv.isEditable = true
        tv.replaceCharacters(in: range, with: indented)
        tv.isEditable = false
    }
}
