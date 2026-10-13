import XCTest
@testable import HarnessDaemonCore

/// Closing a pane hangs up its terminal: ordinary background jobs end, jobs the user
/// detached with `nohup` keep running.
final class PaneCloseJobPolicyTests: XCTestCase {
    override func setUpWithError() throws {
        try skipUnlessLiveDaemonTests()
    }

    func testCloseEndsBackgroundJobsAndKeepsDetachedOnes() throws {
        let marker = "harnessjob\(Int.random(in: 100_000...999_999))"
        // Bash forwards the hangup to its jobs; dash, which is /bin/sh on Debian, does not.
        let pty = try RealPty(id: UUID().uuidString, cwd: NSTemporaryDirectory(), shell: "/bin/bash",
                              rows: 24, cols: 80, scrollbackBytes: 65536)
        pty.start()
        let output = OutputAccumulator()
        _ = pty.subscribe { data, _ in _ = output.appendAndContains(String(decoding: data, as: UTF8.self), marker: "") }
        pty.write("perl -e '$0=\"\(marker)bg\"; sleep 60' &\n")
        pty.write("nohup perl -e '$0=\"\(marker)nohup\"; sleep 60' >/dev/null 2>&1 &\n")
        pty.write("echo READY_$((1+1))\n")
        XCTAssertTrue(waitUntil(timeout: 10) { output.contains("READY_2") })
        XCTAssertTrue(waitUntil(timeout: 5) { Self.processes(named: marker).count == 2 })

        pty.close()
        XCTAssertTrue(waitUntil(timeout: 8) { Self.processes(named: marker + "bg").isEmpty }, "background job outlived its pane")
        let detached = Self.processes(named: marker + "nohup")
        XCTAssertEqual(detached.count, 1, "the nohup job should keep running")
        for pid in Self.processes(named: marker) { kill(pid, SIGKILL) }
    }

    private static func processes(named prefix: String) -> [pid_t] {
        let ps = Process()
        ps.executableURL = URL(fileURLWithPath: "/bin/ps")
        ps.arguments = ["-eo", "pid=,args="]
        let pipe = Pipe()
        ps.standardOutput = pipe
        guard (try? ps.run()) != nil else { return [] }
        let raw = pipe.fileHandleForReading.readDataToEndOfFile()
        ps.waitUntilExit()
        return String(decoding: raw, as: UTF8.self).split(separator: "\n").compactMap { line in
            let fields = line.split(separator: " ", maxSplits: 1)
            guard fields.count == 2, fields[1].hasPrefix(prefix) else { return nil }
            return pid_t(fields[0])
        }
    }
}
