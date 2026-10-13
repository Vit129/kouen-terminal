import AppKit
import HarnessCopyMode
import HarnessCore
import HarnessTerminalEngine
import HarnessTerminalRenderer
import HarnessTheme
import Metal
import QuartzCore

extension HarnessTerminalSurfaceView {
    // MARK: - Find (Cmd+F)

    public func beginFind() { findActive = true }

    /// Close the find bar: drop matches + highlights (the bar stays a host concern).
    public func endFind() {
        findPosition = nil
        findCommandScope = nil
        guard findActive else { return }
        findActive = false
        findQuery = ""
        findCancellation?.cancel()
        findDebounce?.cancel()
        findInFlight = false
        findRefreshQueued = false
        findMatches = []
        findCurrentIndex = 0
        onFindResultsChanged?(0, 0)
        scheduleRender()
    }

    /// Run/refresh the search for `query` (incremental as the user types), honoring the find bar's
    /// match mode (`options`). Empty clears matches.
    public func updateFind(query: String, options: TerminalBufferSearchOptions = .default) {
        findActive = true
        findPosition = nil
        findQuery = query
        findOptions = options
        findCurrentIndex = 0
        scheduleFind()
    }

    func invalidateFindContent() {
        findContentRevision &+= 1
        if findActive, findQuery.isEmpty, !findMatches.isEmpty { findMatches = []; onFindResultsChanged?(0, 0) }
        if findActive, !findQuery.isEmpty { scheduleFindRefresh() }
    }

    /// Output changed under an active query. The current matches stay on screen and the search
    /// re-runs at most every `findRefreshInterval`, so streaming output never blanks the results.
    private func scheduleFindRefresh() {
        guard !findRefreshScheduled else { return }
        if findInFlight || findDebounce.map({ !$0.isCancelled }) == true { findRefreshQueued = true; return }
        findRefreshScheduled = true
        let wait = max(0, findLastStart + Self.findRefreshInterval - ProcessInfo.processInfo.systemUptime)
        DispatchQueue.main.asyncAfter(deadline: .now() + wait) { [weak self] in
            guard let self else { return }
            self.findRefreshScheduled = false
            guard self.findActive, !self.findQuery.isEmpty else { return }
            if self.findInFlight { self.findRefreshQueued = true; return }
            self.runFind(refreshing: true)
        }
    }

    /// A new query, scope, or option: clear the old matches and search after a short debounce.
    func scheduleFind() {
        findCancellation?.cancel()
        findDebounce?.cancel()
        findInFlight = false
        findRefreshQueued = false
        findMatches = []
        onFindResultsChanged?(0, 0)
        guard !findQuery.isEmpty else { onFindStatusChanged?(nil); scheduleRender(); return }
        onFindStatusChanged?("Searching…")
        let work = DispatchWorkItem { [weak self] in self?.runFind(refreshing: false) }
        findDebounce = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12, execute: work)
        scheduleRender()
    }

    /// Search the current text. A refresh keeps the current match without scrolling, because
    /// the user may be reading it while output arrives.
    private func runFind(refreshing: Bool) {
        findDebounce = nil
        let cancellation = TerminalSearchCancellation()
        findCancellation = cancellation
        findInFlight = true
        findLastStart = ProcessInfo.processInfo.systemUptime
        let query = findQuery, options = findOptions, revision = findContentRevision
        let commandScope = findCommandScope
        if refreshing { onFindStatusChanged?("Updating…") }
        let search: @Sendable (TerminalTextSnapshot, TerminalTextRange?) -> Void = { [weak self] snapshot, scope in
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard !cancellation.isCancelled else { return }
                let result = TerminalBufferSearch.search(query: query, options: options,
                    lineCount: commandScope != nil && scope == nil ? 0 : snapshot.lineCount,
                    clusters: snapshot.clusters, within: scope,
                    isWrapped: snapshot.isWrapped, cancelled: { cancellation.isCancelled }, line: snapshot.line)
                DispatchQueue.main.async { [weak self] in
                    guard let self, !cancellation.isCancelled, self.findActive else { return }
                    self.findInFlight = false
                    var stale = revision != self.findContentRevision || self.findRefreshQueued
                    self.findRefreshQueued = false
                    switch result {
                    case let .matches(matches, limited):
                        let previousLine = refreshing && self.findMatches.indices.contains(self.findCurrentIndex)
                            ? self.findMatches[self.findCurrentIndex].bufferLine : nil
                        self.findMatches = matches
                        let position = self.findPosition?.position
                        self.findCurrentIndex = self.findTargetLine.flatMap { target in
                            matches.firstIndex { $0.bufferLine == target }
                        } ?? position.flatMap { position in
                            matches.firstIndex { match in
                                match.spans.contains { $0.bufferLine == position.line && $0.columns.contains(position.column) }
                            }
                        } ?? previousLine.flatMap { line in matches.firstIndex { $0.bufferLine >= line } } ?? 0
                        self.findTargetLine = nil
                        if !matches.isEmpty, !refreshing { self.scrollToCurrentMatch() }
                        self.onFindResultsChanged?(matches.isEmpty ? 0 : self.findCurrentIndex + 1, matches.count)
                        if !stale { self.onFindStatusChanged?(limited ? "Results limited" : nil) }
                    case let .invalidPattern(message): self.onFindStatusChanged?("Invalid pattern: " + message)
                    case .cancelled: return
                    case .expired: stale = true
                    }
                    if stale { self.scheduleFindRefresh() }
                    self.scheduleRender()
                }
            }
        }
        emulatorState.async { emulator in search(emulator.textSnapshot(), commandScope?.outputRange) }
    }

    public func revealSearchResult(query: String, caseSensitive: Bool, line: Int, fingerprint: UInt64) -> Bool {
        guard let target = recordedSearchText(line: line, fingerprint: fingerprint) else { return false }
        findCommandScope = nil
        findTargetLine = target.line
        updateFind(query: query, options: TerminalBufferSearchOptions(caseSensitive: caseSensitive))
        return true
    }
    /// Host and client can retain different physical row offsets after reflow. Accept
    /// an exact row first, otherwise only a unique identical logical line nearby.
    /// Bound the mapping work; ambiguous, evicted or expensive results need a refresh.
    private func recordedSearchText(line: Int, fingerprint: UInt64) -> (line: Int, text: TerminalMappedText)? {
        emulatorSync { emulator in
            let snapshot = emulator.textSnapshot()
            guard line >= 0 else { return nil }
            if line < snapshot.lineCount {
                let text = snapshot.logicalText(startingAt: line).text
                if OutputSearch.fingerprint(text.text) == fingerprint { return (line, text) }
            }
            let deadline = ProcessInfo.processInfo.systemUptime + 0.01
            let lower = max(0, line - 64), upper = min(snapshot.lineCount, line + 65)
            guard lower < upper else { return nil }
            var result: (line: Int, text: TerminalMappedText)?
            var units = 0
            for index in lower..<upper where index == 0 || !snapshot.isWrapped(index - 1) {
                guard ProcessInfo.processInfo.systemUptime < deadline else { return nil }
                let text = snapshot.logicalText(startingAt: index).text
                units += text.utf16Count
                guard units <= 262_144 else { return nil }
                if OutputSearch.fingerprint(text.text) == fingerprint {
                    guard result == nil else { return nil }
                    result = (index, text)
                }
            }
            return result
        }
    }
    /// Apply the isolated worker's recorded span, never execute a regex on a
    /// parser/render/UI queue. Older responses safely jump without a highlight.
    public func revealRegexSearchResult(line: Int, fingerprint: UInt64, span: OutputSearchSpan?) -> Bool {
        guard let target = recordedSearchText(line: line, fingerprint: fingerprint) else { return false }
        let mapped = target.text
        endFind(); findActive = true; findQuery = ""; findMatches = []; findCurrentIndex = 0
        if let span, span.location >= 0, span.length > 0, span.location <= mapped.utf16Count,
           span.length <= mapped.utf16Count - span.location {
            let cells = mapped.cells(for: NSRange(location: span.location, length: span.length))
            if !cells.isEmpty { findMatches = [TerminalBufferMatch(spans: cells)] }
        }
        scrollToBufferLine(max(0, target.line - max(0, rows / 3))); scheduleRender(); return true
    }

    public func findNext() { advanceFind(by: 1) }
    public func findPrevious() { advanceFind(by: -1) }

    private func advanceFind(by delta: Int) {
        guard !findMatches.isEmpty else { return }
        let n = findMatches.count
        findCurrentIndex = ((findCurrentIndex + delta) % n + n) % n
        scrollToCurrentMatch()
        onFindResultsChanged?(findCurrentIndex + 1, n)
        scheduleRender()
    }

    /// Scroll so the current match sits a little below the top of the viewport (context above it).
    private func scrollToCurrentMatch() {
        guard findMatches.indices.contains(findCurrentIndex) else { return }
        let match = findMatches[findCurrentIndex]
        findPosition = trackTextPosition(line: match.bufferLine, column: match.columns.lowerBound)
        let line = findMatches[findCurrentIndex].bufferLine
        scrollToBufferLine(max(0, line - max(0, rows / 3)))
    }

    /// Viewport-relative highlight spans for the matches currently on screen. `nonisolated` +
    /// pure so the off-main render path can call it on its worker queue.
    nonisolated static func viewportFindHighlights(
        _ matches: [TerminalBufferMatch], scrollOffset: Int, historyCount: Int, rows: Int
    ) -> [TerminalSelection] {
        guard !matches.isEmpty, rows > 0 else { return [] }
        let topVisible = historyCount - scrollOffset // buffer index of the top viewport row
        var hits: [TerminalSelection] = []
        var lo = 0, hi = matches.count
        while lo < hi {
            let mid = (lo + hi) / 2
            if (matches[mid].spans.last?.bufferLine ?? 0) < topVisible { lo = mid + 1 } else { hi = mid }
        }
        for match in matches[lo...] {
            if match.bufferLine >= topVisible + rows { break }
            for m in match.spans where !m.columns.isEmpty {
                let row = m.bufferLine - topVisible
                if row >= 0, row < rows {
                    hits.append(TerminalSelection((row, m.columns.lowerBound), (row, m.columns.upperBound - 1)))
                }
            }
        }
        return hits
    }

    /// View rect of the current find match, or nil when it is off the viewport.
    /// The find bar uses this to move aside. It does not change `rows`.
    public func currentFindMatchRect() -> CGRect? {
        guard findMatches.indices.contains(findCurrentIndex) else { return nil }
        let match = findMatches[findCurrentIndex]
        let history = emulatorSync { $0.historyCount }
        let hits = Self.viewportFindHighlights([match], scrollOffset: scrollOffset, historyCount: history, rows: rows)
        guard let hit = hits.first, hit.endColumn >= hit.startColumn else { return nil }
        return cellRect(row: hit.startRow, columns: hit.startColumn ..< (hit.endColumn + 1))
    }
}
