import Foundation
import HarnessCore
import HarnessTerminalEngine

struct DaemonObservationCheckpoint: Codable, Sendable {
    static let currentVersion = 2
    var version = Self.currentVersion
    var surfaces: [String: SurfaceObservationCheckpoint]
    var activity: ActivityMemoryCheckpoint?
}
struct SurfaceObservationCheckpoint: Codable, Sendable {
    var nextSequence: UInt64
    var scanner: PtyStreamScanner
    var status: ProgramStatusBook
    var modes: KeyboardModeMirror
    var streamIdentity: String?
    var openCommand: ShellCommandSpan?
    var lastCommand: ShellCommandSpan?
}

extension SurfaceRegistry {
    func startHostedObservations() {
        guard let host = SessionHostClient.configured else { return }
        observationQueue.async { [weak self] in
            guard let self, self.hostedEventChannel == nil else { return }
            do {
                self.hostedAcknowledgements.removeAll()
                self.hostedEventClient = host
                self.hostedEventChannel = try host.observe(onEvent: { [weak self] event in self?.receiveHostedEvent(event) }, onEnd: { [weak self] in
                    self?.observationQueue.async { [weak self] in
                        guard let self else { return }
                        self.hostedEventChannel = nil; self.hostedEventClient = nil
                        guard !self.hostedEventReconnectScheduled else { return }
                        self.hostedEventReconnectScheduled = true
                        self.observationQueue.asyncAfter(deadline: .now() + 1) { [weak self] in
                            guard let self else { return }
                            self.hostedEventReconnectScheduled = false
                            self.startHostedObservations()
                        }
                    }
                })
                self.lock.lock(); let sessions = self.sessions; self.lock.unlock()
                for (id, session) in sessions where session.isHosted { self.recoverObserver(surfaceKey: id, session: session) }
            } catch {
                self.publishObserverFailure("Terminal events are unavailable; reconnecting from retained output. " + error.localizedDescription)
                self.observationQueue.asyncAfter(deadline: .now() + 1) { [weak self] in self?.startHostedObservations() }
            }
        }
    }
    func sendHostCheckpoint(_ data: Data) throws {
        guard hasHostedObservation else { return }
        let connection = observationQueue.sync { (hostedEventClient, hostedEventChannel) }
        guard let client = connection.0, let channel = connection.1 else {
            throw SessionHostError.refused("The terminal event channel is disconnected; checkpoint was not accepted.")
        }
        try client.sendCheckpoint(data, channel: channel)
    }
    private func receiveHostedEvent(_ event: HostedPtyEvent) {
        switch event {
        case let .output(id, observation):
            lock.lock(); let session = sessions[id]; lock.unlock()
            observeSurfaceEvents(surfaceKey: id, observation: observation, session: session)
        case let .metadata(states, agents):
            observationQueue.async { [weak self] in
                guard let self else { return }
                self.lock.lock()
                var accepted: Set<String> = []
                for (id, state) in states {
                    if let session = self.sessions[id], session.streamIdentity == state.streamIdentity {
                        session.updateState(state); accepted.insert(id)
                    }
                }
                self.lock.unlock()
                self.refreshSurfaceMetadata(parents: [:])
                let currentAgents = agents.filter { accepted.contains($0.key) }
                if !currentAgents.isEmpty { self.applyAgentChanges(currentAgents) }
            }
        case let .exited(id, identity, status):
            observationQueue.async { [weak self] in
                guard let self else { return }
                self.lock.lock(); let session = self.sessions[id]; self.lock.unlock()
                if let session, session.streamIdentity == identity { session.markExited(); self.removeSurfaceIfCurrent(surfaceID: id, session: session, exitStatus: status) }
                self.hostedAcknowledgements.removeValue(forKey: identity)
                self.wakeSchedulesIfCreated(); self.wakeFanoutIfCreated()
            }
        }
    }
    func observeSurfaceEvents(surfaceKey: String, observation: HostedOutputObservation, session: SessionPty?) {
        guard observationBudget.reserve(observation.byteCount) else {
            if hasHostedObservation { observationQueue.async { [weak self] in self?.hostedEventChannel?.closeChannel() } }
            if let session { scheduleObserverRecovery(surfaceKey: surfaceKey, session: session) }
            return
        }
        observationQueue.async { [weak self, weak session] in
            guard let self else { return }
            defer { self.observationBudget.release(observation.byteCount) }
            self.monitorLock.lock()
            let stampNeeded = self.monitors[surfaceKey]?.streamIdentity != observation.streamIdentity
            self.monitorLock.unlock()
            self.lock.lock()
            let suspended = self.quiesced
            let current = self.sessions[surfaceKey]
            let identityMatches = current == nil || current?.streamIdentity == observation.streamIdentity
            if identityMatches && stampNeeded { self.rememberMonitorIdentity(surfaceID: surfaceKey) }
            self.lock.unlock()
            guard !suspended, identityMatches else { return }
            let session = current ?? session
            self.monitorLock.lock(); let floor = self.monitors[surfaceKey]?.lastOutputSequence ?? observation.sequence; self.monitorLock.unlock()
            if observation.sequence > floor, let session { self.recoverObserver(surfaceKey: surfaceKey, session: session) }
            self.monitorLock.lock(); let next = self.monitors[surfaceKey]?.lastOutputSequence ?? floor; self.monitorLock.unlock()
            defer {
                self.acknowledgeHostedObservation(surfaceKey: surfaceKey, identity: observation.streamIdentity,
                    start: observation.sequence, end: observation.endSequence, force: !observation.events.isEmpty)
            }
            guard observation.endSequence > next else { return }
            let start = max(next, observation.sequence)
            let events = observation.events.filter { $0.endSequence > start }
            self.monitorLock.lock()
            var monitor = self.monitors[surfaceKey] ?? SurfaceMonitor()
            monitor.streamIdentity = observation.streamIdentity
            monitor.statusScan = observation.scanner ?? PtyStreamScanner()
            self.monitors[surfaceKey] = monitor
            self.monitorLock.unlock()
            session?.updateOutput(observation)
            if let reply = self.noteSurfaceEvents(surfaceKey: surfaceKey, events: events,
                byteCount: Int(observation.endSequence - start), sequence: start) { session?.write(reply) }
        }
    }
    func scheduleObserverRecovery(surfaceKey: String, session: SessionPty) {
        monitorLock.lock(); let first = observerRecoveries.insert(surfaceKey).inserted; monitorLock.unlock()
        guard first else { return }
        observationQueue.async { [weak self, weak session] in
            guard let self, let session else { return }; self.recoverObserver(surfaceKey: surfaceKey, session: session)
        }
    }
    func recoverObserver(surfaceKey: String, session: SessionPty) {
        defer { monitorLock.lock(); observerRecoveries.remove(surfaceKey); monitorLock.unlock() }
        lock.lock(); let available = sessions[surfaceKey] === session && !quiesced; lock.unlock()
        guard available else { return }
        monitorLock.lock(); let recoveryStart = monitors[surfaceKey]?.lastOutputSequence ?? 1; monitorLock.unlock()
        defer {
            monitorLock.lock(); let consumed = monitors[surfaceKey]?.lastOutputSequence ?? recoveryStart; monitorLock.unlock()
            if let identity = session.streamIdentity {
                acknowledgeHostedObservation(surfaceKey: surfaceKey, identity: identity,
                    start: recoveryStart, end: consumed, force: true)
            }
        }
        while true {
            monitorLock.lock(); let floor = monitors[surfaceKey]?.lastOutputSequence ?? 1; monitorLock.unlock()
            let replay: AttachHistory
            do { replay = try session.observationReplay(fromSequence: floor) }
            catch {
                publishObserverFailure("Activity replay is temporarily unavailable; its parser checkpoint is retained. " + error.localizedDescription)
                observationQueue.asyncAfter(deadline: .now() + 1) { [weak self, weak session] in
                    guard let self, let session else { return }; self.scheduleObserverRecovery(surfaceKey: surfaceKey, session: session)
                }
                return
            }
            if replay.resync {
                let start = replay.chunks.first?.sequence ?? replay.endSequence
                monitorLock.lock()
                var monitor = monitors[surfaceKey] ?? SurfaceMonitor()
                monitor.statusScan = PtyStreamScanner(); monitor.openCommand = nil; monitor.lastOutputSequence = start
                monitors[surfaceKey] = monitor
                monitorLock.unlock()
                publishObserverFailure("Some activity output exceeded retained replay. Live terminal output remains available; activity history may have a gap.")
            }
            for chunk in replay.chunks {
                monitorLock.lock(); let next = monitors[surfaceKey]?.lastOutputSequence ?? floor; monitorLock.unlock()
                let skip = next > chunk.sequence ? min(UInt64(chunk.data.count), next - chunk.sequence) : 0
                let bytes = Data(chunk.data.dropFirst(Int(skip)))
                if !bytes.isEmpty, let reply = noteSurfaceOutput(surfaceKey: surfaceKey, data: bytes, sequence: chunk.sequence + skip, replaying: true) { session.write(reply) }
            }
            guard !replay.chunks.isEmpty else { return }
        }
    }

    private func acknowledgeHostedObservation(surfaceKey: String, identity: String, start: UInt64, end: UInt64, force: Bool) {
        guard let host = hostedEventClient, let channel = hostedEventChannel,
              let sequence = Self.observationAcknowledgement(start: start, end: end, force: force,
                  acknowledgedThrough: &hostedAcknowledgements[identity]) else { return }
        host.acknowledgeEvents(surfaceID: surfaceKey, streamIdentity: identity, sequence: sequence, channel: channel)
    }

    /// Keep the first byte fence even when a stream has no semantic events. Recovery
    /// releases its parsed prefix on return, including a partial recovery before retry.
    static func observationAcknowledgement(start: UInt64, end: UInt64, force: Bool,
                                           acknowledgedThrough: inout UInt64?) -> UInt64? {
        let prior = acknowledgedThrough ?? start
        acknowledgedThrough = prior
        guard end > prior, force || end - prior >= 512 << 10 else { return nil }
        acknowledgedThrough = end
        return end
    }

    func publishObserverFailure(_ message: String) {
        lock.lock(); editor.snapshot.activityError = message; editor.snapshot.revision += 1; let revision = editor.snapshot.revision; lock.unlock()
        onSnapshotCommitted?(revision)
    }
    func observationCheckpoint() -> IPCResponse {
        monitorLock.lock()
        let surfaces = monitors.mapValues { monitor in
            SurfaceObservationCheckpoint(nextSequence: monitor.lastOutputSequence, scanner: monitor.statusScan,
                status: monitor.programStatus, modes: monitor.modeMirror,
                streamIdentity: monitor.streamIdentity, openCommand: monitor.openCommand, lastCommand: monitor.lastCommand)
        }
        monitorLock.unlock()
        do {
            let data = try JSONEncoder().encode(DaemonObservationCheckpoint(surfaces: surfaces, activity: try activity.checkpoint()))
            guard data.count <= 4 << 20 else { return .error("Observation checkpoint exceeds the handover budget.") }
            return .text(String(decoding: data, as: UTF8.self))
        } catch { return .error("Observation checkpoint could not be encoded.") }
    }
    func restoreObservations(_ data: Data) -> String? {
        guard data.count <= 4 << 20, let checkpoint = try? JSONDecoder().decode(DaemonObservationCheckpoint.self, from: data), checkpoint.version == DaemonObservationCheckpoint.currentVersion else {
            return "Daemon observation checkpoint is incompatible; retain the current daemon."
        }
        lock.lock(); let live = sessions; lock.unlock()
        var replays: [String: AttachHistory] = [:], total = 0
        for (id, observation) in checkpoint.surfaces {
            guard let pty = live[id] else { continue }
            guard let state = try? pty.liveState(), state.ringStart <= observation.nextSequence else { return "Observation replay was evicted or its owner is unavailable; retain the current daemon." }
            guard let replay = pty.attachHistory(history: true, fromSequence: observation.nextSequence, screenOnResync: false, includeCheckpoint: false), !replay.resync else { return "Session-host observation replay is unavailable or was evicted." }
            total += replay.chunks.reduce(0) { $0 + $1.data.count }
            guard total <= 32 << 20 else { return "Observation replay exceeded the bounded handover budget." }
            replays[id] = replay
        }
        monitorLock.lock()
        for (id, observation) in checkpoint.surfaces {
            var monitor = monitors[id] ?? SurfaceMonitor()
            monitor.statusScan = observation.scanner
            monitor.programStatus = observation.status; monitor.modeMirror = observation.modes
            monitor.streamIdentity = observation.streamIdentity; monitor.openCommand = observation.openCommand; monitor.lastCommand = observation.lastCommand
            monitor.lastOutputSequence = observation.nextSequence; monitor.statusDirty = true
            monitors[id] = monitor
        }
        monitorLock.unlock()
        for (id, replay) in replays {
            let floor = checkpoint.surfaces[id]!.nextSequence
            for chunk in replay.chunks {
                let skip = floor > chunk.sequence ? min(UInt64(chunk.data.count), floor - chunk.sequence) : 0
                let bytes = Data(chunk.data.dropFirst(Int(skip)))
                if !bytes.isEmpty { _ = noteSurfaceOutput(surfaceKey: id, data: bytes, sequence: chunk.sequence + skip, replaying: true) }
            }
        }
        return nil
    }
}

final class ObservationBudget: @unchecked Sendable {
    private let lock = NSLock()
    private var bytes = 0, entries = 0
    func reserve(_ count: Int) -> Bool {
        lock.lock(); defer { lock.unlock() }
        guard count <= 32 << 20, bytes <= (32 << 20) - count, entries < 32768 else { return false }
        bytes += count; entries += 1; return true
    }
    func release(_ count: Int) { lock.lock(); bytes -= count; entries -= 1; lock.unlock() }
}
