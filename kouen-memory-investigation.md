# รายงานตรวจสอบการใช้หน่วยความจำสูงของ Kouen Terminal

## อาการ

Kouen Terminal ใช้หน่วยความจำประมาณ 600 MB ระหว่างใช้งาน จากการตรวจ process ที่ติดตั้งอยู่ `/Applications/Kouen.app` เวอร์ชัน 4.22.11 พบว่า physical footprint เพิ่มขึ้นต่อระหว่างการตรวจ

| ช่วงตรวจ | Physical footprint | Malloc Small |
|---|---:|---:|
| ครั้งแรก | 642 MB | 499 MB |
| ครั้งถัดมา | 802 MB | 660 MB |
| ภายหลัง | 825 MB | 681 MB |
| ครั้งล่าสุดที่บันทึก | 881 MB | 738 MB |

process นี้เคยมี footprint สูงสุดประมาณ 1.1 GB ตั้งแต่เปิดแอปรอบนั้น Physical footprint ไม่เท่ากับ RSS โดยตรง เพราะ footprint รวมหน่วยความจำที่ถูกบีบอัดหรือสลับออกด้วย ณ ครั้งแรก RSS ของแอปหลักอยู่ราว 185 MB ส่วน KouenDaemon มี RSS ราว 16 MB และเป็นคนละ process

## ผลตรวจแอปหลัก

### ก้อนหลักเกี่ยวข้องกับ RenderBox

คำสั่ง `heap -s -H --guessNonObjects` จัดกลุ่ม allocation ที่ระบุเป็น `RB::DisplayList::Contents` และ allocation ที่เครื่องมือ **คาดว่าเกี่ยวข้องกัน** ได้ดังนี้:

| ประเภทที่เครื่องมือรายงาน | ขนาดโดยประมาณ |
|---|---:|
| `RB::DisplayList::Contents[32]` | 256 MB |
| `RB::DisplayList::Contents[16]` | 164 MB |
| `RB::DisplayList::Contents` | 46 MB |
| **รวม** | **466 MB** |

RenderBox เป็นส่วนของระบบวาด UI บน macOS ตัวเลขสองแถวแรกเป็นการจัดกลุ่มโดยตัวเลือก `--guessNonObjects` จึงควรมองว่าเป็นการระบุความสัมพันธ์โดยประมาณ ไม่ใช่หลักฐานว่า allocation ทุกก้อนมีเจ้าของตามชื่อนั้นแน่นอน

การเก็บ CPU sample พบการวาดข้อความผ่าน SwiftUI และ RenderBox รวมถึง `ViewGraph.updateOutputs(at:)` จึงสอดคล้องกับผล heap ว่าแอปกำลังทำงานในเส้นทางวาด UI แต่ sample ไม่ได้ระบุว่า view ใดเป็นผู้ทำให้หน่วยความจำสะสม

### Terminal grid ไม่ใช่ก้อนใหญ่ที่ระบุชนิดได้

ใน heap รอบเดียวกันพบ:

| ชนิดข้อมูล | ขนาดโดยประมาณ |
|---|---:|
| `TerminalGridCell` array storage | 3.3 MB |
| terminal glyph instance array storage | 4.7 MB |
| Swift string storage | 18.5 MB |

ตัวเลขเหล่านี้ไม่ครอบคลุมหน่วยความจำทั้งหมดที่ terminal อาจเกี่ยวข้อง แต่ไม่มีหลักฐานว่าข้อมูล terminal สองชนิดที่ระบุได้ข้างต้นเป็นต้นเหตุของก้อนหลายร้อย MB

### ยังไม่ยืนยันว่าเป็น memory leak

คำสั่ง `leaks` รายงาน 9 leaks รวม 368 bytes ซึ่งไม่อธิบายก้อนหลายร้อย MB

ผลนี้ไม่ได้พิสูจน์ว่าไม่มีปัญหาการเก็บหน่วยความจำ: หาก object ยังถูกอ้างอิงอยู่ แม้แอปจะไม่จำเป็นต้องใช้แล้ว เครื่องมืออาจไม่จัดเป็น leak การเพิ่มจาก 642 MB เป็น 881 MB ระหว่างที่แอปใช้งานอยู่ก็ยังแยกไม่ได้ว่าเกิดจากการสะสมผิดปกติ การใช้งานที่เพิ่มขึ้น หรือหน่วยความจำที่ระบบเก็บไว้เพื่อใช้ซ้ำ

## เบาะแสจากโค้ด

ที่ `Apps/Kouen/Sources/KouenApp/UI/Terminal/TerminalTabBarView.swift:598` มีคำอธิบายว่า animation ของ working dot เคยทำให้ SwiftUI ViewGraph วาดซ้ำทุก frame และมีการย้าย animation ไปใช้ CALayer แล้ว

เบาะแสนี้แสดงว่าโปรเจกต์เคยมีปัญหา UI วาดซ้ำ แต่ยังไม่มีหลักฐานว่าปัญหาเดิมกลับมา หรือเป็นสาเหตุของ RenderBox memory ครั้งนี้ CPU sample ยังพบการอัปเดต terminal tab bar ในช่วงที่เก็บตัวอย่าง แต่การเกิดขึ้นในช่วงเดียวกันไม่เพียงพอจะสรุปความเป็นเหตุและผล

## ผลตรวจ preview ที่แยกจากแอปหลัก

สร้าง worktree `fix/ui-memory` จาก `origin/main` และรัน Robot regression ได้ 26/26 ผ่าน

การเปิด preview โดยตรงทำให้ footprint ขึ้นเกิน 1.6 GB อย่างรวดเร็ว จึงหยุดเฉพาะ preview เพื่อไม่ให้ใช้หน่วยความจำต่อ การตรวจ heap และ CPU sample ของ preview พบว่า:

- heap มีก้อน `CFString`, `NSDictionary` และข้อมูลที่เกี่ยวข้องกับ JSON จำนวนมาก
- CPU sample ชี้ไปที่ `AgentHistoryScanner.scanClaude()`, `parseClaudeTranscript(...)` และ JSON parsing ระหว่างอ่าน transcript

นี่เป็นหลักฐานของ memory spike ระหว่าง scan history ใน preview แต่ชนิดของ allocation ต่างจากก้อน RenderBox ที่พบในแอปหลัก จึงยังสรุปไม่ได้ว่าเป็นสาเหตุเดียวกัน

## การให้ DeepSeek ตรวจเพิ่ม

DeepSeek ตรวจแบบ read-only โดยไล่ดู history scanner, FTS index และหน้า SwiftUI หลายส่วน ก่อนเริ่มวนกลับไปอ่านไฟล์เดิม จึงหยุดการทำงานหลังประมาณ 7 นาทีครึ่ง

DeepSeek ไม่ได้ส่งรายงานสุดท้าย และไม่มีข้อสรุปใหม่ที่ยืนยันต้นเหตุได้ ตรวจ `git status` ของ worktree แล้วไม่มีไฟล์เปลี่ยน

## สถานะและสิ่งที่ต้องตรวจต่อ

**ยังไม่ได้แก้ไขปัญหา** และยังไม่ได้เปลี่ยนแอปที่ติดตั้งอยู่

ขั้นต่อไปคือสร้าง repro ใน preview ที่ทำให้ RenderBox display list โตเหมือนแอปหลัก แล้วเก็บ allocation stack หรือ memory graph ก่อน–หลัง โดยเปรียบเทียบกิจกรรมทีละอย่าง เช่น เปิดแอปค้างไว้ ใช้ terminal และเปิดหรือปิดหน้า UI ที่เกี่ยวข้อง การทดสอบต้องแยกช่วง scan history ออกจากช่วงวัด RenderBox เพื่อไม่ให้ memory spike อีกประเภทบดบังผล

เมื่อระบุ view และเส้นทางที่ทำให้โตได้แล้ว จึงแก้เฉพาะจุดและวัดซ้ำด้วยขั้นตอนเดียวกัน เพื่อยืนยันว่าหน่วยความจำลดลงโดยไม่กระทบพฤติกรรมของแอป

---

# ภาคผนวก — บันทึกจาก copilot-deepseek

> **เนื้อหาตั้งแต่บรรทัดนี้ลงไปเขียนโดย `copilot-deepseek`** (GitHub Copilot CLI ที่รันบนโมเดล deepseek) ไม่ใช่ผลตรวจของ Claude หรือ agy
> หลักฐานทั้งหมดอ้างจาก `git log` / โค้ดในรีโป ณ วันที่ 6 พ.ย. 2026 — ไม่ได้รันแอปหรือเก็บ heap เอง
> เป้าหมายของภาคผนวกนี้: เทียบว่างาน **fleet 9 ต.ค.** และงานฝั่ง **agy (18/26 ต.ค.)** เกี่ยวกับ UI ที่ทำให้ RenderBox โตหรือไม่ แล้วตกลงแนวทางแก้ร่วมกัน

## ภาคผนวก 1 — fleet 9 ต.ค. (P54) กระทบ UI ไหม → กระทบ ตรงจุด

commit เดียว: `12a2f224` (9 ต.ค. 2026, Merge PR #81, `Co-Authored-By: Gemini 3.8 Flash`)
ชื่อเต็ม: `feat(sidebar): project folder auto-sync, fold fleet into projects & auto-open chrome on rc (P54)`

| ไฟล์ | เปลี่ยนอะไร |
|---|---|
| `UI/Sidebar/KouenSidebarPanelViewController.swift` | **retire Tab 5 (Fleet)** — ย้าย Fleet เข้า Projects tab |
| `UI/Sidebar/ProjectGroupWatcher.swift` | **ไฟล์ใหม่** — FSEvents watcher (depth-1) |
| `UI/Sidebar/ProjectDirectoryTree.swift` | +157 บรรทัด เชื่อม watcher เข้า `syncCategory` |
| `UI/Sidebar/SidebarSessionListView.swift` | +87 บรรทัด ชิป All / Agents / Waiting |
| `UI/Sidebar/SidebarWorkspaceViews.swift` | ปรับ layout |
| `UI/Terminal/FleetView.swift` | ถูกฝังใน Projects tab |
| `UI/Terminal/FleetViewModel.swift` | +18 บรรทัด เพิ่ม `refresh(from:activeSurfaceID:)` |

หมายเหตุ: งานชื่อ "fleet" อีกชิ้นคือ `0b70deac` (15 ต.ค., PR #106 `fix/fleet-launchagent-repo`, แก้ `UI/Automations/AutomationsFleetModel.swift`) — คนละคน ไม่มี trailer ของ Gemini

### เส้นทางที่ทำให้ UI วาดซ้ำ (น่าสงสัยที่สุดสำหรับ RenderBox)

1. `FleetViewModel.swift:77` เขียน doc comment ไว้เองว่า *"Cheap enough (plain array walk + sort, no I/O) to call on **every `snapshotChanged` notification**"*
2. `KouenSidebarPanelViewController.reload()` (บรรทัด 1274) เรียก `fleetModel.refresh(...)` ทุกครั้งที่ `sidebarSectionModel.selectedTab == 0` (Projects — ที่ที่ Fleet ถูกย้ายมา)
3. `FleetViewModel` เป็น `@Observable` และ **assign `items` แบบไม่เช็คค่าซ้ำ** → republish ทุกครั้ง → `FleetView` (`List(model.filteredItems)`) rebuild ทั้ง list → เข้าเส้นทางวาดของ RenderBox
4. P54 ยังเพิ่ม **`ProjectGroupWatcher`** (FSEvent stream ตอน `sourceFolder` เปลี่ยน) → `onTrigger` → `syncCategory` → mutate `projectStore.projects` → เรียก `reload()` เพิ่มอีกชั้น = แหล่ง refresh ชุดใหม่ที่เพิ่งเกิด 9 ต.ค.
5. ฝั่ง tab bar: `TerminalTabBarView.reload/update` assign `model.tabs` แบบไม่เช็คค่า + `TabPillView` subscribe `snapshotChanged` (คอมเมนต์ในโค้ดเองบอก *"can fire many times per second"*) แล้ว `tasks = updatedTasks` แบบไม่มี guard

**สรุป**: fleet P54 กระทบ UI ชัดเจน และเป็นผู้ต้องสงสัยลำดับต้นของก้อน `RB::DisplayList::Contents` — แต่ยังไม่ใช่ข้อสรุปว่าเป็น "สาเหตุเดียว" (รายงานเองก็ยังไม่ยืนยันว่า leak)

### fix ที่ค้างอยู่ใน working tree (ยังไม่ commit)
- `FleetViewModel.swift`: `let newItems = ...` แล้ว `if items != newItems { items = newItems }`
- `TerminalTabBarView.swift`: guard การ assign ทุกตัว, `taskRefreshTask` → `TabTaskRefreshState`, เช็ค `Task.isCancelled`, `.onDisappear { cancel + nil }`, ข้ามเมื่อ `workspaces` ไม่เปลี่ยน

## ภาคผนวก 2 — 18 ต.ค. `8c5e0c8d` P59 (agy session, **unreviewed**)

`wip(perf): P59 performance hardening as left by the agy session (unreviewed)` — trailer: `Antigravity Gemini` + `Claude Opus 5.5`, 18 ไฟล์
ข้อความ commit ระบุเองว่าเป็น snapshot ของงานที่ยังไม่รีวิว เพื่อย้ายออกจาก checkout ที่ใช้ร่วมกัน แล้วค่อยตามด้วย review fixes

| ไฟล์ | เปลี่ยนอะไร | เกี่ยวกับ memory ยังไง |
|---|---|---|
| `UI/FileEditor/MarkdownPreviewView.swift` | `WKWebView` กลายเป็น **optional + lazy** (`ensureWebView()` สร้างเมื่อใช้จริง) | ลด memory เมื่อไม่เคยเปิด preview — **but** `update(markdown:)` ตอนนี้ต้องผ่านทั้ง `isWebViewReady` และ webView ไม่ nil; `viewDidChangeEffectiveAppearance` / `copy` early-return |
| `UI/FileTree/FileTreeSwiftUIView.swift` | `Dictionary(uniqueKeysWithValues:)` → `uniquingKeysWith` (กัน crash dup key) + แยก `runGitCommand` ที่เรียก `Process()` ตรงใน UI | `Process()` ใน UI — ถูกกำจัดภายหลังโดยงาน 25 ต.ค. |
| `UI/Chrome/BrowserPaneView.swift` | ยก `DateFormatter` เป็น `static let`, encode PNG ผ่าน `cgImage` แทน tiff round-trip, log ไฟล์ถูก truncate ที่ 500 KB, ลบ temp log ตอน `deinit` | ลด churn — allocation ต่อ log batch หายไป |
| `UI/Chrome/PaneLifecycleManager.swift` | เพิ่ม **MRU cache + `maxCachedContainers = 8`**, evict แล้ว `removeFromSuperview()` | เป็นการ **จำกัด memory ของ pane ที่ถูก cache ไว้** — ญาติใกล้ชิดกับอาการ RenderBox |
| `KouenCore/Agents/AgentHistoryScanner.swift` | cache `ISO8601DateFormatter`/`DateFormatter` ใต้ `NSLock`, เพิ่ม `fileCache` เป็น `inout` | ตัว scanner ที่รายงานด้านบนชี้ว่าเป็นต้นเหตุ spike ตอน preview |
| `KouenCore/Agents/AgentHistoryFTSIndex.swift` (+189) | rework index | เกี่ยวข้องกับเส้นทาง scan/preview |
| `KouenDaemon/MobileBridgeServer.swift` (+67), `WorkspaceSymbolIndex.swift` (+101), `SplitPaneCoordinator.swift`, `GitStatusProvider.swift`, `KouenCommands/KeyTable.swift`, `Antigravity`/`CodexTranscript` | เก็บกวาด/แยกคอนเนกชัน | ไม่ใช่ UI โดยตรง |

**อ่านผล**: งานนี้เดินไปทาง **"ทำให้ UI เบาลง"** จึงไม่น่าเป็น *สาเหตุ* ของอาการ — แต่เป็นหลักฐานว่าเส้นทาง pane/webview cache เคยถูกมองว่าเป็น memory sink มาก่อน และมันแอบเปลี่ยนพฤติกรรม `MarkdownPreviewView` (lazy webview) ⇒ ตอนแก้อาการรอบนี้ต้อง retest preview ด้วย

## ภาคผนวก 3 — 26 ต.ค. `993bfd90` ProcessRunner rewrite

`fix(core): resolve ProcessRunner regressions in timeouts, output draining, and async concurrency` — trailer: `Antigravity Gemini 3.8 Flash`, 7 ไฟล์

- `ProcessRunner` เขียนใหม่: `AsyncRunCoordinator` (`@unchecked Sendable` + `NSLock`), `runAsync` เป็นแบบ non-blocking ด้วย `withCheckedContinuation` + `terminationHandler`, `timeout` กลายเป็น optional (`nil` = ไม่จำกัด)
- **API change**: เพิ่มฟิลด์ `ProcessResult.isTimedOut` ⇒ กระทบ caller ทุกตัว
- ฝั่ง UI: `GitPanelView.runShellCommand` คง timeout 300 + รวม stdout+stderr, `runGit(..., timeout:)` รับพารามิเตอร์ใหม่, `CommandPaletteController.grepMatches` ยอมรับ exit code 2 / timed out
- ⚠️ จุดน่าสงสัย: `GitResult(output: combined, stderr: combined, success:)` — ตั้งค่า output กับ stderr เป็น string เดียวกัน ซ้ำกัน น่าจะไม่ตั้งใจ
- เกี่ยวกับ memory: อ่อน — ไม่มีเส้นทางวาด UI แต่ `AsyncRunCoordinator` ถือ state แบบ `@unchecked Sendable` + `DispatchWorkItem` ต่อการรันหนึ่งครั้ง ⇒ ถ้ามี git call ค้างสะสมควรนับด้วย

## ภาคผนวก 4 — io / logic / dom / ui: เรามีตอนไหน และเกี่ยวไหม

**ที่มา**: เป็น **Dev-QA Pattern 5-Layer Separation** ซึ่งลงจริงใน Kouen วันที่ **25 ต.ค. 2026**
- PR #122 (`456b522e`): `f6b40e3a` establish QA architecture guard + extract `KouenGit`
- PR #123 (`65a52752`): `2c7640f9` extract `KouenCompositor`, `c95e9eba` purify `KouenIPC` + unify Layer 2 tokens, `ca7164d7` complete (ProcessRunner ratchet G3 → 0, Rule 2/3 guards, layered test tags)
- ตัวบังคับใช้: `Tests/KouenArchitectureGuardTests/ArchitectureGuardTests.swift` → **G1** zero UI imports ใน headless packages, **G2** zero rogue colors, **G3** `Process()` ใน UI (ratchet ปัจจุบัน = **0**), **G4** zero unmanaged language literals, **G5** layered test tags, **G7** zero cross-package duplication, **G10** negative control

เทียบชื่อที่ใช้กันในทีม กับของจริงใน Kouen:

| ชั้น (ที่เรียกกัน) | ของจริงใน Kouen | guard |
|---|---|---|
| **io** | `Packages/KouenGit`, `KouenCore/Platform/ProcessRunner`, `KouenIPC` | G3 (Process() ใน UI = 0) |
| **logic** | Layer 1 headless `KouenCore` (+ `KouenSettings`, `KouenCommands`, `KouenTheme`, `KouenTerminalEngine`) | G1 (zero UI imports) |
| **dom** (ชั้นเรนเดอร์) | `KouenCompositor`, `KouenTerminalRenderer`, `KouenTerminalEngine` | G7 |
| **ui** | `Apps/Kouen/Sources/KouenApp/UI` (+ `KouenOnboarding/UI`) | G2, G4 |
| translator / strings | บังคับผ่าน G4 | G |

**เรื่อง provenance ที่ต้องบันทึกไว้**: commit ชุด 25 ต.ค. **ไม่มี `Co-Authored-By` trailer เลย** (author/committer = `Vit129`) ⇒ git ไม่ได้บันทึกว่า antigravity เป็นผู้ทำ ถ้าจะยืนยันต้องไปดู session/history ของ agy เอง — ส่วน commit ที่มี trailer Antigravity ชัดเจนมีแค่ `8c5e0c8d` (18 ต.ค.) และ `993bfd90` (26 ต.ค.)
แหล่งของ pattern (global): `~/.claude/rules/coding.md` § "Logic vs UI split (every repo)" และ `~/.claude/skills/ai-sdlc/references/dev-qa-pattern.md`

**เกี่ยวหรือไม่** — เกี่ยวในเชิง *ข้อบังคับตอนแก้* มากกว่าเป็นสาเหตุของ memory:
1. `FleetViewModel` วางอยู่ใน `UI/` แต่เนื้อในเป็น pure flatten/filter/sort ล้วน ⇒ ตาม pattern ต้องย้ายส่วนคำนวณไป headless (`logic`) ให้ UI เหลือแค่ render แล้วได้ unit test ที่รันได้โดยไม่มี UI — ซึ่งจะทำให้ A/B ทดสอบ churn ได้แม่นขึ้นด้วย
2. ห้ามแก้ด้วยการเพิ่ม `Process()` ใน UI (G3 = 0) ⇒ การวัด/เก็บ heap ต้องทำผ่าน script หรือ Core ไม่ใช่ใน view
3. ห้ามเพิ่มสี literal (G2) และ string ภาษาต่างประเทศ (G4) ในไฟล์ที่แก้
4. ถ้าแตะ `MarkdownPreviewView` / `FileTreeSwiftUIView` (ของ P59) ให้รัน ArchitectureGuardTests ทั้งชุด

## ภาคผนวก 5 — แนวทางแก้ที่จะทำร่วมกัน

1. **Repro ก่อน** ใน preview (`fix/ui-memory` worktree) — เปิดแอปค้างไว้โดยไม่แตะ UI เทียบกับเปิด Projects tab ค้าง ⇒ แยกผลของ fleet refresh ออกจาก history scan
2. **A/B**: ทำให้ Projects tab ไม่ถูก select (หยุดเรียก `fleetModel.refresh`) แล้วเทียบ footprint
3. **Apply staged fix** ที่มีอยู่แล้ว: `FleetViewModel` guard `items != newItems`, `TerminalTabBarView` guard + cancel-on-disappear
4. **ย้าย logic ออกจาก UI** ตาม 5-layer: flatten/filter/sort ของ FleetViewModel → headless + unit test
5. **Re-measure** ด้วยวิธีเดิม และ retest ของ P59: `PaneLifecycleManager` MRU cache (8) + laziness ของ `MarkdownPreviewView`
6. **ถ้ายังโต**: เก็บ allocation stack ก่อน–หลังทีละกิจกรรม (เปิดแอปค้าง → ใช้ terminal → เปิด/ปิด Projects)

**สถานะ**: ภาคผนวกนี้เป็นข้อเสนอที่ **ลงมือทำแล้ว** — guard ทั้งสองตัว (FleetViewModel/TerminalTabBarView) commit แล้วใน `8901aa88` พร้อมย้าย flatten/sort/filter ไป `KouenCore.FleetSessionList` + เทสต์ (`FleetSessionListTests` 4/4, `FleetViewModelTests` 6/6, ArchitectureGuardTests 7/7, robot 26/26) ส่วนข้อ 1, 2, 5 (repro/A-B/re-measure heap) ยังต้องรันแอปเองจึงยังไม่ได้ทำ
