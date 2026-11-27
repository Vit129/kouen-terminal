import Foundation
import KouenCore

extension AgentSessionHistoryModel {
    /// The hosting view owns the lifetime. File events trigger a scan, with a slower
    /// fallback for CLI-only status and provider directories created after History opens.
    func watchLiveHistory() async {
        let watcher = FileTreeWatcher()
        let (updates, continuation) = AsyncStream<Void>.makeStream(bufferingPolicy: .bufferingNewest(1))
        let fallback = Task {
            var watchedPaths: [String]?
            while !Task.isCancelled {
                let paths = AgentHistoryScanner.sourceDirectories.filter {
                    FileManager.default.fileExists(atPath: $0)
                }
                if watchedPaths != paths {
                    await watcher.startWatching(rootPaths: paths) { continuation.yield() }
                    watchedPaths = paths
                }
                continuation.yield()
                do {
                    try await Task.sleep(for: .seconds(30))
                } catch {
                    break
                }
            }
        }

        await followHistoryUpdates(updates)
        fallback.cancel()
        await fallback.value
        continuation.finish()
        await watcher.stopWatching()
    }

    func followHistoryUpdates(
        _ updates: AsyncStream<Void>,
        scanner: AgentHistoryScanner = .shared
    ) async {
        let showLoading = records.isEmpty && !isLoading
        if showLoading { isLoading = true }
        defer { if showLoading { isLoading = false } }

        for await _ in updates {
            guard !Task.isCancelled else { return }
            let scanned = await scanner.scanAll()
            guard !Task.isCancelled else { return }
            if records != scanned { records = scanned }
            if showLoading && isLoading { isLoading = false }

            // Keep one pending event while a scan runs and rate-limit continuous appends.
            do {
                try await Task.sleep(for: .seconds(1))
            } catch {
                return
            }
        }
    }
}
