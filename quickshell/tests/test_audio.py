import importlib.util
from pathlib import Path
import unittest
from unittest.mock import patch


spec = importlib.util.spec_from_file_location("audio", Path(__file__).parents[1] / "scripts/audio.py")
audio = importlib.util.module_from_spec(spec)
spec.loader.exec_module(audio)


def node(identifier, name, media_class, serial=None):
    return {"id": identifier, "type": "PipeWire:Interface:Node", "info": {"props": {
        "node.name": name, "media.class": media_class, "object.serial": serial or identifier,
    }}}


def link(source, target):
    return {"type": "PipeWire:Interface:Link", "info": {
        "output-node-id": source, "input-node-id": target,
    }}


class AudioRoutingTest(unittest.TestCase):
    def test_selection_moves_pinned_playback_without_changing_default(self):
        nodes = [node(61, "speakers", "Audio/Sink"), node(94, "headphones", "Audio/Sink"),
                 node(95, "player", "Stream/Output/Audio"),
                 node(103, "bluetooth-internal", "Stream/Input/Audio/Internal")]
        with patch.object(audio, "graph", side_effect=[nodes + [link(95, 94)], nodes + [link(95, 61)]]), \
                patch.object(audio, "run") as run:
            self.assertEqual(audio.apply("output", "select", "speakers"), {"name": "speakers"})
        run.assert_called_once_with("pw-metadata", "-n", "default", "95", "target.object", "speakers", "Spa:String")

    def test_input_selection_moves_capture_in_the_correct_direction(self):
        nodes = [node(57, "old-microphone", "Audio/Source"), node(58, "microphone", "Audio/Source"),
                 node(95, "recorder", "Stream/Input/Audio")]
        with patch.object(audio, "graph", side_effect=[nodes + [link(57, 95)], nodes + [link(58, 95)]]), \
                patch.object(audio, "run") as run:
            audio.apply("input", "select", "microphone")
        run.assert_called_once_with("pw-metadata", "-n", "default", "95", "target.object", "microphone", "Spa:String")

    def test_default_uses_pipewire_id_instead_of_pulse_serial(self):
        with patch.object(audio, "graph", return_value=[node(58, "microphone", "Audio/Source", serial=68)]), \
                patch.object(audio, "run") as run:
            audio.apply("input", "default", "microphone")
        run.assert_called_once_with("wpctl", "set-default", "58")

    def test_removed_device_is_rejected_before_modifying_routing(self):
        with patch.object(audio, "graph", return_value=[]), patch.object(audio, "run") as run:
            with self.assertRaisesRegex(ValueError, "no longer available"):
                audio.apply("output", "select", "gone")
        run.assert_not_called()

    def test_failed_routing_is_reported_even_when_metadata_command_succeeds(self):
        objects = [node(61, "speakers", "Audio/Sink"), node(94, "headphones", "Audio/Sink"),
                   node(95, "player", "Stream/Output/Audio"), link(95, 94)]
        with patch.object(audio, "graph", return_value=objects), patch.object(audio, "run"), \
                patch.object(audio.time, "monotonic", side_effect=[0, 3]):
            with self.assertRaisesRegex(RuntimeError, "could not switch"):
                audio.apply("output", "select", "speakers")

    def test_stream_closing_during_switch_is_not_a_failure(self):
        device = node(61, "speakers", "Audio/Sink")
        before = [device, node(95, "player", "Stream/Output/Audio"), link(95, 94)]
        with patch.object(audio, "graph", side_effect=[before, [device]]), patch.object(audio, "run"):
            self.assertEqual(audio.apply("output", "select", "speakers"), {"name": "speakers"})

    def test_device_disconnect_during_switch_is_reported(self):
        before = [node(61, "speakers", "Audio/Sink"), node(95, "player", "Stream/Output/Audio"), link(95, 94)]
        with patch.object(audio, "graph", side_effect=[before, []]), patch.object(audio, "run"):
            with self.assertRaisesRegex(RuntimeError, "disconnected"):
                audio.apply("output", "select", "speakers")


if __name__ == "__main__":
    unittest.main()
