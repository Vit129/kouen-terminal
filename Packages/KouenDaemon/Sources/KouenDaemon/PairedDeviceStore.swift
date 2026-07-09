#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif
import Foundation
import KouenCore

/// P25 F3: persistent (disk-backed, survives a daemon restart) record of devices paired
/// to the mobile WS bridge. Owned by `DaemonServer` so `kouen-cli mobile-list-clients`/
/// `mobile-revoke-client` (ordinary IPC requests) can read/mutate it; `MobileBridgeServer`
/// registers new devices on successful pairing and sets `onRevoke` so a revoke can cancel
/// the live connection. Kept in KouenDaemonCore proper (not gated behind
/// `canImport(Network)`) so the IPC surface compiles identically on every platform — on
/// Linux (bridge never starts) it just always reports zero devices.
///
/// Storage mirrors `RemoteHostStore`'s pattern (small, read-rarely JSON list, atomic write,
/// `flock` sidecar) — this process is the only writer today (mutations arrive over IPC,
/// funneled through this one daemon), so the file lock is defense-in-depth rather than a
/// load-bearing requirement, same reasoning `RemoteHostStore` documents for its own case.
public final class PairedDeviceStore: @unchecked Sendable {
    private let lock = NSLock()
    private var devices: [String: PairedDeviceRecord] = [:]

    /// P37: per-device re-auth secrets expire this long after issuance. A phone that's been
    /// away longer must re-scan a QR (which mints a fresh secret) — bounds the blast radius of
    /// a leaked/stolen device credential without a live revocation, the same reasoning a
    /// refresh-token TTL uses.
    static let secretLifetime: TimeInterval = 30 * 24 * 60 * 60

    /// On-disk record. Distinct from `PairedDeviceSummary` (the IPC/CLI DTO) precisely because
    /// it carries the re-auth secret — which MUST NOT ride out over IPC to `mobile-list-clients`,
    /// so it never becomes a field on the summary type. Only a SHA-256 `secretHash` is persisted,
    /// never the plaintext: the plaintext exists exactly once, in the `{deviceCredentials}` frame
    /// sent to the client at pairing, and is discarded here immediately after hashing. `secretHash`
    /// is optional so an old `[PairedDeviceSummary]` JSON file (P25, no secrets) still decodes
    /// cleanly — those legacy devices stay listed but can't re-auth (nil hash → auth always fails),
    /// forcing a one-time re-scan. Likewise a pre-hash P37-dev file's `secret` key is simply ignored.
    struct PairedDeviceRecord: Codable {
        var id: String
        var label: String
        var pairedAt: Date
        var secretHash: String?
    }

    /// Set by `MobileBridgeServer` after `start()`; called with a device id when
    /// `revoke(id:)` finds and removes a matching entry, so the live WS connection
    /// (if still attached) gets cancelled too — not just dropped from the table.
    public var onRevoke: (@Sendable (String) -> Void)?

    public init() {
        let loaded = Self.loadFromDisk()
        lock.lock()
        devices = Dictionary(uniqueKeysWithValues: loaded.map { ($0.id, $0) })
        lock.unlock()
    }

    /// P37 A2: `secret` is the per-device credential the client stores and replays on
    /// reconnect (so a returning device never needs a fresh QR scan). Only its SHA-256 hash is
    /// persisted here — the plaintext is not retained. Kept out of the IPC DTO — see
    /// `PairedDeviceRecord`.
    public func register(id: String, label: String, secret: String) {
        lock.lock()
        defer { lock.unlock() }
        let hash = SHA256Mini.hexDigest(Array(secret.utf8))
        withFileLock {
            devices[id] = PairedDeviceRecord(id: id, label: label, pairedAt: Date(), secretHash: hash)
            saveLocked()
        }
    }

    /// P37 A2/A2+: constant-time check of a returning device's `{id, secret}`. False for an
    /// unknown id, a legacy (hash-less) record, a mismatched secret, or a secret older than
    /// `secretLifetime` — in every case the client falls back to a fresh token pairing (which
    /// re-issues credentials). Revoke drops the record, so a revoked device fails here too (the
    /// secret is invalidated by removal). The presented secret is hashed and compared against
    /// the stored hash, so the plaintext never has to be kept on disk to verify it.
    public func authenticate(id: String, secret: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        guard let record = devices[id], let storedHash = record.secretHash else { return false }
        guard Date() < record.pairedAt.addingTimeInterval(Self.secretLifetime) else { return false }
        let presentedHash = SHA256Mini.hexDigest(Array(secret.utf8))
        return constantTimeEquals(Array(storedHash.utf8), Array(presentedHash.utf8))
    }

    public func list() -> [PairedDeviceSummary] {
        lock.lock()
        defer { lock.unlock() }
        return devices.values
            .sorted { $0.pairedAt < $1.pairedAt }
            .map { PairedDeviceSummary(id: $0.id, label: $0.label, pairedAt: $0.pairedAt) }
    }

    @discardableResult
    public func revoke(id: String) -> Bool {
        lock.lock()
        var existed = false
        withFileLock {
            existed = devices.removeValue(forKey: id) != nil
            if existed { saveLocked() }
        }
        lock.unlock()
        if existed { onRevoke?(id) }
        return existed
    }

    // MARK: - Inter-process locking (caller must already hold `lock`)

    /// Degrades to running `body` unlocked if the lock file can't be opened/locked — same
    /// tradeoff `RemoteHostStore.withFileLock` documents: a missing cross-process lock is
    /// strictly less safe than skipping persistence entirely, never worse.
    private func withFileLock(_ body: () -> Void) {
        try? KouenPaths.ensureDirectories()
        let lockPath = KouenPaths.pairedDevicesLockURL.path
        let fd = open(lockPath, O_RDWR | O_CREAT | O_CLOEXEC, 0o600)
        guard fd >= 0 else { body(); return }
        defer { close(fd) }
        guard flock(fd, LOCK_EX) == 0 else { body(); return }
        defer { flock(fd, LOCK_UN) }
        body()
    }

    // MARK: - Disk I/O

    private static func loadFromDisk() -> [PairedDeviceRecord] {
        let url = KouenPaths.pairedDevicesURL
        guard FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url)
        else { return [] }
        // `PairedDeviceRecord` is a strict superset of the P25 on-disk shape (adds an
        // *optional* `secret`), so a pre-P37 file decodes here directly — no separate
        // migration pass, the missing key just leaves `secret` nil.
        if let decoded = try? JSONDecoder().decode([PairedDeviceRecord].self, from: data) {
            return decoded
        }
        KouenPaths.backupCorruptFile(at: url, label: "PairedDeviceStore")
        return []
    }

    /// Caller must already hold `lock`.
    @discardableResult
    private func saveLocked() -> Bool {
        try? KouenPaths.ensureDirectories()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(Array(devices.values)) else { return false }
        return KouenPaths.atomicWrite(data, to: KouenPaths.pairedDevicesURL, label: "PairedDeviceStore")
    }
}

/// Length-tolerant constant-time byte equality (P37 A1/A2). Accumulates the XOR of every
/// byte pair instead of returning on the first mismatch, so compare time doesn't leak how
/// long a shared prefix a guess got right — the timing side-channel a brute-forcer would
/// otherwise use to home in on a token/secret one byte at a time. A length mismatch is
/// folded into the accumulator, not short-circuited. Shared by `PairedDeviceStore` (secret)
/// and `MobileBridgeServer` (pairing token); lives here (not `canImport(Network)`-gated) so
/// both callers see it. ponytail: not general-purpose crypto — only these fixed, short,
/// ASCII credentials; a full HMAC-compare would be more code for no added guarantee here.
func constantTimeEquals(_ a: [UInt8], _ b: [UInt8]) -> Bool {
    var diff = a.count ^ b.count
    let n = max(a.count, b.count)
    for i in 0..<n {
        let x = i < a.count ? a[i] : 0
        let y = i < b.count ? b[i] : 0
        diff |= Int(x ^ y)
    }
    return diff == 0
}

/// Minimal dependency-free SHA-256 (FIPS 180-4). Hand-rolled rather than adding swift-crypto
/// because of the project's "no new dependency" rule AND because this must compile on the Linux
/// headless daemon, where CryptoKit is absent. Used only to hash the device re-auth secret at
/// rest — the secret is 256 bits of CSPRNG output, so a bare (unsalted, unstretched) hash is
/// enough: there's no low-entropy password to brute-force, the hash just keeps the plaintext off
/// disk. Correctness is pinned by a known-answer test (SHA-256("abc")) in `PairedDeviceStoreTests`;
/// do not touch this without re-running it.
enum SHA256Mini {
    private static let k: [UInt32] = [
        0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
        0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
        0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
        0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
        0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
        0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
        0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
        0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
    ]

    static func hexDigest(_ input: [UInt8]) -> String {
        var h: [UInt32] = [0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
                           0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19]
        var msg = input
        let bitLen = UInt64(input.count) &* 8
        msg.append(0x80)
        while msg.count % 64 != 56 { msg.append(0) }
        for shift in stride(from: 56, through: 0, by: -8) {
            msg.append(UInt8((bitLen >> UInt64(shift)) & 0xff))
        }
        func rotr(_ x: UInt32, _ n: UInt32) -> UInt32 { (x >> n) | (x << (32 - n)) }
        for chunk in stride(from: 0, to: msg.count, by: 64) {
            var w = [UInt32](repeating: 0, count: 64)
            for i in 0..<16 {
                let j = chunk + i * 4
                w[i] = (UInt32(msg[j]) << 24) | (UInt32(msg[j + 1]) << 16)
                     | (UInt32(msg[j + 2]) << 8) | UInt32(msg[j + 3])
            }
            for i in 16..<64 {
                let s0 = rotr(w[i - 15], 7) ^ rotr(w[i - 15], 18) ^ (w[i - 15] >> 3)
                let s1 = rotr(w[i - 2], 17) ^ rotr(w[i - 2], 19) ^ (w[i - 2] >> 10)
                w[i] = w[i - 16] &+ s0 &+ w[i - 7] &+ s1
            }
            var (a, b, c, d, e, f, g, hh) = (h[0], h[1], h[2], h[3], h[4], h[5], h[6], h[7])
            for i in 0..<64 {
                let s1 = rotr(e, 6) ^ rotr(e, 11) ^ rotr(e, 25)
                let ch = (e & f) ^ (~e & g)
                let t1 = hh &+ s1 &+ ch &+ k[i] &+ w[i]
                let s0 = rotr(a, 2) ^ rotr(a, 13) ^ rotr(a, 22)
                let maj = (a & b) ^ (a & c) ^ (b & c)
                let t2 = s0 &+ maj
                hh = g; g = f; f = e; e = d &+ t1; d = c; c = b; b = a; a = t1 &+ t2
            }
            h[0] = h[0] &+ a; h[1] = h[1] &+ b; h[2] = h[2] &+ c; h[3] = h[3] &+ d
            h[4] = h[4] &+ e; h[5] = h[5] &+ f; h[6] = h[6] &+ g; h[7] = h[7] &+ hh
        }
        return h.map { String(format: "%08x", $0) }.joined()
    }
}
