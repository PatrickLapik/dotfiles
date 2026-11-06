pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property var sessions: []
    property int selectedIndex: 0
    readonly property var selected: sessions[selectedIndex] || null
    function select(index: int) {
        if (index >= 0 && index < sessions.length) selectedIndex = index
    }
    Process {
        command: ["python3", Qt.resolvedUrl("../scripts/greeter-sessions.py").toString().replace("file://", "")]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try { root.sessions = JSON.parse(text) }
                catch (error) { console.warn("Session discovery failed:", error) }
            }
        }
    }
}
