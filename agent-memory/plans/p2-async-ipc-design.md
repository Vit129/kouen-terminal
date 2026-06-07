# P2 — Async IPC Refactor: Design Document

Status: **completed** — fully implemented. IPC and metadata updates are transitioned to non-blocking async/await (via DaemonClientActor and background Task contexts).

---

## ปัญหา

`DaemonSessionService.fetchSnapshot()` และ `requestDaemon(_:)` เป็น **synchronous blocking calls** บน `@MainActor`:

```swift
// DaemonSessionService.swift
public func fetchSnapshot() throws -> SessionSnapshot {
    let response = try request(.getSnapshot)   // blocks up to 2 seconds
    ...
}

// SessionCoordinator.swift
@discardableResult
func syncFromDaemon(metadataOnly: Bool = false) -> Bool {
    let remote = try daemon.fetchSnapshot()     // blocks main thread
    snapshot = remote
    ...
}
```

ผลกระทบ:
- ทุก tab switch / pane select / session click → IPC round-trip บน main thread → UI stutter
- 40+ call sites เรียก `requestDaemon()` (sync) + `syncFromDaemon()` (sync) ต่อกัน
- `DaemonClient` ใช้ `NSLock` เพื่อ thread safety → ไม่ใช่ async-native

---

## เป้าหมาย

```text
Before:
  User action → @MainActor → fetchSnapshot() [block 2s max] → update UI

After:
  User action → @MainActor → Task { await fetchSnapshot() } [off-main wait] → @MainActor update UI
```

---

## สถาปัตยกรรมที่เลือก: Actor-wrapped DaemonClient

### Option A — Actor wrapper (แนะนำ ✅)

```swift
// DaemonClientActor.swift (new)
actor DaemonClientActor {
    private let inner: DaemonClient   // existing NSLock-based client

    func request(_ req: IPCRequest, timeout: TimeInterval = 2) async throws -> IPCResponse {
        // hop off main actor; inner.request is sync+blocking but safe from any thread
        try await Task.detached(priority: .userInitiated) {
            try self.inner.request(req, timeout: timeout)
        }.value
    }
}
```

**장점:**
- `DaemonClient` ไม่ต้องแก้ — NSLock ยังทำงานได้
- Actor isolation ป้องกัน data race โดยอัตโนมัติ
- `Task.detached` หนีออกจาก main actor executor

**ข้อระวัง:**
- `Task.detached` ไม่ inherit actor context — ต้องระวัง captures
- `DaemonClient` ยังคง `@unchecked Sendable` — ต้อง audit ว่า safe จริง

### Option B — Continuation bridging

```swift
func fetchSnapshot() async throws -> SessionSnapshot {
    try await withCheckedThrowingContinuation { continuation in
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let snap = try self.inner.fetchSnapshot()   // sync, off-main
                continuation.resume(returning: snap)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
```

**단점:** ต้องสร้าง wrapper ทุก method, verbose กว่า Option A

**เลือก Option A** เพราะสะอาดกว่าและ reusable ทุก method

---

## แผนการ Migrate แบบ Incremental (ไม่ Break ทุกอย่างพร้อมกัน)

### Step 1 — สร้าง `DaemonClientActor` (ไม่แตะ call sites)

```swift
// Packages/HarnessCore/Sources/HarnessCore/IPC/DaemonClientActor.swift
actor DaemonClientActor {
    private let client: DaemonClient

    init(client: DaemonClient) {
        self.client = client
    }

    func request(_ req: IPCRequest, timeout: TimeInterval = 2) async throws -> IPCResponse {
        let c = client  // capture before detach
        return try await Task.detached(priority: .userInitiated) {
            try c.request(req, timeout: timeout)
        }.value
    }

    func switchEndpoint(_ endpoint: Endpoint) async {
        let c = client
        await Task.detached { c.switchEndpoint(endpoint) }.value
    }

    func ping() async -> Bool {
        let c = client
        return await Task.detached { c.ping() }.value
    }
}
```

### Step 2 — `DaemonSessionService` ใช้ async

```swift
// DaemonSessionService.swift
public func fetchSnapshot() async throws -> SessionSnapshot {
    let response = try await actor.request(.getSnapshot)
    guard case let .snapshot(snapshot) = response else {
        throw DaemonSessionError.unexpectedResponse
    }
    return snapshot
}

public func request(_ req: IPCRequest) async throws -> IPCResponse {
    try await actor.request(req)
}
```

### Step 3 — `syncFromDaemon` เป็น async

```swift
// SessionCoordinator.swift
@discardableResult
func syncFromDaemon(metadataOnly: Bool = false) async -> Bool {
    let remote: SessionSnapshot
    do {
        remote = try await daemon.fetchSnapshot()   // off-main wait
    } catch {
        fputs("Harness: snapshot fetch failed: \(error)\n", harnessStderr)
        noteDaemonError(error)
        return false
    }
    // Everything below stays on @MainActor (class is @MainActor-isolated)
    snapshot = remote
    ...
    return true
}
```

### Step 4 — อัปเดต call sites แบบ batched

**กลุ่มที่ 1 — Simple mutation methods** (~25 sites):
```swift
// Before
_ = requestDaemon(.addTab(...))
syncFromDaemon()

// After
Task {
    _ = await requestDaemon(.addTab(...))
    await syncFromDaemon()
}
```

**กลุ่มที่ 2 — @objc selectors** (ใช้ Task wrapper):
```swift
@objc private func addTab() {
    Task { await addTabAsync() }
}
private func addTabAsync() async { ... }
```

**กลุ่มที่ 3 — `closeEphemeralSessionsBeforeQuit()`** (ต้องเป็น sync):
```swift
// ต้องคงเป็น sync เพราะเรียกก่อน process exit
// ใช้ semaphore bridge:
func closeEphemeralSessionsBeforeQuit() {
    let sema = DispatchSemaphore(value: 0)
    Task.detached {
        _ = try? await self.daemon.request(.closeEphemeralSessions, timeout: 4)
        sema.signal()
    }
    sema.wait()
}
```

**กลุ่มที่ 4 — `connectToRemote()`** (มี `DispatchQueue.global` อยู่แล้ว):
```swift
// ปัจจุบัน: DispatchQueue.global + DispatchQueue.main.async
// เปลี่ยนเป็น: Task.detached + @MainActor
func connectToRemote(named name: String) {
    Task.detached(priority: .userInitiated) { [weak self] in
        let result = Result { try RemoteHostsService.shared.connect(named: name) }
        await MainActor.run { [weak self] in
            switch result {
            case .success(let endpoint): self?.applyEndpointSwitch(endpoint)
            case .failure(let error): self?.noteDaemonError(error)
            }
        }
    }
}
```

---

## ไฟล์ที่ต้องแก้ไข

| ไฟล์ | การเปลี่ยนแปลง |
|------|---------------|
| `Packages/HarnessCore/Sources/HarnessCore/IPC/DaemonClientActor.swift` | **New** — actor wrapper |
| `Packages/HarnessCore/Sources/HarnessCore/IPC/DaemonSessionService.swift` | เพิ่ม async methods |
| `Apps/Harness/Sources/HarnessApp/Services/SessionCoordinator.swift` | `syncFromDaemon` async + 40+ call sites |
| `Apps/Harness/Sources/HarnessApp/Services/DaemonLauncher.swift` | async callback |
| `Apps/Harness/Sources/HarnessApp/UI/ContentAreaViewController.swift` | Task wrappers |
| `Apps/Harness/Sources/HarnessApp/UI/HarnessSidebarPanelViewController.swift` | Task wrappers |

---

## ความเสี่ยงและ Mitigation

| ความเสี่ยง | Mitigation |
|-----------|------------|
| Race condition ใน `snapshot` reads | `@MainActor` isolation คงไว้ — snapshot ยังเขียนบน main actor เสมอ |
| `NSLock` ใน `DaemonClient` deadlock | `Task.detached` ไม่ hold main-actor lock ก่อน enter |
| `@objc` selector ไม่รองรับ `async` | Wrap ด้วย `Task {}` shim method |
| `closeEphemeralSessionsBeforeQuit` ต้อง sync | Semaphore bridge — isolated, bounded timeout |
| Test coverage | ต้องเขียน mock `DaemonClientActor` สำหรับ unit tests |

---

## ลำดับการทำ

```text
1. DaemonClientActor (new file, ไม่ break อะไร)
2. DaemonSessionService + async methods (เพิ่ม parallel กับ sync versions ก่อน)
3. syncFromDaemon async
4. Call site migration แบบ file-by-file (SessionCoordinator ก่อน)
5. ลบ sync versions เมื่อ migrate ครบ
6. Integration test ทั้ง local + remote endpoint
```

**ประมาณเวลา:** 2–3 sessions (ไม่ควรทำรวดเดียวเพราะ 40+ call sites มีโอกาส introduce regression)
