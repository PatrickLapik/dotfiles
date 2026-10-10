"""Exercise the actual QML service with an isolated clipboard backend."""
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


@unittest.skipUnless(shutil.which('quickshell'), 'quickshell is not installed')
class ClipboardRefreshTest(unittest.TestCase):
    def test_queued_refreshes_unchanged_snapshots_failures_and_copy(self):
        with tempfile.TemporaryDirectory(prefix='clipboard-refresh-') as directory:
            base = Path(directory)
            for source in ROOT.iterdir():
                if source.is_dir():
                    (base / source.name).symlink_to(source, target_is_directory=True)
            runtime = base / 'runtime'
            runtime.mkdir(mode=0o700)
            commands = base / 'bin'
            commands.mkdir()
            (commands / 'cliphist').write_text(
                f'#!{sys.executable}\n'
                'import os, pathlib, sys, time\n'
                'counter = pathlib.Path(os.environ["CLIPBOARD_CHECK_COUNTER"])\n'
                'action = sys.argv[1]\n'
                'if action == "list":\n'
                '    count = int(counter.read_text()) + 1 if counter.exists() else 1\n'
                '    counter.write_text(str(count))\n'
                '    time.sleep(0.03)\n'
                '    if count == 4:\n'
                '        sys.stderr.write("backend unavailable")\n'
                '        sys.exit(1)\n'
                '    print("1\\tFixture entry")\n'
                'elif action == "decode":\n'
                '    sys.stdout.write("Fixture entry")\n'
                'else:\n'
                '    sys.exit(2)\n'
            )
            (commands / 'wl-copy').write_text(f'#!{sys.executable}\nimport sys\nsys.stdin.buffer.read()\n')
            for command in commands.iterdir():
                command.chmod(0o700)
            (base / 'shell.qml').write_text('''
import QtQuick
import Quickshell
import qs.services
ShellRoot {
    id: checks
    property int target: 0
    property string phase: "queue"
    property var snapshot: null
    property bool copied: false
    property var tickets: []
    function check(condition, message) {
        if (!condition) { console.log("CLIPBOARD_CHECK_FAILED", message); Qt.quit() }
        return condition
    }
    Component.onCompleted: { Clipboard.refresh(); target = Clipboard.refresh() }
    Connections {
        target: Clipboard
        function onCopied() { checks.copied = true }
        function onRefreshed(ticket, success) {
            checks.tickets.push(ticket)
            if (ticket < checks.target) return
            if (checks.phase === "queue") {
                if (!checks.check(success && checks.tickets.length === 2
                    && checks.tickets[0] === 1 && ticket === 3, "queue must coalesce after the active request")) return
                checks.snapshot = Clipboard.entries
                checks.phase = "unchanged"
                checks.target = Clipboard.refresh()
            } else if (checks.phase === "unchanged") {
                if (!checks.check(success && Clipboard.entries === checks.snapshot, "unchanged list replaced")) return
                checks.phase = "failure"
                checks.target = Clipboard.refresh()
            } else if (checks.phase === "failure") {
                if (!checks.check(!success && Clipboard.entries === checks.snapshot
                    && Clipboard.error === "backend unavailable", "failed refresh lost cached history")) return
                checks.phase = "recovery"
                checks.target = Clipboard.refresh()
            } else if (checks.phase === "recovery") {
                if (!checks.check(success && Clipboard.error === "", "refresh did not recover")) return
                checks.phase = "copy"
                // Start copying after the current completion handler has drained.
                Qt.callLater(() => {
                    Clipboard.copy("1")
                    checks.target = Clipboard.refresh()
                })
            } else if (checks.phase === "copy") {
                if (!checks.check(success && checks.copied, "refresh queued during copy did not finish")) return
                console.log("CLIPBOARD_CHECK_OK")
                Qt.quit()
            }
        }
    }
    Timer { interval: 5000; running: true; onTriggered: { console.log("CLIPBOARD_CHECK_FAILED timeout"); Qt.quit() } }
}
''')
            env = dict(os.environ, QT_QPA_PLATFORM='offscreen', XDG_RUNTIME_DIR=str(runtime),
                       PATH=str(commands) + os.pathsep + os.environ['PATH'],
                       CLIPBOARD_CHECK_COUNTER=str(base / 'counter'))
            env.pop('WAYLAND_DISPLAY', None)
            result = subprocess.run(['quickshell', '-p', str(base), '--no-color'],
                                    env=env, capture_output=True, text=True, timeout=10)
            output = result.stdout + result.stderr
            self.assertEqual(result.returncode, 0, output)
            self.assertNotIn('CLIPBOARD_CHECK_FAILED', output)
            self.assertIn('CLIPBOARD_CHECK_OK', output)


if __name__ == '__main__':
    unittest.main()
