import Foundation
import HarnessCore
import CHarnessSys
#if os(macOS)
import IOKit
import IOKit.ps
import IOKit.pwr_mgt
#endif

/// Assertion and sleep/wake ownership belong to the active application daemon.
/// Native callbacks acknowledge sleep before queuing any persistence or delivery.
final class PowerService: @unchecked Sendable {
    private let queue = DispatchQueue(label: "com.harness.power")
    private let queueKey = DispatchSpecificKey<Bool>()
    private let notificationQueueKey = DispatchSpecificKey<Bool>()
    private let notificationQueue = DispatchQueue(label: "com.harness.power.notifications")
    private let nativeEnabled: Bool
    private let settingsCache = DaemonSettingsCache.shared
    private var settingsObservation: UUID?
    private var settingsFailure: String?
    private var settings: PowerSettings
    private var mode: AwakeMode = .auto
    private var policy = PowerPolicy()
    private var timer: DispatchSourceTimer?
    private var enabled = false
    private var count = 0
    private var source: PowerSource = .unknown
    private var graceUntil: Date?
    private var sleepingAt: Date?
    private var lastWakeAt: Date?
    private var lastSleepSeconds: Double?
    private var failure: String?
    private var assertionFailure: String?
    var workingProvider: (@Sendable () -> Int)?
    var onSleep: (@Sendable () -> Void)?
    var onWake: (@Sendable (Double?) -> Void)?
    #if os(macOS)
    private var assertion: IOPMAssertionID?
    private var powerSourceObservation: PowerSourceObservation?
    private var port: IONotificationPortRef?
    private var rootPort: io_connect_t = 0
    private var notifier: io_object_t = 0
    private let callbackContext = CallbackContext()
    private final class CallbackContext: @unchecked Sendable {
        weak var service: PowerService?
        private let lock = NSLock()
        private var root: io_connect_t = 0
        func setRoot(_ value: io_connect_t) { lock.lock(); root = value; lock.unlock() }
        func acknowledge(_ message: UInt32, argument: UnsafeMutableRawPointer?) {
            guard message == harness_power_can_sleep() || message == harness_power_will_sleep() else { return }
            lock.lock(); defer { lock.unlock() }
            if root != 0 { IOAllowPowerChange(root, Int(bitPattern: argument)) }
        }
        func closeRoot() {
            lock.lock(); defer { lock.unlock() }
            if root != 0 { IOServiceClose(root); root = 0 }
        }
    }
    /// `dispatchMain()` does not run a Core Foundation loop. Battery notifications
    /// therefore get one sleeping event thread for the daemon, shared by all panes.
    private final class PowerSourceObservation: @unchecked Sendable {
        private let lock = NSLock()
        private let ready = DispatchSemaphore(value: 0)
        private var runLoop: CFRunLoop?
        private var worker: Thread?
        private let context: CallbackContext
        init(context: CallbackContext) {
            self.context = context
            worker = Thread { [self] in run() }
            worker?.name = "Harness power source events"; worker?.start()
            ready.wait()
        }
        var isAvailable: Bool { lock.lock(); defer { lock.unlock() }; return runLoop != nil }
        func stop() {
            lock.lock(); let loop = runLoop; worker = nil; lock.unlock()
            if let loop {
                CFRunLoopPerformBlock(loop, CFRunLoopMode.defaultMode.rawValue) { CFRunLoopStop(loop) }
                CFRunLoopWakeUp(loop)
            }
        }
        private func run() {
            guard let observer = IOPSNotificationCreateRunLoopSource({ pointer in
                guard let pointer else { return }
                Unmanaged<CallbackContext>.fromOpaque(pointer).takeUnretainedValue().service?.refresh()
            }, Unmanaged.passUnretained(context).toOpaque())?.takeRetainedValue() else {
                lock.lock(); worker = nil; lock.unlock(); ready.signal(); return
            }
            let loop = CFRunLoopGetCurrent()
            CFRunLoopAddSource(loop, observer, .defaultMode)
            lock.lock(); runLoop = loop; lock.unlock(); ready.signal()
            CFRunLoopRun()
            CFRunLoopRemoveSource(loop, observer, .defaultMode)
            lock.lock(); runLoop = nil; worker = nil; lock.unlock()
        }
    }
    #endif

    init(settings: PowerSettings, nativeEnabled: Bool) {
        self.settings = settings; self.nativeEnabled = nativeEnabled
        queue.setSpecific(key: queueKey, value: true)
        notificationQueue.setSpecific(key: notificationQueueKey, value: true)
        #if os(macOS)
        callbackContext.service = self
        #else
        source = .unsupported; failure = "Idle-sleep management is available on macOS. Linux headless programs continue under the host's own power policy."
        #endif
    }
    deinit {
        if let settingsObservation { settingsCache.removeObserver(settingsObservation) }
        if DispatchQueue.getSpecific(key: queueKey) == true || DispatchQueue.getSpecific(key: notificationQueueKey) == true { stopOnQueue() }
        else { queue.sync { stopOnQueue() } }
    }
    func activate() {
        queue.sync {
            guard !enabled else { return }
            enabled = true
            #if os(macOS)
            if nativeEnabled {
                rootPort = IORegisterForSystemPower(Unmanaged.passUnretained(callbackContext).toOpaque(), &port, { context, _, message, argument in
                    guard let context else { return }
                    let box = Unmanaged<CallbackContext>.fromOpaque(context).takeUnretainedValue()
                    box.acknowledge(message, argument: argument)
                    if let service = box.service { service.queue.async { [weak service] in service?.receive(message) } }
                }, &notifier)
                failure = rootPort == 0 ? "System sleep/wake observation is unavailable." : nil
                callbackContext.setRoot(rootPort)
                if let port { IONotificationPortSetDispatchQueue(port, notificationQueue) }
            }
            #endif
            let source = DispatchSource.makeTimerSource(queue: queue)
            source.schedule(deadline: .distantFuture)
            source.setEventHandler { [weak self] in self?.evaluate() }
            source.resume(); timer = source
            if settingsObservation == nil {
                settingsObservation = settingsCache.observe { [weak self] in
                    self?.queue.async { [weak self] in
                        guard let self, let result = self.settingsCache.latestResult else { return }
                        switch result {
                        case let .success(fresh): self.settings = fresh.power; self.settingsFailure = nil
                        case .failure: self.settingsFailure = "Power settings could not be reloaded; the last working policy remains active."
                        }
                        self.evaluate()
                    }
                }
            }
            #if os(macOS)
            if nativeEnabled {
                let observation = PowerSourceObservation(context: callbackContext)
                powerSourceObservation = observation
                if !observation.isAvailable { failure = "Power source observation is unavailable." }
            }
            #endif
            evaluate()
        }
    }
    func suspend() { queue.sync { stopOnQueue() } }
    func refresh() { queue.async { [weak self] in self?.evaluate() } }
    func configure(_ value: PowerSettings) throws {
        try value.validate()
        try queue.sync {
            _ = try SettingsSectionStorage.save(value, key: "power")
            settingsCache.refresh()
            settings = value; evaluate()
        }
    }
    func setMode(_ value: AwakeMode) throws {
        #if os(macOS)
        try queue.sync {
            guard nativeEnabled, enabled else { throw SessionHostError.refused("The active macOS daemon's power service is unavailable.") }
            mode = value; evaluate()
        }
        #else
        throw SessionHostError.refused("Idle-sleep overrides are supported on macOS only.")
        #endif
    }
    func status() -> AwakeStatus {
        queue.sync {
            AwakeStatus(mode: mode, settings: settings, source: source, assertionActive: assertionActive,
                workingAgents: count, graceUntil: graceUntil, sleeping: sleepingAt != nil,
                lastWakeAt: lastWakeAt, lastSleepSeconds: lastSleepSeconds,
                unavailable: settingsFailure ?? assertionFailure ?? failure ?? (nativeEnabled ? nil : "Native power management is disabled for this embedded daemon."))
        }
    }
    private var assertionActive: Bool {
        #if os(macOS)
        return assertion != nil
        #else
        return false
        #endif
    }
    private func evaluate() {
        guard enabled else { return }
        var retryAt: Date?
        defer {
            let deadline = [graceUntil, retryAt].compactMap { $0 }.min()
            timer?.schedule(deadline: deadline.map { .now() + max(0, $0.timeIntervalSinceNow) } ?? .distantFuture)
        }
        let nextCount = workingProvider?() ?? 0
        if count > 0, nextCount == 0 {
            _ = policy.evaluate(settings: settings, mode: mode, source: source, workingAgents: count, at: .now)
        }
        count = nextCount
        #if os(macOS)
        guard nativeEnabled else { return }
        source = Self.powerSource()
        let decision = policy.evaluate(settings: settings, mode: mode, source: source, workingAgents: count, at: .now)
        graceUntil = decision.graceUntil
        if decision.hold && sleepingAt == nil {
            if assertion == nil {
                var value: IOPMAssertionID = 0
                let result = IOPMAssertionCreateWithName(kIOPMAssertionTypePreventUserIdleSystemSleep as CFString,
                    IOPMAssertionLevel(kIOPMAssertionLevelOn), "Harness working agents" as CFString, &value)
                if result == kIOReturnSuccess { assertion = value; assertionFailure = nil }
                else {
                    assertionFailure = "The macOS idle-sleep assertion could not be acquired."
                    retryAt = Date().addingTimeInterval(5)
                }
            }
        } else { releaseAssertion() }
        #endif
    }
    private func stopOnQueue() {
        enabled = false; timer?.cancel(); timer = nil; graceUntil = nil
        #if os(macOS)
        powerSourceObservation?.stop(); powerSourceObservation = nil
        releaseAssertion()
        if notifier != 0 { IODeregisterForSystemPower(&notifier); notifier = 0 }
        callbackContext.closeRoot(); rootPort = 0
        if let port { IONotificationPortDestroy(port); self.port = nil }
        if DispatchQueue.getSpecific(key: notificationQueueKey) != true { notificationQueue.sync {} }
        #endif
    }
    #if os(macOS)
    private func releaseAssertion() {
        if let assertion { IOPMAssertionRelease(assertion); self.assertion = nil }
        assertionFailure = nil
    }
    private static func powerSource() -> PowerSource {
        guard let info = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let state = IOPSGetProvidingPowerSourceType(info)?.takeUnretainedValue() as String? else { return .unknown }
        if state == kIOPMACPowerKey { return .ac }
        // A UPS is battery power for policy purposes, never implicit permission to drain it.
        if state == kIOPMBatteryPowerKey || state == kIOPMUPSPowerKey { return .battery }
        return .unknown
    }
    private func receive(_ message: UInt32) {
        guard enabled else { return }
        switch message {
        case harness_power_will_sleep():
            sleepingAt = .now; releaseAssertion(); onSleep?()
        case harness_power_did_wake():
            let now = Date()
            lastSleepSeconds = sleepingAt.map { max(0, now.timeIntervalSince($0)) }
            lastWakeAt = now; sleepingAt = nil
            onWake?(lastSleepSeconds); evaluate()
        case harness_power_sleep_cancelled(): sleepingAt = nil; evaluate()
        default: break
        }
    }
    #endif
}
