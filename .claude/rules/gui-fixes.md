# GUI / Layout Fixes

Applies to visual UI bugs in any desktop/web app: title bar, toolbar, sidebar header, button placement, spacing, clipping, alignment.

- **Fix it yourself first.** Don't delegate GUI work to another agent by default.
- **Verify visually every round.** Build/run the app (the project's preview or dev target, e.g. `make preview`, a web dev server), look at the real result (screenshot or browser tool), and compare it against the reported problem before saying it's fixed. Code reading alone is not verification — platform layout (macOS title-bar safe areas and accessory placement, system insets, CSS cascade) is often invisible in code.
- **Stop after 2 failed rounds.** Don't loop. Present options with a one-line recommendation, e.g.:
  - hand to another agent or a person with what was tried and what the screenshot shows
  - try a different approach (name it)
  - park it
  The user picks; never switch tools on your own.
- **When another agent does the fix,** review its diff before merge like any other agent change.

Why: simple GUI fixes (a header label, back/forward buttons) can fail many rounds without visual checks; looking at the real result each round catches platform layout that code reading cannot.
