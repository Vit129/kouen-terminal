import Foundation
#if os(macOS)
import Darwin
#else
import Glibc
#endif

/// Watches the containing directory so atomic replacements and first creation
/// remain observable without a retry timer on macOS.
public final class FileWatcher: @unchecked Sendable {
    private struct Identity: Equatable {
        var device: UInt64, inode: UInt64, size: Int64
        var modifiedSeconds: Int64, modifiedNanoseconds: Int64
        var changedSeconds: Int64, changedNanoseconds: Int64
    }
    private let url: URL
    private let debounce: DispatchTimeInterval
    private let callbackQueue: DispatchQueue
    private let onChange: @Sendable () -> Void
    private let queue = DispatchQueue(label: "com.robert.harness.filewatcher", qos: .utility)
    private var pendingChange: DispatchWorkItem?
    private var identity: Identity?
    #if os(macOS)
    private var source: DispatchSourceFileSystemObject?
    private var watchedDirectory: URL?
    private var fileSource: DispatchSourceFileSystemObject?
    private var watchedFile: (device: UInt64, inode: UInt64)?
    #else
    private var source: DispatchSourceTimer?
    #endif

    public init(url: URL, debounce: DispatchTimeInterval = .milliseconds(200),
                callbackQueue: DispatchQueue = .main, onChange: @escaping @Sendable () -> Void) {
        self.url = url; self.debounce = debounce
        self.callbackQueue = callbackQueue; self.onChange = onChange
        identity = Self.identity(at: url)
        queue.async { [weak self] in self?.arm() }
    }

    deinit {
        source?.cancel(); pendingChange?.cancel()
        #if os(macOS)
        fileSource?.cancel()
        #endif
    }

    private static func identity(at url: URL) -> Identity? {
        var info = stat()
        guard stat(url.path, &info) == 0 else { return nil }
        #if os(macOS)
        let modified = info.st_mtimespec, changed = info.st_ctimespec
        #else
        let modified = info.st_mtim, changed = info.st_ctim
        #endif
        return Identity(device: UInt64(info.st_dev), inode: UInt64(info.st_ino), size: Int64(info.st_size),
            modifiedSeconds: Int64(modified.tv_sec), modifiedNanoseconds: Int64(modified.tv_nsec),
            changedSeconds: Int64(changed.tv_sec), changedNanoseconds: Int64(changed.tv_nsec))
    }

    private func arm() {
        #if os(macOS)
        var directory = url.deletingLastPathComponent()
        var descriptor = open(directory.path, O_EVTONLY | O_CLOEXEC)
        while descriptor < 0, directory.path != "/" {
            directory.deleteLastPathComponent()
            descriptor = open(directory.path, O_EVTONLY | O_CLOEXEC)
        }
        guard descriptor >= 0 else { return }
        if watchedDirectory == directory { close(descriptor); return }
        let fileDescriptor = descriptor
        source?.cancel()
        let source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fileDescriptor,
            eventMask: [.write, .extend, .rename, .delete, .attrib], queue: queue)
        source.setEventHandler { [weak self] in
            guard let self else { return }
            let removed = self.source?.data.intersection([.rename, .delete]).isEmpty == false
            if removed { self.source?.cancel(); self.source = nil; self.watchedDirectory = nil }
            self.checkForChange()
            self.arm()
        }
        source.setCancelHandler { close(fileDescriptor) }
        self.source = source; watchedDirectory = directory
        source.resume()
        checkForChange()
        #else
        let source = DispatchSource.makeTimerSource(queue: queue)
        source.schedule(deadline: .now() + 2, repeating: 2, leeway: .milliseconds(200))
        source.setEventHandler { [weak self] in self?.checkForChange() }
        self.source = source; source.resume()
        #endif
    }

    #if os(macOS)
    private func watchFile(_ identity: Identity?) {
        if let identity, let watchedFile,
           watchedFile.device == identity.device, watchedFile.inode == identity.inode { return }
        fileSource?.cancel(); fileSource = nil; watchedFile = nil
        guard let identity else { return }
        let descriptor = open(url.path, O_EVTONLY | O_CLOEXEC)
        guard descriptor >= 0 else { return }
        // Directory events cover replacement; the file itself reports in-place writes.
        let source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: descriptor,
            eventMask: [.write, .extend, .attrib, .rename, .delete, .revoke], queue: queue)
        source.setEventHandler { [weak self] in self?.checkForChange() }
        source.setCancelHandler { close(descriptor) }
        fileSource = source; watchedFile = (identity.device, identity.inode)
        source.resume()
    }
    #endif

    private func checkForChange() {
        let next = Self.identity(at: url)
        #if os(macOS)
        watchFile(next)
        #endif
        guard next != identity else { return }
        identity = next; pendingChange?.cancel()
        let callback = onChange, callbackQueue = callbackQueue
        let work = DispatchWorkItem { callbackQueue.async(execute: callback) }
        pendingChange = work
        queue.asyncAfter(deadline: .now() + debounce, execute: work)
    }
}
