#!/usr/bin/env python3
"""Create a self-contained greeter bundle, including current theme snapshot."""
import json
import os
import shutil
import sys
from pathlib import Path

root, dest = map(Path, sys.argv[1:])
# QML resolves singleton types and their imports across the shared tree, even
# when only the greeter entry point is instantiated. Keep those imports intact.
shutil.copytree(root / 'quickshell', dest / 'quickshell',
                ignore=shutil.ignore_patterns('__pycache__', '*.pyc', 'tests'))
config = Path(os.environ.get('XDG_CONFIG_HOME', Path.home() / '.config'))
state = Path(os.environ.get('XDG_STATE_HOME', Path.home() / '.local/state'))
wallpaper = root / 'wallpapers/default.jpg'
try:
    selected = Path(json.loads((state / 'quickshell/wallpaper.json').read_text())['current'])
    if selected.is_file():
        wallpaper = selected
except (OSError, ValueError, KeyError, TypeError):
    pass
shutil.copyfile(wallpaper, dest / 'wallpaper')
print('Wallpaper snapshot:', wallpaper)
theme = dest / 'theme/quickshell'
theme.mkdir(parents=True)
palette = config / 'quickshell/colors.json'
if palette.is_file():
    json.loads(palette.read_text())
    shutil.copyfile(palette, theme / 'colors.json')
(dest / 'username').write_text(os.environ.get('USER', '') + '\n')
