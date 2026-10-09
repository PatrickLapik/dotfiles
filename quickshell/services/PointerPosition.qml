pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

// Compositor coordinates remain available when another surface owns pointer focus.
Singleton {
    id: root
    property point position: Qt.point(0, 0)
    property bool available: false

    function nearTop(screen: ShellScreen, height: real): bool {
        return available && !!screen
            && position.x >= screen.x && position.x < screen.x + screen.width
            && position.y >= screen.y && position.y < screen.y + height
    }

    Process {
        id: query
        command: ["hyprctl", "-j", "cursorpos"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const point = JSON.parse(text)
                    if (!Number.isFinite(point.x) || !Number.isFinite(point.y)) {
                        root.available = false
                        return
                    }
                    root.position = Qt.point(point.x, point.y)
                    root.available = true
                } catch (error) {
                    root.available = false
                }
            }
        }
    }
    Timer {
        interval: Theme.pointerPollInterval
        running: true
        repeat: true
        onTriggered: {
            if (!query.running) query.running = true
        }
    }
}
