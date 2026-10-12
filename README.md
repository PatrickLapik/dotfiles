# Personal Hyprland and Quickshell dotfiles

Quickshell provides the bar, launcher, notifications, clipboard, wallpaper picker,
media, network, Bluetooth, audio, brightness, power menu, and session lock.
Hypridle controls idle locking and suspend. Hyprlock remains the recovery locker
and provides the PAM policy used by Quickshell.

## Setup

Keep the checkout at `~/dotfiles`; runtime helpers and preferences use this path.
Review `hypr/hyprland.lua`, the files in `hypr/conf/`, and the browser, terminal,
and file-manager commands in `.settings/` for your machine.

```sh
./install.sh --dry-run             # Check Stow conflicts and preview changes
./install.sh                       # Link configuration and check dependencies
./install.sh --packages            # Also install packages using pacman and yay
./install.sh --dry-run --packages  # Preview package commands without running them
```

The installer requires GNU Stow and Python. Package installation is for Arch
Linux and requires an existing `yay` installation. It performs a full pacman
upgrade and leaves package-manager confirmation prompts enabled. No packages
are automatically uninstalled. Personal apps configured in autostart, such as
Zen Browser, Vesktop, CoreCtrl, and Syncthing, must also be installed as needed.

Every existing Stow target is checked before links are applied. Conflicting
regular files are reported for you to move or back up; the installer does not
adopt or overwrite them. The installer links this checkout directly and does
not copy upstream releases, restore old ML4W settings, change keyboard layouts,
or reboot the machine.

Enable NetworkManager and BlueZ on machines that need them. The installer's
final diagnostics report missing runtime commands, inactive services, and
missing Bluetooth/PAM dependencies. Launch the configured Hyprland session
normally to start Quickshell and Hypridle.

For SDDM, `./install.sh --sddm` additionally copies the Monochrome theme and
`sddm/default.conf` to their system locations, replacing matching destination
files. It does not enable a display manager or replace its service. Preview
with `--dry-run --sddm` first.

## Daily use

Use `scripts/widget.sh list` for available widgets and
`scripts/widget.sh <name> [open|toggle|close]` to control them. See
[Quickshell theming and configuration](quickshell/THEMING.md) for details.

`awww` renders the desktop wallpaper independently of Quickshell. Hyprland starts
`awww-daemon` directly from Lua autostart, then a separate helper restores the
saved wallpaper (or the first bundled image on a
fresh session). The Quickshell picker applies wallpapers through `awww` and keeps
generating application colors with Matugen. Install both `awww` and `matugen`.

Wallpaper changes use a one-second growing-circle transition at 60 FPS. Set
`AWWW_TRANSITION`, `AWWW_TRANSITION_DURATION`, and `AWWW_TRANSITION_FPS` in the
session environment to customize it; other `awww` transition variables also work.
With the daemon running, restore the wallpaper manually with
`python3 ~/.config/quickshell/scripts/wallpapers.py restore`.
Matugen still generates colors for Quickshell, GTK, Qt, Alacritty, Neovim, tmux,
and Gum. The package-update button uses `scripts/updates.sh` and
`scripts/installupdates.sh`; keep those helpers and their dependencies.

The small `app-launcher.sh`, `cliphist.sh`, and `wlogout.sh` scripts remain
compatibility names for the shared Quickshell widget launcher. Other personal
scripts are optional utilities; for example, `scripts/templates.sh` still needs
Rofi if you choose to use it.

Update this checkout through Git. The obsolete upstream ML4W downloader and
AppImage uninstaller have been removed. To unlink a configuration later, use
GNU Stow's delete mode with the same package and target as the installer.
