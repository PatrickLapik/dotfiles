"""Discover wallpapers, render with awww, and regenerate application themes."""
import json
import os
import re
from pathlib import Path
import subprocess
import sys
import tempfile
import time

ROOT = Path(__file__).resolve().parents[2]
DIRECTORY = ROOT / 'wallpapers'
STATE = Path(os.environ.get('XDG_STATE_HOME', Path.home() / '.local/state')) / 'quickshell/wallpaper.json'
CONFIG = Path(os.environ.get('XDG_CONFIG_HOME', Path.home() / '.config'))
EXTENSIONS = {'.jpg', '.jpeg', '.png', '.webp', '.bmp'}
SCHEME_TYPES = (
    'scheme-content', 'scheme-expressive', 'scheme-fidelity', 'scheme-fruit-salad',
    'scheme-monochrome', 'scheme-neutral', 'scheme-rainbow', 'scheme-tonal-spot',
    'scheme-vibrant', 'scheme-smart',
)
DEFAULT_SCHEME = 'scheme-tonal-spot'


def render(path, restore=False):
    command = ['awww', 'img', str(path), '--resize', 'crop',
               '--transition-type', 'none' if restore else os.environ.get('AWWW_TRANSITION', 'grow'),
               '--transition-duration', os.environ.get('AWWW_TRANSITION_DURATION', '1'),
               '--transition-fps', os.environ.get('AWWW_TRANSITION_FPS', '60')]
    result = subprocess.run(command, capture_output=True, text=True, timeout=30)
    if result.returncode:
        raise RuntimeError(result.stderr.strip() or result.stdout.strip() or 'awww failed. Is awww-daemon running?')


def restore():
    """Restore the saved image once the Lua-autostarted renderer is ready."""
    for _ in range(50):
        if subprocess.run(['awww', 'query'], capture_output=True, timeout=5).returncode == 0:
            break
        time.sleep(0.1)
    else:
        raise RuntimeError('awww-daemon did not become ready.')
    current = scan()['current']
    if not current:
        available = images()
        current = str(available[0]) if available else ''
    if current:
        render(current, restore=True)


def images():
    return sorted((p for p in DIRECTORY.rglob('*') if p.is_file() and p.suffix.lower() in EXTENSIONS), key=lambda p: str(p).casefold())


def scan():
    current = ''
    scheme = DEFAULT_SCHEME
    try:
        state = json.loads(STATE.read_text())
        saved = state.get('current', '')
        if state.get('schemeType') in SCHEME_TYPES:
            scheme = state['schemeType']
        if Path(saved).is_file():
            current = saved
    except (OSError, ValueError):
        pass
    return {'current': current, 'schemeType': scheme, 'schemeTypes': SCHEME_TYPES,
            'items': [{'path': str(p), 'url': p.as_uri(), 'name': str(p.relative_to(DIRECTORY))} for p in images()]}


def apply(filename, scheme=None):
    if scheme is None:
        scheme = scan()['schemeType']
    if scheme not in SCHEME_TYPES:
        raise ValueError('Choose a supported Matugen color scheme type.')
    path = Path(filename).resolve()
    if not path.is_relative_to(DIRECTORY.resolve()) or path not in [p.resolve() for p in images()]:
        raise ValueError('Choose an image from the wallpapers directory.')
    output = CONFIG / 'quickshell/colors.json'
    output.parent.mkdir(parents=True, exist_ok=True)
    # Keep every configured template and hook; awww owns wallpaper rendering.
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
        result = subprocess.run(['matugen', '-c', str(config), '-m', 'dark', '--type', scheme, '--source-color-index', '0', 'image', str(path)], capture_output=True, text=True, timeout=120)
        if result.returncode:
            raise RuntimeError(result.stderr.strip() or result.stdout.strip() or 'Matugen failed.')
    render(path)
    STATE.parent.mkdir(parents=True, exist_ok=True)
    temporary = STATE.with_suffix('.tmp')
    temporary.write_text(json.dumps({'current': str(path), 'schemeType': scheme}))
    temporary.replace(STATE)
    return {'current': str(path), 'url': path.as_uri(), 'schemeType': scheme}


if __name__ == '__main__':
    try:
        if sys.argv[1:] == ['list']:
            print(json.dumps(scan()))
        elif sys.argv[1:] == ['restore']:
            restore()
        elif len(sys.argv) in (3, 4) and sys.argv[1] == 'apply':
            print(json.dumps(apply(sys.argv[2], sys.argv[3] if len(sys.argv) == 4 else None)))
        else:
            raise ValueError('Usage: wallpapers.py list | restore | apply PATH [SCHEME_TYPE]')
    except (OSError, ValueError, RuntimeError, subprocess.TimeoutExpired) as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)
