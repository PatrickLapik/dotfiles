#!/usr/bin/env python3
"""One Bluetooth operation with an application-scoped, JSON-speaking pairing agent."""
import json
import sys

import dbus
import dbus.service
from dbus.mainloop.glib import DBusGMainLoop
from gi.repository import GLib

AGENT = 'org.bluez.Agent1'
DEVICE = 'org.bluez.Device1'
PROPERTIES = 'org.freedesktop.DBus.Properties'


def emit(event, **data):
    print(json.dumps({'event': event, **data}), flush=True)


def pairing_value(kind, value):
    value = str(value)
    if kind == 'pin' and 1 <= len(value) <= 16:
        return value
    if kind == 'passkey' and value.isascii() and value.isdigit() and len(value) <= 6:
        return dbus.UInt32(int(value))
    raise ValueError('Enter a PIN of 1–16 characters.' if kind == 'pin' else 'Enter a numeric passkey of up to six digits.')


class Rejected(dbus.DBusException):
    _dbus_error_name = 'org.bluez.Error.Rejected'


class Agent(dbus.service.Object):
    def __init__(self, bus, path, device_path):
        super().__init__(bus, path)
        self.device_path = device_path
        self.pending = None

    def request(self, device, kind, reply, error, **data):
        if str(device) != self.device_path or self.pending:
            error(Rejected('Unexpected pairing request'))
            return
        self.pending = (kind, reply, error)
        emit('prompt', kind=kind, **data)

    def respond(self, data):
        if not self.pending:
            return
        kind, reply, error = self.pending
        if not data.get('accept', False):
            self.pending = None
            error(Rejected('Pairing canceled'))
        else:
            try:
                value = pairing_value(kind, data.get('value', '')) if kind in ('pin', 'passkey') else None
            except ValueError as exc:
                emit('validation', message=str(exc))
                return
            self.pending = None
            if value is None:
                reply()
            else:
                reply(value)
        emit('clear')

    @dbus.service.method(AGENT, in_signature='o', out_signature='s', async_callbacks=('reply', 'error'))
    def RequestPinCode(self, device, reply, error):
        self.request(device, 'pin', reply, error)

    @dbus.service.method(AGENT, in_signature='o', out_signature='u', async_callbacks=('reply', 'error'))
    def RequestPasskey(self, device, reply, error):
        self.request(device, 'passkey', reply, error)

    @dbus.service.method(AGENT, in_signature='ou', out_signature='', async_callbacks=('reply', 'error'))
    def RequestConfirmation(self, device, passkey, reply, error):
        self.request(device, 'confirm', reply, error, code=f'{int(passkey):06d}')

    @dbus.service.method(AGENT, in_signature='o', out_signature='', async_callbacks=('reply', 'error'))
    def RequestAuthorization(self, device, reply, error):
        self.request(device, 'authorize', reply, error)

    @dbus.service.method(AGENT, in_signature='os', out_signature='', async_callbacks=('reply', 'error'))
    def AuthorizeService(self, device, uuid, reply, error):
        self.request(device, 'authorize', reply, error)

    @dbus.service.method(AGENT, in_signature='os', out_signature='')
    def DisplayPinCode(self, device, pincode):
        if str(device) == self.device_path:
            emit('prompt', kind='display', code=str(pincode))

    @dbus.service.method(AGENT, in_signature='ouq', out_signature='')
    def DisplayPasskey(self, device, passkey, entered):
        if str(device) == self.device_path:
            emit('prompt', kind='display', code=f'{int(passkey):06d}', entered=int(entered))

    @dbus.service.method(AGENT, in_signature='', out_signature='')
    def Cancel(self):
        if self.pending:
            _, _, error = self.pending
            self.pending = None
            error(Rejected('Pairing canceled'))
        emit('clear')

    @dbus.service.method(AGENT, in_signature='', out_signature='')
    def Release(self):
        self.Cancel()


def main():
    action, device_path, timeout_ms = sys.argv[1:]
    if action not in ('connect', 'disconnect') or not device_path.startswith('/org/bluez/'):
        raise ValueError('Invalid Bluetooth operation')
    DBusGMainLoop(set_as_default=True)
    bus = dbus.SystemBus()
    loop = GLib.MainLoop()
    obj = bus.get_object('org.bluez', device_path)
    device = dbus.Interface(obj, DEVICE)
    properties = dbus.Interface(obj, PROPERTIES)
    agent_path = '/dotfiles/bluetooth_agent'
    agent = Agent(bus, agent_path, device_path)
    manager = dbus.Interface(bus.get_object('org.bluez', '/org/bluez'), 'org.bluez.AgentManager1')
    manager.RegisterAgent(agent_path, 'KeyboardDisplay')
    phase = 'disconnect' if action == 'disconnect' else 'connect'
    finished = False

    def finish(error=None):
        nonlocal finished
        if finished:
            return
        finished = True
        emit('error', message=str(error)) if error else emit('done')
        loop.quit()

    def connect():
        nonlocal phase
        phase = 'connect'
        device.Connect(reply_handler=lambda: finish(), error_handler=finish, timeout=int(timeout_ms) / 1000)

    def paired():
        try:
            properties.Set(DEVICE, 'Trusted', dbus.Boolean(True))
            connect()
        except dbus.DBusException as exc:
            finish(exc)

    def cancel(message='Pairing canceled'):
        if phase == 'pair':
            device.CancelPairing(reply_handler=lambda: None, error_handler=lambda _: None)
        elif phase == 'connect':
            device.Disconnect(reply_handler=lambda: None, error_handler=lambda _: None)
        agent.Cancel()
        finish(message)

    def read_input(source, condition):
        line = source.readline()
        if not line:
            cancel()
            return False
        try:
            data = json.loads(line)
            if data.get('cancel'):
                cancel()
            else:
                agent.respond(data)
        except (ValueError, TypeError) as exc:
            emit('validation', message=str(exc))
        return not finished

    GLib.io_add_watch(sys.stdin, GLib.IO_IN | GLib.IO_HUP, read_input)
    GLib.timeout_add(int(timeout_ms), lambda: (cancel('Bluetooth operation timed out. Try again.'), False)[1])
    if action == 'disconnect':
        device.Disconnect(reply_handler=lambda: finish(), error_handler=finish)
    elif properties.Get(DEVICE, 'Paired'):
        connect()
    else:
        phase = 'pair'
        device.Pair(reply_handler=paired, error_handler=finish, timeout=int(timeout_ms) / 1000)
    try:
        loop.run()
    finally:
        try:
            manager.UnregisterAgent(agent_path)
        except dbus.DBusException:
            pass


if __name__ == '__main__':
    try:
        main()
    except Exception as exc:
        emit('error', message=str(exc))
        sys.exit(1)
