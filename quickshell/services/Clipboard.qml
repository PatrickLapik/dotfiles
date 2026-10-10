pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property var entries: []
    property string error: ""
    readonly property bool busy: worker.running
    signal copied()
    function request(action: string, id: string) {
        if (busy) return
        error = ""
        const script = decodeURIComponent(Qt.resolvedUrl("../scripts/clipboard.py").toString().replace(/^file:\/\//, ""))
        worker.command = ["python3", script, action, id]
        worker.running = true
    }
    function refresh() { request("list", "") }
    function copy(id: string) { request("copy", id) }
    function remove(id: string) { request("delete", id) }
    function clear() { request("wipe", "") }
    Process {
        id: worker
        onExited: (code, status) => {
            if (code !== 0 && root.error === "") root.error = "Clipboard operation failed"
        }
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const result = JSON.parse(text)
                    if (result.error) root.error = result.error
                    else if (result.copied) root.copied()
                    else root.entries = result.entries || []
                } catch (error) { root.error = "Could not read clipboard history" }
            }
        }
    }
}
