import Foundation

/// Watches a single script file path for on-disk changes and invokes a callback.
/// Reuses the single-file DispatchSource watcher pattern referenced in RL-011.
@MainActor
final class ScriptFileWatcher {
    private var source: DispatchSourceFileSystemObject?
    private var reloadWorkItem: DispatchWorkItem?
    private let debounceInterval: TimeInterval

    init(debounceInterval: TimeInterval = 0.3) {
        self.debounceInterval = debounceInterval
    }

    /// Start watching `path`, replacing any previous watch. `onChange` fires on the
    /// main queue, debounced.
    func start(path: String, onChange: @escaping () -> Void) {
        stop()
        let fd = open(path, O_EVTONLY)
        guard fd >= 0 else { return }

        let newSource = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fd,
            eventMask: [.write, .delete, .rename, .extend, .attrib],
            queue: .main
        )
        newSource.setEventHandler { [weak self] in
            self?.scheduleReload(onChange)
        }
        newSource.setCancelHandler {
            close(fd)
        }
        newSource.resume()
        source = newSource
    }

    func stop() {
        reloadWorkItem?.cancel()
        reloadWorkItem = nil
        source?.cancel()
        source = nil
    }

    private func scheduleReload(_ onChange: @escaping () -> Void) {
        reloadWorkItem?.cancel()
        let work = DispatchWorkItem(block: onChange)
        reloadWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + debounceInterval, execute: work)
    }

    deinit {
        source?.cancel()
    }
}
