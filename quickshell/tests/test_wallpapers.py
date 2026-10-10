import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import Mock, patch

spec = importlib.util.spec_from_file_location(
    "wallpapers", Path(__file__).resolve().parents[1] / "scripts/wallpapers.py")
wallpapers = importlib.util.module_from_spec(spec)
spec.loader.exec_module(wallpapers)


class WallpaperSchemeTests(unittest.TestCase):
    def test_legacy_and_unknown_schemes_use_default(self):
        with tempfile.TemporaryDirectory() as temp, patch.object(wallpapers, "STATE", Path(temp) / "state.json"):
            for state in ({}, {"schemeType": "unknown"}):
                wallpapers.STATE.write_text(json.dumps(state))
                self.assertEqual(wallpapers.scan()["schemeType"], "scheme-tonal-spot")

    def test_generation_passes_and_persists_each_scheme(self):
        image = wallpapers.images()[0]
        with tempfile.TemporaryDirectory() as temp, \
                patch.object(wallpapers, "STATE", Path(temp) / "state.json"), \
                patch.object(wallpapers, "CONFIG", Path(temp)), \
                patch.object(wallpapers.subprocess, "run", return_value=Mock(returncode=0)) as run:
            for scheme in wallpapers.SCHEME_TYPES:
                wallpapers.apply(str(image), scheme)
                command = run.call_args.args[0]
                self.assertEqual(command[command.index("--type") + 1], scheme)
                self.assertEqual(wallpapers.scan()["schemeType"], scheme)
            wallpapers.apply(str(image))
            command = run.call_args.args[0]
            self.assertEqual(command[command.index("--type") + 1], wallpapers.SCHEME_TYPES[-1])

    def test_failed_generation_preserves_saved_scheme(self):
        image = wallpapers.images()[0]
        with tempfile.TemporaryDirectory() as temp, \
                patch.object(wallpapers, "STATE", Path(temp) / "state.json"), \
                patch.object(wallpapers, "CONFIG", Path(temp)), \
                patch.object(wallpapers.subprocess, "run", return_value=Mock(returncode=1, stderr="Failed")):
            saved = json.dumps({"current": str(image), "schemeType": "scheme-neutral"})
            wallpapers.STATE.write_text(saved)
            with self.assertRaises(RuntimeError):
                wallpapers.apply(str(image), "scheme-vibrant")
            self.assertEqual(wallpapers.STATE.read_text(), saved)
            with self.assertRaises(ValueError):
                wallpapers.apply(str(image), "unknown")


if __name__ == "__main__":
    unittest.main()
