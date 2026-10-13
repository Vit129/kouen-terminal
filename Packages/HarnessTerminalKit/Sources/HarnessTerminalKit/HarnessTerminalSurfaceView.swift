import AppKit
import HarnessCopyMode
import HarnessCore
import HarnessTerminalEngine
import HarnessTerminalRenderer
import HarnessTheme
import Metal
import QuartzCore

// AppKit re-exports QuickDraw's legacy C `struct RGBColor`, which shadows
// `HarnessTheme.RGBColor` in this file. Pin the name to ours.
private typealias RGBColor = HarnessTheme.RGBColor

/// QuartzCore supports drawable acquisition on a rendering thread. This one-shot handoff
/// writes on drawableQueue, then is read only by its queued main-thread completion.
private final class SurfaceDrawableRequest: @unchecked Sendable {
    let layer: CAMetalLayer
    var drawable: CAMetalDrawable?
    var waitNanos: UInt64 = 0
    private let lock = NSLock()
    private var cancelled = false

    init(layer: CAMetalLayer) { self.layer = layer }
    func cancel() { lock.lock(); cancelled = true; lock.unlock() }
    private var isCancelled: Bool { lock.lock(); defer { lock.unlock() }; return cancelled }

    func acquire() {
        guard !isCancelled else { return }
        let start = DispatchTime.now().uptimeNanoseconds
        let acquired = autoreleasepool { layer.nextDrawable() }
        waitNanos = DispatchTime.now().uptimeNanoseconds &- start
        if !isCancelled { drawable = acquired }
    }
}

/// All mutable atlas, instance-cache and upload state belongs to this serial queue.
/// Layout joins it only for the transaction-synchronized resize path.
final class SurfaceRenderExecutor: @unchecked Sendable {
    let queue: DispatchQueue
    private let renderer: TerminalMetalRenderer

    init(renderer: TerminalMetalRenderer, queue: DispatchQueue) {
        self.renderer = renderer
        self.queue = queue
    }

    func sync<T>(_ body: (TerminalMetalRenderer) -> T) -> T {
        queue.sync { autoreleasepool { body(renderer) } }
    }

    func async(_ body: @escaping @Sendable (TerminalMetalRenderer) -> Void) {
        // Metal command buffers/encoders are autoreleased; the render queue's inherited
        // pool may otherwise retain completed frame resources across many work items.
        queue.async { [self] in autoreleasepool { body(renderer) } }
    }

    @MainActor func withTransactionOwnership<T>(_ body: (TerminalMetalRenderer) -> T) -> T {
        // Main is the sole submitter. Draining its earlier jobs transfers ownership for this
        // call; no later job can be submitted before the current AppKit transaction returns.
        queue.sync {}
        return autoreleasepool { body(renderer) }
    }
}

private struct SurfacePresentConfiguration: Sendable {
    var originX: Int
    var originY: Int
    var gamma: Float
    var ligatures: Bool
    var fractionPx: Float
    var clipRows: Int?
    var synchronizedWithTransaction: Bool
}

private enum SurfacePresentAttempt: Sendable { case presented, nilDrawable, encodeFailure }

private struct SurfaceFrameBuildConfiguration: Sendable {
    // Keep search distinct from selection and legible on both light/dark themes.
    static let searchBackground = RGBColor(red: 245, green: 191, blue: 66)
    static let searchForeground = RGBColor(red: 24, green: 24, blue: 24)
    var resolver: CellColorResolver
    var cursorColor: RGBColor
    var cursorTextColor: RGBColor?
    var canvasOpacity: Float
    var colorRendering: TerminalColorRenderingMode
    var colorGamut: TerminalColorGamut
    var cursorStyle: CursorStyle
    var selectionBackground: RGBColor?
    var selectionForeground: RGBColor?
    var promptGutterEnabled: Bool

    /// `reverseVideo` is per-build state (DECSET 5 can flip any time), not configuration —
    /// it rides the resolver copy so a build stays a pure function of (config, modes).
    func makeBuilder(reverseVideo: Bool = false) -> FrameBuilder {
        var resolver = self.resolver
        resolver.reverseVideo = reverseVideo
        return FrameBuilder(
            resolver: resolver,
            cursorColor: cursorColor,
            cursorTextColor: cursorTextColor,
            canvasOpacity: canvasOpacity,
            colorRendering: colorRendering,
            colorGamut: colorGamut,
            cursorStyle: cursorStyle,
            selectionBackground: selectionBackground,
            selectionForeground: selectionForeground,
            searchBackground: Self.searchBackground,
            searchForeground: Self.searchForeground,
            promptGutterEnabled: promptGutterEnabled
        )
    }
}

struct SurfaceFrameBuildResult: Sendable {
    var generation: UInt64
    var frame: TerminalFrame
    var damage: TerminalDamage?
    /// Non-zero for a pure scrollback scroll. The renderer rotates its row cache by this
    /// amount and encodes only the newly exposed rows listed in `damage`.
    var scrollShift: Int = 0
    /// True when the frame carries the display-only smooth-scroll peek row: one extra row below
    /// the viewport (built whenever the view is scrolled into history) that the fraction translate
    /// reveals. The renderer clips it behind the grid box at fraction 0.
    var hasPeekRow: Bool = false
    var frameBuildNanos: UInt64
    var clearColor: RenderColor
    /// When the next frame of a Kitty animation this frame draws is due (uptime nanoseconds).
    var nextAnimationFrame: UInt64?
    var cursorCanBlink: Bool = false
    var hasShellPrompt: Bool = false
    var source: ObjectIdentifier?
    var outputGeneration: UInt64 = 0
}

private final class SurfaceColorProviderState: @unchecked Sendable {
    private let lock = NSLock()
    private var foreground = RGBColor(red: 255, green: 255, blue: 255)
    private var background = RGBColor(red: 0, green: 0, blue: 0)
    private var cursor = RGBColor(red: 255, green: 255, blue: 255)
    private var palette: [RGBColor] = []

    func update(foreground: RGBColor, background: RGBColor, cursor: RGBColor, palette: [RGBColor]) {
        lock.lock()
        self.foreground = foreground
        self.background = background
        self.cursor = cursor
        self.palette = palette
        lock.unlock()
    }

    func resolve(_ role: TerminalColorRole) -> (r: UInt8, g: UInt8, b: UInt8)? {
        lock.lock()
        defer { lock.unlock() }
        let c: RGBColor
        switch role {
        case .foreground: c = foreground
        case .background: c = background
        case .cursor: c = cursor
        case let .palette(i):
            guard i >= 0, i < palette.count else { return nil }
            c = palette[i]
        }
        return (c.red, c.green, c.blue)
    }
}

final class SurfaceEmulatorState: @unchecked Sendable {
    private let specific = DispatchSpecificKey<Void>()

    private(set) var emulator: TerminalEmulator
    let queue: DispatchQueue
    var renderMirror: TerminalGridSnapshot?
    var lastPlainFrame: TerminalFrame?
    /// The `renderGeneration` the cached `lastPlainFrame` was built against. The worker refuses to
    /// reuse a frame from a different generation, so a resize/theme/detach that bumps the generation
    /// (and resets the emulator/grid) can never diff new damage against a frame built for the old
    /// grid — which would show torn/stale rows. Belt-and-suspenders alongside `resetPlainFrame()`.
    var lastPlainFrameGeneration: UInt64 = 0
    /// Scroll-delta reuse source: the last overlay-free, image-free viewport frame (live at
    /// offset 0 or a scrolled history view), the scroll offset it was built at, and its
    /// generation. A pure scroll between two such frames rotates the renderer row cache
    /// and resolves only exposed rows. Touched only on the serial emulator queue.
    var lastViewportFrame: TerminalFrame?
    var lastViewportOffset = 0
    var lastViewportGeneration: UInt64 = 0
    /// Per-row fingerprints of the last build's cell-overlay pass (selection / find / IME
    /// preedit shading) — see `overlayRowKeys`. The next build re-encodes exactly the rows
    /// whose fingerprint changed, so a selection drag costs the rows it crossed, not the grid.
    /// Touched only on the serial queue (same discipline as `lastPlainFrame`).
    var lastOverlayKeys: [Int: UInt64] = [:]

    /// Latest-wins coalescing for frame builds. Every `renderNowOffMain()` claims a token; a
    /// build whose token is no longer the latest (a newer build is already queued behind it on this
    /// serial queue) skips itself. The superseding build still sees all accumulated damage (the
    /// skipped build never called `consumeDamage`), so no rows are lost — a burst of marks coalesces
    /// to one build instead of N stale ones. Guarded by `tokenLock` because it's claimed on main and
    /// checked on the worker.
    private let tokenLock = NSLock()
    private var latestFrameToken: UInt64 = 0
    private var isVisible = true

    func setVisible(_ visible: Bool) {
        tokenLock.lock(); isVisible = visible; tokenLock.unlock()
    }

    func claimFrameToken() -> UInt64 {
        tokenLock.lock(); defer { tokenLock.unlock() }
        latestFrameToken &+= 1
        return latestFrameToken
    }

    func isLatestFrameToken(_ token: UInt64) -> Bool {
        tokenLock.lock(); defer { tokenLock.unlock() }
        return token == latestFrameToken
    }

    /// Separate token namespace for the live-resize preview builds. The preview must NOT share
    /// `latestFrameToken` with the output pipeline: during an ANIMATED resize (sidebar slide,
    /// tiling — no live-resize bracket, so output presents are not deferred) the two pipelines
    /// run concurrently, and a shared counter would let an output build silently cancel an
    /// in-flight re-wrap preview (and vice versa, dropping an echo frame). Each pipeline
    /// coalesces latest-wins against itself only.
    private var latestPreviewToken: UInt64 = 0

    func claimPreviewToken() -> UInt64 {
        tokenLock.lock(); defer { tokenLock.unlock() }
        latestPreviewToken &+= 1
        return latestPreviewToken
    }

    func isLatestPreviewToken(_ token: UInt64) -> Bool {
        tokenLock.lock(); defer { tokenLock.unlock() }
        return token == latestPreviewToken
    }

    /// Latest parser state published together so main-thread coordinates share one epoch.
    struct PendingMainHop {
        var textContext: TerminalTextAnchorContext
        var historyCount: Int
        var modes: TerminalModes
        var altScreen: Bool
    }

    /// Staged hop state + the "a main hop is in flight" flag, guarded by `tokenLock` (written on
    /// the worker, consumed on main). Invariant: whenever `pendingHop != nil`, exactly one
    /// `applyPendingMainHop` is queued or executing on main — `stageMainHop` returns true only
    /// to the chunk that transitions nil → non-nil, and that caller dispatches the hop.
    private var pendingHop: PendingMainHop?

    /// Merge this chunk's post-parse state into the staged hop. Returns true when the caller
    /// must dispatch a main hop (none is in flight); false when an already-queued hop will
    /// observe this state.
    func stageMainHop(textContext: TerminalTextAnchorContext, historyCount: Int, modes: TerminalModes, altScreen: Bool) -> Bool {
        tokenLock.lock(); defer { tokenLock.unlock() }
        if var hop = pendingHop {
            hop.textContext = textContext
            hop.historyCount = historyCount
            hop.modes = modes
            hop.altScreen = altScreen
            pendingHop = hop
            return false
        }
        pendingHop = PendingMainHop(
            textContext: textContext, historyCount: historyCount, modes: modes, altScreen: altScreen
        )
        return true
    }

    /// Consume the staged hop (main side). A chunk that lands after this re-arms a new hop.
    func takePendingMainHop() -> PendingMainHop? {
        tokenLock.lock(); defer { tokenLock.unlock() }
        defer { pendingHop = nil }
        return pendingHop
    }

    /// The latest grid size a resize commit requested, applied-and-cleared by the NEXT output/commit
    /// build to run on the queue (`applyPendingResize` at the top of `renderNowOffMain`'s build).
    /// Decoupling "which size to materialize" from "which build wins the latest-wins token" is what
    /// lets mid-drag output presents coexist with live-resize commits: an output build that
    /// supersedes an in-flight commit build (newer token → the commit skips before its resize)
    /// still carries the resize forward, so the emulator can never strand at the old size after
    /// the PTY vote went out. Touched ONLY on `queue` (the setters below dispatch there; the
    /// queue's FIFO orders a `setPendingResize` ahead of any build dispatched after it).
    private var pendingResize: (cols: Int, rows: Int)?
    private var pendingResizeLocalOnly = false

    /// Enqueue a resize target from main. The preview pipeline must never call the apply side —
    /// previews are non-mutating reads at an explicit target size.
    /// `localOnly` reflows the primary screen and leaves the alternate screen alone.
    func setPendingResize(_ size: (cols: Int, rows: Int), localOnly: Bool = false) {
        queue.async { [self] in
            pendingResize = size
            pendingResizeLocalOnly = localOnly
        }
    }

    /// Drop an unapplied target (detach/re-host: a stale size must not apply to a re-hosted view).
    func clearPendingResize() {
        queue.async { [self] in pendingResize = nil }
    }

    /// On-queue: materialize any pending resize and clear it. Idempotent across builds; returns
    /// whether the grid dimensions actually changed so the caller can drop its reuse caches.
    func applyPendingResize() -> Bool {
        dispatchPrecondition(condition: .onQueue(queue))
        guard let size = pendingResize else { return false }
        let localOnly = pendingResizeLocalOnly
        pendingResize = nil
        pendingResizeLocalOnly = false
        if localOnly {
            return emulator.resizePrimaryLocally(cols: size.cols, rows: size.rows)
        }
        emulator.resize(cols: size.cols, rows: size.rows)
        return true
    }

    /// Test seam: the staged-but-unapplied resize target (read on the queue).
    func pendingResizeForTesting() -> (cols: Int, rows: Int)? {
        sync { _ in pendingResize }
    }

    init(columns: Int, rows: Int) {
        self.emulator = TerminalEmulator(cols: columns, rows: rows)
        self.queue = DispatchQueue(label: "com.robert.harness.terminal-surface.emulator", qos: .utility)
        queue.setSpecific(key: specific, value: ())
    }

    func sync<T>(_ body: (TerminalEmulator) -> T) -> T {
        if DispatchQueue.getSpecific(key: specific) != nil {
            return body(emulator)
        }
        return queue.sync {
            body(emulator)
        }
    }

    func async(_ body: @escaping @Sendable (TerminalEmulator) -> Void) {
        tokenLock.lock(); let visible = isVisible; tokenLock.unlock()
        queue.async(qos: visible ? .userInteractive : .utility, flags: .enforceQoS) { [self] in
            body(emulator)
        }
    }

    func resetPlainFrame() {
        sync { _ in
            lastPlainFrame = nil
            lastViewportFrame = nil
            lastOverlayKeys = [:]
        }
    }

    /// Replace the emulator on its worker queue and discard caches describing the old grid.
    func replaceEmulator(with next: TerminalEmulator) {
        emulator = next
        renderMirror = nil
        lastPlainFrame = nil
        lastViewportFrame = nil
        lastOverlayKeys = [:]
    }
}

/// A resync's scrollback, rebuilt off to the side: the history parses into a replacement
/// emulator on this queue while the pane shows the daemon's screen, live output feeds both in
/// the same order, and the view swaps the replacement in once the history is parsed.
private final class HistoryRestore: @unchecked Sendable {
    let emulator: TerminalEmulator
    let queue = DispatchQueue(label: "com.robert.harness.terminal-surface.history-restore", qos: .userInitiated)
    /// Main-confined: any history arrived. A restore without any has nothing to add.
    var receivedHistory = false
    private let sizes: [ReplaySize]
    private var receivingHistory = true
    private var pendingSize: (cols: Int, rows: Int, localOnly: Bool)?

    init(emulator: TerminalEmulator, sizes: [ReplaySize]) {
        self.emulator = emulator
        self.sizes = sizes
        emulator.isReplaying = true
    }

    func feedHistory(_ data: Data, sequence: UInt64, onConsumed: @escaping @Sendable () -> Void) {
        queue.async { [self] in
            defer { onConsumed() }
            ReplaySize.replay(data, sequence: sequence, sizes: sizes, resize: { cols, rows in
                if emulator.cols != cols || emulator.rows != rows { emulator.resize(cols: cols, rows: rows) }
            }, feed: emulator.feed)
            if emulator.isShellPromptReady { StartupMetrics.shared.mark(.firstShellPromptConsumed) }
        }
    }

    func finish(cols: Int, rows: Int) {
        receivingHistory = false
        let target = pendingSize ?? (cols, rows, false)
        resize(cols: target.cols, rows: target.rows, localOnly: target.localOnly)
    }

    func feed(_ data: Data) {
        queue.async { [self] in emulator.feed(data) }
    }

    func afterPendingFeed(_ consumed: @escaping @Sendable () -> Void) {
        queue.async(execute: consumed)
    }

    func resize(cols: Int, rows: Int, localOnly: Bool) {
        if receivingHistory {
            pendingSize = (cols, rows, localOnly)
            return
        }
        queue.async { [self] in
            if localOnly {
                _ = emulator.resizePrimaryLocally(cols: cols, rows: rows)
            } else {
                emulator.resize(cols: cols, rows: rows)
            }
        }
    }
}

private final class SurfaceOutputConfiguration: @unchecked Sendable {
    private let lock = NSLock()
    private var scanner: TriggerScanner?
    private var restore: HistoryRestore?

    func setScanner(_ value: TriggerScanner?) {
        lock.lock(); scanner = value; lock.unlock()
    }

    func setRestore(_ value: HistoryRestore?) {
        lock.lock(); restore = value; lock.unlock()
    }

    func snapshot() -> (TriggerScanner?, HistoryRestore?) {
        lock.lock(); defer { lock.unlock() }
        return (scanner, restore)
    }
}

/// The native, self-contained terminal surface: a `CAMetalLayer`-backed `NSView` that
/// drives a `TerminalEmulator` and draws it with `TerminalMetalRenderer`. This is the
/// replacement for the previous renderer's view — bytes in via `receive(_:)`, input out
/// via `onInput`, grid-size changes via `onResize`.
///
/// Scope: GPU rendering with accurate sRGB output by default, opt-in converted Display-P3
/// vivid color, keyboard input, live resize, PTY responses (DSR/DA), mouse reporting,
/// selection, scrollback, copy mode, file-drop path insertion, IME, inline images, and
/// shell-integration marks.
@MainActor
public final class HarnessTerminalSurfaceView: NSView {
    private static let legacyFilenamesPasteboardType = NSPasteboard.PasteboardType("NSFilenamesPboardType")
    private static let droppedPathPasteboardTypes: [NSPasteboard.PasteboardType] = [
        .fileURL,
        legacyFilenamesPasteboardType,
    ]

    static func droppedFileURLs(from pasteboard: NSPasteboard) -> [URL] {
        var urls: [URL] = []
        let options: [NSPasteboard.ReadingOptionKey: Any] = [.urlReadingFileURLsOnly: true]
        let objects = pasteboard.readObjects(forClasses: [NSURL.self], options: options) ?? []
        urls.append(contentsOf: objects.compactMap { object in
            if let url = object as? URL, url.isFileURL { return url }
            if let url = object as? NSURL, (url as URL).isFileURL { return url as URL }
            return nil
        })

        if let filenames = pasteboard.propertyList(forType: legacyFilenamesPasteboardType) as? [String] {
            urls.append(contentsOf: filenames.map { URL(fileURLWithPath: $0) })
        }

        var seen = Set<String>()
        return urls.compactMap { url in
            let standardized = url.standardizedFileURL
            guard seen.insert(standardized.path).inserted else { return nil }
            return standardized
        }
    }

    static func shellQuotedPath(_ path: String) -> String {
        ShellQuoting.quote(path)
    }

    static func droppedPathText(for urls: [URL]) -> String {
        urls.map { shellQuotedPath($0.path) }.joined(separator: " ")
    }

    /// Set when the pane's shell runs on another machine: a pasted image or file is uploaded
    /// there (bytes, file name, completion with the remote path or nil) instead of pasting a
    /// local path the remote shell can't open.
    public var uploadForPaste: ((Data, String, @escaping @MainActor (String?) -> Void) -> Void)?

    /// Upload each file (or the image) to the remote daemon, then paste the remote paths.
    func pasteRemotely(_ files: [(Data, String)], upload: @escaping (Data, String, @escaping @MainActor (String?) -> Void) -> Void) {
        var remaining = files
        var paths: [String] = []
        func next() {
            // A pane closed mid-upload has no input sink: stop instead of uploading the rest.
            guard onInput != nil else { return }
            guard !remaining.isEmpty else {
                if !paths.isEmpty { pasteText(paths.map(Self.shellQuotedPath).joined(separator: " ")) }
                return
            }
            let (data, name) = remaining.removeFirst()
            upload(data, name) { path in
                if let path { paths.append(path) }
                next()
            }
        }
        next()
    }

    /// Files from a paste or drop, read for upload. Folders and unreadable files are skipped.
    static func uploadable(_ urls: [URL]) -> [(Data, String)] {
        urls.compactMap { url in
            guard let data = try? Data(contentsOf: url, options: .mappedIfSafe) else { return nil }
            return (data, url.lastPathComponent)
        }
    }

    /// Bytes the terminal produces for the PTY (typed input, key sequences, DSR/DA).
    public var onInput: ((Data) -> Void)?
    /// A short user-facing message the view can't show itself, such as a refused paste.
    public var onNotice: ((String) -> Void)?
    /// New grid size after a resize (columns, rows) — the host forwards this to the daemon.
    public var onResize: ((Int, Int) -> Void)?
    /// When false, a resize reflows this client's primary screen and does not vote a PTY size.
    /// The alternate screen is not reflowed. Default true keeps the single-client ioctl path.
    /// Whether this client sets the PTY size. A non-owner reflows locally instead; becoming
    /// the owner again re-commits the grid to the view and votes that size, since the window
    /// may have been resized while its votes didn't count.
    /// This client answers the program's terminal queries (the daemon picks exactly one per
    /// pane); the others stay quiet so a query gets one reply.
    public var answersQueries = true

    public var sizeOwner = true {
        didSet {
            guard sizeOwner, !oldValue else { return }
            updateGridSize()
            onResize?(columns, rows)
        }
    }

    /// A non-owner on the alternate screen shows the owner's grid as-is: a full-screen program
    /// draws for that size, so reflowing it to this view would scramble it. The view clips or
    /// pads; the PTY is untouched.
    public func adoptOwnerSize(cols: Int, rows newRows: Int) {
        guard !sizeOwner, inputAltScreenActive(), cols > 0, newRows > 0, cols != columns || newRows != rows else { return }
        clearSelection()
        columns = cols
        rows = newRows
        invalidateRenderGeneration(contentChanged: true)
        historyRestore?.resize(cols: cols, rows: newRows, localOnly: false)
        emulatorState.setPendingResize((cols, newRows), localOnly: false)
        renderNowOffMain()
    }
    /// Fires while the grid size changes during a resize so the host can show a dimensions HUD.
    /// `committed` is false for the live (mid-drag) tick and true once the size settles. Never
    /// fires for the terminal's initial sizing live tick (opening a window isn't a resize).
    public var onGridSizeWillChange: ((_ cols: Int, _ rows: Int, _ committed: Bool) -> Void)?
    /// Fires when the scrollback position changes (wheel, page keys, jump-to-prompt) so the host
    /// can show a transient scrollbar. `topLine` is the buffer index of the top visible row,
    /// `totalLines` the whole buffer (history + viewport), `visibleRows` the viewport height.
    public var onScrollChanged: ((_ topLine: Int, _ totalLines: Int, _ visibleRows: Int) -> Void)?
    /// Window/tab title (OSC 0 / OSC 2) — the host forwards this to its delegate.
    public var onTitle: ((String) -> Void)?
    /// ConEmu progress report (OSC 9;4) — the host forwards this to its delegate, which
    /// drives the tab's working indicator (Claude Code 2.0+ keep-alives it per turn).
    public var onProgress: ((TerminalProgressReport) -> Void)?
    /// Reported working directory (OSC 7) — the host forwards this to its delegate.
    public var onPwd: ((String) -> Void)?
    /// OSC 7 hostname changes (nil = no authority / reset) — drives per-host profiles.
    public var onRemoteHost: ((String?) -> Void)?
    /// OSC 1337 `SetUserVar=` (decoded + validated by the engine) — the host surfaces these
    /// as pane-scoped `@name` user options so format strings can read them.
    public var onUserVar: ((_ name: String, _ value: String) -> Void)?
    /// RIS dropped every user variable — the host clears the `@` options it pushed for
    /// this surface so `#{@name}` doesn't keep serving pre-reset values.
    public var onUserVarsCleared: (() -> Void)?
    /// Terminal bell (BEL) — the host forwards this to its delegate.
    public var onBell: (() -> Void)?
    /// A shell command finished (OSC 133), with its run duration + exit code — the host forwards
    /// this for the long-running-command-finished notification.
    public var onCommandFinished: ((_ duration: TimeInterval, _ exitCode: Int?) -> Void)?
    /// Desktop notification requested by a program (OSC 9 → nil title; OSC 777 → title+body)
    /// — the host forwards this to its delegate.
    public var onDesktopNotification: ((_ title: String?, _ body: String) -> Void)?
    /// This surface became effectively focused (first responder × key window). The host
    /// bridges it to the focus delegate so focusing a pane by click or app re-activation —
    /// not only a programmatic tab switch — clears its pending notification.
    public var onBecameFocused: (() -> Void)?
    /// Copied selection text — the host mirrors it into the daemon paste buffer (the
    /// system pasteboard is written here directly).
    public var onCopy: ((String) -> Void)?
    /// Optional per-frame renderer stats sink for diagnostics/benchmarks.
    public var onRenderStats: ((TerminalRenderStats) -> Void)?
    /// First successful CPU frame submission containing an OSC 133 B shell prompt.
    public var onFirstShellPromptSubmitted: (() -> Void)?
    private var hasSubmittedShellPrompt = false
    /// Whether a program may set the system clipboard via OSC 52 (tmux
    /// `set-clipboard`). The host sets this from the option; default on.
    public var allowProgramClipboardAccess = true
    /// Whether Kitty graphics may load images from files and shared memory on this Mac. Off for
    /// a pane whose program runs on another machine: its paths aren't ours, and reading them
    /// would let it probe this Mac's disk.
    public func setReadsLocalGraphicsFiles(_ allowed: Bool) {
        emulatorSync { $0.readsGraphicsFiles = allowed }
    }

    /// Whether a program may READ the system clipboard via OSC 52 (`allow-clipboard-read`).
    /// Off by default: anything running in the pane, or on a remote host, could read it.
    public var allowProgramClipboardRead = false

    let emulatorState: SurfaceEmulatorState
    /// The scrollback a resync is rebuilding behind the screen (`beginHistoryRestore`).
    private let outputConfiguration = SurfaceOutputConfiguration()
    private lazy var outputReceiver = createOutputReceiver()
    private var historyRestore: HistoryRestore? {
        didSet { outputConfiguration.setRestore(historyRestore) }
    }
    private let colorProviderState = SurfaceColorProviderState()
    let inputEncoder = InputEncoder()
    private var metalLayer = CAMetalLayer()
    private var drawablePoolReleased = false
    /// Bottom-corner radius applied to the metal layer itself. A parent mask does not
    /// clip an asynchronously presented `CAMetalLayer`, so the surface stays square
    /// unless this layer masks its own drawable.
    private var islandCornerRadius: CGFloat = 0
    var renderer: TerminalMetalRenderer?
    var renderExecutor: SurfaceRenderExecutor?
    private var nextPresentationID: UInt64 = 0
    private var completedPresentationID: UInt64 = 0

    private var frameBuildConfiguration: SurfaceFrameBuildConfiguration
    private var colorRendering: TerminalColorRenderingMode
    private var colorGamut: TerminalColorGamut
    var renderGeneration: UInt64 = 0
    /// The last frame presented on the main thread, kept so a live resize can re-present it at the
    /// new drawable size WITHOUT touching the emulator serial queue (which, during heavy output, is
    /// busy parsing). During a drag the grid content is unchanged — reflow + SIGWINCH is debounced
    /// to drag-end (`scheduleResizeCommit`) — so stretching the last frame is exactly correct and
    /// never blocks main behind the parser. Main-thread only (written in `presentBuiltFrame`).
    // Renderer mutation/encoding is serialized independently of potentially stalled acquisition.
    private let drawableQueue = DispatchQueue(label: "com.robert.harness.drawable", qos: .userInteractive)
    private let drawableAcquisitionQueues = (0..<2).map {
        DispatchQueue(label: "com.robert.harness.drawable-acquisition.\($0)", qos: .userInteractive)
    }
    private var drawableAcquisitionLane = 0
    private var drawableAcquisitionQueue: DispatchQueue { drawableAcquisitionQueues[drawableAcquisitionLane] }
    private var activeDrawableRequest: SurfaceDrawableRequest?
    var drawableRequestInFlight = false
    var pendingDrawableFrame: SurfaceFrameBuildResult?
    private var pendingDrawableNeedsFullDamage = false
    var lastPresentedResult: SurfaceFrameBuildResult?
    /// True when the renderer's row-instance cache verifiably holds exactly
    /// `lastPresentedResult.frame`'s rows — i.e. the last renderer encode was of that frame through
    /// the cache-updating path (non-nil damage, no images). Then `repaintLastFrame` can present with
    /// EMPTY damage and reuse every row (`encodedRows == 0`, zero-copy instance bind): under the
    /// drag-frozen origin all cache keys are stable, so the per-tick cost collapses to the viewport
    /// uniform + draw. Anything that lets the cache and the frame disagree — a preview replacing the
    /// frame without a present, a dropped present wiping the cache, an overlay/image frame bypassing
    /// it, a renderer rebuild — clears the flag, and the next repaint pays one cache-populating full
    /// rebuild before ticks turn free again. Main-thread only, like `lastPresentedResult`.
    var lastPresentedResultIsRendererCoherent = false
    /// The (cols, rows) the live-resize preview was last built for, so a continuous drag rebuilds the
    /// re-wrap preview only when the cell count actually changes (sub-cell drag frames re-present the
    /// cached preview at the new drawable size). Reset on commit so the next drag starts fresh.
    private var previewCols = 0
    private var previewRows = 0
    /// Real-time live resize. When true, a window-edge drag commits the
    /// authoritative grid reflow + PTY `SIGWINCH` at every cell boundary so interactive programs
    /// (vim/htop/tmux) redraw continuously, instead of deferring the reflow to drag-end. The
    /// non-mutating re-wrap preview still rides under it for instant feedback. Set from
    /// `configureAppearance(liveResizeReflow:)`; the escape-hatch setting defaults it on. When
    /// false the surface keeps the legacy defer-to-release behavior.
    private var liveResizeReflowEnabled = true
    /// The (cols, rows) last handed to the PTY via `onResize`, so a mid-drag commit only fires a
    /// `SIGWINCH` when the cell count actually changed from the last one sent (a within-column drag
    /// frame sends nothing). Reset at drag end so the next drag starts fresh.
    private var lastSentPTYSize: (cols: Int, rows: Int)?
    private var fontFamily: String
    private var fontFallbackFamilies: [String]
    private var fontFeatures: [String: Int]
    private var fontSize: CGFloat
    private var fontThicken: Bool
    private var fontThickenStrength: Int
    /// The canvas (default) background — used as the Metal clear color and (at
    /// `canvasOpacity`) for default-bg cells. Resolved by the host through the same
    /// `ThemeManager.resolvedCanvas` the chrome uses, so terminal and chrome never seam.
    private var canvasBackground: RGBColor
    /// 0...1. < 1 makes the canvas translucent (the window blur shows through); program
    /// output backgrounds and glyphs stay opaque.
    private var canvasOpacity: Float
    /// Window padding in points (`window-padding-x/y`); converted to device
    /// pixels and used both as the grid inset and the renderer's draw origin.
    private var paddingPointsX: CGFloat = 0
    private var paddingPointsY: CGFloat = 0
    /// Center the grid by splitting the sub-cell remainder onto both sides (`window-padding-balance`).
    private var paddingBalanced = true
    /// Device-pixel grid origin (padding × scale, plus the centering half-offset when balanced).
    /// Reused by `renderNow` as the draw origin and by mouse→cell mapping via `gridOriginPoints*`.
    private var originOffsetX = 0
    private var originOffsetY = 0
    /// The grid's left/top origin in points (device-px `originOffset` ÷ backing scale). Equals the
    /// window padding when unbalanced; when balanced it includes the centering half-offset, so
    /// mouse hit-testing, link-hover, and IME anchoring stay aligned with the centered grid.
    var gridOriginPointsX: CGFloat { CGFloat(originOffsetX) / (window?.backingScaleFactor ?? 2.0) }
    var gridOriginPointsY: CGFloat { CGFloat(originOffsetY) / (window?.backingScaleFactor ?? 2.0) }
    /// Cursor shape + blink (`cursor-style` / `cursor-style-blink`).
    private var cursorStyle: CursorStyle = .block
    var cursorBlinkEnabled = true
    /// Blink phase: false hides the cursor on the off-beat. Reset to true on activity.
    var cursorBlinkVisible = true
    var blinkTimer: Timer?
    /// SGR text blink (`SGR 5`): phase driver for blinking CELLS, independent of the cursor
    /// timer (cursor blink follows focus; text blink follows content + visibility). Exists
    /// only while the last presented frame contained blink cells and the pane is visible.
    var textBlinkTimer: Timer?
    var textBlinkHidden = false
    /// One-shot wake for a Kitty animation frame too far off for the display link to time
    /// (`RenderScheduler.animationWake`); replaced with each deadline, gone with the link.
    private var animationWakeTimer: Timer?
    /// Whether the most recently presented frame contained SGR-blink cells — drives
    /// `updateTextBlinkTimer` across occlusion changes without rescanning a frame.
    var lastFrameHadBlink = false
    /// First-responder state — the cursor only blinks while focused.
    var focused = false
    /// Whether the host window is key. Combined with `focused` for the user-visible focus
    /// state (hollow cursor, blink) and DECSET 1004 focus reporting — a first responder in a
    /// deactivated window is not focused.
    private var windowIsKey = false
    private var windowKeyObservers: [NSObjectProtocol] = []
    /// Last focus value reported via DECSET 1004, so window-key and first-responder
    /// transitions never double-report the same state.
    var lastReportedFocus: Bool?
    var effectivelyFocused: Bool { focused && windowIsKey }
    /// Mouse selection endpoints (anchor = where the drag started, head = current), in ABSOLUTE
    /// buffer coordinates: `line` is the virtual buffer line (copy mode's space — history first,
    /// then viewport; viewport row 0 = `historyCount - scrollOffset`). Content-anchored, not
    /// viewport-anchored, so the selection survives scrolling and new output (#161). A
    /// `SelectionRegion` is derived (expanded by granularity, rebased to viewport rows) for
    /// highlight + extraction.
    private var textAnchorContext: TerminalTextAnchorContext?
    var selectionStartAnchor: TerminalTextAnchor?
    var selectionEndAnchor: TerminalTextAnchor?
    var selectionAnchor: (line: Int, column: Int)? {
        get { selectionStartAnchor?.position.map { ($0.line, $0.column) } }
        set {
            guard let newValue else { selectionStartAnchor = nil; return }
            if let anchor = trackTextPosition(line: newValue.line, column: newValue.column) { selectionStartAnchor = anchor }
        }
    }
    var selectionHead: (line: Int, column: Int)? {
        get { selectionEndAnchor?.position.map { ($0.line, $0.column) } }
        set {
            guard let newValue else { selectionEndAnchor = nil; return }
            if let anchor = trackTextPosition(line: newValue.line, column: newValue.column) { selectionEndAnchor = anchor }
        }
    }

    func trackTextPosition(line: Int, column: Int) -> TerminalTextAnchor? {
        textAnchorContext?.makeAnchor(line: line, column: column)
    }
    /// Selection unit set by click count: 1 = character, 2 = word, 3 = line. A drag extends by
    /// the unit; word/line ranges reuse copy-mode's word definition.
    enum SelectionGranularity { case character, word, line }
    var selectionGranularity: SelectionGranularity = .character
    /// Option-drag makes a rectangular (block) selection instead of a linear one.
    var selectionRectangular = false
    private var selectionBackground: RGBColor?
    private var selectionForeground: RGBColor?
    /// Copy the selection to the pasteboard automatically when a drag ends.
    var copyOnSelect = false
    /// Confirm before pasting risky (multi-line / control-char) text when bracketed paste is off.
    var pasteProtection = true
    /// Mouse-wheel / trackpad scroll-distance multiplier.
    /// 1 = native. Set from `HarnessSettings.scrollMultiplier` (already clamped).
    var scrollMultiplier: CGFloat = 1
    /// Hide the cursor while typing until the mouse next moves.
    var mouseHideWhileTyping = false
    var optionAsMeta: OptionAsMetaMode = .composed
    /// True swallows the key. Installed by the host for the config-file keymap.
    public var consumeScriptKey: (@MainActor (NSEvent) -> Bool)?
    /// Scrollback offset in lines (0 = live bottom; >0 = scrolled up into history).
    private var viewportAnchor: TerminalTextAnchor?
    var scrollOffset: Int {
        get {
            guard let viewportAnchor else { return 0 }
            guard let position = viewportAnchor.position else { return historyCountMirror }
            return max(0, min(historyCountMirror, historyCountMirror - position.line))
        }
        set {
            guard newValue > 0 else { viewportAnchor = nil; return }
            if let anchor = trackTextPosition(line: max(0, historyCountMirror - newValue), column: 0) {
                viewportAnchor = anchor
            }
        }
    }
    /// Smooth-scroll sub-line position. The continuous scrollback position is
    /// `P = scrollOffset - scrollFraction` (lines): the frame is built at the integer
    /// `scrollOffset = ceil(P)` — one line further back — and translated UP by
    /// `scrollFraction` of a cell at present time (a vertex-stage uniform; render-only, never
    /// baked into instances). The peek row fills the gap the translate opens at the bottom.
    /// Always 0 at the live bottom and whenever resting exactly on a line; every line-based
    /// consumer (hit-testing, copy mode, find, pinning, mouse reporting) keeps reading the
    /// integer `scrollOffset`.
    var scrollFraction: CGFloat = 0
    /// Sub-line wheel remainder carried between scroll events so small trackpad movements
    /// accumulate into whole lines instead of each snapping a full line (see `consumeWheelLines`).
    var wheelLineRemainder: CGFloat = 0
    /// Horizontal counterpart for mouse-reported wheel-left/right (see `consumeWheelColumns`).
    var wheelColumnRemainder: CGFloat = 0
    /// Lines per notch for a discrete (non-precise) mouse wheel — the classic 3-line step.
    static let mouseWheelLinesPerTick: CGFloat = 3
    /// Test-only: counts main-thread consume hops (one per `receiveOffMain` main bounce). The
    /// latency-under-load benchmark reads this to measure how aggressively the consume path
    /// coalesces a flood of small chunks. Never read in production; a single `Int` add on main.
    var testingMainHopCount = 0
    /// Canvas foreground — used to draw IME preedit (marked) text over the grid.
    private var canvasForeground: RGBColor = RGBColor(red: 255, green: 255, blue: 255)
    /// Resolved cursor + 16-color palette, surfaced to programs via OSC 10/11/12/4 *queries*
    /// (`emulator.colorProvider`) for light/dark theme detection.
    private var canvasCursor: RGBColor = RGBColor(red: 255, green: 255, blue: 255)
    private var ansiPalette16: [RGBColor] = []
    /// In-progress IME composition (preedit). Empty when not composing.
    var markedText = ""
    /// Glyph coverage gamma: 1 = native blending; < 1 = gamma-correct (thicker) text.
    private var glyphGamma: Float = 1
    /// Programming-font ligatures via CoreText run shaping.
    private var ligaturesEnabled = true
    /// Draw the OSC 133 prompt gutter stripe. Off by default (a user opt-in).
    private var promptGutterEnabled = false

    var columns: Int = 80
    var rows: Int = 24
    /// Live grid size. Peek and overview read this and do not write it, so `stty size` stays put.
    public var gridCellCount: (rows: Int, columns: Int) { (rows, columns) }
    /// Bumped on the main thread each time parsed output reaches the screen, so a thumbnail
    /// following this pane knows when it has something new to draw.
    public private(set) var outputGeneration: UInt64 = 0
    /// Copy-mode `w`/`b`/`e` separator set. The app pushes the `word-separators` option.
    public var copyModeWordSeparators: String = CopyModeWords.tmuxDefault
    /// Coalesces renders to display cadence: `scheduleRender` marks dirty and wakes the link, which
    /// presents at most one frame per tick (resize/first paint/2026-timeout force immediately). Wired
    /// to `renderNow` in `init`.
    lazy var scheduler = RenderScheduler(
        render: { [weak self] in self?.renderNow() },
        renderSynchronously: { [weak self] in self?.renderNowSynchronous() }
    )
    /// Main-thread display-cadence source (macOS 14+ `NSView.displayLink(target:selector:)`). Created
    /// when the view enters a window, paused while idle, invalidated on detach. nil when not in a
    /// window. Named `renderLink` so it doesn't shadow the `NSView.displayLink(...)` factory.
    private var renderLink: CADisplayLink?
    private var drawableRetryTimer: Timer?
    private var drawableRetryDelay: TimeInterval = 0.025
    /// True once the grid has been sized from a real layout — the first sizing commits
    /// immediately (so the terminal opens at the right size); later changes coalesce.
    private var hasSizedGrid = false
    /// Pending coalesced grid+PTY resize. A sidebar slide / window drag calls `layout()`
    /// every frame; committing the grid reflow + PTY `SIGWINCH` each time storms the shell
    /// (fish/zsh redraw their prompt faster than they coalesce → overlapping garbage). The
    /// drawable still updates every frame for a smooth visual; the grid + PTY commit once the
    /// size settles.
    private var resizeCommitWork: DispatchWorkItem?
    /// Grid origin captured at `viewWillStartLiveResize`, held for the whole drag. Balanced
    /// padding re-centers the grid on *every* layout, so a pixel-by-pixel drag shifts the text
    /// ±1px per frame — a visible shimmer. Freezing the origin anchors the content for the
    /// duration (leftover sub-cell space accumulates at the right/bottom)
    /// and `viewDidEndLiveResize` re-centers exactly once for the settled size.
    private var liveResizeFrozenOrigin: (x: Int, y: Int)?
    /// Safety valve for DEC 2026 synchronized output: a program that enters a synchronized
    /// frame but never ends it must not freeze the display, so we force-present after this.
    private var syncTimeout: DispatchWorkItem?
    private let syncTimeoutInterval: TimeInterval = 0.15

    // MARK: Copy mode (in-pane overlay)
    /// Active copy-mode model (nil = not in copy mode). Driven by the shared
    /// `CopyModeReducer` over this view's own emulator (which holds the full scrollback), so
    /// the GUI overlay and the ssh compositor share one implementation.
    var copyMode: CopyModeState?
    /// Merged copy-mode key tables (defaults + user `keybindings.json`), loaded on entry.
    var copyModeTables: KeyTableSet?
    /// In-progress search query (nil = not entering a search). Shown in the status row.
    var copyModeSearchEntry: String?
    /// Set while a jump-to-char motion (`f`/`F`/`t`/`T`) is waiting for its target keystroke.
    var copyModeJumpEntry: CopyModeJumpKind?
    /// `mode-keys` option value (`vi` / `emacs`); the host sets it from the daemon option.
    public var copyModeKeys: String = "vi"
    public var isInCopyMode: Bool { copyMode != nil }

    // MARK: Find (in-scrollback search bar)
    /// True while the Cmd+F find bar is open; gates highlight rendering + scroll-to-match.
    var findActive = false
    /// All matches for the current query, in buffer-line order (history + viewport space).
    var findMatches: [TerminalBufferMatch] = []
    var findQuery = ""
    var findOptions = TerminalBufferSearchOptions.default
    var findCancellation: TerminalSearchCancellation?
    var findDebounce: DispatchWorkItem?
    /// Content refresh for an active query while output streams: at most one per
    /// `findRefreshInterval`, never cancelling a search already running.
    var findRefreshScheduled = false
    var findRefreshQueued = false
    var findInFlight = false
    var findLastStart: TimeInterval = 0
    static let findRefreshInterval: TimeInterval = 0.25
    var findContentRevision: UInt64 = 0
    private var accessibleCache: (revision: UInt64, text: TerminalAccessibilityText, cursorLine: Int, cursorColumn: Int, history: Int)?
    private var accessibleCacheBuiltAt: TimeInterval = 0
    static let accessibleCacheLifetime: TimeInterval = 0.2
    private(set) var testingAccessibleRebuildCount = 0
    var findTargetLine: Int?
    var findPosition: TerminalTextAnchor?
    var findCommandScope: TerminalCommandRegion?
    public var onRequestCommandFind: (() -> Void)?

    func beginCommandFind(_ command: TerminalCommandRegion) {
        findCommandScope = command
        findPosition = nil
        onRequestCommandFind?()
        scheduleFind()
    }
    public var onFindStatusChanged: ((String?) -> Void)?
    public var accessibilityPaneName = "Terminal"
    /// Index of the "current" match within `findMatches` (the one we scrolled to).
    var findCurrentIndex = 0

    // MARK: - Output triggers
    //
    // Patterns matched against each line as it COMPLETES (the cursor moved past it) —
    // `highlight` spans ride the find-highlight overlay machinery; `notify` surfaces via
    // `onTriggerMatched` with a per-rule cooldown. Scanning runs on the emulator's
    // confinement domain right after a feed, budgeted per batch, and costs nothing when no
    // rules are configured (`triggerScanner == nil` is the only check on the output path).

    /// Compiled rules; nil = scanning disabled. Set on main; immutable, so capturing it
    /// into the emulator-queue feed path is safe.
    var triggerScanner: TriggerScanner? {
        didSet { outputConfiguration.setScanner(triggerScanner) }
    }
    /// Scan bookkeeping confined to the emulator's domain (the serial queue when off-main,
    /// main otherwise — the same confinement the emulator itself has): the buffer line up to
    /// which lines were already scanned, and per-rule notify cooldown stamps.
    final class TriggerScanState: @unchecked Sendable {
        var nextLine = 0
        var lastNotifyNanos: [Int: UInt64] = [:]
        /// Rate-budget bookkeeping: emulator-queue time spent scanning in the current window.
        var windowStartNanos: UInt64 = 0
        var spentNanos: UInt64 = 0
    }
    private let triggerScanState = TriggerScanState()
    /// Highlight matches (absolute buffer lines, find-match shape) — main-thread render
    /// state merged into the find highlights at build. Bounded FIFO.
    var triggerHighlightMatches: [TerminalBufferMatch] = []
    static let maxTriggerHighlights = 512
    /// A `notify` rule matched (rule + the matched line's text). Fired on main, cooled down
    /// per rule (`triggerNotifyCooldownNanos`) so repeating output can't storm notifications.
    public var onTriggerMatched: ((TriggerRule, String) -> Void)?
    nonisolated static let triggerNotifyCooldownNanos: UInt64 = 10_000_000_000
    /// At most this many of the NEWEST completed lines scan per output batch — a flood skips
    /// the backlog (triggers watch recent output; an unbounded scan would tax the drain path).
    nonisolated static let triggerScanBatchLimit = 256
    /// Rate budget: scanning may consume at most this much of each window of emulator-queue
    /// time (~2%). Typical use never hits it; a sustained flood degrades to SAMPLING recent
    /// lines (the high-water keeps advancing past skipped output) instead of collapsing the
    /// drain rate — per-line scan cost is ~10µs, so unbudgeted scanning of a 500k-line/s
    /// flood would saturate the queue.
    nonisolated static let triggerScanWindowNanos: UInt64 = 100_000_000
    nonisolated static let triggerScanBudgetNanos: UInt64 = 2_000_000
    /// Reports `(current, total)` to the host so the find bar can show "n of m" (0,0 = none).
    public var onFindResultsChanged: ((_ current: Int, _ total: Int) -> Void)?

    // MARK: Link hover (⌘-hover affordance for ⌘-click open)
    /// The link span under the pointer while ⌘ is held: a grid row + half-open column range.
    /// Drives the underline layer and the pointing-hand cursor. nil when not hovering a link.
    var hoveredLink: (row: Int, columns: Range<Int>)?
    var linkHoverProbe: (row: Int, column: Int, scrollOffset: Int, revision: UInt64)?
    var testingLinkProbeCount = 0
    /// Underline drawn beneath the hovered link. A sublayer of the Metal layer so it composites
    /// above the terminal content without intercepting clicks (a subview would eat the ⌘-click).
    let linkUnderlineLayer = CALayer()
    /// Visual-bell flash: a full-surface translucent layer composited above the terminal content,
    /// faded out in one shot by `flashBell()`. Hidden at rest so it never affects normal rendering.
    private let bellFlashLayer = CALayer()
    /// Bumped per `flashBell()` so a flash that restarts mid-fade doesn't get hidden by the older
    /// animation's completion block.
    private var bellFlashGeneration: UInt64 = 0
    var trackingArea: NSTrackingArea?

    public init(
        themeName: String = ThemeManager.defaultThemeName,
        fontFamily: String = "Menlo",
        fontSize: CGFloat = 14,
        fontFallbackFamilies: [String] = [],
        fontFeatures: [String: Int] = [:],
        vivid: Bool = false,
        colorRendering: TerminalColorRenderingMode? = nil,
        colorGamut: TerminalColorGamut = .auto,
        liveResizeReflow: Bool = true
    ) {
        let theme = HarnessThemeCatalog.theme(named: themeName)
            ?? HarnessThemeCatalog.theme(named: ThemeManager.defaultThemeName)!
        let resolvedColorRendering = colorRendering ?? (vivid ? .vivid : .accurate)
        let resolvedGamut = TerminalColorGamut.resolved(
            renderingMode: resolvedColorRendering,
            requested: colorGamut
        )
        let resolver = CellColorResolver(theme: theme)
        // Baseline appearance; the host immediately overrides via configureAppearance.
        self.frameBuildConfiguration = SurfaceFrameBuildConfiguration(
            resolver: resolver,
            cursorColor: theme.cursor ?? theme.foreground,
            cursorTextColor: theme.cursorText,
            canvasOpacity: 1,
            colorRendering: resolvedColorRendering,
            colorGamut: resolvedGamut,
            cursorStyle: .block,
            selectionBackground: nil,
            selectionForeground: nil,
            promptGutterEnabled: true
        )
        self.canvasBackground = theme.background
        self.canvasOpacity = 1
        self.fontFamily = fontFamily
        self.fontFallbackFamilies = fontFallbackFamilies
        self.fontFeatures = fontFeatures
        self.fontSize = fontSize
        self.fontThicken = false
        self.fontThickenStrength = 255
        self.colorRendering = resolvedColorRendering
        self.colorGamut = resolvedGamut
        self.liveResizeReflowEnabled = liveResizeReflow
        self.emulatorState = SurfaceEmulatorState(columns: columns, rows: rows)
        self.textAnchorContext = emulatorState.sync { $0.textAnchorContext() }
        super.init(frame: .zero)
        registerForDraggedTypes(Self.droppedPathPasteboardTypes)
        colorProviderState.update(
            foreground: theme.foreground,
            background: theme.background,
            cursor: theme.cursor ?? theme.foreground,
            palette: theme.palette
        )
        configureLayer()
        configureEmulatorCallbacks()
        // Defer the renderer build: at init the view has no window, so
        // `window?.backingScaleFactor` would fall back to 2.0 and compile the Metal
        // pipeline at the wrong scale — work immediately thrown away when the host
        // calls `configureAppearance` and again at `viewDidMoveToWindow` (real scale).
        // Every render/layout path guards `renderer == nil`, and the first real render
        // only happens once the view is in a window, so building there is correct and
        // avoids a discarded shader/pipeline compile per surface.
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) unavailable") }

    // MARK: - Public API

    /// Feed PTY output bytes into the emulator and schedule a redraw.
    public func receive(_ data: Data) { receive(data, replay: false) }

    /// `replay: true` marks persisted-scrollback bytes fed on (re)attach: they restore state but
    /// must not re-fire world-facing effects (query replies to the PTY, bells, notifications,
    /// clipboard writes — see `TerminalEmulator.isReplaying`). The flag brackets exactly this
    /// chunk's `feed` on the emulator's serialized context.
    public func receive(_ data: Data, replay: Bool) {
        invalidateFindContent()
        receiveOffMain(data, replay: replay)
    }

    public func makeOutputReceiver() -> SurfaceOutputReceiver { outputReceiver }

    private func receiveOffMain(_ data: Data, replay: Bool = false) {
        outputReceiver.enqueue(data, replay: replay)
    }

    private func createOutputReceiver() -> SurfaceOutputReceiver {
        let state = emulatorState
        let configuration = outputConfiguration
        let scanState = triggerScanState
        return SurfaceOutputReceiver(schedule: { work in
            state.async { _ in work() }
        }, receive: { [weak self] data, replay, consumed in
            guard let self else { consumed(); return }
            let emulator = state.emulator
            let (scanner, restore) = configuration.snapshot()
            // A restore also parses live output. Its worker must release the ingress budget
            // after this parser finishes, so neither queue can grow behind a faster sibling.
            defer {
                if let restore { restore.afterPendingFeed(consumed) } else { consumed() }
            }
            restore?.feed(data)
            if replay { emulator.isReplaying = true }
            FrameSignposter.shared.interval("parse") { emulator.feed(data) }
            if replay { emulator.isReplaying = false }
            if emulator.isShellPromptReady { StartupMetrics.shared.mark(.firstShellPromptConsumed) }
            let afterHistory = emulator.historyCount
            // Trigger scan on the just-completed lines, here on the emulator queue — results
            // hop to main only when something matched (rare), never per chunk. On replay the
            // scan only advances its high-water (no notifications/highlights for restored output).
            if let scanner {
                let results = Self.scanTriggers(
                    emulator: emulator, scanner: scanner, state: scanState, replay: replay
                )
                if !results.highlights.isEmpty || !results.notifications.isEmpty {
                    DispatchQueue.main.async { [weak self] in
                        self?.consumeTriggerResults(results, scanner: scanner)
                    }
                }
            }
            // Coalesce the main hop: under a flood, per-chunk main.async was tens of thousands
            // of dispatches/sec of pure scheduling tax on the main thread. Each chunk merges its
            // post-parse state into the staged hop; only the chunk that finds no hop in flight
            // dispatches one, and the hop reads the LATEST staged state when it runs — so the
            // mirrors converge exactly as the old one-hop-per-chunk delivery did, in (at most)
            // one main dispatch per main-thread turn instead of one per chunk. A lone keystroke
            // echo on an idle surface still gets its immediate hop + presentNow.
            let needsHop = state.stageMainHop(
                textContext: emulator.textAnchorContext(),
                historyCount: afterHistory,
                modes: emulator.modes,
                altScreen: emulator.isAlternateScreenActive
            )
            guard needsHop else { return }
            FrameSignposter.shared.event("mainHop")
            DispatchQueue.main.async { [weak self] in
                self?.applyPendingMainHop()
            }
        })
    }

    /// Apply the staged post-parse state to the main-thread mirrors and the render scheduler.
    /// Runs on main; no-op when a concurrent flush (`testingWaitForEmulatorIdle`) already
    /// consumed the hop.
    private func applyPendingMainHop() {
        guard let hop = emulatorState.takePendingMainHop() else { return }
        invalidateFindContent()
        testingMainHopCount &+= 1
        outputGeneration &+= 1
        // Refresh the input-side mirror (see `inputModes()`); chunks merge in FIFO order on the
        // emulator queue, so the staged state is always the emulator's latest.
        inputModesMirror = hop.modes
        altScreenMirror = hop.altScreen
        historyCountMirror = hop.historyCount
        textAnchorContext = hop.textContext
        wakeCursor()
        if hop.modes.synchronizedOutput {
            scheduler.setSynchronized(true)
            armSyncTimeout()
        } else {
            syncTimeout?.cancel(); syncTimeout = nil
            scheduler.setSynchronized(false)
            wakeDisplayLink()
            // Low-latency echo (off-main): kick the frame build now rather than at the next
            // tick. renderNowOffMain builds on the emulator queue and presents on main; the
            // renderGeneration guard drops any stale build so there's no double present.
            scheduler.presentNow()
        }
    }

    private func armSyncTimeout() {
        guard syncTimeout == nil else { return }
        let work = DispatchWorkItem { [weak self] in
            self?.syncTimeout = nil
            // Safety valve: a program that set 2026 but never cleared it must not freeze the
            // display, so force-present past the hold.
            self?.scheduler.forceRender()
        }
        syncTimeout = work
        DispatchQueue.main.asyncAfter(deadline: .now() + syncTimeoutInterval, execute: work)
    }

    public func receive(_ text: String) { receive(Data(text.utf8)) }

    public func receive(_ text: String, replay: Bool) { receive(Data(text.utf8), replay: replay) }

    /// A resync: reset the terminal and paint `screen` (the daemon's visible screen as VT bytes)
    /// now, then rebuild the scrollback off the main thread from the history that follows
    /// (`receiveHistory`) and swap it in once parsed (`finishHistoryRestore`). The history never
    /// scrolls past on screen. Without a screen (an older daemon) the pane is blank until then.
    public func beginHistoryRestore(screen: Data?, replaySizes: [ReplaySize] = []) {
        historyRestore = nil
        let sizes = ReplaySize.validated(replaySizes)
        let (cols, rows) = (columns, rows)
        let first = sizes.first
        let restore = HistoryRestore(emulator: emulatorSync {
            $0.makeReplacement(cols: Int(first?.cols ?? UInt16(clamping: cols)),
                               rows: Int(first?.rows ?? UInt16(clamping: rows)))
        }, sizes: sizes)
        // Paint the preview at its source geometry before reflowing into this window.
        // The history emulator independently follows every recorded resize.
        let prepare: @Sendable (TerminalEmulator) -> Void = { emulator in
            if let last = sizes.last { emulator.resize(cols: Int(last.cols), rows: Int(last.rows)) }
            emulator.isReplaying = true
            emulator.feed(Data("\u{1b}c".utf8) + (screen ?? Data()))
            emulator.isReplaying = false
            emulator.resize(cols: cols, rows: rows)
        }
         emulatorState.async(prepare)
        receive(Data(), replay: true)
        historyRestore = restore
    }

    /// History for the restore `beginHistoryRestore` started, oldest first.
    public func receiveHistory(_ data: Data, sequence: UInt64 = 0,
                               onConsumed: @escaping @Sendable () -> Void = {}) {
        guard let restore = historyRestore else { onConsumed(); return }
        restore.receivedHistory = true
        restore.feedHistory(data, sequence: sequence, onConsumed: onConsumed)
    }

    /// The history has all arrived. Once the replacement has parsed it, it becomes the pane's
    /// emulator; a restore that got no history is dropped, since the screen is all there is.
    public func finishHistoryRestore() {
        guard let restore = historyRestore else { return }
        guard restore.receivedHistory else {
            historyRestore = nil
            return
        }
        restore.finish(cols: columns, rows: rows)
        restore.queue.async { [weak self] in
            DispatchQueue.main.async { self?.swapInHistoryRestore(restore) }
        }
    }

    /// Swap the replacement in where the emulator lives. Live output went to both emulators in
    /// one order, so once the replacement has parsed what it was sent the two agree on everything
    /// since the screen, and the replacement adds the history above it. Content-anchored state
    /// (scroll position from the bottom, selection, matches) stays on the same text.
    private func swapInHistoryRestore(_ restore: HistoryRestore) {
        guard historyRestore === restore else { return } // a newer attach began its own
        historyRestore = nil
        invalidateRenderGeneration(contentChanged: true)
        let state = emulatorState
        let scanState = triggerScanState
        let swap: @Sendable (TerminalEmulator) -> Int = { previous in
            restore.queue.sync {}
            let next = restore.emulator
            next.isReplaying = false
            next.takeOver(from: previous)
            state.replaceEmulator(with: next)
            let added = next.historyCount - previous.historyCount
            scanState.nextLine += added
            return added
        }

        emulatorState.async { [weak self] previous in
            let added = swap(previous)
            let next = state.emulator
            _ = state.stageMainHop(
                textContext: next.textAnchorContext(), historyCount: next.historyCount,
                modes: next.modes, altScreen: next.isAlternateScreenActive
            )
            DispatchQueue.main.async { [weak self] in
                self?.shiftBufferLines(by: added)
                self?.applyPendingMainHop()
            }
        }
    }

    /// Move everything anchored to absolute buffer lines down by `added` lines of history.
    private func shiftBufferLines(by added: Int) {
        invalidateFindContent() // The replacement may have landed after an AX getter cached the old grid.
        guard added != 0 else { return }
        findMatches = findMatches.map { $0.shifted(by: added) }
        triggerHighlightMatches = triggerHighlightMatches.map {
            TerminalBufferMatch(bufferLine: $0.bufferLine + added, columns: $0.columns)
        }
        if var mode = copyMode {
            mode.cursor.line += added
            mode.anchor?.line += added
            mode.viewTop += added
            for index in mode.search.matches.indices { mode.search.matches[index].line += added }
            copyMode = mode
        }
        scheduleRender()
    }

    func testingReadGridSnapshot() -> TerminalGridSnapshot {
        emulatorSync { $0.readGrid() }
    }

    nonisolated static func testingSelectedText(_ selection: TerminalSelection, emulator: TerminalEmulator) -> String {
        selectedText(selection, emulator: emulator)
    }

    func testingWaitForEmulatorIdle() {
        // Drain the parse queue AND apply any staged main hop — tests call this in place of
        // spinning the runloop, so the mirrors (incl. modes/alt-screen, smooth scrolling clamps
        // against `historyCountMirror`) must not lag the drained state. The already-queued
        // main.async hop then no-ops (the hop was consumed here).
        var history = 0
        repeat { history = emulatorState.sync { $0.historyCount } }
        while outputReceiver.hasPendingWork
        // Restore parsing has its own queue. Drain it too before tests wait for the main
        // swap callback, rather than relying on a fixed number of run-loop turns.
        historyRestore?.queue.sync {}
        applyPendingMainHop()
        historyCountMirror = history
    }

    func testingInputModes() -> TerminalModes { inputModes() }

    func testingPasteText(_ raw: String) { pasteText(raw) }

    /// The window-space center of a grid cell, offset by `dx`/`dy` points.
    func testingWindowPoint(row: Int, column: Int, dx: CGFloat = 0, dy: CGFloat = 0) -> NSPoint? {
        guard let rect = cellRect(row: row, columns: column ..< column + 1) else { return nil }
        return convert(CGPoint(x: rect.midX + dx, y: rect.midY + dy), to: nil)
    }

    /// ⌘-hover the center of a grid cell. Returns false when the cell has no on-screen rect.
    @discardableResult
    func testingCommandHover(row: Int, column: Int) -> Bool {
        guard let point = testingWindowPoint(row: row, column: column) else { return false }
        updateLinkHover(at: point, modifiers: .command)
        return true
    }

    var testingHoveredLink: (row: Int, columns: Range<Int>)? { hoveredLink }

    var testingHistoryRestorePending: Bool { historyRestore != nil }

    /// Test seam: drive the window-key half of `effectivelyFocused` (the real value comes from
    /// `NSWindow` key-state notifications, which are awkward to trigger headlessly). Mirrors the
    /// `didBecomeKey`/`didResignKey` observers — set the flag, then re-evaluate focus state.
    func testingSetWindowIsKey(_ isKey: Bool) {
        windowIsKey = isKey
        focusStateChanged()
    }

    func testingResizeGrid(cols: Int, rows: Int) {
        commitGridSize(cols: cols, rows: rows)
        // The commit stages the reflow for the next output/commit build to materialize; headless
        // there is no renderer, so no build ever runs — apply the staged target directly (the
        // exact step the first build performs) so tests observe the resize synchronously.
        let state = emulatorState.sync { emulator in
            _ = emulatorState.applyPendingResize()
            return (emulator.historyCount, emulator.textAnchorContext())
        }
        historyCountMirror = state.0
        textAnchorContext = state.1
    }

    var testingRenderSynchronized: Bool { scheduler.synchronized }
    var testingRenderPending: Bool { scheduler.needsRender }
    var testingFontThickenConfiguration: (enabled: Bool, strength: Int) {
        (fontThicken, fontThickenStrength)
    }

    // Live-resize seams (glitchless-resize behavior is asserted headlessly: no window, no Metal).
    var testingPresentsWithTransaction: Bool { metalLayer.presentsWithTransaction }
    var testingLiveResizeFrozenOrigin: (x: Int, y: Int)? { liveResizeFrozenOrigin }
    var testingGridSize: (cols: Int, rows: Int) { (columns, rows) }
    var testingHasPendingResizeCommit: Bool { resizeCommitWork != nil }
    func testingScheduleResizeCommit(cols: Int, rows: Int) { scheduleResizeCommit(cols: cols, rows: rows) }
    func testingRequestLiveResizeCommit(cols: Int, rows: Int) { requestLiveResizeCommit(cols: cols, rows: rows) }
    func testingSetLiveResizeReflow(_ enabled: Bool) { liveResizeReflowEnabled = enabled }
    var testingLiveResizeReflowEnabled: Bool { liveResizeReflowEnabled }
    var testingLastSentPTYSize: (cols: Int, rows: Int)? { lastSentPTYSize }
    func testingMarkGridSized() { hasSizedGrid = true }
    // pendingResize seams: the staged-but-unapplied reflow target, a direct driver for the
    // scheduler's async off-main entry (what a PTY output burst triggers mid-drag), and a queue
    // gate for staging deterministic build interleavings (e.g. an output build superseding a
    // commit build's frame token while both sit queued).
    var testingPendingResize: (cols: Int, rows: Int)? { emulatorState.pendingResizeForTesting() }
    func testingRenderNowOffMainAsync() { renderNowOffMain() }
    func testingBlockDrawableQueue(_ block: @escaping @Sendable () -> Void) {
        drawableQueue.async(execute: block)
    }
    var testingDrawableAcquisitionQueue: DispatchQueue { drawableAcquisitionQueue }
    var testingMetalLayer: CAMetalLayer { metalLayer }
    var testingRendererIdentity: ObjectIdentifier? { renderer.map(ObjectIdentifier.init) }
    var testingDrawableRequestInFlight: Bool { drawableRequestInFlight }
    /// Join each queue and its main completion without blocking main behind drawable acquisition.
    func testingDrainRenderPipeline(passesLeft: Int = 8, _ completion: @escaping @MainActor @Sendable (Bool) -> Void) {
        emulatorState.async { [weak self] _ in
            DispatchQueue.main.async {
                guard let self else { completion(true); return }
                self.drawableAcquisitionQueue.async {
                    DispatchQueue.main.async {
                        guard let executor = self.renderExecutor else { completion(true); return }
                        executor.async { _ in
                            DispatchQueue.main.async {
                                let idle = !self.drawableRequestInFlight && self.pendingDrawableFrame == nil
                                if !idle, passesLeft > 1 {
                                    self.testingDrainRenderPipeline(passesLeft: passesLeft - 1, completion)
                                } else { completion(idle) }
                            }
                        }
                    }
                }
            }
        }
    }
    func testingBlockEmulatorQueue(until gate: DispatchSemaphore) {
        emulatorState.async { _ in gate.wait() }
    }
    // Window-hosted seams (the routing test drives real presents through a real Metal renderer).
    var testingOriginOffset: (x: Int, y: Int) { (originOffsetX, originOffsetY) }
    var testingHasRenderer: Bool { renderer != nil }
    var testingLastPresentScheduleNanos: UInt64 { renderExecutor?.sync { $0.stats.presentScheduleNanos } ?? 0 }
    // Full renderer stats for the frame-pacing harness (encodedRows/reusedRows/uploadBytes/...).
    var testingLastRenderStats: TerminalRenderStats? { renderExecutor?.sync { $0.stats } }
    var testingRepaintCacheCoherent: Bool { lastPresentedResultIsRendererCoherent }
    func testingRepaintLastFrame() -> Bool { repaintLastFrame() }
    // Async resize-preview seams: the current drag target the next landing preview must match,
    // and the renderer's device-pixel cell metrics (for stepping exactly one cell in benchmarks).
    var testingPreviewTarget: (cols: Int, rows: Int) { (previewCols, previewRows) }
    var testingCellPixelSize: (width: Int, height: Int) {
        (renderer?.cellPixelWidth ?? 0, renderer?.cellPixelHeight ?? 0)
    }
    /// Drive `presentResizePreview` directly with explicit (possibly stale) args — the main-hop
    /// guards only fire under racy interleavings production tests can't stage deterministically.
    /// Builds the preview synchronously, then lands it with the given token/target. Returns
    /// whether it was accepted (false = the guards dropped it).
    func testingPresentResizePreview(cols: Int, rows: Int, token: UInt64) -> Bool {
        let config = frameBuildConfiguration
        let bg = canvasBackground
        let fg = canvasForeground
        let opacity = canvasOpacity
        let generation = renderGeneration
        let result: SurfaceFrameBuildResult? = emulatorState.sync { emulator in
            guard let preview = emulator.previewViewportReflow(cols: cols, rows: rows) else { return nil }
            let reverseVideo = emulator.modes.reverseVideo
            let builder = config.makeBuilder(reverseVideo: reverseVideo)
            let frame = builder.buildDirect(preview, region: nil, imageProvider: { emulator.image(for: $0) })
            return SurfaceFrameBuildResult(
                generation: generation, frame: frame, damage: nil,
                frameBuildNanos: 0, clearColor: builder.renderColor(reverseVideo ? fg : bg, alpha: opacity)
            )
        }
        guard let result else { return false }
        return presentResizePreview(result, cols: cols, rows: rows, token: token)
    }
    func testingClaimPreviewToken() -> UInt64 { emulatorState.claimPreviewToken() }
    var testingRenderGeneration: UInt64 { renderGeneration }
    /// Neutralize the armed 60ms resize-commit debounce (matches `viewDidEndLiveResize`'s cancel
    /// semantics) so timing-sensitive assertions don't race it.
    func testingCancelPendingResizeCommit() {
        resizeCommitWork?.cancel()
        resizeCommitWork = nil
    }
    // Scroll-reuse seams: drive a synchronous build+present and a scrollback scroll headlessly.
    func testingForceRender() { scheduler.forceRender() }
    /// Programmatic selection for the cell-overlay tests (a mouse drag's end state). Takes
    /// VIEWPORT rows like a real drag and converts to the absolute buffer anchors `mouseDown`
    /// would store.
    func testingSetSelection(
        anchor: (row: Int, column: Int)?, head: (row: Int, column: Int)?, rectangular: Bool = false
    ) {
        let top = viewportTopBufferLine
        selectionAnchor = anchor.map { (line: top + $0.row, column: $0.column) }
        selectionHead = head.map { (line: top + $0.row, column: $0.column) }
        selectionRectangular = rectangular
        selectionGranularity = .character
        scheduleRender()
    }
    /// The active selection's extracted text (nil when nothing is selected) — the #161 seam:
    /// content-anchored selections must extract the same text before and after scrolling.
    func testingSelectionText() -> String? { selectionTextIfAny() }
    func testingSetSelectionColors(
        background: HarnessTheme.RGBColor?, foreground: HarnessTheme.RGBColor?
    ) {
        selectionBackground = background
        frameBuildConfiguration.selectionBackground = background
        frameBuildConfiguration.selectionForeground = foreground
    }
    func testingMakeFrameBuilder() -> FrameBuilder { frameBuildConfiguration.makeBuilder() }
    var testingLastPresentedFrame: TerminalFrame? { lastPresentedResult?.frame }
    var testingLastPresentedDamage: TerminalDamage? { lastPresentedResult?.damage }
    func testingSetWindowOccluded(_ occluded: Bool) { setWindowOccluded(occluded) }
    var testingIsOccluded: Bool { scheduler.isOccluded }
    // Smooth-scroll seams: continuous (sub-line) scrolling and the resulting offset/fraction split.
    func testingScrollByContinuous(lines: CGFloat) { scrollByContinuous(lines: lines) }
    var testingScrollPosition: (offset: Int, fraction: CGFloat) { (scrollOffset, scrollFraction) }
    // Drive one display-cadence tick (the scheduler's ASYNC render entry — the path the live-drag
    // hold defers); tests use it where the real CADisplayLink would fire.
    @discardableResult
    func testingSchedulerTick() -> Bool { scheduler.tick() }
    func testingScrollBy(lines: Int) { scrollBy(lines: lines) }

    /// The full appearance the host computes from settings + theme:
    /// - `canvasBackground/Foreground/cursor` come from `ThemeManager.resolvedCanvas`, so
    ///   the terminal canvas matches the chrome (no seam) regardless of theme-output mode.
    /// - `outputPalette` is the 16 ANSI colors for *program output*: the theme palette when
    ///   "apply theme to output" is on, otherwise the untouched default palette.
    /// - `canvasOpacity` < 1 makes the canvas translucent for the window blur.
    /// Rebuilds the renderer/atlas (font/colorspace) and the color resolver.
    /// Everything `configureAppearance` was last called with. A sync re-applies settings and
    /// theme to every pane; when nothing changed, the renderer (pipelines, glyph atlas) stays.
    private struct AppearanceInputs: Equatable {
        var fontFamily: String
        var fontFallbackFamilies: [String]
        var fontFeatures: [String: Int]
        var fontSize: CGFloat
        var vivid: Bool
        var colorRendering: TerminalColorRenderingMode?
        var colorGamut: TerminalColorGamut
        var canvasBackgroundHex: String
        var canvasForegroundHex: String
        var cursorHex: String
        var outputPaletteHex: [String?]
        var oscPaletteHex: [String?]?
        var canvasOpacity: Float
        var cursorStyle: String
        var cursorBlink: Bool
        var paddingX: CGFloat
        var paddingY: CGFloat
        var paddingBalance: Bool
        var selectionBackgroundHex: String?
        var selectionForegroundHex: String?
        var cursorTextHex: String?
        var copyOnSelect: Bool
        var pasteProtection: Bool
        var scrollbackLines: Int
        var linearBlending: Bool
        var textRendering: TerminalTextRenderingMode?
        var ligatures: Bool
        var minimumContrast: Double
        var themeFit: Bool
        var boldIsBright: Bool
        var promptGutter: Bool
        var liveResizeReflow: Bool
    }

    private var appliedAppearance: AppearanceInputs?

    public func configureAppearance(
        fontFamily: String,
        fontSize: CGFloat,
        fontFallbackFamilies: [String] = [],
        fontFeatures: [String: Int] = [:],
        vivid: Bool,
        colorRendering: TerminalColorRenderingMode? = nil,
        colorGamut: TerminalColorGamut = .auto,
        canvasBackgroundHex: String,
        canvasForegroundHex: String,
        cursorHex: String,
        outputPaletteHex: [String?],
        oscPaletteHex: [String?]? = nil,
        canvasOpacity: Float,
        cursorStyle: String,
        cursorBlink: Bool,
        paddingX: CGFloat,
        paddingY: CGFloat,
        paddingBalance: Bool = true,
        selectionBackgroundHex: String?,
        selectionForegroundHex: String?,
        cursorTextHex: String? = nil,
        copyOnSelect: Bool,
        pasteProtection: Bool = true,
        scrollbackLines: Int,
        linearBlending: Bool,
        textRendering: TerminalTextRenderingMode? = nil,
        ligatures: Bool,
        minimumContrast: Double = 1,
        themeFit: Bool = false,
        boldIsBright: Bool = true,
        promptGutter: Bool = false,
        liveResizeReflow: Bool = true
    ) {
        let inputs = AppearanceInputs(fontFamily: fontFamily, fontFallbackFamilies: fontFallbackFamilies, fontFeatures: fontFeatures, fontSize: fontSize, vivid: vivid, colorRendering: colorRendering, colorGamut: colorGamut, canvasBackgroundHex: canvasBackgroundHex, canvasForegroundHex: canvasForegroundHex, cursorHex: cursorHex, outputPaletteHex: outputPaletteHex, oscPaletteHex: oscPaletteHex, canvasOpacity: canvasOpacity, cursorStyle: cursorStyle, cursorBlink: cursorBlink, paddingX: paddingX, paddingY: paddingY, paddingBalance: paddingBalance, selectionBackgroundHex: selectionBackgroundHex, selectionForegroundHex: selectionForegroundHex, cursorTextHex: cursorTextHex, copyOnSelect: copyOnSelect, pasteProtection: pasteProtection, scrollbackLines: scrollbackLines, linearBlending: linearBlending, textRendering: textRendering, ligatures: ligatures, minimumContrast: minimumContrast, themeFit: themeFit, boldIsBright: boldIsBright, promptGutter: promptGutter, liveResizeReflow: liveResizeReflow)
        guard inputs != appliedAppearance else { return }
        appliedAppearance = inputs
        liveResizeReflowEnabled = liveResizeReflow
        // `scrollbackLines == 0` stays the unlimited sentinel on the wire. `historyLineCap`
        // turns that 0-byte budget into the daemon's finite safety ceiling.
        let daemonBytes = TerminalHostView.scrollbackBytes(forLines: scrollbackLines)
        let lineCap = TerminalHostView.historyLineCap(daemonScrollbackBytes: daemonBytes)
        emulatorSync { $0.maxScrollbackLines = lineCap }

        let resolvedColorRendering = colorRendering ?? (vivid ? .vivid : .accurate)
        let resolvedGamut = TerminalColorGamut.resolved(
            renderingMode: resolvedColorRendering,
            requested: colorGamut
        )
        let resolvedTextRendering = textRendering ?? (linearBlending ? .crisp : .native)
        glyphGamma = resolvedTextRendering.glyphGamma
        fontThicken = resolvedTextRendering == .crisp
        fontThickenStrength = 255
        ligaturesEnabled = ligatures
        promptGutterEnabled = promptGutter
        let bg = RGBColor(hex: canvasBackgroundHex) ?? RGBColor(red: 0, green: 0, blue: 0)
        let fg = RGBColor(hex: canvasForegroundHex) ?? RGBColor(red: 255, green: 255, blue: 255)
        let cursor = RGBColor(hex: cursorHex) ?? fg
        // Selection background: explicit setting/theme value, else a neutral slate.
        let selBg = selectionBackgroundHex.flatMap { RGBColor(hex: $0) }
            ?? RGBColor(red: 68, green: 78, blue: 102)
        let selFg = selectionForegroundHex.flatMap { RGBColor(hex: $0) }
        // Cursor-text (the glyph under a block cursor); nil falls back to the canvas bg.
        let cursorText = cursorTextHex.flatMap { RGBColor(hex: $0) }
        // 16 ANSI colors for program output; nil slots fall back to the default palette.
        let palette: [RGBColor] = (0 ..< 16).map { i in
            let hex = (i < outputPaletteHex.count ? outputPaletteHex[i] : nil)
                ?? ThemeManager.defaultBaselinePaletteHex[i]
            return RGBColor(hex: hex) ?? RGBColor(red: 0, green: 0, blue: 0)
        }
        let queryPalette: [RGBColor] = (0 ..< 16).map { i in
            let hex = (oscPaletteHex.flatMap { i < $0.count ? $0[i] : nil })
                ?? (i < outputPaletteHex.count ? outputPaletteHex[i] : nil)
                ?? ThemeManager.defaultBaselinePaletteHex[i]
            return RGBColor(hex: hex) ?? RGBColor(red: 0, green: 0, blue: 0)
        }
        self.fontFamily = fontFamily
        self.fontFallbackFamilies = fontFallbackFamilies
        self.fontFeatures = fontFeatures
        self.fontSize = fontSize
        self.colorRendering = resolvedColorRendering
        self.colorGamut = resolvedGamut
        self.canvasBackground = bg
        self.canvasForeground = fg
        self.canvasCursor = cursor
        self.ansiPalette16 = palette
        self.canvasOpacity = max(0, min(1, canvasOpacity))
        self.cursorStyle = CursorStyle(rawValue: cursorStyle) ?? .block
        self.cursorBlinkEnabled = cursorBlink
        self.paddingPointsX = max(0, paddingX)
        self.paddingPointsY = max(0, paddingY)
        self.paddingBalanced = paddingBalance
        self.selectionBackground = selBg
        self.selectionForeground = selFg
        self.copyOnSelect = copyOnSelect
        self.pasteProtection = pasteProtection
        colorProviderState.update(foreground: fg, background: bg, cursor: cursor, palette: queryPalette)
        let resolver = CellColorResolver(
            palette: ANSIPalette(base16: palette),
            defaultForeground: fg,
            defaultBackground: bg,
            boldBrightens: boldIsBright,
            minimumContrast: minimumContrast,
            themeFit: themeFit,
            themeFitTarget: fg
        )
        self.frameBuildConfiguration = SurfaceFrameBuildConfiguration(
            resolver: resolver,
            cursorColor: cursor,
            cursorTextColor: cursorText,
            canvasOpacity: self.canvasOpacity,
            colorRendering: resolvedColorRendering,
            colorGamut: resolvedGamut,
            cursorStyle: self.cursorStyle,
            selectionBackground: selBg,
            selectionForeground: selFg,
            promptGutterEnabled: promptGutterEnabled
        )
        // Resolved colors/opacity changed — cached rows hold the old palette; force a full rebuild.
        emulatorState.resetPlainFrame()
        invalidateRenderGeneration()
        restartBlinkTimer()
        // Opaque only when fully opaque; otherwise the layer must be non-opaque so the
        // window-wide blur shows through the translucent canvas.
        metalLayer.isOpaque = self.canvasOpacity >= 1
        metalLayer.colorspace = CGColorSpace(name: layerColorSpaceName)
        buildRenderer()
        updateGridSize()
        scheduleRender()
    }

    // MARK: - Setup

    func emulatorSync<T>(_ body: (TerminalEmulator) -> T) -> T {
        emulatorState.sync(body)
    }

    /// Snapshot the buffer text + cursor position for the accessibility (VoiceOver) layer, taken
    /// atomically under the one emulator-access seam. Lives here (not the `+Accessibility` extension)
    /// because `emulatorSync` is file-private. Lines are the full scrollback + screen, so VoiceOver
    /// can review history; the cursor line is offset past the scrollback so it indexes those lines.
    func accessibilitySnapshot() -> (lines: [String], cursorLine: Int, cursorColumn: Int) {
        let state = accessibleState()
        return (state.text.lines, state.cursorLine, state.cursorColumn)
    }

    /// The accessibility snapshot rebuilt now, ignoring the reuse window.
    func testingFreshAccessibilitySnapshot() -> (lines: [String], cursorLine: Int, cursorColumn: Int) {
        accessibleCache = nil
        return accessibilitySnapshot()
    }

    func accessibleState() -> (text: TerminalAccessibilityText, cursorLine: Int, cursorColumn: Int, visible: NSRange) {
        // The revision moves on every output chunk, and one VoiceOver action asks for several
        // attributes. Rebuilding the whole buffer for each would cost O(history) per query while
        // output streams, and could answer one action from different snapshots. A stale cache
        // younger than `accessibleCacheLifetime` is reused instead.
        let now = ProcessInfo.processInfo.systemUptime
        if accessibleCache?.revision != findContentRevision,
           accessibleCache == nil || now - accessibleCacheBuiltAt >= Self.accessibleCacheLifetime {
            accessibleCacheBuiltAt = now
            testingAccessibleRebuildCount += 1
            let (snapshot, cursor) = emulatorSync { ($0.textSnapshot(), $0.readGrid().cursor) }
            var mapped: [TerminalMappedText] = []
            mapped.reserveCapacity(snapshot.lineCount)
            for line in 0..<snapshot.lineCount {
                var row = TerminalMappedText()
                var cells = snapshot.line(line)
                while let last = cells.last, last.width != .spacerTail,
                      (last.codepoint == 0 || last.codepoint == 32), last.combining0 == 0 {
                    cells.removeLast()
                }
                row.append(cells, line: line, clusters: snapshot.clusters)
                mapped.append(row)
            }
            accessibleCache = (findContentRevision, TerminalAccessibilityText(mappedLines: mapped),
                               snapshot.historyCount + cursor.row, cursor.col, snapshot.historyCount)
        }
        let cache = accessibleCache!
        let top = max(0, cache.history - scrollOffset)
        let start = cache.text.characterRange(forLine: top)?.location ?? 0
        let bottom = cache.text.characterRange(forLine: min(cache.text.lineCount - 1, top + rows - 1))
        let end = bottom.map(NSMaxRange) ?? start
        return (cache.text, cache.cursorLine, cache.cursorColumn, NSRange(location: start, length: max(0, end - start)))
    }

    func accessibleSelectionRanges() -> [NSRange] {
        let state = accessibleState()
        guard let raw = currentRawSelection else {
            return [NSRange(location: state.text.characterIndex(line: state.cursorLine, column: state.cursorColumn), length: 0)]
        }
        let selection = emulatorSync { Self.resolveAbsoluteSelectionRegion(raw, emulator: $0, columns: columns) }
        func range(_ row: Int, _ first: Int, _ lastRow: Int, _ last: Int) -> NSRange {
            let start = state.text.characterIndex(line: row, column: first)
            let end = state.text.characterIndex(line: lastRow, column: last + 1)
            return NSRange(location: start, length: max(0, end - start))
        }
        switch selection {
        case let .linear(s): return [range(s.startRow, s.startColumn, s.endRow, s.endColumn)]
        case let .block(b): return (b.startRow...b.endRow).map { range($0, b.startColumn, $0, b.endColumn) }
        case nil: return []
        }
    }

    /// How this pane draws, for thumbnails of it and of panes no window has mounted. This and
    /// `thumbnail(_:)` live here (not `TerminalThumbnail.swift`) because they read private state.
    public var thumbnailStyle: TerminalThumbnailStyle {
        let configuration = frameBuildConfiguration
        return TerminalThumbnailStyle(
            makeBuilder: { configuration.makeBuilder(reverseVideo: $0) },
            canvasBackground: canvasBackground,
            canvasForeground: canvasForeground,
            canvasOpacity: canvasOpacity,
            font: .init(family: fontFamily, size: fontSize, thicken: fontThicken, thickenStrength: fontThickenStrength, fallbackFamilies: fontFallbackFamilies, features: fontFeatures),
            gamma: glyphGamma,
            ligatures: ligaturesEnabled,
            colorSpaceName: layerColorSpaceName as String
        )
    }

    /// The live screen as a thumbnail draws it, built on the emulator's queue (behind any output
    /// still parsing) and handed back on main. A read: no damage is consumed, nothing is resized,
    /// and nothing reaches the PTY.
    public func thumbnail(_ done: @escaping @MainActor @Sendable (TerminalThumbnail) -> Void) {
        let style = thumbnailStyle

        emulatorState.async { emulator in
            let thumbnail = style.thumbnail(of: emulator)
            DispatchQueue.main.async { done(thumbnail) }
        }
    }

    /// Main-thread mirror of the emulator state the *input* paths need (key/mouse/paste encoding),
    /// refreshed by every parsed chunk's main hop in `receiveOffMain`. Reading the mirror keeps a
    /// keystroke from doing a `queue.sync` against the parser — a held arrow key must never stall
    /// the main thread behind a busy parse. At most one in-flight chunk stale, the same window the
    /// old synchronous read had (those bytes were simply still unparsed then). Defaults match a
    /// fresh `TerminalEmulator`, so reads before the first output are correct.
    private var inputModesMirror = TerminalModes()
    private var altScreenMirror = false
    /// History line count, same mirror discipline: smooth scrolling clamps against it on EVERY
    /// precise wheel event (sub-line deltas included), so the clamp must not `queue.sync` behind
    /// a busy parse — that per-event stall is the scroll-jank class. At most one chunk stale;
    /// history only moves via parsed output, and the output-pinning hop re-aligns the offset with
    /// the real count anyway, so a momentarily-short clamp self-corrects on the next event.
    var historyCountMirror = 0

    /// The terminal modes input encoding should honor right now (mirror on the off-main pipeline;
    /// never a synchronous parser read).
    func inputModes() -> TerminalModes {
        inputModesMirror
    }

    /// Whether the alternate screen is active, for input-side decisions (alternate scroll).
    func inputAltScreenActive() -> Bool {
        altScreenMirror
    }

    private func invalidateRenderGeneration(contentChanged: Bool = false) {
        if contentChanged { invalidateFindContent() }
        renderGeneration &+= 1
        emulatorState.resetPlainFrame()
        lastPresentedResultIsRendererCoherent = false
        // The blink-scan cache describes the last PRESENTED frame; invalidation makes that
        // frame garbage (theme/font change, window detach), so the occlusion path must not
        // re-arm the text-blink timer from it. Conservative false — every invalidating site
        // schedules a render, and that present recomputes the truth.
        lastFrameHadBlink = false
    }

    private func configureLayer() {
        // Layer-hosting: assign the custom layer before enabling wantsLayer.
        layer = metalLayer
        wantsLayer = true
        metalLayer.device = renderer?.device ?? MTLCreateSystemDefaultDevice()
        metalLayer.pixelFormat = TerminalMetalRenderer.pixelFormat
        metalLayer.framebufferOnly = true
        metalLayer.isOpaque = canvasOpacity >= 1
        // Double-buffer (default is 3): triple-buffering adds up to one extra frame of swap latency,
        // which matters for keystroke echo. 2 still lets the next frame render while the current one
        // scans out. Kept in lockstep with the renderer's `maxFramesInFlight` (also 2) so the in-flight
        // semaphore and the drawable pool advertise the same depth — a deeper semaphore would just
        // block on `nextDrawable()` anyway. Keep `allowsNextDrawableTimeout` on (the default): both
        // regular presents acquire drawables on the render queue; transaction-mode resize
        // acquires on main. A timeout bounds compositor stalls; failed acquisition uses
        // an exponential retry deadline instead of waking at display rate.
        metalLayer.maximumDrawableCount = 2
        metalLayer.allowsNextDrawableTimeout = true
        // Pin the grid to the top-left so any sub-cell remainder from flooring rows/cols
        // parks at the bottom-right instead of being centered into a hairline seam at the
        // top edge during live resize.
        metalLayer.contentsGravity = .topLeft
        // Tag the layer to match the frame builder's RGB output. Accurate mode stays sRGB;
        // vivid mode converts authored sRGB into Display-P3 before tagging the layer P3.
        metalLayer.colorspace = CGColorSpace(name: layerColorSpaceName)
        // Link-hover underline: a thin sublayer composited above the terminal content.
        linkUnderlineLayer.isHidden = true
        linkUnderlineLayer.backgroundColor = NSColor.linkColor.cgColor
        metalLayer.addSublayer(linkUnderlineLayer)
        // Visual-bell flash: a full-surface sublayer above the content, hidden at rest.
        bellFlashLayer.isHidden = true
        bellFlashLayer.opacity = 0
        metalLayer.addSublayer(bellFlashLayer)
        installIslandCornerMask()
    }

    /// A detached layer otherwise retains its full-size drawable pool for the pane's lifetime.
    /// Replacing that owner releases the pool after its old requests and GPU work finish, while
    /// the renderer/atlas stay warm. Two fixed lanes bound outstanding waits across fast remounts.
    private func releaseDrawablePool() {
        guard !drawablePoolReleased else { return }
        drawablePoolReleased = true
        cancelDrawableRetry()
        invalidateRenderGeneration()
        pendingDrawableFrame = nil
        pendingDrawableNeedsFullDamage = false
        drawableRequestInFlight = false
        activeDrawableRequest?.cancel()
        activeDrawableRequest = nil
        lastPresentedResult = nil
        let previous = metalLayer
        metalLayer = CAMetalLayer()
        metalLayer.frame = previous.frame
        metalLayer.bounds = previous.bounds
        metalLayer.contentsScale = previous.contentsScale
        metalLayer.drawableSize = previous.drawableSize
        drawableAcquisitionLane = (drawableAcquisitionLane + 1) % drawableAcquisitionQueues.count
        linkUnderlineLayer.removeFromSuperlayer()
        bellFlashLayer.removeFromSuperlayer()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        configureLayer()
        CATransaction.commit()
    }

    /// Round the bottom corners of the metal drawable so a split island reads as a
    /// rounded surface. The top edge stays square: it meets the identity header.
    public func applyIslandCornerRadius(_ radius: CGFloat) {
        islandCornerRadius = max(0, radius)
        installIslandCornerMask()
    }

    private func installIslandCornerMask() {
        metalLayer.cornerRadius = islandCornerRadius
        metalLayer.masksToBounds = islandCornerRadius > 0
        // Circular to match the island and the gutter fill around it.
        metalLayer.cornerCurve = .circular
        metalLayer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }

    /// Visual bell — a brief theme-foreground flash over the surface (the `visual` channel of the
    /// `bellMode` setting / tmux `visual-bell`). Composites a translucent sublayer above the Metal
    /// content and fades it out; the terminal content underneath is untouched. Re-entrant safe: a
    /// second bell mid-fade just restarts the animation. Must be called on the main thread.
    public func flashBell() {
        let c = canvasForeground
        let flash = CGColor(srgbRed: CGFloat(c.red) / 255, green: CGFloat(c.green) / 255,
                            blue: CGFloat(c.blue) / 255, alpha: 1)
        // Set geometry + color with implicit animation disabled, then run one explicit fade so a
        // resize-driven implicit bounds animation can't blur the flash.
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        bellFlashLayer.frame = bounds
        bellFlashLayer.backgroundColor = flash
        bellFlashLayer.isHidden = false
        CATransaction.commit()

        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = 0.28 // peak: visible but not a jarring full-white blink
        fade.toValue = 0
        fade.duration = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion ? 0 : 0.16
        fade.timingFunction = CAMediaTimingFunction(name: .easeOut)
        fade.isRemovedOnCompletion = true
        let token = bellFlashGeneration &+ 1
        bellFlashGeneration = token
        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
            // Only hide if no newer flash superseded this one (avoid hiding mid-restart).
            guard let self, self.bellFlashGeneration == token else { return }
            self.bellFlashLayer.isHidden = true
        }
        bellFlashLayer.opacity = 0
        bellFlashLayer.add(fade, forKey: "bellFlash")
        CATransaction.commit()
    }

    private var layerColorSpaceName: CFString {
        switch colorGamut {
        case .displayP3: return CGColorSpace.displayP3
        case .sRGB, .auto: return CGColorSpace.sRGB
        }
    }

    private func configureEmulatorCallbacks() {
        let emulator = emulatorState.emulator
        // Only the client that sizes the pane answers terminal queries (DA, DSR, Kitty acks),
        // so several attached clients don't each reply to one question.
        emulator.onResponse = { [weak self] data in
            DispatchQueue.main.async { [weak self] in
                guard let self, self.answersQueries else { return }
                self.onInput?(data)
            }

        }
        emulator.onClipboardRead = { [weak self] selection in
            DispatchQueue.main.async { [weak self] in
                guard let self, self.allowProgramClipboardRead, self.answersQueries,
                      let text = NSPasteboard.general.string(forType: .string)
                else { return }
                self.onInput?(TerminalEmulator.clipboardReply(selection: selection, text: text))
            }
        }
        emulator.onTitleChange = { [weak self] title in
            DispatchQueue.main.async { [weak self] in self?.onTitle?(title) }

        }
        emulator.onProgress = { [weak self] report in
            DispatchQueue.main.async { [weak self] in self?.onProgress?(report) }

        }
        emulator.onWorkingDirectoryChange = { [weak self] path in
            DispatchQueue.main.async { [weak self] in self?.onPwd?(path) }

        }
        emulator.onRemoteHostChange = { [weak self] host in
            DispatchQueue.main.async { [weak self] in self?.onRemoteHost?(host) }

        }
        emulator.onUserVariableChange = { [weak self] name, value in
            DispatchQueue.main.async { [weak self] in self?.onUserVar?(name, value) }

        }
        emulator.onUserVariablesCleared = { [weak self] in
            DispatchQueue.main.async { [weak self] in self?.onUserVarsCleared?() }

        }
        emulator.onBell = { [weak self] in
            DispatchQueue.main.async { [weak self] in self?.onBell?() }

        }
        emulator.onCommandFinished = { [weak self] duration, exitCode in
            DispatchQueue.main.async { [weak self] in self?.onCommandFinished?(duration, exitCode) }

        }
        emulator.onNotification = { [weak self] title, body in
            DispatchQueue.main.async { [weak self] in self?.onDesktopNotification?(title, body) }

        }
        emulator.onPointerShapeChange = { [weak self] shape in
            DispatchQueue.main.async { [weak self] in self?.applyPointerShape(shape) }

        }
        emulator.onSetClipboard = { [weak self] text in
            guard !text.isEmpty else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self, self.allowProgramClipboardAccess else { return }
                let pasteboard = NSPasteboard.general
                pasteboard.clearContents()
                pasteboard.setString(text, forType: .string)
                self.onCopy?(text)   // mirror into the daemon paste buffer, like a yank
            }

        }
        // Answer OSC 10/11/12/4 color queries from the resolved theme (light/dark detection).
        let colorProviderState = colorProviderState
        emulator.colorProvider = { role in
            colorProviderState.resolve(role)
        }
    }

    /// Set the terminal identity the engine answers in XTVERSION (`CSI > q`) and secondary DA
    /// (`CSI > c`). Resolved by the host from the `terminal-identity` option (HarnessCore
    /// `TerminalIdentity`). Mutated on the emulator's serial queue since the replies are produced
    /// while feeding output off-main.
    public func setTerminalIdentity(name: String, version: String, daVersion: Int) {
        emulatorState.sync { emulator in
            emulator.terminalName = name
            emulator.terminalVersion = version
            emulator.secondaryDAVersion = daVersion
        }
    }

    /// Program-requested mouse pointer (OSC 22); nil = system default. Applied via cursor rects.
    private var programPointerCursor: NSCursor?

    private func applyPointerShape(_ shape: String?) {
        programPointerCursor = shape.flatMap(Self.cursor(forShape:))
        window?.invalidateCursorRects(for: self)
    }

    override public func resetCursorRects() {
        if let programPointerCursor {
            addCursorRect(bounds, cursor: programPointerCursor)
        } else {
            super.resetCursorRects()
        }
        // Added last so it wins over the base/program cursor for the link's region: ⌘-hovering
        // a link shows the pointing hand, signalling it's ⌘-clickable.
        if let rect = hoveredLinkRect() {
            addCursorRect(rect, cursor: .pointingHand)
        }
    }

    /// Map a CSI/OSC-22 pointer-shape name to an `NSCursor`. Unknown shapes fall back to the
    /// system default (nil) rather than guessing.
    private static func cursor(forShape name: String) -> NSCursor? {
        switch name.lowercased() {
        case "text", "ibeam", "xterm": return .iBeam
        case "pointer", "hand", "pointinghand": return .pointingHand
        case "default", "arrow", "left_ptr": return .arrow
        case "crosshair": return .crosshair
        case "grab", "openhand": return .openHand
        case "grabbing", "closedhand": return .closedHand
        default: return nil
        }
    }

    /// Compile the terminal shaders before the first pane needs them (off the main thread).
    public nonisolated static func warmRenderer() {
        DispatchQueue.global(qos: .userInitiated).async {
            if let device = MTLCreateSystemDefaultDevice() { TerminalMetalRenderer.warm(device: device) }
        }
    }

    /// The backing scale the current renderer was built for.
    private var rendererScale: CGFloat?

    private func buildRenderer() {
        guard let device = metalLayer.device ?? MTLCreateSystemDefaultDevice() else { return }
        metalLayer.device = device
        let scale = window?.backingScaleFactor ?? 2.0
        rendererScale = scale
        renderer = TerminalMetalRenderer(
            device: device,
            fontFamily: fontFamily,
            fontSize: fontSize,
            fallbackFamilies: fontFallbackFamilies,
            features: fontFeatures,
            scale: scale,
            fontThicken: fontThicken,
            fontThickenStrength: fontThickenStrength,
            colorSpace: CGColorSpace(name: layerColorSpaceName)!
        )
        // Tell the engine the real cell pixel size so inline-image cell footprints + cursor
        // advancement match what the renderer draws.
        if let renderer {
            emulatorSync { $0.setCellPixelSize(width: renderer.cellPixelWidth, height: renderer.cellPixelHeight) }
            renderer.textBlinkHidden = textBlinkHidden // a fresh renderer adopts the current phase
            renderExecutor = SurfaceRenderExecutor(renderer: renderer, queue: drawableQueue)
        }
        invalidateRenderGeneration()
    }

    // MARK: - Layout & rendering

    // No deinit teardown for the display link: a CADisplayLink strongly retains its target, so the
    // link keeps this view alive until `stopDisplayLink()` calls `invalidate()` (which also nils
    // `renderLink`). deinit therefore only runs once the link is already gone — accessing the
    // main-actor-isolated `renderLink` from a nonisolated deinit would also be a Swift 6 error.
    // `viewDidMoveToWindow(nil)` is the teardown hook (AppKit always calls it before dealloc).

    public override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        emulatorState.setVisible(window != nil && !isHiddenOrHasHiddenAncestor)
        windowKeyObservers.forEach(NotificationCenter.default.removeObserver(_:))
        windowKeyObservers.removeAll()
        if let window {
            if !isHiddenOrHasHiddenAncestor { drawablePoolReleased = false }
            StartupMetrics.shared.mark(.firstSurfaceAttached) // idempotent: first surface in a window
            // Pick up the real backing scale. A pane remounted in the same kind of window (a
            // layout rebuild, a tab moved between windows) keeps its renderer and glyph atlas.
            if renderer == nil || rendererScale != window.backingScaleFactor {
                buildRenderer()
            } else {
                invalidateRenderGeneration()
            }
            startDisplayLink()
            updateGridSize()
            scheduleRender()
            // Track the window's key state: focus (hollow cursor, blink, DECSET 1004
            // reports) means "first responder in the key window", not just first responder.
            // Refresh it BEFORE arming the blink timer — the timer only schedules while
            // `effectivelyFocused`, which reads this flag.
            windowIsKey = window.isKeyWindow
            restartBlinkTimer()
            let nc = NotificationCenter.default
            windowKeyObservers.append(nc.addObserver(
                forName: NSWindow.didBecomeKeyNotification, object: window, queue: .main
            ) { [weak self] _ in
                MainActor.assumeIsolated {
                    guard let self else { return }
                    self.windowIsKey = true
                    self.focusStateChanged()
                }
            })
            windowKeyObservers.append(nc.addObserver(
                forName: NSWindow.didResignKeyNotification, object: window, queue: .main
            ) { [weak self] _ in
                MainActor.assumeIsolated {
                    guard let self else { return }
                    self.windowIsKey = false
                    self.focusStateChanged()
                }
            })
            // Track occlusion (covered / minimized / other Space): an invisible pane must not
            // acquire drawables or present — Apple guidance, and it keeps a backgrounded build
            // or `tail -f` from waking the GPU at full cadence. Notification-driven only, NOT
            // seeded from the current state: a window that has never been ordered on screen
            // reads as non-visible (every headless test window, and briefly during launch), and
            // gating those would be wrong — the first real occlusion change corrects any
            // attach-while-covered case.
            windowKeyObservers.append(nc.addObserver(
                forName: NSWindow.didChangeOcclusionStateNotification, object: window, queue: .main
            ) { [weak self] _ in
                MainActor.assumeIsolated {
                    guard let self, let window = self.window else { return }
                    self.setWindowOccluded(!window.occlusionState.contains(.visible))
                }
            })
            window.makeFirstResponder(self)
            focusStateChanged()
        } else {
            cancelDrawableRetry()
            // Removed from the window (pane closed / re-mounted): stop the blink timers so
            // they don't keep the run loop (and a dangling render) alive. The timers hold
            // `[weak self]`, so this is the teardown hook (no retain cycle either way).
            blinkTimer?.invalidate()
            blinkTimer = nil
            textBlinkTimer?.invalidate()
            textBlinkTimer = nil
            textBlinkHidden = false
            renderExecutor?.async { $0.textBlinkHidden = false }
            stopDisplayLink()
            releaseDrawablePool()
            // A view can leave the window MID-DRAG (tab close / pane remount during a live
            // resize) and AppKit does not guarantee `viewDidEndLiveResize` then. This instance
            // is cached and re-hosted (`TerminalPaneRegistry`), so unwind the live-resize state
            // here too — a latched `presentsWithTransaction` would route every later present
            // through the synchronous (main-blocking) path outside any resize, and a stale
            // frozen origin would mis-anchor the next layout. The pending commit is cancelled,
            // not flushed: re-attach runs `layout()`, which re-schedules a commit if the size
            // really differs.
            metalLayer.presentsWithTransaction = false
            metalLayer.maximumDrawableCount = 2 // unwind the drag-scoped third drawable too
            liveResizeFrozenOrigin = nil
            resizeCommitWork?.cancel()
            resizeCommitWork = nil
            // Drop any in-flight preview build too (the generation bump above already declines
            // its hop, but a re-attach at the SAME size would not re-bump): clear the target and
            // advance the preview token so a late landing can never stash a stale-width frame
            // into the re-hosted view.
            _ = emulatorState.claimPreviewToken()
            previewCols = 0; previewRows = 0
            // And any staged-but-unapplied resize target: re-attach runs `layout()`, which
            // commits the real size if it differs — a stale mid-drag target applying to the
            // re-hosted view would resize the grid behind that layout's back.
            emulatorState.clearPendingResize()
        }
    }

    /// Drive renders at the display's refresh rate while in a window. The link starts paused;
    /// `scheduleRender` wakes it, and `displayTick` re-pauses it once the screen is up to date, so an
    /// idle terminal costs nothing. macOS 14+ `NSView.displayLink` is the main-thread display source.
    private func startDisplayLink() {
        guard renderLink == nil else { return }
        let link = displayLink(target: self, selector: #selector(displayTick))
        link.isPaused = true
        link.add(to: .current, forMode: .common)
        renderLink = link
        applyPreferredFrameRateRange()
        scheduler.start()
    }

    /// On a variable-refresh (ProMotion) display, ask for the panel's full rate while the link is
    /// awake — the WWDC-recommended range form (min 60 lets the system adapt down for power). A
    /// no-op on fixed 60Hz panels and when the system already drives the link at native rate; the
    /// link only runs while there's pending paint, so this never holds the panel at 120Hz at idle.
    /// Re-applied on backing-property changes (the cross-monitor drag path).
    private func applyPreferredFrameRateRange() {
        guard let link = renderLink,
              let maxFPS = window?.screen?.maximumFramesPerSecond, maxFPS > 60 else { return }
        link.preferredFrameRateRange = CAFrameRateRange(
            minimum: 60, maximum: Float(maxFPS), preferred: Float(maxFPS))
    }

    private func stopDisplayLink() {
        renderLink?.invalidate()
        renderLink = nil
        scheduler.stop()
        updateAnimationWakeTimer()
    }

    /// Window visibility changed (occlusion observer / attach seed). While occluded the scheduler
    /// holds every present — dirty marks and parsing continue, so the pane stays current and
    /// costs no GPU work. On becoming visible, re-arm: any output that arrived while covered
    /// accumulated engine damage, so the next tick builds and presents one up-to-date frame.
    private func setWindowOccluded(_ occluded: Bool) {
        let hidden = occluded || isHiddenOrHasHiddenAncestor
        emulatorState.setVisible(window != nil && !hidden)
        guard hidden != scheduler.isOccluded else { return }
        scheduler.setOccluded(hidden)
        if hidden { cancelDrawableRetry() }
        // Blink timers follow visibility (idle efficiency): a covered/minimized pane has
        // nothing to blink — stop the wakeups; re-arm when it can show again.
        restartBlinkTimer()
        updateTextBlinkTimer(frameHasBlink: lastFrameHadBlink)
        updateAnimationWakeTimer()
        if !hidden { scheduleRender() }
    }

    public override func viewDidHide() {
        super.viewDidHide()
        setWindowOccluded(true)
        renderLink?.isPaused = true
        releaseDrawablePool()
    }

    public override func viewDidUnhide() {
        super.viewDidUnhide()
        if window != nil {
            drawablePoolReleased = false
            updateGridSize()
        }
        setWindowOccluded(window.map { !$0.occlusionState.contains(.visible) } ?? true)
    }

    public override func viewDidChangeBackingProperties() {
        super.viewDidChangeBackingProperties()
        // AppKit also sends this during same-scale remounts. Keep the warm atlas, and
        // never rebuild against a detached view's synthetic fallback scale.
        guard let window else { return }
        if renderer == nil || rendererScale != window.backingScaleFactor { buildRenderer() }
        applyPreferredFrameRateRange() // the view may have moved to a different-refresh display
        // Backing scale changed (e.g. the drag crossed monitors): a frozen drag origin is in
        // old-scale device pixels — drop it, recompute at the new scale, and re-freeze so the
        // rest of the drag stays anchored.
        let wasFrozen = liveResizeFrozenOrigin != nil
        liveResizeFrozenOrigin = nil
        updateGridSize()
        if wasFrozen, hasSizedGrid { liveResizeFrozenOrigin = (originOffsetX, originOffsetY) }
        scheduleRender()
    }

    /// Glitchless live resize (Hume's technique). While the user drags the window
    /// edge, the layer presents *with* the Core Animation transaction: every present becomes
    /// commit → `waitUntilScheduled()` → `drawable.present()` (see the renderer's
    /// `synchronizedWithTransaction`), so the terminal frame and the window's new frame land in
    /// the SAME transaction — content stays latched to the edge instead of lagging it by 1–2
    /// vsyncs (the judder the async present produces). The mode lives exactly as long as the
    /// drag: outside it, the async present path keeps its latency profile.
    /// `allowsNextDrawableTimeout` deliberately stays on (see `configureLayer`): a nil drawable
    /// mid-drag skips one transaction's present and self-heals on the next layout — preferable
    /// to an unbounded main-thread wait if the GPU wedges.
    public override func viewWillStartLiveResize() {
        super.viewWillStartLiveResize()
        metalLayer.presentsWithTransaction = true
        // Transaction-mode presents hand their drawable to the window server until the CA commit
        // completes, so with the steady-state pool of 2 (kept for keystroke echo latency) the
        // next drag tick parks in `nextDrawable()` for most of a frame (measured p50 ~12ms on
        // 120Hz hardware). A third drawable for the duration of the drag keeps one free while two
        // ride their transactions; the in-flight semaphore stays at 2 — GPU completion is not the
        // bottleneck here (semaphoreWait measured 0), the held presents are.
        metalLayer.maximumDrawableCount = 3
        // Anchor the grid for the whole drag; re-centered once in `viewDidEndLiveResize`.
        // Before the first real layout there's no meaningful origin to freeze — leave nil so
        // `updateGridSize` computes normally.
        liveResizeFrozenOrigin = hasSizedGrid ? (originOffsetX, originOffsetY) : nil
    }

    public override func viewDidEndLiveResize() {
        super.viewDidEndLiveResize()
        metalLayer.presentsWithTransaction = false
        metalLayer.maximumDrawableCount = 2 // restore the low-latency echo pool (see configureLayer)
        // Invalidate any in-flight preview build UNCONDITIONALLY. A live commit's generation bump
        // usually covers this, but a drag that returns to its ORIGINAL size commits nothing (no
        // bump, previewCols still holds the last intermediate target) — a slow build for that
        // intermediate width landing after release would pass every guard and stash a wrong-width
        // frame. Advancing the preview token + clearing the target makes both the on-queue skip and
        // the hop guards drop it.
        _ = emulatorState.claimPreviewToken()
        previewCols = 0; previewRows = 0
        // Unfreeze and recompute geometry/origin for the SETTLED size. With live reflow on this is
        // almost always a pure re-center — the last cell-boundary commit already reflowed + sent
        // the final size; with live reflow off it schedules the drag's one-and-only debounced
        // commit. Either mode, a release landing exactly on a not-yet-processed boundary schedules
        // a fresh commit here, flushed immediately just below.
        liveResizeFrozenOrigin = nil
        updateGridSize()
        // Flush any pending grid+PTY commit NOW: the size is settled the moment the drag ends and
        // transaction mode is off, so it lands immediately instead of waiting out the coalescing
        // delay (which exists only for *animated* resizes — sidebar slides, tiling). `perform` runs
        // it synchronously; `cancel` stops the queued asyncAfter copy from re-running it (and
        // `commitGridSize` is idempotent via its cols/rows guard anyway). Ordered AFTER
        // `updateGridSize` so a commit it just scheduled for a boundary-landing release is caught.
        if let work = resizeCommitWork {
            resizeCommitWork = nil
            work.perform()
            work.cancel()
        }
        if !repaintLastFrame() { scheduleRender() }
    }

    public override func viewWillDraw() {
        super.viewWillDraw()
        guard lastPresentedResult != nil, !scheduler.isOccluded, !metalLayer.presentsWithTransaction else { return }
        if !repaintLastFrame() { scheduleRender() }
    }

    public override func layout() {
        super.layout()
        guard window != nil, !isHiddenOrHasHiddenAncestor, !drawablePoolReleased else { return }
        // Resize the drawable and repaint in the SAME turn, with implicit animations off, so a
        // resize never shows a stale frame stretched to the new bounds (the flicker).
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        installIslandCornerMask()
        let needsFirstPaint = !hasSizedGrid
        updateGridSize()
        if needsFirstPaint {
            // First real layout: `updateGridSize` already committed the grid; build + present the
            // true frame synchronously so the terminal opens correct with no flash.
            scheduler.forceRender()
        } else if !repaintLastFrame() {
            // Resize/animation storm: re-present the cached frame at the new size — no emulator-queue
            // access, so a window drag never blocks on the output parser (the jank source). Fresh
            // output still lands between layout frames via the async display-link path. Fall back to
            // a full synchronous build only when there's no valid cached frame (e.g. generation just
            // changed via a font/theme/reflow invalidation).
            scheduler.forceRender()
        }
        CATransaction.commit()
    }

    /// Recompute columns/rows from the view size and resize the emulator + drawable.
    private func updateGridSize() {
        guard let renderer else { return }
        // A pane being removed or mounted has no drawable geometry yet. Retain its
        // last useful grid instead of voting a synthetic 1×1 PTY size; that vote
        // can otherwise survive while Overview is visible or a shell respawns.
        guard window != nil, bounds.width > 0, bounds.height > 0 else {
            resizeCommitWork?.cancel()
            resizeCommitWork = nil
            return
        }
        let scale = window?.backingScaleFactor ?? 2.0
        metalLayer.contentsScale = scale
        // Round (not floor) so the drawable exactly covers the layer's pixel area. With
        // `contentsGravity = .topLeft`, a floored (sub-pixel-short) drawable leaves a
        // transparent sliver at the right/bottom edge — a thin seam showing the blur through.
        let pixelWidth = max(1, Int((bounds.width * scale).rounded()))
        let pixelHeight = max(1, Int((bounds.height * scale).rounded()))
        metalLayer.drawableSize = CGSize(width: pixelWidth, height: pixelHeight)

        // Inset the grid by the window padding (in device pixels); the same offset is the
        // renderer's draw origin so the padding region shows the canvas color.
        let geometry = Self.computeGridGeometry(
            pixelWidth: pixelWidth, pixelHeight: pixelHeight,
            basePadX: Int((paddingPointsX * scale).rounded()),
            basePadY: Int((paddingPointsY * scale).rounded()),
            cellWidth: renderer.cellPixelWidth, cellHeight: renderer.cellPixelHeight,
            balanced: paddingBalanced,
            // The frozen origin is the live-resize signal (set in viewWillStartLiveResize,
            // cleared in viewDidEndLiveResize / detach) — NOT NSView.inLiveResize, which only
            // AppKit's drag loop sets, so the lifecycle stays directly drivable in tests.
            frozenOrigin: liveResizeFrozenOrigin
        )
        originOffsetX = geometry.originX
        originOffsetY = geometry.originY
        let newCols = geometry.cols
        let newRows = geometry.rows
        guard newCols != columns || newRows != rows else {
            // Split rebuilding can briefly shrink a reused view before restoring its bounds.
            // Its old debounce must not commit that temporary size after layout has settled.
            resizeCommitWork?.cancel()
            resizeCommitWork = nil
            if previewCols != 0, previewCols != newCols || previewRows != newRows {
                _ = emulatorState.claimPreviewToken()
                previewCols = 0; previewRows = 0
                invalidateRenderGeneration()
            }
            return
        }
        if !hasSizedGrid {
            // First real layout: size immediately so the terminal opens correct (no flash).
            hasSizedGrid = true
            commitGridSize(cols: newCols, rows: newRows)
        } else {
            // Live HUD tick: the integer cols/rows only change at cell boundaries (the drawable
            // resizes smoothly every frame), so this fires exactly when the displayed size ticks.
            onGridSizeWillChange?(newCols, newRows, false)
            if liveResizeReflowEnabled, metalLayer.presentsWithTransaction {
                // Real-time live resize : commit the authoritative reflow + PTY
                // SIGWINCH at THIS cell boundary so the running program redraws during the drag,
                // not on release. The reflow runs off-main and coalesces latest-wins, so a fast
                // drag stays cheap. The preview below still rides under it for instant feedback.
                requestLiveResizeCommit(cols: newCols, rows: newRows)
            } else {
                // Legacy / animated path (escape-hatch off, or sidebar slide / tiling which never
                // enter live resize): the drawable already resized above (smooth); defer the
                // authoritative history-wide reflow + PTY SIGWINCH until the size settles so the
                // animation can't storm the shell. Each layout reschedules, so the commit fires
                // once after the last frame.
                scheduleResizeCommit(cols: newCols, rows: newRows)
            }
            // Live re-wrap: show the *content re-wrapped* to the new width during the drag instead of
            // the old grid revealed/clipped — `previewViewportReflow` is O(visible) and non-mutating,
            // so it's affordable every cell-boundary tick. Rebuild only when the cell count changes.
            // The build is async on the emulator queue (this tick's layout re-presents the cached
            // frame at the new drawable size; the re-wrap lands on the next main hop), so a
            // boundary tick costs main no more than a sub-cell tick.
            if newCols != previewCols || newRows != previewRows {
                previewCols = newCols
                previewRows = newRows
                updateResizePreview(cols: newCols, rows: newRows)
            }
        }
    }

    /// Pure grid geometry: cols/rows from the usable (padding-inset) area plus the draw origin.
    /// Normal path: the origin is the padding inset, balanced-centered when enabled — the sub-cell
    /// remainder splits onto both sides instead of `.topLeft` gravity parking it all bottom-right;
    /// the odd pixel (integer / 2) stays bottom-right and is invisible. Recomputed even when the
    /// cell count is unchanged so a sub-cell resize re-centers on the next paint.
    /// Live drag (`frozenOrigin` non-nil): hold the drag-start origin — re-centering every
    /// sub-cell layout shifts the text ±1px per pixel of drag (visible shimmer). Clamped so a
    /// shrink can't push the grid past the drawable's right/bottom edge: the origin slides only
    /// enough to keep the last column/row visible — once per cell boundary, not every pixel.
    /// `viewDidEndLiveResize` re-centers once for the settled size. Static + pure so the headless
    /// tests cover centering/freeze/clamp without a Metal renderer.
    nonisolated static func computeGridGeometry(
        pixelWidth: Int, pixelHeight: Int,
        basePadX: Int, basePadY: Int,
        cellWidth: Int, cellHeight: Int,
        balanced: Bool,
        frozenOrigin: (x: Int, y: Int)?
    ) -> (cols: Int, rows: Int, originX: Int, originY: Int) {
        let usableWidth = max(1, pixelWidth - 2 * basePadX)
        let usableHeight = max(1, pixelHeight - 2 * basePadY)
        let cols = max(1, usableWidth / cellWidth)
        let rows = max(1, usableHeight / cellHeight)
        if let frozen = frozenOrigin {
            return (
                cols, rows,
                min(frozen.x, max(0, pixelWidth - cols * cellWidth)),
                min(frozen.y, max(0, pixelHeight - rows * cellHeight))
            )
        }
        var originX = basePadX
        var originY = basePadY
        if balanced {
            originX += (usableWidth - cols * cellWidth) / 2
            originY += (usableHeight - rows * cellHeight) / 2
        }
        return (cols, rows, originX, originY)
    }

    private func scheduleResizeCommit(cols: Int, rows: Int) {
        resizeCommitWork?.cancel()
        let work = DispatchWorkItem { [weak self] in self?.commitGridSize(cols: cols, rows: rows) }
        resizeCommitWork = work
        // ~60ms outlasts a frame cadence so it lands once the animation/drag stops, while
        // staying snappy enough that a deliberate resize feels immediate.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.06, execute: work)
    }

    /// Commit the settled size to the emulator grid (reflow) and the PTY (one SIGWINCH), then
    /// repaint. The authoritative width reflow is O(history) — tens to hundreds of ms at deep
    /// scrollback — so it runs **off the main thread**: the emulator is confined to its serial queue
    /// (so the resize serializes correctly with any in-flight output feed), and the rebuilt frame is
    /// presented on completion. Main never blocks, so a drag-release never drops a frame; the live
    /// preview (or `repaintLastFrame`) already covers the interim until the authoritative frame lands.
    private func commitGridSize(cols: Int, rows newRows: Int) {
        resizeCommitWork = nil
        // Never commit MID-DRAG (a stationary >60ms hold lets the debounce elapse): the commit
        // bumps the generation — dropping the in-flight preview — but its authoritative re-present
        // (`renderNowOffMain`) defers while the layer presents with the transaction, and with the
        // mouse still no further layout runs: the screen would freeze on a stale-generation frame
        // until the next pointer move. Re-arm instead; `viewDidEndLiveResize` clears the mode
        // FIRST and then flushes, so the commit lands exactly once at release.
        if metalLayer.presentsWithTransaction {
            scheduleResizeCommit(cols: cols, rows: newRows)
            return
        }
        guard cols != columns || newRows != rows else { return }
        let localOnly: Bool
        switch ClientResizePolicy.decide(
            owner: sizeOwner, alternateScreen: inputAltScreenActive(), rows: newRows, cols: cols
        ) {
        case .unchanged:
            return
        case .localReflow:
            localOnly = true
        case .pty:
            localOnly = false
        }
        columns = cols
        rows = newRows
        invalidateRenderGeneration(contentChanged: true) // Reflow changes text positions as well as rendering.
        lastSentPTYSize = (cols, newRows)          // keep the live-resize vote coalescer in sync
        if !localOnly {
            onResize?(cols, newRows)              // one PTY SIGWINCH (fire-and-forget). A non-owner does not ioctl.
        }
        onGridSizeWillChange?(cols, newRows, true) // settled size for the HUD
        previewCols = 0; previewRows = 0           // force the next drag to rebuild a fresh preview
        historyRestore?.resize(cols: cols, rows: newRows, localOnly: localOnly)

            // Off-main pipeline: stage the settled size and let the next build materialize it on
            // the emulator's serial queue (serialized with the output feed) — `setPendingResize`
            // enqueues ahead of the build below, and last-writer-wins overwrites any stale live
            // target still unapplied from the drag. Main never blocks on the O(history) width
            // reflow; the live preview / repaintLastFrame covers the interim. A superseding newer
            // resize drops this build's present via the generation guard, and its own build
            // applies the newest staged size.
            emulatorState.setPendingResize((cols, newRows), localOnly: localOnly)
            renderNowOffMain()

    }

    /// Real-time authoritative commit fired at EVERY cell boundary during a live drag — the counterpart to `commitGridSize`'s debounced drag-end path. It mutates the real
    /// grid (`emulator.resize`) and sends the PTY `SIGWINCH` (`onResize`) live, so interactive
    /// programs — vim/htop/btop/tmux/less, and any alternate-screen TUI the non-mutating preview
    /// cannot serve — reflow and redraw continuously instead of snapping at release.
    ///
    /// Two costs are tamed so a fast drag stays smooth:
    /// - The O(history) width reflow runs OFF-MAIN on the emulator serial queue and is coalesced
    ///   latest-wins via `renderNowOffMain`'s frame token: a drag crossing N columns runs ~1–3
    ///   reflows, not N (superseded targets skip their resize+build entirely).
    /// - The cross-process PTY vote (`onResize` → daemon ioctl → child `SIGWINCH`) fires only when
    ///   the cell count changed from `lastSentPTYSize`, so a within-column drag frame sends nothing.
    ///
    /// The rebuilt frame presents inside an explicit `CATransaction` (`flushTransaction`) so a
    /// completion landing while the mouse is held *still* (no layout pass to ride) still flushes —
    /// see `presentWithinExplicitTransaction`. Called only while `presentsWithTransaction` (a real
    /// drag) and `liveResizeReflowEnabled`; `updateGridSize` gates both.
    private func requestLiveResizeCommit(cols: Int, rows newRows: Int) {
        guard cols != columns || newRows != rows else { return }
        let localOnly: Bool
        switch ClientResizePolicy.decide(
            owner: sizeOwner, alternateScreen: inputAltScreenActive(), rows: newRows, cols: cols
        ) {
        case .unchanged:
            return
        case .localReflow:
            localOnly = true
        case .pty:
            localOnly = false
        }
        columns = cols
        rows = newRows
        // DELIBERATELY no `renderGeneration` bump here. A bump would make `layout()`'s
        // `repaintLastFrame` decline (generation mismatch) and fall to the SYNCHRONOUS `forceRender`,
        // whose `state.sync` would block main behind the in-flight O(history) reflow on the emulator
        // queue — the exact stall the off-main pipeline exists to avoid. Instead the builder-reuse
        // cache is cleared ON the queue right after the resize applies (see `applyPendingResize` at
        // the top of `renderNowOffMain`'s build), and the renderer's row cache auto-invalidates on the
        // dimension change. So between this commit and the authoritative frame landing, layout keeps
        // stretching the cached frame (the same near-free sub-cell repaint), and FIFO queue + main
        // ordering guarantees the latest target's reflow is the one that presents last.
        // PTY SIGWINCH, coalesced caller-side to distinct cell counts (the daemon does not dedupe).
        if !localOnly, lastSentPTYSize?.cols != cols || lastSentPTYSize?.rows != newRows {
            lastSentPTYSize = (cols, newRows)
            onResize?(cols, newRows)
        }
        // Clear the preview target so the next `updateResizePreview` (same boundary tick) rebuilds a
        // fresh re-wrap for this width and a stale in-flight preview can't match `previewCols`.
        previewCols = 0; previewRows = 0
        // Stage the reflow target on the queue (whichever build runs next materializes it — see
        // `pendingResize`) and present the result within an explicit CA transaction.
        historyRestore?.resize(cols: cols, rows: newRows, localOnly: localOnly)
        emulatorState.setPendingResize((cols, newRows), localOnly: localOnly)
        renderNowOffMain(flushTransaction: true)
    }

    /// Run `body` (which presents a transaction-synchronized frame) inside an explicit Core
    /// Animation transaction. With `presentsWithTransaction = true` a `drawable.present()` reaches
    /// the glass only when the enclosing transaction commits; during a live drag the only
    /// transactions are AppKit's per-frame `layout()` passes, so an off-main reflow completing while
    /// the pointer is held still would otherwise never flush (a frozen screen until the next pointer
    /// move). Wrapping the present in our own begin/commit flushes it immediately — the same
    /// mechanism `layout()` relies on (`CATransaction` at the resize site), driven from a completion
    /// handler. A no-op shape outside transaction mode (an explicit transaction around a normal
    /// async present is harmless), so the end-of-drag settle can share the path.
    private func presentWithinExplicitTransaction(_ body: () -> Void) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        body()
        CATransaction.commit()
    }

    /// Mark the surface dirty and ensure the display link is running to present it. Every code path
    /// that changes what's on screen (PTY output, blink, focus, selection, copy mode, IME, …) funnels
    /// here, so a burst coalesces to one present at the next display tick instead of one async render
    /// per call. Before the view is in a window (no link yet) this is just the dirty mark; the first
    /// `viewDidMoveToWindow`/`commitGridSize` paints via the synchronous force path.
    func scheduleRender() {
        scheduler.markDirty()
        wakeDisplayLink()
    }

    /// Resume the display link so a pending paint reaches the screen. No-op until the link exists
    /// (created on window attach).
    private func wakeDisplayLink() {
        guard window != nil, !scheduler.isOccluded, drawableRetryTimer == nil,
              !isHiddenOrHasHiddenAncestor else { return }
        renderLink?.isPaused = false
    }

    private func cancelDrawableRetry() {
        drawableRetryTimer?.invalidate()
        drawableRetryTimer = nil
        drawableRetryDelay = 0.025
    }

    private func deferDrawableRetry() {
        scheduler.markDirty()
        renderLink?.isPaused = true
        guard window != nil, !scheduler.isOccluded, !isHiddenOrHasHiddenAncestor,
              drawableRetryTimer == nil else { return }
        let timer = Timer(timeInterval: drawableRetryDelay, repeats: false) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.drawableRetryTimer = nil
                self?.wakeDisplayLink()
            }
        }
        drawableRetryDelay = min(1, drawableRetryDelay * 2)
        drawableRetryTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    /// Kitty animations play unless the user asked macOS to reduce motion; then each image stays
    /// on the frame it shows.
    private static var animatesImages: Bool { !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion }

    /// Time the next frame of the animations just presented (nil: none visible). Occlusion and
    /// detaching pause it with the rest of the scheduler.
    private func scheduleAnimationFrame(at deadline: UInt64?) {
        scheduler.setAnimationDeadline(deadline)
        updateAnimationWakeTimer()
    }

    /// A frame due within a couple of display frames keeps the display link awake; a farther one
    /// lets `displayTick` pause it and wakes it once, at the deadline, so a slow animation costs
    /// no empty ticks in between.
    private func updateAnimationWakeTimer() {
        animationWakeTimer?.invalidate()
        animationWakeTimer = nil
        let now = DispatchTime.now().uptimeNanoseconds
        if scheduler.animationDeadline != nil, scheduler.hasPendingWork(now: now) { wakeDisplayLink() }
        guard let wake = scheduler.animationWake(now: now) else { return }
        let timer = Timer(timeInterval: TimeInterval(wake - now) / 1e9, repeats: false) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.animationWakeTimer = nil
                self?.wakeDisplayLink()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        animationWakeTimer = timer
    }

    /// Display-cadence tick: present at most one coalesced frame, then pause the link when there's
    /// nothing left to draw so a quiet terminal doesn't wake the CPU every refresh.
    @objc private func displayTick() {
        scheduler.tick()
        if !scheduler.hasPendingWork() {
            renderLink?.isPaused = true
            scheduler.linkDidPause() // reopen the immediate-present path for the next arrival
        }
    }

    private func renderNow() {
        renderNowOffMain()
    }

    /// Force path builds the current frame before returning. Actual transaction-mode resize
    /// submits inline; ordinary first paint/settle uses the bounded off-main drawable pipeline.
    private func renderNowSynchronous() {
        renderNowOffMain(synchronous: true)
    }

    private func renderNowOffMain(
        synchronous: Bool = false,
        flushTransaction: Bool = false
    ) {
        guard !isHiddenOrHasHiddenAncestor else { return }
        // Live-drag hold for the scheduler's async entry — ESCAPE HATCH ONLY. With real-time
        // reflow off, the drag's contract is defer-to-release: the grid stays at its pre-drag
        // size while the re-wrap PREVIEW (a different cell count) owns the glass, so an output
        // build presenting the old-size grid mid-drag would visibly fight the preview's frame.
        // With real-time reflow ON (the default), boundary commits keep the real grid current,
        // so output builds present the same size the drag shows — they flow live (each present
        // flushes its own explicit CATransaction below), which is what keeps streaming output,
        // SIGWINCH redraws, and keystroke echo moving DURING the drag instead of one boundary
        // behind. The synchronous (layout/forceRender) entry always presents — it is a drag
        // present source; a live-resize commit (`flushTransaction`) likewise.
        if !synchronous, !flushTransaction, metalLayer.presentsWithTransaction, !liveResizeReflowEnabled {
            scheduler.markDirty()
            return
        }
        guard renderer != nil else { return }
        let generation = renderGeneration
        let state = emulatorState
        let config = frameBuildConfiguration
        let requestedViewportAnchor = viewportAnchor
        // Capture the RAW selection here (cheap, no emulator access) and resolve it on the emulator
        // queue inside the build — see `resolveSelectionRegion`. Resolving on main would `emulatorSync`
        // for a word selection and stall main behind the in-flight feed every build.
        let rawSelection = currentRawSelection
        let preedit = markedText
        let blinkSetting = cursorBlinkEnabled
        let blinkVisible = cursorBlinkVisible
        let isFocused = effectivelyFocused
        let copyModeState = copyMode
        let searchEntry = copyModeSearchEntry
        let viewRows = rows
        let viewColumns = columns
        let fg = canvasForeground
        let bg = canvasBackground
        let opacity = canvasOpacity
        let findIsActive = findActive
        let findMatchesSnapshot = findMatches
        let triggerMatchesSnapshot = triggerHighlightMatches
        let animatesImages = Self.animatesImages
        let source = ObjectIdentifier(self)
        let frameOutputGeneration = outputGeneration

        // The frame build, identical for the async (coalesced) and synchronous (forced) paths. Pure
        // over the captured value snapshot + the emulator; the only mutations are `state`'s
        // plain-frame cache and the emulator's animation playback, always on the serial queue (sync
        // runs there; async dispatches there).
        let build: @Sendable (TerminalEmulator) -> SurfaceFrameBuildResult = { emulator in
            // Materialize any staged resize on the queue right before the build so it serializes
            // with the in-flight output feed. EVERY output/commit build applies the shared target
            // (`pendingResize`): a superseded commit build (its token is no longer latest) returns
            // before this runs, and whichever build superseded it applies the staged size instead —
            // a fast drag reflows only to the latest target (intermediate column counts are never
            // materialized) and the emulator can never strand at a pre-vote size. Clearing the
            // builder-reuse caches here (on the queue, not via a main-thread generation bump) keeps
            // this build from diffing the new grid against an old-width cached frame; the renderer's
            // row cache auto-invalidates on the dimension change.
            if state.applyPendingResize() {
                state.lastPlainFrame = nil
                state.lastViewportFrame = nil
                state.lastOverlayKeys = [:]
                _ = state.stageMainHop(textContext: emulator.textAnchorContext(), historyCount: emulator.historyCount,
                                      modes: emulator.modes, altScreen: emulator.isAlternateScreenActive)
            }
            let requestedScrollOffset = requestedViewportAnchor.map { anchor in
                max(0, min(emulator.historyCount, emulator.historyCount - (anchor.position?.line ?? 0)))
            } ?? 0
            // DECSCNM: read on the emulator's queue (serialized with the feed that set it);
            // a flip arrives with full-screen damage, so the swap repaints everything.
            let reverseVideo = emulator.modes.reverseVideo
            let builder = config.makeBuilder(reverseVideo: reverseVideo)
            let frameBuildStart = DispatchTime.now().uptimeNanoseconds
            var frame: TerminalFrame
            var renderDamage: TerminalDamage?
            var scrollShift = 0
            var peekRow = false
            var nextAnimationFrame: UInt64?
            var cursorCanBlink = false
            if let cm = copyModeState {
                let offset = cm.scrollbackOffset(historyCount: emulator.historyCount)
                let grid = emulator.readGrid(scrollbackOffset: offset)
                let region: SelectionRegion? = cm.viewportSelection(rows: viewRows, columns: viewColumns).map { vs in
                    switch vs.kind {
                    case .linear:
                        return .linear(TerminalSelection((vs.startRow, vs.startColumn), (vs.endRow, vs.endColumn)))
                    case .block:
                        return .block(BlockSelection((vs.startRow, vs.startColumn), (vs.endRow, vs.endColumn)))
                    }
                }
                let hits = cm.viewportSearchHits(rows: viewRows).map { m in
                    TerminalSelection((m.line, m.startColumn), (m.line, max(m.startColumn, m.endColumn - 1)))
                }
                frame = builder.buildDirect(grid, region: region, searchHighlights: hits,
                                      copyModeCursor: cm.viewportCursor(rows: viewRows),
                                      imageProvider: { emulator.image(for: $0) })
                let statusText = searchEntry.map { (cm.search.reverse ? "?" : "/") + $0 } ?? cm.statusLine()
                Self.applyCopyModeStatus(into: &frame, text: statusText, builder: builder,
                                         selectionBackground: config.selectionBackground,
                                         canvasForeground: fg, canvasBackground: bg)
                state.lastPlainFrame = nil
                state.lastViewportFrame = nil // copy-mode frames bake overlays — not a shift source
            } else {
                // Scrolled views build with the smooth-scroll peek row appended (rows+1 tall) so
                // the fraction translate always has real content to reveal; the live view (offset
                // 0) stays byte-identical. Augmenting whenever scrolled — not just when a fraction
                // is active — keeps the frame shape uniform across the whole scrolled regime, so
                // row cache reuse keeps rotating instead of bailing on a rows mismatch.
                peekRow = requestedScrollOffset > 0
                // `gridRead` brackets boundary 1 (the engine→renderer grid snapshot) on the
                // signpost track, so a per-boundary trace can attribute build time to the
                // snapshot copy vs the RenderCell resolve that follows.
                let (snapshot, damage) = FrameSignposter.shared.interval("gridRead") {
                    () -> (TerminalGridSnapshot, TerminalDamage) in
                    let damage = emulator.consumeDamage()
                    emulator.updateRenderMirror(&state.renderMirror, damage: damage)
                    let grid = peekRow
                        ? Self.appendingPeekRow(
                            to: emulator.readGrid(scrollbackOffset: requestedScrollOffset),
                            emulator: emulator, offset: requestedScrollOffset
                        )
                        : state.renderMirror!
                    return (grid, damage)
                }
                // Kitty animations move on only for the images this frame draws; the present
                // hands their next deadline to the scheduler.
                let grid: TerminalGridSnapshot
                (grid, nextAnimationFrame) = animatesImages
                    ? emulator.animateImages(in: snapshot, now: DispatchTime.now().uptimeNanoseconds)
                    : (snapshot, nil)
                let findHits = (findIsActive
                    ? Self.viewportFindHighlights(findMatchesSnapshot, scrollOffset: requestedScrollOffset, historyCount: emulator.historyCount, rows: viewRows)
                    : [])
                    + Self.viewportFindHighlights(triggerMatchesSnapshot, scrollOffset: requestedScrollOffset,
                                                  historyCount: emulator.historyCount, rows: viewRows)
                // Resolve the selection HERE, on the emulator queue: a `.word` selection reads
                // `wordColumnRange` directly (free) instead of stalling main via `emulatorSync`, and
                // it resolves against the same emulator state this frame renders.
                let selectionRegion = Self.resolveSelectionRegion(rawSelection, emulator: emulator,
                                                                  scrollOffset: requestedScrollOffset,
                                                                  columns: viewColumns)
                let overlayFree = selectionRegion == nil && preedit.isEmpty && findHits.isEmpty
                // The LIVE view (offset 0) always builds CLEAN: selection/find/preedit are
                // re-shaded onto a copy after the reuse caches are updated (the cell-overlay
                // pass below), so they ride damage-driven incremental builds instead of forcing
                // a full rebuild every frame for their whole duration. Scrolled views keep the
                // baked full-rebuild path (overlay coordinates while scrolled are rarer and not
                // worth the extra path).
                let plain = requestedScrollOffset == 0
                // Scroll-delta fast path: a pure scrollback scroll (the offset changed, nothing
                // else did — no output since the last overlay-free frame, no overlays now) is the
                // previous viewport shifted by the offset delta. Only newly exposed rows
                // are resolved; `scrollShift` + the exposed-row damage let the renderer
                // rotate its row cache the same way. This covers k→k′ scrolls AND the 0→k / k→0
                // transitions (landing at 0 yields a byte-identical plain frame, so the plain
                // cache below stays coherent). `damage.rows.isEmpty` is the no-output guard —
                // cursor moves list their rows there, so they conservatively take the full path.
                let scrollDelta = requestedScrollOffset - state.lastViewportOffset
                frame = builder.buildDirect(
                    grid, region: plain ? nil : selectionRegion,
                    searchHighlights: plain ? [] : findHits,
                    imageProvider: { emulator.image(for: $0) }
                )
                if overlayFree, scrollDelta != 0, damage.rows.isEmpty, !damage.full,
                   state.lastViewportGeneration == generation,
                   let previous = state.lastViewportFrame,
                   previous.columns == grid.cols, previous.rows == grid.rows,
                   abs(scrollDelta) < grid.rows, previous.images.isEmpty, grid.images.isEmpty {
                    scrollShift = scrollDelta
                    let exposed = scrollDelta > 0
                        ? IndexSet(integersIn: 0 ..< scrollDelta)
                        : IndexSet(integersIn: grid.rows + scrollDelta ..< grid.rows)
                    renderDamage = TerminalDamage(rows: exposed)
                } else if plain {
                    if damage.scroll != 0, !damage.full, !damage.scrolledRows.isEmpty,
                       abs(damage.scroll) < grid.rows,
                       state.lastPlainFrameGeneration == generation,
                       let previous = state.lastPlainFrame,
                       previous.columns == grid.cols, previous.rows == grid.rows,
                       previous.images.isEmpty, grid.images.isEmpty {
                        scrollShift = damage.scroll
                        renderDamage = TerminalDamage(rows: damage.rows.subtracting(damage.scrolledRows))
                    } else {
                        renderDamage = damage
                    }
                } else {
                    renderDamage = TerminalDamage(full: true)
                }
                switch grid.cursor.shape {
                case .block: frame.cursor.style = .block
                case .bar: frame.cursor.style = .bar
                case .underline: frame.cursor.style = .underline
                case .default: break
                }
                let blinkEnabled = grid.cursor.blinking ?? blinkSetting
                cursorCanBlink = frame.cursor.visible && isFocused && blinkEnabled
                if frame.cursor.visible, isFocused, blinkEnabled, !blinkVisible {
                    frame.cursor.visible = false
                }
                frame.cursor.hollow = !isFocused // unfocused → hollow outline / dimmed cursor
                // Caches hold the CLEAN frame: on the live path the overlay pass below shades a
                // copy, so reuse stays warm through a selection drag / find session / composition.
                state.lastPlainFrame = plain ? frame : nil
                state.lastPlainFrameGeneration = generation
                // Refresh the scroll-reuse source: any clean, image-free viewport frame qualifies
                // (the live view always builds clean now; a scrolled view only when overlay-free —
                // scrolled overlay frames bake highlight colors into cells, so they poison it).
                if plain || overlayFree, frame.images.isEmpty {
                    state.lastViewportFrame = frame
                    state.lastViewportOffset = requestedScrollOffset
                    state.lastViewportGeneration = generation
                } else {
                    state.lastViewportFrame = nil
                }
                // Cell-overlay pass (live view only): re-shade the selection / find rows of a
                // copy and lay the IME preedit over it, leaving the cached clean frame above
                // untouched. The render damage gains exactly the rows whose overlay fingerprint
                // changed since the last build, so a selection drag re-encodes the rows it
                // crossed — a static highlight (or an idle find bar) adds nothing per frame.
                if plain {
                    let keys = Self.overlayRowKeys(
                        selection: selectionRegion, findHits: findHits, preedit: preedit,
                        preeditCursor: (frame.cursor.row, frame.cursor.column),
                        rows: grid.rows, cols: grid.cols
                    )
                    if !keys.isEmpty {
                        builder.applyHighlights(into: &frame, from: grid, region: selectionRegion,
                                                searchHighlights: findHits, rows: IndexSet(keys.keys))
                        if !preedit.isEmpty {
                            Self.applyPreedit(into: &frame, text: preedit, builder: builder,
                                              canvasForeground: fg, canvasBackground: bg)
                        }
                    }
                    if var damage = renderDamage, !damage.full {
                        for (row, key) in keys where state.lastOverlayKeys[row] != key {
                            damage.rows.insert(row)
                        }
                        for row in state.lastOverlayKeys.keys where keys[row] == nil {
                            damage.rows.insert(row)
                        }
                        if !keys.isEmpty || !state.lastOverlayKeys.isEmpty { damage.cursorOnly = false }
                        renderDamage = damage
                    }
                    state.lastOverlayKeys = keys
                }
            }
            return SurfaceFrameBuildResult(
                generation: generation,
                frame: frame,
                damage: renderDamage,
                scrollShift: scrollShift,
                hasPeekRow: peekRow,
                frameBuildNanos: DispatchTime.now().uptimeNanoseconds &- frameBuildStart,
                clearColor: builder.renderColor(reverseVideo ? fg : bg, alpha: opacity),
                nextAnimationFrame: nextAnimationFrame,
                cursorCanBlink: cursorCanBlink,
                hasShellPrompt: emulator.isShellPromptReady,
                source: source, outputGeneration: frameOutputGeneration
            )
        }

        let token = state.claimFrameToken()
        if synchronous {
            // Build in queue order; only a real transaction-mode resize acquires on main.
            let result = state.sync { emulator in
                FrameSignposter.shared.interval("frameBuild") { build(emulator) }
            }
            applyPendingMainHop()
            presentBuiltFrame(result)
        } else {
            let flush = flushTransaction
            state.async { [weak self] emulator in
                // Latest-wins coalescing: if a newer build is already queued behind this one, skip —
                // it will consume the damage this one would have (no rows lost), so a burst of marks
                // collapses to a single build instead of N stale frames. For a live-resize commit
                // the skip also drops this target's `emulator.resize`, bounding O(history) reflows.
                guard state.isLatestFrameToken(token) else { return }
                let result = FrameSignposter.shared.interval("frameBuild") { build(emulator) }
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.applyPendingMainHop()
                    guard state.isLatestFrameToken(token) else {
                        // This build consumed parser damage before a newer build superseded it.
                        // Its main hop precedes the newer drawable's landing (serial build queue),
                        // so invalidate reuse before that frame can encode the missing rows.
                        self.pendingDrawableNeedsFullDamage = true
                        self.lastPresentedResultIsRendererCoherent = false
                        if self.pendingDrawableFrame == nil, !self.drawableRequestInFlight {
                            // A synchronous transaction may already have submitted its successor.
                            self.scheduleRender()
                        }
                        return
                    }
                    // Any present landing while the layer is in transaction mode flushes its own
                    // explicit CATransaction: a live-resize commit by contract, and an un-gated
                    // mid-drag output build because the mouse may be held still (no layout pass
                    // to carry a transaction-mode present to the glass). Checked at LANDING time —
                    // a build that outlives the drag presents normally (the wrap is a harmless
                    // no-op shape either way, see `presentWithinExplicitTransaction`).
                    if flush || self.metalLayer.presentsWithTransaction {
                        self.presentWithinExplicitTransaction { self.presentBuiltFrame(result) }
                    } else {
                        self.enqueueDrawableFrame(result)
                    }
                }
            }
        }
    }

    /// Keep a single drawable wait off main, with at most one latest pending frame. Replacing
    /// a built frame invalidates damage reuse because the parser has already consumed its damage.
    /// This preserves display synchronization without parking input, output delivery or AppKit
    /// behind the compositor's next refresh. Live resize retains its explicit transaction path.
    func enqueueDrawableFrame(_ result: SurfaceFrameBuildResult) {
        guard renderGeneration == result.generation, window != nil, !drawablePoolReleased,
              !isHiddenOrHasHiddenAncestor, renderExecutor != nil else { return }
        if pendingDrawableFrame != nil { pendingDrawableNeedsFullDamage = true }
        pendingDrawableFrame = result
        startDrawableRequest()
    }

    private func startDrawableRequest() {
        guard !drawableRequestInFlight, pendingDrawableFrame != nil,
              !drawablePoolReleased, let executor = renderExecutor else { return }
        drawableRequestInFlight = true
        let request = SurfaceDrawableRequest(layer: metalLayer)
        activeDrawableRequest = request
        drawableAcquisitionQueue.async { [weak self] in
            request.acquire()
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                // An old acquisition must not consume a remounted layer's latest pending frame
                // or clear its in-flight flag, even when both drawable sizes happen to match.
                guard request.layer === self.metalLayer else { return }
                self.activeDrawableRequest = nil
                guard self.renderExecutor === executor else {
                    self.drawableRequestInFlight = false
                    self.startDrawableRequest()
                    return
                }
                guard var pending = self.pendingDrawableFrame else {
                    self.drawableRequestInFlight = false
                    return
                }
                self.pendingDrawableFrame = nil
                if let latest = self.lastPresentedResult,
                   latest.generation == pending.generation,
                   latest.frame.columns == pending.frame.columns, latest.frame.rows == pending.frame.rows,
                   latest.outputGeneration > pending.outputGeneration {
                    // A cached repaint queued during a newer encode must reuse that completed
                    // output, rather than restore the older content on its next drawable.
                    pending = latest
                    pending.damage = TerminalDamage(full: !self.lastPresentedResultIsRendererCoherent)
                    pending.scrollShift = 0
                }
                if self.pendingDrawableNeedsFullDamage {
                    pending.damage = TerminalDamage(full: true)
                    pending.scrollShift = 0
                    self.lastPresentedResultIsRendererCoherent = false
                }
                self.pendingDrawableNeedsFullDamage = false
                guard let drawable = request.drawable,
                      drawable.texture.width == Int(self.metalLayer.drawableSize.width),
                      drawable.texture.height == Int(self.metalLayer.drawableSize.height) else {
                    executor.sync { $0.invalidateRowReuseCache() }
                    self.drawableRequestInFlight = false
                    self.lastPresentedResultIsRendererCoherent = false
                    self.deferDrawableRetry()
                    return
                }
                if self.metalLayer.presentsWithTransaction {
                    self.drawableRequestInFlight = false
                    self.presentWithinExplicitTransaction {
                        self.presentBuiltFrame(pending, drawable: drawable, drawableWaitNanos: request.waitNanos)
                    }
                } else {
                    self.presentOffMain(pending, request: request, executor: executor)
                }
            }
        }
    }

    private func presentOffMain(_ result: SurfaceFrameBuildResult, request: SurfaceDrawableRequest,
                                executor: SurfaceRenderExecutor) {
        guard result.generation == renderGeneration, renderExecutor === executor,
              let configuration = presentConfiguration(for: result) else {
            drawableRequestInFlight = false
            startDrawableRequest()
            return
        }
        nextPresentationID &+= 1
        let presentationID = nextPresentationID
        executor.async { [weak self] renderer in
            let outcome = Self.encodePresentation(result, configuration: configuration,
                                                  renderer: renderer, drawable: request.drawable,
                                                  waitNanos: request.waitNanos)
            if outcome != .presented { renderer.invalidateRowReuseCache() }
            let stats = renderer.stats
            DispatchQueue.main.async { [weak self] in
                guard let self, request.layer === self.metalLayer else { return }
                self.drawableRequestInFlight = false
                if self.renderExecutor === executor {
                    self.finishPresentation(result, outcome: outcome, stats: stats, id: presentationID)
                }
                self.startDrawableRequest()
            }
        }
    }

    /// Accept a built frame. Ordinary frames submit through bounded off-main acquisition;
    /// actual transaction-mode resize submits inline. Completion handles transient failures.
    private func presentBuiltFrame(
        _ result: SurfaceFrameBuildResult, drawable: CAMetalDrawable? = nil, drawableWaitNanos: UInt64 = 0
    ) {
        guard renderGeneration == result.generation, window != nil, !drawablePoolReleased,
              !isHiddenOrHasHiddenAncestor, let executor = renderExecutor else { return }
        if !metalLayer.presentsWithTransaction {
            enqueueDrawableFrame(result)
            return
        }
        // A synchronous layout/resize frame supersedes any older frame waiting for a drawable.
        if pendingDrawableFrame != nil || pendingDrawableNeedsFullDamage {
            pendingDrawableFrame = nil
            pendingDrawableNeedsFullDamage = false
            executor.sync { $0.invalidateRowReuseCache() }
        }
        nextPresentationID &+= 1
        let outcome = presentTransactionFrame(result, damage: result.damage, scrollShift: result.scrollShift, drawable: drawable, acquiredWaitNanos: drawableWaitNanos)
        let stats = executor.sync { $0.stats }
        if outcome != .presented { executor.sync { $0.invalidateRowReuseCache() } }
        finishPresentation(result, outcome: outcome, stats: stats, id: nextPresentationID)
    }

    private func finishPresentation(_ result: SurfaceFrameBuildResult, outcome: PresentAttempt,
                                    stats: TerminalRenderStats, id: UInt64) {
        guard result.generation == renderGeneration, id >= completedPresentationID else { return }
        completedPresentationID = id
        if outcome == .presented {
            cancelDrawableRetry()
            // Remember the presented frame so a live resize can re-stretch it without rebuilding
            // (and without touching the emulator queue). See `repaintLastFrame`.
            lastPresentedResult = result
            // The renderer reports whether the encode left its row cache holding exactly this
            // frame's rows — false for the cache-bypassing paths (nil damage) AND for a
            // mid-encode atlas reset that wiped the cache (which a damage-only heuristic here
            // could not distinguish from a normal full encode).
            lastPresentedResultIsRendererCoherent = stats.rowCacheCoherent
            onRenderStats?(stats)
            updateTextBlinkTimer(frameHasBlink: result.frame.hasBlink)
            scheduleAnimationFrame(at: result.nextAnimationFrame)
            if result.hasShellPrompt { StartupMetrics.shared.mark(.firstShellPromptFrameSubmitted) }
            if !hasSubmittedShellPrompt, result.hasShellPrompt {
                hasSubmittedShellPrompt = true
                onFirstShellPromptSubmitted?()
            }
        } else {
            // A genuine drop: nothing reached the glass this turn (repaintLastFrame failures
            // don't count — their callers fall back to another present in the same turn).
            // The worker has already diffed this frame's damage away (lastPlainFrame /
            // lastViewportFrame advanced at build time), so the NEXT build can legitimately say
            // "nothing changed" — but the renderer's row cache never received this frame's rows
            // (nil drawable drops before encode) or holds rows the screen never showed (encode
            // failed after mutating them). Either way the cache and the next frame's damage
            // disagree about what's on the glass, so drop the cache: the retry re-encodes fully.
            lastPresentedResultIsRendererCoherent = false
            FrameSignposter.shared.recordFrameDrop(
                outcome == .nilDrawable ? .nilDrawable : .encodeFailure)
            deferDrawableRetry()
        }
        if outcome == .presented { StartupMetrics.shared.mark(.firstDrawablePresented) }
    }

    /// CPU submission outcome, distinct from GPU completion or visible scanout.
    private typealias PresentAttempt = SurfacePresentAttempt

    private func presentConfiguration(for result: SurfaceFrameBuildResult) -> SurfacePresentConfiguration? {
        guard let renderer else { return nil }
        let canTranslate = result.hasPeekRow && result.frame.images.isEmpty
        return SurfacePresentConfiguration(
            originX: originOffsetX, originY: originOffsetY,
            gamma: glyphGamma, ligatures: ligaturesEnabled,
            fractionPx: canTranslate && scrollFraction > 0
                ? Float((scrollFraction * CGFloat(renderer.cellPixelHeight)).rounded()) : 0,
            clipRows: result.hasPeekRow ? result.frame.rows - 1 : nil,
            synchronizedWithTransaction: metalLayer.presentsWithTransaction
        )
    }

    /// Submit within the current AppKit transaction. Only actual transaction-mode resize
    /// enters this main-thread acquisition path; ordinary force/repaint stays off main.
    private func presentTransactionFrame(
        _ result: SurfaceFrameBuildResult, damage: TerminalDamage?, scrollShift: Int = 0,
        drawable acquiredDrawable: CAMetalDrawable? = nil, acquiredWaitNanos: UInt64 = 0
    ) -> PresentAttempt {
        guard window != nil, !drawablePoolReleased, !isHiddenOrHasHiddenAncestor,
              let executor = renderExecutor, let configuration = presentConfiguration(for: result)
        else { return .encodeFailure }
        return autoreleasepool {
            let start = DispatchTime.now().uptimeNanoseconds
            let drawable = acquiredDrawable ?? metalLayer.nextDrawable()
            let wait = acquiredDrawable == nil
                ? DispatchTime.now().uptimeNanoseconds &- start : acquiredWaitNanos
            var frame = result
            frame.damage = damage
            frame.scrollShift = scrollShift
            return executor.withTransactionOwnership { renderer in
                Self.encodePresentation(frame, configuration: configuration, renderer: renderer,
                                        drawable: drawable, waitNanos: wait)
            }
        }
    }

    private nonisolated static func encodePresentation(
        _ result: SurfaceFrameBuildResult, configuration: SurfacePresentConfiguration,
        renderer: TerminalMetalRenderer, drawable: CAMetalDrawable?, waitNanos: UInt64
    ) -> PresentAttempt {
        let sp = FrameSignposter.shared
        let start = DispatchTime.now().uptimeNanoseconds
        let outcome = sp.interval("present") { () -> PresentAttempt in
            guard let drawable else { return .nilDrawable }
            let presented = renderer.present(
                result.frame, to: drawable, clearColor: result.clearColor,
                origin: (configuration.originX, configuration.originY),
                gamma: configuration.gamma, ligatures: configuration.ligatures,
                damage: result.damage, scrollShift: result.scrollShift,
                scrollFractionPx: configuration.fractionPx,
                smoothScrollClipRows: configuration.clipRows,
                frameBuildNanos: result.frameBuildNanos,
                animatingImages: result.nextAnimationFrame != nil,
                synchronizedWithTransaction: configuration.synchronizedWithTransaction
            )
            return presented ? .presented : .encodeFailure
        }
        if sp.enabled, outcome == .presented {
            sp.recordPresent(
                nanos: (DispatchTime.now().uptimeNanoseconds &- start) &+ waitNanos,
                drawableWait: waitNanos, semaphoreWait: renderer.stats.semaphoreWaitNanos,
                schedule: renderer.stats.presentScheduleNanos,
                instanceBuild: renderer.stats.buildInstancesNanos, upload: renderer.stats.uploadNanos,
                source: result.source, outputGeneration: result.outputGeneration
            )
        }
        return outcome
    }

    /// Append the buffer line just below the scrolled viewport as a display-only (rows+1)th row —
    /// the smooth-scroll peek row the fraction translate reveals. The snapshot stays a uniform
    /// window over `[history ++ viewport]`, so the renderer rotates it like any other row.
    /// `offset ≥ 1` guarantees the line below the viewport exists (it is at worst the live bottom
    /// row); a defensive blank-pad covers width races during reflow. Runs on the emulator queue
    /// (called from the build closure).
    private nonisolated static func appendingPeekRow(
        to snapshot: TerminalGridSnapshot, emulator: TerminalEmulator, offset: Int
    ) -> TerminalGridSnapshot {
        let peekIndex = emulator.historyCount - offset + snapshot.rows
        var line = peekIndex >= 0 && peekIndex < emulator.bufferLineCount
            ? emulator.bufferLine(peekIndex) : []
        if line.count < snapshot.cols {
            line.append(contentsOf: Array(repeating: .blank, count: snapshot.cols - line.count))
        } else if line.count > snapshot.cols {
            line.removeLast(line.count - snapshot.cols)
        }
        return TerminalGridSnapshot(
            cols: snapshot.cols, rows: snapshot.rows + 1, cells: snapshot.cells + line,
            cursor: snapshot.cursor, images: snapshot.images, marks: snapshot.marks, clusters: snapshot.clusters
        )
    }

    /// Re-present the last built frame at the *current* drawable size with no emulator-queue access
    /// — the smooth-resize fast path. Used by `layout()` during a live drag/animation: the grid
    /// hasn't reflowed yet (deferred to drag-end), so the cached frame is still the correct content;
    /// we just need to redraw it into the freshly-resized drawable. Returns whether a repaint
    /// was accepted (ordinary mode) or submitted (transaction mode). Without a valid cached
    /// frame, the caller builds a current frame before scheduling its submission.
    ///
    /// Damage selection is the per-tick cost lever. Under the drag-frozen origin every row-cache
    /// key (cols/rows/origin/atlas) is stable, so when the cache verifiably holds this exact
    /// frame's rows (`lastPresentedResultIsRendererCoherent`) an EMPTY damage reuses every row —
    /// `encodedRows == 0`, zero-copy instance bind, only the viewport uniform changes. When it
    /// doesn't (preview reflow replaced the frame, a drop wiped the cache), a `full` damage pays
    /// one rebuild *through the cache-populating path* so the very next tick is free again —
    /// unlike `damage: nil`, which rebuilds AND leaves the cache empty, making every sub-cell drag
    /// tick a full re-encode (the pre-#57 resize-lag source). Image frames take the same two
    /// paths — image quads draw outside the cell instance buffers, so they never gate reuse.
    @discardableResult
    func repaintLastFrame() -> Bool {
        guard let result = lastPresentedResult,
              result.generation == renderGeneration,
              window != nil, let executor = renderExecutor else { return false }
        let damage: TerminalDamage?
        if lastPresentedResultIsRendererCoherent, !drawableRequestInFlight,
           !pendingDrawableNeedsFullDamage {
            damage = TerminalDamage(rows: [], full: false)
        } else {
            damage = TerminalDamage(full: true)
        }
        if !metalLayer.presentsWithTransaction {
            // Layout repaints must not replace a newer output frame already awaiting a drawable.
            if pendingDrawableFrame == nil {
                var repaint = result
                repaint.damage = damage
                repaint.scrollShift = 0
                enqueueDrawableFrame(repaint)
            }
            return true
        }
        // Joining an older encode can enqueue its main completion during this transaction.
        // The repaint owns a later submission ID so that completion cannot restore stale
        // frame metadata or cache coherence after the newer transaction has submitted.
        nextPresentationID &+= 1
        let presentationID = nextPresentationID
        let didPresent = presentTransactionFrame(result, damage: damage) == .presented
        if didPresent {
            var repaint = result
            repaint.damage = damage
            repaint.scrollShift = 0
            repaint.frameBuildNanos = 0
            finishPresentation(repaint, outcome: .presented, stats: executor.sync { $0.stats },
                               id: presentationID)
        }
        return didPresent
    }

    /// Build a live re-wrap preview of the viewport at the current drag target `nc × nr` and present
    /// it, so the drag shows the content *re-wrapped to the new width* rather than the old grid
    /// revealed/clipped. Pure: reads the emulator via `previewViewportReflow` (O(visible),
    /// non-mutating) and never reflows history or sends `SIGWINCH` (both deferred to
    /// `commitGridSize`), so the shell's width belief never desyncs from the display. Skipped when an
    /// overlay the preview can't represent is active (scrollback, selection, IME pre-edit, find, copy
    /// mode) or on the alternate screen — `repaintLastFrame` then keeps re-presenting the cached frame.
    ///
    /// The build runs **async on the emulator queue** (latest-wins token, the `renderNowOffMain`
    /// coalescing pattern): a boundary-crossing tick never parks main on the queue — not behind an
    /// in-flight parse under heavy output (the old `pendingFeed.isBusy` skip dodged that but still
    /// paid the full build wall when idle), and not even for the build itself. While the build is in
    /// flight, `layout()` keeps re-presenting the last cached frame at the new drawable size, so the
    /// drag never drops a frame; the re-wrapped content lands on the next main hop via
    /// `presentResizePreview`. A fast drag's boundary builds coalesce to the freshest `nc × nr`.
    ///
    /// DELIBERATE TRADE: the boundary tick shows ≤1 frame of the previous column count's wrap at
    /// the new drawable size before the re-wrap lands (the old synchronous code showed the re-wrap
    /// same-tick but stalled main for the reflow+build — a blown frame budget on big grids, and it
    /// SKIPPED the re-wrap entirely under parser load). Frame pacing wins over single-frame wrap
    /// fidelity; under load the async path is strictly better (stale wrap either way, no stall).
    private func updateResizePreview(cols nc: Int, rows nr: Int) {
        guard scrollOffset == 0, copyMode == nil, selectionAnchor == nil,
              markedText.isEmpty, !findActive else { return }
        let config = frameBuildConfiguration
        let bg = canvasBackground
        let fg = canvasForeground
        let opacity = canvasOpacity
        let isFocused = effectivelyFocused
        let generation = renderGeneration
        let source = ObjectIdentifier(self)
        let frameOutputGeneration = outputGeneration
        let state = emulatorState
        // Preview-namespace token (NOT claimFrameToken): the output pipeline must not cancel an
        // in-flight re-wrap — during an animated resize both pipelines run concurrently.
        let token = state.claimPreviewToken()
        state.async { [weak self] emulator in
            // Latest-wins within the preview pipeline: a further boundary tick is already queued
            // behind this one — skip; it renders a strictly newer drag target.
            guard state.isLatestPreviewToken(token) else { return }
            guard let preview = emulator.previewViewportReflow(cols: nc, rows: nr) else { return }
            let buildStart = DispatchTime.now().uptimeNanoseconds
            let reverseVideo = emulator.modes.reverseVideo
            let builder = config.makeBuilder(reverseVideo: reverseVideo)
            var frame = FrameSignposter.shared.interval("frameBuild") {
                builder.buildDirect(preview, region: nil, imageProvider: { emulator.image(for: $0) })
            }
            frame.cursor.hollow = !isFocused
            // NOTE: must not touch `state.lastPlainFrame`/`lastViewportFrame` — the preview has
            // different dims than the live grid and would poison the damage-reuse caches.
            let result = SurfaceFrameBuildResult(
                generation: generation, frame: frame, damage: nil,
                frameBuildNanos: DispatchTime.now().uptimeNanoseconds &- buildStart,
                clearColor: builder.renderColor(reverseVideo ? fg : bg, alpha: opacity),
                hasShellPrompt: emulator.isShellPromptReady,
                source: source, outputGeneration: frameOutputGeneration
            )
            DispatchQueue.main.async { [weak self] in
                self?.presentResizePreview(result, cols: nc, rows: nr, token: token)
            }
        }
    }

    /// Main-hop landing for an async preview build. Drops a stale preview outright rather than
    /// stashing it: an async build can land after the drag moved to a different cell target, or
    /// after the settled commit bumped the generation — stashing a frame for the wrong grid would
    /// re-present mis-wrapped content on every subsequent sub-cell repaint. A current preview is
    /// stashed exactly like the old synchronous path (coherence broken: the renderer cache still
    /// holds the previous frame's rows) and accepted for repaint — the submission pays the one
    /// cache-populating rebuild per geometry change, and the tick after it is free again.
    /// Returns whether the preview was accepted (stashed + repaint attempted) — false = dropped
    /// as stale. The Bool is for tests pinning the guards; production callers ignore it.
    @discardableResult
    private func presentResizePreview(
        _ result: SurfaceFrameBuildResult, cols: Int, rows: Int, token: UInt64
    ) -> Bool {
        guard renderGeneration == result.generation,         // not superseded by commitGridSize
              emulatorState.isLatestPreviewToken(token),      // not superseded by a newer preview
              cols == previewCols, rows == previewRows,       // still the current drag target
              scrollOffset == 0, copyMode == nil, selectionAnchor == nil,
              markedText.isEmpty, !findActive,                // overlays may change during the build
              window != nil else { return false }
        lastPresentedResult = result
        // The preview replaced the frame WITHOUT a present: the renderer cache still holds the
        // previous frame's rows, so the repaint below takes the cache-populating full path.
        lastPresentedResultIsRendererCoherent = false
        // Present now (sanctioned drag path: the same `repaintLastFrame` that `layout()` drives);
        // when no drawable is free this turn, the next layout pass repaints it instead.
        if !repaintLastFrame() { needsLayout = true }
        return true
    }

    /// Buttons whose press landed in the padding and was not reported: their drags and release
    /// stay local too, so the program never sees a release without its press.
    var unreportedMouseButtons: Set<Int> = []
    /// Last drag position reported, deduping to one report per cell (per pixel in SGR-pixel mode,
    /// where the program asked for that resolution).
    var lastReportedDrag: (x: Int, y: Int)?
    /// Last grid cell reported for button-less motion, deduping any-event tracking to one
    /// report per cell crossed — AppKit delivers `mouseMoved` at event rate, and per-cell is
    /// the protocol's resolution (kept even in SGR-pixel mode so a wiggle inside one cell
    /// can't flood the PTY).
    var lastReportedMotionCell: (row: Int, column: Int)?
    /// Physical modifier keycodes currently held — used to tell press from release in
    /// `flagsChanged` (which fires for both, with no inherent direction).
    var pressedModifierKeyCodes: Set<UInt16> = []
    var selectionFadeView: NSView?
}
