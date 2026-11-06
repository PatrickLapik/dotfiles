#!/usr/bin/env python3
"""List available Wayland sessions; discovery only, never executes commands."""
import configparser
import json
import shutil
import shlex
from pathlib import Path

sessions = []
for path in sorted(Path('/usr/share/wayland-sessions').glob('*.desktop')):
    entry = configparser.ConfigParser(interpolation=None, strict=False)
    try:
        entry.read(path, encoding='utf-8')
        data = entry['Desktop Entry']
        if data.get('Hidden', 'false').lower() == 'true':
            continue
        command = data.get('Exec', '').strip()
        executable = data.get('TryExec', '').strip()
        if not command or (executable and not shutil.which(executable)):
            continue
        # Session commands are argument vectors, never interpolated into a shell.
        # File/URL field codes are inappropriate for a login session.
        argv = shlex.split(command)
        if not argv or any('%' in arg.replace('%%', '') for arg in argv):
            continue
        argv = [arg.replace('%%', '%') for arg in argv]
        if not shutil.which(argv[0]):
            continue
        sessions.append(dict(id=path.name, name=data.get('Name', path.stem),
                             command=argv, desktop=data.get('DesktopNames', '').strip(';').replace(';', ':')))
    except (OSError, UnicodeError, configparser.Error, KeyError, ValueError):
        continue
sessions.sort(key=lambda s: (s['id'] != 'hyprland.desktop', s['name'].casefold()))
print(json.dumps(sessions))
