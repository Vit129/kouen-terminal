# Notification Sound Toggle Ignored + Banner Click Didn't Navigate

Status: **Fix applied, build verified — click behavior not yet manually confirmed** (native
AppKit notification interaction, no GUI automation available for this app in-session).

## Symptom

Two reports that looked like one but had different root causes (same "don't assume a two-symptom
report shares one root cause" lesson as the 2026-07-02 file-preview bug split — see global
agent-memory):

1. Toggling Settings ▸ Agents ▸ "Sound" off did not actually silence agent notifications.
2. Clicking a delivered macOS notification banner did nothing — unlike clicking the same
   entry in the notch/inbox, it did not navigate to the owning workspace/tab/pane.

## Root Cause

### CASE-063a — sound toggle

`notificationSoundEnabled` was correctly threaded through `NotificationCoordinator.deliverAgentAlert`
into `content.sound` (nil when off) and into the AppleScript fallback's `sound name` clause — both
gate correctly. The one place it wasn't respected: `NotificationPresenter.userNotificationCenter(
_:willPresent:withCompletionHandler:)` (`SessionCoordinatorTypes.swift`) — this fires only when a
notification would present while Harness is in the foreground (a different tab/surface active),
and it unconditionally returned `completionHandler([.banner, .sound])` regardless of whether
`content.sound` was actually set. `UNNotificationPresentationOptions.sound` combined with
`content.sound == nil` may still be silent on some OS versions, but it was the one live code-path
that ignored the toggle instead of deferring to the content it was handed.

Confirmed via `defaults read com.robert.harness notificationCenterKnownBad` (and `.preview` domain)
that this machine is NOT on the `NotificationCenterProbe.isKnownBad` AppleScript fallback path (see
`bugs/zombie-crash-macos26.md` for that path) — the real `UNUserNotificationCenter` delegate path,
and this bug, is the one actually in effect.

### CASE-063b — click doesn't route

`NotificationPresenter` never implemented `userNotificationCenter(_:didReceive:withCompletionHandler:)`
at all — only `willPresent` existed (added for foreground presentation, see
`SessionCoordinatorTypes.swift` doc comment referencing Step 3 of `REVIEW-graphify-harness-2026-07-03.md`
Part 3). With no `didReceive`, clicking a banner just foregrounds the app; nothing calls the
equivalent of `NotificationCoordinator.openNotification(_:)` (select workspace → select tab → focus
pane → clear notification), which is what clicking a notch/inbox entry does.

Compounding cause: `DesktopNotifier.show`/`UNNotificationRequest` carried no identity at all —
`identifier: UUID().uuidString` (random, discarded) and no `content.userInfo` — so even with a
`didReceive` handler there was nothing to route on.

## Fix Applied

- `DesktopNotifier.show` gained `surfaceID: String? = nil`, stored into `content.userInfo["surfaceID"]`
  when present.
- `NotificationCoordinator.deliverAgentAlert` gained `surfaceID: SurfaceID? = nil`, passed through to
  `DesktopNotifier.show`. All 4 call sites now pass the surface they already had in scope:
  `pushNewRemoteNotifications`, `pushAgentActivityNotifications`, `handleNotification` (covers
  `.bell` and `.agentWaiting`), and `SessionCoordinator+HostDelegate.terminalHostDidFinishCommand`
  (`.commandFinished`) — this last one was easy to miss since it calls
  `notificationCoordinator.deliverAgentAlert` directly rather than through `handleNotification`.
- New `NotificationCoordinator.openSurface(_ surfaceID: SurfaceID)` — mirrors `openNotification`:
  resolve `tabID` via `coord.activePaneService.tabID(forSurface:)`, find the owning workspace by
  scanning `coord.snapshot.workspaces` for a session containing that tab, `selectWorkspace` →
  `selectTab` → `setActiveSurface` → `focusTerminal()` → `clearNotification(surfaceID:)`.
- `NotificationPresenter.willPresent` now builds `options` conditionally:
  `if notification.request.content.sound != nil { options.insert(.sound) }`.
- New `NotificationPresenter.userNotificationCenter(_:didReceive:withCompletionHandler:)` — extracts
  `response.notification.request.content.userInfo["surfaceID"]`, parses as `UUID`, hops to
  `@MainActor` (delegate callbacks arrive off-main), calls
  `SessionCoordinator.shared.notificationCoordinator.openSurface(surfaceID)`. No `UNNotificationCategory`
  needed — default click (no action buttons) reaches `didReceive` without one.

## If Fix Is Insufficient

- If sound still plays with the toggle off: check System Settings ▸ Notifications ▸ Harness — macOS
  itself may be forcing a sound independent of `content.sound`. Also verify this machine hasn't
  flipped to the `NotificationCenterProbe.isKnownBad` AppleScript path (`defaults read <bundle-id>
  notificationCenterKnownBad`) — that path has no `willPresent`/`didReceive` at all, so a "sound not
  off" report there points somewhere else entirely (terminal bell/beep, not this fix).
- If click still doesn't navigate: confirm `UNUserNotificationCenter.current().delegate` is actually
  set to `NotificationPresenter.shared` before the notification is scheduled
  (`DesktopNotifier.requestAuthorizationIfNeeded()` sets it, gated on `!isKnownBad`) — a race where a
  notification is requested before authorization/delegate assignment would silently drop routing.

## Files

- `Apps/Harness/Sources/HarnessApp/Services/SessionCoordinatorTypes.swift` (`NotificationPresenter`, `DesktopNotifier.show`)
- `Apps/Harness/Sources/HarnessApp/Services/NotificationCoordinator.swift` (`deliverAgentAlert`, new `openSurface`)
- `Apps/Harness/Sources/HarnessApp/Services/SessionCoordinator+HostDelegate.swift` (`terminalHostDidFinishCommand` call site)
