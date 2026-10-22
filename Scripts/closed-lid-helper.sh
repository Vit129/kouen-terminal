#!/bin/sh
# Installs/removes the root helper that lets Kouen keep the Mac awake with the lid closed.
#   sudo Scripts/closed-lid-helper.sh install | uninstall | status
# The helper only runs `pmset -a disablesleep 1|0`; sudoers allows exactly those two
# invocations, for the installing user only, with no password. Pattern from Capsomnia (MIT).
set -eu

HELPER=/Library/PrivilegedHelperTools/kouen-pmset
SUDOERS=/etc/sudoers.d/kouen-pmset

die() { echo "error: $*" >&2; exit 1; }

case "${1:-}" in
install)
    [ "$(id -u)" -eq 0 ] || die "run with sudo"
    user="${SUDO_USER:-}"
    [ -n "$user" ] && [ "$user" != root ] || die "run via sudo from your own account (SUDO_USER is empty)"
    tmp_helper="$(mktemp)"; tmp_rule="$(mktemp)"
    trap 'rm -f "$tmp_helper" "$tmp_rule"' EXIT
    cat > "$tmp_helper" <<'HELPER_EOF'
#!/bin/sh
case "${1:-}" in
    on)  exec /usr/bin/pmset -a disablesleep 1 ;;
    off) exec /usr/bin/pmset -a disablesleep 0 ;;
    *)   echo "usage: kouen-pmset on|off" >&2; exit 64 ;;
esac
HELPER_EOF
    printf '%s ALL=(root) NOPASSWD: %s on, %s off\n' "$user" "$HELPER" "$HELPER" > "$tmp_rule"
    /usr/sbin/visudo -cf "$tmp_rule" >/dev/null || die "generated sudoers rule failed validation"
    mkdir -p /Library/PrivilegedHelperTools
    install -o root -g wheel -m 755 "$tmp_helper" "$HELPER"
    install -o root -g wheel -m 440 "$tmp_rule" "$SUDOERS"
    echo "installed $HELPER and $SUDOERS for user $user"
    echo "enable in Kouen: defaults write <Kouen bundle id> KouenClosedLidAwake -bool YES"
    ;;
uninstall)
    [ "$(id -u)" -eq 0 ] || die "run with sudo"
    /usr/bin/pmset -a disablesleep 0
    rm -f "$SUDOERS" "$HELPER"
    echo "removed helper and sudoers rule; normal sleep restored"
    ;;
status)
    [ -x "$HELPER" ] && echo "helper: installed" || echo "helper: not installed"
    /usr/bin/pmset -g | grep -i SleepDisabled || echo "SleepDisabled: 0"
    ;;
*)
    echo "usage: sudo $0 install|uninstall|status" >&2; exit 64 ;;
esac
