# Read-only runtime checks; missing tools do not undo successful symlinks.
missing=0
for command in Hyprland quickshell hyprlock hypridle matugen python3 awww awww-daemon \
    cliphist wl-copy wl-paste brightnessctl wpctl pw-dump pw-metadata \
    pactl playerctl grim hyprshot checkupdates trizen yay gum figlet; do
    if ! command -v "$command" >/dev/null; then
        printf 'Missing runtime command: %s\n' "$command" >&2
        missing=1
    fi
done
if [[ ! -r /etc/pam.d/hyprlock ]]; then
    printf 'Missing /etc/pam.d/hyprlock; install Hyprlock for lock authentication.\n' >&2
    missing=1
fi
if ! python3 -c 'import dbus; from gi.repository import GLib' >/dev/null 2>&1; then
    printf 'Bluetooth pairing requires python-dbus and python-gobject.\n' >&2
    missing=1
fi
for service in NetworkManager bluetooth; do
    if ! systemctl is-active --quiet "$service"; then
        printf 'Service is not active: %s. Enable it if required for this machine.\n' "$service" >&2
        missing=1
    fi
done
if (( missing )); then
    printf 'Dotfiles linked. Resolve the missing dependencies before starting the desktop.\n'
else
    printf 'Dotfiles linked; runtime dependency checks passed.\n'
fi
