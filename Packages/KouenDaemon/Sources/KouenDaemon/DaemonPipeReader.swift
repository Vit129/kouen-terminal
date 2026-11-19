import Foundation
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

/// Drains raw stdout for callers that need streaming or binary data.
enum DaemonPipeReader {
    static func drain(_ reader: FileHandle, from process: Process, consume: (Data) -> Void) {
        defer { try? reader.close() }
        let clock = ContinuousClock()
        var exitDeadline: ContinuousClock.Instant?
        var bytes = [UInt8](repeating: 0, count: 64 * 1024)
        while true {
            if !process.isRunning, exitDeadline == nil {
                // Descendants can inherit the writer even after Foundation reaps the child.
                exitDeadline = clock.now + .seconds(2)
            }
            if let exitDeadline, clock.now >= exitDeadline { return }

            var descriptor = pollfd(fd: reader.fileDescriptor, events: Int16(POLLIN | POLLHUP), revents: 0)
            let ready = poll(&descriptor, 1, 100)
            if ready == 0 || (ready < 0 && errno == EINTR) { continue }
            guard ready > 0 else { return }
            let count = read(reader.fileDescriptor, &bytes, bytes.count)
            if count < 0 && errno == EINTR { continue }
            guard count > 0 else { return }
            consume(Data(bytes.prefix(count)))
        }
    }
}
