# XCTest — macOS Swift Testing

Write XCTest unit/integration tests for macOS Swift packages and app targets.
Covers Swift 6 concurrency, @Observable model testing, async/await tests,
and the XCTest↔Robot Framework boundary for a terminal-style app.

---

## Layer Boundary — XCTest vs Robot

| What | Tool |
|------|------|
| Pure logic: algorithms, parsers, policies, codecs | **XCTest** |
| `@Observable` model state + transitions | **XCTest** |
| IPC / daemon protocol end-to-end | **Robot** (`Tests/robot/`) |
| UI regression / window interactions | **Robot** or skip — XCUITest is fragile |

Rule: if it needs a running daemon or a real window → Robot. Everything else → XCTest.

---

## Reference

| Task | Load |
|------|------|
| Swift 6 concurrency in tests, @MainActor, async/await | § Swift 6 Test Patterns below |

---

## Where Tests Live

```
Tests/
  AppCoreTests/        # AppCore package — pure logic
  TerminalKitTests/ # TerminalKit package — terminal engine
  AppIPCTests/         # IPC codec, framing
  MyAppTests/         # App-layer models (needs @testable import MyApp)
```

Add a new target in `Package.swift` when the directory doesn't exist yet.

---

## Testability Rule for MyApp Models

`MyApp` is a GUI app target. `@Observable` models declared `private` inside
a source file **cannot** be reached by `@testable import MyApp`.

Fix before writing the test — pick one:

1. **Promote to `internal`** (drop `private`) — enough for `@testable import`
2. **Extract to a package** (`AppDomain`, `AppUI`) — preferred for models
   that grow beyond one screen
3. **Test via the public caller** — only when the model is thin and the caller
   is already covered

Do not write tests that require making a type `public` just to reach it.

---

## Swift 6 Test Patterns

Read this section before writing tests against `@MainActor`
or `@Observable` types:

```swift
// @MainActor model → @MainActor test class
@MainActor
final class PaletteModelTests: XCTestCase {
    func testRebuildRowsEmpty() {
        let model = PaletteModel(actions: [], recentIDs: [], mode: .normal)
        XCTAssertTrue(model.rows.isEmpty)
    }
}

// async test
func testFileScanPopulatesEntries() async throws {
    let model = PaletteModel(actions: [], recentIDs: [], mode: .normal)
    model.startFileScan()
    try await Task.sleep(for: .milliseconds(200))
    XCTAssertFalse(model.cachedFileEntries.entries.isEmpty)
}
```

---

## Anti-Patterns

| Anti-pattern | Fix |
|---|---|
| Mocking `@Observable` with a protocol | Don't — pass real lightweight instances |
| `DispatchQueue.main.async` in test to "wait" | Use `async/await` + `Task.sleep` or `XCTestExpectation` |
| Testing `private` type without promoting it | Promote to `internal` first |
| One giant test covering multiple behaviors | One assertion per `func test…` |
| Asserting on UI layout / frame sizes | Test model state, not view geometry |
| `XCTAssert` with no message on non-obvious condition | Add `— "reason"` param |
| Shared mutable state between test methods | Each test creates its own instance |

---

## Minimal Runnable Check 

Every non-trivial logic change ships with ONE test that fails without the change:

```swift
// Good — fails if the policy ever removes the cap
func testDelayCapsAt1Second() {
    XCTAssertEqual(DaemonReconnectPolicy.delay(forAttempt: 999), 1.0, accuracy: 0.001)
}
```

No frameworks, no fixtures, no mocks — just the thing that breaks if the logic breaks.

---

## Running

```bash
swift test                          # full suite
swift test --filter ModelTests      # filtered
swift test --filter "PaletteModel"  # by class name
```

Run `Tests/robot/run.sh` separately — it needs a built daemon binary.
