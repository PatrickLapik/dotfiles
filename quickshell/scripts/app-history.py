#!/usr/bin/env python3
"""Read/write bounded launcher state; no window titles or search text are stored."""
import json
import math
import os
from pathlib import Path
import sys
import tempfile


def normalize(data):
    if not isinstance(data, dict):
        raise ValueError('Invalid launcher history')
    usage = data.get('usage', {})
    if not isinstance(usage, dict):
        raise ValueError('Invalid launcher history')
    def valid_id(value):
        return isinstance(value, str) and 0 < len(value) <= 512
    def number(value):
        return value if isinstance(value, (int, float)) and math.isfinite(value) and value >= 0 else 0
    clean = {}
    for app, entry in usage.items():
        if valid_id(app) and isinstance(entry, dict):
            clean[app] = {key: number(entry.get(key, 0)) for key in ('lastUsed', 'lastVisit', 'count')}
    clean = dict(sorted(clean.items(), key=lambda pair: pair[1]['lastUsed'], reverse=True)[:200])
    return {'usage': clean, 'tracking': data.get('tracking', True) is not False}


def main():
    path = Path(os.environ.get('XDG_STATE_HOME') or Path.home() / '.local/state') / 'quickshell/app-history.json'
    if sys.argv[1] == 'read':
        data = json.loads(path.read_text()) if path.exists() else {}
        print(json.dumps(normalize(data)))
    elif sys.argv[1] == 'write':
        data = normalize(json.loads(sys.stdin.readline()))
        path.parent.mkdir(parents=True, exist_ok=True)
        name = None
        try:
            with tempfile.NamedTemporaryFile(mode='w', dir=path.parent, delete=False) as file:
                name = file.name
                json.dump(data, file)
                file.flush()
                os.fsync(file.fileno())
            os.replace(name, path)
        finally:
            if name and os.path.exists(name):
                os.unlink(name)
    else:
        raise ValueError('Unknown action')


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError, IndexError) as error:
        print(json.dumps({'error': str(error)}))
        sys.exit(1)
