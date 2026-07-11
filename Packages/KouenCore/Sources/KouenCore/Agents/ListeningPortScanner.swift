import Foundation

/// Batched TCP-listening-port lookup for a set of surface root PIDs — the daemon-side half of
/// P39 G1 (cmux-style "dev server running here" sidebar badge). Passive `URLDetection` only
/// catches ports a server *prints* while its pane is being actively rendered; this catches a
/// server that started before attach or never printed a URL, for every pane, visible or not.
///
/// One `lsof` fork per scan tick covers every surface (the union of their process trees), not
/// one per pane — same batching principle as `AgentDetector.scan()`.
public enum ListeningPortScanner {
    /// `roots`: surfaceKey -> the pane's root child PID (same PID registered with
    /// `AgentDetector.registerRootPID`). Returns surfaceKey -> sorted unique listening ports;
    /// surfaces with no listeners are omitted.
    public static func scan(roots: [String: Int32]) -> [String: [Int]] {
        guard !roots.isEmpty else { return [:] }
        let allPIDs = ProcessScan.livePIDs()
        guard !allPIDs.isEmpty else { return [:] }
        var parentMap: [Int32: Int32] = [:]
        parentMap.reserveCapacity(allPIDs.count)
        for pid in allPIDs { parentMap[pid] = ProcessScan.parentPID(pid) }

        var surfacePIDs: [String: Set<Int32>] = [:]
        var unionPIDs = Set<Int32>()
        for (key, root) in roots {
            var pids = Set(AgentDetector.descendantPIDs(of: root, allPIDs: allPIDs, parentMap: parentMap))
            pids.insert(root)
            surfacePIDs[key] = pids
            unionPIDs.formUnion(pids)
        }
        guard !unionPIDs.isEmpty else { return [:] }

        let portsByPID = listeningPorts(forPIDs: unionPIDs)
        guard !portsByPID.isEmpty else { return [:] }

        var result: [String: [Int]] = [:]
        for (key, pids) in surfacePIDs {
            let ports = Set(pids.compactMap { portsByPID[$0] }.flatMap { $0 })
            if !ports.isEmpty { result[key] = ports.sorted() }
        }
        return result
    }

    /// Runs `lsof -F pn` once for the given PIDs (machine-parseable field output: `p<pid>` then
    /// one `n<name>` per listening socket) rather than screen-scraping the human table format.
    private static func listeningPorts(forPIDs pids: Set<Int32>) -> [Int32: [Int]] {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/lsof")
        process.arguments = [
            "-a", "-p", pids.map(String.init).joined(separator: ","),
            "-iTCP", "-sTCP:LISTEN", "-n", "-P", "-F", "pn",
        ]
        let stdoutPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = FileHandle.nullDevice
        do {
            try process.run()
        } catch {
            return [:]
        }
        let data = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        guard let text = String(data: data, encoding: .utf8) else { return [:] }
        return parseFieldOutput(text)
    }

    /// Pure parser for `lsof -F pn` output, split out from the process-spawning code above so
    /// the parsing logic (the actual non-trivial part) is unit-testable without forking `lsof`.
    static func parseFieldOutput(_ text: String) -> [Int32: [Int]] {
        var result: [Int32: [Int]] = [:]
        var currentPID: Int32?
        for line in text.split(separator: "\n") {
            guard let tag = line.first else { continue }
            let value = line.dropFirst()
            switch tag {
            case "p":
                currentPID = Int32(value)
            case "n":
                // Port is always the segment after the last ':' — holds for both IPv4
                // ("*:3000") and bracketed IPv6 ("[::1]:3000") listen-address notation.
                guard let pid = currentPID,
                      let portToken = value.split(separator: ":").last,
                      let port = Int(portToken)
                else { continue }
                result[pid, default: []].append(port)
            default:
                continue
            }
        }
        return result
    }
}
