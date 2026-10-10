#!/usr/bin/env python3
"""JSON bridge to cliphist; keep decoded clipboard bytes out of shell commands."""
import json
import subprocess
import sys
import tempfile


def run(command, data=None):
    return subprocess.run(command, input=data, stdout=subprocess.PIPE,
                          stderr=subprocess.PIPE, check=True).stdout


def copy(data):
    # wl-copy forks a clipboard owner that keeps stderr open. Capturing it in a
    # pipe waits for that owner to exit instead of reporting a successful copy.
    with tempfile.TemporaryFile() as errors:
        result = subprocess.run(['wl-copy'], input=data, stdout=subprocess.DEVNULL,
                                stderr=errors)
        if result.returncode:
            errors.seek(0)
            raise subprocess.CalledProcessError(result.returncode, result.args,
                                                stderr=errors.read())


def entries():
    result = []
    for line in run(['cliphist', 'list']).decode('utf-8', errors='replace').splitlines():
        ident, separator, preview = line.partition('\t')
        if separator and ident.isdigit():
            result.append({'id': ident, 'preview': preview,
                           'binary': '[[ binary data' in preview})
    return result


def main():
    action = sys.argv[1] if len(sys.argv) > 1 else 'list'
    if action in ('copy', 'delete'):
        ident = sys.argv[2]
        if not ident.isdigit():
            raise ValueError('Invalid clipboard entry')
        if action == 'copy':
            data = run(['cliphist', 'decode', ident])
            copy(data)
            return {'copied': True}
        run(['cliphist', 'delete'], ident.encode())
    elif action == 'wipe':
        run(['cliphist', 'wipe'])
    elif action != 'list':
        raise ValueError('Unknown clipboard action')
    return {'entries': entries()}


if __name__ == '__main__':
    try:
        print(json.dumps(main()))
    except (subprocess.CalledProcessError, OSError, ValueError, IndexError) as error:
        # Report tool failures without printing clipboard contents.
        message = error.stderr.decode(errors='replace').strip() if isinstance(error, subprocess.CalledProcessError) else str(error)
        print(json.dumps({'error': message or 'Clipboard operation failed'}))
