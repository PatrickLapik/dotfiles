#!/usr/bin/env python3
"""Start the independent session locker, with private, bounded screen captures."""
import concurrent.futures
import fcntl
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
from urllib.parse import quote

ROOT = Path(__file__).resolve().parents[1]


def capture_backgrounds(directory):
    if not shutil.which("grim"):
        return
    try:
        monitors = json.loads(subprocess.check_output(
            ["hyprctl", "-j", "monitors"], timeout=1, stderr=subprocess.DEVNULL))
        names = [m["name"] for m in monitors if isinstance(m.get("name"), str)]
    except (OSError, ValueError, subprocess.SubprocessError):
        return

    def capture(name):
        target = Path(directory) / (quote(name, safe="") + ".png")
        try:
            subprocess.run(["grim", "-s", "0.5", "-o", name, str(target)],
                           timeout=1, check=True, stderr=subprocess.DEVNULL)
        except (OSError, subprocess.SubprocessError):
            target.unlink(missing_ok=True)

    # Capture in parallel: a slow/off monitor cannot delay each of the others.
    with concurrent.futures.ThreadPoolExecutor(max_workers=16) as executor:
        list(executor.map(capture, names))


def main():
    runtime = Path(os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}"))
    os.umask(0o077)
    # Keep the guard until the locker exits; repeat requests never toggle it off.
    with (runtime / "quickshell-session-lock.guard").open("w") as guard:
        try:
            fcntl.flock(guard, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            return 0
        with tempfile.TemporaryDirectory(prefix="quickshell-lock-", dir=runtime) as backgrounds:
            capture_backgrounds(backgrounds)
            env = dict(os.environ, QS_LOCK_BACKGROUNDS=backgrounds)
            try:
                result = subprocess.run(["quickshell", "--no-duplicate", "-p",
                                         str(ROOT / "lockscreen.qml")], env=env)
                code = result.returncode
            except OSError:
                code = 1
            if code:
                # Preserve the existing locker as a recovery path for startup failure.
                return subprocess.call(["hyprlock"])
            return 0


if __name__ == "__main__":
    raise SystemExit(main())
