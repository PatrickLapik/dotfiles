import importlib.util
from pathlib import Path
import unittest
from unittest.mock import Mock, patch

spec = importlib.util.spec_from_file_location('bluetooth', Path(__file__).parents[1] / 'scripts/bluetooth.py')
bluetooth = importlib.util.module_from_spec(spec)
spec.loader.exec_module(bluetooth)


class PairingAgentTest(unittest.TestCase):
    def setUp(self):
        self.agent = bluetooth.Agent.__new__(bluetooth.Agent)
        self.agent.device_path = '/org/bluez/hci0/dev_AA_BB_CC_DD_EE_FF'
        self.agent.pending = None
        self.reply, self.error = Mock(), Mock()
        self.emit = patch.object(bluetooth, 'emit').start()
        self.addCleanup(patch.stopall)

    def request(self, kind):
        self.agent.request(self.agent.device_path, kind, self.reply, self.error)

    def test_confirmation_waits_for_explicit_acceptance(self):
        self.request('confirm')
        self.reply.assert_not_called()
        self.agent.respond({'accept': True})
        self.reply.assert_called_once_with()
        self.error.assert_not_called()

    def test_rejection_returns_bluez_error(self):
        self.request('confirm')
        self.agent.respond({'accept': False})
        self.assertIsInstance(self.error.call_args.args[0], bluetooth.Rejected)
        self.reply.assert_not_called()
        self.assertIsNone(self.agent.pending)

    def test_invalid_passkey_keeps_prompt_open_for_retry(self):
        self.request('passkey')
        self.agent.respond({'accept': True, 'value': '12a'})
        self.reply.assert_not_called()
        self.assertIsNotNone(self.agent.pending)
        self.agent.respond({'accept': True, 'value': '000123'})
        self.reply.assert_called_once_with(bluetooth.dbus.UInt32(123))

    def test_pin_preserves_leading_zeroes_and_letters(self):
        self.request('pin')
        self.agent.respond({'accept': True, 'value': '00ab'})
        self.reply.assert_called_once_with('00ab')

    def test_unrelated_device_cannot_use_pairing_agent(self):
        self.agent.request('/org/bluez/hci0/other', 'confirm', self.reply, self.error)
        self.error.assert_called_once()
        self.reply.assert_not_called()
        self.assertIsNone(self.agent.pending)

    def test_cancel_releases_pending_callback(self):
        self.request('pin')
        self.agent.Cancel()
        self.error.assert_called_once()
        self.assertIsNone(self.agent.pending)

    def test_display_passkey_is_zero_padded(self):
        self.agent.DisplayPasskey(self.agent.device_path, 42, 2)
        self.emit.assert_called_once_with('prompt', kind='display', code='000042', entered=2)

    def test_pin_and_passkey_bounds(self):
        for kind, value in [('pin', ''), ('pin', 'a' * 17), ('passkey', '1000000'), ('passkey', '-1'), ('passkey', '１２３')]:
            with self.subTest(kind=kind, value=value), self.assertRaises(ValueError):
                bluetooth.pairing_value(kind, value)


if __name__ == '__main__':
    unittest.main()
