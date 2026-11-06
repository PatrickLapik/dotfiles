#!/usr/bin/env bash
set -euo pipefail
bundle=$(readlink -f /usr/local/share/dotfiles-greeter/current)
export DOTFILES_GREETER_MODE=login
wallpaper=/var/lib/dotfiles-greeter/assets/wallpaper
[[ -r "$wallpaper" ]] || wallpaper="$bundle/wallpaper"
export DOTFILES_GREETER_WALLPAPER="file://$wallpaper"
DOTFILES_GREETER_USER=$(cat "$bundle/username")
export DOTFILES_GREETER_USER
theme=/var/lib/dotfiles-greeter/assets/theme
[[ -r "$theme/quickshell/colors.json" ]] || theme="$bundle/theme"
export XDG_CONFIG_HOME="$theme"
export XDG_CACHE_HOME="${XDG_RUNTIME_DIR:?}/dotfiles-greeter-cache"
export QT_QPA_PLATFORM=wayland
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
# Cage owns the display until Quickshell exits after Greetd.launch().
# -d suppresses client decorations; the login window is also frameless/fullscreen.
# -s retains access to recovery TTYs; -m last avoids spanning multiple monitors.
exec /usr/bin/dbus-run-session -- /usr/bin/cage -d -s -m last -- /usr/bin/quickshell -p "$bundle/quickshell/greeter.qml"
