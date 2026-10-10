import importlib.util
import json
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch, Mock

SCRIPTS = Path(__file__).resolve().parents[1] / "scripts"


def load(name):
    spec = importlib.util.spec_from_file_location(name.replace("-", "_"), SCRIPTS / (name + ".py"))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


lock = load("lock")
jokes = load("lock-joke")


class LockTests(unittest.TestCase):
    def test_capture_failure_does_not_prevent_lock(self):
        with tempfile.TemporaryDirectory() as temp, patch.object(lock.shutil, "which", return_value="grim"), \
                patch.object(lock.subprocess, "check_output", return_value=b'[{"name":"DP-1"}]'), \
                patch.object(lock.subprocess, "run", side_effect=subprocess.TimeoutExpired("grim", 1)):
            lock.capture_backgrounds(temp)
            self.assertEqual(list(Path(temp).iterdir()), [])

    def test_monitor_names_stay_inside_private_directory(self):
        with tempfile.TemporaryDirectory() as temp, patch.object(lock.shutil, "which", return_value="grim"), \
                patch.object(lock.subprocess, "check_output", return_value=b'[{"name":"../odd/output"}]'), \
                patch.object(lock.subprocess, "run") as run:
            lock.capture_backgrounds(temp)
            target = Path(run.call_args.args[0][-1])
            self.assertEqual(target.parent, Path(temp))
            self.assertEqual(target.name, "..%2Fodd%2Foutput.png")

    def test_success_cleans_snapshots_without_starting_fallback(self):
        with tempfile.TemporaryDirectory() as temp, patch.dict(lock.os.environ, {"XDG_RUNTIME_DIR": temp}), \
                patch.object(lock, "capture_backgrounds"), \
                patch.object(lock.subprocess, "run", return_value=Mock(returncode=0)) as run, \
                patch.object(lock.subprocess, "call") as fallback:
            self.assertEqual(lock.main(), 0)
            backgrounds = run.call_args.kwargs["env"]["QS_LOCK_BACKGROUNDS"]
            self.assertFalse(Path(backgrounds).exists())
            fallback.assert_not_called()

    def test_failed_quickshell_starts_existing_locker(self):
        with tempfile.TemporaryDirectory() as temp, patch.dict(lock.os.environ, {"XDG_RUNTIME_DIR": temp}), \
                patch.object(lock, "capture_backgrounds"), \
                patch.object(lock.subprocess, "run", return_value=Mock(returncode=1)), \
                patch.object(lock.subprocess, "call", return_value=0) as fallback:
            self.assertEqual(lock.main(), 0)
            fallback.assert_called_once_with(["hyprlock"])

    def test_duplicate_requests_do_not_start_another_locker(self):
        with tempfile.TemporaryDirectory() as temp, patch.dict(lock.os.environ, {"XDG_RUNTIME_DIR": temp}), \
                patch.object(lock.fcntl, "flock", side_effect=BlockingIOError), \
                patch.object(lock.subprocess, "run") as run:
            self.assertEqual(lock.main(), 0)
            run.assert_not_called()

    def test_offline_jokes_use_cache_or_builtin(self):
        with tempfile.TemporaryDirectory() as temp, patch.object(jokes.urllib.request, "urlopen", side_effect=OSError):
            cache = Path(temp) / "joke"
            self.assertEqual(jokes.joke(cache), jokes.FALLBACK)
            cache.write_text("Cached\nChuck Norris joke")
            self.assertEqual(jokes.joke(cache), "Cached Chuck Norris joke")

    def test_network_joke_is_plain_text_and_cached(self):
        response = Mock()
        response.read.return_value = json.dumps({"value": "Chuck Norris\nuses Vim."}).encode()
        context = Mock()
        context.__enter__ = Mock(return_value=response)
        context.__exit__ = Mock(return_value=False)
        with tempfile.TemporaryDirectory() as temp, patch.object(jokes.urllib.request, "urlopen", return_value=context):
            cache = Path(temp) / "joke"
            self.assertEqual(jokes.joke(cache), "Chuck Norris uses Vim.")
            self.assertEqual(cache.read_text(), "Chuck Norris uses Vim.")


if __name__ == "__main__":
    unittest.main()
