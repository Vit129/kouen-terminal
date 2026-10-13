import Foundation
import HarnessCore
import HarnessDaemonCore
#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif

if CommandLine.arguments.dropFirst().first == "--terminal-pipe-worker" { exit(TerminalPipeWorker.runWorker()) }

let ownership: DaemonInstanceLock
let service: SessionHostService
nonisolated(unsafe) var signals: [DispatchSourceSignal] = []
do {
    do { ownership = try DaemonInstanceLock() }
    catch let error as POSIXError where error.code == .EWOULDBLOCK { throw SessionHostStartupError.ownedByLiveService }
    switch DaemonOwnership.probe() {
    case .alive: throw SessionHostStartupError.ownedByLiveService
    case .uncertain: throw SessionHostStartupError.ownershipUncertain
    case .absent: break
    }
    try HarnessPaths.ensureDirectories()
    try "\(getpid())\n".write(to: HarnessPaths.daemonPIDURL, atomically: true, encoding: .utf8)
    _ = chmod(HarnessPaths.daemonPIDURL.path, 0o600)
    ignoreSIGPIPE()
    // The host owns live PTYs that must outlive the terminal or app that launched it, so a hangup
    // is not a stop request. Children still start with default dispositions (harness_reset_signals).
    signal(SIGHUP, SIG_IGN)
    let executable = URL(fileURLWithPath: CommandLine.arguments[0]).resolvingSymlinksInPath()
    service = SessionHostService(daemonExecutable: HarnessToolLocator.companion("HarnessDaemon", to: executable))
    service.onShutdown = finishShutdown
    for number in [SIGTERM, SIGINT] {
        signal(number, SIG_IGN)
        let source = DispatchSource.makeSignalSource(signal: number, queue: .global())
        source.setEventHandler(handler: handleStopSignal)
        source.resume(); signals.append(source)
    }
    try service.start()
    dispatchMain()
} catch SessionHostStartupError.ownedByLiveService {
    // A zero status tells launchd's KeepAlive (SuccessfulExit = false) the service is satisfied.
    // Failing here made launchd relaunch every ThrottleInterval for as long as another owner,
    // such as one the app started directly, stayed alive.
    fputs("HarnessSessionHost: another session service already owns this home; exiting without changes.\n", harnessStderr)
    exit(0)
} catch {
    DaemonLifecycle.removeOwnedPIDFile(at: HarnessPaths.daemonPIDURL, ownPID: getpid())
    fputs("HarnessSessionHost: \(error.localizedDescription); startup refused without interrupting an existing owner.\n", harnessStderr)
    exit(1)
}
enum SessionHostStartupError: LocalizedError {
    case ownedByLiveService, ownershipUncertain
    var errorDescription: String? {
        switch self {
        case .ownedByLiveService: "Another session service owns this home"
        case .ownershipUncertain: "The existing service owner cannot be verified"
        }
    }
}

// Functions, not closure literals: top-level closures inherit main-actor isolation, and these
// run on signal and owner queues, where Swift's isolation check would trap.
@Sendable private func finishShutdown() {
    DaemonLifecycle.removeOwnedPIDFile(at: HarnessPaths.daemonPIDURL, ownPID: getpid())
    exit(0)
}

@Sendable private func handleStopSignal() {
    if service.stop() { service.onShutdown?() }
}
