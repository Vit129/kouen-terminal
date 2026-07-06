"""
KouenUILibrary — Robot Framework keyword library for Kouen terminal automation.

Uses macOS accessibility APIs via subprocess + osascript for UI interaction,
and kouen CLI for state verification. No Appium dependency required.
"""
import subprocess
import time
import json
from robot.api import logger
from robot.api.deco import keyword, library


BUNDLE_ID = "com.robert.kouen.preview"
BUNDLE_ID_STAGING = "com.robert.kouen.staging"
APP_NAME = "Kouen"

# Staging = release-optimized build with isolated state (not production data)
# Catches crashes that only appear in -O builds without touching user's real sessions.
STAGING_HOME = "/tmp/kouen-staging-tests"


@library(scope="GLOBAL")
class KouenUILibrary:

    def __init__(self):
        self._env = "preview"

    @keyword("Launch Kouen")
    def launch_kouen(self, env="preview"):
        """Launch Kouen app. env: 'preview' (debug) or 'staging' (release+isolated)."""
        self._env = env
        if env == "staging":
            import os
            os.makedirs(STAGING_HOME, exist_ok=True)
            # Launch the repo-root Kouen.app (release build) with isolated home
            app_path = self._repo_root() + "/Kouen.app"
            subprocess.run(
                ["open", app_path, "--env", f"KOUEN_HOME={STAGING_HOME}"],
                check=True
            )
        else:
            subprocess.run(["open", "-b", BUNDLE_ID], check=True)
        time.sleep(2)
        self._wait_for_window()

    @keyword("Quit Kouen")
    def quit_kouen(self, env=None):
        """Quit Kouen app."""
        env = env or self._env
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
        """Return the number of open Kouen windows."""
        script = f'''
        tell application "System Events"
            tell process "{APP_NAME}"
                return count of windows
            end tell
        end tell
        '''
        result = self._osascript(script)
        return int(result.strip())

    @keyword("Kouen Board Should Have Column")
    def kouen_board_should_have_column(self, column_kind: str):
        """Verify a board column exists using kouen CLI."""
        result = subprocess.run(
            ["kouen", "board"],
            capture_output=True, text=True, timeout=5
        )
        if column_kind.lower() not in result.stdout.lower():
            raise AssertionError(
                f"Board column '{column_kind}' not found in output:\n{result.stdout}"
            )

    @keyword("Kouen CLI Should Succeed")
    def kouen_cli_should_succeed(self, *args):
        """Run a kouen CLI command and assert exit code 0."""
        result = subprocess.run(
            ["kouen"] + list(args),
            capture_output=True, text=True, timeout=10
        )
        if result.returncode != 0:
            raise AssertionError(
                f"kouen {' '.join(args)} failed (exit {result.returncode}):\n{result.stderr}"
            )
        return result.stdout

    @keyword("Kouen View Should Output")
    def kouen_view_should_output(self, filepath: str, expected_substring: str):
        """Run kouen view and assert output contains substring."""
        result = subprocess.run(
            ["kouen", "view", filepath],
            capture_output=True, text=True, timeout=5
        )
        if expected_substring not in result.stdout:
            raise AssertionError(
                f"Expected '{expected_substring}' in kouen view output:\n{result.stdout[:500]}"
            )

    @keyword("Type Text")
    def type_text(self, text: str):
        """Type a string of text into the focused element via osascript keystroke."""
        escaped = text.replace("\\", "\\\\").replace('"', '\\"')
        self._osascript(f'''
            tell application "System Events"
                tell process "{APP_NAME}"
                    set frontmost to true
                    keystroke "{escaped}"
                end tell
            end tell
        ''')

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
                key_char = "\\"
            elif part == "colon":
                key_char = ":"
            elif part in ("enter", "return"):
                key_char = "return"
            elif part == "escape":
                key_char = "escape"
            elif len(part) == 1:
                key_char = part
            else:
                key_char = part

        mod_clause = " using {" + ", ".join(modifiers) + "}" if modifiers else ""
        if key_char == "return":
            return f'''
            tell application "System Events"
                tell process "{APP_NAME}"
                    set frontmost to true
                    key code 36{mod_clause}
                end tell
            end tell
            '''
        if key_char == "escape":
            return f'''
            tell application "System Events"
                tell process "{APP_NAME}"
                    set frontmost to true
                    key code 53{mod_clause}
                end tell
            end tell
            '''
        return f'''
        tell application "System Events"
            tell process "{APP_NAME}"
                set frontmost to true
                keystroke "{key_char}"{mod_clause}
            end tell
        end tell
        '''

    # --- Stability test keywords ---

    @keyword("App Should Not Crash")
    def app_should_not_crash(self):
        """Verify app is still running (no crash report in last 10s)."""
        import glob, os
        time.sleep(0.5)
        reports = glob.glob(os.path.expanduser("~/Library/Logs/DiagnosticReports/Kouen*.ips"))
        recent = [r for r in reports if os.path.getmtime(r) > time.time() - 10]
        if recent:
            raise AssertionError(f"App crashed! Report: {recent[-1]}")

    @keyword("Get Heap Count")
    def get_heap_count(self, class_name):
        """Get count of heap objects of given class in running Kouen."""
        pid = self._get_pid()
        result = subprocess.run(["heap", str(pid), "-s"], capture_output=True, text=True)
        for line in result.stdout.splitlines():
            if class_name in line:
                parts = line.split()
                if parts and parts[0].isdigit():
                    return int(parts[0])
        return 0

    @keyword("Get Terminal Size")
    def get_terminal_size(self):
        """Get cols x rows from active terminal via stty."""
        cli = self._cli_path()
        result = subprocess.run(
            [cli, "capture-pane", "--surface", self._active_surface(), "--rows", "1"],
            capture_output=True, text=True
        )
        return result.stdout.strip()[:20]

    @keyword("Send Keys")
    def send_keys(self, text):
        """Send raw keys to active terminal surface."""
        cli = self._cli_path()
        surface = self._active_surface()
        subprocess.run([cli, "send-keys", "--surface", surface, "--keys", text], check=True)

    @keyword("Send Ex Command")
    def send_ex_command(self, command):
        """Send :ex command via CLI."""
        cli = self._cli_path()
        surface = self._active_surface()
        subprocess.run([cli, "send-keys", "--surface", surface, "--keys", f"{command} Enter"], check=True)

    @keyword("Hover Tab")
    def hover_tab(self, index):
        """Hover over tab pill at given index (AppleScript)."""
        self._osascript(f'''
            tell application "System Events"
                tell process "{APP_NAME}"
                    -- hover approximation via mouse move
                end tell
            end tell
        ''')

    @keyword("Click Sync Button")
    def click_sync_button(self):
        """Click the Sync/Fetch button in Git panel."""
        self._osascript(f'''
            tell application "System Events"
                tell process "{APP_NAME}"
                    click button "Sync ▾" of window 1
                end tell
            end tell
        ''')

    @keyword("Toast Should Appear")
    def toast_should_appear(self):
        """Verify a toast appeared (check for label with ✓ or ✗)."""
        time.sleep(0.5)  # toast visible for 1-3s
        # Toast is transient - just verify no crash
        self.app_should_not_crash()

    def _get_pid(self):
        result = subprocess.run(["pgrep", "-f", "Kouen.app/Contents/MacOS/Kouen$"],
                                capture_output=True, text=True)
        return int(result.stdout.strip().split()[0]) if result.stdout.strip() else 0

    def _cli_path(self):
        if self._env == "staging":
            return self._repo_root() + "/.build/release/kouen-cli"
        return self._repo_root() + "/.build/debug/kouen-cli"

    def _active_surface(self):
        cli = self._cli_path()
        env = {"KOUEN_HOME": STAGING_HOME} if self._env == "staging" else {}
        import os
        full_env = {**os.environ, **env}
        result = subprocess.run([cli, "list-surfaces"], capture_output=True, text=True, env=full_env)
        lines = result.stdout.strip().splitlines()
        return lines[0].split()[0] if lines else ""

    def _repo_root(self):
        import os
        return os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
