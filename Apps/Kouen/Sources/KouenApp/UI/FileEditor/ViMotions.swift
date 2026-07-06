import AppKit
import KouenLSP

extension ViEngine {
    func isWordChar(_ c: unichar, bigWord: Bool) -> Bool {
        if bigWord { return c != 32 && c != 9 && c != 10 }
        guard let scalar = UnicodeScalar(c) else { return false }
        let ch = Character(scalar)
        return ch.isLetter || ch.isNumber || c == 95  // _ = 95
    }

    func moveWords(_ tv: NSTextView, count: Int, forward: Bool, bigWord: Bool, toEnd: Bool) {
        var pos = cursorPos(tv)
        let ns = tv.string as NSString
        let len = ns.length
        for _ in 0..<count {
            if forward {
                if toEnd {
                    // e/E: move to end of current/next word
                    if pos < len - 1 { pos += 1 }
                    while pos < len - 1 && !isWordChar(ns.character(at: pos), bigWord: bigWord) { pos += 1 }
                    while pos < len - 1 && isWordChar(ns.character(at: pos + 1), bigWord: bigWord) { pos += 1 }
                } else {
                    // w/W: move to start of next word
                    while pos < len && isWordChar(ns.character(at: pos), bigWord: bigWord) { pos += 1 }
                    while pos < len && !isWordChar(ns.character(at: pos), bigWord: bigWord) { pos += 1 }
                }
            } else {
                // b/B / ge/gE
                if pos > 0 { pos -= 1 }
                if toEnd {
                    // ge/gE: move to end of previous word
                    while pos > 0 && !isWordChar(ns.character(at: pos), bigWord: bigWord) { pos -= 1 }
                    while pos > 0 && isWordChar(ns.character(at: pos - 1), bigWord: bigWord) { pos -= 1 }
                } else {
                    while pos > 0 && !isWordChar(ns.character(at: pos), bigWord: bigWord) { pos -= 1 }
                    while pos > 0 && isWordChar(ns.character(at: pos - 1), bigWord: bigWord) { pos -= 1 }
                }
            }
        }
        tv.setSelectedRange(NSRange(location: max(0, min(pos, len)), length: 0))
    }

    func moveParagraph(_ tv: NSTextView, forward: Bool, count: Int) {
        var pos = cursorPos(tv)
        let ns = tv.string as NSString
        let len = ns.length
        for _ in 0..<count {
            if forward {
                // skip non-empty lines
                while pos < len && ns.character(at: pos) != 10 { pos += 1 }
                // skip empty lines
                while pos < len && ns.character(at: pos) == 10 { pos += 1 }
            } else {
                if pos > 0 { pos -= 1 }
                while pos > 0 && ns.character(at: pos) == 10 { pos -= 1 }
                while pos > 0 && ns.character(at: pos - 1) != 10 { pos -= 1 }
            }
        }
        tv.setSelectedRange(NSRange(location: max(0, min(pos, len)), length: 0))
    }

    func jumpMatchingBracket(_ tv: NSTextView) {
        let pos = cursorPos(tv)
        let ns = tv.string as NSString
        let len = ns.length
        guard pos < len else { return }
        let open: [unichar] = [40, 91, 123]   // ( [ {
        let close: [unichar] = [41, 93, 125]   // ) ] }
        let ch = ns.character(at: pos)
        if let idx = open.firstIndex(of: ch) {
            // search forward for matching close
            var depth = 1; var p = pos + 1
            while p < len && depth > 0 {
                let c = ns.character(at: p)
                if c == open[idx] { depth += 1 }
                else if c == close[idx] { depth -= 1 }
                p += 1
            }
            if depth == 0 { tv.setSelectedRange(NSRange(location: p - 1, length: 0)) }
        } else if let idx = close.firstIndex(of: ch) {
            // search backward
            var depth = 1; var p = pos - 1
            while p >= 0 && depth > 0 {
                let c = ns.character(at: p)
                if c == close[idx] { depth += 1 }
                else if c == open[idx] { depth -= 1 }
                p -= 1
            }
            if depth == 0 { tv.setSelectedRange(NSRange(location: p + 1, length: 0)) }
        }
    }

    func findChar(_ tv: NSTextView, char: String, forward: Bool, till: Bool, count: Int) {
        guard !char.isEmpty else { return }
        lastFindChar = (char, forward, till)
        let ns = tv.string as NSString
        let len = ns.length
        var pos = cursorPos(tv)
        let target = (char as NSString).character(at: 0)
        for _ in 0..<count {
            if forward {
                var p = pos + 1
                while p < len && ns.character(at: p) != target { p += 1 }
                if p < len { pos = till ? p - 1 : p }
            } else {
                var p = pos - 1
                while p >= 0 && ns.character(at: p) != target { p -= 1 }
                if p >= 0 { pos = till ? p + 1 : p }
            }
        }
        tv.setSelectedRange(NSRange(location: pos, length: 0))
    }

    func repeatLastFind(_ tv: NSTextView, reverse: Bool, count: Int) {
        let (char, fwd, till) = lastFindChar
        guard !char.isEmpty else { return }
        findChar(tv, char: char, forward: reverse ? !fwd : fwd, till: till, count: count)
    }

    enum ScreenPos { case top, middle, bottom }

    func moveScreenPosition(_ tv: NSTextView, pos: ScreenPos) {
        guard let lm = tv.layoutManager, let tc = tv.textContainer else { return }
        let visRect = tv.visibleRect
        let targetY: CGFloat
        switch pos {
        case .top:    targetY = visRect.minY + 1
        case .middle: targetY = visRect.midY
        case .bottom: targetY = visRect.maxY - 1
        }
        let glyphIdx = lm.glyphIndex(for: NSPoint(x: visRect.minX + 1, y: targetY), in: tc)
        let charIdx = lm.characterIndexForGlyph(at: glyphIdx)
        let ns = tv.string as NSString
        let lineStart = lineStart(tv, at: charIdx)
        var lineEnd = lineStart
        while lineEnd < ns.length && ns.character(at: lineEnd) != 10 { lineEnd += 1 }
        var firstNonBlank = lineStart
        while firstNonBlank < lineEnd && (ns.character(at: firstNonBlank) == 32 || ns.character(at: firstNonBlank) == 9) { firstNonBlank += 1 }
        tv.setSelectedRange(NSRange(location: firstNonBlank, length: 0))
    }

    // MARK: - Range helpers for operators

    func wordRange(_ tv: NSTextView, count: Int, bigWord: Bool) -> NSRange {
        let start = cursorPos(tv)
        moveWords(tv, count: count, forward: true, bigWord: bigWord, toEnd: false)
        let end = cursorPos(tv)
        tv.setSelectedRange(NSRange(location: start, length: 0))
        return NSRange(location: start, length: max(0, end - start))
    }

    func wordRangeBack(_ tv: NSTextView, count: Int, bigWord: Bool) -> NSRange {
        let end = cursorPos(tv)
        moveWords(tv, count: count, forward: false, bigWord: bigWord, toEnd: false)
        let start = cursorPos(tv)
        tv.setSelectedRange(NSRange(location: start, length: 0))
        return NSRange(location: start, length: max(0, end - start))
    }

    func wordEndRange(_ tv: NSTextView, count: Int, bigWord: Bool) -> NSRange {
        let start = cursorPos(tv)
        moveWords(tv, count: count, forward: true, bigWord: bigWord, toEnd: true)
        let end = cursorPos(tv) + 1
        tv.setSelectedRange(NSRange(location: start, length: 0))
        return NSRange(location: start, length: max(0, end - start))
    }

    func rangeToLineStart(_ tv: NSTextView, firstNonBlank: Bool) -> NSRange {
        let pos = cursorPos(tv)
        let start = lineStart(tv, at: pos)
        if firstNonBlank {
            let ns = tv.string as NSString
            let end = lineEnd(tv, at: pos)
            var p = start
            while p <= end && (ns.character(at: p) == 32 || ns.character(at: p) == 9) { p += 1 }
            return NSRange(location: min(p, end), length: max(0, pos - min(p, end)))
        }
        return NSRange(location: start, length: max(0, pos - start))
    }

    func rangeToLineEnd(_ tv: NSTextView) -> NSRange {
        let pos = cursorPos(tv)
        let end = lineEnd(tv, at: pos)
        return NSRange(location: pos, length: max(0, end - pos + 1))
    }

    func rangeLines(_ tv: NSTextView, count: Int, includeCurrent: Bool) -> NSRange {
        let pos = cursorPos(tv)
        let curLine = lineStart(tv, at: pos)
        if count > 0 {
            var end = lineEnd(tv, at: pos)
            var remaining = count - 1
            while remaining > 0 && end < tv.string.utf16.count - 1 {
                end = lineEnd(tv, at: end + 1)
                remaining -= 1
            }
            return NSRange(location: curLine, length: end - curLine + 1)
        } else {
            var start = curLine
            var remaining = -count - 1
            while remaining > 0 && start > 0 {
                start = lineStart(tv, at: start - 1)
                remaining -= 1
            }
            let endLine = lineEnd(tv, at: pos)
            return NSRange(location: start, length: endLine - start + 1)
        }
    }

    func rangeOverParagraph(_ tv: NSTextView, forward: Bool, count: Int) -> NSRange {
        let start = cursorPos(tv)
        moveParagraph(tv, forward: forward, count: count)
        let end = cursorPos(tv)
        tv.setSelectedRange(NSRange(location: start, length: 0))
        let lo = min(start, end), hi = max(start, end)
        return NSRange(location: lo, length: hi - lo)
    }

    // MARK: - Text objects

    func textObjectRange(_ tv: NSTextView, char: String, inner: Bool) -> NSRange? {
        let pos = cursorPos(tv)
        let ns = tv.string as NSString
        let len = ns.length
        switch char {
        case "w", "W":
            let bigWord = char == "W"
            // find start of word
            var start = pos
            while start > 0 && isWordChar(ns.character(at: start - 1), bigWord: bigWord) { start -= 1 }
            var end = pos
            while end < len && isWordChar(ns.character(at: end), bigWord: bigWord) { end += 1 }
            if !inner {
                // aw: include trailing whitespace
                while end < len && (ns.character(at: end) == 32 || ns.character(at: end) == 9) { end += 1 }
            }
            return NSRange(location: start, length: max(0, end - start))
        case "\"", "'", "`":
            return quoteRange(ns, pos: pos, quote: (char as NSString).character(at: 0), inner: inner)
        case "(", ")", "b":
            return bracketRange(ns, pos: pos, open: 40, close: 41, inner: inner)   // ( )
        case "[", "]":
            return bracketRange(ns, pos: pos, open: 91, close: 93, inner: inner)   // [ ]
        case "{", "}", "B":
            return bracketRange(ns, pos: pos, open: 123, close: 125, inner: inner) // { }
        case "<", ">":
            return bracketRange(ns, pos: pos, open: 60, close: 62, inner: inner)   // < >
        case "p":
            // paragraph
            var start = pos
            while start > 0 && ns.character(at: start - 1) != 10 { start -= 1 }
            // skip backward past empty lines for 'ap'
            if !inner {
                while start > 1 && ns.character(at: start - 1) == 10 && ns.character(at: start - 2) == 10 { start -= 1 }
            }
            var end = pos
            while end < len && ns.character(at: end) != 10 { end += 1 }
            if !inner { while end < len && ns.character(at: end) == 10 { end += 1 } }
            return NSRange(location: start, length: max(0, end - start))
        case "s":
            // sentence: up to . ? ! followed by space/newline
            var start = pos
            while start > 0 {
                let c = ns.character(at: start - 1)
                if c == 46 || c == 63 || c == 33 { break }  // . ? !
                start -= 1
            }
            var end = pos
            while end < len {
                let c = ns.character(at: end)
                if (c == 46 || c == 63 || c == 33) && end + 1 < len { end += 1; break }
                end += 1
            }
            if !inner { while end < len && (ns.character(at: end) == 32 || ns.character(at: end) == 10) { end += 1 } }
            return NSRange(location: start, length: max(0, end - start))
        default: return nil
        }
    }

    func quoteRange(_ ns: NSString, pos: Int, quote: unichar, inner: Bool) -> NSRange? {
        let len = ns.length
        var lo = pos - 1
        while lo >= 0 && ns.character(at: lo) != quote { lo -= 1 }
        guard lo >= 0 else { return nil }
        var hi = pos
        while hi < len && ns.character(at: hi) != quote { hi += 1 }
        guard hi < len else { return nil }
        if inner { return NSRange(location: lo + 1, length: max(0, hi - lo - 1)) }
        return NSRange(location: lo, length: max(0, hi - lo + 1))
    }

    func bracketRange(_ ns: NSString, pos: Int, open: unichar, close: unichar, inner: Bool) -> NSRange? {
        let len = ns.length
        // find enclosing open bracket scanning left
        var depth = 0, lo = pos
        while lo >= 0 {
            let c = ns.character(at: lo)
            if c == close { depth += 1 }
            else if c == open {
                if depth == 0 { break }
                depth -= 1
            }
            lo -= 1
        }
        guard lo >= 0 else { return nil }
        depth = 0
        var hi = lo + 1
        while hi < len {
            let c = ns.character(at: hi)
            if c == open { depth += 1 }
            else if c == close {
                if depth == 0 { break }
                depth -= 1
            }
            hi += 1
        }
        guard hi < len else { return nil }
        if inner { return NSRange(location: lo + 1, length: max(0, hi - lo - 1)) }
        return NSRange(location: lo, length: max(0, hi - lo + 1))
    }
}
