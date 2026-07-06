# Kouen Robot Framework Tests

UI automation tests using Robot Framework + custom Python library (macOS accessibility via AppleScript).

## Prerequisites

```bash
# Already installed:
pip3 install robotframework        # RF 7.x
swift build                        # builds kouen-cli + kouen-mcp

# Grant accessibility permissions:
# System Settings → Privacy & Security → Accessibility → Terminal (or your terminal app)
```

No Appium required — uses native macOS System Events accessibility.

## Run

```bash
# All suites
robot --outputdir results Tests/KouenRobotTests/suites/

# Single suite
robot Tests/KouenRobotTests/suites/p4_lsp_file_view.robot
robot Tests/KouenRobotTests/suites/p11_scripting.robot
robot Tests/KouenRobotTests/suites/p12_mcp.robot
robot Tests/KouenRobotTests/suites/p13_splits_navigation.robot
robot Tests/KouenRobotTests/suites/p16_board.robot

# View report
open results/report.html
```

## Architecture

```
Tests/KouenRobotTests/
├── libraries/
│   └── KouenUILibrary.py    # Python keywords (osascript + CLI wrappers)
├── resources/
│   └── kouen.resource       # Shared RF keywords (Split Right, Toggle Sidebar, etc.)
├── suites/
│   ├── p4_lsp_file_view.robot
│   ├── p11_scripting.robot
│   ├── p12_mcp.robot
│   ├── p13_splits_navigation.robot
│   └── p16_board.robot
└── README.md
```

## Accessibility Identifiers Required

Tests that use `Element Should Exist` / `Click UI Element` require
accessibility identifiers set in the Swift source (PBI-UI-001).
See `agent-memory/plans/p18-ui-automation.md` for the full list.

Tests that only use keyboard shortcuts + CLI verification work without identifiers.

## Troubleshooting

- **"System Events got an error: Not authorized"** → Grant Terminal accessibility in System Settings
- **Window not appearing** → Ensure `make preview` was run at least once to build the preview app
- **MCP tests fail** → Ensure `swift build --product kouen-mcp` was run
