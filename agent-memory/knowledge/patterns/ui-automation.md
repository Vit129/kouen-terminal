# UI Automation — Robot Framework (P18)

## Stack

```
Robot Framework 7.x
└── HarnessUILibrary.py (custom keywords)
    ├── osascript → System Events (UI interaction)
    └── subprocess → harness CLI (state verification)
```

No Appium, no XCUITest, no external drivers.

## Why Not Appium

- Appium Mac2Driver requires Appium 3.x (still RC as of 2026-06)
- Appium 2.x `appium driver install mac2` fails with version mismatch
- Appium server adds infra overhead (start/stop, port management)
- osascript is zero-dep and works with any macOS native app

## Test Strategy

| Layer | Tool | Verifies |
|-------|------|----------|
| Keyboard shortcuts | osascript `keystroke` | Split, sidebar, navigation |
| Element existence | osascript AXIdentifier query | UI state after actions |
| CLI output | `harness view/board/lsp` subprocess | Functional correctness |
| MCP tools | `harness-mcp` stdin/stdout | Policy, tool responses |

## Accessibility Requirements

Tests using `Element Should Exist` / `Click UI Element` need Swift-side:
```swift
button.setAccessibilityIdentifier("tab-bar-new-tab")
```

Tests using only keyboard shortcuts + CLI verification work without identifiers.

## Running

```bash
robot --outputdir results Tests/HarnessRobotTests/suites/
open results/report.html
```

## Files

```
Tests/HarnessRobotTests/
├── libraries/HarnessUILibrary.py    # 200 LOC Python
├── resources/harness.resource       # Shared RF keywords
└── suites/
    ├── p4_lsp_file_view.robot       # 5 tests
    ├── p11_scripting.robot          # 4 tests
    ├── p12_mcp.robot                # 5 tests
    ├── p13_splits_navigation.robot  # 7 tests
    └── p16_board.robot              # 4 tests
```

## Permission

System Settings → Privacy & Security → Accessibility → Terminal app → ✅
