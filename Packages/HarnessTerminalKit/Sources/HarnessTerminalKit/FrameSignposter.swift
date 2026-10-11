import Foundation
import HarnessCore
#if canImport(os)
import os
#endif

/// Opt-in parse/build/encode and frame-submission timing, safe across per-surface render queues.
/// Submission and echo samples are CPU-side proxies; they do not measure GPU completion or
/// visible photons. `HARNESS_FRAME_SIGNPOSTS=1` enables signposts and durable metric summaries.
/// Disabled call sites branch once and perform no locking or I/O.
final class FrameSignposter: @unchecked Sendable {
    static let shared = FrameSignposter()

    let enabled: Bool

    #if canImport(os)
    private let signposter: OSSignposter
    private let logger: Logger
    #endif
    private let lock = NSLock()
    private let fileLoggingEnabled: Bool
    private let logQueue = DispatchQueue(label: "com.harness.frame-metrics", qos: .utility)
    /// Aggregate CPU submission timings across surfaces; source counts accompany each summary.
    private var presentSamples: [UInt64] = []
    private var drawableWaitSamples: [UInt64] = []
    private var semaphoreWaitSamples: [UInt64] = []
    private var scheduleSamples: [UInt64] = []
    /// Per-boundary encode split (from `TerminalRenderStats`): `instanceBuild` = CPU row encode +
    /// flatten (`buildFrameInstances`), `upload` = the GPU ring-slot memcpy / stable bind
    /// (`bindableInstanceBuffers`). Attributes a slow encode to the value boundary that paid it.
    private var instanceBuildSamples: [UInt64] = []
    private var uploadSamples: [UInt64] = []
    /// Presents skipped since the last flush — work was pending but no frame was submitted that
    /// turn; the scheduler retried on a later tick. Counted per cause so a flush line can tell
    /// drawable-pool exhaustion (vsync/window-server pressure) from a renderer encode failure.
    private var droppedNilDrawable = 0
    private var droppedEncodeFailure = 0
    private let presentLogEvery = 120
    private struct Keystroke {
        var nanos: UInt64
        var outputGeneration: UInt64
    }
    /// One latest input per surface. Only its first newer-output submission can consume it.
    private var pendingKeystrokes: [ObjectIdentifier?: Keystroke] = [:]
    private var echoSamples: [UInt64] = []
    private var echoSourceCounts: [String: Int] = [:]
    private var presentSourceCounts: [String: Int] = [:]
    private let echoAttributionWindowNanos: UInt64 = 500_000_000
    private let echoLogEvery = 60

    /// Why a present was skipped: `nilDrawable` = `nextDrawable()` returned nothing (pool
    /// exhausted / layer hidden), `encodeFailure` = the renderer bailed after acquiring one.
    enum FrameDropCause {
        case nilDrawable, encodeFailure
    }

    /// `enabled: nil` (production singleton) reads the environment; tests pass it explicitly.
    init(enabled: Bool? = nil) {
        // `open` (Finder, `make preview`) does not forward the calling shell's environment to a
        // GUI app, so the env var alone is unreachable in practice. Also accept the argument
        // domain — `open -n Harness.app --args -HARNESS_FRAME_SIGNPOSTS 1` lands in
        // `UserDefaults.standard` via NSArgumentDomain. One read at init; the hot path still
        // branches on the stored `enabled`.
        self.enabled = enabled
            ?? (ProcessInfo.processInfo.environment["HARNESS_FRAME_SIGNPOSTS"] == "1"
                || UserDefaults.standard.bool(forKey: "HARNESS_FRAME_SIGNPOSTS"))
        fileLoggingEnabled = enabled == nil && self.enabled
        #if canImport(os)
        signposter = OSSignposter(subsystem: "com.robert.harness", category: "frame")
        logger = Logger(subsystem: "com.robert.harness", category: "frame")
        #endif
    }

    /// Arm an input sample with the surface's output generation before sending the keystroke.
    /// Nil source is reserved for simple fixtures; production callers supply source and generation.
    func noteKeystroke(source: ObjectIdentifier? = nil, outputGeneration: UInt64 = 0,
                       at nanos: UInt64 = DispatchTime.now().uptimeNanoseconds) {
        guard enabled else { return }
        lock.lock(); defer { lock.unlock() }
        pendingKeystrokes[source] = Keystroke(nanos: nanos, outputGeneration: outputGeneration)
    }

    var testingEchoSampleCount: Int { lock.lock(); defer { lock.unlock() }; return echoSamples.count }
    var testingHasPendingKeystroke: Bool { lock.lock(); defer { lock.unlock() }; return !pendingKeystrokes.isEmpty }

    /// Record a successful CPU frame submission. Repaints with unchanged output cannot claim input.
    func recordPresent(
        nanos: UInt64, drawableWait: UInt64 = 0, semaphoreWait: UInt64 = 0, schedule: UInt64 = 0,
        instanceBuild: UInt64 = 0, upload: UInt64 = 0,
        source: ObjectIdentifier? = nil, outputGeneration: UInt64? = nil,
        at now: UInt64 = DispatchTime.now().uptimeNanoseconds
    ) {
        guard enabled else { return }
        lock.lock(); defer { lock.unlock() }
        pendingKeystrokes = pendingKeystrokes.filter {
            now < $0.value.nanos || now - $0.value.nanos <= echoAttributionWindowNanos
        }
        if let pending = pendingKeystrokes[source], now >= pending.nanos,
           (source == nil && outputGeneration == nil)
            || (outputGeneration.map { $0 > pending.outputGeneration } ?? false) {
            pendingKeystrokes.removeValue(forKey: source)
            let elapsed = now - pending.nanos
            echoSamples.append(elapsed)
            echoSourceCounts[Self.sourceLabel(source), default: 0] += 1
            persistSummary(kind: "echo-sample", samples: [elapsed], sources: [Self.sourceLabel(source): 1])
            if echoSamples.count >= echoLogEvery { flushEchoSamples() }
        }
        presentSourceCounts[Self.sourceLabel(source), default: 0] += 1
        presentSamples.append(nanos)
        drawableWaitSamples.append(drawableWait)
        semaphoreWaitSamples.append(semaphoreWait)
        scheduleSamples.append(schedule)
        instanceBuildSamples.append(instanceBuild)
        uploadSamples.append(upload)
        guard presentSamples.count >= presentLogEvery else { return }
        let frames = presentSamples.count
        let total = Self.percentilesMicros(presentSamples)
        let drawable = Self.percentilesMicros(drawableWaitSamples)
        let semaphore = Self.percentilesMicros(semaphoreWaitSamples)
        let sched = Self.percentilesMicros(scheduleSamples)
        let build = Self.percentilesMicros(instanceBuildSamples)
        let up = Self.percentilesMicros(uploadSamples)
        let droppedDrawable = droppedNilDrawable
        let droppedEncode = droppedEncodeFailure
        persistSummary(kind: "frame-submission", samples: presentSamples, sources: presentSourceCounts,
                       additional: ["drawableWaitNanos": drawableWaitSamples,
                                    "semaphoreWaitNanos": semaphoreWaitSamples, "scheduleNanos": scheduleSamples,
                                    "instanceBuildNanos": instanceBuildSamples, "uploadNanos": uploadSamples,
                                    "droppedNilDrawable": droppedDrawable, "droppedEncodeFailure": droppedEncode])
        presentSourceCounts.removeAll(keepingCapacity: true)
        if !echoSamples.isEmpty { flushEchoSamples() }
        presentSamples.removeAll(keepingCapacity: true)
        drawableWaitSamples.removeAll(keepingCapacity: true)
        semaphoreWaitSamples.removeAll(keepingCapacity: true)
        scheduleSamples.removeAll(keepingCapacity: true)
        instanceBuildSamples.removeAll(keepingCapacity: true)
        uploadSamples.removeAll(keepingCapacity: true)
        droppedNilDrawable = 0
        droppedEncodeFailure = 0
        #if canImport(os)
        logger.log("""
        present µs p50=\(total.p50) p95=\(total.p95) p99=\(total.p99) max=\(total.max) | \
        drawableWait p50=\(drawable.p50) p95=\(drawable.p95) p99=\(drawable.p99) | \
        semaphoreWait p50=\(semaphore.p50) p95=\(semaphore.p95) | \
        schedule p50=\(sched.p50) p95=\(sched.p95) | \
        instanceBuild p50=\(build.p50) p95=\(build.p95) | \
        upload p50=\(up.p50) p95=\(up.p95) | \
        dropped=\(droppedDrawable + droppedEncode) (drawable=\(droppedDrawable) encode=\(droppedEncode)) \
        over \(frames) frames
        """)
        #endif
    }

    /// Count a skipped present by cause; included in the periodic `recordPresent` flush line.
    /// Thread-safe; no-op when disabled.
    func recordFrameDrop(_ cause: FrameDropCause) {
        guard enabled else { return }
        lock.lock(); defer { lock.unlock() }
        switch cause {
        case .nilDrawable: droppedNilDrawable += 1
        case .encodeFailure: droppedEncodeFailure += 1
        }
    }

    private static func sourceLabel(_ source: ObjectIdentifier?) -> String {
        source.map { String(describing: $0) } ?? "unattributed"
    }

    private func flushEchoSamples() {
        let echo = Self.percentilesMicros(echoSamples)
        let count = echoSamples.count
        persistSummary(kind: "echo-submission-proxy", samples: echoSamples, sources: echoSourceCounts)
        echoSamples.removeAll(keepingCapacity: true)
        echoSourceCounts.removeAll(keepingCapacity: true)
        #if canImport(os)
        logger.log("echo submission proxy µs p50=\(echo.p50) p95=\(echo.p95) p99=\(echo.p99) max=\(echo.max) over \(count) keystrokes")
        #endif
    }

    /// Serialize small batches while locked, then perform diagnostic file I/O off render queues.
    private func persistSummary(kind: String, samples: [UInt64], sources: [String: Int], additional: [String: Any] = [:]) {
        guard fileLoggingEnabled else { return }
        let percentile = Self.percentilesMicros(samples)
        var record = additional
        record["kind"] = kind
        record["timestamp"] = Date().timeIntervalSince1970
        record["count"] = samples.count
        record["samplesNanos"] = samples
        record["sourceCounts"] = sources
        record["percentilesMicros"] = ["p50": percentile.p50, "p95": percentile.p95,
                                       "p99": percentile.p99, "max": percentile.max]
        guard var line = try? JSONSerialization.data(withJSONObject: record, options: [.sortedKeys]) else { return }
        line.append(0x0a)
        let data = line
        let url = HarnessPaths.logsDirectory.appendingPathComponent("frame-metrics.jsonl")
        logQueue.async {
            do {
                try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
                if !FileManager.default.fileExists(atPath: url.path) {
                    _ = FileManager.default.createFile(atPath: url.path, contents: nil, attributes: [.posixPermissions: 0o600])
                }
                let handle = try FileHandle(forWritingTo: url)
                defer { try? handle.close() }
                try handle.seekToEnd()
                try handle.write(contentsOf: data)
            } catch {
                // Diagnostic persistence must not affect input or frame submission.
            }
        }
    }

    // Internal (not private) so the unit tests pin the percentile math directly.
    static func percentilesMicros(_ samples: [UInt64]) -> (p50: UInt64, p95: UInt64, p99: UInt64, max: UInt64) {
        guard !samples.isEmpty else { return (0, 0, 0, 0) }
        let sorted = samples.sorted()
        return (
            sorted[sorted.count / 2] / 1000,
            sorted[min(sorted.count - 1, Int(Double(sorted.count) * 0.95))] / 1000,
            sorted[min(sorted.count - 1, Int(Double(sorted.count) * 0.99))] / 1000,
            (sorted.last ?? 0) / 1000
        )
    }

    #if canImport(os)
    /// Run `body` inside a named signpost interval (no-op overhead when disabled). Reentrancy- and
    /// concurrency-safe: each call carries its own interval state, so concurrent surface workers
    /// do not confuse the trace.
    @inline(__always)
    func interval<T>(_ name: StaticString, _ body: () -> T) -> T {
        guard enabled else { return body() }
        let state = signposter.beginInterval(name)
        defer { signposter.endInterval(name, state) }
        return body()
    }

    /// Emit a zero-width event (e.g. the cross-thread main hop) to mark a point on the timeline.
    @inline(__always)
    func event(_ name: StaticString) {
        guard enabled else { return }
        signposter.emitEvent(name)
    }
    #else
    @inline(__always)
    func interval<T>(_ name: StaticString, _ body: () -> T) -> T { body() }

    @inline(__always)
    func event(_ name: StaticString) {}
    #endif
}
