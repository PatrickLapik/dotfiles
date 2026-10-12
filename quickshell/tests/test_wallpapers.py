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
                command = run.call_args_list[-2].args[0]
                self.assertEqual(command[command.index("--type") + 1], scheme)
                self.assertEqual(wallpapers.scan()["schemeType"], scheme)
            wallpapers.apply(str(image))
            command = run.call_args_list[-2].args[0]
            self.assertEqual(command[command.index("--type") + 1], wallpapers.SCHEME_TYPES[-1])

    def test_failed_render_preserves_selection(self):
        image = wallpapers.images()[0]
        with tempfile.TemporaryDirectory() as temp, \
                patch.object(wallpapers, "STATE", Path(temp) / "state.json"), \
                patch.object(wallpapers, "CONFIG", Path(temp)), \
                patch.object(wallpapers.subprocess, "run", side_effect=[
                    Mock(returncode=0), Mock(returncode=1, stderr="No daemon")]):
            saved = json.dumps({"current": str(image), "schemeType": "scheme-neutral"})
            wallpapers.STATE.write_text(saved)
            with self.assertRaisesRegex(RuntimeError, "No daemon"):
                wallpapers.apply(str(image))
            self.assertEqual(wallpapers.STATE.read_text(), saved)

    def test_restore_waits_for_daemon_without_launching_it(self):
        image = wallpapers.images()[0]
        with patch.object(wallpapers, "scan", return_value={"current": str(image)}), \
                patch.object(wallpapers.subprocess, "run", side_effect=[
                    Mock(returncode=1), Mock(returncode=1), Mock(returncode=0)]), \
                patch.object(wallpapers.subprocess, "Popen") as launch, \
                patch.object(wallpapers.time, "sleep"), \
                patch.object(wallpapers, "render") as render:
            wallpapers.restore()
            launch.assert_not_called()
            render.assert_called_once_with(str(image), restore=True)

    def test_render_uses_transition_environment(self):
        with patch.dict(wallpapers.os.environ, {"AWWW_TRANSITION": "wave"}), \
                patch.object(wallpapers.subprocess, "run", return_value=Mock(returncode=0)) as run:
            wallpapers.render('/tmp/image with spaces.jpg')
            command = run.call_args.args[0]
            self.assertEqual(command[2], '/tmp/image with spaces.jpg')
            self.assertEqual(command[command.index('--transition-type') + 1], 'wave')
            wallpapers.render('/tmp/image.jpg', restore=True)
            command = run.call_args.args[0]
            self.assertEqual(command[command.index('--transition-type') + 1], 'none')

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
