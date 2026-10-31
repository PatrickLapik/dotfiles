#!/usr/bin/env python3
"""Relay an interactive installer through a PTY and notify about waiting prompts.

Run inside Alacritty: python3 watch-installer.py -- yay
Use --demo for harmless prompts, including a nested PTY like sudo uses.
No terminal input is logged or included in notifications.
"""
import errno
import fcntl
import json
import os
import pty
import re
import select
import signal
import struct
import subprocess
import sys
import termios
import time
import tty

ANSI = re.compile(r"\x1b\][^\x07]*(?:\x07|\x1b\\)|\x1b\[[0-?]*[ -/]*[@-~]")
PROMPT = re.compile(
    r"\[[yn]/[yn]\]|\([yn]/[yn]\)|"
    r"(?:password|passphrase)[^\n]*:\s*$|"
    r"(?:enter|select|choose)[^\n]*(?:[:?>]|\[[^\]\n]*\])\s*$|"
    r"(?:packages to (?:exclude|update)|diffs to show|packages to cleanbuild)[^\n]*$|"
    r"(?:proceed|continue|are you sure)[^\n]*\?\s*$",
    re.IGNORECASE,
)


class PromptDetector:
    def __init__(self):
        self.buffer = ""
        self.last_output = 0.0
        self.notified = False

    def output(self, data, now):
        self.buffer = (self.buffer + data.decode("utf-8", errors="replace"))[-8192:]
        self.last_output = now

    def answered(self):
        self.buffer = ""
        self.notified = False

    def waiting(self, now):
        # Match the current terminal line, including prompts without a newline.
        # Keep escape sequences until stripping so split ANSI codes still work.
        line = ANSI.sub("", self.buffer).replace("\r", "\n").split("\n")[-1]
        return (not self.notified and now - self.last_output >= 1.5
                and bool(PROMPT.search(line)))


def hypr(query):
    result = subprocess.run(["hyprctl", "-j", query], capture_output=True,
                            text=True, timeout=2, check=True)
    return json.loads(result.stdout)


def window_address():
    ancestors = set()
    pid = os.getpid()
    while pid > 1:
        ancestors.add(pid)
        with open(f"/proc/{pid}/stat") as stat:
            pid = int(stat.read().rsplit(")", 1)[1].split()[1])
    for client in hypr("clients"):
        if client.get("pid") in ancestors:
            return client["address"]
    raise RuntimeError("Could not identify this terminal's Hyprland window")


def write_all(fd, data):
    while data:
        try:
            count = os.write(fd, data)
        except InterruptedError:
            continue
        data = data[count:]


def demo_command():
    # The second prompt runs in a new controlling PTY, exercising the boundary
    # missed by the old SIGTTIN demo. This does not invoke sudo or update anything.
    return [sys.executable, "-c", """
import os, pty, sys, time
time.sleep(6)
input('Packages to update (eg: 1 2 3): ')
time.sleep(6)
pid, fd = pty.fork()
if pid == 0:
    input('Proceed with installation? [Y/n] ')
    time.sleep(6)
    input('Second confirmation? [y/N] ')
    print('Demo complete', flush=True)
    os._exit(0)
pty._copy(fd)
_, status = os.waitpid(pid, 0)
sys.exit(os.waitstatus_to_exitcode(status))
"""]


def main():
    args = sys.argv[1:]
    if args == ["--demo"]:
        args = demo_command()
    elif args[:1] == ["--"]:
        args = args[1:]
    if not args:
        print("Usage: watch-installer.py --demo | -- COMMAND [ARGS...]", file=sys.stderr)
        return 2
    address = window_address()
    input_fd = sys.stdin.fileno()
    original_modes = termios.tcgetattr(input_fd)
    size = fcntl.ioctl(input_fd, termios.TIOCGWINSZ, struct.pack("HHHH", 0, 0, 0, 0))
    pid, master = pty.fork()
    if pid == 0:
        try:
            fcntl.ioctl(0, termios.TIOCSWINSZ, size)
            os.execvp(args[0], args)
        except OSError as error:
            print(f"Installer: {error}", file=sys.stderr, flush=True)
            os._exit(127)

    def resize(signum, frame):
        current = fcntl.ioctl(input_fd, termios.TIOCGWINSZ, size)
        fcntl.ioctl(master, termios.TIOCSWINSZ, current)

    def terminate(signum, frame):
        raise SystemExit(128 + signum)

    handlers = {sig: signal.signal(sig, handler) for sig, handler in (
        (signal.SIGWINCH, resize), (signal.SIGTERM, terminate),
        (signal.SIGHUP, terminate))}
    detector = PromptDetector()
    notifications = []
    child_status = None
    next_focus_check = 0.0
    focused = True
    try:
        tty.setraw(input_fd)
        while True:
            ready, _, _ = select.select([input_fd, master], [], [], 0.2)
            now = time.monotonic()
            if master in ready:
                try:
                    output = os.read(master, 65536)
                except OSError as error:
                    if error.errno != errno.EIO:
                        raise
                    break
                if not output:
                    break
                write_all(sys.stdout.fileno(), output)
                detector.output(output, now)
            if input_fd in ready:
                data = os.read(input_fd, 4096)
                if not data:
                    break
                write_all(master, data)
                detector.answered()
            if now >= next_focus_check:
                try:
                    focused = hypr("activewindow").get("address") == address
                except (OSError, ValueError, subprocess.SubprocessError):
                    # A missed focus query should not suppress a waiting alert.
                    focused = False
                next_focus_check = now + 0.5
            notifications = [proc for proc in notifications if proc.poll() is None]
            if not focused and detector.waiting(now):
                try:
                    notifications.append(subprocess.Popen(
                        ["notify-send", "Updates need your attention",
                         "Return to the update terminal to answer the installer prompt."],
                        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL))
                except OSError:
                    pass
                else:
                    detector.notified = True
        _, child_status = os.waitpid(pid, 0)
        code = os.waitstatus_to_exitcode(child_status)
        return code if code >= 0 else 128 - code
    finally:
        termios.tcsetattr(input_fd, termios.TCSADRAIN, original_modes)
        os.close(master)
        if child_status is None:
            # Closing the PTY also hangs up the child's terminal. Reap the
            # direct child without leaving a stopped installer behind.
            try:
                os.kill(pid, signal.SIGHUP)
            except ProcessLookupError:
                pass
            os.waitpid(pid, 0)
        for sig, handler in handlers.items():
            signal.signal(sig, handler)


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, ValueError, RuntimeError, subprocess.SubprocessError) as error:
        print(f"Installer watcher: {error}", file=sys.stderr)
        sys.exit(1)
