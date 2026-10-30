# Appium Inspector / Session Capabilities

Appium Inspector has no CLI — capabilities go in the New Session JSON form, against a running server (`appium` / `appium server --port <port>`).

## Android — install-if-missing, launch-if-present

```json
{
  "platformName": "Android",
  "appium:automationName": "UiAutomator2",
  "appium:deviceName": "Pixel_6",
  "appium:app": "/absolute/path/to/app-debug.apk",
  "appium:noReset": true
}
```

`appium:app` + `appium:noReset: true` is the combination for "install if not present, otherwise just launch": the driver compares the given APK's signature/version against what's already installed and skips reinstall on a match. This is default UiAutomator2 driver behavior — no extra capability needed beyond these two.

To target an already-installed app without ever attempting install, drop `appium:app` and use `appium:appPackage` + `appium:appActivity` instead.

## `noReset` vs `fullReset` — don't confuse these

| Capability | Effect |
|---|---|
| `appium:noReset: true` | Keep app data between sessions; skip reinstall if already present at matching version |
| `appium:fullReset: true` | Uninstall + fresh install every session (clears all data) — opposite of the above, use only when a clean-slate test genuinely needs it |

## iOS

```json
{
  "platformName": "iOS",
  "appium:automationName": "XCUITest",
  "appium:deviceName": "iPhone 15",
  "appium:app": "/absolute/path/to/app.app",
  "appium:noReset": true
}
```

## Before opening Inspector

1. Emulator/simulator must already be booted (`emulator -avd <name>` for Android — list available with `emulator -list-avds`).
2. Appium server must be running first (`appium` or `appium server --port <port>`) — Inspector connects to it, doesn't start it.
3. Remote Host in Inspector: `http://127.0.0.1:4723` for Appium 2+ (no `/wd/hub` suffix needed on v2/v3).
