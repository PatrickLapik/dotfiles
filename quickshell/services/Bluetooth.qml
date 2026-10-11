pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth as BT
import qs.config

Singleton {
    id: root
    readonly property BT.BluetoothAdapter adapter: BT.Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool enabled: available && adapter.enabled
    readonly property bool blocked: available && adapter.state === BT.BluetoothAdapterState.Blocked
    readonly property bool powerChanging: available && (adapter.state === BT.BluetoothAdapterState.Enabling || adapter.state === BT.BluetoothAdapterState.Disabling)
    readonly property bool discovering: available && adapter.discovering
    readonly property var devices: adapter ? adapter.devices.values.slice().sort((a, b) =>
        Number(b.connected) - Number(a.connected) || Number(b.paired) - Number(a.paired)
        || (a.name || a.address).localeCompare(b.name || b.address)) : []
    readonly property var connectedDevices: devices.filter(device => device.connected)
    readonly property string icon: enabled ? "bluetooth" : "bluetooth-off"
    readonly property string details: !available ? "No Bluetooth adapter available" : blocked ? "Bluetooth is blocked"
        : !enabled ? "Bluetooth is off" : connectedDevices.length ? connectedDevices.map(device => device.name || device.address).join(", ") : "Bluetooth is on"
    property bool menuOpen: false
    property bool scanRequested: true
    property string error: ""
    property string operationName: ""
    property string operationPath: ""
    property string operationAction: ""
    property var prompt: null
    readonly property bool busy: operation.running
    readonly property string script: decodeURIComponent(Qt.resolvedUrl("../scripts/bluetooth.py").toString().replace(/^file:\/\//, ""))

    Binding {
        target: root.adapter
        property: "discovering"
        when: root.adapter !== null
        value: root.menuOpen && root.enabled && root.scanRequested && !root.busy
        restoreMode: Binding.RestoreBindingOrValue
    }
    onMenuOpenChanged: {
        if (menuOpen) { scanRequested = true; error = "" }
        else if (busy) cancel()
    }
    onEnabledChanged: if (!enabled && busy) cancel()
    onAdapterChanged: if (busy) cancel()

    function setEnabled(value: bool) {
        if (!available || blocked || powerChanging) return
        error = ""
        if (busy) cancel()
        adapter.enabled = value
    }
    function toggleScan() { scanRequested = !scanRequested }
    function selectDevice(device) {
        if (!device || busy || !enabled || device.blocked || device.pairing
            || device.state === BT.BluetoothDeviceState.Connecting || device.state === BT.BluetoothDeviceState.Disconnecting) return
        error = ""
        prompt = null
        operationName = device.name || device.address
        operationPath = device.dbusPath
        operationAction = device.connected ? "disconnect" : "connect"
        operation.command = ["python3", script, operationAction, operationPath, String(Theme.bluetoothOperationTimeout)]
        operation.running = true
    }
    function respond(accept: bool, value: string) {
        if (!busy || !prompt) return
        error = ""
        operation.write(JSON.stringify({accept: accept, value: value}) + "\n")
    }
    function cancel() {
        if (busy) operation.write(JSON.stringify({cancel: true}) + "\n")
        prompt = null
    }
    function receive(line) {
        try {
            const data = JSON.parse(line)
            if (data.event === "prompt") prompt = data
            else if (data.event === "clear") prompt = null
            else if (data.event === "error" || data.event === "validation") error = data.message
        } catch (exception) { error = "Could not read Bluetooth response." }
    }
    Process {
        id: operation
        stdinEnabled: true
        stdout: SplitParser { onRead: line => root.receive(line) }
        stderr: StdioCollector {
            onStreamFinished: if (text.trim()) root.error = text.trim()
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0 && !root.error) root.error = "Bluetooth operation failed. Check that python-dbus and python-gobject are installed."
            root.prompt = null
            root.operationPath = ""
            root.operationName = ""
        }
    }
}
