#!/usr/bin/env bash
# Install greetd on Arch Linux and select it for the next boot.
set -euo pipefail
DOTFILES_ROOT=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
dry_run=false
for option in "$@"; do
    case "$option" in
        --dry-run) dry_run=true ;;
        --help|-h)
            cat <<'HELP'
Usage: ./scripts/migrate-greetd.sh [--dry-run]

Install greetd, Cage, and Quickshell using pacman, snapshot this checkout's
login UI, selected wallpaper, and palette into /usr/local/share/dotfiles-greeter,
and install the launcher and /etc/greetd/config.toml. Existing config is backed up.
Run again to refresh the installed UI and wallpaper/palette snapshots.

--dry-run  Print commands without installing packages or changing files.

Disables SDDM and enables greetd for the next boot. Does not stop or start
services, change PAM, or reboot. If greetd is already running, the new UI
appears on your next logout; otherwise reboot to switch from SDDM.
Run as your normal user; system changes use sudo. Pacman performs a full
system upgrade and retains its normal confirmation prompt.
HELP
            exit 0 ;;
        *) printf 'Unknown option: %s\n' "$option" >&2; exit 2 ;;
    esac
done
run() {
    if $dry_run; then
        printf 'Would run:'
        printf ' %q' "$@"
        printf '\n'
    else
        "$@"
    fi
}
source_config="$DOTFILES_ROOT/greetd/config.toml"
[[ -f "$source_config" ]] || { printf 'Missing %s\n' "$source_config" >&2; exit 1; }
command -v pacman >/dev/null || { printf 'This script requires Arch Linux and pacman.\n' >&2; exit 1; }
[[ -x /usr/bin/start-hyprland ]] || { printf 'Install Hyprland first: /usr/bin/start-hyprland is missing.\n' >&2; exit 1; }
if ! $dry_run; then
    command -v sudo >/dev/null || { printf 'sudo is required.\n' >&2; exit 1; }
fi
command -v systemctl >/dev/null || { printf 'systemd is required.\n' >&2; exit 1; }
# Refuse to replace an unrelated display manager accidentally.
manager_link=/etc/systemd/system/display-manager.service
previous_manager=""
if [[ -L "$manager_link" ]]; then
    previous_manager=$(basename -- "$(readlink -- "$manager_link")")
    case "$previous_manager" in
        sddm.service|greetd.service) ;;
        *) printf 'Unsupported current display manager: %s\n' "$previous_manager" >&2; exit 1 ;;
    esac
elif [[ -e "$manager_link" ]]; then
    printf 'Expected %s to be a service symlink; inspect it before migrating.\n' "$manager_link" >&2
    exit 1
fi
command -v python3 >/dev/null || { printf 'Python 3 is required.\n' >&2; exit 1; }
# Stage and validate the bundle before installing packages or touching system config.
stage=""
cleanup() { if [[ -n "$stage" ]]; then rm -rf -- "$stage"; fi; }
trap cleanup EXIT
if ! $dry_run; then
    stage=$(mktemp -d)
    python3 "$DOTFILES_ROOT/greetd/prepare.py" "$DOTFILES_ROOT" "$stage"
fi
run sudo pacman -Syu --needed greetd greetd-agreety cage quickshell python

if ! $dry_run; then
    [[ -x /usr/bin/agreety ]] || { printf 'agreety was not installed.\n' >&2; exit 1; }
    [[ -x /usr/bin/cage && -x /usr/bin/quickshell && -x /usr/bin/dbus-run-session ]] || { printf 'Greeter runtime dependencies are missing.\n' >&2; exit 1; }
    getent passwd greeter >/dev/null || { printf 'The greetd package did not create the greeter user.\n' >&2; exit 1; }
fi
run sudo install -d -m 755 /etc/greetd
# Back up after package installation so the packaged default is preserved too.
# mktemp avoids overwriting earlier backups, including repeated runs.
if $dry_run; then
    printf 'Would back up /etc/greetd/config.toml if present (unique config.toml.backup.XXXXXX).\n'
else
    if sudo test -e /etc/greetd/config.toml || sudo test -L /etc/greetd/config.toml; then
        backup=$(sudo mktemp /etc/greetd/config.toml.backup.XXXXXX)
        sudo cp -L --preserve=mode,ownership,timestamps /etc/greetd/config.toml "$backup"
        printf 'Saved existing configuration to %s\n' "$backup"
    fi
fi
# Keep releases immutable to the greeter user and preserve earlier bundles.
# Only publish the new release after the entire copy is complete.
release="/usr/local/share/dotfiles-greeter/releases/$(date +%Y%m%d-%H%M%S)-$$"
run sudo install -d -m 755 "$release"
if $dry_run; then
    printf 'Would snapshot shared QML, the selected wallpaper, palette, and username into %s.\n' "$release"
else
    run sudo cp -R --no-preserve=ownership "$stage/." "$release/"
    run sudo chown -R root:root "$release"
    run sudo chmod -R u=rwX,go=rX "$release"
fi
# Only the assets directory is writable by the desktop user; UI stays root-owned.
run sudo install -d -o root -g root -m 755 /var/lib/dotfiles-greeter
run sudo install -d -o "$(id -u)" -g "$(id -g)" -m 755 /var/lib/dotfiles-greeter/assets
if $dry_run; then
    printf 'Would initialize the shared wallpaper and palette copies in /var/lib/dotfiles-greeter/assets/wallpaper.\n'
else
    run sudo install -o "$(id -u)" -g "$(id -g)" -m 644 "$stage/wallpaper" /var/lib/dotfiles-greeter/assets/wallpaper
    run sudo install -d -o "$(id -u)" -g "$(id -g)" -m 755 /var/lib/dotfiles-greeter/assets/theme /var/lib/dotfiles-greeter/assets/theme/quickshell
    if [[ -f "$stage/theme/quickshell/colors.json" ]]; then
        run sudo install -o "$(id -u)" -g "$(id -g)" -m 644 "$stage/theme/quickshell/colors.json" /var/lib/dotfiles-greeter/assets/theme/quickshell/colors.json
    fi
fi
run sudo ln -sfnT "$release" /usr/local/share/dotfiles-greeter/current
run sudo install -o root -g root -m 755 "$DOTFILES_ROOT/greetd/launch.sh" /usr/local/bin/dotfiles-greeter
# Remove a destination symlink rather than writing through it.
run sudo install -T --backup=numbered -o root -g root -m 644 "$source_config" /etc/greetd/config.toml
# Change boot selection only: --now would terminate the current desktop.
if [[ "$previous_manager" == sddm.service ]]; then
    run sudo systemctl disable sddm.service
fi
if ! run sudo systemctl enable greetd.service; then
    printf 'Failed to enable greetd. Restoring the previous boot selection.\n' >&2
    if [[ "$previous_manager" == sddm.service ]]; then
        sudo systemctl enable sddm.service || printf 'Restore SDDM manually: sudo systemctl enable sddm.service\n' >&2
    fi
    exit 1
fi
if $dry_run; then
    printf '\nWould select greetd for the next boot. No changes made.\n'
else
    printf '\nGraphical greeter installed. If greetd is running, log out when ready; otherwise reboot.\n'
fi
printf 'No running services were restarted. SDDM, if running, remains active until reboot.\n'
printf 'Rollback: sudo systemctl disable greetd.service && sudo systemctl enable sddm.service\n'

