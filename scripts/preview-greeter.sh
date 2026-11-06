#!/usr/bin/env bash
# A normal desktop window; never connects to greetd or launches a session.
set -euo pipefail
DOTFILES_ROOT=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
if [[ $# -gt 1 || "${1:-}" == --help || "${1:-}" == -h ]]; then
    printf 'Usage: ./scripts/preview-greeter.sh [wallpaper-path]\n'
    exit 0
fi
command -v quickshell >/dev/null || { printf 'Install quickshell first.\n' >&2; exit 1; }
DOTFILES_GREETER_WALLPAPER=$(python3 - "$DOTFILES_ROOT" "${1:-}" <<'WALLPAPER'
import json, os, sys
from pathlib import Path
root = Path(sys.argv[1])
image = Path(sys.argv[2]).expanduser() if sys.argv[2] else None
if image is None:
    state = Path(os.environ.get('XDG_STATE_HOME', Path.home() / '.local/state')) / 'quickshell/wallpaper.json'
    try:
        image = Path(json.loads(state.read_text())['current'])
    except (OSError, ValueError, KeyError, TypeError):
        pass
    if image is None or not image.is_file():
        image = root / 'wallpapers/default.jpg'
if not image.is_file():
    sys.exit('Wallpaper does not exist: ' + str(image))
print(image.resolve().as_uri())
WALLPAPER
)
export DOTFILES_GREETER_MODE=preview
unset GREETD_SOCK
export DOTFILES_GREETER_WALLPAPER
exec quickshell -p "$DOTFILES_ROOT/quickshell/greeter.qml"
