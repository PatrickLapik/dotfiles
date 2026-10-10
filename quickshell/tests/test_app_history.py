import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / 'scripts/app-history.py'


class AppHistoryTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.env = dict(os.environ, XDG_STATE_HOME=self.temp.name)
        self.path = Path(self.temp.name) / 'quickshell/app-history.json'

    def run_action(self, action, data=None):
        return subprocess.run(['python3', str(SCRIPT), action],
                              input=json.dumps(data) + '\n' if data is not None else None,
                              env=self.env, capture_output=True, text=True)

    def test_defaults_and_round_trip(self):
        self.assertEqual(json.loads(self.run_action('read').stdout), {'usage': {}, 'tracking': True})
        data = {'pins': ['app', 'app'], 'tracking': False,
                'usage': {'app': {'lastUsed': 123, 'lastVisit': 100, 'count': 4, 'title': 'private'}}}
        self.assertEqual(self.run_action('write', data).returncode, 0)
        result = json.loads(self.run_action('read').stdout)
        self.assertNotIn('pins', result)  # Old favorite data is ignored; history survives.
        self.assertFalse(result['tracking'])
        self.assertEqual(result['usage']['app']['count'], 4)
        self.assertNotIn('private', self.path.read_text())
        self.assertEqual(self.path.stat().st_mode & 0o777, 0o600)

    def test_bounds_and_invalid_numbers(self):
        usage = {str(i): {'lastUsed': i, 'count': -1} for i in range(250)}
        self.assertEqual(self.run_action('write', {'usage': usage}).returncode, 0)
        result = json.loads(self.run_action('read').stdout)['usage']
        self.assertEqual(len(result), 200)
        self.assertNotIn('0', result)
        self.assertEqual(result['249']['count'], 0)

    def test_bad_write_preserves_saved_history(self):
        self.run_action('write', {'usage': {'app': {'count': 2}}})
        before = self.path.read_bytes()
        self.assertNotEqual(self.run_action('write', {'usage': 'bad'}).returncode, 0)
        self.assertEqual(self.path.read_bytes(), before)

    def test_corrupt_history_is_reported_without_overwrite(self):
        self.path.parent.mkdir(parents=True)
        self.path.write_text('{broken')
        result = self.run_action('read')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('error', json.loads(result.stdout))
        self.assertEqual(self.path.read_text(), '{broken')


if __name__ == '__main__':
    unittest.main()
