pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property var items: []
    property string current: ""
    property string error: ""
    readonly property bool busy: selection.running
    readonly property bool scanning: discovery.running
    readonly property string script: decodeURIComponent(Qt.resolvedUrl("../scripts/wallpapers.py").toString().replace(/^file:\/\//, ""))
    readonly property url source: current ? "file://" + current.split("/").map(encodeURIComponent).join("/") : Qt.resolvedUrl("../assets/Wallpaper.jpg")
    property string pendingResult: ""

    function refresh() {
        if (!discovery.running && !busy) {
            error = ""
            discovery.running = true
        }
    }
    function select(path: string) {
        if (busy || scanning) return
        error = ""
        pendingResult = ""
        selection.command = ["python3", script, "apply", path]
        selection.running = true
    }
    Component.onCompleted: refresh()

    Process {
        id: discovery
        command: ["python3", root.script, "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const result = JSON.parse(text)
                    root.items = result.items
                    root.current = result.current
                } catch (e) { root.error = "Could not read wallpaper list." }
            }
        }
        stderr: StdioCollector { onStreamFinished: { if (text.trim()) root.error = text.trim() } }
    }
    Process {
        id: selection
        stdout: StdioCollector { onStreamFinished: root.pendingResult = text }
        stderr: StdioCollector { onStreamFinished: { if (text.trim()) root.error = text.trim() } }
        onExited: (code, status) => {
            if (code === 0) {
                try { root.current = JSON.parse(root.pendingResult).current }
                catch (e) { root.error = "Could not read the selected wallpaper." }
            } else if (!root.error) root.error = "Could not change wallpaper. Check that Matugen is installed."
        }
    }
}
