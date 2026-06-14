import AppKit
import HarnessLSP

extension ViEngine {
    // MARK: - Named register helpers

    func yankToRegister(_ text: String, isLine: Bool) {
        if let reg = activeRegister {
            namedRegisters[reg] = (text, isLine)
            activeRegister = nil
        } else {
            register = text
            registerIsLine = isLine
        }
    }

    func pasteRegister() -> (text: String, isLine: Bool) {
        if let reg = activeRegister, let entry = namedRegisters[reg] {
            activeRegister = nil
            return entry
        }
        return (register, registerIsLine)
    }

    // MARK: - Normal mode key dispatch

    func handleNormal(key: String, chars: String, ctrl: Bool, shift: Bool, cmd: Bool, event: NSEvent, tv: NSTextView) -> Bool {
        // Pending text object second char (after i/a)
        if pendingTextObject, let op = pendingOp {
            pendingTextObject = false
            let inner = pendingInner
            pendingOp = nil
            applyOperatorTextObject(op: op, char: key, inner: inner, tv: tv)
            return true
        }

        // Count digit accumulation
        if let d = key.first, d.isNumber, d != "0" || !countBuf.isEmpty {
            if !ctrl {
                countBuf += String(d)
                return true
            }
        }
        let count = max(1, Int(countBuf) ?? 1)
        countBuf = ""

        if let forward = pendingDiagnosticJump {
            pendingDiagnosticJump = nil
            if key == "d" {
                jumpDiagnostic(tv, forward: forward)
                return true
            }
            return false
        }

        // Ctrl combinations
        if ctrl {
            switch key {
            case "d": scroll(tv, lines: tv.visibleRect.height / lineHeight(tv) / 2, down: true);  return true
            case "u": scroll(tv, lines: tv.visibleRect.height / lineHeight(tv) / 2, down: false); return true
            case "f": scroll(tv, lines: tv.visibleRect.height / lineHeight(tv), down: true);  return true
            case "b": scroll(tv, lines: tv.visibleRect.height / lineHeight(tv), down: false); return true
            case "r": tv.undoManager?.redo(); return true
            case "o": jumpListBack(tv);    return true   // Ctrl+o — jump back
            case "i": jumpListForward(tv); return true   // Ctrl+i — jump forward
            default: break
            }
        }

        switch key {
        // MARK: Motions
        case "h": move(tv, by: -count); return true
        case "l": move(tv, by:  count); return true
        case "j": moveLines(tv, by:  count); return true
        case "k": moveLines(tv, by: -count); return true
        case "w": moveWords(tv, count: count, forward: true,  bigWord: false, toEnd: false); return true
        case "W": moveWords(tv, count: count, forward: true,  bigWord: true,  toEnd: false); return true
        case "b": moveWords(tv, count: count, forward: false, bigWord: false, toEnd: false); return true
        case "B": moveWords(tv, count: count, forward: false, bigWord: true,  toEnd: false); return true
        case "e": moveWords(tv, count: count, forward: true,  bigWord: false, toEnd: true);  return true
        case "E": moveWords(tv, count: count, forward: true,  bigWord: true,  toEnd: true);  return true
        case "0": moveLine(tv, to: .start); return true
        case "^": moveLine(tv, to: .firstNonBlank); return true
        case "$": moveLine(tv, to: .end); return true
        case "g":
            pendingG = true
            return true
        case "G":
            if countBuf.isEmpty { moveToLine(tv, line: lineCount(tv)) }
            else { moveToLine(tv, line: count) }
            return true
        case "{": moveParagraph(tv, forward: false, count: count); return true
        case "}": moveParagraph(tv, forward: true,  count: count); return true
        case "%": jumpMatchingBracket(tv); return true
        case "f": pendingFind = (true, false);  return true  // f{char}
        case "F": pendingFind = (false, false); return true  // F{char}
        case "t": pendingFind = (true, true);   return true  // t{char}
        case "T": pendingFind = (false, true);  return true  // T{char}
        case ";": repeatLastFind(tv, reverse: false, count: count); return true
        case ",": repeatLastFind(tv, reverse: true,  count: count); return true

        // MARK: Operators
        case "d": enter(mode: .operatorPending(op: "d")); return true
        case "c": enter(mode: .operatorPending(op: "c")); return true
        case "y": enter(mode: .operatorPending(op: "y")); return true
        case "D": deleteToEndOfLine(tv); lastEdit = { [weak self] in self?.deleteToEndOfLine(tv) }; return true
        case "C": changeToEndOfLine(tv); return true
        case "Y": yankLines(tv, count: 1); return true

        // MARK: Simple edits
        case "x": deleteChar(tv, forward: true,  count: count); lastEdit = { [weak self] in self?.deleteChar(tv, forward: true, count: count) }; return true
        case "X": deleteChar(tv, forward: false, count: count); lastEdit = { [weak self] in self?.deleteChar(tv, forward: false, count: count) }; return true
        case "r":
            pendingReplace = true
            return true
        case "R": enter(mode: .replace); return true
        case "s": deleteChar(tv, forward: true, count: count); enter(mode: .insert); return true  // s = cl
        case "S": deleteLine(tv, count: 1); enter(mode: .insert); return true  // S = cc
        case "~": toggleCase(tv, count: count); return true
        case "J": joinLines(tv, count: count); return true
        case ".": lastEdit?(); return true

        // MARK: Insert-entry
        case "i": enter(mode: .insert); return true
        case "I": moveLine(tv, to: .firstNonBlank); enter(mode: .insert); return true
        case "a": move(tv, by: 1); enter(mode: .insert); return true
        case "A": moveLine(tv, to: .end); enter(mode: .insert); return true
        case "o": openLineBelow(tv); enter(mode: .insert); return true
        case "O": openLineAbove(tv); enter(mode: .insert); return true

        // MARK: Paste / undo
        case "p": paste(tv, before: false, count: count); return true
        case "P": paste(tv, before: true,  count: count); return true
        case "u": tv.undoManager?.undo(); return true

        // MARK: Visual
        case "v":
            visualAnchor = cursorPos(tv)
            enter(mode: .visual(line: false))
            updateVisualSelection(tv)
            return true
        case "V":
            visualAnchor = lineStart(tv, at: cursorPos(tv))
            enter(mode: .visual(line: true))
            updateVisualSelection(tv)
            return true

        // MARK: Search
        case "/": beginSearch(tv, forward: true);  return true
        case "?": beginSearch(tv, forward: false); return true
        case "n": repeatSearch(tv, reverse: false, count: count); return true
        case "N": repeatSearch(tv, reverse: true,  count: count); return true
        case "*": searchWordUnderCursor(tv, forward: true);  return true
        case "#": searchWordUnderCursor(tv, forward: false); return true
        case "K": showHover(tv); return true
        case "]": pendingDiagnosticJump = true; return true
        case "[": pendingDiagnosticJump = false; return true

        // MARK: Ex command
        case ":": presentExPrompt(tv); return true

        // MARK: Indent
        case ">": enter(mode: .operatorPending(op: ">")); return true
        case "<": enter(mode: .operatorPending(op: "<")); return true

        // MARK: H/M/L — screen positions
        case "H": moveScreenPosition(tv, pos: .top);    return true
        case "M": moveScreenPosition(tv, pos: .middle); return true
        case "L": moveScreenPosition(tv, pos: .bottom); return true

        // MARK: ZZ / ZQ — save+quit / quit shortcuts
        case "Z":
            pendingZ = true
            return true

        // MARK: Marks
        case "m":
            pendingMark = true
            return true
        case "'":
            pendingMarkJump = true
            return true
        case "`":
            pendingMarkJump = true   // backtick — same exact-pos behaviour
            return true

        // MARK: Named register prefix "
        case "\"":
            pendingRegister = true
            return true

        // MARK: Macros
        case "q":
            if recordingMacro != nil {
                // q while recording = stop
                if let reg = recordingMacro { macros[reg] = macroBuffer }
                recordingMacro = nil; macroBuffer = ""; return true
            }
            pendingMacroRecord = true
            return true
        case "@":
            pendingMacroPlay = true
            return true

        default: break
        }

        // g + second key
        if pendingG {
            pendingG = false
            switch key {
            case "g": moveToLine(tv, line: count == 1 ? 1 : count); return true
            case "f": openPathUnderCursor(tv); return true
            case "d": goToDefinition(tv); return true
            case "e": moveWords(tv, count: count, forward: false, bigWord: false, toEnd: true); return true
            case "E": moveWords(tv, count: count, forward: false, bigWord: true, toEnd: true); return true
            case "~": toggleCaseLine(tv); return true
            case "u": lowercaseLine(tv); return true
            case "U": uppercaseLine(tv); return true
            case "v":
                // gv — reselect last visual selection
                visualAnchor = lastVisualRange.location
                tv.setSelectedRange(lastVisualRange)
                enter(mode: .visual(line: lastVisualIsLine))
                return true
            default: return false
            }
        }

        // f/F/t/T — wait for char
        if let (fwd, till) = pendingFind {
            pendingFind = nil
            findChar(tv, char: key, forward: fwd, till: till, count: count)
            return true
        }

        // r — wait for replacement char
        if pendingReplace {
            pendingReplace = false
            replaceChar(tv, with: key, count: count)
            return true
        }

        // ZZ / ZQ
        if pendingZ {
            pendingZ = false
            switch key {
            case "Z": onSave?(); onQuit?()
            case "Q": onQuit?()
            default: break
            }
            return true
        }

        // " — named register: next char selects register for operator
        if pendingRegister {
            pendingRegister = false
            if let c = key.first, (c.isLetter && c.isLowercase) || (c >= "0" && c <= "9") {
                activeRegister = c
            }
            return true
        }

        // m{char} — set mark
        if pendingMark {
            pendingMark = false
            if let c = key.first, c.isLetter {
                marks[c] = cursorPos(tv)
            }
            return true
        }

        // '{char} or `{char} — jump to mark
        if pendingMarkJump {
            pendingMarkJump = false
            if key == "'" || key == "`" {
                // '' / `` — jump back
                let dest = lastJumpPos
                pushJump(cursorPos(tv))
                lastJumpPos = cursorPos(tv)
                tv.setSelectedRange(NSRange(location: dest, length: 0))
            } else if let c = key.first, let pos = marks[c] {
                pushJump(cursorPos(tv))
                lastJumpPos = cursorPos(tv)
                tv.setSelectedRange(NSRange(location: pos, length: 0))
                tv.scrollRangeToVisible(NSRange(location: pos, length: 0))
            }
            return true
        }

        // q{char} — start recording macro
        if pendingMacroRecord {
            pendingMacroRecord = false
            if let c = key.first, c.isLetter {
                recordingMacro = c
                macroBuffer = ""
            }
            return true
        }

        // @{char} — play macro
        if pendingMacroPlay {
            pendingMacroPlay = false
            if key == "@" {
                // @@ — repeat last played macro
                if let last = lastPlayedMacro { playMacro(last, tv: tv, count: count) }
            } else if let c = key.first {
                playMacro(c, tv: tv, count: count)
            }
            return true
        }

        return false
    }
}
