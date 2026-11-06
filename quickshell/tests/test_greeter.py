"""Exercise the real Quickshell greetd client with a fake protocol socket.

No PAM authentication, desktop session, or power action is performed.
Run: python3 -m unittest discover -s quickshell/tests -p test_greeter.py -v
"""
import json
import os
from pathlib import Path
import socket
import struct
import subprocess
import tempfile
import threading
import unittest

ROOT = Path(__file__).resolve().parents[2]


def receive(conn):
    def read(size):
        data = b''
        while len(data) < size:
            chunk = conn.recv(size - len(data))
            if not chunk:
                raise EOFError('Greeter closed the socket')
            data += chunk
        return data
    return json.loads(read(struct.unpack('=I', read(4))[0]))


def send(conn, data):
    data = json.dumps(data).encode()
    conn.sendall(struct.pack('=I', len(data)) + data)


class GreeterTests(unittest.TestCase):
    def exercise(self, mode):
        with tempfile.TemporaryDirectory() as folder:
            folder = Path(folder)
            sock = socket.socket(socket.AF_UNIX)
            address = str(folder / 'greetd.sock')
            sock.bind(address)
            sock.listen(1)
            sock.settimeout(10)
            requests = []
            errors = []

            def server():
                try:
                    conn, _ = sock.accept()
                    with conn:
                        conn.settimeout(8)
                        attempt = 0
                        while True:
                            request = receive(conn)
                            requests.append(request)
                            kind = request['type']
                            if kind == 'create_session':
                                attempt += 1
                                send(conn, dict(type='auth_message', auth_message_type='secret', auth_message='Password:'))
                            elif kind == 'post_auth_message_response':
                                response = request.get('response')
                                if mode == 'retry' and attempt == 1:
                                    send(conn, dict(type='error', error_type='auth_error', description='Wrong password'))
                                elif mode in ('challenge', 'cancel') and response == 'demo':
                                    send(conn, dict(type='auth_message', auth_message_type='visible', auth_message='Verification code:'))
                                elif mode == 'info' and response == 'demo':
                                    send(conn, dict(type='auth_message', auth_message_type='info', auth_message='Welcome'))
                                else:
                                    send(conn, dict(type='success'))
                            elif kind == 'start_session':
                                send(conn, dict(type='success'))
                                break
                            elif kind == 'cancel_session':
                                send(conn, dict(type='success'))
                                if mode != 'retry':
                                    break
                except Exception as error:
                    errors.append(error)

            harness = folder / 'shell.qml'
            harness.write_text("""import QtQuick
import Quickshell
import %s
ShellRoot {
    property int retries: 0
    property var selected: ({id: "plasma.desktop", name: "Plasma", command: ["/fake/plasma", "arg with spaces"], desktop: "KDE"})
    GreeterAuth {
        id: auth
        preview: false
        onFocusResponse: {
            if (waiting) {
                if (%s === "cancel") { cancel(); exitTimer.start() }
                else Qt.callLater(() => submit("demo-user", "123456", selected))
            } else if (failed && retries++ === 0) {
                retryTimer.start()
            }
        }
    }
    Timer { interval: 100; running: true; onTriggered: auth.submit("demo-user", "demo", selected) }
    Timer { id: retryTimer; interval: 100; onTriggered: auth.submit("demo-user", "demo", selected) }
    Timer { id: exitTimer; interval: 100; onTriggered: Qt.quit() }
    Timer { interval: 5000; running: true; onTriggered: { console.error("TEST_TIMEOUT"); Qt.quit() } }
}
""" % (json.dumps((ROOT / 'quickshell/modules/greeter').as_uri()), json.dumps(mode)))
            worker = threading.Thread(target=server, daemon=True)
            worker.start()
            env = dict(os.environ, GREETD_SOCK=address, QT_QPA_PLATFORM='offscreen')
            try:
                result = subprocess.run(['quickshell', '-p', str(harness)], env=env,
                                        capture_output=True, text=True, timeout=9)
            except subprocess.TimeoutExpired as error:
                sock.close()
                self.fail(str(requests) + str(error.stdout)[-5000:] + str(error.stderr)[-1000:])
            worker.join(timeout=2)
            sock.close()
            self.assertFalse(worker.is_alive(), 'Protocol server did not finish')
            self.assertEqual(errors, [], str(errors) + result.stdout + result.stderr)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertNotIn('TEST_TIMEOUT', result.stdout + result.stderr)
            self.assertEqual(requests[0], dict(type='create_session', username='demo-user'))
            self.assertEqual(requests[1], dict(type='post_auth_message_response', response='demo'))
            if mode == 'cancel':
                self.assertEqual(requests[-1]['type'], 'cancel_session')
                self.assertFalse(any(r['type'] == 'start_session' for r in requests))
            else:
                launch = requests[-1]
                self.assertEqual(launch['type'], 'start_session')
                self.assertEqual(launch['cmd'], ['/fake/plasma', 'arg with spaces'])
                self.assertIn('XDG_CURRENT_DESKTOP=KDE', launch['env'])
                self.assertIn('XDG_SESSION_TYPE=wayland', launch['env'])
            if mode == 'retry':
                self.assertEqual(sum(r['type'] == 'create_session' for r in requests), 2)
            if mode == 'challenge':
                self.assertTrue(any(r.get('response') == '123456' for r in requests))

    def test_session_launch(self):
        self.exercise('success')

    def test_wrong_password_retry(self):
        self.exercise('retry')

    def test_additional_visible_challenge(self):
        self.exercise('challenge')

    def test_cancel_challenge(self):
        self.exercise('cancel')

    def test_informational_pam_message(self):
        self.exercise('info')

    def test_packaged_entry_modes(self):
        with tempfile.TemporaryDirectory() as folder:
            bundle = Path(folder)
            subprocess.run(['python3', str(ROOT / 'greetd/prepare.py'), str(ROOT), str(bundle)],
                           check=True, capture_output=True, text=True)
            self.assertTrue((bundle / 'wallpaper').is_file())
            for mode in ('preview', 'login'):
                env = dict(os.environ, QT_QPA_PLATFORM='offscreen', DOTFILES_GREETER_MODE=mode,
                           DOTFILES_GREETER_WALLPAPER=(bundle / 'wallpaper').as_uri(),
                           XDG_CONFIG_HOME=str(bundle / 'theme'))
                env.pop('GREETD_SOCK', None)
                with subprocess.Popen(['quickshell', '-p', str(bundle / 'quickshell/greeter.qml')],
                                      env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                      text=True) as process:
                    try:
                        output, _ = process.communicate(timeout=1)
                    except subprocess.TimeoutExpired:
                        process.terminate()
                        output, _ = process.communicate(timeout=3)
                    self.assertIn('Configuration Loaded', output, output)
                    self.assertNotIn('ERROR', output, output)
