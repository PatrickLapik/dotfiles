pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property var items: []
    property string current: ""
    property var schemeTypes: []
    property string schemeType: "scheme-tonal-spot"
    readonly property int schemeIndex: schemeTypes.indexOf(schemeType)
    property string error: ""
    readonly property bool busy: selection.running
    readonly property bool scanning: discovery.running
    readonly property string script: decodeURIComponent(Qt.resolvedUrl("../scripts/wallpapers.py").toString().replace(/^file:\/\//, ""))
    readonly property url source: "file://" + current.split("/").map(encodeURIComponent).join("/")
    property string pendingResult: ""

    function refresh() {
        if (!discovery.running && !busy) {
            error = ""
            discovery.running = true
        }
    }
    function setScheme(index: int) {
        if (busy || scanning || index < 0 || index >= schemeTypes.length) return
        const scheme = schemeTypes[index]
        if (scheme === schemeType) return
        if (current) select(current, scheme)
        else schemeType = scheme
    }
    function select(path, scheme = root.schemeType) {
        if (busy || scanning) return
        error = ""
        pendingResult = ""
        selection.command = ["python3", script, "apply", path, scheme]
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
                    root.schemeTypes = result.schemeTypes
                    root.schemeType = result.schemeType
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
                try {
                    const result = JSON.parse(root.pendingResult)
                    root.current = result.current
                    root.schemeType = result.schemeType
                }
                catch (e) { root.error = "Could not read the selected wallpaper." }
            } else if (!root.error) root.error = "Could not change wallpaper. Check that Matugen is installed."
        }
    }
}
