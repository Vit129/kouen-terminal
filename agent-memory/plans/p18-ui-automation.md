# P18 — UI Automation (Robot Framework)

Status: **planned** — intentionally sequenced after P17 structural refactor completes
Priority: **P3** — quality/confidence layer, no new features
Owner surface: Tests/HarnessRobotTests/ (new), HarnessApp UI layer (accessibility identifiers)
Created: 2026-06-14
Prerequisite: P17 done (UI/ subfolder reorganized, SessionCoordinator decomposed)

---

## Goal

Automated UI tests using Robot Framework + Appium Mac2Driver that simulate a real
user — keyboard shortcuts, mouse clicks, sidebar interactions — without any manual
steps. Tests are plain English keywords, reusable across projects, and produce
HTML reports.

---

## Why After P17

P17 PBI-REFACTOR-002 reorganizes UI/ into feature subfolders. Adding
`accessibilityIdentifier` to NSView elements before that causes merge conflicts.
After P17, each file is in its stable location.

---

## Stack

```
Robot Framework (Python keywords)
    └── AppiumLibrary
        └── Appium Server (localhost:4723)
            └── Mac2Driver (XCTest WebDriverAgent)
                └── Harness.app (Accessibility API)
```

---

## PBI-UI-001: Add accessibilityIdentifier to key elements

**Problem:** Custom NSView elements have no identifier — Appium cannot find them.

**Elements to tag:**

| Element | File | Identifier |
|---------|------|-----------|
| New tab button | TerminalTabBarView.swift | `tab-bar-new-tab` |
| Tab pill (per tab) | TerminalTabBarView.swift | `tab-pill-<index>` |
| Tab close button | TerminalTabBarView.swift | `tab-close-<index>` |
| ⌘N badge label | TerminalTabBarView.swift | `tab-shortcut-<index>` |
| Sidebar toggle | MainSplitViewController | `sidebar-toggle` |
| File tree tab | HarnessSidebarPanelViewController | `sidebar-tab-files` |
| Board tab | HarnessSidebarPanelViewController | `sidebar-tab-board` |
| Git tab | HarnessSidebarPanelViewController | `sidebar-tab-git` |
| Close pane button | ContentAreaViewController | `close-pane-button` |
| Board column header | BoardViewController | `board-column-<kind>` |

```swift
// NSView
button.setAccessibilityIdentifier("tab-bar-new-tab")

// SwiftUI
Text("Board").accessibilityIdentifier("sidebar-tab-board")
```

---

## PBI-UI-002: Setup Robot Framework environment

**One-time setup:**
```bash
pip install robotframework
pip install robotframework-appiumlibrary

npm install -g appium
appium driver install mac2

# Start Appium (keep running during tests)
appium --address 127.0.0.1 --port 4723
```

**Project structure:**
```
Tests/HarnessRobotTests/
├── resources/
│   └── harness.resource       # shared keywords + variables
├── suites/
│   ├── split_panes.robot
│   ├── tab_bar.robot
│   ├── sidebar.robot
│   └── board.robot
└── README.md                  # setup instructions
```

---

## PBI-UI-003: Shared resource file

**Tests/HarnessRobotTests/resources/harness.resource:**
```robot
*** Settings ***
Library    AppiumLibrary

*** Variables ***
${APPIUM_URL}      http://127.0.0.1:4723
${BUNDLE_ID}       com.robert.harness.preview
${TIMEOUT}         5s

*** Keywords ***
Launch Harness
    Open Application    ${APPIUM_URL}
    ...    platformName=mac
    ...    bundleId=${BUNDLE_ID}
    ...    automationName=mac2

Quit Harness
    Close Application

Split Right
    Press Keys    None    COMMAND+d

Split Down
    Press Keys    None    COMMAND+SHIFT+d

Close Pane
    Press Keys    None    ALT+SHIFT+COMMAND+w

Toggle Sidebar
    Press Keys    None    COMMAND+\
```

---

## PBI-UI-004: Test suites

**split_panes.robot:**
```robot
*** Settings ***
Resource    ../resources/harness.resource
Test Setup      Launch Harness
Test Teardown   Quit Harness

*** Test Cases ***
Split Right Creates Second Pane
    Split Right
    Element Should Be Visible    accessibility_id=close-pane-button

Split Down Creates Vertical Pane
    Split Down
    Element Should Be Visible    accessibility_id=close-pane-button

Close Pane Restores Single View
    Split Right
    Close Pane
    Element Should Not Be Visible    accessibility_id=close-pane-button

Nested Split Creates Three Panes
    Split Right
    Split Down
    ${panes}=    Get Element Count    accessibility_id=close-pane-button
    Should Be Equal As Numbers    ${panes}    2
```

**tab_bar.robot:**
```robot
*** Settings ***
Resource    ../resources/harness.resource
Test Setup      Launch Harness
Test Teardown   Quit Harness

*** Test Cases ***
Close Button Hidden At Rest
    [Documentation]    Regression: CASE-028 — close button must not show without hover
    Element Should Not Be Visible    accessibility_id=tab-close-0
    Element Should Be Visible        accessibility_id=tab-shortcut-0

New Tab Button Adds Tab
    ${before}=    Get Element Count    accessibility_id=tab-pill
    Click Element    accessibility_id=tab-bar-new-tab
    ${after}=    Get Element Count    accessibility_id=tab-pill
    Should Be Equal As Numbers    ${after}    ${before + 1}
```

**sidebar.robot:**
```robot
*** Settings ***
Resource    ../resources/harness.resource
Test Setup      Launch Harness
Test Teardown   Quit Harness

*** Test Cases ***
Board Tab Shows Status Columns
    Click Element    accessibility_id=sidebar-tab-board
    Element Should Be Visible    accessibility_id=board-column-idle
    Element Should Be Visible    accessibility_id=board-column-running
    Element Should Be Visible    accessibility_id=board-column-needs-attention

Sidebar Toggle Hides Panel
    Toggle Sidebar
    Element Should Not Be Visible    accessibility_id=sidebar-tab-files
    Toggle Sidebar
    Element Should Be Visible    accessibility_id=sidebar-tab-files

Git Tab Opens Git Panel
    Click Element    accessibility_id=sidebar-tab-git
    Element Should Be Visible    accessibility_id=git-panel-changes
```

---

## PBI-UI-005: CI integration

**.github/workflows/ui-tests.yml:**
```yaml
name: UI Tests
on: [push]
jobs:
  ui-test:
    runs-on: macos-15
    steps:
      - uses: actions/checkout@v4
      - name: Build preview app
        run: make preview
      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.12'
      - name: Install dependencies
        run: |
          pip install robotframework robotframework-appiumlibrary
          npm install -g appium
          appium driver install mac2
      - name: Start Appium
        run: appium --address 127.0.0.1 --port 4723 &
      - name: Run Robot tests
        run: |
          robot --outputdir results Tests/HarnessRobotTests/suites/
      - name: Upload results
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: robot-results
          path: results/
```

**Run locally:**
```bash
# Start Appium in background
appium &

# Run all suites
robot --outputdir results Tests/HarnessRobotTests/suites/

# Run single suite
robot Tests/HarnessRobotTests/suites/split_panes.robot

# Open HTML report
open results/report.html
```

---

## Execution Order

```
PBI-UI-001  Add accessibilityIdentifiers     [Low effort, unblocks everything]
PBI-UI-002  Setup Robot Framework env        [One-time, ~30 min]
PBI-UI-003  Shared resource file             [Low effort]
PBI-UI-004  Test suites                      [Medium effort]
PBI-UI-005  CI integration                   [Low effort]
```

---

## Success Criteria

- [ ] `robot Tests/HarnessRobotTests/suites/` passes on a clean machine
- [ ] HTML report generated at `results/report.html`
- [ ] Close button vs ⌘N badge regression test (CASE-028) catches the bug pattern
- [ ] Split pane create + close tests pass
- [ ] Board column visibility tests pass
- [ ] CI uploads HTML report as artifact on every push

---

## Non-Goals

- No XCUITest — Robot Framework only
- No visual regression / screenshot diff
- No performance measurement (use HarnessBenchmarks)
- No Metal rendering assertions (not accessible via AX tree)
