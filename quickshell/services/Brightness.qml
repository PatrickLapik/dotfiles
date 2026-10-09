pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

Singleton {
    id: root
    property bool available: false
    property int percent: 0
    property string device: ""
    property int pending: -1
    property string error: ""

    function setPercent(value: real) {
        if (!available) return
        pending = Math.max(1, Math.min(100, Math.round(value)))
        flush()
    }
    function flush() {
        if (setter.running || pending < 0) return
        const value = pending
        pending = -1
        setter.command = ["brightnessctl", "-d", device, "set", value + "%"]
        setter.running = true
    }
    Process {
        id: query
        command: ["brightnessctl", "-m", "-c", "backlight", "info"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const fields = text.trim().split("\n").find(line => line.split(",")[1] === "backlight")
                if (!fields) { root.available = false; return }
                const parts = fields.split(",")
                const value = parseInt(parts[3])
                root.available = Number.isFinite(value)
                if (root.available) { root.device = parts[0]; root.percent = value }
            }
        }
    }
    Process {
        id: setter
        stderr: StdioCollector { onStreamFinished: root.error = text.trim() }
        onRunningChanged: {
            if (!running) {
                if (!query.running) query.running = true
                root.flush()
            }
        }
    }
    Timer {
        interval: Theme.brightnessPollInterval
        running: true
        repeat: true
        onTriggered: { if (!query.running && !setter.running) query.running = true }
    }
}
