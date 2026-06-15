"""
HarnessUILibrary — Robot Framework keyword library for Harness terminal automation.

Uses macOS accessibility APIs via subprocess + osascript for UI interaction,
and harness CLI for state verification. No Appium dependency required.
"""
import subprocess
import time
import json
from robot.api import logger
from robot.api.deco import keyword, library


BUNDLE_ID = "com.robert.harness.preview"
APP_NAME = "Harness"


@library(scope="GLOBAL")
class HarnessUILibrary:

    @keyword("Launch Harness")
    def launch_harness(self):
        """Launch Harness preview app and wait for window."""
        subprocess.run(["open", "-b", BUNDLE_ID], check=True)
        time.sleep(2)
        self._wait_for_window()

    @keyword("Quit Harness")
    def quit_harness(self):
        """Quit Harness preview app."""
        self._osascript(f'tell application "{APP_NAME}" to quit')
        time.sleep(1)

    @keyword("Press Shortcut")
    def press_shortcut(self, keys: str):
        """Press a keyboard shortcut. Format: 'cmd+d', 'cmd+shift+d', 'cmd+backslash'."""
        script = self._build_keystroke_script(keys)
        self._osascript(script)
        time.sleep(0.5)

    @keyword("Click UI Element")
    def click_ui_element(self, identifier: str):
        """Click an accessibility element by identifier."""
        script = f'''
        tell application "System Events"
            tell process "{APP_NAME}"
                set frontmost to true
                click (first UI element whose value of attribute "AXIdentifier" is "{identifier}")
            end tell
        end tell
        '''
        self._osascript(script)
        time.sleep(0.3)

    @keyword("Element Should Exist")
    def element_should_exist(self, identifier: str):
        """Assert that a UI element with the given accessibility identifier exists."""
        result = self._find_element(identifier)
        if not result:
            raise AssertionError(f"Element '{identifier}' not found in accessibility tree")

    @keyword("Element Should Not Exist")
    def element_should_not_exist(self, identifier: str):
        """Assert that a UI element with the given identifier does NOT exist."""
        result = self._find_element(identifier)
        if result:
            raise AssertionError(f"Element '{identifier}' should not exist but was found")

    @keyword("Get Window Count")
    def get_window_count(self) -> int:
        """Return the number of open Harness windows."""
        script = f'''
        tell application "System Events"
            tell process "{APP_NAME}"
                return count of windows
            end tell
        end tell
        '''
        result = self._osascript(script)
        return int(result.strip())

    @keyword("Harness Board Should Have Column")
    def harness_board_should_have_column(self, column_kind: str):
        """Verify a board column exists using harness CLI."""
        result = subprocess.run(
            ["harness", "board"],
            capture_output=True, text=True, timeout=5
        )
        if column_kind.lower() not in result.stdout.lower():
            raise AssertionError(
                f"Board column '{column_kind}' not found in output:\n{result.stdout}"
            )

    @keyword("Harness CLI Should Succeed")
    def harness_cli_should_succeed(self, *args):
        """Run a harness CLI command and assert exit code 0."""
        result = subprocess.run(
            ["harness"] + list(args),
            capture_output=True, text=True, timeout=10
        )
        if result.returncode != 0:
            raise AssertionError(
                f"harness {' '.join(args)} failed (exit {result.returncode}):\n{result.stderr}"
            )
        return result.stdout

    @keyword("Harness View Should Output")
    def harness_view_should_output(self, filepath: str, expected_substring: str):
        """Run harness view and assert output contains substring."""
        result = subprocess.run(
            ["harness", "view", filepath],
            capture_output=True, text=True, timeout=5
        )
        if expected_substring not in result.stdout:
            raise AssertionError(
                f"Expected '{expected_substring}' in harness view output:\n{result.stdout[:500]}"
            )

    @keyword("Wait For UI")
    def wait_for_ui(self, seconds: float = 1.0):
        """Wait for UI to settle."""
        time.sleep(float(seconds))

    # --- Private helpers ---

    def _osascript(self, script: str) -> str:
        result = subprocess.run(
            ["osascript", "-e", script],
            capture_output=True, text=True, timeout=10
        )
        if result.returncode != 0:
            logger.warn(f"osascript failed: {result.stderr}")
        return result.stdout

    def _wait_for_window(self, timeout: int = 10):
        for _ in range(timeout * 2):
            count = self.get_window_count()
            if count > 0:
                return
            time.sleep(0.5)
        raise AssertionError(f"{APP_NAME} window did not appear within {timeout}s")

    def _find_element(self, identifier: str) -> bool:
        script = f'''
        tell application "System Events"
            tell process "{APP_NAME}"
                set frontmost to true
                try
                    set el to first UI element whose value of attribute "AXIdentifier" is "{identifier}"
                    return "found"
                on error
                    return "not_found"
                end try
            end tell
        end tell
        '''
        result = self._osascript(script)
        return "found" in result

    def _build_keystroke_script(self, keys: str) -> str:
        parts = [k.strip().lower() for k in keys.split("+")]
        modifiers = []
        key_char = ""
        for part in parts:
            if part in ("cmd", "command"):
                modifiers.append("command down")
            elif part in ("shift",):
                modifiers.append("shift down")
            elif part in ("alt", "option"):
                modifiers.append("option down")
            elif part in ("ctrl", "control"):
                modifiers.append("control down")
            elif part == "backslash":
                key_char = "\\\\"
            elif part == "enter":
                key_char = "return"
            elif part == "escape":
                key_char = "escape"
            elif len(part) == 1:
                key_char = part
            else:
                key_char = part

        modifier_str = "{" + ", ".join(modifiers) + "}" if modifiers else ""
        if key_char in ("return", "escape"):
            keystroke_cmd = f'key code {{"return": 36, "escape": 53}}'
            return f'''
            tell application "System Events"
                tell process "{APP_NAME}"
                    set frontmost to true
                    keystroke "" using {modifier_str}
                end tell
            end tell
            '''
        return f'''
        tell application "System Events"
            tell process "{APP_NAME}"
                set frontmost to true
                keystroke "{key_char}" using {modifier_str}
            end tell
        end tell
        '''
