# Keep awake with the lid closed

By default Kouen holds an idle-sleep assertion while an AI provider app (Claude Desktop, VS Code,
Antigravity, Codex, ChatGPT) is running. That doesn't stop **lid-close** sleep. For that, Kouen can
set `pmset disablesleep` through a small root helper. It is opt-in.

## Setup

```bash
sudo Scripts/closed-lid-helper.sh install     # one-time; installs the helper + a sudoers rule
defaults write <Kouen bundle id> KouenClosedLidAwake -bool YES
```

- The helper (`/Library/PrivilegedHelperTools/kouen-pmset`) only accepts `on` / `off`. The sudoers
  rule (`/etc/sudoers.d/kouen-pmset`) allows exactly those two calls, for the installing user only.
- Kouen turns it on while a provider app runs and off when the last one quits or Kouen quits.
  On launch it resets it once (it may be stuck after a crash).
- Check state: `Scripts/closed-lid-helper.sh status`. Manual reset: `sudo pmset -a disablesleep 0`.
- Remove everything: `sudo Scripts/closed-lid-helper.sh uninstall`.

## Caveats

- A closed, running MacBook in a bag gets hot. Use it on purpose, not always.
- A force-kill leaves `disablesleep` on until the next Kouen launch or a manual reset.
- Design follows [Capsomnia](https://github.com/fuji-mak/Capsomnia) (MIT).
