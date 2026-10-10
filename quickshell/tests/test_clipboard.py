import importlib.util
import json
import os
from pathlib import Path
import signal
import shutil
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch


BRIDGE = Path(__file__).parents[1] / "scripts/clipboard.py"
spec = importlib.util.spec_from_file_location("clipboard", BRIDGE)
clipboard = importlib.util.module_from_spec(spec)
spec.loader.exec_module(clipboard)


class ClipboardCopyTest(unittest.TestCase):
    def run_copy(self, fails=False):
        with tempfile.TemporaryDirectory(prefix="clipboard-test-") as directory:
            root = Path(directory)
            payload = b"  clipboard text\n\x00\xff\r\n"
            (root / "payload").write_bytes(payload)
            (root / "cliphist").write_text(
                f"#!{sys.executable}\n"
                "import os, pathlib, sys\n"
                "assert sys.argv[1:] == ['decode', '123']\n"
                "sys.stdout.buffer.write((pathlib.Path(os.environ['CLIPBOARD_TEST_DIR']) / 'payload').read_bytes())\n"
            )
            (root / "wl-copy").write_text(
                f"#!{sys.executable}\n"
                "import os, pathlib, signal, sys\n"
                "root = pathlib.Path(os.environ['CLIPBOARD_TEST_DIR'])\n"
                "(root / 'received').write_bytes(sys.stdin.buffer.read())\n"
                "if os.environ.get('CLIPBOARD_TEST_FAIL'):\n"
                "    sys.stderr.write('Cannot connect to compositor\\n')\n"
                "    sys.exit(1)\n"
                "pid = os.fork()\n"
                "if pid:\n"
                "    (root / 'owner.pid').write_text(str(pid))\n"
                "    os._exit(0)\n"
                "# Match wl-copy: its background owner retains stderr until replaced.\n"
                "os.close(0)\n"
                "os.close(1)\n"
                "signal.pause()\n"
            )
            for command in ("cliphist", "wl-copy"):
                (root / command).chmod(0o700)
            env = dict(os.environ, PATH=str(root) + os.pathsep + os.environ["PATH"],
                       CLIPBOARD_TEST_DIR=str(root), CLIPBOARD_TEST_FAIL="1" if fails else "")
            try:
                result = subprocess.run([sys.executable, str(BRIDGE), "copy", "123"],
                                        env=env, capture_output=True, check=True, timeout=2)
                self.assertEqual((root / "received").read_bytes(), payload)
                return json.loads(result.stdout)
            finally:
                pid_file = root / "owner.pid"
                if pid_file.exists():
                    try:
                        os.kill(int(pid_file.read_text()), signal.SIGTERM)
                    except ProcessLookupError:
                        pass

    def test_copy_finishes_while_clipboard_owner_is_alive(self):
        self.assertEqual(self.run_copy(), {"copied": True})

    def test_copy_reports_compositor_errors(self):
        self.assertEqual(self.run_copy(fails=True), {"error": "Cannot connect to compositor"})


@unittest.skipUnless(shutil.which("cliphist"), "cliphist is not installed")
class CliphistIntegrationTest(unittest.TestCase):
    def test_restore_and_delete_with_real_id_parser(self):
        with tempfile.TemporaryDirectory(prefix="cliphist-test-") as directory:
            base = ["cliphist", "-db-path", str(Path(directory) / "db")]
            payload = b"  clipboard integration check\n\x00\xff\r\n"
            subprocess.run(base + ["store"], input=payload, check=True, capture_output=True)
            listing = subprocess.run(base + ["list"], check=True, capture_output=True).stdout
            ident = listing.split(b"\t", 1)[0].decode()
            original_run = clipboard.run

            def isolated_run(command, data=None):
                self.assertEqual(command[0], "cliphist")
                return original_run(base + command[1:], data)

            with patch.object(clipboard, "run", side_effect=isolated_run), \
                    patch.object(clipboard, "copy") as copy:
                with patch.object(sys, "argv", [str(BRIDGE), "copy", ident]):
                    self.assertEqual(clipboard.main(), {"copied": True})
                copy.assert_called_once_with(payload)
                with patch.object(sys, "argv", [str(BRIDGE), "delete", ident]):
                    self.assertEqual(clipboard.main(), {"entries": []})
            remaining = subprocess.run(base + ["list"], check=True, capture_output=True).stdout
            self.assertEqual(remaining, b"")


if __name__ == "__main__":
    unittest.main()
