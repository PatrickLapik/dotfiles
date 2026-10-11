import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class InstallerPreflightTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.repo = self.base / 'dotfiles'
        for name in ['alacritty', 'hypr', 'fastfetch', 'nvim', 'matugen', 'quickshell', 'starship', 'zsh', 'tmux', '.install']:
            (self.repo / name).mkdir(parents=True)
        self.config = self.base / 'config'
        self.bin = self.base / 'bin'
        self.bin.mkdir()
        self.calls = self.base / 'calls'
        stow = self.bin / 'stow'
        stow.write_text('#!/bin/sh\nprintf "%s\\n" "$*" >> "$TEST_CALLS"\necho \'WARNING: in simulation mode so not modifying filesystem.\' >&2\ncase "$*" in\n    *--simulate*hypr)\n        if [ "${TEST_CONFLICT:-0}" != 0 ]; then\n            echo \'CONFLICT: existing configuration file\' >&2\n            exit "$TEST_CONFLICT"\n        fi\n        ;;\nesac\n')
        stow.chmod(0o755)

    def run_links(self, dry_run, conflict='0'):
        env = dict(os.environ, DOTFILES_ROOT=str(self.repo), XDG_CONFIG_HOME=str(self.config),
                   PATH=str(self.bin) + ':' + os.environ['PATH'], TEST_CALLS=str(self.calls), TEST_CONFLICT=conflict)
        return subprocess.run(['bash', '-c', 'set -euo pipefail; dry_run=$1; source "$2"', 'test',
                               'true' if dry_run else 'false', str(ROOT / 'create-symlinks.sh')],
                              env=env, capture_output=True, text=True)

    def test_dry_run_does_not_create_missing_config_directories(self):
        result = self.run_links(True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(self.config.exists())
        self.assertNotIn('WARNING: in simulation mode', result.stderr)
        self.assertIn('Checking configuration links for conflicts', result.stdout)
        self.assertTrue(all('--simulate' in line for line in self.calls.read_text().splitlines()))

    def test_conflict_aborts_before_any_real_stow(self):
        (self.config / 'hypr').mkdir(parents=True)
        result = self.run_links(False, '1')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('CONFLICT: existing configuration file', result.stderr)
        self.assertFalse((self.config / 'alacritty').exists())
        self.assertTrue(all('--simulate' in line for line in self.calls.read_text().splitlines()))


if __name__ == '__main__':
    unittest.main()
