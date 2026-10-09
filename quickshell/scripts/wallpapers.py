"""Discover wallpapers and regenerate application themes without wallpaper daemons."""
import json
import os
import re
from pathlib import Path
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[2]
DIRECTORY = ROOT / 'wallpapers'
STATE = Path(os.environ.get('XDG_STATE_HOME', Path.home() / '.local/state')) / 'quickshell/wallpaper.json'
CONFIG = Path(os.environ.get('XDG_CONFIG_HOME', Path.home() / '.config'))
EXTENSIONS = {'.jpg', '.jpeg', '.png', '.webp', '.bmp'}


def images():
    return sorted((p for p in DIRECTORY.rglob('*') if p.is_file() and p.suffix.lower() in EXTENSIONS), key=lambda p: str(p).casefold())


def scan():
    current = ''
    try:
        saved = json.loads(STATE.read_text()).get('current', '')
        if Path(saved).is_file():
            current = saved
    except (OSError, ValueError):
        pass
    return {'current': current, 'items': [{'path': str(p), 'url': p.as_uri(), 'name': str(p.relative_to(DIRECTORY))} for p in images()]}


def apply(filename):
    path = Path(filename).resolve()
    if not path.is_relative_to(DIRECTORY.resolve()) or path not in [p.resolve() for p in images()]:
        raise ValueError('Choose an image from the wallpapers directory.')
    output = CONFIG / 'quickshell/colors.json'
    output.parent.mkdir(parents=True, exist_ok=True)
    # Keep every configured template and hook, but let Quickshell render the wallpaper.
    matugen_directory = ROOT / 'matugen'
    config_text = (matugen_directory / 'config.toml').read_text()
    def disable_wallpaper(match):
        section = match.group(0)
        return re.sub(r'(?m)^set\s*=.*$', 'set = false', section)
    config_text = re.sub(r'(?ms)^\[config\.wallpaper\]\n.*?(?=^\[|\Z)', disable_wallpaper, config_text)
    with tempfile.TemporaryDirectory(prefix='quickshell-palette-') as tmp:
        config = Path(tmp) / 'config.toml'
        # Existing input paths are relative to the Matugen configuration directory.
        (Path(tmp) / 'templates').symlink_to(matugen_directory / 'templates', target_is_directory=True)
        config.write_text(config_text)
        result = subprocess.run(['matugen', '-c', str(config), '-m', 'dark', '--source-color-index', '0', 'image', str(path)], capture_output=True, text=True, timeout=120)
        if result.returncode:
            raise RuntimeError(result.stderr.strip() or result.stdout.strip() or 'Matugen failed.')
    STATE.parent.mkdir(parents=True, exist_ok=True)
    temporary = STATE.with_suffix('.tmp')
    temporary.write_text(json.dumps({'current': str(path)}))
    temporary.replace(STATE)
    return {'current': str(path), 'url': path.as_uri()}


if __name__ == '__main__':
    try:
        if sys.argv[1:] == ['list']:
            print(json.dumps(scan()))
        elif len(sys.argv) == 3 and sys.argv[1] == 'apply':
            print(json.dumps(apply(sys.argv[2])))
        else:
            raise ValueError('Usage: wallpapers.py list | apply PATH')
    except (OSError, ValueError, RuntimeError, subprocess.TimeoutExpired) as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)
